---
title: "9.4 ConfigMap"
weight: 94
sectionnumber: 9.4
---

Similar to environment variables, _ConfigsMaps_ allow you to separate the configuration for an application from the image. Pods can access those variables at runtime which allows maximum portability for applications running in containers.
In this lab, you will learn how to create and use ConfigMaps.


## ConfigMap creation

A ConfigMap can be created using the `{{% param cliToolName %}} create configmap` command as follows:

```bash
{{% param cliToolName %}} create configmap <name> <data-source> --namespace <namespace>
```

Where the `<data-source>` can be a file, directory, or command line input.


## Task {{% param sectionnumber %}}.1: Java properties as ConfigMap

A classic example for ConfigMaps are properties files of Java applications which can't be configured with environment variables.

First, create a file called `java.properties` with the following content:

{{< highlight text >}}{{< readfile file="content/en/docs/09/04/java.properties" >}}{{< /highlight >}}
Now you can create a ConfigMap based on that file:

```bash
{{% param cliToolName %}} create configmap javaconfiguration --from-file=./java.properties --namespace <namespace>
```

Verify that the the ConfigMap was created successfully:

```bash
oc get configmaps --namespace <namespace>
```

```
NAME                DATA   AGE
javaconfiguration   1      7s
```

Have a look at its content:

```bash
{{% param cliToolName %}} get configmap javaconfiguration -o yaml --namespace <namespace>
```

Which should yield output similar to this one:

{{< highlight yaml >}}{{< readfile file="content/en/docs/09/04/javaconfig.yaml" >}}{{< /highlight >}}


## Taks {{% param sectionnumber %}}.2: Attach the ConfigMap to a Container

Next, we want to make a ConfigMap accessible for a Container. There are basically the following possibilities to achieve {{% onlyWhenNot openshift %}}[this](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/){{% /onlyWhenNot %}}{{% onlyWhen openshift %}}[this](https://docs.openshift.com/container-platform/latest/builds/builds-configmaps.html#builds-configmaps-consuming-configmap-in-pods){{% /onlyWhen %}}

* ConfigMap properties as environment variables in a Deployment
* Command line arguments via environment variables
* Mounted as volumes in the container

In this example, we want the file to be mounted as a volume inside the Container.
{{% onlyWhen openshift %}}
As in [lab 8](../08/), we can use the `oc set volume` command to achieve this:
{{% /onlyWhen %}}
{{% onlyWhen openshift %}}
```bash
oc set volume deploy/example-web-python --add --configmap-name=javaconfiguration --mount-path=/etc/config --name=config-volume --type configmap --namespace <namespace>
```
{{% /onlyWhen %}}
{{% onlyWhen openshift %}}
{{% alert title="Note" color="primary" %}}
This task doesn't have any effect on the Python application inside the Container. It is for demonstration purposes only.
{{% /alert %}}
{{% /onlyWhen %}}
{{% onlyWhen openshift %}}

This results in the addition of the following parts to the Deployment (check with `oc get deploy awesome-app -o yaml`):

{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
Basically, a Deployment has to be extended with the following config:
{{% /onlyWhenNot %}}

```yaml
      ...
        volumeMounts:
        - mountPath: /etc/config
          name: config-volume
      ...
      volumes:
      - configMap:
          defaultMode: 420
          name: javaconfiguration
        name: config-volume
      ...
```
{{% onlyWhenNot openshift %}}
Here is a complete example Deployment of a sample Java app:

{{% onlyWhenNot mobi %}}
{{< highlight yaml >}}{{< readfile file="content/en/docs/09/04/spring-boot-example.yaml" >}}{{< /highlight >}}
{{% /onlyWhenNot %}}

{{% onlyWhen mobi %}}
{{< highlight yaml >}}{{< readfile file="content/en/docs/09/04/spring-boot-example-mobi.yaml" >}}{{< /highlight >}}
{{% /onlyWhen %}}
{{% /onlyWhenNot %}}


This means that the Container should now be able to access the ConfigMap's content in `/etc/config/java.properties`. Let's check:


{{% onlyWhen openshift %}}
```bash
oc exec <pod name> --namespace <namespace> -- cat /etc/config/java.properties
```
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
```bash
kubectl exec -it <pod> --namespace <namespace> -- cat /etc/config/java.properties
```
{{% /onlyWhenNot %}}


{{< highlight text >}}{{< readfile file="content/en/docs/09/04/java.properties" >}}{{< /highlight >}}

Like this, the property file can be read and used by the application inside the Container. The image stays portable to other environments.


## Task {{% param sectionnumber %}}.3: ConfigMap Data Sources

Create a ConfigMap and use the other kinds of {{% onlyWhenNot openshift %}}[data sources](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/){{% /onlyWhenNot %}}{{% onlyWhen openshift %}}[data sources](https://docs.openshift.com/container-platform/latest/builds/builds-configmaps.html#builds-configmap-create_builds-configmaps){{% /onlyWhen %}}
