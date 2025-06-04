-- Player class

Deck   = require "deck"

Player = {}
Player.__index = Player

function Player:new(name, x, y)
    
    local deck  = Deck:new(cardData, name, width*0.025, height*0.78)
    deck:shuffle()
  
    local hand = {}
    for _ = 1, 4 do
      local card = deck:deal()
      if name == "Opponent" then
        card:flip()
      end
      card.owner = name
      table.insert(hand, card)
    end
    
    local cardWidth = img_width*scale+10
    for i, card in ipairs(hand) do
      card.position = Vector(
        x+cardWidth*#hand*0.5-cardWidth*i,
        y
      )
    end
    
    return setmetatable({
        name = name,
        deck = deck,
        hand = hand,
        discard_pile = {},
        points = 0,
        mana = 1,
        extra = 0,
        position = Vector(x, y),
    }, self)
end

function Player:drawCard()
  
  -- If hand is at limit or deck is empty, leave --
  if #self.hand >= 7 or #self.deck.cards <= 0 then
    return
  end

  -- Transfer top card to hand --
  table.insert(self.hand, self.deck:deal())

  -- Flip face down if enemy --
  if self.name == "Opponent" then
    self.hand[#self.hand]:flip()
    
  end
  
  -- Cardwidth + permittedd distance between cards --
  local cardWidth = img_width*scale+120/(4*#self.hand)
  
  -- Space cards apart properly --
  for i, card in ipairs(self.hand) do
    card.owner = self
    card.position = Vector(
      self.position.x+cardWidth*#self.hand*0.5-cardWidth*i,
      self.position.y
    )
  end
end

function Player:addCard(card)
  
  -- If hand is at limit or deck is empty, leave --
  if #self.hand >= 7 or card == nil then
    return
  end

  -- Transfer top card to hand --
  table.insert(self.hand, card)

  -- Flip face down if enemy --
  if self.name == "Opponent" then
    self.hand[#self.hand]:flip()
    
  end
  
  -- Cardwidth + permittedd distance between cards --
  local cardWidth = img_width*scale+120/(4*#self.hand)
  
  -- Space cards apart properly --
  for i, card in ipairs(self.hand) do
    card.owner = self
    card.position = Vector(
      self.position.x+cardWidth*#self.hand*0.5-cardWidth*i,
      self.position.y
    )
  end
end

function Player:playCard(index)
    local card = self.hand[index]
    if card and tonumber(card.cost) <= self.mana then
        self.mana = self.mana - card.cost
        table.remove(self.hand, index)
        return card
    end
    return nil
end

function Player:removeCard(index)
    local card = self.hand[index]
    if card then
        self.mana = self.mana - card.cost
        table.remove(self.hand, index)
        return card
    end
    return nil
end

function Player:draw()
  if self.name ~= "Opponent" then
    for _, card in ipairs(self.hand) do
      card:draw()
    end
    self.deck:draw()
  end
  love.graphics.setColor(COLORS.DARKER_GREEN)
  love.graphics.setFont(name_font)
  local y = self.name == "Opponent" and height*0.07 or -height*0.04
  --local x = self.name == "Opponent" and width*0.1 or width*0.9

  love.graphics.printf(self.name, 0, self.position.y+y, width, "center")
  love.graphics.setColor(COLORS.BLUE)
  love.graphics.printf("Mana: " .. self.mana, self.position.x-width*0.1, self.position.y+y, img_height, "right", 0, 1, 1, name_font:getWidth("Mana: " .. self.mana))
  love.graphics.setColor(COLORS.DARK_GOLD)
  love.graphics.printf("Points: " .. self.points, self.position.x+width*0.075, self.position.y+y, img_height*2, "left")
end

return Player

