All functions on this page are tested by pipeline: [![Pipeline](https://github.com/laughingbiscuit/seandavis.sh/actions/workflows/pipeline.yml/badge.svg)](https://github.com/laughingbiscuit/seandavis.sh/actions/workflows/pipeline.yml)

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
  apk add git tmux curl busybox-extras pandoc gettext openjdk17 graphviz kubectl docker expect asciinema


  curl -sSL \
    "https://github.com/plantuml/plantuml/releases/download/v1.2023.11/plantuml-1.2023.11.jar" \
    -o /opt/plantuml.jar
  java -jar /opt/plantuml.jar -testdot
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | sh

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
```
