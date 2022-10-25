---
title: "Web terminal"
weight: 2
type: docs
onlyWhen: openshift
---

## Using the web terminal

Using OpenShift's web terminal might be more convenient for you as it doesn't require you to install `{{% param cliToolName %}}` locally on your computer.


### {{% task %}} Login on the web console

First of all, open your browser.
Then, log in on OpenShift's web console using the URL and credentials provided by your trainer.


### {{% task %}} Initialize terminal

In OpenShift's web console:

1. Click on the terminal icon on the upper right
2. Choose to create a new project
3. Name your project `<username>-terminal` where `<username>` is the username given to you during this training
4. Click **Start**

![Web terminal in the OpenShift console](../web-terminal.png)


### {{% task %}} Verification

After the initial setup, you're presented with a web terminal.
Tools like `{{% param cliToolName %}}` are already installed and you're also already logged in.

You can check this by executing the following command:

```bash
oc whoami
```

You're now ready to go!

{{% alert title="Warning" color="warning" %}}
The terminal project is only meant to be used for the web terminal resources.
Always check that you do not use the terminal namespace for the other labs!
{{% /alert %}}


## Next steps

If you're interested, have a look at the {{<link "more-tools-to-work-with-openshift">}}, which is however totally optional.

When you're ready to go, head on over to the [labs](../../docs/) and begin with the training!
