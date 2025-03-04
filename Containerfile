FROM registry.redhat.io/devspaces/udi-rhel9:3.18

ENV JBANG_VERSION=0.123.0

USER 0

# Install JBang
RUN wget https://github.com/jbangdev/jbang/releases/download/v${JBANG_VERSION}/jbang.tar \
    -O - | tar -x --strip 2 -C /usr/local/bin jbang/bin/jbang && jbang version

# Copy CamelJBang.java to the container
COPY CamelJBang.java /home/user/

RUN for f in "/home/user" "/projects"; do \
      chgrp -R 0 ${f} && \
      chmod -R g=u ${f}; \
    done

WORKDIR /projects
CMD tail -f /dev/null