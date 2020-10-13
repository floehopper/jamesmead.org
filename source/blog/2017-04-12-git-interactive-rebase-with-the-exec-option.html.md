---
title: Git interactive rebase with the exec option
description: How to detect accidental reintroduction of renamed classes or variables
created_at: 2017-04-12 15:11:00 +00:00
updated_at: 2017-04-12 15:11:00 +00:00
guid: c65af8aa-c296-46f3-984a-fd3759ac8ab4
---

Recently we've been doing a lot of refactoring in GDS' [manuals-publisher][] application. With three of us working on the codebase at the same time and significant renames occurring across the application, it's been tricky to avoid merge conflicts when rebasing our branches.

One tactic we use to help avoid this problem is to ensure that each commit is atomic, i.e. all the tests pass after each commit. This means that when you're rebasing you can use the tests as a check that you've resolved conflicts successfully. A simple way to check this for a branch is to use a command like the following:

    git rebase --interactive master --exec rake

This replays all your commits running the tests after each of them. If the tests fail for any of them, the interactive rebase halts and allows you to put things right before continuing.

It's worth noting that you can use as many `exec` options as you like and you can use any command you like as long as it returns a non-zero exit code when you want the interactive rebase to stop. With this in mind, I've recently taken to using a `grep` command inside an `exec` option to catch the accidental reintroduction of code that's been renamed.

For example, if I know that the class `SpecialistDocument` has been renamed to `Section` in `master` and I'm rebasing my branch against `master`, I can use the following command to ensure that `SpecialistDocument` hasn't been accidentally reintroduced in any of the commits:

    git rebase --interactive master --exec "! grep -R SpecialistDocument *" --exec rake

Note that the `!` inverts the exit code, so that the command as a whole fails if the pattern *is* found in any file thereby stopping the interactive rebase at that point.

I also did something similar to check that my commit notes weren't accidentally still referencing the old class name:

    git rebase --interactive master --exec "! git show | grep SpecialistDocument"

[manuals-publisher]: https://github.com/alphagov/manuals-publisher/
