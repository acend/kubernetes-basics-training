---
title: "Optional Kubernetes power tools"
weight: 30
type: docs
onlyWhenNot: openshift
---

## Optional Kubernetes power tools

`kubectx` and `kubens` are two handy shell scripts which let you easily switch between Kubernetes contexts and namespaces. See <https://github.com/ahmetb/kubectx> for detailed instructions.

Installation of `kubectx` and `kubens`:

```bash
curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o ~/bin/kubectx
curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o ~/bin/kubens
chmod +x ~/bin/kubectx ~/bin/kubens
```

`kube-ps1` is another helpful shell script which adds the current context and namespace to the shell prompt: <https://github.com/jonmosco/kube-ps1>

`fzf` is yet another handy helper tool when you have to deal with a lot of contexts or namespaces by adding an interactive menu to `kubectx` and `kubens`: <https://github.com/junegunn/fzf>

`stern` is a very powerful enhancement of `kubectl logs` and lets you tail logs of multiple containers and Pods at the same time: <https://github.com/wercker/stern>.


## Other tools to work with Kubernetes

* <https://github.com/lensapp/lens>


## Next steps

When you're ready to go, head on over to the [labs](../../docs/) and begin with the training!
