local S = bleeding.get_translator

minetest.register_craftitem("bleeding:bandage", {
    description = S("Bandage"),
    inventory_image = "bleeding_bandage.png",
    on_use = function(itemstack, player)
        local inv = player:get_inventory()
        local name = player:get_player_name()
        if minetest.settings:get_bool("enable_damage") then
            if bleeding.bleeding[name] and bleeding.bleeding[name].bleeding then
                bleeding.bleeding[name].bleeding = 0
                player:set_hp(player:get_hp() + 1)
                inv:remove_item("main", "bleeding:bandage")
            else
                minetest.chat_send_player(name, S("-!- You have no bleeding and cannot use bandage."))
            end
        end
    end
})

minetest.register_craftitem("bleeding:bag", {
    description = S("Medecine bag"),
    inventory_image = "bleeding_bag.png",
    on_use = function(itemstack, player)
        local inv = player:get_inventory()
        if minetest.settings:get_bool("enable_damage") then
            if player:get_hp() < player:get_properties().hp_max then
                if bleeding.bleeding[name] and bleeding.bleeding[name].bleeding then
                    bleeding.bleeding[name].bleeding = 0
                end
                player:set_hp(player:get_hp() + 10)
                inv:remove_item("main", "bleeding:bag")
            else
                local name = player:get_player_name()
                minetest.chat_send_player(name, S("-!- You have full healts and cannot use medecine."))
            end
        end
    end
})

minetest.register_craftitem("bleeding:syringe_empty", {
    description = S("Syringe empty"),
    inventory_image = "bleeding_syringe_empty.png",
    on_use = function(itemstack, player)
        local inv = player:get_inventory()
        if minetest.settings:get_bool("enable_damage") then
            if player:get_hp() > 2 then
                player:set_hp(player:get_hp() - 2)
                inv:remove_item("main", "bleeding:syringe_empty")
                inv:add_item("main", "bleeding:syringe_blood")
            end
        end
    end
})

minetest.register_craftitem("bleeding:syringe_blood", {
    description = S("Syringe with blood"),
    inventory_image = "bleeding_syringe_blood.png"
})

minetest.register_craftitem("bleeding:syringe_full", {
    description = S("Syringe full"),
    inventory_image = "bleeding_syringe_full.png",
    on_use = function(itemstack, player)
        local inv = player:get_inventory()
        if minetest.settings:get_bool("enable_damage") then
            if player:get_hp() < player:get_properties().hp_max then
                player:set_hp(player:get_hp() + 5)
                inv:remove_item("main", "bleeding:syringe_full")
                inv:add_item("main", "bleeding:syringe_empty")
            else
                local name = player:get_player_name()
                minetest.chat_send_player(name, S("-!- You have full healts and cannot use medecine."))
            end
        end
    end
})

minetest.register_craft({
	output = "bleeding:syringe_empty",
	recipe = {
		{"vessels:glass_bottle"},
        {"vessels:glass_fragments"},
	}
})

minetest.register_craft({
	output = "bleeding:syringe_full",
	recipe = {
		{"bleeding:syringe_blood", "dye:green"},
        {"default:sapling", ""},
	}
})

minetest.register_craft({
	output = "bleeding:bag",
	recipe = {
		{"wool:dark_green", "bleeding:syringe_full"},
        {"bleeding:bandage", "bleeding:bandage"},
	}
})

minetest.register_craft({
	output = "bleeding:bandage",
	recipe = {
        {"wool:white", "wool:white"},
	}
})