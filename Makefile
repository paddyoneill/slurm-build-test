SHELL := /bin/bash

SLURM_VERSION ?= 23.11.10
SLURM_MD5SUM ?= 9e3c2bf7b7c0f1a2951881573b3f00d2
SLURM_TARBALL ?= slurm-$(SLURM_VERSION).tar.bz2
SLURM_SOURCE ?= https://download.schedmd.com/slurm/$(SLURM_TARBALL)

HOST_DIR ?= /src
BUILD_DIR ?= /build

.PHONY: default
default:
        @echo "No target specified"

.PHONY: prep-host
prep-host: $(HOST_DIR)/$(SLURM_TARBALL)
$(HOST_DIR)/$(SLURM_TARBALL):
        @mkdir -p $(HOST_DIR)
        @curl -L $(SLURM_SOURCE) -o $(HOST_DIR)/$(SLURM_TARBALL)
        @if [[ $$(md5sum $(HOST_DIR)/$(SLURM_TARBALL) | awk '{print $$1}') != $(SLURM_MD5SUM) ]]; then \
                echo "$(SLURM_TARBALL) md5sum does not match expected value: $(SLURM_MD5SUM)"; \
                exit 1; \
        fi

.PHONY: common
common:
        @mkdir -p $(BUILD_DIR)
        @cp $(HOST_DIR)/$(SLURM_TARBALL) $(BUILD_DIR)/

.PHONY: rocky-build
rocky-build: common

.PHONY: rocky-release
rocky-release: common

.PHONY: ubuntu-build
ubuntu-build: common
        @apt -y update && apt -y upgrade
        @ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
        @DEBIAN_FRONTEND=noninteractive apt -y install tzdata
        @dpkg-reconfigure --frontend noninteractive tzdata
        @apt -y install build-essential curl devscripts fakeroot equivs lsb-release
        @curl -L https://repo.radeon.com/amdgpu-install/6.2.4/ubuntu/$$(lsb_release -sc 2>/dev/null)/amdgpu-install_6.2.60204-1_all.deb -o /tmp/amdgpu-install.deb
        @apt -y install /tmp/amdgpu-install.deb
        @apt -y update
        @apt -y install rocm-smi-lib
        @tar -C $(BUILD_DIR) -xf $(BUILD_DIR)/$(SLURM_TARBALL)
        @pushd $(BUILD_DIR)/slurm-$(SLURM_VERSION) && \
                yes | mk-build-deps -i debian/control && \
                debuild -b -uc -us

.PHONY: ubuntu-release
ubuntu-release: ubuntu-build
        @find $(BUILD_DIR) -maxdepth 1 -name '*.deb' -printf '%f\n' | xargs tar -C $(BUILD_DIR) -cf $(HOST_DIR)/slurm-$(SLURM_VERSION)-ubuntu-$$(lsb_release -sr 2>/dev/null).tar.gz