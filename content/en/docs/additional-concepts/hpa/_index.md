---
title: "Horizontal Pod Autoscaler (HPA)"
weight: 98
onlyWhenNot: openshift
---

The Horizontal Pod Autoscaler (HPA) in Kubernetes is a feature that automatically scales the number of pods in a deployment, replica set, or stateful set based on observed CPU utilization, memory usage, or custom metrics.

HPA continuously monitors the resource usage of pods and adjusts the number of replicas to maintain a desired performance level. The scaling process is based on metrics collected from the [Kubernetes Metrics Server](https://kubernetes-sigs.github.io/metrics-server/) or external monitoring systems like Prometheus.

For more details, see also the Kubernetes documentation on [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).

## {{% task %}} Create a Deployment, Service and the HPA

Let's try this out, first, we create a new Deployment with the file `deploy-hpa.yaml`.

{{< readfile file="/content/en/docs/additional-concepts/hpa/deploy-hpa.yaml" code="true" lang="yaml" >}}

And a service in `svc-hpa.yaml` to connect to our pods:

{{< readfile file="/content/en/docs/additional-concepts/hpa/svc-hpa.yaml" code="true" lang="yaml" >}}

And finally for the HPA to do its job, we also have to deploy the HPA object in `hpa.yaml`:

{{< readfile file="/content/en/docs/additional-concepts/hpa/hpa.yaml" code="true" lang="yaml" >}}

Apply all those files with:

```bash
cat *hpa.yaml | {{% param cliToolName %}} apply -f -
```

## {{% task %}} Trigger the HPA

To see our HPA in action, lets generate some traffic on our hpa-demo-deployment in a seperate terminal: We use a simple while loop with a `wget` call to our `hpa-demo-deployment` service:

```bash
{{% param cliToolName %}}  run -i --tty load-generator --rm --image=busybox --restart=Never --namespace <namespace> -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://hpa-demo-deployment; done"
```

Now lets watch how the HPA increases the replica count of our Deployment:

```bash
watch {{% param cliToolName %}} get deploy,pod,hpa -l run=hpa-demo-deployment --namespace <namespace>
```

At beginn, you just have one Pod:

```
NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hpa-demo-deployment   1/1     1            1           42h

NAME                                      READY   STATUS    RESTARTS   AGE
pod/hpa-demo-deployment-9cc6d54b5-kprvn   1/1     Running   0          42h

NAME                                                      REFERENCE                        TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/hpa-demo-deployment   Deployment/hpa-demo-deployment   cpu: 0%/50%   1         10        1          42h
```

after a while, you notice that the CPU utilization value on the HPA is increasing:

```
NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hpa-demo-deployment   1/1     1            1           42h

NAME                                      READY   STATUS    RESTARTS   AGE
pod/hpa-demo-deployment-9cc6d54b5-kprvn   1/1     Running   0          42h

NAME                                                      REFERENCE                        TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/hpa-demo-deployment   Deployment/hpa-demo-deployment   cpu: 6%/50%   1         10        1          42h
```

And then you see that new Pods are being scheduled in our Namespace, because the current CPU utilization is at around 250% (and therefore over its target of 50%). The HPA will now scale your Deployment until it reaches again the target 50% CPU utilization or when MAXPODS is reached:

```
NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hpa-demo-deployment   6/6     6            6           42h

NAME                                      READY   STATUS    RESTARTS   AGE
pod/hpa-demo-deployment-9cc6d54b5-7fnkf   1/1     Running   0          11s
pod/hpa-demo-deployment-9cc6d54b5-k5tdg   1/1     Running   0          26s
pod/hpa-demo-deployment-9cc6d54b5-kgngq   1/1     Running   0          26s
pod/hpa-demo-deployment-9cc6d54b5-kprvn   1/1     Running   0          42h
pod/hpa-demo-deployment-9cc6d54b5-t9xhq   1/1     Running   0          26s
pod/hpa-demo-deployment-9cc6d54b5-vt9zg   1/1     Running   0          11s

NAME                                                      REFERENCE                        TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/hpa-demo-deployment   Deployment/hpa-demo-deployment   cpu: 249%/50%   1         10        4          42h
```

Once the CPU utilization reaches around 50% again, no more new Pods will be created and the replica count remains on that level:

```
NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hpa-demo-deployment   6/6     6            6           42h

NAME                                      READY   STATUS    RESTARTS   AGE
pod/hpa-demo-deployment-9cc6d54b5-7fnkf   1/1     Running   0          39s
pod/hpa-demo-deployment-9cc6d54b5-k5tdg   1/1     Running   0          54s
pod/hpa-demo-deployment-9cc6d54b5-kgngq   1/1     Running   0          54s
pod/hpa-demo-deployment-9cc6d54b5-kprvn   1/1     Running   0          42h
pod/hpa-demo-deployment-9cc6d54b5-t9xhq   1/1     Running   0          54s
pod/hpa-demo-deployment-9cc6d54b5-vt9zg   1/1     Running   0          39s

NAME                                                      REFERENCE                        TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/hpa-demo-deployment   Deployment/hpa-demo-deployment   cpu: 46%/50%   1         10        6          42h
```

Stop the `load-generator` by closing the terminal. You will see that the deployment scales back to 1 replica.
