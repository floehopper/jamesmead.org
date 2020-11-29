---
title: Multiple Rails development environments using nix-shell
description: Four Rails apps using different versions of Ruby, Rails, PostgreSQL and MySQL
created_at: 2020-11-29 12:21:00 +00:00
updated_at: 2020-11-29 12:21:00 +00:00
guid: 4276f4a5-2406-41c9-baba-2bf154e0712b
---

I've continued to make slow but steady progress with my experiment to setup Rails development environments using nix-shell on a Vagrant VM running Ubuntu. I've now got to the stage where I have four Rails apps using combinations of Ruby versions, Rails versions, PostgreSQL versions, and MySQL versions which I'm pretty happy about!

* Ruby v2.5, Rails v5.2.4.4, PostgreSQL v10
* Ruby v2.5, Rails v5.2.4.4, MySQL v5.7
* Ruby v2.6, Rails v6.0.3.4, PostgreSQL v11
* Ruby v2.6, Rails v6.0.3.4, MySQL v8.0

<img style="display: block; margin-left: auto; margin-right: auto; width: 100%;" src="/images/four-rails-apps.png" alt="Four Rails apps">

I've continued to use bash scripts as Vagrant provisioners to do this in a reproducible way, although [the code][rails-on-nix-3c40a3fe] is currently a bit messier than I would like.

### Creating the Rails apps

I've improved the way that `rails new` is run so that it works correctly for different versions of Ruby. The new approach closely based on [this answer][nixos-forums-answer] to a question I asked on the NixOS forums.

Some of the complications around having a suitable environment to run `rails new` for a particular version of Ruby and of Rails has reminded me that I don't have a particularly good solution for this in my current non-Nix MacOS setup.

In fact I tend to do something analagous to what I've done with Nix, i.e. I use `rbenv` to switch to the relevant version of Ruby, create a `Gemfile` containing just a reference to the version of the Rails gem that I want, run `bundle install` and then `rails new`. I'd be interested to hear if anyone has a better/simpler way of doing this.

At this point, it's probably instructive to show you the relevant files for one of the four Rails apps. A `bundler.nix` is used only to run `bundle lock` to generate `Gemfile.lock`. Previously I had been using `bundix` itself to generate `Gemfile.lock`, but I couldn't work out how to do this for different versions of Ruby.

    # Gemfile
    source 'https://rubygems.org'
    gem 'rails', '= 6.0.3.4'

    # bundler.nix
    with (import <nixpkgs> {});
    let
      myBundler = bundler.override { ruby = ruby_2_6; };
    in
    mkShell {
      name = "bundler-shell";
      buildInputs = [ myBundler ];
    }

A `shell.nix` is used to run `bundix` to generate a `gemset.nix` and to run `rails new` using this gemset.

    # shell.nix
    with (import <nixpkgs> {});
    let
      env = bundlerEnv {
        name = "ruby2.6-rails6.0.3.4-mysql8.0";
        ruby = ruby_2_6;
        gemdir = ./.;
      };
    in mkShell { buildInputs = [ env env.wrappedRuby ]; }

Inside the rails app directory there's another `bundler.nix` (exactly the same as the one above) which is again only used to run `bundle lock` and another `shell.nix` which is used both to run `bundix` and to provide the actual development environment including all the relevant dependencies:

    # shell.nix
    with (import <nixpkgs> {});
    let
      env = bundlerEnv {
        name = "ruby2.6-rails6.0.3.4-mysql8.0";
        ruby = ruby_2_6;
        gemdir = ./.;
      };
    in mkShell {
      buildInputs = [ env env.wrappedRuby nodejs yarn mysql80 ];
    }

One other thing I had to deal with to handle Rails v5 was to run `rails yarn:install` instead of `rails webpacker:install` for Rails v6 when initally setting up the app.

### Setting up databases

I've added a [shellHook][nix-shellhook] to the development environment `shell.nix` to configure and run an instance of a database server for each Rails app. I'm now less sure that configuring and running a database on entering the nix-shell is very sensible. I suspect it might make more sense to have a separate script to do this.

This time I've made a couple of changes to improve the level of isolation between the apps. Firstly I've configured each database to store their data in a Rails app sub-directory rather than in a global location. And secondly I've configured each database to only accept connections via a [unix domain socket][] also stored in a Rails app sub-directory.

I managed to achieve the former by moving the Rails apps under the Vagrant user's home directory. This avoided the problem I had previously with hard links in a VirtualBox shared directory. Although this means the Rails app source code is not available from the guest OS, that seems like just a temporary invconvience since I'm only using the Vagrant VM to simulate a fresh machine. Eventually my aim is to run Nix natively and not use Vagrant at all.

I'm particularly pleased with the unix domain socket solution, because it means there's no need to identify an unused port for each Rails app to connect over TCP/IP. Here's the shellHook code for PostgreSQL and MySQL databases:

