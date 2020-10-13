---
title: Generating and running a Rails app with PostgreSQL using Nix on Ubuntu
description: Isolating a Nix environment by running on an Ubuntu VM provisioned by Vagrant
created_at: 2020-10-12 20:20:00 +00:00
updated_at: 2020-10-12 20:20:00 +00:00
guid: c31f4da5-1cbb-4843-90f3-30075869abc3
---

In my first attempt at setting up [a simple Ruby development environment][simple-ruby], I was quite careful to make sure the Nix shell environment wasn't accidentally relying on anything available from the underlying environment. In particular, I noticed that unless I specifically added `nodejs` to the list of `buildInputs`, middleman ended up using the Node version in the _underlying_ MacOS environment.

However, in my second attempt where I set up [a simple Rails development environment][simple-rails], I wasn't so careful and [I didn't do the same checks on the run-time dependencies][runtime-dependencies-update].

### Ubuntu VM on Vagrant

Previously, in order to ensure full isolation, I ended up editing my "dot" files and even modifying environment variables in the current shell, but this was fiddly and error prone. So this time I decided to setup a completely seperate VM running Ubuntu Xenial (with minimal OS packages) using Vagrant to continue with my Nix experiments.

Furthermore I decided to try to write a provisioning script for the Vagrant configuration to create a new Rails app from scratch and to complete all the steps necessary for getting both the Rails tests and the Rails server running. By doing it this way, I could easily snapshot the VM and restore the snapshot or even destroy the VM and build it again to get back to a clean slate. I found this a really productive way to tackle the problem.

### Installing Nix

