podman := podman
local_tag := nfs-server:latest
hub_tag := docker.io/aufin/nfs-server:latest
run_tag := $(local_tag)

build:
	$(podman) build -t $(local_tag) .
run:
	$(podman)  run -ti --name ecm-nfs --user=root -p 111:111/tcp  -p 111:111/udp -p 2049:2049/tcp -p 2049:2049/udp   -v /srv/ecm/shared:/data $(run_tag)

push:
	$(podman) tag $(local_tag)
	$(podman) push $(local_tag) $(hub_tag)
