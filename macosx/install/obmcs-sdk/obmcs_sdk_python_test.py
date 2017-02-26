#!/usr/bin/env python

import ssl

import oraclebmc
from oraclebmc.config import validate_config
from oraclebmc.core.models import AttachVolumeDetails
from oraclebmc.core.models import CreateVolumeDetails
from oraclebmc.core.models import LaunchInstanceDetails
from oraclebmc.identity.models import CreateUserDetails

BRISTOL_CLOUD_COMPARTMENT_ID="iocid1.compartment.oc1..aaaaaaaa3um2atybwhder4qttfhgon4j3hcxgmsvnyvx4flfjyewkkwfzwnq"

#---------------------------------------------------------------------------------------------------
# configuration

def init_config():
    config = oraclebmc.config.from_file("~/.oraclebmc/config", "trjl-test")
    validate_config(config)
    return config

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

def list_users(config):
    compartment_id = config["tenancy"]
    identity = init_identity(config)
    response = identity.list_users(compartment_id=compartment_id)
    users = response.data
    print("num users: {}".format(len(users)))
    for idx, user in enumerate(users):
        print("user[{}] : {}".format(idx, user))
    return users


#---------------------------------------------------------------------------------------------------
# networking

def init_network(config):
    return oraclebmc.core.virtual_network_client.VirtualNetworkClient(config)


def create_vcn(config):
    return None


#---------------------------------------------------------------------------------------------------
# storage functions

def init_storage(config):
    return oraclebmc.core.blockstorage_client.BlockstorageClient(config)

def list_volumes(config):
    # compartment_id = BRISTOL_CLOUD_COMPARTMENT_ID
    compartment_id = config["tenancy"]
    storage = init_storage(config)
    response = storage.list_volumes(compartment_id=compartment_id)
    volumes = response.data
    print("num volumes: {}".format(len(volumes)))
    for idx, volume in enumerate(volumes):
        print("volume[{}] : {}".format(idx, volume))
    return volumes

def create_volume(config):
    storage = init_storage(config)
    request = CreateVolumeDetails()
    request.availability_domain=DOMAIN_3
    request.compartment_id = config["tenancy"]
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

def list_instances(config):
    # compartment_id = BRISTOL_CLOUD_COMPARTMENT_ID
    compartment_id = config["tenancy"]
    compute = init_compute(config)
    response = compute.list_instances(compartment_id=compartment_id)
    instances = response.data
    print("num instances: {}".format(len(instances)))
    for idx, instance in enumerate(instances):
        print("instance[{}] : {}".format(idx, instance))
    return instances

UBUNTU_IMAGE_OCID="ocid1.image.oc1.phx.aaaaaaaaxsufrpzn72dvhry5swbuwnuldcn3eko3cx6g7z4tw4qfwkq2zkra"
SHAPE_VS1="VM.Standard1.1"
DOMAIN_3="NWuj:PHX-AD-3"
SUBNET="ocid1.subnet.oc1.phx.aaaaaaaalyd5je5flygivxi66aem23jqsbeu7fwru3vod7fxlthutjidnh7a"
def launch_instance(config):
    compute = init_compute(config)
    request = LaunchInstanceDetails()
    request.availability_domain=DOMAIN_3
    request.compartment_id = config["tenancy"]
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

if __name__ == "__main__":
    print("OpenSSL Version: {}".format(ssl.OPENSSL_VERSION))
    CONFIG = init_config()
    print("Config: {}".format(CONFIG))
    # get_configured_user(CONFIG)
    # list_users(CONFIG)
    
    # instance_ocid = launch_instance(CONFIG).id
    instance_ocid = "ocid1.instance.oc1.phx.abyhqljrzih7t6psauzroi2bshosfgvjfrixjljlmctyepjrxt3mqymam3ga"
    # terminate_instance(CONFIG, instance_ocid)
    list_instances(CONFIG)
    
    # volume_ocid = create_volume(CONFIG).id
    volume_ocid = "ocid1.volume.oc1.phx.abyhqljrr4t77t2q4f5x4hqgbeg6ooewvpuzunazxqrk426aedlhd2zmungq"
    # delete_volume(CONFIG, volume_ocid)
    list_volumes(CONFIG)
    
    # volume_attachment_id = attach_volume(CONFIG, instance_ocid, volume_ocid).id
    volume_attachment_id = "ocid1.volumeattachment.oc1.phx.abyhqljrexbeinbndxnltcd3l5awk2rsrl7eodre2u62o6rw6ja7edilznzq"
    get_volume_attachment(CONFIG, volume_attachment_id)

