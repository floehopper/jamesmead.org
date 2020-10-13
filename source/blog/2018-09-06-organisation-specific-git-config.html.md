---
title: Organisation-specific git config
description: Using conditional includes in your git configuration
created_at: 2018-09-06 17:52:00 +00:00
updated_at: 2018-09-06 17:52:00 +00:00
guid: a186486d-172a-40c8-83d2-0ed9d3365041
---

Recently I wanted to use a different email address in the configuration for my `git` user, but only when working on repositories relating to a particular client. I've always tended to organise my local repositories by user and organisation as follows:

    ~/Code
    ├── organisation-1
    │ ├── repository-1
    │ └── repository-2
    ├── user-1
    │ ├── repository-1
    │ └── repository-2
    ├── organisation-2
    │ ├── repository-1
    │ └── repository-2
    └── user-2
      ├── repository-1
      └── repository-2

So I was pleased to discover that [`git` has supported conditional configuration since v2.13.0][1] and I've used a [conditional include][2] to load an organisation-specific configuration file if the repository is under the relevant organisation directory. In this included configuration file I then override the user email address.

    # ~/.gitconfig

    [includeIf "gitdir:~/Code/organisation-1/"]
      path = ~/.gitconfig.organisation-1.inc

    # ~/.gitconfig.organisation-1.inc

    [user]
      email = james.mead@organisation-1.com

The `gitdir` "variable" is the path to the `.git` directory for the repository. You can also use the usual glob wildcards in the right-hand side of the condition if you want to do more sophisticated matching.

[1]: https://blog.github.com/2017-05-10-git-2-13-has-been-released/#conditional-configuration
[2]: https://git-scm.com/docs/git-config#_conditional_includes
