# Extended Universal Developer Image (UDI) for OpenShift DevSpaces

## Extending UDI
 
The [`Containerfile`](./Containerfile) included in this repo demostrates how to extend the official UDI image with extra tooling for Red Hat OpenShift DevSpaces.

## Building the Image

Build the image and push it to Quay.io:

```
podman build -t devspaces-extended-udi .
podman tag devspaces-extended-udi quay.io/jnyilimbibi/devspaces-extended-udi:3.12
podman push quay.io/jnyilimbibi/devspaces-extended-udi:3.12
```

## Using the New Image

To use this new UDI image in your own workspaces, specify the image location as the `image` in the `tools` component of your **Devfile**.

```
schemaVersion: 2.2.2
metadata:
  name: demo-project
components:
  - name: tools
    container:
      image: quay.io/jnyilimbibi/devspaces-extended-udi:3.12
      env:
        - name: MAVEN_URL
          value: https://repo.maven.apache.org/maven2/
      memoryRequest: 1Gi
      memoryLimit: 3Gi
      cpuLimit: 1000m
      cpuRequest: 500m
```

When your workspace starts up, it will be using your extended UDI image.
