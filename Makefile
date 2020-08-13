.PHONY: default help contribute add-tool distribute-readme clean

SHELL             = /bin/bash
APP_NAME          = WebHackersWeapons
ADD_TOOL          = add-tool
DISTRIBUTE_README = distribute-readme
VERSION           = $(shell git describe --always --tags)
GIT_COMMIT        = $(shell git rev-parse HEAD)
GIT_DIRTY         = $(shell test -n "`git status --porcelain`" && echo "+CHANGES" || true)
BUILD_DATE        = $(shell date '+%Y-%m-%d-%H:%M:%S')

default: help

help:
	@echo 'Management commands for ${APP_NAME}:'
	@echo
	@echo 'Usage:'
	@echo '    make contribute            Compile ${ADD_TOOL} & ${DISTRIBUTE_README}.'
	@echo '    make add-tool              Build ${ADD_TOOL}'
	@echo '    make distribute-readme     Build ${DISTRIBUTE_README}'
	@echo '    make clean                 Clean the contribute file.'

	@echo

contribute: add-tool distribute-readme

add-tool:
	@echo "Build ${ADD_TOOL} ${VERSION}"
	@echo "GOPATH=${GOPATH}"
	go build -ldflags "-w -X github.com/hahwul/WebHackersWeapons/version.GitCommit=${GIT_COMMIT}${GIT_DIRTY} -X github.com/hahwul/WebHackersWeapons/version.Version=${VERSION} -X github.com/hahwul/WebHackersWeapons/version.BuildDate=${BUILD_DATE}" -o ./${ADD_TOOL} ./${ADD_TOOL}.go

distribute-readme:
	@echo "Build ${ADD_TOOL} ${VERSION}"
	@echo "GOPATH=${GOPATH}"
	go build -ldflags "-w -X github.com/hahwul/WebHackersWeapons/version.GitCommit=${GIT_COMMIT}${GIT_DIRTY} -X github.com/hahwul/WebHackersWeapons/version.Version=${VERSION} -X github.com/hahwul/WebHackersWeapons/version.BuildDate=${BUILD_DATE}" -o ./${DISTRIBUTE_README} ./${DISTRIBUTE_README}.go

clean:
	@echo "Removing ${APP_NAME} ${VERSION}"
	@test ! -e ${ADD_TOOL} || rm ${ADD_TOOL}
	@test ! -e ${DISTRIBUTE_README} || rm ${DISTRIBUTE_README}