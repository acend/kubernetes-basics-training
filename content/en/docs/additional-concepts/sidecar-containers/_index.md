---
title: "Sidecar containers"
weight: 97
onlyWhenNot: sbb
---

Let's first have another look at the Pod's description [on the Kubernetes documentation page](https://kubernetes.io/docs/concepts/workloads/pods/pod/):

> A Pod (as in a pod of whales or pea pod) is a group of one or more containers (such as Docker containers), with shared storage/network, and a specification for how to run the containers. A Pod’s contents are always co-located and co-scheduled, and run in a shared context. A Pod models an application-specific “logical host” - it contains one or more application containers which are relatively tightly coupled — in a pre-container world, being executed on the same physical or virtual machine would mean being executed on the same logical host.
> The shared context of a Pod is a set of Linux namespaces, cgroups, and potentially other facets of isolation - the same things that isolate a Docker container. Within a Pod’s context, the individual applications may have further sub-isolations applied.

A sidecar container is a utility container in the Pod. Its purpose is to support the main container. It is important to note that the standalone sidecar container does not serve any purpose, it must be paired with one or more main containers. Generally, sidecar containers are reusable and can be paired with numerous types of main containers.

In a sidecar pattern, the functionality of the main container is extended or enhanced by a sidecar container without strong coupling between the two. Although it is always possible to build sidecar container functionality into the main container, there are several benefits with this pattern:

* Different resource profiles, i.e. independent resource accounting and allocation
* Clear separation of concerns at packaging level, i.e. no strong coupling between containers
* Reusability, i.e., sidecar containers can be paired with numerous "main" containers
* Failure containment boundary, making it possible for the overall system to degrade gracefully
* Independent testing, packaging, upgrade, deployment and if necessary rollback


## {{% task %}} Add a Prometheus MySQL exporter as a sidecar

In {{<link "persistent-storage">}} you created a MariaDB deployment. In this task you are going to add the [Prometheus MySQL exporter](https://github.com/prometheus/mysqld_exporter) to it.

{{% onlyWhenNot openshift %}}
Change the existing `mariadb` Deployment by first editing your local `mariadb.yaml` file. Add a new (sidecar) container into your Deployment:

{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
{{% onlyWhenNot baloise %}}
Change the existing `mariadb` DeploymentConfig using:

```bash
oc edit dc mariadb --namespace <namespace>
```

{{% /onlyWhenNot %}}
{{% onlyWhen baloise %}}
Change the existing `mariadb` Deployment using:

```bash
oc edit deploy mariadb --namespace <namespace>
```

{{% /onlyWhen %}}
And add a new (sidecar) container to it:
{{% /onlyWhen %}}

{{% onlyWhenNot customer %}}
{{< readfile file="/content/en/docs/additional-concepts/sidecar-containers/deploy_mariadb-sidecar.yaml" code="true" lang="yaml" >}}
{{% /onlyWhenNot %}}
{{% onlyWhen baloise %}}
{{< readfile file="/content/en/docs/additional-concepts/sidecar-containers/deploy_mariadb-sidecar_baloise.yaml" code="true" lang="yaml" >}}
{{% /onlyWhen %}}
{{% onlyWhen mobi %}}
{{< readfile file="/content/en/docs/additional-concepts/sidecar-containers/deploy_mariadb-sidecar_mobi.yaml" code="true" lang="yaml" >}}
{{% /onlyWhen %}}

{{% onlyWhenNot openshift %}}
and then apply the change with:

```bash
{{% param cliToolName %}} apply -f mariadb.yaml --namespace <namespace>
```
{{% /onlyWhenNot %}}

Your Pod now has two running containers. Verify this with:

```bash
{{% param cliToolName %}} get pod --namespace <namespace>

The output should look similar to this:

```
NAME                       READY   STATUS    RESTARTS   AGE
mariadb-65559644c9-cdjjk   2/2     Running   0          5m35s
```

Note the `READY` column which shows you 2 ready containers.

You can get the logs from the mysqld-exporter with:

```bash
{{% param cliToolName %}} logs <pod> -c mysqld-exporter --namespace <namespace>
```

Which gives you an output similar to this:

```
time="2020-05-10T11:31:02Z" level=info msg="Starting mysqld_exporter (version=0.12.1, branch=HEAD, revision=48667bf7c3b438b5e93b259f3d17b70a7c9aff96)" source="mysqld_exporter.go:257"
time="2020-05-10T11:31:02Z" level=info msg="Build context (go=go1.12.7, user=root@0b3e56a7bc0a, date=20190729-12:35:58)" source="mysqld_exporter.go:258"
time="2020-05-10T11:31:02Z" level=info msg="Enabled scrapers:" source="mysqld_exporter.go:269"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.global_variables" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.slave_status" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.global_status" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.info_schema.query_response_time" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.info_schema.innodb_cmp" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.info_schema.innodb_cmpmem" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg="Listening on :9104" source="mysqld_exporter.go:283"
```

By using the `port-forward` subcommand, you can even have a look at the Prometheus metrics:

```bash
{{% param cliToolName %}} port-forward <pod> 9104 --namespace <namespace>
```

And then use `curl` to check the mysqld_exporter metrics with:

```bash
curl http://localhost:9104/metrics
```
