.PHONY: build clean

# The PDF filename
PROJECT = main

# Docker image to use
DOCKER_IMAGE = texlive/texlive:latest

# Build the PDF using latexmk inside Docker
build:
	docker run --rm -v "$(shell pwd):/workdir" -w /workdir $(DOCKER_IMAGE) latexmk -pdf -interaction=nonstopmode $(PROJECT).tex

# Remove intermediate files
clean:
	docker run --rm -v "$(shell pwd):/workdir" -w /workdir $(DOCKER_IMAGE) latexmk -C $(PROJECT).tex
	rm -rf *.aux *.log *.out *.toc *.lof *.lot *.bbl *.blg *.fls *.fdb_latexmk *.synctex.gz
