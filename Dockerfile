FROM centos:latest as base

COPY scripts /opt/scripts

RUN yum -y update \
  && yum -y install mc java psmisc python-setuptools zip unzip iproute libgcc libgcc.i686 libX11 libX11.i686 libXext.i686 libXft.i686 gtk2.i686 libXtst.i686 zlib zlib.i686 compat-libstdc++-33-3.2.3-72.el7.i686 \
  && easy_install supervisor \
  && ln -s /opt/scripts/supervisord.conf /etc/supervisord.conf \
  && chmod +x /opt/scripts/start_wrapper.sh \
  && yum clean all \
  && rm -rfv /var/cache/yum

FROM base as builder

ADD was /was

VOLUME ["/opt/IBM"]

ARG WAS_HOME=/opt/IBM/WebSphere/AppServer/

RUN  tar -C /was/was -xvzf /was/was/C1FZ9ML_WAS_7.0_Linux_86_64_MultLang.tar.gz \
  && /was/was/WAS/install -options /was/was/response.txt -silent -is:javaconsole || true \
  && tar -C /was/upd -xvzf /was/upd/7.0.0.45-WS-UPDI-LinuxAMD64.tar.gz \
  && /was/upd/UpdateInstaller/install -options /was/upd/response.txt -silent -is:javaconsole \
  && tar -C /opt/IBM/UpdateInstaller/maintenance -xvzf /was/packs/packs.tar.gz \
  && /opt/IBM/UpdateInstaller/update.sh -options /was/upd/install.txt -silent \
  && tar -C /was/wp/portal -xvf /was/wp/portal/portal.tar \
  && sed 's/127.*/127.0.0.1 localhost was-v7.myhost.lan/w /root/hosts' /etc/hosts \
  && cp -f /root/hosts /etc/hosts \
  && cat /etc/hosts \
  && /was/wp/portal/IL-Setup/install.sh -options /was/wp/portal/response.txt\
  && cat /tmp/wpinstalllog.txt \
  && unzip /was/wp/updportal/6.1-WP-UpdateInstaller-Universal.zip -d /was/wp/updportal/ \
  && unzip /was/wp/Portal_FIXPACK/6.1.0-WP-Multi-FP006.zip -d /was/wp/Portal_FIXPACK/ \
  && chmod +x /was/wp/updportal/updatePortal.sh \
  && sed -i -f /was/wp/updportal/sed_commands /opt/IBM/WebSphere/wp_profile/ConfigEngine/properties/wkplc.properties \
  && cat /opt/IBM/WebSphere/wp_profile/ConfigEngine/properties/wkplc.properties \
  && while killall java; do sleep 5; done \
  && /was/wp/updportal/updatePortal.sh -fixpack -install -installDir /opt/IBM/WebSphere/PortalServer/ -fixpackDir /was/wp/Portal_FIXPACK/ -fixpackID WP_PTF_6106 \
  && while killall java; do sleep 5; done \
  && rm -rfv /opt/IBM/UpdateInstaller/maintenance/* \
  && tar -C /opt -cvzf /opt/IBM.tgz IBM

FROM base

COPY --from=builder /opt/IBM.tgz /opt/IBM.tgz

CMD ["/opt/scripts/start_wrapper.sh"]
