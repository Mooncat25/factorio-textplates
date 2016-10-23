 require("plate-types")

function on_player_cursor_stack_changed(event)
	player=game.players[event.player_index]
	if player.cursor_stack and player.cursor_stack.valid and player.cursor_stack.valid_for_read and is_blank_plate(player.cursor_stack.name)then
		show_gui(player, player.cursor_stack.name)
	else
		hide_gui(player)
	end
end 

function is_blank_plate(item_name)
	for i1, material in ipairs(materials) do
		for i2, size in ipairs(sizes) do
			if item_name == size .. "-" .. material .. "-blank" then
				return true
			end
		end
	end
	return false
end

function show_gui(player, item_name)
	local item_prefix = string.gsub(item_name, "-blank", "")
	
	-- remove any UIs of the other plate types
	for i1, material in ipairs(materials) do
		for i2, size in ipairs(sizes) do
			if(size.."-"..material ~= item_prefix) and player.gui.left[size.."-"..material] ~= nil then
				player.gui.left[size.."-"..material].destroy()
			end
		end
	end
	
	-- add the desired plate type UI
	if player.gui.left[item_prefix] == nil then
		local plate_frame = player.gui.left.add{type = "frame", name = item_prefix, caption = {"text-plate-ui-title"}, direction = "vertical"}
		local plates_table = plate_frame.add{type ="table", name = "plates_table", colspan = 6, style = "plates-table"}
		
		for i3, symbol in ipairs(symbols) do
			local plate_option = item_prefix.."-"..symbol
			if(symbol == "blank") then
				plates_table.add{type = "sprite-button", name = plate_option, sprite="item/"..plate_option, style="plates-button-active"}
			else
				plates_table.add{type = "sprite-button", name = plate_option, sprite="item/"..plate_option, style="plates-button"}
			end
		end
		
		local plates_input_label = plate_frame.add{type ="label", name = "plates_input_label", caption={"text-plate-input-label"}}
		local plates_input = plate_frame.add{type ="textfield", name = "plates_input"}
		
		prep_player_plate_options(player.index)
		global.plates_players[player.index][item_prefix] = item_prefix.."-blank"
		
	end
end

function hide_gui(player)
	for i1, material in ipairs(materials) do
		for i2, size in ipairs(sizes) do
			if player.gui.left[size.."-"..material] ~= nil then
				player.gui.left[size.."-"..material].destroy()
			end
		end
	end
end

function on_gui_click(event)
	local player_index = event.player_index
	local player = game.players[player_index]
	if event.element.parent and event.element.parent.name == "plates_table" then
		for i1, material in ipairs(materials) do
			for i2, size in ipairs(sizes) do
				for i3, symbol in ipairs(symbols) do
					if event.element.name == size.."-"..material.."-"..symbol then
						-- uncheck others
						for _,buttonname in ipairs(event.element.parent.children_names) do
							event.element.parent[buttonname].style = "plates-button"
						end
						-- check self
						event.element.style = "plates-button-active"
						prep_player_plate_options(player_index)
						global.plates_players[player_index][size.."-"..material] = event.element.name
						if(player.gui.left[size.."-"..material].plates_input) then
							player.gui.left[size.."-"..material].plates_input.text = ""
						end
					end
				end
			end
		end
	end
end

function on_gui_text_changed(event)
	if(event.element.name == "plates_input") then
		prep_next_symbol(event.player_index)
	end
end

