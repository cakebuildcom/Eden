replicated = nil
server = nil

module = {
	Install = function(rep)
		replicated = rep
		local modules = replicated.Modules
		local items = replicated.Items

		items.Event.OnClientEvent:Connect(function(name,method,...)
			if name == script.Name then
				module.RemoteFunctions[method](...)
			else
				module.Modules[name].RemoteFunctions[method](...)
			end
		end)

		function items.Invoke.OnClientInvoke(name,method,...)
			if name == script.Name then
				return module.RemoteFunctions[method](...)
			else
				return module.Modules[name].RemoteFunctions[method](...)
			end
		end

		items.BindEvent.Event:Connect(function(...)
			items.Event:FireServer(...)
		end)
		function items.BindInvoke.OnInvoke(...)
			return items.Invoke:InvokeServer(...)
		end

		module.Installed = items.Invoke:InvokeServer("Server","GetProducts")
		for _,item in pairs (module.Installed) do
			module.RemoteFunctions.Install(item)
		end
	end,
	Modules = {},
	Installed = {},

	RemoteFunctions = {
		Install = function(name)
			local mod = replicated.Modules:FindFirstChild(name)
			if mod and module.Modules[name] == nil then
				module.Modules[name] = require(mod)
				table.insert(module.Installed,name)
				print("Eden: Locally installed ",name)
			end
		end
	}
}

return module
