me = game.Players.LocalPlayer

gui = script.VendingGui:Clone()
gui.Parent = me.PlayerGui

me = game.Players.LocalPlayer
mouse = me:GetMouse()

modules = script.Parent.Parent.Modules
items = script.Parent.Parent.Items
invoke = items.BindInvoke
event = items.BindInvoke

code = ""
ready = true
current = nil

for _,button in pairs (gui.Frame:GetChildren()) do
	button.MouseButton1Click:connect(function()
		if ready == true then
			ready = false
			if button.Name == "Clear" then
				module.Close()
			else
				code = code..button.Name
				if string.len(code) == 2 then
					invoke:Invoke(
						script.Name,"CodeEntered",code,current
					)
					module.Close()
				end
			end
			ready = true
		end
	end)
end

mouse.Button1Down:Connect(function()
	local target = mouse.Target
	if target and target.Name == "EdenVendingMachineToggle" then
		module.Open(target)
	end
end)

module = {
	Close = function()
		code = ""
		gui.Enabled = false
		current = nil
	end,

	Open = function(target)
		current = target.Parent
		if gui.Enabled == false then
			gui.Enabled = true
		end
	end,
	RemoteFunctions = {

	}
}

return module
