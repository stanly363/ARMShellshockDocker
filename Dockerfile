FROM arm64v8/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Clean, update, and install in a single command to prevent cache errors
RUN rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    build-essential \
    ncurses-dev \
    libcrypt-dev \
    apache2 \
    ca-certificates

# Define the full URL as a variable
WORKDIR /tmp
ARG BASH_URL=https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/bash/4.3-7ubuntu1/bash_4.3.orig.tar.gz

# Download and compile vulnerable Bash using the variable
RUN wget ${BASH_URL} && \
    tar -xzf bash_4.3.orig.tar.gz && \
    cd bash-4.3 && \
    ./configure --prefix=/usr --with-curses && \
    make && \
    make install && \
    cd / && rm -rf /tmp/bash*

RUN ln -sf /usr/bin/bash /bin/sh

RUN a2enmod cgi

# Use a 'here document' to create the script cleanly
RUN cat > /usr/lib/cgi-bin/vulnerable.sh <<'EOL'
#!/bin/sh
echo "Content-type: text/plain"
echo ""
echo "---CGI SCRIPT OUTPUT---"
printenv
EOL

# Make the script executable in a separate command
RUN chmod +x /usr/lib/cgi-bin/vulnerable.sh

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
