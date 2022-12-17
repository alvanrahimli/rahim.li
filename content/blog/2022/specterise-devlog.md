+++
title = "Specterise Devlog"
date = "2022-12-17T13:30:29+04:00"
tags = ["startup","devlog","rant","update","yearly"]
+++

Hi all! 

Today, I'm planning to write a relatively lengthy post about the startup we've been working on, for about 4 months now.

## Ideation
As you probably know (I've been talking about these in earlier posts), we were working on two different startups in late 2021 and early 2022. 

After having quite a bit of difficultues regarding finding funds, monetizing it, having go-to-market strategy, launching in time and other factors, we sadly declared those startups' (iVolt.energy & bilgin.az) failure.

![Declaring failure of iVolt.energy](/images/2022/ivolt-declaring-failure.png "Samir's and my messages, saying we don't regret any effort we had put into iVolt's implementation and appreciating each other for this good run")
_I actually keep this screenshot in my backup drive :D_

Anyways, after this emotional (maybe a little bit cringe, idk) occasion, I had a little break from startup stuff. In the meantime, I started working at bp, did some reading etc. Also I coded less, to prevent burnout, lol.

Some time passed, I saw Samir doing research and trying to find a new idea to work on. I joined to this search, but been contributing relatively less, probably because I don't like the process of researching unknown things :D. But, thankfully Samir is quite good at this, and he had been putting a lot of effort to this, to finally came up with an idea! (not yet specterise)

He had seen a turkish startup, called [Cameralyze](http://cameralyze.com/). They analyze video footages with AI and users can create pipelines to process this data. But seems like they have pivoted to Serverless AI SaaS, which is great market too. 

So, we started thinking on "analyzing video streams" topic and gradually formed the idea of specterise. It was going to be a platform, where users can connect their CCTV cameras and get analytics and real-time notifications based on what is happening in them.

## Specterise
To summarize, **[Specterise](https://specterise.com)** is a software that provides customer behavior analytics and real-time notifications to managers by analyzing place's existing CCTV camera footage. 

Yes indeed! I personally think this is quite good sounding and cool startup to do, also this is B2B market, which Samir and I wanted to do business in.

### SABAH.Lab
While forming this idea, we were in-touch with guys from [SABAH.lab](https://www.sabahlab.edu.az/) and wanted to join this acceleration. Firstly because they got great perks, like mentorship, some amount of money to spend on, working place etc. So, we went for it and finally got accepted. 

In days of SABAH.lab, we faced with some deadlines! This actually was what we wanted, as being close friends and having less experience/time to spend on the project, we knew if we were not responsible enough, this project would fail too. So, we took SABAH.lab's mentoring seriously and started working on the platform. 

In first couple of weeks, we fully formed the idea, talked with competitors in foreign markets and did quite a bit of progess. Guess what is missing! - Development!

Now it was time to, well, actually **coding** promises that we gave in our presentation.

## Development - Planning
For this project, I had a lot of thoughts. I didn't know which stack we'll be using. I knew dotNet well enough, Angular a bit, and these are all. There are golang etc, but I was not ready to use them for production. So, I took a paper and a pen, started drawing rectangles, hoping I'll decide on tech stack.

My constraints were:
- It needed to be fast to develop with. 
- UI framework should be easy for me and again, fast to develop with.
- I was going to use OpenCV to process footages, it should be easy to use
- We were going to have a lot of charts and graphs. This constraint was telling me to use some JS framework, as [there probably are some lib for this](https://www.npmjs.com/package/is-odd).
- It needed to be dotNET :D

So, looking at these constraints, you can tell the obvious answer is dotNET. Well, I'm somewhat proficent with it and I got inspired by the project we are writing at bp right now. 

## Development - The fun part
So, these are what Specterise needed to do:
- Get video stream from camera using OpenCV
- Send the frame to AI service, get coordinates of rectangles for every person in frame
- Somehow track people across frames (in future, cameras, more on this later)
- Draw heatmap on camera frame, to show on dashboard
- Detect people coming in and going out, and record this to show historical graphs
- Persist all of these data, to make reports, etc
- Be scalable, so we can plug new services, new calculations that will provide new data, functionality and so on.

By reading these, you can tell there is some processing order for this. You get data (location of people in frames), do calculation in multiple steps, and every step will have separate property to add this data. So it is like a pipeline of data. It starts as a frame at camera, and ends up as a processed data in our database.

Lucky me, there were an [amazing library - Berberis](https://github.com/azixaka/Berberis), written by a teammate of mine to do exactly this and I was already familiar with this lib. 

### Choosing AI service
Now it was time to find the AI. As a so-called web developer, I didn't know much about AI, so, had to do some research. My search queries was like: "self hosting ai service", "object detection self host", "object detection github", etc :D. 

After some time, I stumbled upon a thing called [DeepStack](https://www.deepstack.cc/). People are using this for their CCTV camera systems, so this had to be nicely trained model. Because we are also analyzing CCTV cameras, which made sense. Well, as I didn't have any insight about AI services, models, etc, I was quite pleased with its response time, which was around 240ms, on my potato-laptop with MX250 GPU. It also had some complex architecture consisting of web api, redis cache, some kind message broker, etc. That's why I had to set it up with docker, which resulted in huge storage usage and so on.

Anyways, AI service was working fine-ish, this was when I started working on platform itself, and finished prototyping. 

### Working on web platform
At this point, I only had one question in mind: "Which UI framework to use?"

Well, why not new, shiny, good looking, cool sounding [Blazor Server](https://dotnet.microsoft.com/en-us/apps/aspnet/web-apps/blazor)! And I had one more reason to chose this over JS frameworks. I had recently seen [MudBlazor](https://mudblazor.com/), which is an amazing Material UI library for Blazor, and starred it on GitHub. I thought this will make it easier for me to build UI components, which later did exactly this!

***
_**Full disclosure:** I personally don't love Material UI, but it was going to make things so fast, that I might consider looking at it_
***

Anyways, after deciding on Blazor+MudBlazor, prototyping some components and digging docs for a few hours, I finally started writing actual platform itself!

### Oh, dear!
I thought from now on, it will be smooth sailing, but hell no! I remembered there is no "official" OpenCV library that I know of, so had to research it a bit. After some quick searches, I came accross 2 libraries: [Emgu](https://www.emgu.com/) and [OpenCvSharp](https://github.com/shimat/opencvsharp). Emgu one is well documented, and looks like is some company backed. Meanwhile, OpenCvSharp seemed to have easier and more intuitive API. So, I chose second one, OpenCvSharp, which went nice for some time!

I drew our data-flow diagram and started coding it. 

### Exciting times
If you know me, you already know that I love coding nice stuff. But it was quite some time that I was doing standard web programming, dealing with CRUD, etc. Of course, starting new job at bp helped a lot. I was finally coding to solve problems, but I didn't have much responsibility and ngl, I was afraid of changing some code in that repo :D. 

But at specterise, I was all alone, writing this kind of software for the first time! Btw, I love exactly this about startups. Having all responsibility on me really incentivies me to learn stuff.

Well, these times I had my brain's LogLevel set to Verbose, and added [Misir](https://themisir.com)'s whatsapp as the only sink :D. He really had a lot to add, and I was discussing critical parts with him, to get some cold eye on topic. Oh, now I write, I'm starting to realize that I was probably annoying him. But I think he was also excited at some parts, at the end of the day, he is also fellow nerd, isn't he.

Anyways. Coming back to Specterise. 

### It all coming together
At this point, I was working almost 14 hours a day, trying to maintain full-time job, university, and this Specterise. To be precise, it was hella nice feeling! (I have written [about this feeling here](/status-update-and-some-rant/)[after "Yep, I'm back" line]) So, after coding day and night for couple of weeks, we finally got nice looking dashboard!

As our requirements was forming along the way, I had to rewrite some parts of it, refactor it multiple times and as I was approaching end of first spring, it was quite solid codebase! Letme see if I can find some screenshots for you

![Specterise HomePage screenshot](/images/2022/specterise-ss-1.png)

We can actually see multiple things here, we got heatmap, being drawn on camera frame, people being counted (writing this part was nice, I implemented ring buffer for the first time, did some trigonometry, worked with vectors - Very nice feelings, indeed!), not-so-nice looking alerts (at the top-right corner, telling there is queue overflow happening), etc.

These are all nice features, working quite accurately. But there is a problem. 

_S e l l i n g - t h i s_ 

### Business time 💸
I'm starting to think that this became quite lenghty post, and I've been writing this for almost 4 hours now (including breaks to get meal). 

Also, a friend is waiting for me outside. Gotta meet with him.

*** 

Anyways, if you got any questions, something to talk about, or just want to rant about today's tech, write to me via email :)

alvanrahimli [~@~] pm.me (trying to confuse scrapers, lol)

> To be continued :D