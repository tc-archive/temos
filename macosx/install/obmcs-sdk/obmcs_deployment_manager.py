#!/usr/bin/env python
import json
import logging
import pprint
import ssl
import sys
import time
import oraclebmc

from oraclebmc.config import validate_config
from oraclebmc.core.models import AttachVolumeDetails
from oraclebmc.core.models import CreateSubnetDetails
from oraclebmc.core.models import CreateVolumeDetails
from oraclebmc.core.models import CreateVcnDetails
from oraclebmc.core.models import LaunchInstanceDetails
from oraclebmc.identity.models import CreateUserDetails

#---------------------------------------------------------------------------------------------------
# volumes

def init_storage(config):
    return oraclebmc.core.blockstorage_client.BlockstorageClient(config)

def find_volume(storage_client, compartment_ocid, volume_name):
    volumes = storage_client.list_volumes(compartment_id=compartment_ocid).data
    volume = filter(lambda x : x.display_name == volume_name and x.lifecycle_state == "AVAILABLE", volumes)
    if len(volume) > 0:
        log.debug("found available volume: {}".format(volume[0]))
        return volume[0]
    else:
        return None

def create_volume(storage_client, compartment_ocid, subnet_availability_domain, volume_spec, synchronous=True, attempts=30, period=2):
    log.debug("creating volume...")
    request = CreateVolumeDetails()
    request.compartment_id = compartment_ocid
    request.display_name = volume_spec["display_name"]
    request.availability_domain = subnet_availability_domain
    request.size_in_mbs = volume_spec["size_in_mbs"]
    # requst.volume_backup_id=
    request.description = "Created with the Python SDK"
    response = storage_client.create_volume(request)
    volume = response.data
    if synchronous:
        volume = wait_for_obmcs_entity_state(lambda : storage_client.get_volume(volume.id).data, "AVAILABLE", attempts, period)
    log.debug("created volume: {}".format(volume))
    return volume

def destroy_volume(storage_client, volume_ocid, synchronous=True, attempts=30, period=2):
    log.debug("destroying volume: {}".format(volume_ocid))
    response = storage_client.delete_volume(volume_ocid)
    volume = response.data
    if synchronous:
        volume = wait_for_obmcs_entity_state(lambda : storage_client.get_volume(volume_ocid).data, "TERMINATED", attempts, period)
    log.debug("destroyed volume: {}".format(volume_ocid))
    return volume

def process_volume_specs(config, operation, compartment_ocid, subnet_availability_domain, volume_specs, attach_instance_ocid=None):
    volumes_info = []
    for volume_spec in volume_specs:
        volume_info = process_volume_spec(config, operation, compartment_ocid, subnet_availability_domain, volume_spec, attach_instance_ocid)
        if volume_info is not None:
            volumes_info.append(volume_info)
    return volumes_info

def process_volume_spec(config, operation, compartment_ocid, subnet_availability_domain, volume_spec, attach_instance_ocid=None):
    volume_name = volume_spec["display_name"]
    storage_client = init_storage(config)
    compute_client = init_compute(config)
    volume = find_volume(storage_client, compartment_ocid, volume_name)
    volume_attachment = None
    # handle op
    if operation == Operation.CREATE:
        log.debug("create process_volume_spec: {}".format(operation))
        if is_unprovisioned(volume):
            volume = create_volume(storage_client, compartment_ocid, subnet_availability_domain, volume_spec)
        if attach_instance_ocid is not None:
            volume_attachment = find_volume_attachment(compute_client, compartment_ocid, attach_instance_ocid, volume.id)
            if volume_attachment is None:
                volume_attachment = attach_volume(compute_client, attach_instance_ocid, volume.id, volume_spec)
    elif operation == Operation.DESTROY and volume is not None :
        log.debug("destroy process_volume_spec: {}".format(operation))
        if attach_instance_ocid is not None:
            volume_attachment = find_volume_attachment(compute_client, compartment_ocid, attach_instance_ocid, volume.id)
            if volume_attachment is not None:
                volume_attachment = detach_volume(compute_client, volume_attachment.id)
        volume = destroy_volume(storage_client, volume.id)
    elif volume is not None:
        log.debug("list process_volume_spec: {}".format(operation))
        volume_attachment = find_volume_attachment(compute_client, compartment_ocid, attach_instance_ocid, volume.id)
    # assemble results
    volume_info = None
    if volume is not None:
        volume_info = as_info(volume)
        if volume_attachment is not None:
            volume_info["volume_attachment_info"] = as_info(volume_attachment)
    return volume_info

