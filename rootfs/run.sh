#!/usr/bin/with-contenv bashio
# Hotplug-fähiger Start für CUPS + Avahi-Reflector
# Voraussetzung: udev-Paket im Image und udev: true in config.yaml

set -euo pipefail

ulimit -n 524288

# --- UDEV starten (Hotplug)
if command -v udevd >/dev/null 2>&1; then
  bashio::log.info "Starting udevd for USB hotplug"
  # im Debian-Image heißt der Daemon 'udevd'
  udevd --daemon
  # bestehende Geräte einmalig „neu ansagen“ und aufräumen
  udevadm control --reload || true
  udevadm trigger --action=add --type=subsystems --type=devices || true
  udevadm settle || true
else
  bashio::log.warning "udevd not found; hotplug will not work"
fi

# --- Auf Avahi-Socket warten (Reflector läuft separat über s6)
until [ -e /var/run/avahi-daemon/socket ]; do
  sleep 1s
done

bashio::log.info "Preparing CUPS directories"
if [ ! -d /config/cups ]; then
  cp -v -R /etc/cups /config
fi
rm -v -fR /etc/cups
ln -v -s /config/cups /etc/cups

# (Optional, hilfreich für Debug)
# sed -i 's/^LogLevel .*/LogLevel warn/' /etc/cups/cupsd.conf || true
# sed -i 's/^WebInterface .*/WebInterface Yes/' /etc/cups/cupsd.conf || true

bashio::log.info "Starting CUPS (foreground)"
exec cupsd -f
