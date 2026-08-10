.PHONY: build clean all help docker-build docker-build-editor editor

# Real path of the repo root ON THE HOST. Normally just $(shell pwd).
#
# Exception: when `make build` runs FROM INSIDE the code-server editor
# container (see `editor` target below), `pwd` there resolves to /workdir --
# that container's OWN view of the repo -- but the `docker run -v ...` below
# is sent to the HOST's Docker daemon (Docker-outside-of-Docker), which has
# no /workdir and would silently bind-mount an empty directory. The `editor`
# target works around this by injecting HOST_PROJECT_ROOT with the real host
# path, which this variable then prefers.
PROJECT_ROOT := $(or $(HOST_PROJECT_ROOT),$(shell pwd))

# Container flavor: abnt (default, custom image) | overleaf (Overleaf-compatible)
# Choose at build time, e.g.:  make build ART=... FLAVOR=overleaf
#   abnt     -> ./Dockerfile          (texlive:latest + abntex2 + babel-portuges)
#   overleaf -> ./Dockerfile.overleaf (full TeX Live pinned to Overleaf's year)
FLAVOR ?= abnt
DOCKER_IMAGE_LATEX = $(if $(filter overleaf,$(FLAVOR)),artigo-revinfor-overleaf:latest,artigo-revinfor-latex:latest)
DOCKERFILE         = $(if $(filter overleaf,$(FLAVOR)),Dockerfile.overleaf,Dockerfile)

# code-server editor container: flavor-agnostic (no TeX Live inside), talks
# to the HOST's Docker daemon via a mounted socket so it can build ART with
# either FLAVOR from the same running editor. See ides/code-server/Dockerfile.
DOCKER_IMAGE_EDITOR = artigo-revinfor-editor:latest
DOCKER_SOCK = /var/run/docker.sock
DOCKER_GID := $(shell stat -c '%g' $(DOCKER_SOCK) 2>/dev/null || stat -f '%g' $(DOCKER_SOCK) 2>/dev/null)

# Docker images
DOCKER_IMAGE_PANDOC = pandoc/core:latest

# LaTeX engine: pdf (default) | xe (XeLaTeX) | lua (LuaLaTeX)
# Choose at build time, e.g.:  make build ART=... ENGINE=xe
# All three engines live in the same image; this only changes a latexmk flag.
ENGINE ?= pdf
LATEXMK_FLAG := $(if $(filter xe,$(ENGINE)),-pdfxe,$(if $(filter lua,$(ENGINE)),-pdflua,-pdf))

# Output PDF base name encodes the flavor + engine that produced it, e.g.
# main-abnt-pdf.pdf, main-overleaf-xe.pdf. latexmk's -jobname renames all
# generated files (pdf, aux, log, ...) to this, so each combo stays separate.
PDF_NAME = main-$(FLAVOR)-$(ENGINE)

# Find all directories containing a main.tex file (articles live under artigos/)
ARTICLES = $(shell find . -maxdepth 3 -name "main.tex" -not -path "./common-shared/*" -not -path "./ides/*" -not -path "./main.tex" | xargs -n1 dirname | sed 's|./||')

help:
	@echo "First-time setup:"
	@echo "  make docker-build [FLAVOR=abnt|overleaf]   Build the LaTeX image (once per flavor)"
	@echo "  make docker-build-editor                   Build the code-server editor image (optional)"
	@echo ""
	@echo "Available articles to build:"
	@for art in $(ARTICLES); do echo "  - $$art"; done
	@echo ""
	@echo "Commands:"
	@echo "  make build ART=<folder_name>   Build a specific article PDF"
	@echo "  make all                       Build all articles"
	@echo "  make clean                     Remove intermediate files from all articles"
	@echo "  make clean ART=<folder_name>   Remove intermediate files from one article"
	@echo "  make editor                    Launch VS Code in the browser (see CODE_SERVER_TUTORIAL.org)"
	@echo ""
	@echo "Options:"
	@echo "  ENGINE=pdf|xe|lua              LaTeX engine (default: pdf)"
	@echo "                                 e.g. make build ART=<folder> ENGINE=xe"
	@echo "  FLAVOR=abnt|overleaf           Container image (default: abnt)"
	@echo "                                 overleaf = Overleaf-compatible TeX Live"

