#!/usr/bin/env python

import ssl

import oraclebmc
from oraclebmc.config import validate_config
from oraclebmc.core.models import AttachVolumeDetails
from oraclebmc.core.models import CreateSubnetDetails
from oraclebmc.core.models import CreateVolumeDetails
from oraclebmc.core.models import CreateVcnDetails
from oraclebmc.core.models import LaunchInstanceDetails
from oraclebmc.identity.models import CreateUserDetails

#---------------------------------------------------------------------------------------------------
# user management

def init_identity(config):
    return oraclebmc.identity.IdentityClient(config)

def get_configured_user(config):
    identity = init_identity(config)
    response = identity.get_user(config["user"])
    user = response.data
    print("this user : {}".format(user))
    return user

def list_users(config, compartment_ocid):
    identity = init_identity(config)
    response = identity.list_users(compartment_id=compartment_ocid)
    users = response.data
    print("num users: {}".format(len(users)))
    for idx, user in enumerate(users):
        print("user[{}] : {}".format(idx, user))
    return users


#---------------------------------------------------------------------------------------------------
# networking

def init_network(config):
    return oraclebmc.core.virtual_network_client.VirtualNetworkClient(config)

def list_vcns(config, compartment_ocid):
    identity = init_network(config)
    response = identity.list_vcns(compartment_id=compartment_ocid)
    vcns = response.data
    print("num vcns: {}".format(len(vcns)))
    for idx, vcn in enumerate(vcns):
        print("vcn[{}] : {}".format(idx, vcn))
    return vcns

VCN_CIDR_BLOCK="192.168.0.0/27"
def create_vcn(config, compartment_ocid):
    network = init_network(config)
    request = CreateVcnDetails()
    request.compartment_id = compartment_ocid
    request.cidr_block = VCN_CIDR_BLOCK
    request.display_name = "trjl-test-vcn"
    request.description = "Created with the Python SDK"
    response = network.create_vcn(request)
    vcn = response.data
    print("create vcn: {}".format(vcn))
    return vcn

def delete_vcn(config, vcn_ocid):
    network = init_network(config)
    response = network.delete_vcn(vcn_ocid)
    print("deleting vcn: {}".format(vcn_ocid))
    return response.data

def list_subnets(config, compartment_ocid, vcn_ocid):
    identity = init_network(config)
    response = identity.list_subnets(compartment_id=compartment_ocid, vcn_id=vcn_ocid)
    subnets = response.data
    print("num subnets: {}".format(len(subnets)))
    for idx, subnet in enumerate(subnets):
        print("subnet[{}] : {}".format(idx, subnet))
    return subnets

SUBNET_CIDR_BLOCK="192.168.0.0/28"
SUBNET_AVAILABILITY_DOMAIN="NWuj:PHX-AD-3"
def create_subnet(config, compartment_ocid, vcn_ocid):
    network = init_network(config)
    request = CreateSubnetDetails()
    request.compartment_id = compartment_ocid
    request.availability_domain = SUBNET_AVAILABILITY_DOMAIN
    request.vcn_id = vcn_ocid
    request.cidr_block = SUBNET_CIDR_BLOCK
    # dhcp_options_id =
    # route_table_id =
    # security_list_ids =
    request.display_name = "trjl-test-vcn-subnet"
    request.description = "Created with the Python SDK"
    response = network.create_subnet(request)
    subnet = response.data
    print("create subnet: {}".format(subnet))
    return subnet

def delete_subnet(config, subnet_ocid):
    network = init_network(config)
    response = network.delete_subnet(subnet_ocid)
    print("deleting subnet: {}".format(subnet_ocid))
    return response.data

#---------------------------------------------------------------------------------------------------
# storage functions

def init_storage(config):
    return oraclebmc.core.blockstorage_client.BlockstorageClient(config)

def list_volumes(config, compartment_ocid):
    storage = init_storage(config)
    response = storage.list_volumes(compartment_id=compartment_ocid)
    volumes = response.data
    print("num volumes: {}".format(len(volumes)))
    for idx, volume in enumerate(volumes):
        print("volume[{}] : {}".format(idx, volume))
    return volumes

def create_volume(config, compartment_ocid):
    storage = init_storage(config)
    request = CreateVolumeDetails()
    request.availability_domain=DOMAIN_3
    request.compartment_id = compartment_ocid
    request.size_in_mbs=262144
    # requst.volume_backup_id=
    request.display_name = "trjl-test-instance-volume"
    request.description = "Created with the Python SDK"
    response = storage.create_volume(request)
    volume = response.data
    print("created volume: {}".format(volume))
    return volume

# create_volume_backup

def delete_volume(config, volume_ocid):
    storage = init_storage(config)
    response = storage.delete_volume(volume_ocid)
    print("deleting volume: {}".format(volume_ocid))
    return response.data

#---------------------------------------------------------------------------------------------------
# compute functions

def init_compute(config):
    return oraclebmc.core.compute_client.ComputeClient(config)

def list_instances(config, compartment_ocid):
    compute = init_compute(config)
    response = compute.list_instances(compartment_id=compartment_ocid)
    instances = response.data
    print("num instances: {}".format(len(instances)))
    for idx, instance in enumerate(instances):
        print("instance[{}] : {}".format(idx, instance))
    return instances

