---
title:  "Setting up a Blog"
date:   2022-04-08 12:54:19 +0000
categories: technology web
tags: jekyll github

layout: post
twitter: true
---

What I wanted:

1. The ability to typeset mathematics.
2. The ability to easily add charts and graphs.
3. Very low headache management tools. I particularly did not want to be writing everything in HTML.
4. The ability for it to thrive on neglect and still look and behave basically the same.
5. HTTPS.

In addition I had a few nice-to-haves:

<ol start="6">
  <li>The ability to work mostly in markdown or $\LaTeX$.</li>
  <li>The ability to tinker with it and play around.</li>
  <li>Relatively scalable so that I wouldn't have to ever go back and redo it because I "outgrew" it in terms of sophistication of the posts or something else.</li>
  <li>Very, very low price such that if I forget about it for a while I won't feel like I am wasting money.</li>
</ol>

I've set up (quite a few) Wordpress and a few other equivalent blogs over the years and they are all fine for what they are, but they failed horribly at most of these criteria.

I also _do_ have a github account, so why not try [pages](https://pages.github.com/) out?

## Thus Our Journey Begins

So there are a variety of hacks—most of which are quite old—for typesetting equations into github pages.

There have been various attempts at doing this with MathJax or by directing `img`s to [unsupported URLs](https://gist.github.com/a-rodin/fef3f543412d6e1ec5b6cf55bf197d7b), some strategies in that genre almost-sort-of-kind-of-work, but most of which are not what I would describe as "straightforward."  Some would work for a page or two, but became difficult to extend past that. Virtually none were set up for modern versions of MathJax.

So my first pass was to do it in the most complicated way possible: Why not just use latex directly in a prebuilt container on gitpod?

I loaded up the [guide from 2019](https://www.gitpod.io/docs/languages/latex) and the guide for getting started with github pages, built a docker container, and we're good to go, right?

<blockquote class="twitter-tweet" data-theme="dark"><p lang="
en" dir="ltr">i learned to code by writing html in notepad and dragging the file into an FTP client. I wouldn&#39;t even know where to start today. <a href="https://t.co/MxQgOUzChE">https://t.co/MxQgOUzChE</a></p>&mdash; Owen Williams ⚡ (@ow) <a href="https://twitter.com/ow/status/1256203966389587970?ref_src=twsrc%5Etfw">May 1, 2020</a></blockquote>

### Timeouts, Compile Errors, and Typos oh my

Turns out that downloading `texlive-full` requires downloading about two thirds of the internet and that gitpod really doesn't like prebuilds taking over an hour.  So that's exciting and also difficult to debug, because it doesn't come out and _tell_ you that like a good process, it just kind of lets you infer it. Especially if you want to download anything _after_ that, things can get pretty exciting.

It also turns out that ruby versions matter for compiling and that there were a variety of path weirdness from me not quite understanding how to execute the ruby code within gitpod as part of a dockerfile. Suffice it to say just doing this:

```docker
RUN gem install bundler
```

…did not do what I wanted nor expected.

Gitpod, for its part, was mostly generating errors that looked like this:

```console
Prebuild failed for system reasons. Please contact support. Error: headless task failed: exit status 1
```

With no real tangible logs to speak of to let me know what happened, and things often getting conflated with what looks like the timeout.

My first instinct, of course, is that I need to install ruby, so I give that a shot:

```docker
RUN brew install ruby
```

This has two main effects:

1. It makes the build take longer, further exacerbating the timeout.
2. It does not, in fact, solve my problem with bundler.

Eventually I give up and go "I'll find some other way to manage it temporarily" and pull out all of the $\LaTeX$ pieces, since those seem to be obscuring anything else going on. "I'll just get this set up with jekyll first, and then I'll circle back to $\LaTeX$ if necessary," I think.

Now having solved my timeout issue, it's easier to debug my ruby problems—it can't find `gem`—and I find someone else's solution to that:

```docker
FROM gitpod/workspace-full

RUN echo "rvm_gems_path=/home/gitpod/.rvm" > ~/.rvmrc

USER gitpod

RUN /bin/bash -l -c "gem install jekyll"
RUN /bin/bash -l -c "gem install bundler"
```

Okay, _that_ works. If that didn't work I've also seen people put the gem commands into a gitpod `init`, which also seems to work okay.

Now I can go and initialize the repository.

I quickly get it set up and running with the [midnight](https://github.com/pages-themes/midnight) theme, which looks pretty at first glance and we're off to the races.

### Except going the wrong direction

A few things become quickly apparent:

1. Github pages depends on an [old (ancient?) version of jekyll](https://github.com/github/pages-gem/issues/651) and doesn't look like it will… ever… get updated.
2. The [list of supported plugins](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll#plugins) is very short.
3. Midnight is an awfully… bare bones… theme. It doesn't really support my use case without significant customization.  It only has a default template, and that's pretty minimalistic. It doesn't even support the initial generated file types.

Hunting around for this I find a lot of people really like `jekyll-spaceship` and it does pretty much everything I need… and it is [not going to get allowlisted any time soon](https://github.com/github/pages-gem/pull/688).  I first find this by trying to compile:

```latex
\vdash \frac{1}{2}
```

Which it renders for me as $\vdash \frac{1}{2}$ on my local system but on pages just shows up as source code on an unthemed page.

But there is a solution to this: Because jekyll is just a static page generator, we can run it as part of a [github action](https://github.com/marketplace/actions/jekyll-deploy-action).  That way we'll generate it when pushing to `main`.

Perfect.

### Gang aft agley

Turns out there is a conflict between the github pages plugin and the version of jekyll I want to use. No big deal, I'll just pull the information out of the system and…

Wait, what do you mean all of my text is now completely without a template?

I try various things to circumvent this problem—including using the remote template plugin and downloading it locally—but it turns out that this is a consequence of two things:

1. The presence of the plugins `jekyll-default-layout` and `jekyll-optional-front-matter`. These were probably done to make life easier for beginners setting up sites, but what it meant in practice was that not all of the (generated! dowloaded!) files actually had any template information associated with them, and in some cases just flat out failed to do anything productive.
2. Because the template only has `default` as a base, it doesn't include… `post`, or `home`, or, well, anything.

While (1) is an easy fix (just add the information), there seems to be no way around (2) with this template short of writing everything from the ground up.

But it is enough to get the github action working. This takes a few false starts due to some confusion about branches, but it was actually remarkably straightforward to set up.  Good job to the creator of the action and to the github actions team.

### The hunt begins for a theme

Okay, so next stop is to find a template that will… actually… work. The theme world is a horrid mess and while pages like [Jekyll Themes](https://jekyllthemes.io/) exist they lack really any sort of search functionality adequate to find what I am looking for.

So  I find one that seems to look reasonable, eventually, plug it in and…

…what do you mean there are **more** files that I need?

So it turns out that while a good chunk of the theme is in the `gem`, there's also a good bit in a default project that they have to jump start things.  

There is no easy way, with jekyll, to bring down the files that I can find.  People are recommending strategies like bringing down everything into a clean detached branch and fixing a bunch of merge conflicts.

I solve this by copying it over and copying the files more-or-less by hand, which isn't too bad given the new project state.

That works reasonably well, so I do a bit of mucking around with the configuration—adding CDNs or changing which CDN was used, altering a few versions, tweaking the fonts, etc.

Things look good—I can now compile things like $\frac{x:{\mathbf T} \in \Gamma}{\Gamma \vdash x:T}$, so I deploy and call it a day.

<blockquote class="twitter-tweet" data-theme="dark"><p lang="en" dir="ltr">I have abandoned installing jekyll and am now making a geocities website</p>&mdash; zachary (@chetchavat) <a href="https://twitter.com/chetchavat/status/1096290876668739585?ref_src=twsrc%5Etfw">February 15, 2019</a></blockquote>

