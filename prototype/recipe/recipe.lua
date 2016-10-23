for i1, material in ipairs(materials) do
	for i2, size in ipairs(sizes) do
		for i3, symbol in ipairs(symbols) do
			local recipe = { 
				type = "recipe",
				name = size.."-"..material.."-"..symbol,
				icon = "__textplates__/graphics/icon/"..size.."/"..material.."_"..symbol..".png",
				category = "crafting",
				enabled = true,
				energy_required = 0.25,
				ingredients = {{type="item", name=size.."-"..material.."-blank", amount=1}},
				results= {{type="item", name=size.."-"..material.."-"..symbol, amount=1}},
			}
			if(symbol == "blank")then
				if(material == "copper") then  
					recipe.ingredients = {{type="item", name="copper-plate", amount=1}}
				else 
					recipe.ingredients = {{type="item", name="iron-plate", amount=1}}
				end
				recipe.energy_required = 0.5
				if(size == "large") then
					recipe.ingredients[1].amount = 4
					recipe.energy_required = 1
				end
			else 
				if(size == "large") then
					recipe.energy_required = 0.5
				end
			end
			data:extend({recipe})
		end
	end
end
