FROM centos:latest
MAINTAINER Tomohiro Iizuka

RUN yum update -y

RUN yum install -y openssh-server
RUN mkdir -p /var/run/sshd

RUN sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i '/pam_loginuid\.so/s/required/optional/' /etc/pam.d/sshd

RUN ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ""
RUN ssh-keygen -t dsa -b 1024 -f /etc/ssh/ssh_host_dsa_key -N ""
RUN ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -t ecdsa -N ""

# install git
RUN yum install -y git

RUN mkdir /opt/repo.git && \
  cd /opt/repo.git && \
  git --bare init --share && \
  mkdir /opt/work && \
  cd /opt/work && \
  git init && \
  echo "git example" > version && \
  git add . && \
  git config --global user.email "you@example.com" && \
  git commit -m "init" && \
  git remote add origin /opt/repo.git && \
  git push origin master


# Runtime script
ADD script/run.sh /bin/run.sh
RUN chmod +x /bin/run.sh

RUN echo 'root:pass' | chpasswd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]


