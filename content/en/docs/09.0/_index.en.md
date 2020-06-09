---
title: "9. Persistent storage"
weight: 9
sectionnumber: 9
---

By default, data in Pods is not persistent which was the case in [lab 8](../08.0/). This means that data that was written in a Pod is lost as soon as that Pod does not exist anymore. We want to prevent this from happening. One possible solution to this problem is to use persistent storage.


## Request storage

Attaching persistent storage to a Pod happens in two steps. The first step includes the creation of a so-called _PersistentVolumeClaim_ (PVC) in our namespace. This claim defines amongst others what name and size we would like to get.

The PersistentVolumeClaim only represents a request but not the storage itself. It is automatically going to be bound to a _PersistentVolume_ by Kubernetes, one that has at least the requested size. If only volumes exist that have a larger size than was requested, one of these volumes is going to be used. The claim will automatically be updated with the new size. If there are only smaller volumes available, the claim will not be bound as long as no volume the exact same or larger size is created.


## Attaching a volume to a Pod

In a second step, the PVC from before is going to be attached to the right Pod. In [lab 6](../06.0/) we edited the deployment configuration in order to insert a readiness probe. We are now going to do the same for inserting the persistent volume.

The following command creates a PersistentVolumeClaim which requests a volume of 1Gi size.  
Save it to `pvc.yaml`:

```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  labels:
    app: mysql
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

And create it with:

```bash
kubectl create -f pvc.yaml --namespace <namespace>
```

We now have to insert the volume definition in the correct section of the MySQL deployment:

```bash
kubectl edit deployment mysql --namespace <namespace>
```

Add both parts `volumeMounts` and `volumes`

```yaml
...
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        # start to copy here
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
      # stop to copy here
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
...
```

{{% alert title="Note" color="warning" %}}
Because we just changed the Deployment a new Pod was automatically redeployed. This unfortunately also means that we just lost the data we inserted before.
{{% /alert %}}

Our application automatically creates the database schema at startup time.

{{% alert title="Tip" color="warning" %}}
If you want to force a redeployment of a Pod, you could use this:

```bash
kubectl patch deployment example-web-python -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}" --namespace <namespace>
```

{{% /alert %}}

Using the command `kubectl get persistentvolumeclaim` or `kubectl get pvc`, we can display the freshly created PersistentVolumeClaim:

```bash
kubectl get pvc --namespace <namespace>
```

Wich gives you an output similar to this:

```
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mysql-pv-claim   Bound    pvc-2cb78deb-d157-11e8-a406-42010a840034   1Gi        RWO            standard       11s
```

The two columns `STATUS` and `VOLUME` show us that our claim has been bound to the PersistentVolume `pvc-2cb78deb-d157-11e8-a406-42010a840034`.


## Error case

If the container is not able to start it is the right moment to debug it!
Check the logs from the container and search for the error.

```bash
kubectl logs mysql-f845ccdb7-hf2x5 --namespace <namespace>
```

{{% alert title="Tip" color="warning" %}}
If the container won't start because the data directory has files in it then mount the volume at a different location in the Pod and check the content. Remove it if necessary.
{{% /alert %}}


## Task {{% param sectionnumber %}}.1: Persistence check


### Restore data

Repeat the task from [Lab8, Task: Import a database dump](../08.0/#task-import-a-database-dump).


### Test

Scale your MySQL Pod to 0 replicas and back to 1. Observe that the new Pod didn't loose any data.
