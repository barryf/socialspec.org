---
layout: post
created_at: 2026-10-13T07:01:00-07:00
title: Why use .well-known URIs?
description: |
  What are .well-known URIs and why does SocialSpec use them? 
byline:
  name: Caleb Hailey
  username: "@calebhailey.com"
  href: https://calebhailey.com
tags: []
date: October 13, 2026
color: none
---

One of the first things we hope people will notice about the SocialSpec APIs is the URLs: 

```
https://example.com/.well-known/following.opml
https://example.com/.well-known/about.md  
https://example.com/.well-known/contact.vcf
```

Some developers will immediately recognize these as [`.well-known` URIs], while others may be seeing this `/.well-known/` pattern for the first time.
In this post we will explain what `.well-known` URIs are, how they are used, and why we chose them for SocialSpec.

## What are .well-known URIs?

A `.well-known` [URI] is a [URL] that starts with `/.well-known/`.
The `.well-known` URI specification offers the following definition:

> _A well-known URI is a URI whose path component begins with the characters `/.well-known/`, provided that the scheme is explicitly defined to support well-known URIs. For example, if an application registers the name 'example', the corresponding well-known URI on 'http://www.example.com/' would be 'http://www.example.com/.well-known/example'._ 
> 
> &mdash; @rfc-editor.org, [RFC8615](https://www.rfc-editor.org/info/rfc8615/)

RFC8615 says that "Applications that wish to mint new well-known URIs MUST register them", presumably to help avoid conflicts.
There are currently [106 .well-known URIs] registered with the [Internet Assigned Numbers Authority (IANA)]. 
But there also some _well known_ `.well-known` URIs that are not registered, including the [Apple Universal Links] `.well-known/apple-app-site-association` URI that is used to open links in apps instead of in Safari.[^1] 

## How do .well-known URIs work?

When you install Instagram on an Android device, the app contains some information that says "use me to open links to https://instagram.com". 
However, to prevent unofficial apps from claiming an association with Instagram, Android checks a predefined location on Instagram's website to see which app(s) it allows to open links to https://instagram.com.
That predefined location is a `.well-known` URI:

```
https://instagram.com/.well-known/assetlinks.json
```

When the app matches an entry in the .well-known URI, Android saves that association and the next time you tap a link to a post on Instagram, it should open in the Instagram app instead of opening in Chrome.[^2]

## Why use .well-known URIs?

The primary use case for `.well-known` URIs is discovery.
Applications can declare locations they will check for information about a given website, and websites opt-in to support those applications by publishing files at the predetermined `.well-known` URIs. 

When we set out to design APIs for social engagement on the world wide web, we started with a goal: 

> **SocialSpec.org Design Goal**
> 
> Each API should have a **single purpose**, require a **single file**, and be discoverable via a **single request**.

Most websites that could benefit from SocialSpec APIs generally already publish the very same information in HTML format.
And many applications already collect this information using a well-established technique called [web scraping]. 
But web scraping is inefficient, fragile, and increasingly controversial. 

The more we thought about the overwhelming abundance of social information that websites contain &ndash; if not **ubiquity** in the case of `/about` and `/contact` pages &ndash; the more we realized that _discovery_ was the most important problem to be solved. 
And focusing on discovery is what led us to `.well-known` URIs. 

I mean, just look at this @contactspec.org URL:

```
https://example.com/.well-known/contact.vcf
```

There is a lot of information available at a glance in this URL!
The `https:` scheme and `example.com` domain tell you exactly _how_ and _where_ to fetch the data.
The `/.well-known/` path prefix suggests _who_ the intended consumer is (an application).
The `contact` filename suggests _why_ the information is being shared.
And the `.vcf` file extension tells you _what_ the contents are a [Virtual Contact File (VCF) or vCard](https://en.wikipedia.org/wiki/VCard).
Some developers will be able to guess exactly how they can use a @contactspec.org URL without even needing to read [the _very simple_ API specification](https://contactspec.org).
And that is why we chose `.well-known` URIs for SocialSpec: because they are transparent.

We want SocialSpec to be easy to understand and easy to implement.
It should be easy to support SocialSpec APIs on a personal website, regardless of what tools are used.
And it should be easy to implement support for SocialSpec APIs on content management systems with millions of users. 
As SocialSpec API adoption grows, so do the incentives for a new generation of social experiences based on open standards.
As those experiences grow in popularity, so do [the choices for millions of people who are increasingly frustrated with the big social media platforms](/news/introducing-socialspec-dot-org/). 

<!-- Footnotes -->
[^1]: Both the iPhone ([Apple Universal Links]) and Android devices ([Android App Links]) rely on .well-known URIs for opening links to web resources in associated apps.

[^2]: [Apple Universal Links] works the exact same way on iOS. 
      The corresponding .well-known URI for Instagram's Apple Universal Link metadata is https://www.instagram.com/.well-known/apple-app-site-association. 
      We used Android as the primary example because the Android `.well-known/assetlinks.json` URI is registered with @iana.org, and `.well-known/apple-app-site-association` is not (yet).


<!-- Links -->
[rfc8615]: https://www.rfc-editor.org/info/rfc8615/
[URI]: https://developer.mozilla.org/en-US/docs/Glossary/URI
[URL]: https://developer.mozilla.org/en-US/docs/Glossary/URL
[106 .well-known URIs]: https://www.iana.org/assignments/well-known-uris
[Internet Assigned Numbers Authority (IANA)]: https://www.iana.org
[web scraping]: https://en.wikipedia.org/wiki/Web_scraping
[Apple Universal Links]: https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app
[Android App Links]: https://developer.android.com/studio/write/app-link-indexing
[`.well-known` URIs]: https://www.iana.org/assignments/well-known-uris