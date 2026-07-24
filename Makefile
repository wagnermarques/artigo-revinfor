.PHONY: build clean all help docker-build

# Container flavor: abnt (default, custom image) | overleaf (Overleaf-compatible)
# Choose at build time, e.g.:  make build ART=... FLAVOR=overleaf
#   abnt     -> ./Dockerfile          (texlive:latest + abntex2 + babel-portuges)
#   overleaf -> ./Dockerfile.overleaf (full TeX Live pinned to Overleaf's year)
FLAVOR ?= abnt
DOCKER_IMAGE_LATEX = $(if $(filter overleaf,$(FLAVOR)),artigo-revinfor-overleaf:latest,artigo-revinfor-latex:latest)
DOCKERFILE         = $(if $(filter overleaf,$(FLAVOR)),Dockerfile.overleaf,Dockerfile)

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
	@echo "  FLAVOR=abnt|overleaf           Container image (default: abnt)"
	@echo "                                 overleaf = Overleaf-compatible TeX Live"

# Build the LaTeX image for the chosen FLAVOR (abnt or overleaf).
# Only needs to be run once per flavor, or after changes to its Dockerfile.
docker-build:
	@case "$(FLAVOR)" in abnt|overleaf) ;; *) echo "Error: FLAVOR must be abnt or overleaf (got '$(FLAVOR)')"; exit 1 ;; esac
	docker build -t $(DOCKER_IMAGE_LATEX) -f $(DOCKERFILE) .

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
	docker run --rm -v "$(shell pwd):/workdir" -w /workdir/$(ART) $(DOCKER_IMAGE_LATEX) latexmk $(LATEXMK_FLAG) -jobname=$(PDF_NAME) -interaction=nonstopmode main.tex
	@echo ">> Generated: $(ART)/$(PDF_NAME).pdf  (flavor=$(FLAVOR), engine=$(ENGINE))"

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
		rm -rf $$art/*.aux $$art/*.log $$art/*.out $$art/*.toc $$art/*.lof $$art/*.lot \
			$$art/*.bbl $$art/*.blg $$art/*.fls $$art/*.fdb_latexmk $$art/*.synctex.gz \
			$$art/*.idx $$art/*.ilg $$art/*.ind $$art/*.nlo $$art/*.nls $$art/*.xdv \
			$$art/*.pdfxref $$art/main*.pdf; \
	done
	rm -rf *.aux *.log *.out *.toc *.bbl *.blg *.fls *.fdb_latexmk *.synctex.gz *.docx *.odt
