.PHONY: build clean docx odt

# The filenames
PROJECT = main

# Docker images to use
DOCKER_IMAGE_LATEX = texlive/texlive:latest
DOCKER_IMAGE_PANDOC = pandoc/core:latest

# Build the PDF using latexmk inside Docker
build:
	docker run --rm -v "$(shell pwd):/workdir" -w /workdir $(DOCKER_IMAGE_LATEX) latexmk -pdf -interaction=nonstopmode $(PROJECT).tex

# Convert LaTeX to DOCX (MS Word)
docx:
	docker run --rm -v "$(shell pwd):/data" $(DOCKER_IMAGE_PANDOC) -s $(PROJECT).tex -o $(PROJECT).docx --citeproc --bibliography=references.bib --toc

# Convert LaTeX to ODT (LibreOffice)
odt:
	docker run --rm -v "$(shell pwd):/data" $(DOCKER_IMAGE_PANDOC) -s $(PROJECT).tex -o $(PROJECT).odt --citeproc --bibliography=references.bib --toc

# Remove intermediate files
clean:
	docker run --rm -v "$(shell pwd):/workdir" -w /workdir $(DOCKER_IMAGE_LATEX) latexmk -C $(PROJECT).tex
	rm -rf *.aux *.log *.out *.toc *.lof *.lot *.bbl *.blg *.fls *.fdb_latexmk *.synctex.gz *.docx *.odt
