# The class to append/remove flags to/from /etc/chrome_dev.conf
RDEPEND="chromeos-base/chromeos-login"
DEPEND="${RDEPEND}"
#the flags need be added"
#CHROME_DEV_FLAGS=""
#the flags need be removed"
#CHROME_REMOVE_FLAGS=""
CHROME_TMP_CONFIG="chrome_dev.conf"
CHROME_TMP_UI="ui.override"

S=${WORKDIR}

check_file() {
  if [ ! -f $1 ]; then 
     eerror "$1 doesn't exist."
  fi
}

append_flags() {
    local chrome_dev=$CHROME_TMP_CONFIG
    for flag in $@; do
      if [ -z "`grep -e $flag $chrome_dev`" ]; then
        echo "--${flag}" >> $chrome_dev
      fi
    done  
}

remove_flags() {
    local chrome_dev=$CHROME_TMP_CONFIG
    for flag in $@; do
        sed -i "/${flag}/d" $chrome_dev
    done
}

append_flags_ui() {
    local origin_flags
    local real_flags
    if [ -f ${ROOT}/etc/init/${CHROME_TMP_UI} ]; then
        origin_flags=$(grep -E "^env CHROME_COMMAND_FLAG=.*" ${ROOT}/etc/init/${CHROME_TMP_UI})
        origin_flags=${origin_flags#*\"}
        origin_flags=${origin_flags%\"*}
    fi
    for flag in ${CHROME_DEV_FLAGS}; do
        [ -z "$(echo $origin_flags | grep -e $flag)" ] && real_flags="${real_flags} ${flag}"
    done
    real_flags="${origin_flags}${real_flags}"    
    if [ -n "$real_flags" ]; then
        sed -i "/^env CHROME_COMMAND_FLA/s/G.*/G=\"${real_flags}\"/g" $CHROME_TMP_UI
    fi
}

src_compile() {
    check_file ${ROOT}/etc/chrome_dev.conf
    check_file ${ROOT}/etc/init/ui.conf
    cat ${ROOT}/etc/chrome_dev.conf > $CHROME_TMP_CONFIG
    cat ${ROOT}/etc/init/ui.conf > $CHROME_TMP_UI
    if [ -n "$CHROME_DEV_FLAGS" ]; then
      if use force-chinese; then
         CHROME_DEV_FLAGS="${CHROME_DEV_FLAGS} --lang=zh-CN LANGUAGE=zh-CN"
      fi
      einfo "append flags: ${CHROME_DEV_FLAGS}"
      append_flags $CHROME_DEV_FLAGS
      append_flags_ui
    fi
    if [ -n "$CHROME_REMOVE_FLAGS" ]; then
      einfo "remove flags: ${CHROME_DEV_FLAGS}"
      remove_flags $CHROME_REMOVE_FLAGS
    fi
}

src_install() {
    insinto /etc
    doins $CHROME_TMP_CONFIG
    insinto /etc/init
    doins $CHROME_TMP_UI
}
