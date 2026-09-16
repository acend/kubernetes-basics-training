---
title: "Persistent storage"
weight: 8
---

By default, data in containers is not persistent as was the case e.g. in {{<link "attaching-a-database">}}. This means that the data written in a container is lost as soon as it does not exist anymore. We want to prevent this from happening. One possible solution to this problem is to use persistent storage.


## Request storage

Attaching persistent storage to a Pod happens in two steps. The first step includes the creation of a so-called _PersistentVolumeClaim_ (PVC) in our namespace. This claim defines amongst other things what size we would like to get.

The PersistentVolumeClaim only represents a request but not the storage itself. It is automatically going to be bound to a _PersistentVolume_ by {{% param distroName %}}, one that has at least the requested size. If only volumes exist that have a bigger size than was requested, one of these volumes is going to be used. The claim will automatically be updated with the new size. If there are only smaller volumes available, the claim cannot be fulfilled as long as no volume with the exact same or larger size is created.


## Attaching a volume to a Pod

In a second step, the PVC from before is going to be attached to the Pod. In {{<link "scaling">}} we edited the deployment configuration in order to insert a readiness probe. We are now going to do the same for inserting the persistent volume.


## {{% task %}} Add a PersistentVolume

The following command creates a PersistentVolumeClaim which requests a volume of 1Gi size.
Save it to `pvc.yaml`:

{{< readfile file="/content/en/docs/persistent-storage/pvc.yaml" code="true" lang="yaml" >}}

And create it with:

```bash
{{% param cliToolName %}} apply -f pvc.yaml --namespace <namespace>
```

We now have to insert the volume definition in the correct section of the MariaDB deployment.

Change your local `mariadb.yaml` file and add the `volumeMounts` and `volumes` parts:

{{< highlight YAML "hl_lines=8-15" >}}
          resources:
            limits:
              cpu: 500m
              memory: 512Mi
            requests:
              cpu: 50m
              memory: 128Mi
          # start to copy here
          volumeMounts:
          - name: mariadb-data
            mountPath: /var/lib/mysql
      volumes:
      - name: mariadb-data
        persistentVolumeClaim:
          claimName: mariadb-data
{{< /highlight >}}

Then apply the change with:

```bash
{{% param cliToolName %}} apply -f mariadb.yaml --namespace <namespace>
```

{{% alert title="Note" color="info" %}}
Because we just changed the Deployment a new Pod was automatically redeployed. This unfortunately also means that we just lost the data we inserted before.
{{% /alert %}}

We need to redeploy the application pod, our application automatically creates the database schema at startup time. Wait for the database pod to be started fully before restarting the application pod.

If you want to force a redeployment of a Pod, you can use this:

```bash
{{% param cliToolName %}} rollout restart deployment example-web-app --namespace <namespace>
```

Using the command `{{% param cliToolName %}} get persistentvolumeclaim` or `{{% param cliToolName %}} get pvc`, we can display the freshly created PersistentVolumeClaim:

```bash
{{% param cliToolName %}} get pvc --namespace <namespace>
```

Which gives you an output similar to this:

```
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mariadb-data     Bound    pvc-2cb78deb-d157-11e8-a406-42010a840034   1Gi        RWO            standard       11s
```

The two columns `STATUS` and `VOLUME` show us that our claim has been bound to the PersistentVolume `pvc-2cb78deb-d157-11e8-a406-42010a840034`.


## Error case

If the container is not able to start it is the right moment to debug it!
Check the logs from the container and search for the error.

```bash
{{% param cliToolName %}} logs mariadb-f845ccdb7-hf2x5 --namespace <namespace>
```

{{% alert title="Note" color="info" %}}
If the container won't start because the data directory already has files in it, use the `{{% onlyWhenNot openshift %}}kubectl exec{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}oc debug{{% /onlyWhen %}}` command mentioned in {{<link "attaching-a-database">}} to check its content and remove it if necessary.{{% /alert %}}


## {{% task %}} Persistence check


### Restore data

Repeat [the task to import a database dump](../attaching-a-database/#task-75-import-a-database-dump).


### Test

Scale your MariaDB Pod to 0 replicas and back to 1. Observe that the new Pod didn't loose any data.