#---------------------------------------------------------------------------------------------------
# instances

def init_compute(config):
    return oraclebmc.core.compute_client.ComputeClient(config)

def list_instances(compute_client, compartment_ocid):
    response = compute_client.list_instances(compartment_id=compartment_ocid)
    instances = response.data
    return instances

def find_instance(compute_client, compartment_ocid, instance_name):
    instances = list_instances(compute_client, compartment_ocid)
    # print("instances: {}".format(instances))
    instance = filter(lambda x : x.display_name == instance_name and x.lifecycle_state == "RUNNING", instances)
    if len(instance) > 0:
        log.debug("found available instance: {}".format(instance[0]))
        return instance[0]
    else:
        return None

def create_instance(compute_client, compartment_ocid, subnet_ocid, subnet_availability_domain, instance_spec, synchronous=True, attempts=30, period=2):
    log.debug("launching instance...")
    request = LaunchInstanceDetails()
    request.compartment_id = compartment_ocid
    request.display_name = instance_spec["name"]
    request.availability_domain = subnet_availability_domain
    request.subnet_id = subnet_ocid
    request.image_id = instance_spec["image_ocid"]
    request.shape = instance_spec["instance_shape"]
    request.metadata = instance_spec["metadata"]
    request.description = "Created with the Python SDK"
    response = compute_client.launch_instance(request)
    instance = response.data
    if synchronous:
        instance = wait_for_obmcs_entity_state(lambda : compute_client.get_instance(instance.id).data, "RUNNING", attempts, period)
    log.debug("launched instance: {}".format(instance))
    return instance

def destroy_instance(compute_client, instance_ocid, synchronous=True, attempts=30, period=2):
    log.debug("terminating instance: {}".format(instance_ocid))
    instance = compute_client.terminate_instance(instance_ocid).data
    if synchronous:
        instance = wait_for_obmcs_entity_state(lambda : compute_client.get_instance(instance_ocid).data, "TERMINATED", attempts, period)
    log.debug("terminated instance: {}".format(volume_ocid))
    return instance

def find_volume_attachment(compute_client, compartment_ocid, instance_ocid, volume_ocid,):
    volume_attachments = compute_client.list_volume_attachments(compartment_id=compartment_ocid).data
    volume_attachment = filter(
        lambda x : x.instance_id == instance_ocid and x.volume_id == volume_ocid and x.lifecycle_state == "ATTACHED", volume_attachments)
    if len(volume_attachment) > 0:
        log.debug("found attached volume_attachment: {}".format(volume_attachment[0]))
        return volume_attachment[0]
    else:
        return None

def get_volume_attachment(compute_client, volume_attachment_ocid):
    return compute_client.get_volume_attachment(volume_attachment_ocid).data

def attach_volume(compute_client, instance_ocid, volume_ocid, volume_spec, synchronous=True, attempts=30, period=2):
    log.debug("attaching volume {} to instance {}".format(volume_ocid, instance_ocid))
    request = AttachVolumeDetails()
    request.display_name = volume_spec["display_name"]
    request.instance_id = instance_ocid
    request.volume_id = volume_ocid
    request.type = volume_spec["attachment_type"]
    response = compute_client.attach_volume(request)
    volume_attachment = response.data
    if synchronous:
        volume_attachment = wait_for_obmcs_entity_state(lambda : get_volume_attachment(compute_client, volume_attachment.id), "ATTACHED", attempts, period)
    log.debug("attached volume {} to instance {}".format(volume_ocid, instance_ocid))
    return volume_attachment

def detach_volume(compute_client, volume_attachment_ocid, synchronous=True, attempts=30, period=2):
    log.debug("detaching volume: {}".format(volume_attachment_ocid))
    response = compute_client.detach_volume(volume_attachment_ocid)
    volume_attachment = response.data
    if synchronous:
        volume_attachment = wait_for_obmcs_entity_state(lambda : get_volume_attachment(compute_client, volume_attachment_ocid), "DETACHED", attempts, period)
    log.debug("detached volume: {}".format(volume_attachment_ocid))
    return volume_attachment

def process_instance_specs(config, operation, compartment_ocid, subnet_ocid, subnet_availability_domain, instance_specs):
    instances_info = []
    for instance_spec in instance_specs:
        instance_info = process_instance_spec(config, operation, compartment_ocid, subnet_ocid, subnet_availability_domain, instance_spec)
        if instance_info is not None:
            instances_info.append(instance_info)
    return instances_info

