#!/bin/sh -e

###
# ______________ 
#< seandavis.sh >
# -------------- 
#        \   ^__^
#         \  (oo)\_______
#            (__)\       )\/\
#                ||----w |
#                ||     ||
###
#
# My notepad as a shell script
# 
###
# 2 Dev Environment Setup
###
#
# Since Alpine Linux 3.16, DNS over TCP issues have been resolved. Its
# time to give it another try!
#
# To stay simple and portable, my minimal environment will use a few core
# tools in addition to busybox.
#
function install_dev_env {
  apk update
  apk add git tmux curl busybox-extras pandoc gettext
}

"$@"
