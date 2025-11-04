 ARG BUILD_FROM
 FROM $BUILD_FROM
 
 LABEL io.hass.version="1.5" io.hass.type="addon" io.hass.arch="aarch64|amd64"
 
 # Set shell
 SHELL ["/bin/bash", "-o", "pipefail", "-c"]
 
 RUN apt update \
     && apt install -y --no-install-recommends \
         sudo \
         locales \
         cups \
         cups-filters \
         avahi-daemon \
         libnss-mdns \
         dbus \
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
+        ca-certificates wget curl \
+        libc6:i386 libstdc++6:i386 zlib1g:i386 libusb-0.1-4:i386 \
     && apt clean -y \
     && rm -rf /var/lib/apt/lists/*
 
+# --- Brother MFC-260C Treiber integrieren (i386 .deb) ---
+RUN mkdir -p /tmp/brother \
+  && wget -O /tmp/brother/mfc260clpr-1.0.1-1.i386.deb \
+       https://download.brother.com/welcome/dlf006076/mfc260clpr-1.0.1-1.i386.deb \
+  && wget -O /tmp/brother/mfc260ccupswrapper-1.0.1-1.i386.deb \
+       https://download.brother.com/welcome/dlf006078/mfc260ccupswrapper-1.0.1-1.i386.deb \
+  && dpkg -i /tmp/brother/mfc260clpr-1.0.1-1.i386.deb || true \
+  && dpkg -i /tmp/brother/mfc260ccupswrapper-1.0.1-1.i386.deb || true \
+  && apt update && apt -f install -y \
+  && find /usr -name 'brlpdwrapper*' -exec chmod 0755 {} \; \
+  && rm -rf /tmp/brother
+
 # Add Canon cnijfilter2 driver
 RUN cd /tmp \
   && if [ "$(arch)" = 'x86_64' ]; then ARCH="amd64"; else ARCH="arm64"; fi \
   && curl https://gdlp01.c-wss.com/gds/0/0100012300/02/cnijfilter2-6.80-1-deb.tar.gz -o cnijfilter2.tar.gz \
   && tar -xvf ./cnijfilter2.tar.gz cnijfilter2-6.80-1-deb/packages/cnijfilter2_6.80-1_${ARCH}.deb \
   && mv cnijfilter2-6.80-1-deb/packages/cnijfilter2_6.80-1_${ARCH}.deb cnijfilter2_6.80-1.deb \
   && apt install ./cnijfilter2_6.80-1.deb
 
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
