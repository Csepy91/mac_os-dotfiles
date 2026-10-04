.PHONY: bootstrap prereqs brew custom stow unstow

bootstrap:
	./bootstrap.sh

prereqs:
	./bootstrap.sh --only prereqs

brew:
	./bootstrap.sh --only brew

custom:
	./bootstrap.sh --only custom

stow:
	./bootstrap.sh --only stow

unstow:
	./install/stow.sh --delete
