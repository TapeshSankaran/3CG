
-- Abilities --

local Config = require "conf"

ABILITIES = {
  
  ["Wooden Cow"] = nil,
  ["Pegasus"]    = nil,
  ["Minotaur"]   = nil,
  ["Titan"]      = nil,
  
  ["Zeus"] = {
    onReveal = function(card)
      local player = card.owner == game.player and game.opponent or game.player
      for _, c in ipairs(player.hand) do
        c.power = c.power - 1
      end
    end
  },

  ["Ares"] = {
    onReveal = function(card)
      if card.field ~= nil then
        local slots = card.owner == game.player and card.field.opponent_slots or card.field.player_slots
        card.power = card.power + #slots * 2
      end
    end
  },

  ["Medusa"] = {
    onPlay = function(card, c)
      print("hello")
      c.power = (tonumber(c.power) > 0 and c ~= card) and c.power - 1 or c.power
    end
  },

  ["Cyclops"] = {
    onReveal = function(card)
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      local toRemove = {}
      for _, c in ipairs(slots) do
        if c ~= card then
          table.insert(toRemove, c)
          card.power = card.power + 2
        end
      end
      for _, c in ipairs(toRemove) do
        card.field:removeCard(card.owner, c)
      end
    end
  },

  ["Poseidon"] = {
    onReveal = function(card)
      local enemy_slots = card.owner == game.player and card.field.opponent_slots or card.field.player_slots
      local weakest, index = nil, nil
      local enemy = card.owner == game.player and game.opponent or game.player
      for i, c in ipairs(enemy_slots) do
        if not weakest or tonumber(c.power) < tonumber(weakest.power) then
          weakest = c
          index = i
        end
      end
      if weakest then
        game.board:moveCard(weakest.owner, weakest)
      end
    end
  },

  ["Artemis"] = {
    onReveal = function(card)
      local enemy_slots = card.owner == game.player and card.field.opponent_slots or card.field.player_slots
      if #enemy_slots == 1 then
        card.power = card.power + 5
      end
    end
  },

  ["Hera"] = {
    onReveal = function(card)
      for _, c in ipairs(card.owner.hand) do
        c.power = c.power + 1
      end
    end
  },

  ["Demeter"] = {
    onReveal = function(card)
      card.owner:drawCard()
      game.opponent:drawCard()
    end
  },

  ["Hades"] = {
    onReveal = function(card)
      card.power = card.power + #card.owner.discard_pile*2
    end
  },

  ["Hercules"] = {
    onReveal = function(card)
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      local strongest = card
      for _, c in ipairs(slots) do
        if c.power > strongest.power then return end
      end
      if strongest == card then
        card.power = card.power * 2
      end
    end
  },

  ["Dionysus"] = {
    onReveal = function(card)
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      card.power = card.power + (#slots - 1) * 2
    end
  },

  ["Hermes"] = {
    onReveal = function(card)
      game.board:moveCard(card.owner, card)
    end
  },

  ["Hydra"] = {
    onDiscard = function(card)
      local hydra = cardData[17]
      local c = game:createCard(hydra, true)
      card.owner:addCard(c)
      card.owner:addCard(c)
    end
  },

  ["Ship of Theseus"] = {
    onReveal = function(card)
      local ship_of_theseus = cardData[18]
      ship_of_theseus = game:createCard(ship_of_theseus, true)
      ship_of_theseus.owner = card.owner
      ship_of_theseus.power = ship_of_theseus.power + 1
      card.owner:addCard(ship_of_theseus)
    end
  },

  ["Sword of Damocles"] = {
    onEoT = function(card)
      if not card.field:isWinning(card.owner) then
        card.power = card.power - 1
      end
    end
  },

  ["Midas"] = {
    onReveal = function(card)
      local all = {}
      for _, c in ipairs(card.field.player_slots) do table.insert(all, c) end
      for _, c in ipairs(card.field.opponent_slots) do table.insert(all, c) end
      for _, c in ipairs(all) do
        c.power = 3
      end
    end
  },

  ["Aphrodite"] = {
    onReveal = function(card)
      local enemy_slots = card.owner == game.player and card.field.opponent_slots or card.field.player_slots
      for _, c in ipairs(enemy_slots) do
        c.power = c.power - 1
      end
    end
  },

  ["Athena"] = {
    onPlay = function(card, c)
      if c ~= card and card.owner == c.owner then
        card.power = card.power + 1
      end
    end
  },

  ["Apollo"] = {
    onReveal = function(card)
      card.owner.extra = card.owner.extra + 1
    end
  },

  ["Hephaestus"] = {
    onReveal = function(card)
      for i=1,2 do
        local c = card.owner.hand[math.ceil(math.random(#card.owner.hand))]
        c.cost = c.cost - 1
      end
    end
  },

  ["Persephone"] = {
    onReveal = function(card)
      local weakest = card.owner.hand[1]
      local index = 1
      for i, c in ipairs(card.owner.hand) do
        if not weakest or tonumber(c.power) < tonumber(weakest.power) then
          weakest = c
          index = i
        end
      end
      if weakest then
        local c = card.owner:removeCard(index)
        if c then 
          c.position = Vector(-100, -100)
          table.insert(card.owner.discard_pile, c)
        end
      end
    end
  },

  ["Prometheus"] = {
    onReveal = function(card)
      local enemy = card.owner == game.player and game.opponent or game.player
      local stolen = enemy.deck:deal()
      if stolen then card.owner:addCard(stolen) end
      stolen.owner = card.owner
    end
  },

  ["Pandora"] = {
    onReveal = function(card)
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      if #slots == 1 then
        card.power = card.power - 5
      end
    end
  },

  ["Icarus"] = {
    onEoT = function(card)
      card.power = card.power + 1
      if card.power > 7 then
        card.field:removeCard(card.owner, card)
      end
    end
  },

  ["Iris"] = {
    onEoT = function(card)
      for _, field in ipairs(game.board.fields) do
        local slotList = card.owner == game.player and field.player_slots or field.opponent_slots
        for _, c in ipairs(slotList) do
          if c ~= card and ABILITIES[c.name] ~= nil then
            c.power = c.power + 1
          end
        end
      end
    end
  },

  ["Nyx"] = {
    onReveal = function(card)
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      local toRemove = {}
      for _, c in ipairs(slots) do
        if c ~= card then
          card.power = c.power + card.power
          table.insert(toRemove, c)
        end
      end
      for _, c in ipairs(toRemove) do
        card.field:removeCard(card.owner, c)
      end
    end
  },

  ["Atlas"] = {
    onEoT = function(card)
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      if #slots >= 4 then
        card.power = card.power - 1
      end
    end
  },

  ["Daedalus"] = {
    onReveal = function(card)
      for _, field in ipairs(game.board.fields) do
        local wooden_cow = cardData[1]
        field:addCard(card.owner, game:createCard(wooden_cow, true))
      end
    end
  },

  ["Helios"] = {
    onEoT = function(card)
      print(tostring(card.owner))
      card.field:removeCard(card.owner, card)
    end
  },

  ["Mnemosyne"] = {
    onReveal = function(card)
      local lastPlayed = card.owner.lastPlayedCard
      if lastPlayed then
        card.owner:addCard(lastPlayed.name)
      end
    end
  },
}
