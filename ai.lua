
Player = require "player"

AI = {}
AI.__index = AI

function AI:new(player, board)
  local ai = {
    player = player,
    board = board,
    action = {}
  }
  setmetatable(ai, AI)
  return ai
end

-- Returns a table of card plays: { {card, locationIndex, slotIndex}, ... }
function AI:takeTurn()
  local availableMana = self.player.mana
  local hand = self.player.hand
  local plays = {}
  local used = {}

  -- Simple: sort hand by cost ascending to prioritize low-cost cards
  table.sort(hand, function(a, b) return tonumber(a.cost) < tonumber(b.cost) end)

  for _, card in ipairs(hand) do
    if tonumber(card.cost) <= availableMana then
      -- Pick a random location and first open slot
      local locIndex = math.random(1, 3)
      local location = self.board.fields[locIndex]
      local slotIndex = self:findOpenSlot(location, self.player)
  
      if slotIndex then
        table.insert(plays, {card = card, location = locIndex, slot = slotIndex})
        table.insert(game.action, card)
        local index = indexOf(self.player.hand, card)
        
        if index == nil then return nil end
        
        local outCard = self.player:playCard(index)
        if outCard == nil then return nil end
        
        location:addCard(self.player, outCard)

        local c, onPlay = location:hasTrigger("onPlay", "both")
        if onPlay then
          onPlay(c, card)
        end

        availableMana = availableMana - card.cost
        table.insert(used, card)
      
      end
    end
  end

  self.action = plays
end

function AI:findOpenSlot(location, player)
  local side = location.opponent_slots  -- assume board location holds { [1] = {}, [2] = {} } for players
  for i = 1, 4 do
    if not side[i] then
      return i
    end
  end
  return nil
end

return AI
