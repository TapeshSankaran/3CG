
Vector = require "vector"
Config = require "conf"  

local Card = {}
Card.__index = Card

-- Load all Images --
faceDown  = love.graphics.newImage(FILE_LOCATIONS.FACEDOWN)
emptyCard = love.graphics.newImage(FILE_LOCATIONS.EMPTY)
solitaire = love.graphics.newImage(FILE_LOCATIONS.SOLITAIRE)
reset_img = love.graphics.newImage(FILE_LOCATIONS.RESET)
undo_img  = love.graphics.newImage(FILE_LOCATIONS.UNDO)
mute_img  = love.graphics.newImage(FILE_LOCATIONS.MUTE)
win_img   = love.graphics.newImage(FILE_LOCATIONS.VICTORY)


-- Load all Audio --
win_SFX     = love.audio.newSource(FILE_LOCATIONS.WIN, "static")
shuffle_SFX = love.audio.newSource(FILE_LOCATIONS.SHUFFLE, "static")
move_SFX    = love.audio.newSource(FILE_LOCATIONS.MOVE, "static")
draw_SFX    = love.audio.newSource(FILE_LOCATIONS.DRAW, "static")

-- Edit Audio --
move_SFX:setVolume(0.5)
move_SFX:setPitch(2)


-- CREATE NEW CARD --
function Card:new(cost, power, sprite, faceUp, x, y)
  local metatable = {__index = Card}
  local card = {
    cost = cost,
    power = power,
    sprite = sprite,
    faceUp = faceUp,
    position = Vector(x, y),
    isDragging = false,
    offsetX = 0,
    offsetY = 0,
    anchor = Vector(x, y),
    draggable = true,
  }
  setmetatable(card, metatable)
  return card
end

-- FORMAT CARD INTO PRINTABLE STATE --
function Card:toString()
  return ranks[self.rank] .. " of " .. self.suit.s
end

-- FLIP CARD --
function Card:flip()
  self.faceUp = not self.faceUp
end

-- DRAW CARD --
function Card:draw()
  
  if self.draggable and self.faceUp and draggableCard == nil and self:isMouseOver(love.mouse.getX(), love.mouse.getY()) then
    love.graphics.setColor(COLORS.LIGHT_GOLD)
  end
  if self.faceUp == true then
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, scale, scale)
  else
    love.graphics.draw(faceDown, self.position.x, self.position.y, 0, scale, scale)
  end
  love.graphics.setColor(COLORS.WHITE)
end

-- START DRAGGING CARD --
function Card:startDrag(mouseX, mouseY)
    self.isDragging = true
    self.offsetX = mouseX - self.position.x
    self.offsetY = mouseY - self.position.y
end

-- TRANSFER PILE TO ANOTHER --
function Card:transfer(pile, prev_card_hidden)
  
  prev_card_hidden = prev_card_hidden or false
  local prev_shown = false
  
  -- If card is top if its pile...
  if self.pile.cards[#self.pile.cards] == self then
    
    -- Set prev_shown to whether previous card in pile is face up if there is a previous card --
    if #self.pile.cards > 1 then
      prev_shown = self.pile.cards[#self.pile.cards-1].faceUp
    end
    
    -- Set prev_shown to false if pile is waste pile --
    if self.pile == board.cardWaste then
      prev_shown = false
    end
    
    -- Transfer card --
    self.pile:remove()
    pile:add(self, prev_card_hidden)
    self.isDragging = false
  
  -- If card is not the top card in deck --
  else
  
    -- Remove cards from pile, check prev card in pile's face state --
    local cT, prev_shown = self.pile:removeI(self)
    
    -- Move all cards to pile. If previous card is hidden(and  -- 
    -- technically is an undo action), set it to hidden again. --
    for i,c in ipairs(cT) do
      if i == 1 and prev_card_hidden then
        pile:add(c, prev_card_hidden)
      else
        pile:add(c)
      end
    end
    self.isDragging = false
  end
  
  -- Play audio and return opposite of prev_shown --
  -- (if previous card is shown, when undoing, no action is needed. --
  --        action is needed when previous card is not shown)       --
  move_SFX:play()
  return not prev_shown
end
  
-- STOP DRAGGING CARD --
function Card:stopDrag(mouseX, mouseY)
    -- For all accepted input locations --
    for i, region in ipairs(regions) do
      
      -- If mouse is in one of these locations?
      if mouseX > region.start and mouseX < region.finish and mouseY > region.y then
        
        -- Leave loop if released on same pile as before --
        if board.piles[i] == self.pile then break end
        
        -- If dropped on a tableau tile then...
        if PILE_TYPES[i] == TorF.TABLEAU then
          
          -- If tableau pile has no cards then...
          if board.piles[i]:isEmpty() then
            -- Check if card is a king --
            if ranks[self.rank] ~= "K" then
              break
            end
            -- Transfer card as well as all cards on it to new pile --
            table.insert(board.action_stack, {self, self.pile, self:transfer(board.piles[i])})
            
            
            return
          end          
          
          -- If tableau pile's top card is of the same suit as card, then leave loop --
          if board.piles[i].cards[#board.piles[i].cards].suit.c == self.suit.c then
            break
          end
          
          -- If card's rank is not one less than top card in pile, then leave loop --
          if board.piles[i].cards[#board.piles[i].cards].rank ~= self.rank+1 then
            break
          end
          
          -- Transfer card as well as all cards on it to new pile --
          table.insert(board.action_stack, {self, self.pile, self:transfer(board.piles[i])})
          
          return
        else -- If pile is a foundation pile, then...
          
          -- If card's suit is not same as pile's top card, then leave loop --
          if board.piles[i].cards[#board.piles[i].cards].suit.s ~= self.suit.s then
            break
          end
          
          -- If card's rank is not one more than pile's top card, then leave loop --
          if board.piles[i].cards[#board.piles[i].cards].rank ~= self.rank-1 then
            break
          end
          
          -- If card is not the top card of its current pile, then leave loop --
          if self.pile.cards[#self.pile.cards] ~= self then
            break
          end
          
          -- Remove card from current pile and transfer it to new pile --
          table.insert(board.action_stack, {self, self.pile, self:transfer(board.piles[i])})
          
          return
        
        end
      end
    end
    
    -- Return card to original position if any condition did not pass or no pile was found --
    self.position = Vector(self.anchor.x, self.anchor.y)
    self.isDragging = false
end

-- UPDATE CARD POSITION WHEN DRAGGING --
function Card:update(dt, mouseX, mouseY)
    if self.isDragging and self.faceUp then
        
        self.position.x = mouseX - self.offsetX
        self.position.y = mouseY - self.offsetY
    end
end

-- CHECKS WHEN MOUSE IS OVER CARD --
function Card:isMouseOver(mouseX, mouseY)
    local width = self.sprite:getWidth() * scale
    local height = self == self.pile.cards[#self.pile.cards] and self.sprite:getHeight() * scale or height*0.03
    --local height = self.sprite:getHeight() * scale
    return mouseX > self.position.x and mouseX < self.position.x + width and
           mouseY > self.position.y and mouseY < self.position.y + height
end

return Card
