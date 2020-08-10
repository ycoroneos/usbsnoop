
# Targets
.PHONY : all
all: build

.PHONY: build
build: check
	apio build

.PHONY: check
check:
	apio verify

.PHONY: flash
flash: build
	apio upload

.PHONY: sim
sim:
	apio sim

.PHONY: clean
clean:
	apio clean
