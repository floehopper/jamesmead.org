--- 
permalink: debugging-monit
created_at: 2011-01-20 17:10:32 +00:00
updated_at: 2011-01-20 17:10:32 +00:00
title: Debugging Monit
description: Notes on debugging monit start program and stop program commands.
keywords: monit linux osx
guid: 46a1d9f1-20a5-487a-87de-72cce418122d
---

At [GoFreeRange](http://gofreerange.com) I recently spent some time debugging a couple of [Monit](http://mmonit.com/monit/) `start program` and `stop program` commands, so I thought I'd share some notes I made in case they're of use to anyone else.

Although we mainly deploy to [Ubuntu](http://www.ubuntu.com/), I wanted to be able to debug the commands on my local [OSX](http://www.apple.com/macosx/) machine. I found I could run Monit in non-daemon mode with verbose logging enabled, but it doesn't show the stdout/stderr generated when it runs your `start program` or `stop program` commands. So it seems the best you can do is to create an environment that mimics the Monit environment and try running the commands from there.

According to the [documentation](http://mmonit.com/monit/documentation/monit.html), the Monit process runs as superuser and has only a very limited set of environment variables. Notably it only has the following `PATH` set: `/bin:/usr/bin:/sbin:/usr/sbin`.

In our automated [provisioning](https://github.com/freerange/freerange-puppet) and [deployment](https://github.com/freerange/deploy) solution, we use a [Brightbox Ruby Enterprise Edition package](http://wiki.brightbox.co.uk/docs:ruby-enterprise) which *replaces* the existing system [Ruby](http://www.ruby-lang.org/), so the default Monit `PATH` is enough to find the Ruby binaries.

We use [Bundler](http://gembundler.com/), so we need to have the `bundler` gem installed as a system gem in the default Ruby. We use `bundle install` with the `--path` option to install project gems into a directory under the [Capistrano](https://github.com/capistrano/capistrano) shared directory. This means that at environment load time the `bundler` gem finds the project gems based on the `BUNDLE_PATH` specified in the project's `.bundle/config`. The advantage of this is that this takes care of adding any `PATH`s to gem binaries and again we can manage with just the default Monit `PATH`.

Next I created a `monitrc` containing the `start program` and `stop program` commands and put it in my local project root. Note that we run the commands as a specified user and group (`run_as_username` & `run_as_group`) :-

    check process myprocess
      with pidfile /Users/myusername/myproject/log/myprocess.pid
      start program = "/usr/bin/env RAILS_ENV=development /bin/sh -c \
        'cd /Users/myusername/myproject/ && script/daemon script/myscript start'" \
        as uid run_as_username and gid run_as_group
      stop program = "/usr/bin/env RAILS_ENV=development /bin/sh -c \
        'cd /Users/myusername/myproject/ && script/daemon script/myscript stop'" \
        as uid run_as_username and gid run_as_group

Since Monit is run as superuser, I found I needed to change the ownership of this `monitrc` file so the Monit process could read it :-

    $ sudo chown root:wheel /Users/myusername/myproject/monitrc

We try to use a standard daemon mechanism for all our background processes and so we put all the `pid` files in the log directory under the Capistrano shared directory (the project log directory in development). I found I needed to change the ownership for my local log directory to match the `run_as_username` & `run_as_group` so that it can write and delete the `pidfile` :-

    $ sudo chown run_as_username:run_as_group /Users/myusername/myproject/log

At this point I was in a position to run the `start program` command either directly in a shell environment mimicking the Monit environment or by running Monit itself. I achieved the former as follows :-

    $ sudo su
    $ env -i PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/sh
    $ su run_as_username
    $ /usr/bin/env RAILS_ENV=development /bin/sh -c \
      'cd /Users/myusername/myproject/ && script/daemon script/myscript start'
    Running daemon command 'start' for 'script/myscript' with app name 'myscript'
    $ /usr/bin/env RAILS_ENV=development /bin/sh -c \
      'cd /Users/myusername/myproject/ && script/daemon script/myscript stop'
    Running daemon command 'stop' for 'script/myscript' with app name 'myscript'

This meant I could see stdout/stderr and diagnose any problems. Note that in my case I had to [create a new user and group](/blog/2011-01-20-adding-a-user-in-osx-on-command-line) for `run_as_username` & `run_as_group`. Once this was working, I was able to run Monit as follows :-

    $ sudo su
    $ env -i PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/sh
    $ /usr/local/bin/monit -c /Users/myusername/myproject/monitrc -v

You should see Monit trying to start `myprocess` and checking for the existence of the `myprocess.pid` file. If this doesn't work, it will eventually timeout.
