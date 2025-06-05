
-- CONFIGURATION --

   -- Size of Display --
width  = 1200
height = 900

   -- Dimentions of Card Images --
img_width = 39
img_height = 64

   -- Scale of Cards --
scale = 2.2

   -- Set Random Seed --
seed = os.time() -- [default: 5 for testing, os.time() for main use]

   -- Target Points --
target_points = 25 -- [default: 25] 

   -- End Button Options --
end_x = width*0.9
end_y = height*0.9
end_scale = 0.15


-- ENUMS --

   -- File Locations --
FILE_LOCATIONS = {
  EMPTY = "Sprites/Empty.png",
  BACK  = "Sprites/Card Back.png",
  END   = "Sprites/end.png",
  CSV   = "Resources/Tapesh Sankaran Project 3 Card Table - Sheet1.csv",
  FONT1 = "Resources/Fighting Spirit 2 bold.otf",
  FONT2 = "Resources/JMH Typewriter-Thin.ttf",
}

   -- Colors --
COLORS = {
  WHITE        = {1, 1, 1},
  BLACK        = {0, 0, 0},
  RED          = {1, .3, .3},
  BLUE         = {.3, .5, 1},
  DARK_BLUE    = {.2, .3, 0.8},
  DARK_RED     = {0.7, 0, 0},
  DARK_GREEN   = {.18, .302, .255},
  DARKER_GREEN = {.1, .240, .210},
  DARK_GOLD    = {0.95, 0.810, 0.2},
  GOLD         = {1.00, 0.860, 0.25},
  LIGHT_GOLD   = {1.00, .922, .502},
}

   -- 33 zeros --
LIST = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}


-- GLOBAL VARS --
game = {}
ai = {}
cardData = {}
hasWon = false
cont_over = false

-- USEFUL FUNCTIONS --
function indexOf(tbl, val)
  for i, v in ipairs(tbl) do
    if v == val then return i end
  end
  return nil  -- Not found
end
