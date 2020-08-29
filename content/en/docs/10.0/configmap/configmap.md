---
title: "10.4 ConfigMap"
weight: 104
sectionnumber: 10.4
---

Similar to environment variables, _ConfigsMaps_ allow you to separate the configuration for an application from the image. Pods can access those variables at runtime which allows maximum portability for applications running in containers.
In this lab, you learn how to create and use ConfigMaps.


## Creating ConfigMaps

Use the following command to create a ConfigMap:

```bash
kubectl create configmap <name> <data-source> --namespace <namespace>
```

The `<data-source>` can be a file, a directory, or a command line input.


## Task {{% param sectionnumber %}}.1: Create a ConfigMap from Java properties

A classic example for ConfigMaps are properties files of Java applications which can't be configured with environment variables.

You can create a ConfigMap based on a local file:

```bash
kubectl create configmap javaconfig --from-file=./java.properties --namespace <namespace>
```

The content of `java.properties` should be:

{{< highlight text >}}{{< readfile file="content/en/docs/10.0/configmap/java.properties" >}}{{< /highlight >}}

With

```bash
kubectl get configmaps --namespace <namespace>
```

you can verify, if the ConfigMap was created successfully:

```
NAME                DATA   AGE
javaconfig   1      7s
```

The content can also be displayed with

```bash
kubectl get configmap javaconfig -o yaml --namespace <namespace>
```

Which should yield output similar to this one:

{{< highlight yaml >}}{{< readfile file="content/en/docs/10.0/configmap/javaconfig.yaml" >}}{{< /highlight >}}


## Task {{% param sectionnumber %}}.2: Attach a ConfigMap to a Pod

Next, we want to make a ConfigMap accessible for a Pod.

Basically, there are the following possibilities to achieve [this](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)

* ConfigMap properties as environment variables in a deployment
* Commandline arguments via environment variables
* Mounted as volumes in the container

In this example, we want the file to be mounted as a volume in the container.
Basically, a Deployment has to be extended with the following config:

```yaml
...
        - mountPath: /etc/config
          name: config-volume
      ...
      - configMap:
          defaultMode: 420
          name: javaconfiguration
        name: config-volume
...
```

Here is a complete example Deployment of a sample Java app:

{{< onlyWhenNot mobi >}}
{{< highlight yaml >}}{{< readfile file="content/en/docs/10.0/configmap/spring-boot-example.yaml" >}}{{< /highlight >}}
{{< /onlyWhenNot >}}

{{< onlyWhen mobi >}}
{{< highlight yaml >}}{{< readfile file="content/en/docs/10.0/configmap/spring-boot-example-mobi.yaml" >}}{{< /highlight >}}
{{< /onlyWhen >}}

After that, it's possible for the container to access the values in the ConfigMap in `/etc/config/java.properties`

```bash
kubectl exec -it <pod> --namespace <namespace> -- cat /etc/config/java.properties
```

{{< highlight text >}}{{< readfile file="content/en/docs/10.0/configmap/java.properties" >}}{{< /highlight >}}

Like this, the property file can be read and used by the Java application in the container. The image stays portable to other environments.


## Task {{% param sectionnumber %}}.3: ConfigMap Data Sources

Create a ConfigMap and use the other kinds of [data sources](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
