FROM arm64v8/ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y libcrypt-dev
RUN apt-get install -y --no-install-recommends wget build-essential \
libncurses-dev apache2 ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
RUN wget \
https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/bash/4.3-7ubuntu1/bash_4.3.orig.tar.gz \
&& tar -xzf bash_4.3.orig.tar.gz && cd bash-4.3 && ./configure --prefix=/usr --with-curses make && make install && cd / && rm -rf /tmp/bash*
RUN ln -sf /usr/bin/bash /bin/sh
RUN a2enmod cgi
RUN echo ’#!/bin/sh’ > /usr/lib/cgi-bin/vulnerable.sh && \
echo ’echo "Content-type: text/plain"’ >>
/usr/lib/cgi-bin/vulnerable.sh && \
echo ’echo ""’ >> /usr/lib/cgi-bin/vulnerable.sh && \
echo ’echo "---CGI SCRIPT OUTPUT---"’ >>
/usr/lib/cgi-bin/vulnerable.sh && \
echo ’printenv’ >> /usr/lib/cgi-bin/vulnerable.sh && \
chmod +x /usr/lib/cgi-bin/vulnerable.sh
EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]
