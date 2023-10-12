# Section 1

## Subsection 1

```
function install_dev_env {

  cat << EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF

  apk update
  apk add git tmux curl busybox-extras pandoc gettext openjdk17 graphviz \
    kubectl docker expect asciinema chromium chromium-chromedriver xvfb-run jq


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

function demo_plantuml_seq {
  cat << EOF | java -jar /opt/plantuml.jar -p > demo_plantuml_seq.png


@startuml
a->b: GET /
@enduml


EOF
}

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

while [[ $(cat out.cast | wc -l) -lt 2 ]]; do sleep 2; done
cat out.cast | tail -n +2 > out.snip
echo '{"version": 2, "width": 66, "height": 15, "timestamp": 1695663471, "env": {"SHELL": "/bin/ash", "TERM": "xterm-256color"}}' > out.cast
cat out.snip >> out.cast

}
```

Test text

```
function test {
  echo "test"
}
```

# Section 2

Test again

```
function hello {
  echo '<html><body><p>Hello World!</p></body></html>' > index.html
}
function prototype_busybox_web {
  mkdir -p prototype_busybox_web 
  (cd prototype_busybox_web &&
    echo '<html><body><p>Hello World!</p></body></html>' > index.html &&
    httpd -p 8081 -h .
    while ! curl -f http://localhost:8081/; do sleep 1; done)
}
```

## Images

![](demo_plantuml_seq.png)

![](demo_plantuml_component.png)

![](demo_plantuml_flow.png)

<div id="democast"></div>
<script>AsciinemaPlayer.create('/out.cast', document.getElementById('democast'));</script>


# Headless chrome

```
function demo_headless_chrome_curl {
  xvfb-run chromedriver --disable-dev-shm-usage --disable-gpu --no-sandbox --disable-setuid-sandbox &
  while ! curl -f localhost:9515/status; do sleep 2; done
  SESSION_ID=$(curl localhost:9515/session -d '{
    "desiredCapabilities": {
      "browserName": "chromium",
      "chromeOptions": {
        "args": ["--no-sandbox", "--headless"]
      }
    }
  }'| jq -r '.sessionId')
  
  sleep 2
  curl -s localhost:9515/session/$SESSION_ID/url -d '{"url":"https://example.com/"}' >/dev/null
  sleep 2
  curl localhost:9515/session/$SESSION_ID/screenshot | jq -r '.value' | base64 -d > last-screenshot.png
}
```

![](last-screenshot.png)
