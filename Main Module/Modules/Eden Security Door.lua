market = game:GetService("MarketplaceService")

module = {
	Install = function(product)
		product.Source.Parent = nil

		product.Front.MouseClick:Connect(function(player)
			product.Front.MaxActivationDistance = 0
			local granted = module.HasPermission(player,product.Settings.Access)
			if granted then
				module.Teleport(player,product.Door,-1)
			end
			product.Front.MaxActivationDistance = 10
		end)

		product.Back.MouseClick:Connect(function(player)
			product.Back.MaxActivationDistance = 0
			local granted = module.HasPermission(player,product.Settings.Access)
			if granted then
				module.Teleport(player,product.Door,1)
			end
			product.Back.MaxActivationDistance = 10
		end)
	end,

	HasPermission = function(player,access)
		for _,check in pairs (access) do
			local granted = module.Checks[check[1]](player,check)
			if granted == true then return true end
		end
	end,

	Checks = {
		Group = function(player,check)
			if check[3] then
				if check[4] and check[4] == "+" then
					return player:GetRankInGroup(check[2]) >= check[3]
				else
					return player:GetRankInGroup(check[2]) == check[3]
				end
			else
				if player:GetRankInGroup(check[2]) > 0 then
					return true
				end
			end
		end,

		Person = function(player,check)
			return player.UserId == check[2]
		end,

		Gamepass = function(player,check)
			return market:UserOwnsGamePassAsync(player.UserId,check[2])
		end
	},

	Teleport = function(player,door,dir)
		local root = player.Character.HumanoidRootPart
		local deltaY = math.abs(
			door.Position.Y - root.Position.Y
		)
		root.CFrame = door.CFrame * CFrame.new(0,-deltaY, 3 * dir)
	end
}

return module
