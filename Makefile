# Makefile for wireguard initramfs boot.

TARGETDIR = $(DESTDIR)/etc/wireguard-initramfs
INITRAMFS = $(DESTDIR)/etc/initramfs-tools
DOCSDIR   = $(DESTDIR)/usr/local/share/docs/wireguard-initramfs

.PHONY: help 
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
	@echo "Example configuration located at: $(DOCSDIR)"
	@echo

.PHONY: root_check
root_check:
	@if ! [ "$(shell id -u)" = 0 ]; then echo "You must be root to perform this action."; exit 1; fi

.PHONY: install_deps
install_deps: root_check
	@apt update && apt install initramfs-tools

.PHONY: install_files
install_files:
	@mkdir -p "$(TARGETDIR)"
	@touch "$(TARGETDIR)/private_key"
	@chmod 0600 "$(TARGETDIR)/private_key"
	@touch "$(TARGETDIR)/pre_shared_key"
	@chmod 0600 "$(TARGETDIR)/pre_shared_key"
	@cp -vn config "$(TARGETDIR)/config"
	@chmod 0644 "$(TARGETDIR)/config"
	@install -vD hooks "$(INITRAMFS)/hooks/wireguard"
	@install -vD init-premount "$(INITRAMFS)/scripts/init-premount/wireguard"
	@install -vD init-bottom "$(INITRAMFS)/scripts/init-bottom/wireguard"
	@install -vD -m0644 config "$(DOCSDIR)/examples/config"

.PHONY: install
install: root_check remove_legacy install_deps
	@echo "Installing wireguard-initramfs ..."
	+$(MAKE) install_files
	@echo "Done."
	@echo
	@echo "Setup $(TARGETDIR)/config and run:"
	@echo
	@echo "  update-initramfs -u && update-grub"
	@echo
	@echo "Done."

.PHONY: uninstall
uninstall: root_check remove_legacy
	@echo "Uninstalling wireguard-initramfs ..."
	@rm -f "$(INITRAMFS)/hooks/wireguard"
	@rm -f "$(INITRAMFS)/scripts/init-premount/wireguard"
	@rm -f "$(INITRAMFS)/scripts/init-bottom/wireguard"
	@rm -rf "$(DOCSDIR)"
	@echo
	@echo "Done."

.PHONY: remove_legacy
remove_legacy: root_check
	@rm -f "/usr/share/initramfs-tools/hooks/wireguard"
	@rm -f "/usr/share/initramfs-tools/scripts/init-premount/wireguard"
	@rm -f "/usr/share/initramfs-tools/scripts/init-bottom/wireguard"
