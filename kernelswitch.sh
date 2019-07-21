#!/usr/bin/env bash

if [[ ! -f /etc/yum.repos.d/elrepo.repo ]]
then
        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
        rpm -Uvh https://elrepo.org/linux/kernel/el7/x86_64/RPMS/elrepo-release-7.0-4.el7.elrepo.noarch.rpm

        sed '35,47s/enabled=0/enabled=1/' /etc/yum.repos.d/elrepo.repo > /tmp/elrepo.repo
        cp /etc/yum.repos.d/elrepo.repo /etc/yum.repos.d/elrepo.repo.bak
        mv /tmp/elrepo.repo /etc/yum.repos.d/elrepo.repo
fi

echo -n "Enter kernel version: (kernel-lt or kernel-ml): "
read KernelVer

if [[ ${KernelVer} != "kernel-lt" && ${KernelVer} != "kernel-ml" ]]
then
        echo "Incorrect kernel selected"
        exit
fi

yum -y install "${KernelVer}"

if yum list installed | grep -q kernel-headers
then
        echo "kernel-headers installed, swapping"
        yum -y swap kernel-headers -- "${KernelVer}-headers"
else
        echo "Installing ${KernelVer}-headers"
        yum -y install "${KernelVer}-headers"
fi

if yum list installed | grep -q kernel-tools-libs
then
        echo "kernel-tools-libs is installed, swapping"
    yum -y swap kernel-tools-libs -- "${KernelVer}-tools-libs"
else
        echo "Installing ${KernelVer}-tools-libs"
    yum -y install "${KernelVer}-tools-libs"
fi

if yum list installed | grep -q kernel-tools
then
        echo "kernel-tools installed, swapping"
    yum -y swap kernel-tools -- "${KernelVer}-tools"
else
        echo "Installing ${KernelVer}-tools"
    yum -y install "${KernelVer}-tools"
fi

if yum list installed | grep -q kernel-devel
then
    echo "kernel-devel installed, swapping"
    yum -y swap kernel-devel -- "${KernelVer}-devel"
else
    echo "Installing ${KernelVer}-devel"
    yum -y install "${KernelVer}-devel"
fi

echo -n "Remove old kernel? (y/N): "
read KernelDel
if [[ ${KernelDel} == "Y" || ${KernelDel} == "y" ]]
then
        echo "Deleting old kernel, you will still need to run this command after reboot if you wish to delete the running kernel"
        yum -y remove kernel
fi

echo -n "Set GRUB to new kernel? (y/N): "
read ChangeGrubConfig
if [[ ${ChangeGrubConfig} == "Y" || ${ChangeGrubConfig} == "y" ]]
then
        sed 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=0/g' /etc/default/grub > /tmp/grub.cfg
        cp /etc/default/grub /etc/default/grub.bak
        mv /tmp/grub.cfg /etc/default/grub
fi

echo "Updating GRUB"
echo -n "Enter GRUB config path (default: /boot/efi/EFI/centos/grub.cfg): "
read GRUB_PATH
GRUB_PATH=${GRUB_PATH:-"/boot/efi/EFI/centos/grub.cfg"}
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

echo -n "You must reboot for to use the newer kernel, do so now? (y/N): "
read RESTARTNOW
if [[ ${RESTARTNOW} == "Y" || ${RESTARTNOW} == "y" ]]
then
        echo "Rebooting"
        shutdown -r
fi
