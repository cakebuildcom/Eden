service = game:GetService("DataStoreService")

module = {
	Temporary = {
		Players = {}
	},

	GetDefaultPlayer = function()
		return {
			Credits = 5,
			Locations = {}
		}
	end,

	AddMoney = function(player,amount)
		local key = tostring(player.UserId)
		local credits = module.Temporary.Players[key].Credits
		credits = credits + amount
		module.Temporary.Players[module.PlayerKey(player)].Credits = credits
	end,

	GetFromPlayer = function(player,value)
		local key = tostring(player.UserId)
		return module.Temporary.Players[key][value]
	end,

	PlayerKey = function(player)
		return tostring(player.UserId)
	end,
}

game.Players.PlayerAdded:Connect(function(player)
	local id = tostring(player.UserId)
	module.Temporary.Players[id] = {}
	for key,value in pairs (module.GetDefaultPlayer()) do
		pcall(function()
			local save = service:GetDataStore(
				"Eden",id
			):GetAsync(key) or value
			module.Temporary.Players[id][key] = save
		end)
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	local id = tostring(player.UserId)
	pcall(function()
		for key,value in pairs (module.Temporary.Players[id]) do
			service:GetDataStore(
				"Eden",id
			):SetAsync(key,value)
		end
	end)
end)

for _,player in pairs (game.Players:GetPlayers()) do
	local id = tostring(player.UserId)
	if not module.Temporary.Players[id] then
		module.Temporary.Players[id] = {}
		for key,value in pairs (module.GetDefaultPlayer()) do
			pcall(function()
				local save = service:GetDataStore(
					"Eden",module.PlayerKey(player)
				):GetAsync(key) or value
				module.Temporary.Players[id][key] = save
			end)
		end
	end
end

return module
