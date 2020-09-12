#!/bin/bash

source /etc/kolla/admin-openrc.sh

#passo 2
openstack project create UFCQuixada
openstack project create IFCEQuixada
openstack role add --user admin --project UFCQuixada admin
openstack role add --user admin --project IFCEQuixada admin

#passo 3
openstack user create "josberto"
openstack user create "maria"
openstack role add --user "josberto" --project "UFCQuixada" admin
openstack role add --user "maria" --project "IFCEQuixada" admin

#passo 4
wget -q http://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img
openstack image create --file cirros-0.5.1-x86_64-disk.img --disk-format qcow2 cirros

#passo 5
openstack flavor create --ram 512 --disk 1 --vcpus 1 "m1.tiny"
openstack flavor create --ram 2048 --disk 20 --vcpus 1 "m1.small"
openstack flavor create --ram 4096 --disk 40 --vcpus 2 "m1.medium"
openstack flavor create --ram 8192 --disk 80 --vcpus 4 "m1.large"
openstack flavor create --ram 16384 --disk 160 --vcpus 8 "m1.xlarge"

#passo 6
openstack quota set --cores 2 --instances 2 --key-pairs 2 --ram 2048 "UFCQuixada"
openstack quota set --cores 2 --instances 2 --key-pairs 2 --ram 2048 "IFCEQuixada"

export OS_PROJECT_NAME=UFCQuixada

#passo 7
openstack network create "ufcnet"
openstack subnet create --network "ufcnet" --subnet-range 172.16.100.0/24 --gateway 172.16.100.254 --allocation-pool start=172.16.100.100,end=172.16.100.200 --dns-nameserver 8.8.8.8 "ufcsubnet1"

#passo 8
openstack keypair create ufckey

#passo 9
openstack security group create ufcsecgroup
openstack security group rule create --protocol icmp ufcsecgroup
openstack security group rule create --protocol tcp --dst-port 22 ufcsecgroup

#passo 10
openstack server create --image cirros --flavor m1.tiny --network ufcnet --security-group ufcsecgroup --key-name ufckey vm1
openstack server create --image cirros --flavor m1.tiny --network ufcnet --security-group ufcsecgroup --key-name ufckey vm2
