# SPDX-License-Identifier: MIT

BUILD_DIR := build

.PHONY: all clean
all:
	mkdir -p $(BUILD_DIR) && \
	cd $(BUILD_DIR) && \
	cmake -GNinja .. && \
	ninja

clean:
	rm -rf $(BUILD_DIR)
