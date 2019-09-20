FROM alpine:3.10

LABEL maintainer="steven@armstrong.cc"

RUN echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
    && echo '@edgecommunity http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories

RUN apk --no-cache add --upgrade apk-tools@edge; \
    # Install openrc
    apk --no-cache add openrc syslog-ng \
    # can't get ttys unless you run the container in privileged mode
    && sed -i '/tty/d' /etc/inittab \
    && sed -i \
        # Tell openrc its running inside a container
        -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
        # Tell openrc loopback and net are already there, since docker handles the networking
        -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
        # Allow all variables through
        -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
        # Start crashed services
        -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
        -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
        /etc/rc.conf \
    # can't set hostname since docker sets it
    && sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname \
    # can't mount tmpfs since not privileged
    && sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh \
    # can't do cgroups
    #&& sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh \
    && sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh \
    # Remove unnecessary services
    && rm -f /etc/init.d/hwdrivers \
            /etc/init.d/hwclock \
            /etc/init.d/hwdrivers \
            /etc/init.d/modules \
            /etc/init.d/modules-load \
            /etc/init.d/modloop

ADD syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
RUN rc-update add syslog-ng

CMD ["/sbin/init"]
