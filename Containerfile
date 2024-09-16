FROM registry.redhat.io/devspaces/udi-rhel8:3.14

ENV KAMEL_VERSION=1.10.6
ENV JBANG_VERSION=0.118.0

USER 0

# Install Kamel
RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/camel-k/${KAMEL_VERSION}/camel-k-client-${KAMEL_VERSION}-linux-64bit.tar.gz \
    -O - | tar -xz -C /usr/local/bin/

# Install JBang
RUN wget https://github.com/jbangdev/jbang/releases/download/v${JBANG_VERSION}/jbang.tar \
    -O - | tar -x --strip 2 -C /usr/local/bin jbang/bin/jbang && jbang version

# Copy custom maven settings.xml file to the container
COPY CamelJBang.java /home/user/

RUN for f in "/home/user" "/projects"; do \
      chgrp -R 0 ${f} && \
      chmod -R g=u ${f}; \
    done

WORKDIR /projects
CMD tail -f /dev/null