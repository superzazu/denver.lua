local class = require 'lib.middleclass'
local denver = require 'denver'

local Synthesizer = class('Synthesizer')

function Synthesizer:initialize(waveform_type)
	self.notes = {}

	for i=0,8 do -- from A0 to B8
		self.notes['A'..i] = denver.get(waveform_type, 'A'..i)
		self.notes['A#'..i] = denver.get(waveform_type, 'A#'..i)
		self.notes['B'..i] = denver.get(waveform_type, 'B'..i)
		self.notes['C'..i] = denver.get(waveform_type, 'C'..i)
		self.notes['C#'..i] = denver.get(waveform_type, 'C#'..i)
		self.notes['D'..i] = denver.get(waveform_type, 'D'..i)
		self.notes['D#'..i] = denver.get(waveform_type, 'D#'..i)
		self.notes['E'..i] = denver.get(waveform_type, 'E'..i)
		self.notes['F'..i] = denver.get(waveform_type, 'F'..i)
		self.notes['F#'..i] = denver.get(waveform_type, 'F#'..i)
		self.notes['G'..i] = denver.get(waveform_type, 'G'..i)
		self.notes['G#'..i] = denver.get(waveform_type, 'G#'..i)
	end

end

function Synthesizer:playNote(note)
	self.notes[note]:setLooping(true)
	love.audio.play(self.notes[note])
end

function Synthesizer:stopNote(note)
	self.notes[note]:setLooping(false)
	love.audio.stop(self.notes[note])
end

function Synthesizer:stopNotesOnOctave(octave) -- fix to avoid blocked notes
	self:stopNote('A'..octave)
	self:stopNote('A#'..octave)
	self:stopNote('B'..octave)
	self:stopNote('C'..octave)
	self:stopNote('C#'..octave)
	self:stopNote('D'..octave)
	self:stopNote('D#'..octave)
	self:stopNote('E'..octave)
	self:stopNote('F'..octave)
	self:stopNote('F#'..octave)
	self:stopNote('G'..octave)
	self:stopNote('G#'..octave)
end

return Synthesizer