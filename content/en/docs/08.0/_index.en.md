---
title: "8. Attaching a Database"
weight: 8
---

Numerous applications are in some kind stateful and want to save data persistently, be it in a database or as files on a filesystem or in an object store. During this lab we are going to create a MySQL service and attach it to our application so that application pods can access the same database.


## Task: Create the MySQL Service


We are first going to create a so-called secret in which we write the password for accessing the database.

```bash
kubectl create secret generic mysql-password --from-literal=password=mysqlpassword --namespace [NAMESPACE]
```

The secret will neither be shown with `kubectl get` nor with `kubectl describe`:

```bash
kubectl get secret mysql-password --namespace [NAMESPACE] -o json
```

which give you an output similar to this:

```
{
    "apiVersion": "v1",
    "data": {
        "password": "bXlzcWxwYXNzd29yZA=="
    },
    "kind": "Secret",
    "metadata": {
        "creationTimestamp": "2018-10-16T13:36:15Z",
        "name": "mysql-password",
        "namespace": "[namespace]",
        "resourceVersion": "3156527",
        "selfLink": "/api/v1/namespaces/[namespace]/secrets/mysql-password",
        "uid": "74a7f030-d148-11e8-a406-42010a840034"
    },
    "type": "Opaque"
}
```

The string at `.data.password` is base64 encoded and can easily be decoded:

```bash
echo "bXlzcWxwYXNzd29yZA=="| base64 -d
```

**Note:** Secrets by default are not encrypted! Kubernetes 1.13 [offers this capability](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/). Another option would be the use of a vault like [Vault by HashiCorp](https://www.vaultproject.io/).

We are going to create another secret for storing the MySQL root password.

```bash
kubectl create secret generic mysql-root-password --namespace [NAMESPACE] --from-literal=password=mysqlrootpassword
```

We are now going to create deployment and service. As a first example we use a database without persistent storage. Only use an ephemeral database for testing purposes as a restart of the pod leads to the loss of all saved data. We are going to look at how to persist this data in a persistent volume later on.

As we had seen in the earlier labs, all resources like deployments, services, secrets and so on can be displayed in yaml or json format. But it doesn't end there, capabilities also include the creation and exportation of resources using yaml or json files.

In our case we want to create a deployment including a service for our MySQL database.  
Save this snippet as `mysql.yaml`:


```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  ports:
    - port: 3306
  selector:
    app: mysql
---
apiVersion: apps/v1 # for k8s versions before 1.9.0 use apps/v1beta2  and before 1.8.0 use extensions/v1beta1
kind: Deployment
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: mysql:5.7
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-root-password
              key: password
        - name: MYSQL_DATABASE
          value: example
        - name: MYSQL_USER
          value: example
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-password
              key: password
        livenessProbe:
          tcpSocket:
            port: 3306
        ports:
        - containerPort: 3306
          name: mysql
```

Execute it with:
```bash
kubectl apply -f mysql.yaml --namespace [NAMESPACE]
```

As soon as the container image for mysql:5.7 has been pulled, you will see a new pod using `kubectl get pods`.

The environment variables defined in the deployment configure the MySQL pod and how our frontend will be able to access it.


## Task: Attaching the Database to the Application

By default our example-web-python application uses a sqlite memory database. However, this can be changed by defining the following environment variables to use the newly created MySQL service:

- MYSQL_URI mysql://example:mysqlpassword@mysql/example

You can either use the MySQL service's cluster ip or DNS name as address. All services and pods can be resolved by DNS using their name.

We now can set these environment variables inside the deployment configuration. The configuration change automatically triggers a new deployment of the application. Because we set the environment variables the application now tries to connect to the MySQL database.

So let's set the environment variables in the example-spring-boot deployment:

```bash
kubectl create secret generic mysql-uri --from-literal=MYSQL_URI="mysql://example:mysqlpassword@mysql/example" --namespace [NAMESPACE] 
```

```bash
kubectl set env deployment/example-web-python --from=secret/mysql-uri --namespace [NAMESPACE] 
```

You could also do the changes by directly editing the deployment:

```bash
kubectl edit deployment example-web-python --namespace [NAMESPACE] 
```

```bash
kubectl get deployment example-web-python --namespace [NAMESPACE]
```
```yaml
...
      - env:
        - name: MYSQL_URI
          valueFrom:
            secretKeyRef:
              name: mysql-uri
              key: MYSQL_URI
...
```

In order to find out if the change worked we can either look at the container's logs (**Tip**: `kubectl logs [POD NAME]`).
Or we could register some "Hellos" in the application, delete the pod, wait for the new pod to be started and check if they are still there.

**Attention:** This does not work if we delete the database pod as its data is not yet persisted.


## Task: Manual Database Connection

As described in [lab 07](../07.0/) we can log into a pod with `kubectl exec -it [POD NAME] -- /bin/bash`.

Show all pods:

```bash
kubectl get pods --namespace [NAMESPACE]
```

which gives you an output similar to this:

```
NAME                                  READY   STATUS    RESTARTS   AGE
example-web-python-574544fd68-qfkcm   1/1     Running   0          2m20s
mysql-f845ccdb7-hf2x5                 1/1     Running   0          31m
```

Log into the MySQL pod:

```bash
kubectl exec -it mysql-f845ccdb7-hf2x5 --namespace [NAMESPACE] -- /bin/bash
```

You are now able to connect to the database and display the tables. Log in using:

```bash
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD example
```

```
Warning: Using a password on the command line interface can be insecure.
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 12
Server version: 5.6.41 MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```


Show all tables with:

```bash
show tables;
```


## Task: Import a Database Dump

Our task is now to import this [dump](https://raw.githubusercontent.com/acend/kubernetes-techlab/master/content/labs/08.0/dump.sql) into the MySQL database running as a pod. Use the `mysql` command line utility to do this. Make sure the database is empty beforehand. You could also delete and recreate the database.

{{% alert title="Tip" color="warning" %}}
**Tip:** You can also copy local files into a pod using `kubectl cp`. Be aware that the `tar` binary has to be present inside the container and on your operating system in order for this to work! Install `tar` on UNIX systems with e.g. your package manager, on Windows there's e.g. [cwRsync](https://www.itefix.net/cwrsync). If you cannot install `tar` on your host, there's also the possibility of logging into the pod and using `curl -O [URL]`.
{{% /alert %}}


### Solution
This is how you copy the database dump into the pod:

```bash
wget https://raw.githubusercontent.com/acend/kubernetes-techlab/master/content/labs/08.0/dump.sql
kubectl cp ./dump.sql mysql-f845ccdb7-hf2x5:/tmp/ --namespace [NAMESPACE]
```

This is how you log into the MySQL pod:

```
kubectl exec -it mysql-f845ccdb7-hf2x5 --namespace [NAMESPACE] -- /bin/bash
```

This shows how to drop the whole database:
```bash
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD example
```

```bash

drop database example;
create database example;
exit
```

Importing a dump:

```bash
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD example < /tmp/dump.sql
```

**Note:** A database dump can be created as follows:

```bash
mysqldump --user=$MYSQL_USER --password=$MYSQL_PASSWORD example > /tmp/dump.sql
```
