package.path = package.path .. ";../?.lua" -- to load denver.lua
local Synthesizer = require 'Synthesizer'

function love.load()
	synth = Synthesizer:new('square')

	keyboard_bind = {q='C', z='C#', s='D', e='D#', d='E', f='F', t='F#', g='G', y='G#', h='A', u='A#', j='B'}
	current_octave = 4
end

function love.keypressed(key)
	if keyboard_bind[key] then
		synth:playNote(keyboard_bind[key]..current_octave)
	elseif key == 'up' then
		synth:stopNotesOnOctave(current_octave)
		current_octave = current_octave + 1
	elseif key == 'down' then
		synth:stopNotesOnOctave(current_octave)
		current_octave = current_octave - 1
	end
end

function love.keyreleased(key)
	if keyboard_bind[key] then
		synth:stopNote(keyboard_bind[key]..current_octave)
	end
end



-- show informations
function love.draw()
	love.graphics.printf('LOVE synthesizer',0,0,320, 'center')
	love.graphics.printf('use : QZSEDFTGYHJ to play, and up/down to change octaves', 0, 30, 320, 'center')
end