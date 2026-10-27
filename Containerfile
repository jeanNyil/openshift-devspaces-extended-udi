FROM registry.redhat.io/devspaces/udi-rhel9:3.31

ENV JBANG_VERSION=0.142.0
ENV PATH="/home/tooling/.local/bin:${PATH}"

# Install JBang into a user-writable path (no USER 0 / capset needed).
RUN mkdir -p /home/tooling/.local/bin \
 && wget https://github.com/jbangdev/jbang/releases/download/v${JBANG_VERSION}/jbang.tar \
        -O - | tar -x --strip 2 -C /home/tooling/.local/bin jbang/bin/jbang \
 && jbang version

# Copy CamelJBang.java; --chown keeps OpenShift arbitrary-UID (10001:0) without chgrp.
COPY --chown=10001:0 CamelJBang.java /home/tooling/

CMD tail -f /dev/null
