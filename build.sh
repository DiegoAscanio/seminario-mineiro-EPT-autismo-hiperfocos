#!/bin/bash
docker run --rm --name latex-builder -it -v `pwd`:/document diegoascanio/cefetmg:academic-pandoc-template-builder /usr/local/bin/compilar_trabalho.sh "$@"
