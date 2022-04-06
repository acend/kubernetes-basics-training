---
title: "Verify the installation"
weight: 6
type: docs
sectionnumber: 1
---

## Verify the installation

You should now be able to execute `{{% param cliToolName %}}` in the command prompt. To test, execute:

```bash
{{% param cliToolName %}} version
```

You should now see something like (the version number may vary):

{{% onlyWhenNot openshift %}}

```
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.0", GitCommit:"9e991415386e4cf155a24b1da15becaa390438d8", GitTreeState:"clean", BuildDate:"2020-03-25T14:58:59Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"linux/amd64"}
...
```

{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}

```
Client Version: 4.6.9
...
```

{{% /onlyWhen %}}

If you don't see a similar output, possibly there are issues with the `PATH` variable.

{{% alert title="Warning" color="warning" %}}
{{% onlyWhenNot openshift %}}
Make sure to use at least version 1.16.x for your `kubectl`
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Make sure to use at least `oc` version `4.6.x`.
{{% /onlyWhen %}}

{{% /alert %}}


## First steps with {{% param cliToolName %}}

The `{{% param cliToolName %}}` binary has many subcommands. Invoke `{{% param cliToolName %}} --help` (or simply `-h`) to get a list of all subcommands; `{{% param cliToolName %}} <subcommand> --help` gives you detailed help about a subcommand.

{{% onlyWhenNot openshift %}}
If you don't want to memorize all `kubectl` options then use the `kubectl` cheat sheet: <https://kubernetes.io/docs/reference/kubectl/cheatsheet/>
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
If you don't want to memorize all `oc` options (and have a Red Hat Login) then use the `oc` cheat sheet: <https://developers.redhat.com/cheat-sheets/red-hat-openshift-container-platform>
{{% /onlyWhen %}}


## Optional tools

{{% onlyWhenNot openshift %}}
Have a look at the optional tools described in [Optional power tools for kubectl](../05_kubernetes/) if you're interested.
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Have a look at the optional tools mentioned in [Other tools to work with OpenShift](../05_openshift/) if you're interested.
{{% /onlyWhen %}}


## Next steps

When you're ready to go, head on over to the [labs](../../docs/) and begin with the training!
