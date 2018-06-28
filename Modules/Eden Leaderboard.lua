--[[Eden Leaderboard]]--
service = game:GetService("DataStoreService")
library = require(script.Parent.Library)
server = require(script.Parent.Server)

module = {
	Leaderboards = {},
	Screens = {},

	Install = function(product)
		product.Source.Parent = nil

		table.insert(module.Screens,product)
	end,

	MakePlayer = function(parent,index,data,preferences)
		local height = parent.AbsoluteSize.Y

		local frame = Instance.new("Frame",parent)
		frame.BackgroundTransparency = 1
		frame.Position = UDim2.new(0,0,0,height * (index-1))
		frame.Size = UDim2.new(1,0,0,height)

		local lblIndex = Instance.new("TextLabel",frame)
		lblIndex.BackgroundTransparency = 1
		lblIndex.Size = UDim2.new(0,50,1,0)
		lblIndex.Font = preferences.Font
		lblIndex.Text = tostring(index)
		lblIndex.TextColor3 = preferences.TextColor
		lblIndex.TextSize = preferences.TextSize

		local lblPlayer = Instance.new("TextLabel",frame)
		lblPlayer.BackgroundTransparency = 1
		lblPlayer.Position = UDim2.new(0,50,0,0)
		lblPlayer.Size = UDim2.new(1,-150,1,0)
		lblPlayer.Font = preferences.Font
		lblPlayer.Text = "  "..game.Players:GetPlayerByUserId(tonumber(data.Key))
		lblPlayer.TextColor3 = preferences.TextColor
		lblPlayer.TextSize = preferences.TextSize
		lblPlayer.TextXAlignment = Enum.TextXAlignment.Left

		local lblWins = Instance.new("TextLabel",frame)
		lblPlayer.BackgroundTransparency = 1
		lblWins.Position = UDim2.new(1,-100,0,0)
		lblPlayer.Size = UDim2.new(0,100,1,0)
		lblPlayer.Font = preferences.Font
		lblPlayer.Text = data.Value
		lblPlayer.TextColor3 = preferences.TextColor
		lblPlayer.TextSize = preferences.TextSize
	end,

	RemoteFunctions = {}
}

spawn(function()
	while wait(60) do
		for _,board in pairs (module.Leaderboards) do
			pcall(function()
				local save = service:GetOrderedDataStore(board.Preferences.StoreName)
				local data = save:GetSortedAsync(false, 10)
				for i,pair in ipairs(data) do
					module.MakePlayer(board.Scroll,i,data,board.Preferences)
				end
			end)
		end
	end
end)

return module
