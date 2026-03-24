FROM cassandra:5.0

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        procps \
        iproute2 \
        iputils-ping \
        net-tools \
        nano && \
    mkdir -p /run/sshd && \
    echo 'root:rootpass' | chpasswd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/^#?PasswordAuthentication\s+.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -ri 's/^#?UsePAM\s+.*/UsePAM yes/' /etc/ssh/sshd_config && \
    ssh-keygen -A && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY docker/entrypoint-with-ssh.sh /usr/local/bin/entrypoint-with-ssh.sh
RUN chmod +x /usr/local/bin/entrypoint-with-ssh.sh

ENTRYPOINT ["/usr/local/bin/entrypoint-with-ssh.sh"]
CMD ["cassandra", "-f"]