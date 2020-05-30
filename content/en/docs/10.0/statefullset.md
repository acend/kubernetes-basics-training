---
title: "10.1 StatefulSet"
weight: 101
sectionnumber: 10.1
---

Stateless applications or applications with a stateful backend, can be described as **Deployments**. Sometimes you need your application to be stateful.
For example if your application needs the same hostname every time it starts or if you have a clustered application with a strict start/stop order of all cluster services (e.g. rabbitmq).
These features are implemented as **Statefulset**.


## Consistent hostnames

While in normal Deployments a hash based name of the Pods (represented also as Hostname inside the Pod) is generated, Statefulsets create Pods with preconfigured names.
Example of a rabbitmq-cluster with three nodes (Pods):

```
rabbitmq-0
rabbitmq-1
rabbitmq-2
```


## Scaling

Scaling is handled as well differently in Statefulsets.
On scaling up from 3 to 5 within a Deployment, two additional Pods could be started at the __same__ time (based on the configuren. Using the Stateful it seems to be more "in control".

Example with Rabbitmq

1. Scale `kubectl scale deployment rabbitmq --replicas=5 --namespace [USER]`
1. `rabbitmq-3` is started
1. when `rabbitmq-3` done starting up (State: "Ready", take a look at _Readiness probe_), `rabbitmq-4` follows with the start procedure

On downscaling the order is vice versa. The "youngest" Pod will be stopped in first place and it needs to be finished, before the "second youngest" Pod is stopped.
Order for scaling down: `rabbitmq-4`, `rabbitmq-3`, etc.


## Update procedure / Rollout of a new application

On an update of the application, also the "youngest" Pod will be the first and only after a successful Start the next Pod will be updated.

1. Youngest Pod will be stopped
1. new Pod with new Image version is started
1. Having a successful "readinessProbe" the second youngest Pod will be stopped
1. etc...

If the start of a new Pod fails, the Update / Rollout will be interrupted, so that the architecture of your application won't break.


## Trivia

As Statefulsets have predictable names, which are reused, you can integrate PVCs into the sets from a configured storageclass. The will be used als on **scale up**!
As names are predictable a 1-to-1 relation is given. 
By setting a _Partition_ updates can be splitted into two steps.


## Conclusion

The control- and predictable behaviour can be perfectly used with application as __rabbitmq__ or __etcd__, as you need unique names the cluster creation.


## Tasks


### Statefulsets

1. Create a statefulset based on the YAML file _nginx-sfs.yaml_ :

```YAML
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx-cluster
spec:
  serviceName: "nginx"
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.12
        ports:
        - containerPort: 80
          name: nginx
```

1. Start the Statefulset
  
```bash
kubectl create -f nginx-sfs.yaml --namespace [USER]
```


### Scaling

1. To watch the progress, open a second console and list the Statefulsets and watch the Pods:

```bash
kubectl get statefulset --namespace <NAMESPACE>
kubectl get pods -l app=nginx -w --namespace <NAMESPACE>
```

1. Scale up Statefulset


```bash
kubectl scale statefulset nginx-cluster --replicas=3 --namespace <NAMESPACE>
```


### Update Statefulset Image

1. To watch the changes of the the Pods, please open a second window and execute the command:


```bash
kubectl get pods -l app=nginx -w --namespace <NAMESPACE>
```

1. Set new version of the Image in the Statefulset

```bash
kubectl set image statefulset nginx-cluster nginx=nginx:latest --namespace <NAMESPACE>
```

1. Rollback the software

```bash
kubectl rollout undo statefulset nginx-cluster --namespace <NAMESPACE>
```

Further Information can be found at the [Kubernetes StatefulSet Dokumentation](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) or at this [published article](https://opensource.com/article/17/2/stateful-applications).
