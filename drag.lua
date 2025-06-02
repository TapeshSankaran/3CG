
local Config = "conf"
local Player = "player"

-- Checks if mouse is pressed --
local mousePressed = false
-- Card currently being dragged --
local draggableCard = nil
-- Checker for mute state --
local is_muted = false
-- Checker for win state --
local not_won = true

local substate = "standby"

-- UPDATE FUNCTION --
function love.update(dt)
  local mouseX, mouseY = love.mouse.getPosition()
  
  -- Update card position of card being dragged --
  if draggableCard then
    draggableCard:update(dt, mouseX, mouseY)
  end
  if state == "ai_turn" then
    game:submitTurn()
    state = "wait_for_flip"
    timer = 2
  elseif state == "wait_for_flip" then
    timer = timer - dt
    if timer <= 0 then
      substate = "stalled"
      state = "waiting"
      timer = 1
    end
  elseif state == "flipped" then
    timer = timer - dt
    if timer <= 0 then
      state = "next_phase"
    end
  elseif state == "next_phase" then
    game:nextTurn()
    state = "player_turn"
  elseif state == "won" then
    timer = 1
    state = "winning"
  elseif state == "winning" then
    timer = timer - dt
    if timer <= 0 then
      hasWon = true
    end
  end
  
  if substate == "stall" then
    timer = timer - dt
    if timer <= 0 then
      substate = "stalled"
      game:activateReveal()
    end
  elseif substate == "stalled" then
    timer = 1
    if #game.action > 0 then
      game:revealCard()
      substate = "repeat"
    else
      substate = "standby"
      state = "next_phase"
      timer = 1
    end
  elseif substate == "repeat" then
    timer = 1
    substate = "stall"
  end
  
  if cont_button_isOver(mouseX, mouseY) then
    cont_over = true
  else
    cont_over = false
  end

  -- Check win state --
  -- (empty) --

end

-- WHEN MOUSE PRESSED --
function love.mousepressed(x, y, button, istouch, presses)
  
  -- If left click and no card already being dragged --
  if button == 1 and draggableCard == nil and state == "player_turn" then
    start_drag(x, y)
  end
  
  -- End Turn Button click functionality --
  if button == 1 and end_button_isOver(x, y) and not mousePressed and state == "player_turn" then
    state = "ai_turn"
  end
  
    -- New Game Button click functionality --
  if button == 1 and cont_button_isOver(x, y) and not mousePressed and hasWon then
    restartGame()
  end
  
  mousePressed = false
end

function love.mousereleased(x, y, button, istouch, presses)
  if draggableCard then
    stop_drag(x, y)
  end
end

-- START DRAGGING CARD --
function start_drag(x, y)
  for _, card in ipairs(game.player.deck.cardTable) do
    if card.draggable and card.faceUp and card:isMouseOver(x, y) then
      draggableCard = card
      draggableCard:startDrag(x, y)
      break
    end
  end
end

-- WHEN STOP DRAGGING CARD --
function stop_drag(x, y)
    draggableCard:stopDrag(x, y)
    draggableCard = nil  
end

-- DRAWING DRAGGED CARD --
function dragged_card_draw() 
  love.graphics.setColor(COLORS.GOLD)
  if draggableCard ~= nil then
    draggableCard:draw()
  end
end

-- CHECK IF OVER END TURN BUTTON -- 
function end_button_isOver(mouseX, mouseY)
  local end_sx = endButton:getWidth() * end_scale
  local end_sy = endButton:getHeight() * end_scale
  
  return mouseX > end_x and mouseX < end_x + end_sx and
           mouseY > end_y and mouseY < end_y + end_sy
end

-- RESTART GAME --
function restartGame()
  math.randomseed(os.time())
  
  -- Create Deck --
  local me_deck2 = Deck:new(cardData, width*0.025, height*0.78)
  me_deck:shuffle()
  local opp_deck2 = Deck:new(cardData, width*0.875, height*0.01)
  opp_deck:shuffle()
  
  game = Game:new(me_deck2, opp_deck2)
  
  ai = AI:new(game.opponent, game.board)
  state = "player_turn"
  hasWon = false
  cont_over = false

end

-- CHECK IF OVER CONTINUE BUTTON -- 
function cont_button_isOver(mouseX, mouseY)
  local cont_sx = title_font:getWidth("Continue?")
  local cont_sy = title_font:getHeight()
  local cont_x  = (width - cont_sx) * 0.5
  local cont_y  = height*0.75
  
  return mouseX > cont_x and mouseX < cont_x + cont_sx and
           mouseY > cont_y and mouseY < cont_y + cont_sy
end