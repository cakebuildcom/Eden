--[[Eden Vending Machine]]--
library = require(script.Parent.Library)
server = require(script.Parent.Server)

items = script.Parent.Parent.Items
event = items.Event
broadcast = items.Broadcast
invoke = items.Invoke

module = {
	Machines = {},

	Install = function(product)
		product.Source.Parent = nil
		local preferences = product.Preferences

		local tools = preferences.Tools
		local package = preferences.Package
		local markers = package:WaitForChild("Signs")
		local button = package:WaitForChild("EdenVendingMachineToggle")

		local toolcodes = {}

		for i = 1,#preferences.Tools do
			if markers:FindFirstChild(tostring(i)) ~= nil then
				local marker = markers:FindFirstChild(tostring(i))
				local zero = ""
				if i < 10 then zero = "0" end
				local code = zero..tostring(i)
				marker.SurfaceGui.TextLabel.Text = code
				table.insert(toolcodes,{[1] = code,[2] = preferences.Tools[i]})
			end
		end

		local click = Instance.new("ClickDetector",button)
		click.MaxActivationDistance = preferences.ActivationDistance

		product["ToolCodes"] = toolcodes
		preferences.ToolFolder.Parent = nil

		table.insert(module.Machines,product)

		broadcast:Fire(
			"Client","Install",script.Name
		)
	end,

	GetMachine = function(machine)
		for _,v in pairs (module.Machines) do
			if v.Preferences.Package == machine then
				return v
			end
		end
		return nil
	end,

	RemoteFunctions = {
		CodeEntered = function(player,entered,machine)
			local package = module.GetMachine(machine)
			if package then
				for i = 1,#package.ToolCodes do
					local code = package.ToolCodes[i][1]
					local toolName = package.ToolCodes[i][2]

					if entered == code then
						local tool = package.Preferences.ToolFolder:FindFirstChild(
							toolName
						):Clone()
						tool.Parent = player.Backpack
					end
				end
			end
		end
	}
}

return module
