-- Field class

local Player = "player"

Field = {}
Field.__index = Field

function Field:new(x, y, endX, endY)
    return setmetatable({
        player_slots = {},
        opponent_slots = {},
        position = Vector(x, y),
        end_position = Vector(endX, endY)
    }, self)
end

function Field:addCard(player, card)
    local slots = player.name == "Player" and self.player_slots or self.opponent_slots
    local height = player.name == "Player" and self.position.y+0.6*self.end_position.y or self.position.y+self.end_position.y*0.1
    if #slots < 4 then
        table.insert(slots, card)
        card.position = Vector(self.position.x + self.end_position.x*(#slots-1)/4, height)
        card.field = self
        return true
    end
    return false
end

function Field:removeCard(player, card)
  local slots = player.name == "Player" and self.player_slots or self.opponent_slots
  
  if #slots > 0 then
    local index = indexOf(slots, card)
    table.remove(slots, index)
    table.insert(player.discard_pile, card)
    card.position = Vector(-100, -100)
    
    self:refreshCards(player)
    
    return card
  end
  return nil
end

function Field:emptyCardSlots(player)
  local slots = player.name == "Player" and self.player_slots or self.opponent_slots
  for i=1,#slots do  
    local card = table.remove(slots)
    table.insert(player.discard_pile, card)
    if ABILITIES[card.name] and ABILITIES[card.name].onDiscard then
      ABILITIES[card.name].onDiscard(card)
    end
    card.position = Vector(-100, -100)
  end
end

function Field:isWinning(player)
  local pPower, oPower = self:calculatePower()
  ownerPower = player.name == "Player" and pPower or oPower
  otherPower = player.name ~= "Player" and pPower or oPower
  return ownerPower > otherPower
end

function Field:refreshCards(player)
  local slots = player.name == "Player" and self.player_slots or self.opponent_slots
  local height = player.name == "Player" and self.position.y+0.6*self.end_position.y or self.position.y+self.end_position.y*0.1
  for i, card in ipairs(slots) do
    card.position = Vector(self.position.x + self.end_position.x*(i-1)/4, height)
  end
end

function Field:hasTrigger(trigger, target)
  if target == "Player" or target == "both" then
    for _, card in ipairs(self.player_slots) do
      local ability = ABILITIES[card.name]
      if ability and ability[trigger] then
        return card, ability[trigger]
      end
    end
  end
  if target == "Opponent" or target == "both" then
    for _, card in ipairs(self.opponent_slots) do
      local ability = ABILITIES[card.name]
      if ability and ability[trigger] then
        return card, ability[trigger]
      end
    end
  end
  return nil, nil
end

function Field:hasTriggers(trigger, target)
  local cards, abilities = {}, {}
  if target == "Player" or target == "both" then
    for _, card in ipairs(self.player_slots) do
      local ability = ABILITIES[card.name]
      if ability and ability[trigger] then
        table.insert(cards, card)
        table.insert(abilities, ability[trigger])
      end
    end
  end
  if target == "Opponent" or target == "both" then
    for _, card in ipairs(self.opponent_slots) do
      local ability = ABILITIES[card.name]
      if ability and ability[trigger] then
        table.insert(cards, card)
        table.insert(abilities, ability[trigger])
      end
    end
  end
  return cards ~= {} and cards or nil, abilities ~= {} and abilities or nil
end

function Field:calculatePower()
  local function sumPower(cards)
    local total = 0
    for _, c in ipairs(cards) do total = total + c.power end
    return total
  end
  return sumPower(self.player_slots), sumPower(self.opponent_slots)
end

function Field:isOver(mouseX, mouseY)
  local width = self.end_position.x
  local height = self.end_position.y
  --local height = self.sprite:getHeight() * scale
  return mouseX > self.position.x and mouseX < self.position.x + width and
        mouseY > self.position.y and mouseY < self.position.y + height
end

function Field:draw()
  local bevel = 10
  love.graphics.setColor(COLORS.DARKER_GREEN)
  love.graphics.rectangle("fill", self.position.x-bevel, self.position.y-bevel, self.end_position.x+bevel*2, self.end_position.y+bevel)
  love.graphics.setColor(COLORS.WHITE)

  for i=1,4 do
    if self.player_slots[i] ~= nil then
      self.player_slots[i]:draw()
    else
      love.graphics.setColor(COLORS.DARK_GREEN)
      love.graphics.draw(emptyCard, self.position.x+((i-1)/4)*self.end_position.x, self.position.y+0.6*self.end_position.y, 0, scale, scale)
      love.graphics.setColor(COLORS.WHITE)
    end
  end
  
  for i=1,4 do
    if self.opponent_slots[i] ~= nil then
      self.opponent_slots[i]:draw()
    else
      love.graphics.setColor(COLORS.DARK_GREEN)
      love.graphics.draw(emptyCard, self.position.x+((i-1)/4)*self.end_position.x, self.position.y+self.end_position.y*0.1, 0, scale, scale)
      love.graphics.setColor(COLORS.WHITE)
    end
  end
end

return Field
