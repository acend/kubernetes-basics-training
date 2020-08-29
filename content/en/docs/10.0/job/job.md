---
title: "10.3 Job"
weight: 103
sectionnumber: 10.3
---

Jobs are different from normal Deployments: Jobs execute a time-constrained operation and report the result as soon as they are finished; think of a batch job. To achieve this, a Job creates a Pod and runs a defined command. A Job isn't limited to create a single Pod, it can also create multiple Pods. When a Job is deleted, the Pods started (and stopped) by the Job are also deleted.

For example, a Job is used to ensure that a Pod is run until its completion. If a Pod fails, for example because of a Node error, the Job starts a new one. A Job can also be used to start multiple Pods in parallel.

More detailed information can be retrieved from [Kubernetes Jobs Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/).

{{% alert title="Note" color="primary" %}}
This lab depends on lab 8 or 9.
{{% /alert %}}


## Task {{% param sectionnumber %}}.1: Create a Job for a MySQL Dump

Similar to [task 8.4](../../../08.0/#task-84-import-a-database-dump), we now want to create a dump of a running MySQL database, but without the need of interactively logging into the Pod.

Let's first look at the Job resource that we want to create.

{{< onlyWhenNot mobi >}}
{{< highlight yaml >}}{{< readfile file="content/en/docs/10.0/job/job-mysql-dump.yaml" >}}{{< /highlight >}}
{{< /onlyWhenNot >}}

{{< onlyWhen mobi >}}
{{< highlight yaml >}}{{< readfile file="content/en/docs/10.0/job/job-mysql-dump-mobi.yaml" >}}{{< /highlight >}}
{{< /onlyWhen >}}

The parameter `.spec.template.spec.containers[0].image` shows that we use the same image as the running database. In contrast to the database Pod, we don't start a database afterwards, but run a `mysqldump` command, specified with `.spec.template.spec.containers[0].command`. To perform the dump, we use the environment variables of the database deployment to set the hostname, user and password parameters of the `mysqldump` command. The `MYSQL_PASSWORD` variable refers to the value of the secret, which is already used for the database Pod. Like this we ensure that the dump is performed with the same credentials.

Let's create our Job: Create a file `job_mysql-dump.yaml` with the content above:

```bash
kubectl create -f ./job_mysql-dump.yaml --namespace <namespace>
```

Check if the Job was successful:

```bash
kubectl describe jobs/mysql-dump --namespace <namespace>
```

The executed Pod can be shown as follows:

```bash
kubectl get pods --namespace <namespace>
```

To show all Pods belonging to a Job in a human-readable format, the following command can be used:

```bash
kubectl get pods --selector=job-name=mysql-dump --output=go-template='{{range .items}}{{.metadata.name}}{{end}}' --namespace <namespace>
```


## CronJobs

A Kubernetes CronJob is nothing else than a resource which creates a Job at a defined time, which in turn starts (as we saw in the previous section) a Pod to run a command. Typical use cases are cleanup Jobs, which tidy up old data for a running Pod, or a Job to regularly create and save a database dump.

Further information can be found at the [Kubernetes CronJob Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).
