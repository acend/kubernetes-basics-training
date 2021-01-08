---
title: "7. Attaching a database"
weight: 7
sectionnumber: 7
---

Numerous applications are stateful in some way and want to save data persistently, be it in a database, as files on a filesystem or in an object store. In this lab, we are going to create a MariaDB database and configure our application to store its data in it.

{{% onlyWhen openshift %}}
{{% alert title="Warning" color="secondary" %}}
Please make sure you completed labs [2 (Project creation)](../02/), [3 (Deployment creation)](../03/) and [4 (Service and Route creation)](../04/) before you continue with this lab.
{{% /alert %}}
{{% /onlyWhen %}}


## Task {{% param sectionnumber %}}.1: Instantiate a MariaDB database

{{% onlyWhen openshift %}}
We are going to use an OpenShift template to create the database. This can be done by either using the Web Console or the CLI. Both are going to be explained in this lab, so pick the one you are more comfortable with.


### Instantiate a template using the Web Console

Make sure you are in OpenShift's **Developer** view (upper left dropdown) and have selected the correct Project:

![selection](selection.png)

Now click **+Add**, choose **Database**, **MariaDB (Ephemeral)** and then **Instantiate Template**. A form opens. Check that the first field corresponds to the correct Project and set the MariaDB Database Name field to `acendexampledb` and leave the remaining fields as they are. Finally click **Create** at the end of the form.


### Instantiate a template using the CLI

{{% alert title="Warning" color="secondary" %}}
Do not execute these steps if you already have created a MariaDB database using the Web Console.
{{% /alert %}}

We are going to instantiate the MariaDB Template from the `openshift` Project. Before we can do that, we need to know what parameters the Template expects. Let's find out:

```bash
oc process --parameters mariadb-ephemeral --namespace openshift
```

```
NAME                    DESCRIPTION                                                               GENERATOR           VALUE
MEMORY_LIMIT            Maximum amount of memory the container can use.                                               512Mi
NAMESPACE               The OpenShift Namespace where the ImageStream resides.                                        openshift
DATABASE_SERVICE_NAME   The name of the OpenShift Service exposed for the database.                                   mariadb
MYSQL_USER              Username for MariaDB user that will be used for accessing the database.   expression          user[A-Z0-9]{3}
MYSQL_PASSWORD          Password for the MariaDB connection user.                                 expression          [a-zA-Z0-9]{16}
MYSQL_ROOT_PASSWORD     Password for the MariaDB root user.                                       expression          [a-zA-Z0-9]{16}
MYSQL_DATABASE          Name of the MariaDB database accessed.                                                        sampledb
MARIADB_VERSION         Version of MariaDB image to be used (10.2 or latest).                                         10.2
```

As you might already see, each of the parameters has a default value ("VALUE" column). Also, the parameters `MYSQL_USER`, `MYSQL_PASSWORD` and `MYSQL_ROOT_PASSWORD` are going to be generated ("GENERATOR" is set to `expression` and "VALUE" contains a regular expression). This means we don't necessarily have to overwrite any of them so let's simply use those defaults:

```bash
oc process mariadb-ephemeral -pMYSQL_DATABASE=acendexampledb  --namespace openshift | oc apply -f -
```


## Task {{% param sectionnumber %}}.2: Inspection

What just happened is that you instantiated an OpenShift Template that creates multiple resources using the (default) values as parameters. Let's have a look at the resources that just have been created by looking at the Template's definition:

```bash
oc get templates -n openshift mariadb-ephemeral -o yaml
```

The Template's content reveals a Secret, a Service and a DeploymentConfig.
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}

We are first going to create a so-called _Secret_ in which we store sensitive data like the databasename, the password, the rootpassword and the username. The secret will be used to access the database and also to create the initial database.

```bash
kubectl create secret generic mariadb --from-literal=database-name=acendexampledb --from-literal=database-password=mysqlpassword --from-literal=database-root-password=mysqlrootpassword --from-literal=database-user=acend-user --namespace <namespace>
```
{{% /onlyWhenNot %}}

The Secret contains the database name, user, passwort and the root password. However, these values will neither be shown with `{{% param cliToolName %}} get` nor with `{{% param cliToolName %}} describe`:

```bash
{{% param cliToolName %}} get secret mariadb --output yaml --namespace <namespace>
```

```
apiVersion: v1
data:
  database-name: YWNlbmQtZXhhbXBsZS1kYg==
  database-password: bXlzcWxwYXNzd29yZA==
  database-root-password: bXlzcWxyb290cGFzc3dvcmQ=
  database-user: YWNlbmQtdXNlcg==
kind: Secret
metadata:
  ...
type: Opaque
```
The reason is all the values in the `.data` section are base64 encoded. Even though we cannot see the true values, they can easily be decoded:

```bash
echo "YWNlbmQtZXhhbXBsZS1kYg==" | base64 -d
```

{{% onlyWhen openshift %}}
{{% alert title="Note" color="primary" %}}
There's also the `oc extract` command which can be used to extract the content of Secrets and ConfigMaps into a local directory. Use `oc extract --help` to see how it works.
{{% /alert %}}
{{% /onlyWhen %}}

