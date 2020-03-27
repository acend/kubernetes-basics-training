---
title: "10.3 - Jobs"
weight: 103
---

Jobs are different from normal deployments, as they execute a time-constrained operation and report the result, as soon as they are finished. To achieve this, a job creates a pod and runs the defined operation e.g. command. A job isn't limited to create a single pod, it can also create multiple pods. When a job is deleted, the pods started (and stopped) by the job are also deleted.

For example, a job is used to ensure that a pod is run until its completion. If a pod fails, for example because of a node error, the job starts a new one. A job can also be used to start multiple pods in parallel.


More detailed information can be retrieved from [Kubernetes Jobs Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/).


## Task: LAB10.1 Create a Job for a MySQL Dump


FIXME Similar to [Task 8.4](08_database.md#aufgabe-lab84-dump-auf-mysql-db-einspielen), we now want to create a dump of a running MySQL database, but without the need of interactively logging into the pod.

Lets first look at the job resource that we want to create. It can be found at [labs/10_data/job_mysql-dump.yaml](https://github.com/puzzle/kubernetes-techlab/blob/master/labs/10_data/job_mysql-dump.yaml).
The paramter `.spec.template.spec.containers[0].image` shows, that we use the same image as the running database. In contrast to the database pod, we don't start a database afterwards, but run a mysqldump command, specified with `.spec.template.spec.containers[0].command`. To perform the dump, we use the environment variables of the database deployment to set the hostname, user and password parameters of the mysqldump command. The `MYSQL_PASSWORD` variable refers to the value of the secret, which is already used for the database pod. Like this we ensure that the dump is performed with the same credentials.

Lets create our job:


```
$ kubectl create -f ./labs/10_data/job_mysql-dump.yaml --namespace [TEAM]-dockerimage
```

Check if the job was successful:

```
$ kubectl describe jobs/mysql-dump --namespace [TEAM]-dockerimage
```

The executed pod can be shown as follows:

```
$ kubectl get pods --namespace [TEAM]-dockerimage
```

To show all pods belonging to a job in a human-readable format, the following command can be used:

```
$ kubectl get pods --selector=job-name=mysql-dump --output=jsonpath={.items..metadata.name} --namespace [TEAM]-dockerimage
```

## Cron Jobs
A Kubernetes cronjob is nothing else than a resource which creates a job at a defined time, which in turn starts (as we saw in the previous section) a pod to run a command. Typical use cases are cleanup jobs, which tidy up old data for a running pod, or a job to regularly create and save a database dump.

Further information can be found at [Kubernetes CronJob Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).

---

**End Of Lab 10.3**