package.path = package.path .. ";../?.lua" -- to load denver.lua

local denver = require 'denver'
local ScoreReader = require 'ScoreReader' -- requires middleclass

function love.load()
    sheet = {'C3', 'C4', 'G3', 'C4', 'C3', 'C4', 'G3', 'C4',
			 'D3', 'D4', 'A3', 'D4', 'G3', 'F3', 'E3', 'D3'}
    player = ScoreReader:new('square', sheet, 200)
    player:setLooping(true)
    player:play()
end

function love.update(dt)
    player:update(dt)
end
