---
title: Using GitHub Actions to publish a static site to GitHub Pages
description: Automatically build a Middleman-generated site and push it to the gh-pages branch on every push to the master branch
created_at: 2019-09-07 12:57:00 +00:00
updated_at: 2019-09-07 12:57:00 +00:00
---

I recently got access to the new [GitHub Actions](https://github.com/features/actions) functionality and decided to experiment with using it to automatically build and deploy [this site](/).

For the last three years I've been using [Travis CI](https://travis-ci.org/floehopper/jamesmead.org) to automatically build this [Middleman](https://middlemanapp.com/)-generated site and publish it to a [Linode](https://www.linode.com/) VPS using `rsync`, although it has to be said I haven't published much in that time!

Rather than trying to replicate this behaviour exactly using GitHub Actions, I decided to try publishing to [GitHub Pages](https://pages.github.com/); something I've been meaning to do for a while. This will mean I'm a bit closer to being able to get rid of my Linode VPS altogether.

I tried quite a few actions which claimed to do what I wanted, but ran into a few problems. The main problem turned out to be that while the GitHub token which is supplied to an action by default does allow pushing to the `gh-pages` branch, it doesn't allow triggering of a GitHub Pages build; instead you need to generate a [Personal Access Token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line).

In the end I settled on this [GitHub Pages Deploy](https://github.com/marketplace/actions/github-pages-deploy) action with a workflow configured as follows:

    name: Continuous Deployment to GitHub Pages
    on:
      push:
        branches:
          - master
    jobs:
      build:
        name: Build
        runs-on: ubuntu-latest
        steps:
          - name: Checkout repo
            uses: actions/checkout@master
          - name: Setup Ruby
            uses: actions/setup-ruby@v1
            with:
              ruby-version: '2.6.3'
          - name: Install bundler
            run: gem install bundler:2.0.2
          - name: Install bundled gems
            run: bundle install
          - name: Build site
            run: bundle exec middleman build
          - name: Publish site
            uses: maxheld83/ghpages@v0.2.1
            env:
              GH_PAT: ${{ secrets.GH_PAT }}
              BUILD_DIR: ./build

I'm pretty happy with this solution so far, although I don't really understand why this action (and all the others I looked at) *force* pushes to the `gh-pages` branch rather than just pushing. I think it would be nice to have a historic record of the generated HTML in the git repo.
