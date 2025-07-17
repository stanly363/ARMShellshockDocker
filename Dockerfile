FROM arm64v8/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile now correctly uses the default repositories for Ubuntu 22.04
RUN rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    build-essential \
    ncurses-dev \
    libcrypt-dev \
    apache2 \
    ca-certificates

WORKDIR /tmp
ARG BASH_URL=https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/bash/4.3-7ubuntu1/bash_4.3.orig.tar.gz
RUN wget ${BASH_URL} && \
    tar -xzf bash_4.3.orig.tar.gz && \
    cd bash-4.3 && \
    ./configure --prefix=/usr --with-curses && \
    make && \
    make install && \
    cd / && rm -rf /tmp/bash*

RUN ln -sf /usr/bin/bash /bin/sh

RUN a2enmod cgi

RUN cat > /usr/lib/cgi-bin/vulnerable.sh <<'EOL'
#!/bin/sh
echo "Content-type: text/plain"
echo ""
echo "---CGI SCRIPT OUTPUT---"
printenv
EOL

RUN chmod +x /usr/lib/cgi-bin/vulnerable.sh

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
