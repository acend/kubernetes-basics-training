---
title: "Verification"
weight: 20
type: docs
onlyWhenNot: openshift
---

## Verify the installation

You should now be able to execute `{{% param cliToolName %}}` in the command prompt. To test, execute:

```bash
{{% param cliToolName %}} version
```

You should now see something like (the version number may vary):

```
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.0", GitCommit:"9e991415386e4cf155a24b1da15becaa390438d8", GitTreeState:"clean", BuildDate:"2020-03-25T14:58:59Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"linux/amd64"}
...
```

If you don't see a similar output, possibly there are issues with the `PATH` variable.

{{% alert title="Warning" color="warning" %}}
Make sure to use at least version 1.16.x for your `kubectl`
{{% /alert %}}


## First steps with {{% param cliToolName %}}

The `{{% param cliToolName %}}` binary has many subcommands. Invoke `{{% param cliToolName %}} --help` (or simply `-h`) to get a list of all subcommands; `{{% param cliToolName %}} <subcommand> --help` gives you detailed help about a subcommand.


## Optional tools

Have a look at the optional tools described in {{<link "optional-kubernetes-power-tools">}} if you're interested.


## Next steps

When you're ready to go, head on over to the [labs](../../docs/) and begin with the training!
