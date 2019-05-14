# Setup DAML development environment

### Docker build

```
docker build -t tanvk/daml-centos7.6 .
```

### Docker run

mount an application volume to persist application data.
an absolute path is required.

```
mkdir -p ./data
docker run --rm -it -v "$(pwd)/projects":/home/tanvk/projects -p 6865:6865 -p 4000:4000 -t tanvk/daml-centos7.6
```

### Optional: DAML quickstart

Compile the DAML model in a docker instance:
  cd quickstart
  da run damlc -- package daml/Main.daml target/daml/iou

run the sandbox(a lightweight local version of the ledger):
  da run sandbox -- --scenario Main:setup target/daml/* &

start the navigator:
  da run navigator -- server &

