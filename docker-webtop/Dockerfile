FROM lscr.io/linuxserver/webtop:ubuntu-mate

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

RUN set -ex && \
	apt-get update && \
	apt-get install -y \
    chromium-browser \
		wget \
		terminator \
    eom && \
    echo "**** cleanup ****" && \
	apt-get autoclean && \
	rm -rf \
		/config/.cache \
		/config/.launchpadlib \
		/var/lib/apt/lists/* \
		/var/tmp/* \
		/tmp/*

RUN set -ex && \ 
	cd /tmp && \
	wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O code.deb && \
        dpkg -i code.deb && \
        rm -rf code.deb

# Si necesitan cosas que usen Java

# Agregar a apt-get
# openjdk-21-jdk \
# 		maven \

# RUN update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java" 1500
# RUN update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1500

# RUN set -ex && \
# cd /tmp && \
# wget https://download-cdn.jetbrains.com/idea/ideaIC-2025.2.5.tar.gz && \
# tar -xzf ideaIC-*.tar.gz -C /opt && \
# rm -rf ideaIC-*.tar.gz


