 ARG BUILD_FROM
 FROM $BUILD_FROM
 
 LABEL io.hass.version="1.5" io.hass.type="addon" io.hass.arch="aarch64|amd64"
 
 # Set shell
 SHELL ["/bin/bash", "-o", "pipefail", "-c"]
 
-RUN dpkg --add-architecture i386 && apt update
-RUN apt update \
-    && apt install -y --no-install-recommends \
+ENV DEBIAN_FRONTEND=noninteractive
+
+# i386 aktivieren und alles in EINEM Layer installieren
+RUN dpkg --add-architecture i386 \
+    && apt update \
+    && apt install -y --no-install-recommends \
         sudo \
         locales \
         cups \
         cups-filters \
         avahi-daemon \
         libnss-mdns \
         dbus \
-+        udev \
+        udev \
         colord \
         printer-driver-all-enforce \
         printer-driver-all \
         printer-driver-splix \
         printer-driver-brlaser \
         printer-driver-gutenprint \
         openprinting-ppds \
         hpijs-ppds \
         hp-ppd  \
         hplip \
         printer-driver-foo2zjs \
         printer-driver-hpcups \
         printer-driver-escpr \
         cups-pdf \
         gnupg2 \
         lsb-release \
         nano \
         samba \
         bash-completion \
         procps \
         whois \
-+        ca-certificates wget curl \
-+        libc6:i386 libstdc++6:i386 zlib1g:i386 libusb-0.1-4:i386 \
+        ca-certificates wget curl \
+        libc6:i386 libstdc++6:i386 zlib1g:i386 libusb-0.1-4:i386 \
     && apt clean -y \
     && rm -rf /var/lib/apt/lists/*
 
 # --- Brother MFC-260C Treiber integrieren (i386 .deb) ---
-RUN mkdir -p /tmp/brother \
+RUN mkdir -p /tmp/brother \
   && wget -O /tmp/brother/mfc260clpr-1.0.1-1.i386.deb \
        https://download.brother.com/welcome/dlf006076/mfc260clpr-1.0.1-1.i386.deb \
   && wget -O /tmp/brother/mfc260ccupswrapper-1.0.1-1.i386.deb \
        https://download.brother.com/welcome/dlf006078/mfc260ccupswrapper-1.0.1-1.i386.deb \
   && dpkg -i /tmp/brother/mfc260clpr-1.0.1-1.i386.deb || true \
   && dpkg -i /tmp/brother/mfc260ccupswrapper-1.0.1-1.i386.deb || true \
-  && apt update && apt -f install -y \
+  && apt update && apt -f install -y \
   && find /usr -name 'brlpdwrapper*' -exec chmod 0755 {} \; \
   && rm -rf /tmp/brother
@@
 COPY rootfs /
 
 # Add user and disable sudo password checking
 RUN useradd \
   --groups=sudo,lp,lpadmin \
   --create-home \
   --home-dir=/home/print \
   --shell=/bin/bash \
   --password=$(mkpasswd print) \
   print \
 && sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers
 
 EXPOSE 631
 
 RUN chmod a+x /run.sh
 
 CMD ["/run.sh"]
