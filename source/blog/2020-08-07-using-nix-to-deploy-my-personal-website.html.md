---
title: Using nix to deploy my personal website
description: Using nix to build the website in a GitHub Action workflow
created_at: 2020-08-07 11:32:00 +00:00
updated_at: 2020-08-07 11:32:00 +00:00
---

This is a follow-up to my previous article about setting up [a simple Ruby development environment using nix-shell][nix-shell-article] in which I mentioned I wasn't certain I'd _completely_ specified the development environment. Although it's a bit of a tangent from my main aim of configuring isolated _development_ environments, I thought it would be instructive to modify [the GitHub Action workflow that automatically publishes this website][github-actions-article] to [nix][].

### Modifying the GitHub action workflow to use nix

I found [cachix/install-nix-action][] and decided to use it in my workflow along with the `shell.nix` & `gemset.nix` files I'd already created. I had to remove the specification of a "ruby:2.6.6" container image, because this did not include a number of packages required by the install-nix-action step to install nix. Removing this specification meant that the workflow fell back to using GitHub's "ubuntu-latest" virtual environment which comes with [loads of OS packages][github-ubuntu-1804-packages] installed including those needed to install nix.

I then inserted the install-nix-action step immediately after the existing [actions/checkout][] step, removed the steps installing node.js and the bundled gems, and modified the step which built the website to run `nix-shell --command 'middleman build'`, i.e. to build the site within the shell specified by `shell.nix`.

At this point slightly to my amazement, the build ran successfully! You can see all the changes I made in [this commit][use-nix-commit].

### Observations

As with the experience of running nix-shell on my local machine, I belatedly realised node.js was being made available by the GitHub virtual environment and not by nix-shell. I did spend a bit of time investigating this by basing the workflow on a minimal container image, but it turns out that it's not trivial to prepare a container image suitable for installing nix. So I decided to give up at this point. Although it meant I still hadn't definitively proved I'd _completely_ specified the development environment, I'd convinced myself that I understood what was going on and could prove it given enough time!

I was pleasantly surprised to see that the nix-based build were significantly quicker than the original build, even though the bundled gems were being cached in the latter. Some of the speed-up can be attributed to the fact that the nix-based build doesn't have to spin up a separate container, but from a cursory look at the logs most of the gain seems to be in not having to install the bundled gems.

* [Building without nix-shell](https://github.com/floehopper/jamesmead.org/actions/runs/183152555) 4 mins 48 secs
* [Building with nix-shell](https://github.com/floehopper/jamesmead.org/actions/runs/183290575) 1 min 44 secs

### Next steps

As I mentioned previously, I plan to try creating a development environment for a simple Rails app, probably [this one][freerange/site] which doesn't need a database.

[nix-shell-article]: /blog/2020-07-26-a-simple-ruby-development-environment-using-nix-shell
[cachix/install-nix-action]: https://github.com/cachix/install-nix-action
[actions/checkout]: https://github.com/actions/checkout
[nix]: https://nixos.org/
[github-ubuntu-1804-packages]: https://github.com/actions/virtual-environments/blob/master/images/linux/Ubuntu1804-README.md
[github-actions-article]: /blog/2019-09-07-using-github-actions-to-publish-a-static-site-to-github-pages
[use-nix-commit]: https://github.com/floehopper/jamesmead.org/commit/cee581de9849fa721bf621fe58553458b17e83c5
[freerange/site]: https://github.com/freerange/site
