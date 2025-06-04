
Card = require "card"
local Vector = require "vector"

local Deck = {}
Deck.__index = Deck

function Deck:new(cardData, owner, x, y)
  
  
  local cards = {}
  local cardRef = {}
  local cardCheck = {}

  while #cards < 20 do
    cardIndex = math.random(1, 34)
    cardCheck[cardIndex] = cardCheck[cardIndex] and cardCheck[cardIndex] + 1 or 1
    
    if cardCheck[cardIndex] <= 2 then
      local card = Card:new(cardData[cardIndex], false, owner, x, y)

      table.insert(cards, card)
      table.insert(cardRef, card)
    end
  end
  
  local deck = {
    cards = cards,
    cardTable = cardRef,
    position = Vector(x, y)
  }
  
  setmetatable(deck, self)
  return deck
end

function Deck:shuffle()
  for i = #self.cards, 2, -1 do
    local j = math.random(i)
    self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
  end
end

function Deck:deal()
  local card = table.remove(self.cards)
  
  card:flip()
  return card
end

function Deck:stage(card)
  card.faceUp = false
  card.position = self.position
  table.insert(self.cards, card)
end

function Deck:floor(card)
  card.faceUp = false
  card.position = self.position
  table.insert(self.cards, 1, card)
end

function Deck:isMouseOver(mouseX, mouseY)
  local width = faceDown:getWidth() * scale
  local height = faceDown:getHeight() * scale
  return mouseX > self.position.x and mouseX < self.position.x + width and
           mouseY > self.position.y and mouseY < self.position.y + height
end

function Deck:draw()
  
  if #self.cards == 0 then
    return
  end
  
  for _, card in ipairs(self.cards) do
    card:draw()
  end
end

return Deck
