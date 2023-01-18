---
title: "Attaching a database"
weight: 7
---

Numerous applications are stateful in some way and want to save data persistently, be it in a database, as files on a filesystem or in an object store. In this lab, we are going to create a MariaDB database and configure our application to store its data in it.

{{% onlyWhen openshift %}}
{{% alert title="Warning" color="warning" %}}
{{% onlyWhenNot sbb %}}
Please make sure you completed labs {{<link "first-steps">}}, {{<link "deploying-a-container-image">}} and {{<link "exposing-a-service">}} before you continue with this lab.
{{% /onlyWhenNot %}}
{{% onlyWhen sbb %}}
Please make sure you completed labs {{<link "first-steps">}} and {{<link "scaling">}} before you continue with this lab.
{{% /onlyWhen %}}
{{% /alert %}}
{{% /onlyWhen %}}


## {{% task %}} Instantiate a MariaDB database

{{% onlyWhen openshift %}}
{{% onlyWhenNot baloise %}}
We are going to use an OpenShift template to create the database. This can be done by either using the Web Console or the CLI. Both are going to be explained in this lab, so pick the one you are more comfortable with.


### Instantiate a template using the Web Console

Make sure you are in OpenShift's **Developer** view (upper left dropdown) and have selected the correct Project:

{{< imgproc selection.png Resize  "600x" >}}{{< /imgproc >}}

Now click **+Add**, choose **Database**, **MariaDB (Ephemeral)** and then **Instantiate Template**. A form opens. Check that the first field corresponds to the correct Project and set the **MariaDB Database Name** field to `acend_exampledb` and leave the remaining fields as they are. Finally, click **Create** at the end of the form.


### Instantiate a template using the CLI

{{% alert title="Warning" color="warning" %}}
Do not execute these steps if you already have created a MariaDB database using the Web Console.
{{% /alert %}}

We are going to instantiate the MariaDB Template from the `openshift` Project. Before we can do that, we need to know what parameters the Template expects. Let's find out:

```bash
oc process --parameters openshift//mariadb-ephemeral
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
oc process openshift//mariadb-ephemeral -pMYSQL_DATABASE=acend_exampledb  | oc apply --namespace=<namespace> -f -
```

The output should be:

```
secret/mariadb created
service/mariadb created
deploymentconfig.apps.openshift.io/mariadb created
```


## {{% task %}} Inspection

What just happened is that you instantiated an OpenShift Template that creates multiple resources using the (default) values as parameters. Let's have a look at the resources that have just been created by looking at the Template's definition:

```bash
oc get templates -n openshift mariadb-ephemeral -o yaml
```

The Template's content reveals a Secret, a Service and a DeploymentConfig.
{{% /onlyWhen %}}
{{% /onlyWhenNot %}}
{{% onlyWhenNot openshift %}}

We are first going to create a so-called _Secret_ in which we store sensitive data. The secret will be used to access the database and also to create the initial database.

```bash
kubectl create secret generic mariadb \
  --from-literal=database-name=acend_exampledb \
  --from-literal=database-password=mysqlpassword \
  --from-literal=database-root-password=mysqlrootpassword \
  --from-literal=database-user=acend_user \
  --namespace <namespace>
```

{{% /onlyWhenNot %}}
{{% onlyWhen baloise %}}
We are first going to create a so-called _Secret_ in which we store sensitive data. The secret will be used to access the database and also to create the initial database.
The `oc create secret` command helps us create the secret like so:

```bash
oc create secret generic mariadb \
  --from-literal=database-name=acend_exampledb \
  --from-literal=database-password=mysqlpassword \
  --from-literal=database-root-password=mysqlrootpassword \
  --from-literal=database-user=acend_user \
  --namespace <namespace> \
  --dry-run=client -o yaml > secret_mariadb.yaml
```

Above command has not yet created any resources on our cluster as we used the `--dry-run=client` parameter and redirected the output into the file `secret_mariadb.yaml`.

The reason we haven't actually created the Secret yet but instead put the resource definition in a file has to do with the way things work at Baloise. The file will help you later.
But for now, create the Secret by applying the file's content:

```bash
oc apply -f secret_mariadb.yaml
```

{{% /onlyWhen %}}

The Secret contains the database name, user, password, and the root password. However, these values will neither be shown with `{{% param cliToolName %}} get` nor with `{{% param cliToolName %}} describe`:

```bash
{{% param cliToolName %}} get secret mariadb --output yaml --namespace <namespace>
```

```
apiVersion: v1
data:
  database-name: YWNlbmQtZXhhbXBsZS1kYg==
  database-password: bXlzcWxwYXNzd29yZA==
  database-root-password: bXlzcWxyb290cGFzc3dvcmQ=
  database-user: YWNlbmRfdXNlcg==
kind: Secret
metadata:
  ...
type: Opaque
```

