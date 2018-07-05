service = game:GetService("MarketplaceService")

me = game.Players.LocalPlayer

items = script.Parent.Parent.Items
gui = script.CreditGui:Clone()
gui.Parent = me.PlayerGui
frame = gui:WaitForChild("Frame")
scroll = frame:WaitForChild("Scroll")
close = frame:WaitForChild("Close")
creditslabel = frame:WaitForChild("Credits")
products = items.Invoke:InvokeServer(script.Name,"GetPreferences")

close.MouseButton1Click:Connect(function()
	frame:TweenPosition(
		UDim2.new(0.5,0,-0.5,0),"Out","Back",0.5,true,function()
			gui.Enabled = false
		end
	)
end)

module = {
	Fill = function()
		local x = 0
		local y = 0
		local width = 50
		local xMax = math.floor(scroll.AbsoluteSize.X/width) -1
		local xGapTotal = scroll.AbsoluteSize.X - (xMax * width)
		local xGap = math.floor(xGapTotal / xMax)
		local yGap = xGap

		for i,product in pairs (products) do
			local info = service:GetProductInfo(product.ID,Enum.InfoType.Product)
			local pos = UDim2.new(
				0,(x*width)+(x*xGap)+xGap/2,
				0,yGap + (y*width)+(y*yGap)
			)
			local square = script.Product:Clone()
			local icon = square:WaitForChild("Icon")
			local title = square:WaitForChild("Title")

			icon.Image = "rbxassetid://"..info.IconImageAssetId
			title.Text = info.Name

			icon.MouseButton1Click:Connect(function()
				items.Invoke:InvokeServer(script.Name,"Selected",i)
			end)

			square.Position = pos
			square.Parent = scroll
			x = x + 1
			if x >= xMax then
				x = 0
				y = y + 1
				scroll.CanvasSize = UDim2.new(0,0,0,(y * width) + (y * yGap) + width)
			end
		end
	end,
	RemoteFunctions = {
		Display = function(products,money)
			creditslabel.Text = "   Credits: ".. (money or 0)
			gui.Enabled = true
			frame:TweenPosition(UDim2.new(0.5,0,0.5,0),"In","Back",0.5,true)
		end
	}
}

module.Fill()

return module
