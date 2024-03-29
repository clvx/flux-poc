
#ENV = dev stage
ENV = dev

# ==============================================================================
# For full Kind v0.12 release notes: https://github.com/kubernetes-sigs/kind/releases/tag/v0.12.0
# Running from within k8s/kind
KIND_CLUSTER ?= flux
DASHBOARD_PASSWORD = "noadmin"

kind-up:
	for i in $(ENV); do kind create cluster \
		--image kindest/node:v1.27.2 \
		--name $(KIND_CLUSTER)-$$i \
		--config kind/kind-config.yaml; done

kind-down:
	for i in $(ENV); do kind delete cluster --name $(KIND_CLUSTER)-$$i; done

# ==============================================================================
GITHUB_USER = clvx
GITHUB_REPO = flux-poc

bootstrap: export GITHUB_TOKEN := $(shell cat ./.gh-token)
bootstrap:
	for i in $(ENV); do switch kind-flux-$$i && \
		flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=$(GITHUB_REPO) \
		--branch=master \
		--path=./clusters/$$i \
		--personal; done

gitops-install:
	curl --silent --location "https://github.com/weaveworks/weave-gitops/releases/download/v0.24.0/gitops-$(shell uname)-$(shell uname -m).tar.gz" | tar xz -C ./bin

gitops-dashboard:
	for i in $(ENV); do ./bin/gitops create dashboard ww-gitops \
	  --password=$(DASHBOARD_PASSWORD) \
	  --export > ./clusters/$(ENV)/weave-gitops-dashboard.yaml; done

alert:
	kubectl -n flux-system create secret generic telegram-token \
		--from-literal=token=$(shell cat .telegram-token) \
		--from-literal=address=https://api.telegram.org
