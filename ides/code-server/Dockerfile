# Editor-only container: code-server (VS Code in the browser) + LaTeX Workshop.
#
# Deliberately does NOT install TeX Live. It stays flavor-agnostic and shells
# out to the existing abnt/overleaf build containers via the HOST's Docker
# daemon (Docker-outside-of-Docker: the host's /var/run/docker.sock is
# bind-mounted in at `docker run` time -- see `make editor` in the Makefile).
# This lets you run `make build ART=... FLAVOR=abnt` and
# `make build ART=... FLAVOR=overleaf` from the SAME running editor, instead
# of being locked into whichever single image a "devcontainer" would attach
# you to.
FROM codercom/code-server:latest

USER root

# docker-cli only (no dockerd/containerd) -- just needs to talk to the
# socket mounted in from the host.
RUN apt-get update \
    && apt-get install -y --no-install-recommends docker-cli git make \
    && rm -rf /var/lib/apt/lists/*

USER coder

RUN code-server --install-extension James-Yu.latex-workshop

WORKDIR /workdir
