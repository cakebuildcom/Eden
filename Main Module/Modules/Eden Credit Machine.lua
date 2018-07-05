service = game:GetService("MarketplaceService")
installed = false

items = script.Parent.Parent.Items
save = require(script.Parent.Save)

module = {
	DevProducts = nil,
	Install = function(product)
		if not installed then
			module.DevProducts = product.Products
			function service.ProcessReceipt(receipt)
				local amount = module.GetAmount(receipt.ProductId)
				save.AddMoney(
					game.Players:GetPlayerByUserId(receipt.PlayerId),
					amount
				)
				save.AddPurchase(
					receipt.PlayerId,
					receipt.PurchaseId,
					receipt.ProductId,
					receipt.CurrencySpent
				)
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end

		product.Button.Click.MouseClick:Connect(function(player)
			items.Event:Fire(
				player,script.Name,"Display",
				product.Products,save.GetFromPlayer(player,"Credits")
			)
		end)
	end,

	GetAmount = function(productId)
		for i,v in pairs (module.DevProducts) do
			if v.ID == productId then
				return v.Credits
			end
		end
	end,
	RemoteFunctions = {
		Selected = function(player,index)
			local data = module.DevProducts[index]
			service:PromptProductPurchase(player, data.ID)
		end,
		GetPreferences = function(player)
			return module.DevProducts
		end
	},
}


return module