UBUNTU_IMAGE_OCID="ocid1.image.oc1.phx.aaaaaaaaxsufrpzn72dvhry5swbuwnuldcn3eko3cx6g7z4tw4qfwkq2zkra"
SHAPE_VS1="VM.Standard1.1"
DOMAIN_3=SUBNET_AVAILABILITY_DOMAIN
SUBNET="ocid1.subnet.oc1.phx.aaaaaaaalyd5je5flygivxi66aem23jqsbeu7fwru3vod7fxlthutjidnh7a"
def launch_instance(config, compartment_ocid):
    compute = init_compute(config)
    request = LaunchInstanceDetails()
    request.availability_domain=DOMAIN_3
    request.compartment_id = compartment_ocid
    request.image_id=UBUNTU_IMAGE_OCID
    request.shape=SHAPE_VS1
    request.subnet_id=SUBNET
    request.display_name = "trjl-test-instance"
    request.description = "Created with the Python SDK"
    response = compute.launch_instance(request)
    instance = response.data
    print("launched instance: {}".format(instance))
    return instance

def terminate_instance(config, instance_ocid):
    compute = init_compute(config)
    response = compute.terminate_instance(instance_ocid)
    print("terminating instance: {}".format(instance_ocid))
    return response.data

def attach_volume(config, instance_ocid, volume_ocid):
    compute = init_compute(config)
    request = AttachVolumeDetails()
    request.display_name = "trjl-test-attached_volume"
    request.instance_id = instance_ocid
    request.volume_id = volume_ocid
    request.type = "iscsi"
    response = compute.attach_volume(request)
    attached_volume = response.data
    print("attaching volume {} to instance {}: {}".format(volume_ocid, instance_ocid, attached_volume))
    return response.data


# get the details required for mounting the iscsi disk..
#
# https://iaas.us-phoenix-1.oraclecloud.com/20160918/volumeAttachments/?compartmentId=ocid1.tenancy.oc1..aaaaaaaatyn7scrtwtqedvgrxgr2xunzeo6uanvyhzxqblctwkrpisvke4kq&instanceId=ocid1.instance.oc1.phx.abyhqljrzih7t6psauzroi2bshosfgvjfrixjljlmctyepjrxt3mqymam3ga

def get_volume_attachment(config, volume_attachment_ocid):
    compute = init_compute(config)
    response = compute.get_volume_attachment(volume_attachment_ocid)
    volume_attachment = response.data
    print("getting volume_attachment {}: ".format(volume_attachment))
    return response.data

#---------------------------------------------------------------------------------------------------
# main

BRISTOL_CLOUD_COMPARTMENT_ID="ocid1.compartment.oc1..aaaaaaaa3um2atybwhder4qttfhgon4j3hcxgmsvnyvx4flfjyewkkwfzwnq"

def init_config():
    config = oraclebmc.config.from_file("~/.oraclebmc/config", "trjl-test")
    validate_config(config)
    return config

if __name__ == "__main__":
    print("OpenSSL Version: {}".format(ssl.OPENSSL_VERSION))
    CONFIG = init_config()
    print("Config: {}".format(CONFIG))
    print("Config tenancy compartment id: {}".format(CONFIG["tenancy"]))

    # get_configured_user(CONFIG)
    # list_users(CONFIG, CONFIG["tenancy"])

    vcn_ocid = "ocid1.vcn.oc1.phx.aaaaaaaar3h6qeuux25rutju45j3eiwayytwgnm6y4kusjnwkiauhl6ur5wq"
    # vcn_ocid = create_vcn(CONFIG, BRISTOL_CLOUD_COMPARTMENT_ID).id
    list_vcns(CONFIG, BRISTOL_CLOUD_COMPARTMENT_ID)
    subnet_ocid = "ocid1.subnet.oc1.phx.aaaaaaaaml73o3jtkspuhha6ek552lsqyzupmmkuq3peuujtqs66t6r67j7q"
    # subnet_ocid = create_subnet(CONFIG, BRISTOL_CLOUD_COMPARTMENT_ID, vcn_ocid).id
    list_subnets(CONFIG, BRISTOL_CLOUD_COMPARTMENT_ID, vcn_ocid)

    delete_subnet(CONFIG, subnet_ocid)
    delete_vcn(CONFIG, vcn_ocid)

    # instance_ocid = "ocid1.instance.oc1.phx.abyhqljrzih7t6psauzroi2bshosfgvjfrixjljlmctyepjrxt3mqymam3ga"
    # instance_ocid = launch_instance(CONFIG, BRISTOL_CLOUD_COMPARTMENT_ID).id
    # terminate_instance(CONFIG, instance_ocid)
    # list_instances(CONFIG, BRISTOL_CLOUD_COMPARTMENT_ID)

    # volume_ocid = "ocid1.volume.oc1.phx.abyhqljrr4t77t2q4f5x4hqgbeg6ooewvpuzunazxqrk426aedlhd2zmungq"
    # volume_ocid = create_volume(CONFIG, BRISTOL_CLOUD_COMPARTMENT_ID).id
    # delete_volume(CONFIG, volume_ocid)
    # list_volumes(CONFIG, BRISTOL_CLOUD_COMPARTMENT_ID)

    # volume_attachment_id = "ocid1.volumeattachment.oc1.phx.abyhqljrexbeinbndxnltcd3l5awk2rsrl7eodre2u62o6rw6ja7edilznzq"
    # volume_attachment_id = attach_volume(CONFIG, instance_ocid, volume_ocid).id
    # get_volume_attachment(CONFIG, volume_attachment_id)
