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
  apk add git tmux curl busybox-extras pandoc gettext openjdk17 graphviz kubectl docker expect asciinema

  curl -sSL \
    "https://github.com/plantuml/plantuml/releases/download/v1.2023.11/plantuml-1.2023.11.jar" \
    -o /opt/plantuml.jar
  curl -sSL \
    "https://github.com/asciinema/agg/releases/download/v1.4.2/agg-x86_64-unknown-linux-musl" \
    -o /usr/bin/agg
  chmod +x /usr/bin/agg
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
#
# Why not kind? It doesn't play nice in alpine on ARM
# see <a href="https://github.com/rancher-sandbox/rancher-desktop/issues/5092">here</a>

function demo_k3d {
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

###
# 3.3 Expect + Asciinema demo
###

# Scripting recorded demos
# Loosely based on: https://blog.waleedkhan.name/automating-terminal-demos/
# try in tmux?

function demo_expect_asciinema {
set -x
  cat << EOF > recscript
set timeout 1
set send_human {0.1 0.3 1 0.05 1}
set CTRLC \003

proc expect_prompt {} {
    expect "$ "
}

proc run_command {cmd} {
    send -h "$cmd"
    sleep 3
    send "\r"
    expect -timeout 1
}

proc send_keystroke_to_interactive_process {key {addl_sleep 2}} {
    send "$key"
    expect -timeout 1
    sleep $addl_sleep
}

spawn asciinema rec out.cast
expect_prompt

run_command "echo Hello, world!"
run_command "vi foo.txt"

send_keystroke_to_interactive_process "i"
send_keystroke_to_interactive_process "Example text"
send -h "Example text"
send_keystroke_to_interactive_process "$CTRLC"
send -h ":wq\r"
expect_prompt

send "exit"
EOF
mkfifo /wait
tmux new-session -d -s recsession
tmux send-keys -t recsession.0 "expect -f recscript; echo . > /wait ENTER"
read -t 30 WAIT <>/wait

[ -z "$WAIT" ] && 
  echo 'The operation failed to complete within 10 seconds.' ||
  agg out.cast out.gif

}
# Output:
# <img src="out.gif">

# Thank you!
"$@"