First I had to install Nix on the Ubuntu VM. I used the [Nix multi-user installation instructions][nix-installation] to write an inline provisioning script in the `Vagrantfile` and I even worked out how to make the script idempotent:

    nix --version
    if [ $? -eq 0 ]; then
      echo 'nix is already installed (skipping installation)'
    else
      sh <(curl -L https://nixos.org/nix/install) --daemon
    fi

### Generating a new Rails app

Next I created a nix-shell configuration that made the Rails gem specified by the "outer" `Gemfile` available:

    nix-shell -p ruby_2_6 bundler bundix --run 'bundle lock && bundix --init --ruby=ruby_2_6'

Much like in my [previous article][simple-ruby], this generated the following files in the "outer" directory:

* `Gemfile.lock`
* `gemset.nix`
* `shell.nix`

Now that this nix-shell specified by `shell.nix` made the Rails gem available, I used it to generate a new Rails app in a subdirectory with the `rails new` command:

    nix-shell --run 'rails new my-rails-app --skip-bundle --skip-webpack-install --database=postgresql'

This step created a vanilla Rails app in the `my-rails-app` subdirectory. Note that I chose to skip the `bundle install` and `rails webpacker:install` steps, because at this point the nix-shell could not provide everything necessary.

### Bundled gems

I felt as if generating the Rails app was separate from setting up and running it and so I decided to create a separate nix-shell within the "inner" subdirectory. This was achieved much as before, but this time based on the "inner" `Gemfile` generated as part of the new Rails app:

    cd my-rails-app

    nix-shell -p ruby_2_6 bundler bundix --run 'bundle lock && bundix --init --ruby=ruby_2_6'

This generated the following files in the subdirectory:

* `Gemfile.lock`
* `gemset.nix`
* `shell.nix`

### Runtime dependencies

While the `shell.nix` file in combination with the `gemset.nix` would make the bundled gems and their dependent OS packages available within the nix-shell, I also needed to add some runtime dependencies (`nodejs`, `yarn` & `ruby_2_6`) for subsequent steps by adding them to the list of `buildInputs` in `shell.nix`:

    buildInputs = [ env nodejs yarn ruby_2_6 ];

### PostgreSQL package

Having specified PostgreSQL as the database when I generated the Rails app, I wanted to setup and start a PostgreSQL server in the nix-shell development environment. So I also added the postgresql package to the list of `buildInputs`:

    buildInputs = [ env nodejs yarn postgresql ruby_2_6 ];

### Webpacker

The "inner" nix-shell was now ready to install webpacker using the `rails webpacker:install` command.

    nix-shell> rails webpacker:install

Running the "inner" nix-shell for the first time resulted in the bundled gems and their OS dependencies being installed along with runtime dependencies mentioned above. I found it pretty cool seeing that e.g. the `libxml2` OS package was automatically installed just because `nokogiri` was in the bundled gems!

### PostgreSQL server

I wanted a PostgreSQL database server to be available, but only from _within_ the nix-shell, i.e. not system-wide. To this end I added a [`shellHook`][nix-shellhook] to `shell.nix` to idempotently configure the server and start it when entering the nix-shell:

    shellHook = ''
      export PGHOST=$HOME/postgres
      export PGDATA=$PGHOST/data
      export PGDATABASE=postgres
      export PGLOG=$PGHOST/postgres.log

      mkdir -p $PGHOST

      if [ ! -d $PGDATA ]; then
        initdb --auth=trust --no-locale --encoding=UTF8
      fi

      if ! pg_ctl status
      then
        pg_ctl start -l $PGLOG -o "--unix_socket_directories='$PGHOST'"
      fi
    '';

I set the database server up with minimal security to make it easy to access from `psql` and so the generated `database.yml` would just work out of the box.

### Rails development environment

By this stage, the nix-shell Rails development environment was pretty much ready to go. To make things slightly more interesting, I decided to create the canonical simple Rails "blog" app using the `rails generate scaffold` command:

    nix-shell> rails generate scaffold post title:string content:text

I then created and migrated the development and test databases for the Rails app in the usual way:

    nix-shell> rails db:create
    nix-shell> rails db:migrate

And ran the Rails tests as follows:

    nix-shell> rails test

And finally, the moment of truth (!), I ran the Rails server and opened a browser at the home page 🚀:

    nix-shell> rails server --binding 0.0.0.0 --daemon
    nix-shell> open http://localhost:3000/


<img style="display: block; margin-left: auto; margin-right: auto; width: 80%;" src="/images/rails-welcome.png" alt="Rails welcome page">

The blogging functionality was also accessible at [the relevant endpoint][local-rails-posts] and seemed to persist new posts successfully.

### Trying it yourself

If you want to follow along at home, I've published the source code in [a GitHub repository][rails-on-nix]. The steps I've described above are documented in the [README][rails-on-nix-readme] and the corresponding code is in a couple of inline provisioning scripts within the [`Vagrantfile`][rails-on-nix-vagrantfile].

### Observations

* Very belatedly, I came across the `--pure` option for nix-shell which might've been a simpler way to isolate my development environment. However, [the documentation][nix-shell-docs] says: "Note that `~/.bashrc` and (depending on your Bash installation) `/etc/bashrc` are still sourced, so any variables set there will affect the interactive shell." The latter was the main source of my previous isolation woes, so perhaps it wouldn't have helped that much after all.

* Initially I wanted to have the database-related directories *within* the Rails app project directory, but it turned out I couldn't do this because VirtualBox doesn't allow hard links within shared directories (at least not on MacOS). And so I put them in the user's home directory instead. If I was doing this "for real", I wouldn't be on a VirtualBox VM and so putting them in the Rails app project directory wouldn't be an issue.

* I decided not to worry about shutting down the database server when exiting the nix-shell, but I believe this would be fairly straightforward using the Linux `trap` command.

* I discovered that in Nix Ruby packages the Rails gem is [fixed at v4.2.11.1][rails-in-nix-ruby-packages]. I didn't want to use such an old version and so I ended up using Bundler and Bundix in conjunction with a `Gemfile` to make a newer version of Rails available. If the version in Nix Ruby packages was more up-to-date, I believe I could have used something much simpler, e.g.

^
    nix-shell -p 'ruby_2_6.gems.rails' --run 'rails new my-rails-app --skip-bundle --skip-webpack-install --database=postgresql'

### Next steps

* Multiple Rails app with different database types and versions. This is really the core issue I'm trying to solve by setting my development environment up using Nix.

* Investigate using Nix to somehow make Node packages available to the environment in a similar way to Bundix instead of using Yarn directly, i.e. also automatically installing any OS package dependencies.

* Investigate using [Nix home-manager][nix-home-manager] to provide a more generic environment on the VM to create the Rails app, i.e. to be able to run `rails new`.

### Further reading

* Someone on the Nix forums pointed me at [this Ruby guide for Nix][nix-ruby-guide] which for some reason hasn't been incorporated into the main Nix documentation.

* At various points I've found it useful to dive into the source code of the [Nix Ruby modules][]. This was particularly useful when I was trying to understand how Bundix worked.

[simple-ruby]: /blog/2020-07-26-a-simple-ruby-development-environment-using-nix-shell
[simple-rails]: /blog/2020-09-10-a-simple-rails-development-environment-using-nix-shell
[runtime-dependencies-update]: /blog/2020-09-10-a-simple-rails-development-environment-using-nix-shell#runtime-dependencies-update
[nix-installation]: https://nixos.org/manual/nix/stable/#sect-multi-user-installation
[rails-on-nix]: https://github.com/floehopper/rails-on-nix
[rails-on-nix-readme]: https://github.com/floehopper/rails-on-nix/blob/main/README.md
[rails-on-nix-vagrantfile]: https://github.com/floehopper/rails-on-nix/blob/main/Vagrantfile
[nix-shellhook]: https://nixos.org/manual/nix/stable/#description-13
[rails-in-nix-ruby-packages]: https://github.com/NixOS/nixpkgs/blob/e0c48efc170866a8889b6b758aac10e6d04a4d9b/pkgs/top-level/ruby-packages.nix#L1893-L1903
[nix-shell-docs]: https://nixos.org/manual/nix/stable/#name-2
[nix-home-manager]: https://nixos.wiki/wiki/Home_Manager
[nix-ruby-guide]: https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/ruby.section.md
[Nix Ruby modules]: https://github.com/NixOS/nixpkgs/tree/master/pkgs/development/ruby-modules
[local-rails-posts]: http://localhost:3000/posts