function prep_next_symbol(player_index)
	local player = game.players[player_index]
	for i1, material in ipairs(materials) do
		for i2, size in ipairs(sizes) do
			if player.gui.left[size.."-"..material] and player.gui.left[size.."-"..material].plates_input and player.gui.left[size.."-"..material].plates_table then
				prep_player_plate_options(player_index)
				local text = player.gui.left[size.."-"..material].plates_input.text
				if string.len(text) > 0 then 
					local first_char = string.sub(text, 1, 1)
					local next_name = size.."-"..material.."-"..item_suffix_from_char(first_char)
					for _,buttonname in ipairs(player.gui.left[size.."-"..material].plates_table.children_names) do
						player.gui.left[size.."-"..material].plates_table[buttonname].style = "plates-button"
					end
					player.gui.left[size.."-"..material].plates_table[next_name].style = "plates-button-active"
					global.plates_players[player_index][size.."-"..material] = next_name
				else
					for _,buttonname in ipairs(player.gui.left[size.."-"..material].plates_table.children_names) do
						player.gui.left[size.."-"..material].plates_table[buttonname].style = "plates-button"
					end
					player.gui.left[size.."-"..material].plates_table[size.."-"..material.."-blank"].style = "plates-button-active"
					global.plates_players[player_index][size.."-"..material] = size.."-"..material.."-blank"
				end
			end
		end
	end
end

function prep_player_plate_options(player_index) 
	if not global.plates_players then
		global.plates_players = {}
	end
	if not global.plates_players[player_index] then
		global.plates_players[player_index] = {}
	end
end

function on_built_entity (event)
	local player_index = event.player_index
	local player = game.players[player_index]
	local entity = event.created_entity
	if entity.valid then -- in case of other scripts
		if entity.name == "entity-ghost" then
			if player.cursor_stack and player.cursor_stack.valid and player.cursor_stack.valid_for_read and is_blank_plate(player.cursor_stack.name) then
				for i1, material in ipairs(materials) do
					for i2, size in ipairs(sizes) do
						if entity.ghost_name == size.."-"..material.."-blank" then
							prep_player_plate_options(player_index)
							local replace_name = entity.ghost_name
							-- loaded value
							if global.plates_players[player_index][size.."-"..material] then 
								replace_name = global.plates_players[player_index][size.."-"..material]
							end
							-- sequence
							if player.gui.left[size.."-"..material] and player.gui.left[size.."-"..material].plates_input then
								local text = player.gui.left[size.."-"..material].plates_input.text
								if string.len(text) > 0 then 
									local first_char = string.sub(text, 1, 1)
									local remainder = string.sub(text, 2, -1)
									player.gui.left[size.."-"..material].plates_input.text = remainder
									replace_name = size.."-"..material.."-"..item_suffix_from_char(first_char)
									prep_next_symbol(player_index)
								end
							end
							
							if replace_name ~= entity.name then 
								-- replace
								entity.get_control_behavior().parameters={parameters={{signal={type="item",name=replace_name},count=0,index=1}}}
								return
							end
						end
					end
				end
			else
				for i1, material in ipairs(materials) do
					for i2, size in ipairs(sizes) do
						for i3, symbol in ipairs(symbols) do
							if symbol ~= "blank" and entity.ghost_name == size.."-"..material.."-"..symbol then
								local replacement = entity.surface.create_entity{ name="entity-ghost", inner_name=size.."-"..material.."-blank", position=entity.position, force=entity.force}
								replacement.get_control_behavior().parameters={parameters={{signal={type="item",name=entity.ghost_name},count=0,index=1}}}
								entity.destroy()
								return
							end
						end
					end
				end
			end
		else
			for i1, material in ipairs(materials) do
				for i2, size in ipairs(sizes) do
					if entity.name == size.."-"..material.."-blank" then
						prep_player_plate_options(player_index)
						local replace_name = entity.name
						-- loaded value
						if global.plates_players[player_index][size.."-"..material] then 
							replace_name = global.plates_players[player_index][size.."-"..material]
						end
						-- sequence
						if player.gui.left[size.."-"..material] and player.gui.left[size.."-"..material].plates_input then
							local text = player.gui.left[size.."-"..material].plates_input.text
							if string.len(text) > 0 then 
								local first_char = string.sub(text, 1, 1)
								local remainder = string.sub(text, 2, -1)
								player.gui.left[size.."-"..material].plates_input.text = remainder
								replace_name = size.."-"..material.."-"..item_suffix_from_char(first_char)
								prep_next_symbol(player_index)
							end
						end
						
						if replace_name ~= entity.name then 
							-- replace
							local replacement = entity.surface.create_entity{ name=replace_name,  position=entity.position, force=entity.force}
							entity.destroy()
							return
						end
					end
				end
			end
		end
	end
