local count = 0
for i1, material in ipairs(materials) do
	for i2, size in ipairs(sizes) do
		for i3, symbol in ipairs(symbols) do
			count = count + 1
			item = { 
					type = "item",
					name = size.."-"..material.."-"..symbol,
					icon = "__textplates__/graphics/icon/"..size.."/"..material.."_"..symbol..".png",
					flags = {"goes-to-quickbar"},
					subgroup = "text-plates-symbols",
					order = "e[tileplates]-"..string.format( "%03d", count ),
					stack_size = 50,
					place_result = size.."-"..material.."-"..symbol,
				}
			if(symbol == "blank") then
				item.subgroup = "text-plates-blanks"
			end
			data:extend({ item })
		end
	end
end
