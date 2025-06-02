
-- Tapesh Sankaran
-- CMPM 121
-- 4-29-2025

io.stdout:setvbuf("no")

local Config   = require "conf"
local Sys      = require "sys-set"
local Drag     = require "drag"
local Read_CSV = require "rcsv"
local Game     = require "game"
local AI       = require "ai"

local cardBuffer = {}

-- LOAD FUNCTION --
function love.load()
  
  -- Set Window and Random Seed --
  --     (from sys-set.lua)     --
  System_Set()
  
  -- Read CSV --
  cardData = read_csv(FILE_LOCATIONS.CSV)
  
  -- Create Deck --
  local me_deck  = Deck:new(cardData, width*0.025, height*0.78)
  me_deck:shuffle()
  local opp_deck = Deck:new(cardData, width*0.875, height*0.01)
  opp_deck:shuffle()

  game = Game:new(me_deck, opp_deck)
  
  ai = AI:new(game.opponent, game.board)
end

-- DRAW FUNCTION --
function love.draw()
  
  game:draw()
  
  dragged_card_draw()
end