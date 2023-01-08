
#ENV = dev stage
ENV = devpod

# ==============================================================================
# For full Kind v0.12 release notes: https://github.com/kubernetes-sigs/kind/releases/tag/v0.12.0
# Running from within k8s/kind
KIND_CLUSTER ?= flux

kind-up:
	for i in $(ENV); do kind create cluster \
		--image kindest/node:v1.23.4@sha256:0e34f0d0fd448aa2f2819cfd74e99fe5793a6e4938b328f657c8e3f81ee0dfb9 \
		--name $(KIND_CLUSTER)-$$i \
		--config kind/kind-config.yaml; done

kind-down:
	for i in $(ENV); do kind delete cluster --name $(KIND_CLUSTER)-$$i; done

# ==============================================================================
GITHUB_USER = clvx
GITHUB_REPO = flux-poc

bootstrap: export GITHUB_TOKEN := $(shell cat ./.gh-token)
bootstrap:
	for i in $(ENV); do kubectx kind-flux-$$i && \
		flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=$(GITHUB_REPO) \
		--branch=master \
		--path=./clusters/$$i \
		--personal; done

alert:
	kubectl -n flux-system create secret generic telegram-token \
		--from-literal=token=$(shell cat .telegram-token) \
		--from-literal=address=https://api.telegram.org

