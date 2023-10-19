This is my notepad.

# Development Environment

I like to keep things simple. I strive to develop expertise in a small number
of powerful, platform-agnostic open-source tools. This means that with a browser
and a terminal I have my favourite tools available and avoid vendor lock-in.

My development environment follows me. Whether using Linux, Windows and Busybox-w32,
Mac OS and Docker or Android and Termux I have what I need.

I like to start with an Alpine Linux base. I appreciate the philosophy, lightness,
simplicity and POSIX compliance of its components. For a while I was put off by
muslibc's lack of DNS over TCP, however this is resolved in newer versions.

I occasionally need to make exceptions when using tools that require glibc or have
no ARM support, however I can fallback to SSHing into a remote VM when needed.

Full applications run in Docker, K8s or a SaaS so are not included in my development 
environment.

## Installation

`curl -sSL https://seandavis.sh/raw | sh - -- install_dev_env`

```
function install_dev_env {

  cat << EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/v3.18/main
http://dl-cdn.alpinelinux.org/alpine/v3.18/community
EOF

  apk update
  apk add git tmux curl busybox-extras pandoc gettext openjdk17 graphviz \
    docker expect asciinema chromium chromium-chromedriver xvfb-run jq weasyprint
  apk add kubectl --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
  apk add mdp --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing


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
    xterm
}
```

## PlantUML

Learning the syntax of plantuml has allowed me to transfer the benefits 
of in-person whiteboarding into a remote environment, and the ability
of storing the source for a diagram in version control is much easier
to manage than an presentation or UI diagramming tool.

Typically I will create mindmaps, sequence, flow and component diagrams.
For anything else, I will create a plaintext file in `vi`.

```
function demo_plantuml_seq {
  cat << EOF | java -jar /opt/plantuml.jar -p > demo_plantuml_seq.png

@startuml
a->b: GET /
@enduml

EOF
}
```

![](demo_plantuml_seq.png)

```
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
```

![](demo_plantuml_component.png)

```
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
```

![](demo_plantuml_flow.png)

## Docker

Docker is the most important tool in my toolbox. With access to docker I can
spin up a lightweight development environment, run prebuilt images from docker hub,
run a headless browser, diff a container after running a process to see while files
have changed and even `rm -rf` without fear. Once software has been built in Docker,
it can then be run on many platforms including in a container orchestration platform
for production. I store all state in Dockerfile or mounted volumes, so I can regularly
clean up with `docker rm -f $(docker ps -a -q)`.

## Kubernetes

Deploying to EKS or GKE costs money. For local development there are a number of 
options. I use `k3d` as the only requirement is a docker environment and at the
time of write, `kind` doesn't play nicely with ARM [devices](https://github.com/rancher-sandbox/rancher-desktop/issues/5092).

```
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
  timeout 30 sh -c "while ! curl -f localhost:8080/; do sleep 2; done"

}
```

## Asciinema

Recording terminal sessions can be a little bit painful. When live recording,
there can be lots of typos and unnecessary pauses. When scripting, `tmux` is often
used to `send-keys` without human interaction, but given the complexity of waiting for
long running commands to complete, many people resort to random `sleep 10` commands.
`sleep`s have their place for allowing a viewer to read the screen, but not when you
have to estimate how long a command will run for.

Once the recording is complete, you also have to consider how it will be viewed. `script`
and `scriptreplay` are great locally, but a `gif` or embedded video is often desired
in a web page for normies to view.

