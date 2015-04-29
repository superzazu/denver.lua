-- A VERY SIMPLE CLASS TO READ SHEETS

local class = require 'lib.middleclass'
local denver = require 'denver'

local ScoreReader = class('ScoreReader')

function ScoreReader:initialize(wave_type, notes, bpm)
    self.wave_type = wave_type
    self.notes = notes
    self.bpm = bpm

    self.looping = false
    self:stop()
end

function ScoreReader:update(dt)
    if self.playing then
        self.timer = self.timer + dt

        if self.timer > 60/self.bpm then
            self.timer = 0
            self.current_note = self.current_note + 1

            if self.current_note > #self.notes then
                self:stop()
                if self.looping then
                    self.playing = true
                end
            end

            self:_playNote(self.current_note)
        end
    end
end


function ScoreReader:play()
    self.playing = true
    self:_playNote(self.current_note)
end

function ScoreReader:stop()
    self.timer = 0
    self.current_note = 1
    self.playing = false
end

function ScoreReader:setLooping(l)
    self.looping = l
end

function ScoreReader:_playNote(n)
    local current_sample = denver.get({waveform=self.wave_type,
                                       frequency=self.notes[n],
                                       length=60/self.bpm})
    love.audio.play(current_sample)
end

return ScoreReader
