---
title: "Generic Chart usage"
weight: 125
onlyWhen: baloise
---

You have now seen how to set up and use the Generic Chart. Now it's your turn!


## {{% task %}} Setup

Repeat the steps from {{<link "generic-chart-setup">}} in order to create a new Chart.

{{% alert title="Note" color="info" %}}
Note the `alias: ` line inside `Chart.yaml`. You can change this value to whatever you'd like, but you need to use the same name as first line inside your `values.yaml`!

This is also how you can use the Generic Chart multiple times if you have more than one app/component.
{{% /alert %}}


## {{% task %}} example-web-app

Implement the example-web-app application from lab {{<link "scaling">}} using the Generic Chart.

{{% alert title="Note" color="info" %}}
Have a look at the Chart's documentation in its git repository or in the Baloise documentation site for all the available values.
{{% /alert %}}


## {{% task %}} Your own applications

Do you have applications of your own? Deploy them using the Generic Chart!
