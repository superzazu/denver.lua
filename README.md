# denver
denver is a simple library to help you play custom waveforms with
[LÖVE](http://love2d.org). It currently supports several waveforms:
sinus, sawtooth, square, triangle, whitenoise, pinknoise, brownnoise.

## How it works
```
local denver = require 'denver'

-- play a sinus of 1sec at 440Hz
local sine = denver.get({waveform='sinus', frequency=440, length=1})
love.audio.play(sine)

-- play a F#2 (available os)
local square = denver.get({waveform='square', frequency='F#2', length=1})
love.audio.play(square)

-- to loop the wave, don't specify a length (generates one period-sample)
local saw = denver.get({waveform='sawtooth', frequency=440})
saw:setLooping(true)
love.audio.play(saw)

-- play noise
local noise = denver.get({waveform='whitenoise', length=6})
love.audio.play(noise)
```
