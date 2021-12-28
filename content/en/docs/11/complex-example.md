---
title: "11.4 Complex Example"
weight: 114
sectionnumber: 11.4
---

In this extended lab, we are going to deploy an existing, more complex application with a Helm chart from the Artifact Hub.


## Artifact Hub

Check out [Artifact Hub](https://artifacthub.io/) where you'll find a huge number of different Helm charts. For this lab, we'll use the [WordPress chart by Bitnami](https://artifacthub.io/packages/helm/bitnami/wordpress), a publishing platform for building blogs and websites.


## WordPress

As this WordPress Helm chart is published in Bitnami's Helm repository, we're first going to add it to our local repo list:

{{% onlyWhen mobi %}}
You have to set your `HTTP_PROXY` environment variable in order to access the bitnami helm repository:

```bash
# Linux
export HTTP_PROXY="http://<username>:<password>@PROXYANDPORT"
export HTTPS_PROXY="http://<username>:<password>@PROXYANDPORT"

# Windows cmd
setx HTTP_PROXY="http://<username>:<password>@PROXYANDPORT"
setx HTTPS_PROXY="http://<username>:<password>@PROXYANDPORT"
setx http_proxy="http://<username>:<password>@PROXYANDPORT"
setx https_proxy="http://<username>:<password>@PROXYANDPORT"

# Windows Powershell
$env:HTTP_PROXY="http://<username>:<password>@PROXYANDPORT"
$env:HTTPS_PROXY="http://<username>:<password>@PROXYANDPORT"
$env:http_proxy="http://<username>:<password>@PROXYANDPORT"
$env:https_proxy="http://<username>:<password>@PROXYANDPORT"
```

Replace `<username>` and `<password>` with your account details. If you have special chars in your password, you have to escape them with hexadecimal value according to [this](https://en.wikipedia.org/wiki/Percent-encoding#Percent-encoding_reserved_characters).
{{% /onlyWhen %}}

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Let's check if that worked:

```bash
helm repo list
```

```
NAME    URL
bitnami https://charts.bitnami.com/bitnami
```

Now look at the available configuration for this Helm chart. Usually you can find it in the [`values.yaml`](https://github.com/bitnami/charts/blob/master/bitnami/wordpress/values.yaml) or in the chart's readme file. You can also check it on its [Artifact Hub page](https://artifacthub.io/packages/helm/bitnami/wordpress).

We are going to override some of the values. For that purpose, create a new `values.yaml` file locally on your workstation (e.g. `~/<workspace>/values.yaml`) with the following content:

```yaml
---
persistence:
  size: 1Gi
service:
  type: ClusterIP
updateStrategy:
  type: Recreate
{{% onlyWhen openshift %}}
podSecurityContext:
  enabled: false
containerSecurityContext:
  enabled: false
{{% /onlyWhen %}}
ingress:
  enabled: true
  hostname: wordpress-<namespace>.<appdomain>

mariadb:
  primary:
    persistence:
      size: 1Gi
{{% onlyWhen openshift %}}
    podSecurityContext:
      enabled: false
    containerSecurityContext:
      enabled: false
{{% /onlyWhen %}}
```

{{% alert title="Note" color="primary" %}}
Make sure to set the proper value as hostname. `<appdomain>` will be provided by the trainer.
{{% /alert %}}

{{% onlyWhen mobi %}}
Use `wordpress-<namespace>.kubedev.mobicorp.test` as your hostname. It might take some time until your ingress hostname is accessible, as the DNS name first has to be propagated correctly.
{{% /onlyWhen %}}

If you look inside the [Chart.yaml](https://github.com/bitnami/charts/blob/master/bitnami/wordpress/Chart.yaml) file of the WordPress chart, you'll see a dependency to the [MariaDB Helm chart](https://github.com/bitnami/charts/tree/master/bitnami/mariadb). All the MariaDB values are used by this dependent Helm chart and the chart is automatically deployed when installing WordPress.

{{% onlyWhen mobi %}}
The WordPress and MariaDB charts use the following container images (at the time of writing):

* `docker.io/bitnami/wordpress:5.4.0-debian-10-r6`
* `docker.io/bitnami/mariadb:10.3.22-debian-10-r60`

As we cannot access these images, we'll have to overwrite them. Add the following to your `values.yaml` file in order to do so:

```yaml
[...]
image:
  registry: REGISTRY
  repository: puzzle/helm-techlab/wordpress

mariadb:
  image:
    registry: REGISTRY
    repository: puzzle/helm-techlab/mariadb
[...]
```

You have to merge the `mariadb` part with the already defined `mariadb` part from the lab instructions above. Your final `values.yaml` should look like:

```yaml
---
image:
  registry: REGISTRY
  repository: puzzle/helm-techlab/wordpress

persistence:
  size: 1Gi
service:
  type: ClusterIP
updateStrategy:
  type: Recreate

ingress:
  enabled: true
  hostname: wordpress-<namespace>.kubedev.mobicorp.test

mariadb:
  image:
    registry: REGISTRY
    repository: puzzle/helm-techlab/mariadb
  primary:
    persistence:
      size: 1Gi
```

Make sure to replace `<namespace>`.

The image tag remains as already defined in the orginial [`values.yaml`](https://github.com/bitnami/charts/blob/master/bitnami/wordpress/values.yaml) file from the chart.

{{% /onlyWhen %}}

The `Chart.yaml` file allows us to define dependencies on other charts. In our Wordpress chart we use the `Chart.yaml` to add a `mariadb` to store the WordPress data in.

```yaml
dependencies:
  - condition: mariadb.enabled
    name: mariadb
    repository: https://charts.bitnami.com/bitnami
    version: 9.x.x
```

[Helm's best practices](https://helm.sh/docs/chart_best_practices/) suggest to use version ranges instead of a fixed version whenever possible.
The suggested default therefore is patch-level version match:

```
version: ~3.5.7
```

This is e.g. equivalent to `>= 3.5.7, < 3.6.0`
Check [this SemVer readme chapter](https://github.com/Masterminds/semver#checking-version-constraints) for more information on version ranges.

{{% alert title="Note" color="primary" %}}
For more details on how to manage **dependencies**, check out the [Helm Dependencies Documentation](https://helm.sh/docs/chart_best_practices/dependencies/).
{{% /alert %}}

Subcharts are an alternative way to define dependencies within a chart: A chart may contain another chart (inside of its `charts/` directory) upon which it depends. As a result, when installing the chart, it will install all of its dependencies from the `charts/` directory.

We are now going to deploy the application in a specific version (which is not the latest release on purpose). Also note that we define our custom `values.yaml` file with the `-f` parameter:

```bash
helm install wordpress bitnami/wordpress -f values.yaml --version 10.7.1 --namespace <namespace>
```

Look for the newly created resources with `helm ls` and `{{% param cliToolName %}} get deploy,pod,ingress,pvc`:

```bash
helm ls --namespace <namespace>
```

which gives you:

```bash
NAME      NAMESPACE       REVISION  UPDATED                                     STATUS    CHART             APP VERSION
wordpress <namespace>         1     2021-03-25 14:27:38.231722961 +0100 CET     deployed  wordpress-10.7.1  5.7.0
```

and

```bash
{{% param cliToolName %}} get deploy,pod,ingress,pvc --namespace <namespace>
```

which gives you:

```bash
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/wordpress   1/1     1            1           2m6s

NAME                             READY   STATUS    RESTARTS   AGE
pod/wordpress-6bf6df9c5d-w4fpx   1/1     Running   0          2m6s
pod/wordpress-mariadb-0          1/1     Running   0          2m6s

NAME                           HOSTS                                          ADDRESS       PORTS   AGE
ingress.extensions/wordpress   wordpress-<namespace>.<appdomain>              10.100.1.10   80      2m6s

NAME                                             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
persistentvolumeclaim/data-wordpress-mariadb-0   Bound    pvc-859fe3b4-b598-4f86-b7ed-a3a183f700fd   1Gi        RWO            cloudscale-volume-ssd   2m6s
persistentvolumeclaim/wordpress                  Bound    pvc-83ebf739-0b0e-45a2-936e-e925141a0d35   1Gi        RWO            cloudscale-volume-ssd   2m7s
```

In order to check the values used in a given release, execute:

```bash
helm get values wordpress --namespace <namespace>
```

which gives you:
{{% onlyWhen openshift %}}

```yaml
USER-SUPPLIED VALUES:
containerSecurityContext:
  enabled: false
ingress:
  enabled: true
  hostname: wordpress-<namespace>.<appdomain>
mariadb:
  primary:
    containerSecurityContext:
      enabled: false
    persistence:
      size: 1Gi
    podSecurityContext:
      enabled: false
persistence:
  size: 1Gi
podSecurityContext:
  enabled: false
service:
  type: ClusterIP
updateStrategy:
  type: Recreate
```

{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}

```yaml
USER-SUPPLIED VALUES:
ingress:
  enabled: true
  hostname: wordpress-<namespace>.<appdomain>
mariadb:
  primary:
    persistence:
      size: 1Gi
persistence:
  size: 1Gi
service:
  type: ClusterIP
updateStrategy:
  type: Recreate
```

{{% /onlyWhenNot %}}

As soon as all deployments are ready (meaning pods `wordpress` and `mariadb` are running) you can open the application with the URL from your Ingress resource defined in `values.yaml`.


## Upgrade

We are now going to upgrade the application to a newer Helm chart version. When we installed the Chart, a couple of secrets were needed during this process. In order to do the upgrade of the Chart now, we need to provide those secrets to the upgrade command, to be sure no sensitive data will be overwritten:

* wordpressPassword
* mariadb.auth.rootPassword
* mariadb.auth.password

{{% alert title="Note" color="primary" %}}
This is specific to the wordpress Bitami Chart, and might be different when installing other Charts.
{{% /alert %}}

Use the following commands to gather the secrets and store them in environment variables. Make sure to replace `<namespace>` with your current value.

```bash
export WORDPRESS_PASSWORD=$({{% param cliToolName %}} get secret wordpress -o jsonpath="{.data.wordpress-password}" --namespace <namespace> | base64 --decode)
```

```bash
export MARIADB_ROOT_PASSWORD=$({{% param cliToolName %}} get secret wordpress-mariadb -o jsonpath="{.data.mariadb-root-password}" --namespace <namespace> | base64 --decode)
```

```bash
export MARIADB_PASSWORD=$({{% param cliToolName %}} get secret wordpress-mariadb -o jsonpath="{.data.mariadb-password}" --namespace <namespace> | base64 --decode)
```

Then do the upgrade with the following command:

```bash
helm upgrade -f values.yaml --set wordpressPassword=$WORDPRESS_PASSWORD --set mariadb.auth.rootPassword=$MARIADB_ROOT_PASSWORD --set mariadb.auth.password=$MARIADB_PASSWORD --version 10.7.2 wordpress bitnami/wordpress --namespace <namespace>
```

And then observe the changes in your WordPress and MariaDB Apps


## Cleanup

```bash
helm uninstall wordpress --namespace <namespace>
```


## Additional Task

Study the Helm [best practices](https://helm.sh/docs/chart_best_practices/) as an optional and additional task.
