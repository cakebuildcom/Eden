library = require(script.Parent.Library)

module = {
	Install = function(product)
		local scanner = product.Scanner
		local ready = true
		scanner.Touched:Connect(function(part)
			if part.Parent == workspace or not ready then return end
			local human = part.Parent:FindFirstChild("Humanoid")
			if not human then return end
			local player = game.Players:GetPlayerFromCharacter(human.Parent)
			if not player then return end

			ready = false
			local tools = player.Backpack:GetChildren()
			local found = false
			for _,tool in pairs (tools) do
				if library.IsInArray(product.Whitelist,tool.Name) then
					found = true
					module.Granted(product)
					break
				end
			end
			if found == false then
				module.Denied(product)
			end
			wait(1)
			module.Lights(product.Lights:GetChildren(),BrickColor.new("White"))
			ready = true
		end)
	end,

	Lights = function(lights,color)
		for _,light in pairs (lights) do
			light.BrickColor = color
		end
	end,

	Denied = function(product)
		product.Scanner.Denied:Play()
		module.Lights(product.Lights:GetChildren(),product.DeniedColor)
	end,

	Granted = function(product)
		product.Scanner.Granted:Play()
		module.Lights(product.Lights:GetChildren(),product.GrantedColor)
	end
}

return module
