---
title: "Local usage"
weight: 10
type: docs
---

{{% onlyWhenNot nolocalinstallation %}}

Please follow the instructions on the {{<link "cli-installation">}} page to install `{{% param cliToolName %}}`.

{{% onlyWhen openshift %}}

If you already have successfully installed `{{% param cliToolName %}}`, please verify that your installed version is current.
Then, head over to {{<link "console-login">}} to log in.

{{% /onlyWhen %}}

{{% /onlyWhenNot %}}

{{% onlyWhen nolocalinstallation %}}

As the labs of this training will be done in your company's environment, please follow the company-specific instructions on how to set up your local installation.

{{% onlyWhen baloise %}}

After installing `{{% param cliToolName %}}`, follow the instructions on {{<link "console-login">}} in order to log in.

{{% /onlyWhen %}}
{{% /onlyWhen %}}
