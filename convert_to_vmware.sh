#!/bin/bash
self_name=$0
source_img=$1
target_img=$2.vmdk

show_help_exit() {
  echo "help: $self_name <source_raw_img> <target_img>"
  echo "detail: convert chromiumos raw image to <target_img>.vmdk"
  exit 1
}

[ -z "$source_img" ] && show_help_exit
[ ! -f "$source_img" ] && show_help_exit
[ -f ${target_img} ] && rm ${target_img}
qemu-img convert -O vmdk ${source_img} ${target_img}
