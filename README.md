# denver

denver is a simple library to help you play custom waveforms through [LÖVE2D](http://love2d.org).

## How it works

```
local denver = require 'denver'

-- play a sinus
local sine = denver.get('sinus', 440, 1) -- create a sample of 1sec, at the frequency of 440Hz (note that you can also play square, sawtooth and triangle waves)
love.audio.play(sine)

-- play a note
local square = denver.get('square', 'F#2', 1) -- you can also specify a note : C4, A#2, Fb5
love.audio.play(square)

-- play a looped wave
local saw = denver.get('sawtooth', 440) -- if you want to loop your sound, don't specify a length
saw:setLooping(true)
love.audio.play(saw)

-- play noise
local noise = denver.get('whitenoise', 6) -- 6sec of white noise (you can also use pinknoise and brownnoise)
love.audio.play(noise)


-- bonus : plays a binaural beat (you can use denver.stopBinauralBeat() to stop it)
denver.playBinauralBeat(432, 4, true) -- carrier frequency of 432Hz and a perceived frequency of 4Hz, with pink noise
```
You may be interested in looking in the folder `example-scorereader` and `example-synthesizer`.
