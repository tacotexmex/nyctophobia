-- Vars
local timer = 0
local hudbars = minetest.get_modpath("hudbars") or false

-- Functions

-- Registrations
minetest.register_on_joinplayer(function(player)
	if hudbars then hb.init_hudbar(player, "sanity") end
	player:set_attribute("sanity", 20)
end)

minetest.register_on_respawnplayer(function(player)
	player:set_attribute("sanity", 20)
end)

if hudbars then
	hb.register_hudbar("sanity",
		0xFFFFFF,
		"Sanity",
		{ bar = "nyctophobia_bar.png",
			icon = "nyctophobia_icon.png",
			bgicon = "nyctophobia_icon.png" },
		20, 20,
		false)
end

minetest.register_privilege("sane", {
	description = "Immune to nyctophobia",
	give_to_singleplayer = false,
})

minetest.register_on_priv_grant(function(name, granter, priv)
	if priv == "sane" then
		local player = minetest.get_player_by_name(name)
		player:set_attribute("sanity", 20)
		if hudbars then hb.change_hudbar(player, "sanity", 20) end
	end
end)

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= 4 then
		for _,player in ipairs(minetest.get_connected_players()) do
			if not minetest.check_player_privs(player, "sane") then
				local sanity = tonumber(player:get_attribute("sanity"))
				local pos = player:getpos()
					pos.y = math.floor(pos.y) + 1.5
				local light = minetest.get_node_light(pos)
				if light < 6 and sanity > 0 then
					sanity = sanity - 1
				elseif light >= 10 and sanity < 20 then
					sanity = sanity + 1
				end
				if sanity == 0 then
					player:set_hp(player:get_hp() - 1)
				end
				if hudbars then hb.change_hudbar(player, "sanity", sanity) end
				player:set_attribute("sanity", sanity)
			end
		end
		timer = 0
	end
end)
