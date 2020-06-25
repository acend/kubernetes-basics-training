---
title: "10.1 StatefulSet"
weight: 101
sectionnumber: 10.1
---

Stateless applications or applications with a stateful backend can be described as Deployments.
Sometimes your application has to be stateful.
For example, if your application needs the same hostname every time it starts or if you have a clustered application with a strict start/stop order of all cluster services (e.g., RabbitMQ).
These features are implemented as StatefulSets.


## Consistent hostnames

While in normal Deployments a hash based name of the Pods (represented also as Hostname inside the Pod) is generated, StatefulSets create Pods with preconfigured names.
Example of a RabbitMQ cluster with three instances (Pods):

```
rabbitmq-0
rabbitmq-1
rabbitmq-2
```


## Scaling

Scaling is handled differently in StatefulSets.
When scaling up from 3 to 5 replicas in a Deployment, two additional Pods could be started at the same time (based on the configuration). Using the StatefulSet it seems to be more "in control".

Example with RabbitMQ:

1. Scale `kubectl scale deployment rabbitmq --replicas=5 --namespace [USER]`
1. `rabbitmq-3` is started
1. When `rabbitmq-3` is done starting up (State: "Ready", take a look at the readiness probe), `rabbitmq-4` follows with the start procedure

On downscaling, the order is vice versa. The "youngest" Pod will be stopped in the first place, and it needs to be finished before the "second youngest" Pod is stopped.
Order for scaling down: `rabbitmq-4`, `rabbitmq-3`, etc.


## Update procedure

During an update of an application with a StatefulSet the "youngest" Pod will be the first to be updated and only after a successful start the next Pod will follow.

1. Youngest Pod will be stopped
1. New Pod with new image version is started
1. Having a successful readiness probe, the second youngest Pod will be stopped
1. And so on...

If the start of a new Pod fails the update will be interrupted so that the architecture of your application won't break.


## Trivia

As StatefulSets have predictable names---which are reused---you can integrate PVCs into the sets from a configured StorageClass. They will also be used on scaling up!
As names are predictable a 1-to-1 relation is given.
By setting a _partition_ updates can be splitted into two steps.


## Conclusion

The controllable and predictable behaviour can be a perfect match for applications such as RabbitMQ or etcd, as you need unique names for such application clusters.


## Tasks


### StatefulSets

Create a StatefulSets based on the YAML file `nginx-sfs.yaml`:
{{< onlyWhenNot mobi >}}

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

{{< /onlyWhenNot >}}
{{< onlyWhen mobi >}}

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
        image: docker-registry.mobicorp.ch/puzzle/k8s/kurs/nginx:1.12
        ports:
        - containerPort: 80
          name: nginx
```

{{< /onlyWhen >}}
Start the StatefulSet:
  
```bash
kubectl create -f nginx-sfs.yaml --namespace <namespace>
```


### Scale the StatefulSet

To watch the progress, open a second console and list the StatefulSet and watch the Pods:

```bash
kubectl get statefulset --namespace <namespace>
kubectl get pods -l app=nginx -w --namespace <namespace>
```

Scale the StatefulSet up:

```bash
kubectl scale statefulset nginx-cluster --replicas=3 --namespace <namespace>
```


### Update the StatefulSet

To watch the changes of the Pods, please open a second window and execute the command:

```bash
kubectl get pods -l app=nginx -w --namespace <namespace>
```

Set the image version to `latest` in the StatefulSet:
{{< onlyWhenNot mobi >}}

```bash
kubectl set image statefulset nginx-cluster nginx=nginx:latest --namespace <namespace>
```

{{< /onlyWhenNot >}}
{{< onlyWhen mobi >}}

```bash
kubectl set image statefulset nginx-cluster nginx=docker-registry.mobicorp.ch/puzzle/k8s/kurs/nginx:latest --namespace <namespace>
```

{{< /onlyWhen >}}
Rollback the software:

```bash
kubectl rollout undo statefulset nginx-cluster --namespace <namespace>
```

Clean up:

```bash
kubectl delete statefulset nginx-cluster --namespace <namespace>
```

Further Information can be found at the [Kubernetes StatefulSet Dokumentation](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) or at this [published article](https://opensource.com/article/17/2/stateful-applications).
