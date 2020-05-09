# Kubernetes Techlab

In the guided hands-on techlab, we show the participants the Helm basics.

For more see [Kubernetes Techlabs online](https://kubernetes-techlab.k8s.puzzle.ch/).


## Content Sections

The Techlab content resides within the [content](content) directory.

The main part are the labs, which can be found at [content/en/docs](content/en/docs).

## Hugo

Kubernetes Techlab is built using the static page generator [Hugo](https://gohugo.io/) and published under [kubernetes-techlab.k8s.puzzle.ch](https://kubernetes-techlab.k8s.puzzle.ch/).

The page uses the [docsy theme](https://github.com/google/docsy) which is included as a Git Submodule.

After cloning the main repo, you need to initialize the submodule like this: 

```bash
git submodule update --init --recursive
``` 

## Build using Docker

Build the image:

```bash
docker build -t acend/kubernetes-techlab:latest .
```

Run it locally:

```bash
docker run -i -p 8080:8080 acend/kubernetes-techlab
```

## How to develop locally

To develop locally we don't want to rebuild the entire container image every time something changed, and it is also important to use the same hugo versions like in production.
We simply mount the working directory into a running container, where hugo is started in the server mode.

```bash
$ docker run --rm --interactive --publish 8080:8080 -v $(pwd):/opt/app/src -w /opt/app/src acend/hugo:0.68.3 hugo server -p 8080 --bind 0.0.0.0
```

## Contributions

If you find errors, bugs or missing information please help us improve our techlab and have a look at the [Contribution Guide](CONTRIBUTING.md).
