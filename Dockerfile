FROM centos:latest as base

COPY scripts /opt/scripts

RUN yum -y update \
  && yum -y install mc java iproute libgcc libgcc.i686 libX11 libX11.i686 libXext.i686 libXft.i686 gtk2.i686 libXtst.i686 zlib zlib.i686 \
  && yum clean all \
  && rm -rfv /var/cache/yum \
  && chmod -R +x /opt/scripts

FROM base as builder

ADD was /was

RUN tar -C /was/was -xvzf /was/was/C1FZ9ML_WAS_7.0_Linux_86_64_MultLang.tar.gz \
  && tar -C /was/upd -xvzf /was/upd/7.0.0.45-WS-UPDI-LinuxAMD64.tar.gz \
  && /was/was/WAS/install -options /was/was/response.txt -silent -is:javaconsole || true \
  && /was/upd/UpdateInstaller/install -options /was/upd/response.txt -silent -is:javaconsole \
  && tar -C /opt/IBM/UpdateInstaller/maintenance -xvzf /was/packs/packs.tar.gz \
  && /opt/IBM/UpdateInstaller/update.sh -options /was/upd/install.txt -silent \
  && tar -C /opt -cvzf /opt/IBM.tgz IBM

FROM base

COPY --from=builder /was /was
COPY --from=builder /opt/IBM.tgz /opt/IBM.tgz

VOLUME ["/opt/IBM"]

RUN tar -C /opt -xvzf /opt/IBM.tgz

CMD ["/bin/bash"]
