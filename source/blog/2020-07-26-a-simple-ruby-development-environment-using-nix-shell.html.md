---
title: A simple Ruby development environment using nix-shell
description: This nix-shell environment provides a Ruby environment capable of running middleman in order to build and serve my personal website locally
created_at: 2020-07-26 14:01:00 +00:00
updated_at: 2020-07-26 14:01:00 +00:00
guid: 62c8f224-9da6-40c6-922e-ced9305a513f
---

I've been playing around with the the [nix][] package manager recently. At the moment I'm mainly interested in seeing whether I can use it to configure isolated _development_ environments for various projects with varying package dependencies. The classic case of this would be two [Rails][] apps, one using [PostgreSQL][] and the other using [MySQL][]. Ideally I'd like development environments which completely specify all the projects dependencies and make *only* those dependencies available in the relevant development environment.

It's not unusual for me to need multiple versions of PostgreSQL and MySQL installed at the same time for different projects. While it is possible to do this using [Homebrew][], I've never found it very straightforward. At [Go Free Range][], we've often used [Vagrant][] to tackle this problem and more recently I've had some success using [Docker][] and [docker-compose][] using a similar approach to [the Evil Martians][docker-on-whales]. However, the former has always seemed like overkill and uses a lot of resources, while the latter often introduces extra orchestration complexity, because of the affordances which push you towards only having one process per container.

### Familiarising myself with nix

I ran into a minor hitch when installing nix on my laptop which is running MacOS Catalina, but this was soon resolved when someone [answered my question in the nix forums][nix-discourse-post]. I then spent a while watching some of the videos from Burke Libby's excellent [Nixology Youtube series][], reading his [What is Nix][] article on the Shopify engineering blog, working through some of the [nix expression language tutorial][] and reading bits of the [nix.dev guide][], all while playing around with nix in a terminal on my laptop.

Playing around like this is all very well, but I find that I only really start learning about things when I try to use them for real. Although eventually I want to use nix to create development environments for Rails apps, I thought I'd start with something much simpler - this website which is a static site generated using the [middleman][] Ruby library.

### A Ruby development environment using nix-shell

Firstly I installed [bundix][] using `nix-env --install bundix`. Since I already had a `Gemfile.lock`, I used `bundix --init --ruby=ruby_2_6` to generate a `gemset.nix` and (because of the `--init` option) a skeleton `shell.nix`. I needed to specify the Ruby version, because I didn't want the latest version, v2.7 at the time of writing.

At this point I realised, much like with other OS-level package managers, there isn't a simple way to specify the patch version of Ruby in nix; instead you have to use whatever patch version is in your current version of [nixpkgs][]. So to cope with that, I upgraded the version of Ruby used in `Gemfile` & `Gemfile.lock` from v2.6.5 to v2.6.6, currently the latest patch release of v2.6. I've read that it's possible to pin the version of nixpkgs to an older version if you want a specific patch version of Ruby, but I haven't tried that out yet. While I was at it, I upgraded [bundler][] from v2.0.2 to v2.1.4, the version included in Ruby v2.6.6, and ran `bundle install` to update the version recorded against `BUNDLED_WITH` in `Gemfile.lock` before re-generating the `gemset.nix` as described above.

I then ran `nix-shell` to see whether the development environment had been setup correctly. Running `which ruby` I discovered that it was still (incorrectly) pointing at my [rbenv][]. I fixed this by adding `ruby` to the array of `buildInputs` in `shell.nix`. Now `which ruby` was (correctly) pointing at the Ruby in the nix-store.

Running `middleman build` triggered a `Bundler::GemNotFound` exception with the message: "Could not find RedCloth-4.3.2 in any of the sources". I fixed this by removing the `.bundle/config` file from my home directory - I normally use this to set `BUNDLE_PATH` to `.bundle/gems` and
`BUNDLE_BIN` to `.bundle/bin` so that the bundled gems for a project are saved within a `.bundle` directory in each project directory, i.e. the gems for different projects are isolated from each other. Removing this configuration file seemed to do the trick and the website was built successfully.

I was actually a bit surprised that the build succeeded since my Vagrant- & Docker-based development environments had both _explicitly_ installed [node.js][]. Investigating this I realised that node.js was being made available from [nvm][] via the [execjs][] gem and highlighted the fact that my nix-shell development environment wasn't actually very isolated, because I still had things like nvm in my `PATH`.

