---
title: Automatically sending Webmentions from a static website
description: Using Actionsflow to automate the sending of Webmentions using webmention.app
created_at: 2020-10-13 08:29:00 +00:00
updated_at: 2020-10-13 08:29:00 +00:00
guid: e3390a6e-2423-4fe8-8089-7b12c3c8c3e9
---

A few months back I wrote about [indieweb-ifying this website][]. I attempted to follow the excellent [indiewebify.me guide][], but I skipped step 2 of Level 2, i.e. [adding the ability to send Webmentions to other IndieWeb sites][level2-step2]. My [excuse][level2-step2-excuse] at the time was:

> I decided to skip this step for now given that it's relatively easy to [send a Webmention manually using `curl`][send-webmention-using-curl] and it's not as if I currently blog that frequently!

Anyway a couple of recent discoveries led me to fix this omission...

### webmention.app

This lovely little [service][webmention.app] built by [Remy Sharp][], not to be confused with [webmention.io][] which is used for _receiving_ incoming [Webmentions][], makes it easy to _send_ outgoing webmentions for all the links on a given page:

> This is a platform agnostic service that will check a given URL for links to other sites, discover if they support webmentions, then send a webmention to the target.

Fortunately I still have an [RSS feed][] for my blog and in this case the documentation [suggests using IFTTT][] to automate doing this each time you publish an article.

### Actionsflow

Somewhat serendipitously I recently came across [Actionsflow][] which is a free Zapier/IFTTT alternative for developers to automate workflows based on GitHub Actions.

I have to admit that I was initially quite confused by the Actionsflow documentation and I tried to add my Webmention-sending workflow to [the repo for this website][website-repo]. However, once I realised the idea was to [create a new repo][] based on a template, things became a little clearer.

### Workflow to send Webmentions

I created [this repo][send-webmentions-repo] and added [this workflow][send-webmentions-workflow] to poll my RSS feed and send an HTTP POST request to the webmention.app API for every new item. I was pleasantly surprised by how simple this was:

    name: Send webmentions for new blog posts
    on:
      rss:
        url: http://feeds.jamesmead.org/floehopper-blog
        config:
          logLevel: debug
          limit: 1
    jobs:
      send_webmentions:
        name: Send webmentions
        runs-on: ubuntu-latest
        steps:
          - name: 'Send webmentions for RSS item link'
            uses: actionsflow/axios@v1
            with:
              url: https://webmention.app/check/
              method: 'POST'
              params: '{ "url": "${{on.rss.outputs.link}}", "token": "${{ secrets.WM_TOKEN }}" }'
              is_debug: true

It took me a while to realise that the underlying Actionsflow GitHub Action was running every 5 minutes and _polling_ my RSS feed. It seems to use the GitHub Action cache to "remember" which items it has seen before. Since I don't publish blog posts very often, polling every 5 minutes seemed a bit excessive and so I decided to [reduce the frequency to hourly][reduce-frequency].

### Observations

* I'm not sure I like the design of Actionsflow which means creating a new repo, but perhaps this would make more sense to me if I had more than one workflow. I suppose this repo is roughly equivalent to a single IFTTT account.

* Over the course of the last year I've automated some backup jobs for [Go Free Range][] using the [`ScheduledFargateTask` class][ScheduledFargateTask] in the [AWS CDK][] to fire up a container and run a script on a cron schedule. This has worked really well, but it's quite tempting to port these over to Actionsflow so we don't have to maintain anything other than the `Dockerfile` and associated shell scripts.

* webmention.app is really nicely implemented with good documentation; it's a classic example of an elegant solution to a tightly scoped problem. Since I'll be making use of the API on a regular basis, I decided to [buy Remy a drink][] to say thank you!

* I'd also like to find a way to say thank you to [Aaron Parecki][] who built webmention.io and [Ryan Barrett][], [Kyle Mahan][], et al who built [brid.gy][]. However, I can't see a way to do either and, indeed, the latter [explicitly say][brid.gy-cost] "We don't need donations, promise."


[indieweb-ifying this website]: https://jamesmead.org/blog/2020-06-27-indieweb-ifying-my-personal-website
[indiewebify.me guide]: https://indiewebify.me/
[level2-step2]: https://indiewebify.me/#send-webmentions
[level2-step2-excuse]: https://jamesmead.org/blog/2020-06-27-indieweb-ifying-my-personal-website#publishing-on-the-indieweb
[send-webmention-using-curl]: https://indieweb.org/webmention-implementation-guide#One-liner_webmentions
[Remy Sharp]: https://remysharp.com/
[webmention.app]: https://webmention.app/
[RSS feed]: http://feeds.jamesmead.org/floehopper-blog
[suggests using IFTTT]: https://webmention.app/docs#using-ifttt-to-trigger-checks
[Actionsflow]: https://actionsflow.github.io/docs/
[website-repo]: https://github.com/floehopper/jamesmead.org
[create a new repo]: https://github.com/actionsflow/actionsflow-workflow-default/generate
[send-webmentions-repo]: https://github.com/floehopper/send-webmentions
[send-webmentions-workflow]: https://github.com/floehopper/send-webmentions/blob/main/workflows/send-webmentions.yml
[reduce-frequency]: https://github.com/floehopper/send-webmentions/commit/eb5a9cb573b1c532c92143b7fb2aed260c5fa552
[webmention.io]: https://webmention.io/
[Webmentions]: https://indieweb.org/Webmention
[ScheduledFargateTask]: https://docs.aws.amazon.com/cdk/api/latest/typescript/api/aws-ecs-patterns/scheduledfargatetask.html#aws_ecs_patterns_ScheduledFargateTask
[Go Free Range]: https://gofreerange.com
[AWS CDK]: https://aws.amazon.com/cdk/
[buy Remy a drink]: paypal.me/rem
[Aaron Parecki]: https://aaronparecki.com/
[brid.gy]: https://brid.gy/
[brid.gy-cost]: https://brid.gy/about#cost
[Ryan Barrett]: https://snarfed.org/
[Kyle Mahan]: https://kylewm.com/
