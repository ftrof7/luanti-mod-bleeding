bleeding = {}

local bleeding_path = minetest.get_modpath("bleeding")

local S = minetest.get_translator("bleeding")

bleeding.get_translator = S
bleeding.bleeding = {}

dofile(bleeding_path.."/medecine.lua")

local effects = {
    {text = "bleeding_screen1.png", speed = 0.9},
    {text = "bleeding_screen2.png", speed = 0.75},
    {text = "bleeding_screen3.png", speed = 0.55},
    {text = "bleeding_screen4.png", speed = 0.2},
}

local spawn_blood_particles = function(pos, amount)
    minetest.add_particlespawner({
        amount = amount,
        time = 0.5,
        minpos = vector.subtract(pos, {x=0.2, y=0.2, z=0.2}),
        maxpos = vector.add(pos, {x=0.2, y=0.2, z=0.2}),
        minvel = {x=-2, y=3, z=-2},
        maxvel = {x=2, y=5, z=2},
        minacc = {x=0, y=-9.81, z=0},
        maxacc = {x=0, y=-9.81, z=0},
        minsize = 1,
        maxsize = 2,
        texture = "bleeding_particle.png",
        collisiondetection = true,
        collision_removal = true,
        vertical = false,
    })
end

local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 1.3 then
        timer = 0
        for key, value in pairs(bleeding.bleeding) do
            local player = minetest.get_player_by_name(key)
            if value.bleeding then
                player:set_hp(player:get_hp() - 1)
                spawn_blood_particles(player:get_pos(), 10)
                if bleeding.bleeding[key] and bleeding.bleeding[key].bleeding <= 1 then
                    bleeding.bleeding[key].bleeding = nil
                else
                    bleeding.bleeding[key].bleeding = bleeding.bleeding[key].bleeding - 1
                end
            end
        end
    end
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    local name = player:get_player_name()
 
    if hp_change >= 0 or math.abs(hp_change) > player:get_hp() then return end

    local name = player:get_player_name()
    local damage = math.abs(hp_change)
    local pos = player:get_pos()
    local stage = 0
    local speed_before = player:get_physics_override().speed

    if damage < 4 then
        stage = 1
    elseif damage < 9 then
        stage = 2
        spawn_blood_particles(pos, 10)
    elseif damage < 14 then
        stage = 3
        spawn_blood_particles(pos, 23)
    else
        stage = 4
        spawn_blood_particles(pos, 32)
    end
    if bleeding.bleeding[name] then
        return
    end
    bleeding.bleeding[name] = {}
    bleeding.bleeding[name].stage = stage
    bleeding.bleeding[name].hud = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.5, y = 0.5},
		scale = {x = -100,y = -100},
		text = effects[stage].text,
		alignment = {x = 0, y = 0},
		offset = {x = 0, y = 0}
	})

    for i = stage, 1, -1 do
        if i > 1 then
            bleeding.bleeding[name].bleeding = i + (bleeding.bleeding[name].bleeding or 0)
        end
        minetest.after(2 * (stage - i + 1), function()
            if bleeding.bleeding[name] then
                player:hud_change(bleeding.bleeding[name].hud, "text", effects[i].text)
            end
        end)
    end

    minetest.after(2*stage+1, function()
        if bleeding.bleeding[name] then
            player:hud_remove(bleeding.bleeding[name].hud)
            bleeding.bleeding[name] = nil 
        end
    end)
end)

minetest.register_on_respawnplayer(function(player)
    local name = player:get_player_name()
    if bleeding.bleeding[name] then
        player:hud_remove(bleeding.bleeding[name].hud)
        bleeding.bleeding[name] = nil
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if bleeding.bleeding[name] then
        bleeding.bleeding[name] = nil
    end
end)