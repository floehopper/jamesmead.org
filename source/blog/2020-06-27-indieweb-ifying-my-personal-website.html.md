---
title: IndieWeb-ifying my personal website
description: Marking up relevant content with microformats and adding the ability to receive webmentions
created_at: 2020-06-27 18:53:00 +00:00
updated_at: 2020-06-27 18:53:00 +00:00
---

I've been interested in the [IndieWeb][] since [Chris R][] got me interested in it years ago and at various points I've played with a few bits of it on my website, e.g. [OpenID][] and [IndieAuth][]. As part of my efforts to move away from Twitter and Facebook, I recently joined the very friendly [fosstodon.org][] Mastodon instance and I noticed quite a lot of toots about the IndieWeb including one which mentioned the [indiewebify.me][] website which walks you through various levels of IndieWeb "compliance". I've been interested in finding out more about [Webmentions][] for a while and this gave me the motivation I needed to give them a try.

It turns out I had already [become a citizen of the IndieWeb][indieauth-commit], i.e. Level 1 compliance, back in June 2013 and amazingly (to me anyway) that functionality was still working. Level 2 compliance is about publishing on the IndieWeb and Level 3 compliance is about federating IndieWeb conversations.


### Publishing on the IndieWeb

For level 2, the first step was to markup my home page using the [h-card microformat][], not to be confused with the older [hCard microformat][]. I started doing this by creating separate hidden markup, but I was unhappy with the amount of duplication. And so, after faffing about with [middleman][] for a while and discovering its [nested layouts][], I managed to markup some of the existing content to reduce the amount of duplication: [h-card & p-name](https://github.com/floehopper/jamesmead.org/blob/6760dd64e5a3999f19726efa96f46e4d42fd9905/source/layouts/home.html.erb#L2-L6), [p-org, p-job-title, p-locality & p-country-name](https://github.com/floehopper/jamesmead.org/blob/6760dd64e5a3999f19726efa96f46e4d42fd9905/source/index.html.erb#L12-L13) and [u-photo, p-note, u-uid & u-url](https://github.com/floehopper/jamesmead.org/blob/6760dd64e5a3999f19726efa96f46e4d42fd9905/source/index.html.erb#L31-L46). The validator suggested that it was [working OK][h-card-validation]. So far, so good.

<img style="display: block; margin-left: auto; margin-right: auto; width: 80%;" src="/images/h-card-validation.png" alt="h-card validation success">

The next step was to markup my blog posts with the [h-entry microformat][]. This was relatively straightforward to implement now that I had a separate [`blog` layout][h-entry-in-layout] and the validator suggested that it was [working OK][h-entry-validation].

<img style="display: block; margin-left: auto; margin-right: auto; width: 80%;" src="/images/h-entry-validation.png" alt="h-entry validation success">

At this point, I should have added the ability to send Webmentions to other IndieWeb sites, but it's not completely obvious to me how to do this for a static site. I _think_ I could do it by hooking the [`webmention` gem][webmention-gem] into my [GitHub Action-based build][github-action-build], but I decided to skip this step for now given that it's relatively easy to [send a Webmention manually using `curl`][send-webmention-using-curl] and it's not as if I currently blog that frequently!


### Federating IndieWeb conversations

I also decided to skip the steps about posting [replies][indieweb-reply] to other people's posts and adding [reply contexts][indieweb-reply-context] to my own site until I actually want to reply to something someone has written.

However, I did [configure my site to receive Webmentions][webmention.io-config] using the excellent hosted [webmention.io][] service. This was very easy.

I then added some very basic code to [display Webmentions][display-webmentions-commit] at the bottom of each blog post closely based on [Sebastian De Deyne's implementation][sebastiandedeyne-implementation]. For the moment, I'm using JavaScript running on the client-side, but I can see how in time this might lead to putting an unfair load on webmention.io.

A better solution might be to incorporate fetching the latest Webmentions and rendering them in HTML into the automated build, perhaps enhancing them with the latest Webmentions using JavaScript. I think this might be how the [webmention.io Jekyll plugin][] works, but that's a job for another day.

I checked that my website is receiving Webmentions OK by commenting on a blog post using [commentpara.de][]. 🎉🎉

<img style="border: 1px dashed; display: block; margin-left: auto; margin-right: auto; width: 50%;" src="/images/webmention-comment.png" alt="comment added using commentpara.de">

Clearly I haven't yet fully achieved even level 2 IndieWeb compliance, but I'm pleased with what I've done so far and, more to the point, what I've learnt in doing it. I should also mention that I found lots of useful advice in the following articles:

* [Adding webmentions to my blog](https://sebastiandedeyne.com/adding-webmentions-to-my-blog/) by Sebastian De Deyne

* [Displaying Webmentions on my Hugo website](https://www.jvt.me/posts/2019/03/18/displaying-webmentions/) by Jamie Tanna

* [Indieweb Webmentions on Middleman or Jekyll](http://evantravers.com/articles/2019/11/14/indieweb-webmentions-on-middleman-or-jekyll/) by Evan Travers

[IndieWeb]: https://indieweb.org/
[Chris R]: http://chrisroos.co.uk/
[OpenID]: https://en.wikipedia.org/wiki/OpenID
[IndieAuth]: https://indieauth.net/
[fosstodon.org]: https://fosstodon.org/
[indiewebify.me]: https://indiewebify.me
[indieauth-commit]: https://github.com/floehopper/jamesmead.org/commit/7755ead416ed2e39906a1d61f692d0b83be34546
[Webmentions]: https://www.w3.org/TR/webmention/
[h-card microformat]: http://microformats.org/wiki/h-card
[hCard microformat]: http://microformats.org/wiki/hCard
[middleman]: https://middlemanapp.com/
[nested layouts]: https://middlemanapp.com/basics/layouts/#nested-layouts
[h-card-validation]: https://indiewebify.me/validate-h-card/?url=https%3A%2F%2Fjamesmead.org%2F
[h-entry microformat]: http://microformats.org/wiki/h-entry
[h-entry-in-layout]: https://github.com/floehopper/jamesmead.org/blob/b5522b3c2529b93b3dfd07b148ecc3f911d23d4f/source/layouts/blog.html.erb#L2-L19
[h-entry-validation]: https://indiewebify.me/validate-h-entry/?url=https%3A%2F%2Fjamesmead.org%2Fblog%2F2020-03-30-automatic-backup-of-trello-boards-to-s3-using-aws-cdk
[webmention-gem]: https://github.com/indieweb/webmention-client-ruby
[github-action-build]: /blog/2019-09-07-using-github-actions-to-publish-a-static-site-to-github-pages
[send-webmention-using-curl]: https://indieweb.org/webmention-implementation-guide#One-liner_webmentions
[indieweb-reply]: https://indieweb.org/reply
[indieweb-reply-context]: https://indieweb.org/reply-context
[webmention.io]: https://webmention.io/
[webmention.io-config]: https://github.com/floehopper/jamesmead.org/blob/6760dd64e5a3999f19726efa96f46e4d42fd9905/source/layouts/layout.html.erb#L33
[display-webmentions-commit]: https://github.com/floehopper/jamesmead.org/commit/6760dd64e5a3999f19726efa96f46e4d42fd9905
[webmention.io Jekyll plugin]: https://github.com/aarongustafson/jekyll-webmention_io
[commentpara.de]: https://commentpara.de/
[sebastiandedeyne-implementation]: https://sebastiandedeyne.com/adding-webmentions-to-my-blog/#displaying-webmentions-on-post-pages