When I removed the nvm config from the shell, execjs fell back to providing node.js from Homebrew, and when I removed the the Homebrew config from the shell, it fell back to prodiving node.js from the [JavaScriptCore framework][] in MacOS! Anyway, all this convinced me that I should include an explicit dependency on node.js in my nix-shell development environment and so I added `nodejs` to the list of `buildInputs` in `shell.nix`.

    with (import <nixpkgs> {});
    let
      ruby = ruby_2_6;
      env = bundlerEnv {
        name = "jamesmead.org-bundler-env";
        inherit ruby;
        gemdir = ./.;
      };
    in stdenv.mkDerivation {
      name = "jamesmead.org";
      buildInputs = [ env ruby nodejs ];
    }

### Conclusions

At this point I was pretty convinced (although not certain) I had a completely specified development environment for my personal website and I'd learned a few things along the way...

Although I can see why nix doesn't cater for specifying patch versions of Ruby, I feel as if I have needed this in development environments in the past and I'm not sure I'm ready to lose this capability provided by the likes of rbenv.

As I understand it, `gemset.nix` is effectively a translation of `Gemfile.lock` into a list of nix derivations which are then included in my nix-shell environment by `shell.nix` via `bundlerEnv`. I think the effect of this is that you don't need to run `bundle install` within the nix-shell environment, but I'm wondering whether this benefit is worth the extra hassle of keeping `gemset.nix` up-to-date with `Gemfile.lock`. However, perhaps the benefits would be more apparent if you have a lot of gems, particularly some with native extensions.

I'm now wondering whether a sensible half-way house for a development environment is to continue to use rbenv, nvm, bundler and npm in the normal way, but use nix to provide OS-level packages (e.g. PostgreSQL, MySQL, etc) as an alternative to Homebrew.

### Next steps

As I mentioned earlier, at this point I wasn't certain that I had a completely specified development environment. I could have tried it out on a Vagrant VM or a Docker container, but instead I decided to make use of it in the GitHub Action workflow that automatically publishes this website which I've written about [previously][github-actions-article]. I'll write about my experience of doing that in a separate article.

Having tackled a relatively trivial Ruby application, I'd like to try the same approach with a simple Rails app. The most obvious candidate is the [Go Free Range website][] which is a Rails app with no database. I'll let you know how I get on.

### Further reading

After writing this article, I came across Farid Zakaria's article, [what is bundlerEnv doing?][what-is-bundlerenv-doing], which I can highly recommend if you want to understand more about what's going on under the hood of the whole `bundix`, `gemset.nix` and `bundlerEnv` malarkey.

[nix]: https://nixos.org/
[Rails]: https://rubyonrails.org/
[PostgreSQL]: https://www.postgresql.org/
[MySQL]: https://www.mysql.com/
[Homebrew]: https://brew.sh/
[nix-discourse-post]: https://nixos.trydiscourse.com/t/installing-nix-on-macos-catalina-with-encrypted-boot-volume/7833
[Nixology Youtube series]: https://www.youtube.com/playlist?list=PLRGI9KQ3_HP_OFRG6R-p4iFgMSK1t5BHs
[What is Nix]: https://engineering.shopify.com/blogs/engineering/what-is-nix
[nix expression language tutorial]: https://nixcloud.io/tour/
[nix.dev guide]: https://nix.dev/
[bundix]: https://github.com/nix-community/bundix
[nixpkgs]: https://github.com/NixOS/nixpkgs
[rbenv]: https://github.com/rbenv/rbenv
[docker-on-whales]: https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development
[bundler]: https://bundler.io/
[Go Free Range]: https://gofreerange.com/
[Vagrant]: https://www.vagrantup.com/
[Docker]: https://www.docker.com/
[node.js]: https://nodejs.org/
[execjs]: https://github.com/rails/execjs
[nvm]: https://github.com/nvm-sh/nvm
[JavaScriptCore framework]: https://developer.apple.com/documentation/javascriptcore
[npm]: https://www.npmjs.com/
[github-actions-article]: /blog/2019-09-07-using-github-actions-to-publish-a-static-site-to-github-pages
[Go Free Range website]: https://github.com/freerange/site
[what-is-bundlerenv-doing]: https://fzakaria.com/2020/07/18/what-is-bundlerenv-doing.html
[middleman]: https://middlemanapp.com/
[docker-compose]: https://docs.docker.com/compose/
