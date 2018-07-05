preferences = nil

modules = script.Parent
items = modules.Parent.Items

event = items.Event
broadcast = items.Broadcast
invoke = items.Invoke

module = {
	Install = function(product)
		product.Source.Parent = nil
		preferences = product.Preferences

		local machines = preferences.Machines
		for _,machine in pairs (machines:GetChildren()) do
			module.InstallMachine(preferences,machine)
		end

		broadcast:Fire(
			"Client","Install",script.Name
		)
	end,

	InstallMachine = function(preferences,machine)
		local ready = true
		local touch = machine:FindFirstChild("Touch")
		if touch then
			if module.Functions[machine.Name] then
				module.Functions[machine.Name](machine)
			else
				touch.Touched:Connect(function(handle)
					if ready == true then
						ready = false
						module.MachineTouched(machine,touch,handle)
						delay(2,function()
							ready = true
						end)
					end
				end)
			end
		end
	end,

	MachineTouched = function(machine,touch,handle)
		local tool = handle.Parent
		if not tool.ClassName == "Tool" then return end
		local player = game.Players:GetPlayerFromCharacter(tool.Parent)
		if not player then return end

		local bool,arg = pcall(function()
			module.Modes[machine.Name](tool,player)
			local sound = touch:FindFirstChildOfClass("Sound")
			if sound then
				sound:Stop()
				wait()
				sound:Play()
			end
		end)
		if bool == false then
			warn(arg)
		end
	end,

	GetWords = function(msg, pattern)
		local words = {}
		for w in string.gmatch(msg, pattern) do
			table.insert(words,w)
		end
		return words
	end,

	FillCup = function(tool,color,alpha,name)
		if tool:FindFirstChild("Liquid") then
			tool.Liquid.BrickColor = color
			tool.Liquid.Transparency = alpha
		end
		if name then
			tool.Name = name
		end
	end,

	Modes = {
		["Flavors"] = function(tool,player)
			event:Fire(
				player,script.Name,"Select","Flavors"
			)
		end,
		["Juice"] = function(tool,player)
			event:Fire(
				player,script.Name,"Select","Juice"
			)
		end,
		["Beverages"] = function(tool,player)
			event:Fire(
				player,script.Name,"Select","Beverages"
			)
		end,
		["Espresso"] = function(tool,player)
			if tool.Name == "Cup" then
				module.FillCup(
					tool,BrickColor.new("Pine Cone"),0,"Espresso"
				)
			elseif tool.Name == "Milk" then
				module.FillCup(
					tool,BrickColor.new("Burlap"),0,"Cappuccino"
				)
			end
		end,
		["Regular"] = function(tool,player)
			if tool.Name == "Cup" then
				module.FillCup(
					tool,BrickColor.new("Pine Cone"),0,"Regular"
				)
			end
		end,
		["Decaf"] = function(tool,player)
			if tool.Name == "Cup" then
				module.FillCup(
					tool,BrickColor.new("Pine Cone"),0,"Decaf"
				)
			end
		end,
		["Tea"] = function(tool,player)
			if tool.Name == "Cup" then
				module.FillCup(
					tool,BrickColor.new("White"),0.8,"Tea"
				)
			end
		end,
		["Foam"] = function(tool,player)
			if tool.Name == "Espresso" then
				module.FillCup(
					tool,BrickColor.new("Pine Cone"),0,"Frappe"
				)
			elseif tool.Name == "Latte" then
				module.FillCup(
					tool,BrickColor.new("Burlap"),0,"Flat White"
				)
			end
		end,
		["Marshmallows"] = function(tool,player)
			if tool.Name == "Hot Chocolate" then
				module.FillCup(
					tool,BrickColor.new("Pine Cone"),0,"Hot Chocolate with Marshmallows"
				)
			end
		end,
		["Ice"] = function(tool,player)
			if tool.Name == "Espresso" then
				module.FillCup(
					tool,BrickColor.new("Burlap"),0,"Americano"
				)
			elseif tool.Name == "Mocha" then
				module.FillCup(
					tool,BrickColor.new("Burlap"),0,"Iced Mocha"
				)
			elseif tool.Name == "Tea" then
				module.FillCup(
					tool,BrickColor.new("White"),0.8,"Iced Tea"
				)
			elseif tool.Name == "Cup" then
				module.FillCup(
					tool,BrickColor.new("White"),0.2,"Ice"
				)
			elseif tool.Name == "Water" then
				module.FillCup(
					tool,BrickColor.new("White"),0.2,"Water with Ice"
				)
			end
		end,
		["Water"] = function(tool,player)
			if tool.Name == "Cup" then
				module.FillCup(
					tool,BrickColor.new("Baby blue"),0.7,"Water"
				)
			end
		end,
		["Milk"] = function(tool,player)
			if tool.Name == "Cup" then
				module.FillCup(
					tool,BrickColor.new("White"),0,"Milk"
				)
			elseif tool.Name == "Espresso" then
				module.FillCup(
					tool,BrickColor.new("Pastel brown"),0,"Latte"
				)
			end
		end,
		["Milk Steamer"] = function(tool,player)
			if tool.Name == "Milk" then
				module.FillCup(
					tool,BrickColor.new("White"),0,"Steamed Milk"
				)
			end
		end,
		["Cream"] = function(tool,player)
			if tool.Name == "Espresso" then
				module.FillCup(
					tool,BrickColor.new("Pastel brown"),0,"Macchiato"
				)
			elseif tool.Name == "Hot Chocolate" then
				module.FillCup(
					tool,BrickColor.new("Pine Cone"),0,"Hot Chocolate with Cream"
				)
			elseif tool.Name == "Decaf" then
				module.FillCup(
					tool,BrickColor.new("Burlap"),0,"Decaf with Cream"
				)
			end
		end,
		["Mixer"] = function(tool,player)
			local Words = module.GetWords(tool.Name,"%a+")
			if preferences.Types.Flavors[Words[1]] and Words[2] == "Milk" then
				module.FillCup(
					tool,preferences.Types.Flavors[Words[1]],0,Words[1].." Milkshake"
				)
			end
		end,
		["Blender"] = function(tool,player)
			if tool.Name == "Ice" then
				module.FillCup(
					tool,BrickColor.new("White"),0.5,"Crushed Ice"
				)
			else
				local words = module.GetWords(tool.Name,"%a+")
				if words[1] == "Crushed" and words[2] == "Ice" then
					if preferences.Types.Juice[words[3]] then
						module.FillCup(
							tool,preferences.Types.Juice[words[3]],0,words[3].." Slushie"
						)
					end
				elseif preferences.Types.Flavors[words[1]] and words[2] == "Milk" then
					module.FillCup(
						tool,preferences.Types.Flavors[words[1]],0.5,words[1].." Smoothie"
					)
				end
			end
		end,
		["Mocha Sauce"] = function(tool,player)
			if tool.Name == "Latte" then
				module.FillCup(tool,BrickColor.new("Pine Cone"),0,"Mocha")
			elseif tool.Name == "Steamed Milk" then
				module.FillCup(tool,BrickColor.new("Pine Cone"),0,"Hot Chocolate")
			end
		end,
		["Green Tea"] = function(tool,player)
			if tool.Name == "Tea" then
				module.FillCup(tool,BrickColor.new("Earth green"),0.5,"Green Tea")
			end
		end,
		["White Tea"] = function(tool,player)
			if tool.Name == "Tea" then
				module.FillCup(tool,BrickColor.new("Buttermilk"),0.5,"White Tea")
			end
		end,
		["Black Tea"] = function(tool,player)
			if tool.Name == "Tea" then
				module.FillCup(tool,BrickColor.new("Black"),0.5,"Black Tea")
			end
		end,
		["IceCream"] = function(tool,player)
			event:Fire(
				player,script.Name,"Select","Ice Cream"
			)
		end,
	},

	Functions = {
		["CupGiver"] = function(machine)
			local touch = machine.Touch
			if touch:FindFirstChildOfClass("ClickDetector") then
				touch.ClickDetector.MouseClick:Connect(function(player)
					local sound = touch:FindFirstChildOfClass("Sound")
					if sound then
						sound:Stop()
						wait()
						sound:Play()
					end
					local cup = machine.Cup:Clone()
					local handle = cup:WaitForChild("Handle")
					local tool = Instance.new("Tool",player.Backpack)
					tool.Name = "Cup"
					tool.CanBeDropped = false

					for _,part in pairs(cup:GetChildren()) do
						if part.Name ~= "Handle" then
							local weld = Instance.new("Weld",part)
							weld.Part0 = part
							weld.Part1 = handle
							weld.C0 = part.CFrame:inverse()
							weld.C1 = handle.CFrame:inverse()
						end
						part.Anchored = false
						part.Parent = tool
					end
					cup:Destroy()

					local drink = script.Drink:Clone()
					drink.Parent = tool
					drink.Disabled = false
				end)
			end
		end,

		["ConeGiver"] = function(machine)
			local Touch = machine.Touch
			if Touch:FindFirstChildOfClass("ClickDetector") then
				Touch.ClickDetector.MouseClick:Connect(function(player)
					local sound = Touch:FindFirstChildOfClass("Sound")
					if sound then
						sound:Stop()
						wait()
						sound:Play()
					end
					local cone = machine.Cone:Clone()
					local handle = cone:WaitForChild("Handle")
					local tool = Instance.new("Tool",player.Backpack)
					tool.Name = "Cone"
					tool.CanBeDropped = false

					for _,part in pairs(cone:GetChildren()) do
						if part.Name ~= "Handle" then
							local weld = Instance.new("Weld",part)
							weld.Part0 = part
							weld.Part1 = handle
							weld.C0 = part.CFrame:inverse()
							weld.C1 = handle.CFrame:inverse()
						end
						part.Anchored = false
						part.Parent = tool
					end
					local drink = script.Drink:Clone()
					drink.Parent = tool
					drink.Disabled = false
				end)
			end
		end,
	},

	RemoteFunctions = {
		GetPreferences = function(player)
			return preferences
		end,

		Selected = function(player,typ,name)
			if preferences.Types[typ][name] then
				local tool = player.Character:FindFirstChildOfClass("Tool")
				if not tool then return end

				if typ == "Beverages" then
					if tool.Name == "Cup" then
						module.FillCup(tool,preferences.Types[typ][name],0,name)
					end
				elseif typ == "Flavors" then
					if
					(
						tool.Name == "Frappe" or
						tool.Name == "Milk" or
						tool.Name == "Latte" or
						tool.Name == "Cappuccino" or
						tool.Name == "Macchiato" or
						tool.Name == "Steamed Milk"
					)
					then
						tool.Name = name.." "..tool.Name
					end
				elseif typ == "Juice" then
					if tool.Name == "Water" then
						module.FillCup(
							tool,preferences.Types[typ][name],0.5,name.." Juice"
						)
					elseif tool.Name == "Crushed Ice" then
						module.FillCup(
							tool,preferences.Types[typ][name],0.5,"Crushed Ice "..name
						)
					end
				elseif typ == "Ice Cream" then
					if tool.Name == "Cone" then
						tool.Name = name.." Cream"
						if tool:FindFirstChild("Cream") then
							tool.Cream.Transparency = 0
							tool.Cream.Material = Enum.Material.Sand
							tool.Cream.BrickColor = preferences.Types[typ][name]
						end
					end
				end
			end
		end
	}
}

return module
