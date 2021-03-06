FROM solita/centos-systemd:latest
MAINTAINER "Adam Belebczuk" <Adam@BelebczukConsulting.com>

LABEL Description="This image is based on Solita's Centos7 w/ systemd image, and runs R Studio Server Pro 0.99 over port 8787. To run the container, use the run command: docker run --name rstudio-server -t -d --security-opt seccomp=unconfined --stop-signal=SIGRTMIN+3 --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 8787:8787 sqldiablo/rstudio-server:0.99 To get to a shell prompt once the container is running, use the following command: docker exec -u 0 -it rstudio-server bash "
LABEL Product="R Studio Server Pro" Version="1.0.44"

# Install some prerequisites
RUN yum install --nogpgcheck -y epel-release deltarpm

# Make sure we're updated
RUN yum update -y

# Install some more prerequisites
RUN yum install --nogpgcheck -y R wget sudo nano mlocate openssl

# Fix for rserver-studio-pro expecting an ancient version of OpenSSL libraries
RUN ln -s /usr/lib64/libssl.so.10 /usr/lib64/libssl.so.6
RUN ln -s /usr/lib64/libcrypto.so.10 /usr/lib64/libcrypto.so.6

# Actually install rstudio-server-pro
RUN yum install --nogpgcheck -y https://download2.rstudio.org/rstudio-server-rhel-pro-1.0.44-x86_64.rpm

# Some cleanup
RUN yum clean all

# Remove the broken service that the rstudio-server-pro installer created and create one that works
RUN chkconfig rstudio-server --del
RUN systemctl enable /usr/lib/rstudio-server/extras/systemd/rstudio-server.service

# Port mapping
EXPOSE 8787

# I'll be nice and let you use locate to find stuff
RUN updatedb

# Add some groups and an admin user
RUN groupadd rstudio-admins; groupadd rstudio-superuser-admins; adduser admin -p x2bu1rgmI2oIA; usermod -a -G rstudio-admins admin; usermod -a -G rstudio-superuser-admins admin; printf '%s\nadmin-enabled=1%s\nadmin-group=rstudio-admins%s\nadmin-superuser-group=rstudio-superuser-admins%s\n' >> /etc/rstudio/rserver.conf

# Service setup on boot
CMD ["/usr/sbin/init"]
