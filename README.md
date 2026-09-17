# Extended Universal Developer Image (UDI) for OpenShift DevSpaces

## Extending UDI
 
The [`Containerfile`](./Containerfile) included in this repo demostrates how to extend the official UDI image with extra tooling for Red Hat OpenShift DevSpaces.

## Building the Image

Build the image and push it to Quay.io for instance:
> **NOTE**: Use the appropriate image repository namespace according to your quay environment.

```
podman build -t quay.io/jnyilimbibi/devspaces-extended-udi:3.30 .
podman push quay.io/jnyilimbibi/devspaces-extended-udi:3.30
```

## Using the New Image

To use this new UDI image in your own workspaces, specify the image location as the `image` in the `tools` component of your **Devfile**.

```yaml
schemaVersion: 2.2.2
metadata:
  name: openshift-devspaces-extended-udi
attributes:
  .vscode/extensions.json: |
    {
      "recommendations": [
        "redhat.vscode-quarkus",
        "redhat.apache-camel-extension-pack"
      ]
    }
components:
  - name: tools
    container:
      image: quay.io/jnyilimbibi/devspaces-extended-udi:3.30
      env:
        # For Jbang to use system built-in proxy settings
        # Reference: https://www.jbang.dev/documentation/guide/latest/configuration.html#proxy-configuration
        - name: JAVA_TOOL_OPTIONS
          value: "-Djava.net.useSystemProxies=true"
        # UDI entrypoint selects the default JDK via env vars (first match wins):
        #   USE_JAVA8=true  -> Java 8
        #   USE_JAVA11=true -> Java 11
        #   USE_JAVA21=true -> Java 21
        #   (none set)      -> Java 17 (default)
        - name: USE_JAVA21
          value: "true"
      memoryRequest: 8Gi
      memoryLimit: 8Gi
      cpuLimit: 4000m
      cpuRequest: 500m
commands:
  - id: install-camel-cli
    exec:
      label: "Install Apache Camel JBang"
      component: tools
      workingDir: ${PROJECT_SOURCE}
      commandLine: "jbang trust add -o https://github.com/apache && jbang app install --verbose --name=camel /home/tooling/CamelJBang.java"
  - id: install-camel-k8s-plugin
    exec:
      label: "Install Camel Kubernetes Plugin"
      component: tools
      workingDir: ${PROJECT_SOURCE}
      commandLine: "source ~/.bashrc && camel plugin add kubernetes"
events:
  postStart:
    - install-camel-cli
    - install-camel-k8s-plugin
```

When your workspace starts up, it will be using your extended UDI image.
