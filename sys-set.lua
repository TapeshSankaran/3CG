
require "conf"

function System_Set() 
  -- Set Title of Window --
  love.window.setTitle("Greek Slam")
  
  -- Set Filter for Clearness --
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  -- Set Dimentions for Window --
  love.window.setMode(width, height)
  
  -- Set Color --
  love.graphics.setBackgroundColor(COLORS.DARK_GREEN)
  
  -- SET RANDOM SEED --
  math.randomseed(seed)
end
