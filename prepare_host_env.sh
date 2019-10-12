#!/bin/bash
cur_dir="$(cd "$(dirname $0)" && pwd)"
overlay_dir="/mnt/host/source/src/third_party/chromiumos-overlay/dev-libs"
xmlsec_ebuild="${cur_dir}/dev-libs/xmlsec"
packages="
  xmlsec
  libtirpc
  libdnet
"

is_root() {
  [ $(id -u) -eq 0 ]  
}

check_env() {
  [ -d $overlay_dir ] && is_root && [ -d $xmlsec_ebuild ] 
}

prepare_xmlsec() {
  rsync -a $xmlsec_ebuild $overlay_dir
}

print_help() {
  echo "Usage: sudo $(basename $0) 
  Build related packages on host to support vmware board. 
  Have to run under root account"  
  exit 0
}

has_installed() {
  equery l $1 1>/dev/null 2>&1
  [ $? -eq 0 ]  
}

buid_packages() {
  for pkg in $packages; do
    has_installed $pkg || emerge $pkg
  done 
}

main() {
  echo "Job is begin..."
  if ! check_env; then
    print_help
  fi 
  prepare_xmlsec
  USE="-python" buid_packages 
  echo "Job is done."
}

main
