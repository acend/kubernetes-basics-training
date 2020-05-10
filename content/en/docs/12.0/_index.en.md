---
title: "12. Kustomize"
weight: 12
---


[kustomize](https://github.com/kubernetes-sigs/kustomize) is a project from the [Kubernetes Special Interest Groups (SIGs)](https://kubernetes.io/community/) to manage complex Kubernetes configurations.
In this lab we deploy a configuration into a integration and a production environment via kustomize


## Task: LAB12.1 install kustomize

For this lab, we need the kustomize client. Check the [documentation](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md) on how to install.


## Task: LAB11.2 understand kustomize

We are going to deploy a simple application:

* The deployment starts an nginx
* A service exposes the deployment
* The application will be deployed into a integratin and into a production environment

Kustomize allowes to to inherit kubertenes configurations. We are going to use this, to create a base and then inherit the configuration for the integration and production environment.


Habe a look at chapter _1)_ und _2)_ in [kustomize-Readme](https://github.com/kubernetes-sigs/kustomize/blob/master/README.md). Our base configuration represents the  _base_, integration and production environment will be realizes as _overlay_.

In den [Dateien zu diesem Lab](./12_data) befindet sich die kustomize-Konfiguration für Basis und Umgebungen. Eine gültige kubernetes-Konfiguration für die Integrationsumgebung generiert man daraus wie folgt:

```
kustomize build ./labs/12_data/overlays/integration
```

Diese Konfiguration lässt sich mittels einer Pipe an `kubectl apply` weitergeben um die Konfiguration anzuwenden. Das ist unser nächster Schritt.


## Aufgabe: LAB11.3 Umgebungen deployen

Lege erst zwei Namespaces für die Applikationsumgebungen an:

```
user=[Dein Techlab-Username]

kubectl create namespace $user-lab-12-integration
kubectl create namespace $user-lab-12-production
```

Deploye dann die Integration...

```
kustomize build ./labs/12_data/overlays/integration | kubectl apply -n $user-lab-12-integration -f -
```

und die Produktion:

```
kustomize build ./labs/12_data/overlays/production | kubectl apply -n $user-lab-12-production -f -
```

Eine entsprechende Abfage zeigt, dass in beiden Umgebungen Pods starten:

```
kubectl get pod -n $user-lab-12-integration
kubectl get pod -n $user-lab-12-production
```

Nach einer Weile zeigt `kubectl get service -n $user-lab-12-integration -w` (abbrechen mit Ctrl + C), welche externe IP dem Service zugewiesen wurde.

Rufe mittels `curl http://[EXTERNAL_IP]` oder Webbrowser die deployte Applikation auf.

Prüfe analog, ob auch die Produktion läuft. Falls ja: Gratulation! Zwei identische Applikationsumgebungen sind deployt.
Im nächsten Schritt verwenden wir kustomize, um umgebungsspezifische Anpassungen vorzunehmen.


## Aufgabe: LAB11.4 Ressourcenlimits setzen

Unser Kubernetes-Cluster hat beschränkte Ressourcen. Wir verhindern nun mittels [Ressourcenlimits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-requests-and-limits-of-pod-and-container), dass eine Umgebung der andern alle CPU-Power oder den Arbeitsspeicher stehlen kann.

Die Applikation soll in der Integrationsumgebung maximal 10% einer CPU und 50MB RAM verwenden können, in der Produktionsumgebung aber das doppelte zur Verfügung haben, um den zu erwartenden Ansturm von Besuchern zu bewältigen.

Der folgende Befehl erstellt einen kustomize-Patch, in welchem diese Anpassung für die Integrationsumgebung spezifiziert wird:

```
cat > labs/12_data/overlays/integration/ressource-quotas.yaml <<EOF
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: app
spec:
  template:
    spec:
      containers:
        - name: app
          resources:
            limits:
              cpu: 100m
              memory: 50Mi
EOF
```

Damit der Patch angewendet wird, muss `labs/12_data/overlays/integration/kustomization.yaml` wie folgt angepasst werden:

```
bases:
- ../../base
patches:
- ressource-quotas.yaml
```

Die Änderungen können danach wie im letzten Abschnitt gelernt angewendet werden:

```
user=[Dein Techlab-Username]
kustomize build ./labs/12_data/overlays/integration | kubectl apply -n $user-lab-12-integration -f -
```

Nach einer Weile zeigt `kubectl get svc -n $user-lab-12-integration -w` (abbrechen mit Ctrl + C), dass ein neuer Pod angelegt wurde und läuft.

Die Deploymentkonfiguration zeigt, dass neu ein Limit für CPU und Memory gilt:

```
kubectl -n $user-lab-12-integration describe deployment app
```

Übrigens: Kustomize patcht ziemlich clever, es verwendet [strategic merges](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-api-machinery/strategic-merge-patch.md). Für dich heisst das: Wenn du neue Werte für YAML-Arrays (z.B. Umgebungsvariabeln, Container eines Pods oder tief verschachtelte Optionen) angibst, führt kustomize die Objeke richtig zusammen und ersetzt sie nicht einfach mit den Inhalten deines Patches.

Konfiguriere nun analog die höheren Limits für die Produktion und freue dich darüber, wie DRY, aber doch flexibel, die Konfiguration ist ;)

## Aufgabe: LAB11.4 Umgebungsvariabeln setzen

Dir ist sicher aufgefallen, dass deine Applikation meldet, ihr Name sei "Test-Applikation"". Diesen Namen kriegt sie über die im Deployment gesetzte Umgebungsvariable `APPLICATION_NAME`.

* Ändere den Namen in einer der Umgebungen. Der Name steht stellvertretend für die vielen Konfigurationsoptionen verschiedenster Container, welche via Umgebungsvariable gesetzt werden können und mitunter nicht in jeder Applikationsumgebung gleich lauten.
* Bleibe ordentlich. Du könntest das natürlich im oben angelegten Ressource-Quota-Patch tun, solltest aber eine Lösung finden, um diesen Aspekt deiner Konfiguration in einem separaten Patch abzulegen.

## Weitere Infos

kustomize hat weitere hilfreiche Features.

* Verwende mehrere _bases_, um verschiedene Komponenten zu einer Konfiguration zu vereinen.
* Füge automatisch Labels zu den Ressourcen oder prefixe deren Namen.
* Erbe in deinen _overlays_ von andern _overlays_
* Und viel mehr, siehe die [Beispiele](https://github.com/kubernetes-sigs/kustomize/tree/master/examples) oder diese [kustomization.yaml](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/glossary.md#kustomization), welche viele der vorhandenen Features nutzt und erklärt.
