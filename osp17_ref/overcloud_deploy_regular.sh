#!/bin/bash

PARAMS="$*"
USER_THT="$HOME/osp17_ref"

if [ ! -d /home/stack/images ]; then
    mkdir -p /home/stack/images
    pushd /home/stack/images
    for i in /usr/share/rhosp-director-images/overcloud-full-latest.tar /usr/share/rhosp-director-images/ironic-python-agent-latest.tar; do tar -xvf $i; done
    sudo yum install libguestfs-tools -y
    export LIBGUESTFS_BACKEND=direct
    virt-customize --root-password password:redhat -a overcloud-full.qcow2
    virt-sysprep --operation machine-id -a overcloud-full.qcow2
    openstack overcloud image upload --image-path /home/stack/images/ --update-existing
    for i in $(openstack baremetal node list -c UUID -f value); do openstack overcloud node configure $i; done
    popd
fi

openstack overcloud roles generate -o $HOME/roles_data.yaml ControllerSriov ComputeOvsDpdkSriov

openstack overcloud deploy $PARAMS \
    --templates \
    --timeout 120 \
    --network-config \
    --deployed-server \
    --baremetal-deployment ~/osp17_ref/baremetal_deployment.yaml \
    -r $HOME/roles_data.yaml \
    -n $USER_THT/network_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovn-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovn-sriov.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/debug.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/config-debug.yaml \
    -e $USER_THT/environment.yaml \
    -e $USER_THT/network-environment.yaml \
    -e $USER_THT/network-environment-regular.yaml \
    -e $USER_THT/ml2-ovs-nfv.yaml \
    -e $HOME/containers-prepare-parameter.yaml

