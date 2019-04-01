FROM centos:latest as base

COPY scripts /opt/scripts

RUN yum -y update \
  && yum -y install mc java psmisc zip unzip iproute libgcc libgcc.i686 libX11 libX11.i686 libXext.i686 libXft.i686 gtk2.i686 libXtst.i686 zlib zlib.i686 compat-libstdc++-33-3.2.3-72.el7.i686 \
  && yum clean all \
  && rm -rfv /var/cache/yum \
  && chmod -R +x /opt/scripts

VOLUME ["/opt/IBM"]

FROM base as builder

ADD was /was

#RUN tar -C /was/was -xvzf /was/was/C1FZ9ML_WAS_7.0_Linux_86_64_MultLang.tar.gz \
#  && tar -C /was/upd -xvzf /was/upd/7.0.0.45-WS-UPDI-LinuxAMD64.tar.gz \
#  && /was/was/WAS/install -options /was/was/response.txt -silent -is:javaconsole || true \
#  && /was/upd/UpdateInstaller/install -options /was/upd/response.txt -silent -is:javaconsole \
#  && tar -C /opt/IBM/UpdateInstaller/maintenance -xvzf /was/packs/packs.tar.gz \
#  && /opt/IBM/UpdateInstaller/update.sh -options /was/upd/install.txt -silent \
#  && tar -C /opt -cvzf /opt/IBM.tgz IBM

ARG WAS_HOME=/opt/IBM/WebSphere/AppServer/

RUN echo 111 \
  && tar -C /was/was -xvzf /was/was/C1FZ9ML_WAS_7.0_Linux_86_64_MultLang.tar.gz \
  && echo 222222 \
  && /was/was/WAS/install -options /was/was/response.txt -silent -is:javaconsole || true \
  && echo 3333333 \
  && tar -C /was/upd -xvzf /was/upd/7.0.0.45-WS-UPDI-LinuxAMD64.tar.gz \
  && echo 44444444 \
  && /was/upd/UpdateInstaller/install -options /was/upd/response.txt -silent -is:javaconsole \
  && echo 555555 \
  && tar -C /opt/IBM/UpdateInstaller/maintenance -xvzf /was/packs/packs.tar.gz \
  && echo 666666 \
  && /opt/IBM/UpdateInstaller/update.sh -options /was/upd/install.txt -silent \
  && echo 7777777 \
  && tar -C /was/wp/portal -xvf /was/wp/portal/portal.tar \
  && echo 888888 \
  && sed 's/127.*/127.0.0.1 localhost was-v7.myhost.lan/w /root/hosts' /etc/hosts \
  && echo 9999 \
  && cp -f /root/hosts /etc/hosts \
  && echo 9191919191919 \
  && cat /etc/hosts \
  && echo 9292929292929 \
  && /was/wp/portal/IL-Setup/install.sh -options /was/wp/portal/response.txt\
  && echo 10101010ten \
  && cat /tmp/wpinstalllog.txt \
  && echo 111111eleven \
  && unzip /was/wp/updportal/6.1-WP-UpdateInstaller-Universal.zip -d /was/wp/updportal/ \
  && echo 1212121212twelve \
  && unzip /was/wp/Portal_FIXPACK/6.1.0-WP-Multi-FP006.zip -d /was/wp/Portal_FIXPACK/ \
  && echo 13131313thirtin \
  && chmod +x /was/wp/updportal/updatePortal.sh \
  && echo 1414141414fourteen \
  && sed -i -f /was/wp/updportal/sed_commands /opt/IBM/WebSphere/wp_profile/ConfigEngine/properties/wkplc.properties \
  && echo 1515151515fivteen \
  && cat /opt/IBM/WebSphere/wp_profile/ConfigEngine/properties/wkplc.properties \
  && echo 16161616sixteen \
  && while killall java; do sleep 5; done \
  && echo 1717171717seventeen \
  && /was/wp/updportal/updatePortal.sh -fixpack -install -installDir /opt/IBM/WebSphere/PortalServer/ -fixpackDir /was/wp/Portal_FIXPACK/ -fixpackID WP_PTF_6106 \
  && eighteen \
  && tar -C /opt -cvzf /opt/IBM.tgz IBM

FROM base

#COPY --from=builder /was /was
COPY --from=builder /opt/IBM.tgz /opt/IBM.tgz

CMD ["/bin/bash"]
