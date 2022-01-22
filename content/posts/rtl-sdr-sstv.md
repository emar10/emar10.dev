---
date: "2022-01-22"
title: "Receiving SSTV with an RTL-SDR"
tags:
    - ham radio
    - rtl-sdr
---

Occasionally the Amateur Radio on International Space Station (ARISS) crew
transmits commemorative Slow Scan Television (SSTV) images. At the time of
writing, the last event was just a few days ago. Here's how I was able to
(somewhat) successfully receive images from space using nothing but the
contents of a $40 RTL-SDR kit and a laptop.

# Hardware Setup

My weapon of choice for this particular adventure was a V3
[RTL-SDR](https://rtl-sdr.com) dongle, coupled with a fairly simple telescoping
dipole antenna that came with it.

In researching the ideal antenna setup, I came across the idea of using a
horizontal V-shape from [Adam 9A4QV][1]. The idea is that the horizontal
orientation and V-shape help to minimize interference from nearby stations on
Earth and provide some directionality towards space. I did not get enough data
to confirm that this helped, but it certainly didn't seem to hurt my reception.
Here's how I wound up configuring the antenna:

* 120° V-shape
* Each arm telescoped to 50cm
* Antenna parallel to the ground, pointed Northward

# Software Setup

There were a couple of resources on receiving SSTV using an SDR, most of which
were Windows-centric. I did find an excellent post at [artemis.sh][2] detailing
both TX and RX of SSTV on Linux, with a Raspberry Pi (!) doing transmit and an
RTL-SDR receiving. Obviously the RX bits are of more interest here. The post
does mention a way to do realtime SSTV decoding, but I slightly streamlined
this process.

This was the final software stack:
* [gpredict][3]: Track overhead passes of the ISS
* [gqrx][4]: Talk to the RTL-SDR (tuning, FM demod, etc.)
* [qsstv][5]: Decode SSTV signal when received

## gpredict

{{<figure src=/images/rtl-sdr-sstv/gpredict.png title="gpredict showing predicted locations for various satellites">}}

Radio waves tend to not propagate so well through the Earth[^1], so when trying to
receive a signal from the ISS it's generally helpful to know when it will
actually be above the horizon. I wound up using a popular GUI application
called gpredict. There are plenty of online trackers available[^2], but since I
planned to be running my station in the middle of a field I needed an offline
solution.

gpredict's default "Amateur" profile already tracks the ISS, and shortly after
startup I was prompted to download updated prediction data. After grabbing
fresh data, I had a convenient list of upcoming passes.

## gqrx

{{<figure src=/images/rtl-sdr-sstv/gqrx.png title="gqrx driving the RTL-SDR">}}

gqrx is a pretty much the gold standard when it comes to working with an
RTL-SDR on Linux. As long as the `rtlsdr` kernel module is loaded instead of
the TV tuner drivers included in Linux[^3] the dongle will appear as a usable
device in gqrx on startup.

Once set up, I tuned the radio to 145.800 MHz and set gqrx to do narrow FM
demodulation.

## qsstv

{{<figure src=/images/rtl-sdr-sstv/qsstv.png title="qsstv decoding a sample transmission">}}

The last piece of the puzzle was decoding the SSTV signal. The qsstv project is
able to handle both live decode through a microphone input and decoding from
stored audio files. It can also automatically detect the SSTV mode used by an
incoming signal.

In order to get the signal from gqrx into qsstv, I set qsstv to run off of
microphone input, then applied a bit of PulseAudio trickery.[^4] In `pavucontrol`,
I simply set qsstv's recording sink to the monitor for my laptop's speakers,
and like magic qsstv started receiving all of my system's sound output,
demodulated audio from gqrx included.

![pavucontrol](/images/rtl-sdr-sstv/pavucontrol.png)


# Results

By the time I had my setup ready to go and was in a position to go out and try
to receive images from the ISS, there were only two passes of the space station
before the end of the event. One pass had a fairly low maximum elevation, this
combined with unlucky timing of breaks between transmissions resulted in me
coming back empty-handed.

On the other pass, however, I was able to catch most of a single transmission!
The first half had a fair bit of noise. During this time I fiddled with the
antenna orientation a bit, but I think the clearer signal later on was more a
result of the station's elevation increasing. There is also a "drift" to the
image, something qsstv can account for, but in all the excitement I forgot to
enable this feature.


{{<figure src="/images/rtl-sdr-sstv/sstv.png" title="A (nearly) complete SSTV image">}}

While I don't have anything spectacular to show for it, I'm very pleased that I
was able to receive anything. The next time ARISS does an event like this, I'm
looking forward to getting more images, along with some recorded audio/raw IQ
data to tinker with.

[1]: https://lna4all.blogspot.com/2017/02/diy-137-mhz-wx-sat-v-dipole-antenna.html
[2]: https://artemis.sh/2016/08/29/sstv-tx-rx-with-a-pi-and-an-rtl-sdr.html
[3]: http://gpredict.oz9aec.net/
[4]: https://gqrx.dk/
[5]: http://users.telenet.be/on4qz/index.html
[6]: https://www.qsl.net/kd2bd/predict.html

[^1]: At least, not at the ones we're interested in.
[^2]: A lot of these seem to use the same [upstream project][6] that gpredict
  does under the hood anyway.
[^3]: Most distros that package RTL-SDR handle this automagically.
[^4]: This also works with PipeWire via `pipewire-pulse`, for those who like to
  live on the edge.
