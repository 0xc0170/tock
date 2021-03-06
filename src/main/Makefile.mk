# Exports rules to build `kernel.o`, to be linked with platform specific code to
# compile a binary image. For convenience,Also exposes rules to 

CORE_SOURCES=$(call rwildcard,$(SRC_DIR)main/,*.rs)
MAIN_DEPS=$(BUILD_PLATFORM_DIR)/libcore.rlib $(BUILD_PLATFORM_DIR)/libsupport.rlib $(CORE_SOURCES)
MAIN_DEPS+=$(BUILD_PLATFORM_DIR)/libplatform.rlib $(BUILD_PLATFORM_DIR)/libprocess.rlib

$(BUILD_PLATFORM_DIR)/kernel.o: $(MAIN_DEPS) | $(BUILD_PLATFORM_DIR)
	@echo "Building $@"
	@$(RUSTC) $(RUSTC_FLAGS) -C lto --emit obj -o $@ $(SRC_DIR)main/main.rs

$(BUILD_PLATFORM_DIR)/kernel.S: $(MAIN_DEPS) | $(BUILD_PLATFORM_DIR)
	@echo "Building $@"
	@$(RUSTC) $(RUSTC_FLAGS) -C lto --emit asm -o $@ $(SRC_DIR)main/main.rs

$(BUILD_PLATFORM_DIR)/kernel.ir: $(MAIN_DEPS) | $(BUILD_PLATFORM_DIR)
	@echo "Building $@"
	@$(RUSTC) $(RUSTC_FLAGS) -C lto --emit llvm-ir -o $@ $(SRC_DIR)main/main.rs