{{% alert title="Note" color="primary" %}}
By default, Secrets are not encrypted!
{{% onlyWhen openshift %}}OpenShift [offers this capability](https://docs.openshift.com/container-platform/latest/security/encrypting-etcd.html){{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}Kubernetes 1.13 [offers this capability](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/){{% /onlyWhenNot %}}. Another option would be the use of a secrets management solution like [Vault by HashiCorp](https://www.vaultproject.io/).
{{% /alert %}}
{{% onlyWhen openshift %}}
The interesting thing about Secrets is that they can be reused. We could extract all the plaintext values from the Secret but it's way easier to instead simply refer to its values inside the Deployment or DeploymentConfig (as in this lab):

```bash
oc get dc mariadb --output yaml --namespace <namespace>
```

```
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  annotations:
    template.alpha.openshift.io/wait-for-ready: "true"
  labels:
    template: mariadb-ephemeral-template
    template.openshift.io/template-instance-owner: 763195be-4429-462d-bb26-70d199f5dbe0
  ...
  name: mariadb
  namespace: acend-test
spec:
  replicas: 1
  ...
  template:
    metadata:
      ...
    spec:
      containers:
      - name: mariadb
        env:
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              key: database-user
              name: mariadb
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              key: database-password
              name: mariadb
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              key: database-root-password
              name: mariadb
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              key: database-name
              name: mariadb
        image: image-registry.openshift-image-registry.svc:5000/openshift/mariadb@sha256:44292f3eeaa3729372eee6fde9e1f07719172a1ca759f399619660bf1949192e
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3306
          protocol: TCP
        ...
status:
  ...
```

Above DeploymentConfig is the output you get from the command before. Most parts have been cut out to focus on the relevant lines: The references to the `mariadb` Secret. As you can see, instead of directly defining environment variables you can refer to a specific key inside a Secret. We are going to make use of this concept for our own application.
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
We are now going to create a Deployment and a Service. As a first example, we use a database without persistent storage. Only use an ephemeral database for testing purposes as a restart of the Pod leads to data loss. We are going to look at how to persist this data in a persistent volume later on.

As we had seen in the earlier labs, all resources like Deployments, Services, Secrets and so on can be displayed in YAML or JSON format. It doesn't end there, capabilities also include the creation and exportation of resources using YAML or JSON files.

In our case we want to create a deployment including a Service for our MySQL database.
Save this snippet as `mariadb.yaml`:

{{% onlyWhenNot mobi %}}
{{< highlight yaml >}}{{< readfile file="content/en/docs/07/mariadb.yaml" >}}{{< /highlight >}}
{{% /onlyWhenNot %}}

{{% onlyWhen mobi %}}
{{< highlight yaml >}}{{< readfile file="content/en/docs/07/mariadb-mobi.yaml" >}}{{< /highlight >}}
{{% /onlyWhen %}}

Execute it with:

```bash
kubectl create -f mariadb.yaml --namespace <namespace>
```

As soon as the container image for `mariadb:10.5` has been pulled, you will see a new Pod using `kubectl get pods`.

The environment variables defined in the deployment configure the MariaDB Pod and how our frontend will be able to access it.
{{% /onlyWhenNot %}}


## Task {{% param sectionnumber %}}.2: Attach the database to the application

By default, our `example-web-python` application uses a SQLite memory database. However, this can be changed by defining the following environment variable(`MYSQL_URI`) to use the newly created MariaDB database:

```
#MYSQL_URI=mysql://<user>:<password>@<host>/<database>
MYSQL_URI=mysql://acend-user:mysqlpassword@mariadb/acendexampledb
```

The connection string our `example-web-python` application uses to connect to our new MariaDB, is a concatenated string from the values of the `mariadb` Secret.

For the actual MariaDB host, you can either use the MariaDB Service's ClusterIP or DNS name as address. All Services and Pods can be resolved by DNS using their name.

The following commands sets the environment variables for the deployment configuration of the `example-web-python` application

```bash
{{% param cliToolName %}} set env --from=secret/mariadb --prefix=MYSQL_ deploy/example-web-python --namespace <namespace>
{{% param cliToolName %}} set env deploy/example-web-python MYSQL_URI='mysql://$(MYSQL_DATABASE_USER):$(MYSQL_DATABASE_PASSWORD)@mariadb/$(MYSQL_DATABASE_NAME)' --namespace <namespace>
```

The first command inserts the values from the Secret, the second finally uses these values to put them in the environment variable `MYSQL_URI` which the application considers.

You could also do the changes by directly editing the Deployment:

```bash
{{% param cliToolName %}} edit deployment example-web-python --namespace <namespace>
```

```yaml
      ...
      containers:
      - env:
        - name: MYSQL_DATABASE_NAME
          valueFrom:
            secretKeyRef:
              key: database-name
              name: mariadb
        - name: MYSQL_DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              key: database-password
              name: mariadb
        - name: MYSQL_DATABASE_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              key: database-root-password
              name: mariadb
        - name: MYSQL_DATABASE_USER
          valueFrom:
            secretKeyRef:
              key: database-user
              name: mariadb
        - name: MYSQL_URI
          value: mysql://$(MYSQL_DATABASE_USER):$(MYSQL_DATABASE_PASSWORD)@mariadb/$(MYSQL_DATABASE_NAME)
        image: quay.io/acend/example-web-go
        imagePullPolicy: Always
        name: example-web-python
        ...
```

In order to find out if the change worked we can either look at the container's logs (`{{% param cliToolName %}} logs <pod>`).
Or we could register some "Hellos" in the application, delete the Pod, wait for the new Pod to be started and check if they are still there.

{{% alert title="Note" color="primary" %}}
This does not work if we delete the database Pod as its data is not yet persisted.
{{% /alert %}}


## Task {{% param sectionnumber %}}.3: Manual database connection

As described in [lab 6](../06/) we can log into a Pod with {{% onlyWhenNot openshift %}}`kubectl exec -it <pod> -- /bin/bash`.{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}`oc rsh <pod>`.{{% /onlyWhen %}}

Show all Pods:

```bash
{{% param cliToolName %}} get pods --namespace <namespace>
```

Which gives you an output similar to this:

```
NAME                                  READY   STATUS    RESTARTS   AGE
example-web-python-574544fd68-qfkcm   1/1     Running   0          2m20s
mariadb-f845ccdb7-hf2x5               1/1     Running   0          31m
mariadb-1-deploy                      0/1     Completed   0          11m
```

Log into the MariaDB Pod:
{{% onlyWhenNot openshift %}}
```bash
kubectl exec -it mariadb-f845ccdb7-hf2x5 --namespace <namespace> -- /bin/bash
```
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
```bash
oc rsh mariadb-f845ccdb7-hf2x5 --namespace <namespace>
```
{{% /onlyWhen %}}

You are now able to connect to the database and display the tables. Login with:

```bash
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -hmariadb acendexampledb
```

```
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 52810
Server version: 10.2.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [acendexampledb]>
```

Show all tables with:

```bash
show tables;
```


## Task {{% param sectionnumber %}}.4: Import a database dump

Our task is now to import this [dump.sql](https://raw.githubusercontent.com/acend/kubernetes-basics-training/master/content/en/docs/07/dump.sql) into the MariaDB database running as a Pod. Use the `mysql` command line utility to do this. Make sure the database is empty beforehand. You could also delete and recreate the database.

{{% alert title="Note" color="primary" %}}
You can also copy local files into a Pod using `{{% param cliToolName %}} cp`. Be aware that the `tar` binary has to be present inside the container and on your operating system in order for this to work! Install `tar` on UNIX systems with e.g. your package manager, on Windows there's e.g. [cwRsync](https://www.itefix.net/cwrsync). If you cannot install `tar` on your host, there's also the possibility of logging into the Pod and use `curl -O <url>`.
{{% /alert %}}


### Solution

This is how you copy the database dump into the Pod:

```bash
curl -O https://raw.githubusercontent.com/acend/kubernetes-basics-training/master/content/en/docs/07/dump.sql
{{% param cliToolName %}} cp ./dump.sql mysql-f845ccdb7-hf2x5:/tmp/ --namespace <namespace>
```

This is how you log into the MySQL Pod:

{{% onlyWhenNot openshift %}}
```bash
kubectl exec -it mariadb-f845ccdb7-hf2x5 --namespace <namespace> -- /bin/bash
```
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
```bash
oc rsh mariadb-f845ccdb7-hf2x5 --namespace <namespace>
```
{{% /onlyWhen %}}

This command shows how to drop the whole database:

```bash
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -hmariadb acendexampledb
```

```bash
drop database acendexampledb;
create database acendexampledb;
exit
```

Import a dump:

```bash
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -hmariadb acendexampledb < /tmp/dump.sql
```

{{% alert title="Note" color="primary" %}}
A database dump can be created as follows:

{{% onlyWhenNot openshift %}}
```bash
kubectl exec -it mariadb-f845ccdb7-hf2x5 --namespace <namespace> -- /bin/bash
```
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
```bash
oc rsh mariadb-f845ccdb7-hf2x5 --namespace <namespace>
```
{{% /onlyWhen %}}

```bash
mysqldump --user=$MYSQL_USER --password=$MYSQL_PASSWORD -hmariadb acendexampledb > /tmp/dump.sql
```

```bash
{{% param cliToolName %}} cp mariadb-f845ccdb7-hf2x5:/tmp/dump.sql /tmp/dump.sql
```

{{% /alert %}}


## Save point

You should now have the following resources in place:

* [example-web-python.yaml](example-web-python.yaml)
* [mariadb-secret.yaml](mariadb-secret.yaml)
* {{% onlyWhenNot mobi %}}[mariadb.yaml](mariadb.yaml){{% /onlyWhenNot %}}
  {{% onlyWhen mobi %}}[mariadb-mobi.yaml](mariadb-mobi.yaml){{% /onlyWhen %}}
