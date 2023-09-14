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
# 1 Introduction
###
#
# - Sean Davis
# - API Geek
# - Biker
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
  apk add git tmux curl busybox-extras pandoc gettext openjdk17
  curl -sSL "https://github.com/plantuml/plantuml/releases/download/v1.2023.11/plantuml-1.2023.11.jar" -o /opt/plantuml.jar
}
function install_dev_env_desktop {
  apk update
  apk add xfce-terminal dwm chromium
}
###
# 3.1. Dev Env Demo - PlantUML
###
function demo_plantuml_seq {
  cat << EOF | java -jar /opt/plantuml.jar -ttxt
@startuml
a->b: GET /
@enduml
EOF
}
# <img src="demo_plantuml_component.png">
function demo_plantuml_component {
  cat << EOF | java -jar /opt/plantuml.jar > demo_plantuml_component.png
@startuml
cloud GCP {
  rectangle uSvc as ms
  database Database as db
  ms->db
}
@enduml
EOF
}
# <img src="demo_plantuml_flow.png">
function demo_plantuml_flow {
  cat << EOF | java -jar /opt/plantuml.jar > demo_plantuml_flow.png
@startuml
:step one;
:step two;
@enduml
}
EOF
}

"$@"
