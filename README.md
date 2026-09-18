# Extended Universal Developer Image (UDI) for OpenShift DevSpaces

This repository builds a custom Universal Developer Image for Red Hat OpenShift DevSpaces, based on the official UDI and extended for Apache Camel and Quarkus workspaces.

## What this image provides

- Base image: [`registry.redhat.io/devspaces/udi-rhel9:3.30`](https://catalog.redhat.com/software/containers/devspaces/udi-rhel9)
- [JBang](https://www.jbang.dev/) `0.141.0`
- [`CamelJBang.java`](./CamelJBang.java) in `/home/tooling` (Camel JBang `4.18.3`, kamelets `4.18.0`)
- Default workspace JDK **Java 21** via `USE_JAVA21=true` (UDI default is Java 17)
- Devfile `postStart` events that install the Camel CLI and the Camel Kubernetes plugin
- Recommended VS Code extensions from [`.vscode/extensions.json`](./.vscode/extensions.json):
  - `redhat.vscode-quarkus`
  - `redhat.apache-camel-extension-pack`

The [`Containerfile`](./Containerfile) installs JBang and copies `CamelJBang.java` into the image. Workspace env vars, resource limits, and Camel CLI setup live in [`devfile.yaml`](./devfile.yaml).

## Building the Image

Log in to `registry.redhat.io` if needed to pull the base UDI, then build and push to Quay.io (or your registry):

> **NOTE**: Use the appropriate image repository namespace according to your quay environment.

```
podman build -t quay.io/jnyilimbibi/devspaces-extended-udi:3.30 .
podman push quay.io/jnyilimbibi/devspaces-extended-udi:3.30
```

## Using the Image

To use this UDI in your own workspaces, set the `image` on the `tools` component of your **Devfile** (this matches [`devfile.yaml`](./devfile.yaml)):

```yaml
schemaVersion: 2.3.0
metadata:
  name: openshift-devspaces-extended-udi
  displayName: Extended UDI for OpenShift DevSpaces
  description: Custom Universal Developer Image with JBang, Apache Camel CLI, and Java 21 for OpenShift DevSpaces workspaces.
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
      cpuRequest: 100m
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

When your workspace starts up, it will use the extended UDI image, Java 21, and the Camel CLI installed by the `postStart` commands.
