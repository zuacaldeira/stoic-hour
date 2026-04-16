SDK ?= $(HOME)/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b
KEY ?= $(HOME)/.Garmin/ConnectIQ/keys/developer_key.der
DEVICE ?= fr265
OUT_DIR ?= build

DEVICES := fr265 fr265s fr955 fr965 venu3 venu3s epix2 epix2pro47mm vivoactive5

LD_LIB := $(HOME)/garmin/lib-compat/usr/lib/x86_64-linux-gnu

export LD_LIBRARY_PATH := $(LD_LIB):$(LD_LIBRARY_PATH)

.PHONY: build all test sim run clean help

help:
	@echo "Stoic Hour build targets"
	@echo "  make build           - build for $(DEVICE)"
	@echo "  make all             - build for all 9 devices"
	@echo "  make test            - build with --unit-test and run in simulator"
	@echo "  make sim             - launch the simulator"
	@echo "  make run             - sideload current build to simulator (requires sim running)"
	@echo "  make clean           - remove $(OUT_DIR)/"
	@echo ""
	@echo "Variables: SDK=$(SDK)"
	@echo "           KEY=$(KEY)"
	@echo "           DEVICE=$(DEVICE)"
	@echo "           DEVICES=$(DEVICES)"

$(OUT_DIR):
	mkdir -p $@

build: $(OUT_DIR)
	$(SDK)/bin/monkeyc -d $(DEVICE) -f monkey.jungle \
	    -o $(OUT_DIR)/StoicHour-$(DEVICE).prg -y $(KEY) -w

all: $(OUT_DIR)
	@for d in $(DEVICES); do \
	    printf "%-15s " $$d; \
	    $(SDK)/bin/monkeyc -d $$d -f monkey.jungle \
	        -o $(OUT_DIR)/StoicHour-$$d.prg -y $(KEY) 2>&1 | tail -1; \
	done

test: $(OUT_DIR)
	$(SDK)/bin/monkeyc -d $(DEVICE) -f monkey.jungle \
	    -o $(OUT_DIR)/StoicHour-test.prg -y $(KEY) --unit-test
	$(SDK)/bin/monkeydo $(OUT_DIR)/StoicHour-test.prg $(DEVICE) -t

sim:
	$(SDK)/bin/connectiq &

run:
	$(SDK)/bin/monkeydo $(OUT_DIR)/StoicHour-$(DEVICE).prg $(DEVICE)

clean:
	rm -rf $(OUT_DIR)/
