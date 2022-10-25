---
title: "Console login"
weight: 14
type: docs
onlyWhen: openshift
---

## {{% task %}} Login on the web console

First of all, open your browser.
Then, log in on OpenShift's web console using the URL and credentials provided by your trainer.


## {{% task %}} Login on the command line

In order to log in on the command line, copy the login command from the web console.

To do that, open the Web Console and click on your username that you see at the top right, then choose **Copy Login Command**.

![OpenShift web console login](../console-login.png)

A new tab or window will open in your browser.

{{% alert title="Note" color="info" %}}
You might need to log in again.
{{% /alert %}}

The page now displays a link **Display token**.
Click on it and copy the command under **Log in with this token**.

Now paste the copied command on the command line.


## {{% task %}} Verify login

If you now execute `oc version` you should see something like this (your output may vary):

```
Client Version: 4.11.2
Kustomize Version: v4.5.4
Kubernetes Version: v1.24.0+dc5a2fd
```


## First steps with {{% param cliToolName %}}

The `{{% param cliToolName %}}` binary has many subcommands. Invoke `{{% param cliToolName %}} --help` (or simply `-h`) to get a list of all subcommands; `{{% param cliToolName %}} <subcommand> --help` gives you detailed help about a subcommand.


## Next steps

If you're interested, have a look at the {{<link "more-tools-to-work-with-openshift">}}, which is however totally optional.

When you're ready to go, head on over to the [labs](../../docs/) and begin with the training!