def process_instance_spec(config, operation, compartment_ocid, subnet_ocid, subnet_availability_domain, instance_spec):
    instance_name = instance_spec["name"]
    compute_client = init_compute(config)
    instance = find_instance(compute_client, compartment_ocid, instance_name)
    volume_specs = instance_spec["volumes"]
    # handle op
    volumes_info = []
    if operation == Operation.CREATE and is_unprovisioned(instance) :
        log.debug("create process_instance_spec: {}".format(operation))
        instance = create_instance(compute_client, compartment_ocid, subnet_ocid, subnet_availability_domain, instance_spec)
        volumes_info = process_volume_specs(config, operation, compartment_ocid, subnet_availability_domain, volume_specs, attach_instance_ocid=instance.id)
    elif operation == Operation.DESTROY and instance is not None:
        log.debug("destroy process_instance_spec: {}".format(operation))
        volumes_info = process_volume_specs(config, operation, compartment_ocid, subnet_availability_domain, volume_specs, attach_instance_ocid=instance.id)
        instance = destroy_instance(compute_client, instance.id)
    elif instance is not None:
        log.debug("list process_instance_spec: {}".format(operation))
        volumes_info = process_volume_specs(config, operation, compartment_ocid, subnet_availability_domain, volume_specs, attach_instance_ocid=instance.id)
    # assemble results
    instance_info = None
    if instance is not None:
        instance_info = as_info(instance)
        instance_info["volumes"] = volumes_info
    return instance_info

#---------------------------------------------------------------------------------------------------
# subnets

def list_subnets(network_client, compartment_ocid, vcn_ocid):
    response = network_client.list_subnets(compartment_id=compartment_ocid, vcn_id=vcn_ocid)
    subnets = response.data
    return subnets

def find_subnet(network_client, compartment_ocid, vcn_ocid, subnet_name):
    subnets = list_subnets(network_client, compartment_ocid, vcn_ocid)
    # print("subnets: {}".format(subnets))
    subnet = filter(lambda x : x.display_name == subnet_name and x.lifecycle_state == "AVAILABLE", subnets)
    if len(subnet) > 0:
        log.debug("found available subnet: {}".format(subnet[0]))
        return subnet[0]
    else:
        return None

def create_subnet(network_client, compartment_ocid, vcn_ocid, subnet_spec, synchronous=True, attempts=30, period=2):
    log.debug("creating subnet...")
    request = CreateSubnetDetails()
    request.display_name = subnet_spec["name"]
    request.compartment_id = compartment_ocid
    request.availability_domain = subnet_spec["availability_domain"]
    request.vcn_id = vcn_ocid
    request.cidr_block = subnet_spec["cidr_block"]
    # dhcp_options_id =
    # route_table_id =
    # security_list_ids =
    request.description = "Created with the Python SDK"
    subnet = network_client.create_subnet(request).data
    if synchronous:
        subnet = wait_for_obmcs_entity_state(lambda : network_client.get_subnet(subnet.id).data, "AVAILABLE", attempts, period)
    log.debug("created subnet: {}".format(subnet))
    return subnet

def destroy_subnet(network_client, subnet_ocid, synchronous=True, attempts=30, period=2):
    log.debug("destroying subnet: {}".format(subnet_ocid))
    subnet = network_client.delete_subnet(subnet_ocid).data
    if synchronous:
        subnet = wait_for_obmcs_entity_state(lambda : network_client.get_subnet(subnet_ocid).data, "TERMINATED", attempts, period)
    log.debug("destroyed subnet: {}".format(subnet_ocid))
    return subnet

def process_subnet_specs(config, operation, compartment_ocid, vcn_ocid, subnet_specs):
    subnets = []
    for subnet_spec in subnet_specs:
        subnet = process_subnet_spec(config, operation, compartment_ocid, vcn_ocid, subnet_spec)
        if subnet is not None:
            subnets.append(subnet)
    return subnets

