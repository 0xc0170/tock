CHIP := nrf51822
ARCH := cortex-m0
TOCK_PLATFORM_LINKER_SCRIPT = $(TOCK_DIR)/chips/nrf_pca10001/loader.ld

include $(TOCK_APPS_DIR)/Makefile.Arm-M.mk

JLINK_OPTIONS := -device nrf51822 -if swd -speed 1000
JLINK_EXE ?= JLinkExe

# Apps to link may grow over time so defer expanding that
.SECONDEXPANSION:
$(TOCK_APP_BUILD_DIR)/kernel_and_app.elf: $(TOCK_BUILD_DIR)/arch.o $(TOCK_BUILD_DIR)/kernel.o $$(APPS_TO_LINK_TO_KERNEL) | $(TOCK_BUILD_DIR)
	@tput bold ; echo "Linking $@" ; tput sgr0
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ $(LDFLAGS) -Wl,-Map=$(TOCK_APP_BUILD_DIR)/kernel_and_app.Map -o $@
	$(OBJDUMP) $(OBJDUMP_FLAGS) $@ > $(TOCK_APP_BUILD_DIR)/kernel_and_app.lst
	$(SIZE) $@

$(TOCK_APP_BUILD_DIR)/kernel_and_app.bin: $(TOCK_APP_BUILD_DIR)/kernel_and_app.elf
	@tput bold ; echo "Flattening $< to $@..." ; tput sgr0
	$(OBJCOPY) -O binary $< $@

$(TOCK_APP_BUILD_DIR)/kernel_and_app.sdb: $(TOCK_APP_BUILD_DIR)/kernel_and_app.elf
	@tput bold ; echo "Packing SDB..." ; tput sgr0
	$(SLOAD) pack -m "$(SDB_MAINTAINER)" -v "$(SDB_VERSION)" -n "$(SDB_NAME)" -d $(SDB_DESCRIPTION) -o $@ $<

all: $(TOCK_APP_BUILD_DIR)/kernel_and_app.sdb


# "Flash" process:
# 1) set NVMC.CONFIG to 1 (Write enabled)
# 2) write firmware at address 0
# 3) set NVMC.CONFIG to 0 (Read only access)
.PHONY: program
program: $(BUILD_PLATFORM_DIR)/main.bin
	echo \
	connect\\n\
	w4 4001e504 1\\n\
	loadbin $< 0\\n\
	w4 4001e504 0\\n\
	r\\n\
	g\\n\
	exit | $(JLINK) $(JLINK_OPTIONS)

# "Erase all" process:
# 1) set NVMC.CONFIG to 2 (Erase enabled)
# 2) set NVMC.ERASEALL to 1 (Start chip erase)
# 3) wait some time for erase to finish
# 4) set NVMC.CONFIG to 0 (Read only access)
.PHONY: erase-all
erase-all:
	echo \
	connect\\n\
	w4 4001e504 2\\n\
	w4 4001e50c 1\\n\
	sleep 100\\n\
	w4 4001e504 0\\n\
	r\\n\
	exit | $(JLINK) $(JLINK_OPTIONS)

