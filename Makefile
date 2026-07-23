.PHONY: build clean all help docker-build

# Docker images
DOCKER_IMAGE_LATEX = artigo-revinfor-latex:latest
DOCKER_IMAGE_PANDOC = pandoc/core:latest

# LaTeX engine: pdf (default) | xe (XeLaTeX) | lua (LuaLaTeX)
# Choose at build time, e.g.:  make build ART=... ENGINE=xe
# All three engines live in the same image; this only changes a latexmk flag.
ENGINE ?= pdf
LATEXMK_FLAG := $(if $(filter xe,$(ENGINE)),-pdfxe,$(if $(filter lua,$(ENGINE)),-pdflua,-pdf))

# Find all directories containing a main.tex file (articles live under artigos/)
ARTICLES = $(shell find . -maxdepth 3 -name "main.tex" -not -path "./common-shared/*" -not -path "./ides/*" -not -path "./main.tex" | xargs -n1 dirname | sed 's|./||')

help:
	@echo "First-time setup:"
	@echo "  make docker-build              Build the custom LaTeX image (run once)"
	@echo ""
	@echo "Available articles to build:"
	@for art in $(ARTICLES); do echo "  - $$art"; done
	@echo ""
	@echo "Commands:"
	@echo "  make build ART=<folder_name>   Build a specific article PDF"
	@echo "  make all                       Build all articles"
	@echo "  make clean                     Remove all build artifacts"
	@echo ""
	@echo "Options:"
	@echo "  ENGINE=pdf|xe|lua              LaTeX engine (default: pdf)"
	@echo "                                 e.g. make build ART=<folder> ENGINE=xe"

# Build the custom image (texlive + abntex2 + babel-portuges)
# Only needs to be run once, or after changes to the Dockerfile.
docker-build:
	docker build -t $(DOCKER_IMAGE_LATEX) .

# Build a specific article
# Usage: make build ART=artigo_modelo_revista_infor
build:
	@if [ -z "$(ART)" ]; then \
		echo "Error: Please specify the article folder using ART=<folder_name>"; \
		exit 1; \
	fi
	@case "$(ENGINE)" in pdf|xe|lua) ;; *) echo "Error: ENGINE must be pdf, xe or lua (got '$(ENGINE)')"; exit 1 ;; esac
	@if ! docker image inspect $(DOCKER_IMAGE_LATEX) >/dev/null 2>&1; then \
		echo "LaTeX image '$(DOCKER_IMAGE_LATEX)' not found locally."; \
		echo ">> First-time setup: run 'make docker-build' before building."; \
		exit 1; \
	fi
	docker run --rm -v "$(shell pwd):/workdir" -w /workdir/$(ART) $(DOCKER_IMAGE_LATEX) latexmk $(LATEXMK_FLAG) -interaction=nonstopmode main.tex

# Build all articles
all:
	@for art in $(ARTICLES); do \
		echo "Building $$art..."; \
		$(MAKE) build ART=$$art; \
	done

# Clean all articles and root
clean:
	@for art in $(ARTICLES); do \
		echo "Cleaning $$art..."; \
		docker run --rm -v "$(shell pwd):/workdir" -w /workdir/$$art $(DOCKER_IMAGE_LATEX) latexmk -C main.tex; \
		rm -rf $$art/*.aux $$art/*.log $$art/*.out $$art/*.toc $$art/*.bbl $$art/*.blg $$art/*.fls $$art/*.fdb_latexmk; \
	done
	rm -rf *.aux *.log *.out *.toc *.bbl *.blg *.fls *.fdb_latexmk *.synctex.gz *.docx *.odt
