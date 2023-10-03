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

################# <a id="1" href="#1"><sub>jump</sub></a>
# 1 Introduction 
#################
# - Sean Davis
# - API Geek
# - Biker
#################

############################################################ <a id="2" href="#2"><sub>jump</sub></a>
# 2 Dev Environment Setup
############################################################
# Since Alpine Linux 3.18, it's main issue has been solved.
# <a href="https://www.theregister.com/2023/05/16/alpine_linux_318/">(issue)</a>
# Time to return!
#
# To stay simple and portable, my minimal environment will use a few core
# tools in addition to busybox.
############################################################

function install_dev_env {

  cat << EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF

  apk update
  apk add git tmux curl busybox-extras pandoc gettext openjdk17 graphviz kubectl docker expect asciinema


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

############################### <a id="3.1" href="#3.1"><sub>jump</sub></a>
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

######################################################################################## <a id="3.2" href="#3.2"><sub>jump</sub></a>
# 3.2 K3d Demo
########################################################################################
# K3d is a tool that runs k3s, a minimal kubernetes distribution, in docker. This means
# that my host system only needs docker and can create multiple clusters for running
# projects locally.
#
# Why not kind? It doesn't play nice in alpine on ARM
# see <a href="https://github.com/rancher-sandbox/rancher-desktop/issues/5092">here</a>
########################################################################################

function demo_k3d {
exit
  k3d cluster create -p "8080:80@loadbalancer"

  # Useful for overwriting current kube config:
  # k3d kubeconfig write k3s-default --output ~/.kube/config

  docker ps
  kubectl cluster-info
  docker pull nginx:latest
  docker tag nginx:latest my-nginx:0.1 
  k3d image import my-nginx:0.1 # similar to publishing to a registry - note this doesn't work for :latest
  kubectl create deployment nginx --image=my-nginx:0.1
  kubectl create service clusterip nginx --tcp=80:80
  kubectl create ingress nginx --rule="/=nginx:80" 
  while ! curl -f localhost:8080/; do sleep 2; done

}

############################## <a id="3.3" href="#3.3"><sub>jump</sub></a>
# 3.3 Expect + Asciinema demo
##############################

# Scripting recorded demos
# Loosely based on: https://blog.waleedkhan.name/automating-terminal-demos/

function demo_expect_asciinema {
  set -x
  cat << EOF | expect -f -
set timeout 5
set send_human {0.1 0.3 1 0.05 1}
set CTRLC \003

spawn asciinema rec out.cast

expect "~/seandavis.sh/target #"
send -h "echo Hello, world!"
sleep 2
send "\r"
expect "Hello, World!" -timeout 1
send -h "vi"
sleep 2
send "\r"
sleep 2
send -h "ihello"
sleep 2
send -h "\x1b"
sleep 2
send -h ":q!"
sleep 2
send "\r"
send -h "exit\r\n"
expect -timeout 1

EOF

}
# Output:
# <div id="democast"></div>

############################## <a id="4.1" href="#4.1"><sub>jump</sub></a>
# 4.1 Prototyping with Busybox
##############################
# Sometimes it is useful to build working prototypes, whilst
# making sure they are low-resolution and stakeholders don't
# believe it is the 'finished product'.
#
# Using busybox httpd, shell scripts and curl we can mock up
# user flows.
##############################

function prototype_busybox_web {
  mkdir -p prototype_busybox_web 
  (cd prototype_busybox_web &&
    echo "<html><body><p>Hello World!</p></body></html>" > index.html &&
    httpd -p 8081 -h .
    while ! curl -f http://localhost:8081/; do sleep 1; done
}

# Thank you!
"$@"
