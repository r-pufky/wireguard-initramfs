# Makefile for wireguard initramfs boot.

INITRAMFS = $(DESTDIR)/etc/initramfs-tools

.PHONY: help
help:
	@echo "USAGE:"
	@echo "  make install"
	@echo "        Install wireguard-initramfs and default configuration files."
	@echo
	@echo "  make uninstall"
	@echo "        Remove wireguard-initramfs from initramfs."
	@echo

.PHONY: root_check
root_check:
	@if ! [ "$(shell id -u)" = 0 ]; then echo "You must be root to perform this action."; exit 1; fi

.PHONY: install_dependencies_debian
install_dependencies_debian: root_check
	@apt update && apt install wget wireguard initramfs-tools

.PHONY: install_files
install_files:
	@install -vD initramfs/hooks "$(INITRAMFS)/hooks/wireguard"
	@install -vD initramfs/init-premount "$(INITRAMFS)/scripts/init-premount/wireguard"
	@install -vD initramfs/init-bottom "$(INITRAMFS)/scripts/init-bottom/wireguard"

.PHONY: install
install: root_check remove_legacy install_dependencies_debian
	@echo "Installing wireguard-initramfs ..."
	@chmod 0755 "./scripts/build_wg_setconf.sh"
	@./scripts/build_wg_setconf.sh $@ || exit 1
	@echo "... created wireguard configuration file."
	+$(MAKE) install_files
	@echo "Done."

.PHONY: uninstall
uninstall: root_check remove_legacy
	@echo "Uninstalling wireguard-initramfs ..."
	@rm -f "$(INITRAMFS)/hooks/wireguard"
	@rm -f "$(INITRAMFS)/scripts/init-premount/wireguard"
	@rm -f "$(INITRAMFS)/scripts/init-bottom/wireguard"
	@echo "Done."

.PHONY: remove_legacy
remove_legacy: root_check
	@rm -f "/usr/share/initramfs-tools/hooks/wireguard"
	@rm -f "/usr/share/initramfs-tools/scripts/init-premount/wireguard"
	@rm -f "/usr/share/initramfs-tools/scripts/init-bottom/wireguard"

.PHONY: build_initramfs
build_initramfs: root_check
	update-initramfs -u && update-grub

.PHONY: build_initramfs_rpi
build_initramfs_rpi: root_check
	cp /boot/firmware/config-"$(shell uname -r)" /boot
	mkinitramfs -o /boot/firmware/initramfs.gz "$(shell uname -r)"
