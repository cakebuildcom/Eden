service = game:GetService("DataStoreService")

module = {
	Install = function(product)
		product.Source.Parent = nil
		local saveModule = require(script.Parent.Save)
		local ready = true

		product.Button.Click.MouseClick:Connect(function(player)
			if not ready or not player.Character then return end
			ready = false

			local bool,_ = pcall(function()
				local key = tostring(player.UserId)
				local locations = saveModule.GetFromPlayer(player,"Locations")

				if product.Type == "Entrance" then
					local credits = saveModule.GetFromPlayer(player,"Credits")
					local after = credits - product.Price
					if after >= 0 then
						module.Teleport(player,product.Gate)
						product.Button.Granted:Play()
						table.insert(
							saveModule.Temporary.Players[key].Locations,
							module.CreateLocation(product)
						)
						saveModule.AddMoney(player,-product.Price)
					else
						product.Button.Denied:Play()
					end
				elseif product.Type == "Exit" then
					product.Button.Granted:Play()
					module.Teleport(player,product.Gate)
					table.insert(
						saveModule.Temporary.Players[key].Locations,
						module.CreateLocation(product)
					)
				end
			end)

			ready = true
		end)
	end,

	Teleport = function(player,gate)
		local root = player.Character.HumanoidRootPart
		local deltaY = math.abs(
			gate.Position.Y - root.Position.Y
		)
		root.CFrame = gate.CFrame * CFrame.new(0,-deltaY,-3)
	end,

	CreateLocation = function(product)
		return {
			Name = product.Station,
			Time = os.time()
		}
	end
}

return module
