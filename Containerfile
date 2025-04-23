FROM registry.redhat.io/devspaces/udi-rhel9:3.20

USER 0

# Copy CamelJBang.java to the container
COPY CamelJBang.java /home/user/

RUN for f in "/home/user" "/projects"; do \
      chgrp -R 0 ${f} && \
      chmod -R g=u ${f}; \
    done

WORKDIR /projects
CMD tail -f /dev/null