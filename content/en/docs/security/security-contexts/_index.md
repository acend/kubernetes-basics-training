---
title: "Security contexts"
weight: 102
onlyWhenNot: techlab,sbb
---

In the concept of security context for a pod or container, there are severals thing to consider:

* Access control
* SElinux
* Running privileged or unprivileged workload
* Linux capabilities
* AppArmor
* Seccomp

In this lab you will learn where to configure and how to use some of these types.


## {{% task %}} Access Control

Create a new pod by using this example:
{{< readfile file="/content/en/docs/security/security-contexts/control_pod.yaml" code="true" lang="yaml" >}}

You can see the different value entries in the 'securityContext' section, let's figure how what do they do. So create the pod and connect into the shell:

```bash
kubectl exec -it security-context-demo --namespace <namespace> -- sh
```

In the container run 'ps' to get a list of all running processes. The output shows, that the processes are running with the user 1000, which is the value from 'runAsUser':

```
PID   USER     TIME  COMMAND
    1 1000      0:00 sleep 1h
    6 1000      0:00 sh
```

Now navigate to the directory '/data' and list the content. As you can see the 'emptyDir' has been mounted with the group ID of 2000, which is the value of the 'fsGroup' field.

```
drwxrwsrwx 2 root 2000 4096 Oct  20 20:10 demo
```

Go into the dir 'demo' and create a file:

```bash
cd demo
echo hello > demofile
```

List the content with 'ls' again and see, that 'demofile' has the group ID 2000, which is the value 'fsGroup' as well.

Run the last command 'id' here and check the output:

```
uid=1000 gid=3000 groups=2000
```

The shown group ID of the user is 3000, from the field 'runAsGroup'. If the field would be empty the user would have 0 (root) and every process would be able to go with files which are owned by the root (0) group.

```
exit
```


## {{% task %}} Advanced

As we are limited, in terms of permission, on the lab cluster we can't show all the other security contexts in a lab.

Check the documentation at kubernetes.io to view all the examples for [Security Contexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/).