end

function on_robot_built_entity (event)
	local entity = event.created_entity
	if entity.valid then -- in case of other scripts
		for i1, material in ipairs(materials) do
			for i2, size in ipairs(sizes) do
				if entity.name == size.."-"..material.."-blank" then
					local replace_name = entity.get_control_behavior().parameters.parameters[1].signal.name
					for i3, symbol in ipairs(symbols) do
						if replace_name == size.."-"..material.."-"..symbol then 
							local replacement = entity.surface.create_entity{ name=replace_name, position=entity.position, force=entity.force}
							entity.destroy()
							return
						end
					end
				end
			end
		end
	end
end

function on_entity_died (event)
	local entity = event.entity
	if entity.valid then -- in case of other scripts
		for i1, material in ipairs(materials) do
			for i2, size in ipairs(sizes) do
				for i3, symbol in ipairs(symbols) do
					if entity.name == size.."-"..material.."-"..symbol then
						local replacement = entity.surface.create_entity{ name="entity-ghost", inner_name=size.."-"..material.."-blank", position=entity.position, force=entity.force}
						replacement.get_control_behavior().parameters={parameters={{signal={type="item",name=entity.name},count=0,index=1}}}
						entity.destroy()
						return
					end
				end
			end
		end
	end
end

function item_suffix_from_char(character)
	local uc = string.lower(character)
	if 		uc == "a" 
		or 	uc == "b" 
		or 	uc == "c" 
		or 	uc == "d" 
		or 	uc == "e" 
		or 	uc == "f" 
		or 	uc == "g" 
		or 	uc == "h" 
		or 	uc == "i" 
		or 	uc == "j" 
		or 	uc == "k" 
		or 	uc == "l" 
		or 	uc == "m" 
		or 	uc == "n" 
		or 	uc == "o" 
		or 	uc == "p" 
		or 	uc == "q" 
		or 	uc == "r" 
		or 	uc == "s" 
		or 	uc == "t" 
		or 	uc == "u" 
		or 	uc == "v" 
		or 	uc == "w" 
		or 	uc == "x" 
		or 	uc == "y" 
		or 	uc == "z" 
		or 	uc == "0" 
		or 	uc == "1" 
		or 	uc == "2" 
		or 	uc == "3" 
		or 	uc == "4" 
		or 	uc == "5" 
		or 	uc == "6" 
		or 	uc == "7" 
		or 	uc == "8" 
		or 	uc == "9" then
			return uc
	elseif uc == "^" then
		return "hat"
	elseif uc == "@" then
		return "at"
	elseif uc == "." then
		return "stop"
	elseif uc == "," or uc == "'" or uc == "\"" then
		return "comma"
	elseif uc == ":" or uc == ";" then
		return "colon"
	elseif uc == "(" or uc == "[" or uc == "{" then
		return "bracket_left"
	elseif uc == ")" or uc == "]" or uc == "}" then
		return "bracket_right"
	elseif uc == "<"  then
		return "less"
	elseif uc == ">"  then
		return "greater"
	elseif uc == "/" or uc == "\\" then
		return "divide"
	elseif uc == "|" then
		return "pipe"
	elseif uc == "%" then
		return "percent"
	elseif uc == "*" then
		return "multiply"
	elseif uc == "+" then
		return "plus"
	elseif uc == "-" or uc == "_" or uc == " " then
		return "minus"
	elseif uc == "=" then
		return "equals"
	elseif uc == "&" then
		return "ampersand"
	elseif uc == "?" then
		return "question"
	elseif uc == "!" then
		return "exclamation"
	end
	return "blank"
end
	
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
script.on_event(defines.events.on_gui_text_changed, on_gui_text_changed)
script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_robot_built_entity)
script.on_event(defines.events.on_entity_died, on_entity_died)