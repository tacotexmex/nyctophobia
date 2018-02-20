-- Vars
local timer = 0
local hudbars = minetest.get_modpath("hudbars") or false

-- Functions
minetest.register_on_joinplayer(function(player)
  if hudbars then hb.init_hudbar(player, "sanity") end
  player:set_attribute("sanity", 20)
end)

minetest.register_on_respawnplayer(function(player)
  player:set_attribute("sanity", 20)
end)

-- Registrations
if hudbars then
  hb.register_hudbar("sanity",
    0xFFFFFF,
    "Sanity",
    { bar = "nyctophobia_bar.png", icon = "nyctophobia_icon.png", bgicon = "nyctophobia_icon.png" },
    20, 20,
    false)
end

minetest.register_globalstep(function(dtime)
  timer = timer + dtime
  if timer >= 1 then
    for _,player in ipairs(minetest.get_connected_players()) do
      local sanity = tonumber(player:get_attribute("sanity"))
      local pos = player:getpos()
        pos.y = math.floor(pos.y) + 1.5
      local light = minetest.get_node_light(pos)
      if light < 9 and sanity > 0 then
        sanity = sanity - 1
      elseif light >= 9 and sanity < 20 then
        sanity = sanity + 1
      end
      if sanity == 0 then
        player:set_hp(player:get_hp() - 1)
      end
      if hudbars then
        hb.change_hudbar(player, "sanity", sanity)
      end
      player:set_attribute("sanity", tostring(math.floor(sanity)))
    end
    timer = 0
  end
end)
