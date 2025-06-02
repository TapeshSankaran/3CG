-- Board class

local Field = require "field"

Board = {}
Board.__index = Board

function Board:new(sx, sy, ex, ey)
    return setmetatable({
        fields = {Field:new(sx, sy, 0.3*(ex-sx), ey-sy), Field:new(sx+0.33*ex, sy, 0.3*(ex-sx), ey-sy), Field:new(sx+0.66*ex, sy, 0.3*(ex-sx), ey-sy)},
        start_position = Vector(sx, sy),
        end_position = Vector(ex, ey),
    }, self)
end

function Board:stageCards(player, locationIndex, card)
    return self.fields[locationIndex]:addCard(player, card)
end

function Board:evaluateTurn()
  local results = {}
  for i, field in ipairs(self.fields) do
    local pPower, oPower = field:calculatePower()
    
    local scoreDiff = math.abs(pPower - oPower)
    if pPower > oPower then
      field:emptyCardSlots(game.opponent)
      results.player = (results.player or 0) + scoreDiff
    elseif oPower > pPower then
      field:emptyCardSlots(game.player)
      results.opponent = (results.opponent or 0) + scoreDiff
    else
      -- Flip coin for tie
      if math.random() < 0.5 then
          results.player = (results.player or 0) + scoreDiff
      else
          results.opponent = (results.opponent or 0) + scoreDiff
      end
    end
  end
  return results
end

function Board:moveCard(player, card)
  local og_field = card.field
  local fieldOptions = {1, 2, 3}
  table.remove(fieldOptions, indexOf(self.fields, og_field))
  local end_field = self.fields[fieldOptions[math.random(1, 2)]]

  end_field:addCard(player, og_field:removeCard(player, card))
end

function Board:allFaceDown()
  for _, field in ipairs(self.fields) do
    for _, card in ipairs(field.player_slots) do
      card.faceUp = false
    end
  end
end

function Board:draw()
  for i, field in ipairs(self.fields) do
    field:draw()
  end
end

return Board
