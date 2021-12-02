+++ 
date = 2021-12-01T19:26:49-05:00
title = "Building a DIY router for Fun and Profit, Part 1: Requirements"
tags = ["networking"]
+++

In a world where many of our critical networking devices are unknowable black
boxes, the idea of having hardware I can describe from top to bottom is pretty
attractive. In this series of posts I'll be talking about my experiences
building a full-featured router. First up: an overview of the project.

# Okay, but why?

Well, why not? My old network setup was starting to show its age, so the time
was right for *something* new. I don't do anywhere near as much with networking
at my day job as I used to, so it was nice to be able to keep those skills
sharp with a bit of a self-imposed challenge. Besides, I certainly wasn't
switching over to the router provided by my ISP!

# Requirements

The word *"router"* can mean a few different things depending on whether you're
talking to a layman, a seasoned IT professional, or a carpenter; a good place
to start would be to describe exactly what I'm talking about here.

The end goal was to match the kind of functionality you'd get out of
some standard consumer hardware. In short: a single magic box where Internet
goes in and Wi-Fi comes out.

As far as the hardware itself goes, my requirements were pretty open-ended:
Dual-band Wi-Fi, four or more 1Gb NICs (airwaves are crowded in my area, so I prefer
to hard-wire when possible), and enough juice to be able to handle a pretty
busy network without breaking a sweat (if I get gigabit speeds from my ISP, I
want to use them!).

Software-wise, I wanted the box to do the following:

* **Firewall/NAT:** block any and all unsolicited traffic from the Internet,
  but allow local clients to do their thing
* **Wi-Fi AP:** for phones, friends, IoT devices, etc.
* **Switching:** bridge Ethernet and wireless interfaces for local
  communication.
* **DHCP:** if I'm going to go through all of this, I'm not also going to
  manually configure an IP for every single client.
* **DNS:** cache hits for bonus speed, dodge ISP shenanigans, and block ad
  domains

*... easy, right?*

# Next Up

In my next post I'll get into the meat of the project and talk about hardware.

