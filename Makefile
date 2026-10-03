.PHONY: bootstrap prereqs brew custom stow unstow macos capture-vm capture-metal compare-metal

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

macos:
	./bootstrap.sh --only macos

capture-vm:
	./macos/capture.sh vm

capture-metal:
	./macos/capture.sh metal

compare-metal:
	./macos/compare.sh vm metal
