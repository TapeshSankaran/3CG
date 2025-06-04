
-- Game class

local Player  = require "player"
local Board   = require "board"

Game = {}
Game.__index = Game

function Game:new()
  return setmetatable({
    turn = 1,
    targetPoints = target_points,
    player = Player:new("Player", width/2, height*0.79),
    opponent = Player:new("Opponent", width/2, -height*0.005),
    board = Board:new(width*0.03, height*0.25, width*0.97, height*0.73),
    extra = 0,
    state = "player_turn",
    action = {}
  }, self)
end

function Game:nextTurn()
  local result = self.board:evaluateTurn()
  self.player.points = self.player.points + (result.player or 0)
  self.opponent.points = self.opponent.points + (result.opponent or 0)

  if self.player.points >= self.targetPoints or self.opponent.points >= self.targetPoints then
    if self.player.points > self.opponent.points then
      self.winner = "Player wins!"
      self.state = "won"
    elseif self.opponent.points > self.player.points then
      self.winner = "Opponent wins!"
      self.state = "won"
    else
      self.winner = "It's a draw!"
      self.state = "won"
    end
    return true
  end
  
  self.turn = self.turn + 1
  self.player.mana = self.turn + self.player.extra
  self.opponent.mana = self.turn + self.opponent.extra
  self.player:drawCard()
  self.opponent:drawCard()
  
  for _, field in ipairs(self.board.fields) do
    local cards, onEoTs = field:hasTriggers("onEoT", "both")
    if onEoTs then
      for i, onEoT in ipairs(onEoTs) do
        onEoT(cards[i])
      end
    end
    --for _, c in ipairs(field.opponent_slots) do
    --  if ABILITIES[c.name] and ABILITIES[c.name].onEoT then
    --    ABILITIES[c.name].onEoT(c)
    --  end
    --end
    --for _, c in ipairs(field.player_slots) do
    --  if ABILITIES[c.name] and ABILITIES[c.name].onEoT then
    --    ABILITIES[c.name].onEoT(c)
    --  end
    --end
  end
end

function Game:submitTurn()
  for _, card in ipairs(self.action) do
    card.faceUp = false
  end
  ai:takeTurn()
end

function Game:revealCard()
  local card = self.action[1]
  
  if card ~= nil then 
    card:flip()
  end
end

function Game:activateReveal()
  local card = table.remove(self.action, 1)
  
  if card ~= nil then
    card:trigger("onReveal")
  end
end

function Game:createCard(cardData, faceUp)
  local card = Card:new(cardData, faceUp, -100, -100)
  return card
end

function Game:draw()
  if hasWon then
    love.graphics.setColor(COLORS.LIGHT_GOLD)
    love.graphics.setFont(title_font)
    love.graphics.printf(self.winner, 0, height*0.5, width, "center")
    
    local cont_color = cont_over and COLORS.DARK_BLUE or COLORS.BLUE
    love.graphics.setColor(cont_color)
    love.graphics.printf("Continue?", 0, height*0.75, width, "center")
    return
  end
  self.board:draw()
  self.player:draw()
  self.opponent:draw()
  if game.state == "player_turn" then
    love.graphics.draw(endButton, end_x, end_y, 0, end_scale, end_scale)
  end
  love.graphics.setColor(COLORS.BLACK)
  love.graphics.setFont(name_font)
  love.graphics.printf("Round " .. self.turn, 0, height*0.01, width*0.5, "center", 0, 2, 2)
end

return Game
