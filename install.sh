#!/bin/bash

#instalação leva aproximadamente 15 min
#necessário ter 2 interfaces de rede na instancia da aws

#passo 1
sudo apt update -y
sudo apt install -y net-tools
sudo apt install -y python3-dev libffi-dev gcc libssl-dev python3-pip ansible
sudo pip3 install -U pip

#passo 2
sudo pip install kolla-ansible

ip_eth0=$(ifconfig eth0 | grep 'netmask' | awk '{print $2}')

#passo 3
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla

#passo 4
cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla

#passo 5
cp /usr/local/share/kolla-ansible/ansible/inventory/* .

#passo 6
kolla-genpwd

#passo 7
cat <<EOT > /etc/kolla/globals.yml
kolla_base_distro: "ubuntu"
kolla_install_type: "binary"
network_interface: "eth0"
neutron_external_interface: "eth1"
kolla_internal_vip_address: $ip_eth0
enable_haproxy: "no"
nova_compute_virt_type: "qemu"
EOT

#passo 8 (~12min)
sudo kolla-ansible -i ./all-in-one bootstrap-servers
sudo kolla-ansible -i ./all-in-one deploy

#passo 9 - precisou de sudo
sudo pip install python-openstackclient

kolla-ansible post-deploy

cat /etc/kolla/admin-openrc.sh | grep -i 'os_password'
