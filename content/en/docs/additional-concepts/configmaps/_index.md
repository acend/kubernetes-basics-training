---
title: "ConfigMaps"
weight: 94
---

Similar to environment variables, _ConfigMaps_ allow you to separate the configuration for an application from the image. Pods can access those variables at runtime which allows maximum portability for applications running in containers.
In this lab, you will learn how to create and use ConfigMaps.


## ConfigMap creation

A ConfigMap can be created using the `{{% param cliToolName %}} create configmap` command as follows:

```bash
{{% param cliToolName %}} create configmap <name> <data-source> --namespace <namespace>
```

Where the `<data-source>` can be a file, directory, or command line input.


## {{% task %}} Java properties as ConfigMap

A classic example for ConfigMaps are properties files of Java applications which can't be configured with environment variables.

First, create a file called `java.properties` with the following content:

{{< readfile file="/content/en/docs/additional-concepts/configmaps/java.properties" code="true" lang="yaml" >}}
Now you can create a ConfigMap based on that file:

```bash
{{% param cliToolName %}} create configmap javaconfiguration --from-file=./java.properties --namespace <namespace>
```

Verify that the ConfigMap was created successfully:

```bash
{{% param cliToolName %}} get configmaps --namespace <namespace>
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

{{< readfile file="/content/en/docs/additional-concepts/configmaps/javaconfig.yaml" code="true" lang="yaml" >}}


## {{% task %}} Attach the ConfigMap to a container

Next, we want to make a ConfigMap accessible for a container. There are basically the following possibilities to achieve {{% onlyWhenNot openshift %}}[this](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/){{% /onlyWhenNot %}}{{% onlyWhen openshift %}}[this](https://docs.openshift.com/container-platform/latest/applications/config-maps.html){{% /onlyWhen %}}:

* ConfigMap properties as environment variables in a Deployment
* Command line arguments via environment variables
* Mounted as volumes in the container

In this example, we want the file to be mounted as a volume inside the container.

{{% onlyWhen openshift %}}
As in {{<link "persistent-storage">}}, we can use the `oc set volume` command to achieve this:

{{% alert title="Note" color="info" %}}
If you are using Windows and your shell uses the POSIX-to-Windows path conversion, remember to prepend your command with `MSYS_NO_PATHCONV=1` if the resulting mount path was mistakenly converted.
{{% /alert %}}

```bash
oc set volume deploy/example-web-app --add --configmap-name=javaconfiguration --mount-path=/etc/config --name=config-volume --type configmap --namespace <namespace>
```

{{% alert title="Note" color="info" %}}
This task doesn't have any effect on the example application inside the container. It is for demonstration purposes only.
{{% /alert %}}

This results in the addition of the following parts to the Deployment (check with `oc get deploy example-web-app -o yaml`):

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
{{< readfile file="/content/en/docs/additional-concepts/configmaps/spring-boot-example.yaml" code="true" lang="yaml" >}}
{{% /onlyWhenNot %}}

This means that the container should now be able to access the ConfigMap's content in `/etc/config/java.properties`. Let's check:

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

{{% alert title="Note" color="info" %}}
On Windows, you can use Git Bash with `winpty kubectl exec -it <pod> --namespace <namespace> -- cat //etc/config/java.properties`.
{{% /alert %}}

{{< readfile file="/content/en/docs/additional-concepts/configmaps/java.properties" code="true" lang="yaml" >}}

Like this, the property file can be read and used by the application inside the container. The image stays portable to other environments.


## {{% task %}} ConfigMap environment variables

Use a ConfigMap by {{% onlyWhenNot openshift %}}[populating environment variables into the container](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#define-container-environment-variables-using-configmap-data){{% /onlyWhenNot %}}{{% onlyWhen openshift %}}[populating environment variables into the container](https://docs.openshift.com/container-platform/latest/applications/config-maps.html#nodes-pods-configmaps-use-case-consuming-in-env-vars_config-maps){{% /onlyWhen %}} instead of a file.