#### PostgreSQL

    export PGHOST=/home/vagrant/ruby2.6-rails6.0.3.4-postgres11/tmp/postgres
    export PGDATA=$PGHOST/data
    export PGDATABASE=postgres
    export PGLOG=$PGHOST/postgres.log

    mkdir -p $PGHOST

    if [ ! -d $PGDATA ]; then
      initdb --auth=trust --no-locale --encoding=UTF8
    fi

    if ! pg_ctl status
    then
      pg_ctl start -l $PGLOG -o "--unix_socket_directories='$PGHOST' --listen_addresses='''"
    fi

#### MySQL

    MYSQL_HOME=/home/vagrant/ruby2.6-rails6.0.3.4-mysql8.0/tmp/mysql
    MYSQL_DATA=$MYSQL_HOME/data
    export MYSQL_UNIX_PORT=$MYSQL_HOME/mysql.sock

    mkdir -p $MYSQL_HOME

    if [ ! -d $MYSQL_DATA ]; then
      mysqld --initialize-insecure --datadir=$MYSQL_DATA
    fi

    if ! mysqladmin status --user=root
    then
      mysqld_safe --datadir=$MYSQL_DATA --skip-networking &
      while ! mysqladmin status --user=root; do
        sleep 1
      done
    fi

I'm definitely no expert on setting up databases, so if you can suggest any improvements, I'd love to hear from you!

### Summary

I'm pretty happy with where I've got to. It's starting to feel as if I have a solid basis for using Nix to create decent isolated development environments using various versions of Ruby, Rails, PostgreSQL & MySQL on the same machine.

One nice side-benefit is the way dependencies on OS package are made more explicit. And I don't think it would take much more work to have reproducible configurations to share with other developers and/or for use in continuous integration and/or deployments.

As usual the source code is available in [a GitHub repository][rails-on-nix] and there are instructions on how to run it yourself in the [README][rails-on-nix-readme].

### Next steps

* Come up with a better way to manage each database instance, i.e. not in a shellHook - either using a separate script (or possibly using [systemd][]?).

* Use specific patch versions of Ruby or minor versions of Ruby not available in the current set of nix packages. I'm pretty confident this is possible by [pinning the version of nix packages][pin-nixpkgs] or it might be worth investigating [nix flakes][].

* Use specific versions of Bundler. I haven't really looked into this at all yet, because I'm not sure it's a deal-breaker.

* Investigate how hard it is to upgrade a gem in one of these Rails apps, i.e. regenerating the `Gemfile.lock` and `gemset.nix` files.

* Investigate using [direnv in conjunction with nix][direnv-nix] or [lorri][] to seamlessly move between different Rails app directories without having to explicitly enter/exit the relevant nix-shell.

* Investigate using Nix to somehow make Node packages available to the environment in a similar way to Bundix instead of using Yarn directly, i.e. also automatically installing any OS package dependencies.

* Investigate using [Nix home-manager][nix-home-manager] or custom scripting to make it easy to be able to run `rails new` for a specified version of Ruby and Rails.

### Further reading

* This is the third article in a series:
  1. [A simple Rails development environment using nix-shell](/blog/2020-09-10-a-simple-rails-development-environment-using-nix-shell)
  1. [Generating and running a Rails app with PostgreSQL using Nix on Ubuntu](/blog/2020-10-12-generating-and-running-a-rails-app-with-postgresql-using-nix-on-ubuntu)

* [Lightning Introduction to Nix for Developers](https://blog.sulami.xyz/posts/nix-for-developers/) by Robin Schroer.

* [An introduction to nix-shell](https://ghedam.at/15978/an-introduction-to-nix-shell) by Mattia Gheda.

* [Easy Reproducible Development Environments with Nix and direnv](https://medium.com/better-programming/easily-reproducible-development-environments-with-nix-and-direnv-e8753f456110) by Tom Feron.

* [Nix package versions](https://lazamar.co.uk/nix-versions/) by Marcelo Lazaroni. Find all versions of a package that were available in a channel and the revision you can download it from.

* [Man pages for Nix command line tools](https://www.mankier.com/package/nix).

[rails-on-nix-3c40a3fe]: https://github.com/floehopper/rails-on-nix/tree/3c40a3fe195a08dfdec54a50a2b042eae1305b64
[nixos-forums-answer]: https://discourse.nixos.org/t/using-bundlerenv-with-non-default-version-of-ruby-v2-5/8470/4
[nix-shellhook]: https://nixos.org/manual/nix/stable/#description-13
[unix domain socket]: https://en.wikipedia.org/wiki/Unix_domain_socket
[rails-on-nix]: https://github.com/floehopper/rails-on-nix
[rails-on-nix-readme]: https://github.com/floehopper/rails-on-nix/blob/main/README.md
[systemd]: https://systemd.io/
[nix-home-manager]: https://nixos.wiki/wiki/Home_Manager
[pin-nixpkgs]: https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs
[nix flakes]: https://nixos.wiki/wiki/Flakes
[direnv-nix]: https://github.com/direnv/direnv/wiki/Nix
[lorri]: https://github.com/target/lorri/
