# Extended Universal Developer Image (UDI) for OpenShift DevSpaces

## Extending UDI
 
The [`Containerfile`](./Containerfile) included in this repo demostrates how to extend the official UDI image with extra tooling for Red Hat OpenShift DevSpaces.

## Building the Image

Build the image and push it to Quay.io for instance:
> **NOTE**: Use the appropriate image repository namespace according to your quay environment.

```
podman build -t quay.io/jnyilimbibi/devspaces-extended-udi:3.14 .
podman push quay.io/jnyilimbibi/devspaces-extended-udi:3.14
```

## Using the New Image

To use this new UDI image in your own workspaces, specify the image location as the `image` in the `tools` component of your **Devfile**.

```yaml
schemaVersion: 2.2.2
metadata:
  name: openshift-devspaces-extended-udi
components:
  - name: tools
    container:
      image: quay.io/jnyilimbibi/devspaces-extended-udi:3.14
      memoryRequest: 2Gi
      memoryLimit: 6Gi
      cpuLimit: 4000m
      cpuRequest: 1000m
commands:
  - id: install-camel-cli
    exec:
      label: "Install Apache Camel JBang"
      component: tools
      workingDir: ${PROJECT_SOURCE}
      commandLine: "jbang trust add -o https://github.com/apache && jbang app install --verbose --name=camel /home/user/CamelJBang.java"
events:
  postStart:
    - install-camel-cli
```

When your workspace starts up, it will be using your extended UDI image.
