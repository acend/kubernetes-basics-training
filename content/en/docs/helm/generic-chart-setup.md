---
title: "Generic Chart setup"
weight: 123
onlyWhen: baloise
---

In the following labs we are going to create our first Helm Charts with the help of Baloise's Generic Chart and deploy them.

Baloise's Generic Helm Chart is meant as a template and easy starting point to deploy common Kubernetes resource manifests.
By declaring the Generic Chart as a dependency of your own Chart, you can make use of all the features the Generic Chart offers.


## {{% task %}} Setup the dependency

So first, let's create your own Chart. Open your favorite terminal and make sure you're in the workspace for this lab, e.g. `cd ~/<workspace-kubernetes-training>`:

```bash
helm create mychart
```

You will now find a `mychart` directory with the newly created chart. It already is a valid and fully functional Chart which deploys an nginx instance.
However, instead of using these generated templates and values, we want to use the Generic Chart.
Change into your Chart's directory and remove the generated templates:

```bash
cd mychart/
rm -r templates/
```

Before we declare the Generic Chart as a dependency, have a look at the generated `Chart.yaml` using your favorite text editor:

```bash
vim Chart.yaml
```

As you can see, the `Chart.yaml` defines the metadata for your chart, so feel free to change anything.

Also note that the `version` and `appVersion` values are different.
This is because the `version` field refers to the Helm Chart's version while the `appVersion` refers to the application's version that's deployed using this Chart.

In order to declare the Generic Chart as a dependency, add the following lines to your `Chart.yaml`:

```yaml
dependencies:
  - name:  generic-chart
    version: 3.13.0
    repository: https://CHART-REPOSITORY-URL/shared/release/
    alias: first-example-app
```

Save and close the file. You can check if you added the dependency correctly be executing:

```bash
helm dependency list
```

Above command should show you the dependency:

```
helm dependency list
NAME         	VERSION	REPOSITORY                                             	STATUS
generic-chart	3.13.0 	https://CHART-REPOSITORY-URL/shared/release/	missing
```

Note the `STATUS` field and its `missing` value. This is because the dependency has not yet been downloaded. Let's change this, execute:

```bash
helm dependency update
```

Note that `helm dependency list` now shows `ok` under `STATUS` and the `charts/` directory contains a gzipped tarball.
