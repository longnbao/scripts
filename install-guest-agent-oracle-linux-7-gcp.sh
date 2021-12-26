#!/bin/bash
echo "== Installing Google guest environment for CentOS/RHEL =="
sleep 30 # Wait for network.
echo "Determining CentOS/RHEL version..."
eval $(grep VERSION_ID /etc/os-release)
if [[ -z $VERSION_ID ]]; then
  echo "ERROR: Could not determine version of CentOS/RHEL."
  exit 1
fi
echo "Updating repo file..."
tee "/etc/yum.repos.d/google-cloud.repo" << EOM
[google-compute-engine]
name=Google Compute Engine
baseurl=https://packages.cloud.google.com/yum/repos/google-compute-engine-el${VERSION_ID/.*}-x86_64-stable
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
echo "Running yum makecache..."
yum makecache
echo "Running yum updateinfo..."
yum updateinfo
echo "Running yum install google-compute-engine..."
yum install -y google-compute-engine
rpm -q google-compute-engine
if [[ $? -ne 0 ]]; then
  echo "ERROR: Failed to install ${pkg}."
fi
echo "Removing this rc.local script."
rm /etc/rc.d/rc.local
# Move back any previous rc.local:
if [[ -f "/etc/moved-rc.local" ]]; then
  echo "Restoring a previous rc.local script."
  mv "/etc/moved-rc.local" "/etc/rc.d/rc.local"
fi
