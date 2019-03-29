FROM centos:latest as base

COPY scripts /opt/scripts

RUN yum -y update \
  && yum -y install mc java psmisc zip unzip iproute libgcc libgcc.i686 libX11 libX11.i686 libXext.i686 libXft.i686 gtk2.i686 libXtst.i686 zlib zlib.i686 compat-libstdc++-33-3.2.3-72.el7.i686 \
  && yum clean all \
  && rm -rfv /var/cache/yum \
  && chmod -R +x /opt/scripts

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
VOLUME ["/opt/IBM"]

RUN tar -C /was/was -xvzf /was/was/C1FZ9ML_WAS_7.0_Linux_86_64_MultLang.tar.gz
RUN /was/was/WAS/install -options /was/was/response.txt -silent -is:javaconsole || true
#RUN tar -C /was/upd -xvzf /was/upd/7.0.0.45-WS-UPDI-LinuxAMD64.tar.gz
#RUN /was/upd/UpdateInstaller/install -options /was/upd/response.txt -silent -is:javaconsole
#RUN tar -C /opt/IBM/UpdateInstaller/maintenance -xvzf /was/packs/packs.tar.gz
#RUN /opt/IBM/UpdateInstaller/update.sh -options /was/upd/install.txt -silent
#RUN tar -C /was/wp/portal -xvf /was/wp/portal/portal.tar
#RUN /was/wp/portal/IL-Setup/install.sh -options /was/wp/portal/response.txt
#RUN cat /tmp/wpinstalllog.txt
#RUN unzip /was/wp/updportal/6.1-WP-UpdateInstaller-Universal.zip -d /was/wp/updportal/
#RUN unzip /was/wp/Poratl_FIXPACK/6.1.0-WP-Multi-FP006.zip -d /was/wp/Poratl_FIXPACK/
#RUN chmod +x /was/wp/updportal/updatePortal.sh
#RUN sed -i -f /was/wp/updportal/sed_commands /opt/IBM/WebSphere/wp_profile/ConfigEngine/properties/wkplc.properties
#RUN while killall java; do sleep 5; done
#RUN /was/wp/updportal/updatePortal.sh -fixpack -install -installDir /opt/IBM/WebSphere/PortalServer/ -fixpackDir /was/wp/Poratl_FIXPACK/ -fixpackID WP_PTF_6106
RUN tar -C /opt -cvzf /opt/IBM.tgz IBM

FROM base

COPY --from=builder /was /was
COPY --from=builder /opt/IBM.tgz /opt/IBM.tgz


CMD ["/bin/bash"]