After some experimentation, I found a sweet spot with `expect`, `asciinema` and a local
`asciinema-player` instead of pushing to their website. Thanks for the inspiration 
[Waleed](https://blog.waleedkhan.name/automating-terminal-demos/).

```

function demo_expect_asciinema {
  cat << EOF | expect -f -
set timeout 5
set send_human {0.1 0.3 1 0.05 1}
spawn asciinema rec --cols 60 --rows 15 out.cast

expect "~/seandavis.sh/target #"
send -h "echo Hello, world!"; sleep 2
send "\r"
expect "Hello, World!" -timeout 1

send -h "vi"; sleep 2
send "\r"; sleep 2

send -h "ihello"; sleep 2
send -h "\x1b"; sleep 2
send -h ":q!"; sleep 2
send "\r"
send -h "exit\r\n"

EOF
}
```

<div id="democast"></div>
<script>AsciinemaPlayer.create('/out.cast', document.getElementById('democast'));</script>

```
function demo_simple_rec {
  cat << EOF | expect -f -
set timeout 5
set send_human {0.1 0.3 1 0.05 1}
spawn asciinema rec --cols 60 --rows 15 simple.cast
expect "~/seandavis.sh/target #"
send -h "sh index.sh install_dev_env"; sleep 2
send "\r"
expect "~/seandavis.sh/target #"

EOF
}
```
<div id="simplecast"></div>
<script>AsciinemaPlayer.create('/simple.cast', document.getElementById('simplecast'));</script>

## Busybox

Busybox has a great core set of tools. With minimal POSIX versions of 
`vi`, `sed`, `awk`, `httpd` and `sh` you can build quite powerful solutions
for prototyping or deployment on embedded/lightweight devices. Busybox is 
also _tiny_ and comes as standard in Alpine Linux.

In a few lines, I can build a website:

```
function prototype_busybox_web {
  mkdir -p prototype_busybox_web 
  (cd prototype_busybox_web &&
    echo '<html><body><p>Hello World!</p></body></html>' > index.html &&
    httpd -p 8081 -h .
    while ! curl -f http://localhost:8081/; do sleep 1; done)
}
```

## Curl

With the rise of APIs in the global consciousness, the HTTP client space has
exploded. From UI tools like Postman, Insomnia and Paw to CLIs like `httpie` and
`hurl`, it can be overwhelming to choose. Let's keep it simple and stick to the
universal HTTP client. It's installed by default on many systems and its creator,
[Daniel Stenberg](https://daniel.haxx.se/) is a great role model for maintaining
and open source project.

## Pandoc

I believe that plain text files are the best way of record, sharing and 
evolving information - however not everybody likes reading it. By using
pandoc, I can generate websites (such as this one), word, powerpoint and pdf docs.

When generating documents for work, they may need styling to fit brand guidelines.
I find the latex syntax unintuitative and prefer to use `weasyprint` and `css` to
easily change fonts, colours and other styles. This requires python which is a bit
heavy, so I try to avoid the need to style my docs where possible.

```
function demo_pandoc_pdf {
  curl -sSL -o rs-fonts.zip https://github.com/RuneStar/fonts/releases/download/1.103-0/RuneScape-Fonts.zip
  (mkdir -p rs-fonts && cd rs-fonts && unzip ../rs-fonts.zip) 
  cat << EOF > rs.css
@font-face {
  font-family: "Runescape Plain 12";
  src: url(rs-fonts/ttf/RuneScape-Plain-12.ttf);
}
@page {
    @top-right{
        content: "Page " counter(page) " of " counter(pages);
    }
}
* {
    font-family: "Runescape Plain 12";
}
h1 {
  color: red;
}

EOF
  cat << EOF | pandoc --metadata title="" -s -c rs.css --pdf-engine weasyprint -o sample.html

# Hello World

Some text here
EOF
  pandoc --metadata title="" -s -c rs.css --pdf-engine weasyprint sample.html -o sample.pdf
}
```

<embed src="sample.pdf" type="application/pdf" width="100%" height="600px" />

## Git

Needs no explanation.

## Tmux

Tabs in the terminal. Set a nice colour scheme and title using:

```
function style_tmux {
  cat << EOF > $HOME/.tmux.conf
set -g status-bg red
set -g status-right Ferrari
set -g status-left ""
EOF
}
```

## MDP

Markdown presentation viewer in the terminal. Using this tool makes presentations
standout compared with powerpoints and it is really quick to use.

<div id="mdpcast"></div>
<script>AsciinemaPlayer.create('/mdp.cast', document.getElementById('mdpcast'));</script>

## Headless Chrome

I talked about how great `docker` and `curl` are earlier. Why not install Chrome
in docker, add `chromedriver` to allow automation via API for web testing?

I am inspired by [Shellnium](https://github.com/Rasukarusan/shellnium), but want to 
use busybox POSIX `sh` instead of `bash`.

```
function demo_headless_chrome_curl {
  xvfb-run chromedriver --disable-dev-shm-usage --disable-gpu --no-sandbox --disable-setuid-sandbox &
  timeout 10 sh -c "while ! curl -f localhost:9515/status; do sleep 2; done"
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

# Sample Project

## Brief

A small pizzeria serves two local villages. Following the Napoli tradition, they have a simple menu:

- Marinara
- Margherita

This sample project will help them with a digital transformation.


```
function gen_hlsa {
  cat << EOF | java -jar /opt/plantuml.jar -p > hlsa.png
@startuml
actor Customer as c
rectangle PerfectPizza as pp {
  rectangle MobileApp as app
  rectangle CDN as cdn
  rectangle WebApp as web
  rectangle "API GW/Ingress" as api
  rectangle "Service Mesh/Network" sm {
    rectangle "Microsvcs (HTTP/Streaming)" as u
    rectangle "IDP" as idp
    database "Persistence" as db
  }
  rectangle "Ops Tooling" as ops
}

c-d->pp
c-d->app
c-d->cdn
cdn-d->web
app-d->cdn
cdn-d->api
api-d->sm
u-d->db
idp-d->db

@enduml
EOF
}
```

![](hlsa.png)

# Programming Challenges

## Project Euler

Where possible, I solve these with busybox only. For more complex
performance requirements, I choose a more suitable tool.

Problem 1

```
function euler_1 {
  seq 999 | awk '{ if ($0 % 3 == 0 || $0 % 5 == 0) { sum+=$0}} END { print sum }'
}
```

Problem 2

```
function euler_2 {
  curl -sSL https://raw.githubusercontent.com/yousefvand/fibonacci/master/sequence.txt | \
    sed 's/^1, //' fib.txt | tr ',' '\n' | \
    awk '{ if ($0 < 4000000 && $0 % 2 == 0) {sum+=$0}} END {print sum}'
}
```

Problem 3

```
function euler_3 {
  factor 600851475143 | sed 's/.* \(.*\)$/\1/'
}
```

Problem 4

```
function euler_4 {
  echo 3 | awk 'BEGIN{ 
    max = (10 ^ $0)
    highest = 0
    for (i = 1; i < max; i++) {
      for (j = 1; j < max; j++) {
        # calculate product
        product = i*j

        # reverse string
        rev=""
        for(k=length(product);k!=0;k--) {
          rev=(rev substr(product,k,1))
        }

        # store highest
        if(product == rev && product > highest) {
          highest = product
        }
      }
    }
    print highest
  }'
}
```

# Contact
