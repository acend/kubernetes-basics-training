---
title: "10.3  Jobs"
weight: 103
---

Jobs are different from normal deployments, as they execute a time-constrained operation and report the result, as soon as they are finished. To achieve this, a job creates a pod and runs the defined operation e.g. command. A job isn't limited to create a single pod, it can also create multiple pods. When a job is deleted, the pods started (and stopped) by the job are also deleted.

For example, a job is used to ensure that a pod is run until its completion. If a pod fails, for example because of a node error, the job starts a new one. A job can also be used to start multiple pods in parallel.


More detailed information can be retrieved from [Kubernetes Jobs Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/).


## Task: Create a Job for a MySQL Dump

Similar to [Lab8, Task: Import a Database Dump](../08.0/#task-import-a-database-dump), we now want to create a dump of a running MySQL database, but without the need of interactively logging into the pod.

Lets first look at the job resource that we want to create.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: mysql-dump
spec:
  template:
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        command:
        - 'bash'
        - '-eo'
        - 'pipefail'
        - '-c'
        - >
          trap "echo Backup failed; exit 0" ERR;
          FILENAME=backup-${MYSQL_DATABASE}-`date +%Y-%m-%d_%H%M%S`.sql.gz;
          mysqldump --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} --port=${MYSQL_PORT} --skip-lock-tables --quick --add-drop-database --routines ${MYSQL_DATABASE} | gzip > /tmp/$FILENAME;
          echo "";
          echo "Backup successful"; du -h /tmp/$FILENAME;
        env:
        - name: MYSQL_DATABASE
          value: example
        - name: MYSQL_USER
          value: example
        - name: MYSQL_HOST
          value: mysql
        - name: MYSQL_PORT
          value: "3306"
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-password
              key: password
      restartPolicy: Never
```

The paramter `.spec.template.spec.containers[0].image` shows, that we use the same image as the running database. In contrast to the database pod, we don't start a database afterwards, but run a mysqldump command, specified with `.spec.template.spec.containers[0].command`. To perform the dump, we use the environment variables of the database deployment to set the hostname, user and password parameters of the mysqldump command. The `MYSQL_PASSWORD` variable refers to the value of the secret, which is already used for the database pod. Like this we ensure that the dump is performed with the same credentials.

Lets create our job, create a file `job_mysql-dump.yaml` with the content above

```bash
kubectl create -f ./job_mysql-dump.yaml --namespace [NAMESPACE]
```

Check if the job was successful:

```bash
kubectl describe jobs/mysql-dump --namespace [NAMESPACE]
```

The executed pod can be shown as follows:

```bash
kubectl get pods --namespace [NAMESPACE]
```

To show all pods belonging to a job in a human-readable format, the following command can be used:

```bash
kubectl get pods --selector=job-name=mysql-dump --output=jsonpath={.items..metadata.name} --namespace [NAMESPACE]
```

## Cron Jobs

A Kubernetes cronjob is nothing else than a resource which creates a job at a defined time, which in turn starts (as we saw in the previous section) a pod to run a command. Typical use cases are cleanup jobs, which tidy up old data for a running pod, or a job to regularly create and save a database dump.

Further information can be found at [Kubernetes CronJob Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).
