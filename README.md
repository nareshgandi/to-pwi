# README: PostgreSQL Installation Guide

## Prerequisites

# Ubuntu or RHEL Virtual Machines

* Ensure that you have Ubuntu and/or RHEL virtual machines installed.

* These VMs should have connectivity to both the host machine and the internet.

2. Verify Connectivity

To check if your VMs are reachable from the host machine, run:

ping <VM_IP>

To verify internet access from the VM, run:

ping google.com

3. Install PuTTY (For Windows Users)

If you are using Windows, install PuTTY to connect to your virtual machines via SSH.

4. Retrieve VM IP Addresses

Get the IP addresses of all VMs using:

ip a

or

ifconfig

Installation Steps

Refer to the individual markdown files provided to install PostgreSQL on various operating systems:

install_postgres_ubuntu.md – Guide for installing PostgreSQL on Ubuntu.

install_postgres_rhel.md – Guide for installing PostgreSQL on RHEL.

Important Notes

This guide is meant for learning purposes only and does not necessarily follow best practices.

Ensure that you have sufficient system resources before proceeding with the installation.

For any issues, verify network connectivity and SSH access to your virtual machines.

