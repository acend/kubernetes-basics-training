---
title: "9.3 CronJobs and Jobs"
weight: 93
sectionnumber: 9.3
onlyWhenNot: techlab,sbb
---

Jobs are different from normal Deployments: Jobs execute a time-constrained operation and report the result as soon as they are finished; think of a batch job. To achieve this, a Job creates a Pod and runs a defined command. A Job isn't limited to creating a single Pod, it can also create multiple Pods. When a Job is deleted, the Pods started (and stopped) by the Job are also deleted.

For example, a Job is used to ensure that a Pod is run until its completion. If a Pod fails, for example because of a Node error, the Job starts a new one. A Job can also be used to start multiple Pods in parallel.

{{% onlyWhenNot openshift %}}
More detailed information can be retrieved from the [Kubernetes documentation](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/).
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
More detailed information can be retrieved from the [OpenShift documentation](https://docs.openshift.com/container-platform/latest/nodes/jobs/nodes-nodes-jobs.html).
{{% /onlyWhen %}}

{{% alert title="Note" color="info" %}}
This lab depends on [lab 7](../../07/) or [lab 8](../../08/).
{{% /alert %}}


## Task {{% param sectionnumber %}}.1: Create a Job for a database dump

Similar to [task 7.4](../../07.0/#task-74-import-a-database-dump), we now want to create a dump of the running database, but without the need of interactively logging into the Pod.

Let's first look at the Job resource that we want to create.

{{% onlyWhenNot customer %}}
{{< readfile file="/content/en/docs/09/03/job-mariadb-dump.yaml" code="true" lang="yaml" >}}
{{% /onlyWhenNot %}}

{{% onlyWhen mobi %}}
{{< readfile file="/content/en/docs/09/03/job-mariadb-dump-mobi.yaml" code="true" lang="yaml" >}}
{{% /onlyWhen %}}


The parameter `.spec.template.spec.containers[0].image` shows that we use the same image as the running database. In contrast to the database Pod, we don't start a database afterwards, but run a `mysqldump` command, specified with `.spec.template.spec.containers[0].command`. To perform the dump, we use the environment variables of the database deployment to set the hostname, user and password parameters of the `mysqldump` command. The `MYSQL_PASSWORD` variable refers to the value of the secret, which is already used for the database Pod. This way we ensure that the dump is performed with the same credentials.

Let's create our Job: Create a file named `job_database-dump.yaml` with the content above and execute the following command:

```bash
{{% param cliToolName %}} apply -f ./job_database-dump.yaml --namespace <namespace>
```

Check if the Job was successful:

```bash
{{% param cliToolName %}} describe jobs/database-dump --namespace <namespace>
```

The executed Pod can be shown as follows:

```bash
{{% param cliToolName %}} get pods --namespace <namespace>
```

To show all Pods belonging to a Job in a human-readable format, the following command can be used:

```bash
{{% param cliToolName %}} get pods --selector=job-name=database-dump --output=go-template='{{range .items}}{{.metadata.name}}{{end}}' --namespace <namespace>
```


## CronJobs

A CronJob is nothing else than a resource which creates a Job at a defined time, which in turn starts (as we saw in the previous section) a Pod to run a command. Typical use cases are cleanup Jobs, which tidy up old data for a running Pod, or a Job to regularly create and save a database dump as we just did during this lab.

The CronJob's definition will remind you of the Deployment's structure, or really any other control resource. There's most importantly the `schedule` specification in [cron schedule format](https://crontab.guru/), some more things you could define and then the Job's definition itself that is going to be created by the CronJob:

{{< readfile file="/content/en/docs/09/03/cronjob-mariadb-dump.yaml" code="true" lang="yaml" >}}

{{% onlyWhenNot openshift %}}
Further information can be found in the [Kubernetes CronJob documentation](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Further information can be found in the [OpenShift CronJob documentation](https://docs.openshift.com/container-platform/latest/nodes/jobs/nodes-nodes-jobs.html).
{{% /onlyWhen %}}
