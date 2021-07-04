# Makefile for wireguard initramfs boot.

# You can set these variables from the command line, and also
# from the environment for the first two.
TARGETDIR = /etc/wireguard-initramfs
INITRAMFS = /usr/share/initramfs-tools

help:
	@echo "USAGE:"
	@echo "  make install"
	@echo "        Install wireguard-initramfs and default configuration files."
	@echo "        Requires additional configuration!"
	@echo
	@echo "  make uninstall"
	@echo "        Remove wireguard-initramfs from initramfs, leaves "
	@echo "        $(TARGETDIR). Does not need to be installed."
	@echo

.PHONY: help Makefile

install:
	@if ! [ "$(shell id -u)" = 0 ]; then echo "You must be root to perform this action."; exit 1; fi
	@echo "Installing wireguard-initramfs ..."
	@apt update && apt install initramfs-tools
	@mkdir -p "$(TARGETDIR)"
	@touch "$(TARGETDIR)/private_key"
	@chmod 0400 "$(TARGETDIR)/private_key"
	@cp -v config "$(TARGETDIR)/config"
	@chmod 0644 "$(TARGETDIR)/config"
	@cp -v hooks "$(INITRAMFS)/hooks/wireguard"
	@cp -v init-premount "$(INITRAMFS)/scripts/init-premount/wireguard"
	@cp -v init-bottom "$(INITRAMFS)/scripts/init-bottom/wireguard"
	@echo "Done."
	@echo
	@echo "Setup $(TARGETDIR)/config and run:"
	@echo
	@echo "  update-initramfs -u && update-grub"
	@echo "Done."

uninstall:
	@if ! [ "$(shell id -u)" = 0 ]; then echo "You must be root to perform this action."; exit 1; fi
	@echo "Uninstalling wireguard-initramfs ..."
	@rm -f "$(INITRAMFS)/hooks/wireguard"
	@rm -f "$(INITRAMFS)/scripts/init-premount/wireguard"
	@rm -f "$(INITRAMFS)/scripts/init-bottom/wireguard"
	@echo "Done."
	@echo
