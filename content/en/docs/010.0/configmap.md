---
title: "10.4 ConfigMap"
weight: 104
---

Similar to environment variables, ConfigsMaps allow you to separate the configuration for an application from the image. Pods can access those variables during runtime, which allows maximum portability for applications running in containers.
In this lab you learn to create and use ConfigMaps.

# Create a ConfigMap in the Kubernetes Namespace:

To create a ConfigMap in a namespace, the following command is used:

```bash
kubectl create configmap [name der ConfigMap] [Data Source]
```
The [data source] can be a file, a directory or a command line input.


## Java properties Files as ConfigMap

A classic example for ConfigMaps are property files of Java applications, which can't be configured with environment variables.

We change to the namespace of lab 4 `$ kubectl config set-context $(kubectl config current-context) --namespace=[NAMESPACE]`

With the following command, a ConfigMap based on a local file is created:

```bash
kubectl create configmap javaconfiguration --from-file=./properties.properties 
```

The content of `properties.properties` should be:

```ini
key=value
key2=value2
```

With 

```bash
kubectl get configmaps
```

you can verify, if the ConfigMap was crated successfully:

```
NAME                DATA   AGE
javaconfiguration   1      7s
```

The content can also be displayed with 

```bash
kubectl get configmaps javaconfiguration -o json --namespace [NAMESPACE]
```


## Attach a Configmap to a Pod

Next, we want to make a ConfigMap accessible for a pod.

Basically, there are the following possibilities to achieve this: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/

* ConfigMap properties as environment variables in a deployment
* Commandline arguments via environment variables
* Mounted as volumes in the container

In this example, we want the file to be mounted as a volume in the container. We add the ConfigMap in the deployment as follows:


Basically, the pod or in our case the deployment has to be edited with `kubectl edit deployment example-spring-boot --namespace [NAMESPACE]`:

```yaml
      - configMap:
          defaultMode: 420
          name: javaconfiguration
        name: config-volume

```

With `kubectl edit deployment example-spring-boot --namespace [NAMESPACE]` we can edit the deployment and add the configuration in the volumes section at the very bottom:


```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "8"
  creationTimestamp: 2018-10-15T13:53:08Z
  generation: 8
  labels:
    app: spring-boot-example
  name: spring-boot-example
  namespace: [NAMESPACE]
  resourceVersion: "3990918"
  selfLink: /apis/extensions/v1beta1/namespaces/philipona/deployments/spring-boot-example
  uid: a5c2f455-d081-11e8-a406-42010a840034
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: spring-boot-example
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: spring-boot-example
        date: "1539788777"
    spec:
      containers:
      - env:
        - name: SPRING_DATASOURCE_USERNAME
          value: springboot
        - name: SPRING_DATASOURCE_PASSWORD
          value: mysqlpassword
        - name: SPRING_DATASOURCE_DRIVER_CLASS_NAME
          value: com.mysql.jdbc.Driver
        - name: SPRING_DATASOURCE_URL
          value: jdbc:mysql://springboot-mysql/springboot?autoReconnect=true
        image: appuio/example-spring-boot
        imagePullPolicy: Always
        name: example-spring-boot
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/config
          name: config-volume
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - configMap:
          defaultMode: 420
          name: javaconfiguration
        name: config-volume

```

After that, it's possible for the container to access the values in the ConfigMap in /etc/config/properties.properties 

```bash
kubectl exec -it [POD]  --namespace [NAMESPACE] -- cat /etc/config/properties.properties
```

```
key=value
key2=value2
```

Like this, the property file can be read and used by the Java application in the container. The image stays portable to other environments.


## Task: LAB10.4.1 ConfigMap Data Sources

Create a ConfigMap and use the different kinds of data sources: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/

Make the values accessible in the different ways possible.
