# SPDX-License-Identifier: MIT

BUILD_DIR := build

.PHONY: all clean
all: ${BUILD_DIR}/build.ninja
	cd $(BUILD_DIR) && \
	ninja

${BUILD_DIR}/build.ninja: ${BUILD_DIR}
	cd $(BUILD_DIR) && \
	cmake -GNinja ..

${BUILD_DIR}:
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: docker-start
docker-start:
	@docker start i_offnariscv
	@docker attach i_offnariscv