def process_subnet_spec(config, operation, compartment_ocid, vcn_ocid, subnet_spec):
    subnet_name = subnet_spec["name"]
    network_client = init_network(config)
    subnet = find_subnet(network_client, compartment_ocid, vcn_ocid, subnet_name)
    subnet_availability_domain = subnet_spec["availability_domain"]
    instance_specs = subnet_spec["instances"]
    # handle op
    instances_info = []
    if operation == Operation.CREATE and is_unprovisioned(subnet) :
        log.debug("create process_subnet_spec: {}".format(operation))
        subnet = create_subnet(network_client, compartment_ocid, vcn_ocid, subnet_spec)
        instances_info = process_instance_specs(config, operation, compartment_ocid, subnet.id, subnet_availability_domain, instance_specs)
    elif operation == Operation.DESTROY and subnet is not None :
        log.debug("destroy process_subnet_spec: {}".format(operation))
        instances_info = process_instance_specs(config, operation, compartment_ocid, subnet.id, subnet_availability_domain, instance_specs)
        destroy_subnet(network_client, subnet.id)
    elif subnet is not None:
        log.debug("list process_subnet_spec: {}".format(operation))
        instances_info = process_instance_specs(config, operation, compartment_ocid, subnet.id, subnet_availability_domain, instance_specs)
    # process results
    subnet_info = None
    if subnet is not None:
        subnet_info = as_info(subnet)
        subnet_info["instances"] = instances_info
    return subnet_info

#---------------------------------------------------------------------------------------------------
# networks

def init_network(config):
    return oraclebmc.core.virtual_network_client.VirtualNetworkClient(config)

def list_vcns(network_client, compartment_ocid):
    return network_client.list_vcns(compartment_ocid).data

def find_vcn(network_client, compartment_ocid, network_name):
    vcns = list_vcns(network_client, compartment_ocid)
    vcn =  filter(lambda x : x.display_name == network_name and x.lifecycle_state == "AVAILABLE", vcns)
    if len(vcn) > 0:
        log.debug("found available vcn: {}".format(vcn[0]))
        return vcn[0]
    else:
        return None

def create_vcn(network_client, compartment_ocid, vcn_spec, synchronous=True, attempts=30, period=2):
    log.debug("creating vcn...")
    request = CreateVcnDetails()
    request.compartment_id = compartment_ocid
    request.display_name = vcn_spec["name"]
    request.cidr_block = vcn_spec["cidr_block"]
    request.description = "Created with the Python SDK"
    vcn = network_client.create_vcn(request).data
    if synchronous:
        vcn = wait_for_obmcs_entity_state(lambda : network_client.get_vcn(vcn.id).data, "AVAILABLE", attempts, period)
    log.debug("created vcn: {}".format(vcn))
    return vcn

def destroy_vcn(network_client, vcn_ocid, synchronous=True, attempts=30, period=2):
    log.debug("destroying vcn: {}".format(vcn_ocid))
    vcn = network_client.delete_vcn(vcn_ocid).data
    if synchronous:
        vcn = wait_for_obmcs_entity_state(lambda : network_client.get_vcn(vcn_ocid).data, "TERMINATED", attempts, period)
    log.debug("destroyed vcn: {}".format(vcn_ocid))
    return vcn

def process_vcn_spec(config, operation, compartment_ocid, vcn_spec):
    network_client = init_network(config)
    vcn_name = vcn_spec["name"]
    subnet_specs = vcn_spec["subnets"]
    vcn = find_vcn(network_client, compartment_ocid, vcn_name)
    # handle op
    subnets_info = []
    if operation == Operation.CREATE and is_unprovisioned(vcn) :
        log.debug("create process_vcn_spec: {}".format(operation))
        vcn = create_vcn(network_client, compartment_ocid, vcn_spec)
        subnets_info = process_subnet_specs(config, operation, compartment_ocid, vcn.id, subnet_specs)
    elif operation == Operation.DESTROY and vcn is not None :
        log.debug("destroy process_vcn_spec: {}".format(operation))
        subnets_info = process_subnet_specs(config, operation, compartment_ocid, vcn.id, subnet_specs)
        vcn = destroy_vcn(network_client, vcn.id)
    elif vcn is not None:
        log.debug("vcn process_vcn_spec: {}".format(operation))
        subnets_info = process_subnet_specs(config, operation, compartment_ocid, vcn.id, subnet_specs)
    # assemble results
    vcn_info = None
    if vcn is not None:
        vcn_info = as_info(vcn)
        vcn_info["subnets"] = subnets_info
    return vcn_info

#---------------------------------------------------------------------------------------------------
# compartments

def init_identity(config):
    return oraclebmc.identity.IdentityClient(config)

def list_compartments(identity_client, tenancy_ocid):
    response = identity_client.list_compartments(tenancy_ocid)
    compartments = response.data
    return compartments

