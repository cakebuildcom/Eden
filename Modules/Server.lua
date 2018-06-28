authkey = "***********"

gate = Instance.new("RemoteFunction",game.ReplicatedStorage)
gate.Name = "EdenAuth"

items = script.Parent.Parent.Items
replicated = script.Parent.Parent.Replicated
replicated.Parent = game.ReplicatedStorage
modules = script.Parent

library = require(modules.Library)

encryption = library.Encrypt(20)
fakeReplicated = library.Hide(2)
replicated.Name = encryption

module = {
	Install = function(product)
		local data = module.Products[product.Name]
		if data then
			if not module.Modules[product.Name] then
				module.Modules[product.Name] = require(modules[product.Name])
				print("Eden: Installed ",product.Name)
				table.insert(module.Installed,product.Name)
			end
			module.Modules[product.Name].Install(product)
		else
			warn(product.Name.." is not a valid product!")
		end
	end,
	Installed = {},
	Modules = {
		Library = library,
		Google = require(modules.Google)
	},
	Auths = {
	},
	Products = {
		["Eden Vending Machine"] = {

		},
		["Eden Coffee Machines"] = {

		},
		["Eden Leaderboard"] = {

		}
	},

	RemoteFunctions = {
		GetProducts = function(player)
			return module.Installed
		end
	}
}

function gate.OnServerInvoke(player, key)
	if key == authkey then
		return replicated
	else
		player:Kick("Eden: Failed 2 Step Verification")
	end
end

--server 2 server----------------------------------------------------------------------
function items.Invoke.OnInvoke(...)
	return replicated.Items.Invoke:InvokeClient(...)
end

items.Event.Event:Connect(function(...)
	replicated.Items.Event:FireClient(...)
end)

items.Broadcast.Event:Connect(function(...)
	replicated.Items.Event:FireAllClients(...)
end)
--client 2 server----------------------------------------------------------------------
replicated.Items.Event.OnServerEvent:Connect(function(player,name,method,...)
	module.Modules[name].RemoteFunctions[method](player,...)
end)

function replicated.Items.Invoke.OnServerInvoke(player,name,method,...)
	return module.Modules[name].RemoteFunctions[method](player,...)
end
---------------------------------------------------------------------------------------

for _,fakeFolder in pairs (fakeReplicated) do
	fakeFolder.Event.OnServerEvent:Connect(function(player)
		player:Kick("Eden: Broadcasting on the wrong channel")
	end)
	function fakeFolder.Invoke.OnServerInvoke(player)
		player:Kick("Eden: Broadcasting on the wrong channel")
	end
end

client = script.EdenClient
client.Parent = game.StarterPlayer.StarterPlayerScripts

return module
