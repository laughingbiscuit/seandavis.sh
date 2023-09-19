#!/bin/sh -e

################################
# ______________ 
#< seandavis.sh >
# -------------- 
#        \   ^__^
#         \  (oo)\_______
#            (__)\       )\/\
#                ||----w |
#                ||     ||
################################

# My notepad as a shell script

#################
# 1 Introduction
#################

# - Sean Davis
# - API Geek
# - Biker

##########################
# 2 Dev Environment Setup
##########################

# Since Alpine Linux 3.18, it's main issue has been solved.
# <a href="https://www.theregister.com/2023/05/16/alpine_linux_318/">(issue)</a>
# Time to return!

# To stay simple and portable, my minimal environment will use a few core
# tools in addition to busybox.

function install_dev_env {
cat <<EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF
  apk update
  apk add git \
    tmux \
    curl \
    busybox-extras \
    pandoc \
    gettext \
    openjdk17 \
    graphviz \
    kubectl \ 
    docker
  curl -sSL \
    "https://github.com/plantuml/plantuml/releases/download/v1.2023.11/plantuml-1.2023.11.jar" \
    -o /opt/plantuml.jar
  java -jar /opt/plantuml.jar -testdot
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | sh

}

function install_dev_env_desktop {
  apk update
  apk add \
    dwm \
    chromium \
    xterm
}

###############################
# 3.1. Dev Env Demo - PlantUML
###############################

function demo_plantuml_seq {
  cat << EOF | java -jar /opt/plantuml.jar -p > demo_plantuml_seq.png


@startuml
a->b: GET /
@enduml


EOF
}

# Output:
# <img src="demo_plantuml_seq.png">

function demo_plantuml_component {
  cat << EOF | java -jar /opt/plantuml.jar -p > demo_plantuml_component.png


@startuml
cloud GCP {
  rectangle uSvc as ms
  database Database as db
  ms->db
}
@enduml


EOF
}

# Output:
# <img src="demo_plantuml_component.png">

function demo_plantuml_flow {
  cat << EOF | java -jar /opt/plantuml.jar -p > demo_plantuml_flow.png


@startuml
:step one;
if (condition?) then (result1)
  :something;
else (result2)
  :something else;
endif
:step two;
@enduml


EOF
}
# Output:
# <img src="demo_plantuml_flow.png">

###
# 3.2 K3d Demo
###

# K3d is a tool that runs k3s, a minimal kubernetes distribution, in docker. This means
# that my host system only needs docker and can create multiple clusters for running
# projects locally.

function demo_k3d {
  k3d cluster create mycluster
  kubetctl get nodes
  docker ps
}


# Thank you!
"$@"
