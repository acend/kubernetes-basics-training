---
title: "10.4 ConfigMap"
weight: 104
sectionnumber: 10.4
---

Similar to environment variables, _ConfigsMaps_ allow you to separate the configuration for an application from the image. Pods can access those variables at runtime which allows maximum portability for applications running in containers.
In this lab, you learn how to create and use ConfigMaps.


## Task {{% param sectionnumber %}}.1: Create a ConfigMap in the Kubernetes namespace

Use the following command to create a ConfigMap in a namespace:

```bash
kubectl create configmap <name> <data-source> --namespace <namespace>
```

The `<data-source>` can be a file, a directory, or a command line input.


### Java properties files as ConfigMap

A classic example for ConfigMaps are properties files of Java applications which can't be configured with environment variables.

With the following command, a ConfigMap based on a local file is created:

```bash
kubectl create configmap javaconfiguration --from-file=./java.properties --namespace <namespace>
```

The content of `java.properties` should be:

```properties
key=value
key2=value2
```

With

```bash
kubectl get configmaps --namespace <namespace>
```

you can verify, if the ConfigMap was created successfully:

```
NAME                DATA   AGE
javaconfiguration   1      7s
```

The content can also be displayed with

```bash
kubectl get configmap javaconfiguration -o json --namespace <namespace>
```


## Taks {{% param sectionnumber %}}.2: Attach a Configmap to a Pod

Next, we want to make a ConfigMap accessible for a Pod.

Basically, there are the following possibilities to achieve [this](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)

* ConfigMap properties as environment variables in a deployment
* Commandline arguments via environment variables
* Mounted as volumes in the container

In this example, we want the file to be mounted as a volume in the container.
Basically, a Deployment has to be extended with the following config:

```yaml
...
        - mountPath: /etc/config
          name: config-volume
      ...
      - configMap:
          defaultMode: 420
          name: javaconfiguration
        name: config-volume
...
```

Here is a complete example Deployment of a sample Java app:
{{< onlyWhenNot mobi >}}

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: spring-boot-example
  name: spring-boot-example
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
      labels:
        app: spring-boot-example
    spec:
      containers:
      - env:
        - name: SPRING_DATASOURCE_USERNAME
          value: example
        - name: SPRING_DATASOURCE_PASSWORD
          value: mysqlpassword
        - name: SPRING_DATASOURCE_DRIVER_CLASS_NAME
          value: com.mysql.jdbc.Driver
        - name: SPRING_DATASOURCE_URL
          value: jdbc:mysql://mysql/example?autoReconnect=true
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

{{< /onlyWhenNot >}}
{{< onlyWhen mobi >}}

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: spring-boot-example
  name: spring-boot-example
  namespace: <namespace>
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
        image: docker-registry.mobicorp.ch/puzzle/k8s/kurs/example-spring-boot:latest
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

{{< /onlyWhen >}}
After that, it's possible for the container to access the values in the ConfigMap in `/etc/config/java.properties`

```bash
kubectl exec -it <pod> --namespace <namespace> -- cat /etc/config/java.properties
```

```properties
key=value
key2=value2
```

Like this, the property file can be read and used by the Java application in the container. The image stays portable to other environments.


## Task {{% param sectionnumber %}}.3: ConfigMap Data Sources

Create a ConfigMap and use the other kinds of [data sources](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
