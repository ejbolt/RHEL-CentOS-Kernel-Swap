# RHEL-CentOS-Kernel-Swap
Quick and dirty script to switch the kernel in CentOS/RHEL to the EPEL kernels, long term or mainline

Must run with bash, either as root or with sudo

May need to manually select grub entry the first time, for some reason setting grub entry to 0 doesn't work in my testing but works manually

Still need to manually remove old kernel if you want it uninstalled, but that's easy enough

Hard coded for EPEL 7 at the moment, intend to make it more dynamic, but we all know how intentions work with these projects :)