The reason is that all the values in the `.data` section are base64 encoded. Even though we cannot see the true values, they can easily be decoded:

```bash
echo "YWNlbmQtZXhhbXBsZS1kYg==" | base64 -d
```

{{% onlyWhen openshift %}}
{{% alert title="Note" color="info" %}}
There's also the `oc extract` command which can be used to extract the content of Secrets and ConfigMaps into a local directory. Use `oc extract \--help` to see how it works.
{{% /alert %}}
{{% /onlyWhen %}}

{{% alert title="Note" color="info" %}}
By default, Secrets are not encrypted!

However, both [OpenShift](https://docs.openshift.com/container-platform/latest/security/encrypting-etcd.html) and [Kubernetes (1.13 and later)](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/) offer the capability to encrypt data in etcd.

{{% onlyWhenNot baloise %}}
Another option would be the use of a secrets management solution like [Vault by HashiCorp](https://www.vaultproject.io/).
{{% /onlyWhenNot %}}

{{% onlyWhen baloise %}}
At Baloise, secrets are managed by HashiCorp Vault and integrated into OpenShift by use of the [External Secrets Operator](https://external-secrets.io/).
{{% /onlyWhen %}}
{{% /alert %}}

{{% onlyWhenNot openshift %}}
We are now going to create a Deployment and a Service. As a first example, we use a database without persistent storage. Only use an ephemeral database for testing purposes as a restart of the Pod leads to data loss. We are going to look at how to persist this data in a persistent volume later on.

As we had seen in the earlier labs, all resources like Deployments, Services, Secrets and so on can be displayed in YAML or JSON format. It doesn't end there, capabilities also include the creation and exportation of resources using YAML or JSON files.

In our case we want to create a Deployment and Service for our MariaDB database.
Save this snippet as `mariadb.yaml`:

{{% onlyWhenNot customer %}}
{{< readfile file="/content/en/docs/attaching-a-database/mariadb.yaml" code="true" lang="yaml" >}}
{{% /onlyWhenNot %}}

{{% onlyWhen mobi %}}
{{< readfile file="/content/en/docs/attaching-a-database/mariadb-mobi.yaml" code="true" lang="yaml" >}}
{{% /onlyWhen %}}

Apply it with:

```bash
kubectl apply -f mariadb.yaml --namespace <namespace>
```

As soon as the container image for `mariadb:10.5` has been pulled, you will see a new Pod using `kubectl get pods`.

The environment variables defined in the deployment configure the MariaDB Pod and how our frontend will be able to access it.
{{% /onlyWhenNot %}}
{{% onlyWhen baloise %}}
We are now going to create a Deployment and a Service. As a first example, we use a database without persistent storage. Only use an ephemeral database for testing purposes as a restart of the Pod leads to data loss. We are going to look at how to persist this data in a persistent volume later on.

In our case we want to create a Deployment and Service for our MariaDB database.
Save this snippet as `mariadb.yaml`:

{{< readfile file="/content/en/docs/attaching-a-database/mariadb-baloise.yaml" code="true" lang="yaml" >}}

Apply it with:

```bash
oc apply -f mariadb.yaml --namespace <namespace>
```

As soon as the container image has been pulled, you will see a new Pod using `oc get pods`.

The environment variables defined in the deployment configure the MariaDB Pod and how our frontend will be able to access it.
{{% /onlyWhen %}}

The interesting thing about Secrets is that they can be reused, e.g., in different Deployments. We could extract all the plaintext values from the Secret and put them as environment variables into the Deployments, but it's way easier to instead simply refer to its values inside the Deployment (as in this lab) like this:

```
...
spec:
  template:
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
...
```

Above lines are an excerpt of the MariaDB Deployment. Most parts have been cut out to focus on the relevant lines: The references to the `mariadb` Secret. As you can see, instead of directly defining environment variables you can refer to a specific key inside a Secret. We are going to make further use of this concept for our Python application.


## {{% task %}} Attach the database to the application

By default, our `example-web-app` application uses an SQLite memory database.

However, this can be changed by defining the following environment variable to use the newly created MariaDB database:

{{% onlyWhenNot sbb %}}

```
#MYSQL_URI=mysql://<user>:<password>@<host>/<database>
MYSQL_URI=mysql://acend_user:mysqlpassword@mariadb/acend_exampledb
```

{{% /onlyWhenNot %}}
{{% onlyWhen sbb %}}

```
#SPRING_DATASOURCE_URL=jdbc:mysql://<host>/<database>
SPRING_DATASOURCE_URL=jdbc:mysql://mariadb/acend_exampledb
```

{{% /onlyWhen %}}

The connection string our `example-web-app` application uses to connect to our new MariaDB, is a concatenated string from the values of the `mariadb` Secret.

For the actual MariaDB host, you can either use the MariaDB Service's ClusterIP or DNS name as the address. All Services and Pods can be resolved by DNS using their name.

{{% onlyWhenNot sbb %}}
The following commands set the environment variables for the deployment configuration of the `example-web-app` application:

{{% alert title="Warning" color="warning" %}}
Depending on the shell you use, the following `set env` command works but inserts too many apostrophes! Check the deployment's environment variable afterwards or directly edit it as described further down below.
{{% /alert %}}

```bash
{{% param cliToolName %}} set env --from=secret/mariadb --prefix=MYSQL_ deploy/example-web-app --namespace <namespace>
{{% param cliToolName %}} set env deploy/example-web-app MYSQL_URI='mysql://$(MYSQL_DATABASE_USER):$(MYSQL_DATABASE_PASSWORD)@mariadb/$(MYSQL_DATABASE_NAME)' --namespace <namespace>
```

The first command inserts the values from the Secret, the second finally uses these values to put them in the environment variable `MYSQL_URI` which the application considers.

You could also do the changes by directly editing the Deployment:

```bash
{{% param cliToolName %}} edit deployment example-web-app --namespace <namespace>
```

In the file, find the section which defines the containers. You should find it under:

```
...
spec:
...
 template:
 ...
  spec:
    containers:
    - image: ...
...
```

The dash defines the beginning of a separate container definition. The following specifications should be inserted into this container definition:

```yaml
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
```

Your file should now look like this:

```
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
        image: {{% param "images.training-image-url" %}}
        imagePullPolicy: Always
        name: example-web-app
        ...
```

{{% /onlyWhenNot %}}
{{% onlyWhen sbb %}}
Add the environment variables by directly editing the Deployment:

```bash
{{% param cliToolName %}} edit deployment example-web-app --namespace <namespace>
```

```yaml
      ...
      containers:
      - env:
        - name: SPRING_DATASOURCE_DATABASE_NAME
          valueFrom:
            secretKeyRef:
              key: database-name
              name: mariadb
        - name: SPRING_DATASOURCE_USERNAME
          valueFrom:
            secretKeyRef:
              key: database-user
              name: mariadb
        - name: SPRING_DATASOURCE_PASSWORD
          valueFrom:
            secretKeyRef:
              key: database-password
              name: mariadb
        - name: SPRING_DATASOURCE_DRIVER_CLASS_NAME
          value: com.mysql.cj.jdbc.Driver
        - name: SPRING_DATASOURCE_URL
          value: jdbc:mysql://mariadb/$(SPRING_DATASOURCE_DATABASE_NAME)?autoReconnect=true
        image: {{% param "images.training-image-url" %}}
        imagePullPolicy: Always
        name: example-web-app
        ...
```

{{% /onlyWhen %}}

{{% alert title="Note" color="info" %}}
The environment can also be checked with the `set env` command and the `--list` parameter:

```bash
{{% param cliToolName %}} set env deploy/example-web-app --list --namespace <namespace>
```

This will show the environment as follows:

{{% onlyWhenNot sbb %}}

```
# deployments/example-web-app, container example-web-app
# MYSQL_DATABASE_PASSWORD from secret mariadb, key database-password
# MYSQL_DATABASE_ROOT_PASSWORD from secret mariadb, key database-root-password
# MYSQL_DATABASE_USER from secret mariadb, key database-user
# MYSQL_DATABASE_NAME from secret mariadb, key database-name
MYSQL_URI=mysql://$(MYSQL_DATABASE_USER):$(MYSQL_DATABASE_PASSWORD)@mariadb/$(MYSQL_DATABASE_NAME)
```

{{% /onlyWhenNot %}}
{{% onlyWhen sbb %}}

```
# deployments/example-web-app, container example-web-app
# SPRING_DATASOURCE_DATABASE_NAME from secret mariadb, key database-name
# SPRING_DATASOURCE_USERNAME from secret mariadb, key database-user
# SPRING_DATASOURCE_PASSWORD from secret mariadb, key database-password
SPRING_DATASOURCE_DRIVER_CLASS_NAME=com.mysql.cj.jdbc.Driver
SPRING_DATASOURCE_URL=jdbc:mysql://mariadb/$(SPRING_DATASOURCE_DATABASE_NAME)?autoReconnect=true
```

{{% /onlyWhen %}}

{{% /alert %}}

In order to find out if the change worked we can either look at the container's logs (`{{% param cliToolName %}} logs <pod>`) or we could register some "Hellos" in the application, delete the Pod, wait for the new Pod to be started and check if they are still there.

{{% alert title="Note" color="info" %}}
This does not work if we delete the database Pod as its data is not yet persisted.
{{% /alert %}}


## {{% task %}} Manual database connection

As described in {{<link "troubleshooting">}} we can log into a Pod with {{% onlyWhenNot openshift %}}`kubectl exec -it <pod> -- /bin/bash`.{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}`oc rsh <pod>`.{{% /onlyWhen %}}

Show all Pods:

```bash
{{% param cliToolName %}} get pods --namespace <namespace>
```

Which gives you an output similar to this:

```
NAME                                  READY   STATUS      RESTARTS   AGE
example-web-app-574544fd68-qfkcm      1/1     Running     0          2m20s
mariadb-f845ccdb7-hf2x5               1/1     Running     0          31m
mariadb-1-deploy                      0/1     Completed   0          11m
```

Log into the MariaDB Pod:

{{% alert title="Note" color="info" %}}
As mentioned in {{<link "troubleshooting">}}, remember to append the command with `winpty` if you're using Git Bash on Windows.
{{% /alert %}}

{{% onlyWhenNot openshift %}}

```bash
kubectl exec -it mariadb-f845ccdb7-hf2x5 --namespace <namespace> -- /bin/bash
```

{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}

```bash
oc rsh --namespace <namespace> <mariadb-pod-name>
```

{{% /onlyWhen %}}

You are now able to connect to the database and display the data. Login with:

```bash
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MARIADB_SERVICE_HOST $MYSQL_DATABASE

```

```
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 52810
Server version: 10.2.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [acend_exampledb]>
```

Show all tables with:

```bash
show tables;
```

Show any entered "Hellos" with:

```bash
select * from hello;
```

{{% alert title="Note" color="info" %}}
If your database is empty you can generate some hellos by visiting the Service you exposed in lab {{<link "exposing-a-service" >}} task "Expose the Service".
You can find your app URL by looking at your route:

```bash
oc get route --namespace <namespace>
```
{{% /alert %}}


## {{% task %}} Import a database dump

Our task is now to import this [dump.sql](https://raw.githubusercontent.com/acend/kubernetes-basics-training/main/content/en/docs/attaching-a-database/dump.sql) into the MariaDB database running as a Pod. Use the `mysql` command line utility to do this. Make sure the database is empty beforehand. You could also delete and recreate the database.

{{% alert title="Note" color="info" %}}
You can also copy local files into a Pod using `{{% param cliToolName %}} cp`. Be aware that the `tar` binary has to be present inside the container and on your operating system in order for this to work! Install `tar` on UNIX systems with e.g. your package manager, on Windows there's e.g. [cwRsync](https://www.itefix.net/cwrsync). If you cannot install `tar` on your host, there's also the possibility of logging into the Pod and using `curl -O <url>`.
{{% /alert %}}


### Solution

This is how you copy the database dump into the MariaDB Pod.

Download the [dump.sql](https://raw.githubusercontent.com/acend/kubernetes-basics-training/main/content/en/docs/attaching-a-database/dump.sql) or get it with curl:

```bash
curl -O https://raw.githubusercontent.com/acend/kubernetes-basics-training/main/content/en/docs/attaching-a-database/dump.sql
```

Copy the dump into the MariaDB Pod:

```bash
{{% param cliToolName %}} cp ./dump.sql <podname>:/tmp/ --namespace <namespace>
```

This is how you log into the MariaDB Pod:

{{% onlyWhenNot openshift %}}

```bash
kubectl exec -it <podname> --namespace <namespace> -- /bin/bash
```

{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}

```bash
oc rsh --namespace <namespace> <podname>
```

{{% /onlyWhen %}}

This command shows how to drop the whole database:

```bash
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MARIADB_SERVICE_HOST $MYSQL_DATABASE
```

```bash
drop database `acend_exampledb`;
create database `acend_exampledb`;
exit
```

Import a dump:

```bash
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MARIADB_SERVICE_HOST $MYSQL_DATABASE < /tmp/dump.sql
```

Check your app to see the imported "Hellos".

{{% alert title="Note" color="info" %}}
You can find your app URL by looking at your route:

```bash
oc get route --namespace <namespace>
```
{{% /alert %}}

{{% alert title="Note" color="info" %}}
A database dump can be created as follows:

{{% onlyWhenNot openshift %}}

```bash
kubectl exec -it <podname> --namespace <namespace> -- /bin/bash
```

{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}

```bash
oc rsh --namespace <namespace> <podname>
```

{{% /onlyWhen %}}

```bash
mysqldump --user=$MYSQL_USER --password=$MYSQL_PASSWORD -h$MARIADB_SERVICE_HOST $MYSQL_DATABASE > /tmp/dump.sql
```

```bash
{{% param cliToolName %}} cp <podname>:/tmp/dump.sql /tmp/dump.sql
```

{{% /alert %}}