def find_compartment(identity_client, tenancy_ocid, compartment_name):
    tenancy_compartments = list_compartments(identity_client, tenancy_ocid)
    tenancy_compartment = filter(lambda x : x.name == compartment_name and x.lifecycle_state == "ACTIVE", tenancy_compartments)
    if len(tenancy_compartment) > 0:
        log.debug("found available compartment: {}".format(tenancy_compartment[0]))
        return tenancy_compartment[0]
    else:
        return None

def process_compartment_spec(config, operation, compartment_spec):
    log.debug("processing compartment_spec: {}".format(compartment_spec["name"]))
    identity_client = init_identity(config)
    compartment_name = compartment_spec["name"]
    tenancy_ocid = config["tenancy"]
    compartment = find_compartment(identity_client, tenancy_ocid, compartment_name)
    # handle op
    vcns_info = []
    for vcn_spec in compartment_spec["networks"]:
        if compartment is not None:
            vcn_info = process_vcn_spec(config, operation, compartment.id, vcn_spec)
            if vcn_info is not None:
                vcns_info.append(vcn_info)
    # assemble results
    compartment_info = as_info(compartment)
    if len(vcns_info) > 0:
        compartment_info["networks"] = vcns_info
    return compartment_info

#---------------------------------------------------------------------------------------------------
# deployments

def process_deployment_spec(config, operation, deployment_spec):
    compartments = []
    for compartment_spec in deployment_spec["compartments"]:
        compartment = process_compartment_spec(config, operation, compartment_spec)
        compartments.append(compartment)
    deployment = {}
    deployment["compartments"] = compartments
    return deployment

#---------------------------------------------------------------------------------------------------
# main

def as_map(obmcs_response_data):
    """
    Extract the member variables of an obmcs response object as a <String, Object> key value map.
    """
    result = {}
    var_map = vars(obmcs_response_data)
    for key in obmcs_response_data.attribute_map.keys():
        var_name = "_" + key
        if var_name in var_map:
            result[key] = var_map.get(var_name)
    return result

def as_info(obmcs_response_data):
    """
    Extract the member variables of an obmcs response object as a <String, String> key value map.
    """
    return json.loads(obmcs_response_data.__repr__())

def is_unprovisioned(obmcs_response_data):
    """
    Check to see if the obmcs entity is provisioned
    """
    return obmcs_response_data is None or obmcs_response_data.lifecycle_state == "TERMINATED"

def wait_for_obmcs_entity_state(get_obmcs_entity_fn, obmcs_entity_target_state, attempts=30, period=2):
    obmcs_entity = None
    for attempt in range(attempts):
        obmcs_entity = get_obmcs_entity_fn()
        log.debug("wait_for_obmcs_entity_state obmcs_entity: {}".format(obmcs_entity))
        state = obmcs_entity.lifecycle_state
        log.debug("wait_for_obmcs_entity_state state: {}".format(state))
        if state == obmcs_entity_target_state:
            return obmcs_entity
        else:
            log.debug("wait_for_obmcs_entity_state transition: {}".format(obmcs_entity_target_state))
            time.sleep(period)
    return obmcs_entity

class Operation(object):
    CREATE = "create"
    LIST = "list"
    DESTROY = "destroy"

def init_config():
    config = oraclebmc.config.from_file("~/.oraclebmc/config")
    validate_config(config)
    return config

def init_logger():
    logging.getLogger("requests").setLevel(logging.WARNING)
    logger = logging.getLogger()
    handler = logging.StreamHandler()
    formatter = logging.Formatter(
        '%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(logging.WARN)
    return logger

if __name__ == "__main__":
    log = init_logger()
    pp = pprint.PrettyPrinter(indent=0)
    config = init_config()
    # NB: python client requires ssl version >= 1.0
    log.debug("using OpenSSL Version: {}".format(ssl.OPENSSL_VERSION))
    print ("\n------- obmcs deployment manager -------\n")
    # handle cli operation type
    if len(sys.argv) > 2:
        operation = sys.argv[2]
    else:
        operation = Operation.LIST
    print("operation           : {}".format(operation))
    # handle cli deployment_spec path type
    deployment_spec_path = sys.argv[1]
    print("deployment spec path: {}".format(deployment_spec_path))
    with open(deployment_spec_path) as json_data:
        deployment_spec = json.load(json_data)
        print ("\n---------- deployment spec ----------\n")
        pp.pprint(deployment_spec)
    # handle deloyment operation
    deployment = process_deployment_spec(config, operation, deployment_spec)
    # display result
    print ("\n---------- current deployment ----------\n")
    pp.pprint(deployment)