# Build the LaTeX image for the chosen FLAVOR (abnt or overleaf).
# Only needs to be run once per flavor, or after changes to its Dockerfile.
docker-build:
	@case "$(FLAVOR)" in abnt|overleaf) ;; *) echo "Error: FLAVOR must be abnt or overleaf (got '$(FLAVOR)')"; exit 1 ;; esac
	docker build -t $(DOCKER_IMAGE_LATEX) -f $(DOCKERFILE) .

# Build the code-server editor image. Only needs to be run once, or after
# changes to ides/code-server/Dockerfile.
docker-build-editor:
	docker build -t $(DOCKER_IMAGE_EDITOR) -f ides/code-server/Dockerfile ides/code-server

# Launch the editor: VS Code (code-server) in the browser at
# http://localhost:8080, pre-loaded with the LaTeX Workshop extension.
# No TeX Live inside -- it mounts the HOST's Docker socket and reuses this
# same Makefile's `build`/`docker-build` targets from its own integrated
# terminal, so both FLAVOR=abnt and FLAVOR=overleaf stay available from the
# one running editor (see the PROJECT_ROOT comment above for why
# HOST_PROJECT_ROOT is passed in).
# Password: printed by `docker logs artigo-revinfor-editor` on first run,
# and persisted afterwards in the named volume below.
editor:
	@if ! docker image inspect $(DOCKER_IMAGE_EDITOR) >/dev/null 2>&1; then \
		echo "Editor image '$(DOCKER_IMAGE_EDITOR)' not found locally."; \
		echo ">> First-time setup: run 'make docker-build-editor' before this."; \
		exit 1; \
	fi
	docker run --rm -it --name artigo-revinfor-editor \
		-p 127.0.0.1:8080:8080 \
		-v "$(PROJECT_ROOT):/workdir" \
		-v $(DOCKER_SOCK):$(DOCKER_SOCK) \
		$(if $(DOCKER_GID),--group-add $(DOCKER_GID)) \
		-v artigo-revinfor-editor-config:/home/coder/.config \
		-v artigo-revinfor-editor-data:/home/coder/.local/share/code-server \
		-e HOST_PROJECT_ROOT=$(PROJECT_ROOT) \
		-w /workdir \
		$(DOCKER_IMAGE_EDITOR)

# Build a specific article
# Usage: make build ART=artigo_modelo_revista_infor
build:
	@if [ -z "$(ART)" ]; then \
		echo "Error: Please specify the article folder using ART=<folder_name>"; \
		exit 1; \
	fi
	@case "$(ENGINE)" in pdf|xe|lua) ;; *) echo "Error: ENGINE must be pdf, xe or lua (got '$(ENGINE)')"; exit 1 ;; esac
	@case "$(FLAVOR)" in abnt|overleaf) ;; *) echo "Error: FLAVOR must be abnt or overleaf (got '$(FLAVOR)')"; exit 1 ;; esac
	@if ! docker image inspect $(DOCKER_IMAGE_LATEX) >/dev/null 2>&1; then \
		echo "LaTeX image '$(DOCKER_IMAGE_LATEX)' not found locally."; \
		echo ">> First-time setup: run 'make docker-build FLAVOR=$(FLAVOR)' before building."; \
		exit 1; \
	fi
	docker run --rm -v "$(PROJECT_ROOT):/workdir" -w /workdir/$(ART) $(DOCKER_IMAGE_LATEX) latexmk $(LATEXMK_FLAG) -jobname=$(PDF_NAME) -interaction=nonstopmode main.tex
	@echo ">> Generated: $(ART)/$(PDF_NAME).pdf  (flavor=$(FLAVOR), engine=$(ENGINE))"

# Build all articles
all:
	@for art in $(ARTICLES); do \
		echo "Building $$art..."; \
		$(MAKE) build ART=$$art; \
	done

# Remove LaTeX intermediate files. Leaves the final main*.pdf in place.
# Usage:
#   make clean                 Clean every article (and the repo root)
#   make clean ART=<folder>    Clean only that article's intermediates
CLEAN_EXTS = aux log out toc lof lot bbl blg brf fls fdb_latexmk synctex.gz \
	idx ilg ind nlo nls xdv pdfxref

clean:
	@if [ -n "$(ART)" ]; then \
		echo "Cleaning $(ART)..."; \
		for ext in $(CLEAN_EXTS); do rm -f $(ART)/*.$$ext; done; \
	else \
		for art in $(ARTICLES); do \
			echo "Cleaning $$art..."; \
			for ext in $(CLEAN_EXTS); do rm -f $$art/*.$$ext; done; \
		done; \
		for ext in $(CLEAN_EXTS) docx odt; do rm -f *.$$ext; done; \
	fi
