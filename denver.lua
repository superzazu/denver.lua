local denver = {
	_VERSION 		= 'denver v1.0.0',
	_DESCRIPTION	= 'An audio generation module for LÖVE2D',
	_URL			= 'http://github.com/superzazu/denver.lua',
	_LICENSE		= [[
		Copyright (c) 2014 Nicolas Allemand

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in
		all copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
		THE SOFTWARE.
	]]
}

denver.rate = 44100
denver.bits = 16
denver.channel = 1
denver.base_freq = 440 -- A4 = 440

local oscillators = {}

-- returns a LOVE2D audio source with a wave
-- examples :
--    my_wave = denver.get('sinus', 440, 1)
--    my_wave2= denver.get('square', 'E#3') -- do not specify length if you need to loop the wave (generates only a period, so that's memory-friendly and avoids cracks in the sound)
--    my_noise= denver.get('pinknoise', 4) -- generate a sample of 4second pink-noise
denver.get = function (wave_type, frequency, length, ...)
	
	-- retrieving data
	if wave_type:find('noise') then -- if it's a noise...
		length = frequency -- ...we do not need frequencies
		frequency = 0
		length = length or 1 -- ..if no length specified
	else -- if it's NOT a noise
		if type(frequency) == 'string' then
			frequency = denver.noteToFrequency(frequency)
		else
			frequency = frequency or 0
		end
		length = length or 1/frequency -- by default creates one period-sample; that allows user to loop the sample (and smaller audio sources)
	end
	if length <= 0 then error('sample length must be > 0', 2) end

	-- creating an empty sample 
	local soundData = love.sound.newSoundData(length * denver.rate, denver.rate, denver.bits, denver.channel)

	-- setting up the oscillator
	local osc = nil
	if oscillators[wave_type] then
		osc = oscillators[wave_type](frequency, ...)
	else
		error('wave type "'.. wave_type ..'"" is not supported.', 2)
	end

	-- filling the sample with values 
	local amplitude = 0.2
	for i=0,length*denver.rate-1 do
		sample = osc(freq, denver.rate) * amplitude
		soundData:setSample(i, sample)
	end

	return love.audio.newSource(soundData)
end

-- you can add your own waves
denver.set = function (wave_type, osc)
	oscillators[wave_type] = osc
end

-- takes a note in parameter and returns a frequency (ie note_str=C#4, returns 277.18314331964 (for base_freq=440))
denver.noteToFrequency = function (note_str)
	if type(note_str) ~= 'string' then error('note must be a string', 2) end
	local note_semitones = {C=-9, D=-7, E=-5, F=-4, G=-2, A=0, B=2}

	local semitones = note_semitones[note_str:sub(1,1)]
	local octave = 4
	local alteration = 0

	if note_str:len() == 2 then
		octave = note_str:sub(2,2)
	elseif note_str:len() == 3 then -- # or flat
		if note_str:sub(2,2) == '#' then
			semitones = semitones + 1
		elseif note_str:sub(2,2) == 'b' then
			semitones = semitones - 1
		end
		octave = note_str:sub(3,3)
	end

	semitones = semitones + 12 * (octave-4)

	return denver.base_freq * math.pow(math.pow(2, 1/12), semitones) -- 1/12 ~= 0.083333
	-- frequency = root * (2^(1/12))^steps (steps(=semitones) can be negative)
end



-- BONUS: plays a basic binaural beat (option: pink noise)
local left = nil
local right = nil
local noise = nil
denver.playBinauralBeat = function (carrier, frequency, play_noise)

	-- noise generation
	if play_noise then
		noise = denver.get('pinknoise', 5)
		noise:setLooping(true)
		noise:setVolume(0.8)
		love.audio.play(noise)
	end

	-- sinus
	left = denver.get('sinus', carrier + frequency / 2)
	left:setPosition(-1,0,0)
	left:setLooping(true)

	right = denver.get('sinus', carrier - frequency / 2)
	right:setPosition(1,0,0)
	right:setLooping(true)

	love.audio.play(left)
	love.audio.play(right)
end

denver.stopBinauralBeat = function ()
	if left then
		love.audio.stop(left)
	end
	if right then
		love.audio.stop(right)
	end
	if noise then
		love.audio.stop(noise)
	end
end





-- OSCILLATORS
oscillators.sinus = function (f)
	local phase = 0
	return function()
		phase = phase + 2*math.pi/denver.rate
		if phase >= 2*math.pi then
			phase = phase - 2*math.pi
		end
		return math.sin(f*phase)
	end
end

oscillators.sawtooth = function (f) -- https://github.com/zevv/worp/blob/master/lib/Dsp/Saw.lua
	local dv = 2 * f / denver.rate
	local v = 0
	return function()
		v = v + dv
		if v > 1 then v = v - 2 end
		return v
	end
end

oscillators.square = function (f, pwm)
	pwm = pwm or 0
	if pwm >= 1 or pwm < 0 then error('PWM must be between 0 and 1 (0 <= PWM < 1)', 2) end
	local saw = oscillators.sawtooth(f)
	return function()
		return saw() < pwm and -1 or 1
	end
end

oscillators.triangle = function (f)
	local dv = 1 / denver.rate
	local v = 0
	local a = 1 -- up or down
	return function()
		v = v + a * dv * 4 * f
		if v > 1 or v < -1 then
			a = a * -1
			v = math.floor(v+.5)
		end
		return v
	end
end

oscillators.whitenoise = function ()
	return function()
		return math.random() * 2 - 1
	end
end

oscillators.pinknoise = function () -- http://www.musicdsp.org/files/pink.txt
	local b0,b1,b2,b3,b4,b5,b6 = 0,0,0,0,0,0,0
	return function()
		local white = math.random() * 2 - 1
		b0 = 0.99886 * b0 + white * 0.0555179;
		b1 = 0.99332 * b1 + white * 0.0750759;
		b2 = 0.96900 * b2 + white * 0.1538520;
		b3 = 0.86650 * b3 + white * 0.3104856;
		b4 = 0.55000 * b4 + white * 0.5329522;
		b5 = -0.7616 * b5 - white * 0.0168980;
		pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362; 
		b6 = white * 0.115926; 
		return pink * 0.11 -- (roughly) compensate for gain
	end
end

oscillators.brownnoise = function () -- http://noisehack.com/generate-noise-web-audio-api/
	local lastOut = 0
	return function()
		local white = math.random() * 2 - 1
		local out = (lastOut + (0.02 * white)) / 1.02
		lastOut = out
		return out * 3.5 -- (roughly) compensate for gain
	end
end



-- Denver, the last dinosaur
-- He's my friend and a whole lot more
-- Denver, the last dinosaur
-- Shows me a world I never saw before

-- Everywhere we go we don't really care
-- If people stop and stare at our pal dino.
-- Creating history thru the rock n' roll spotlight
-- We've got a friend who helps us, we can do alright

-- That's Denver, the last dinosaur
-- He's my friend and a whole lot more
-- Denver, the last dinosaur
-- Shows me a world I never saw before.

return denver