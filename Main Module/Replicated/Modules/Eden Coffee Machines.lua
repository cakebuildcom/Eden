me = game.Players.LocalPlayer
interface = nil

items = script.Parent.Parent.Items
invoke = items.BindInvoke
event = items.BindEvent

preferences = invoke:Invoke(script.Name,"GetPreferences")

module = {
	FillScroll = function(typ,data)
		local pos = 0
		local ready = true
		for name,color in pairs (data or preferences.Types[typ]) do
			local button = Instance.new("TextButton",interface.Scroll)
			button.BackgroundColor3 = color.Color
			button.BorderSizePixel = 0
			button.Position = UDim2.new(0,0,0,pos)
			button.Size = UDim2.new(1,0,0,20)
			button.Font = Enum.Font.SourceSansLight
			button.TextScaled = true
			button.ZIndex = interface.Scroll.ZIndex
			button.Text = name
			button.TextColor3 = Color3.new(1,1,1)
			button.TextStrokeTransparency = 0.8

			button.MouseButton1Click:Connect(function()
				if ready == true then
					ready = false
					interface.Gui.Enabled = false
					event:Fire(
						script.Name,"Selected",typ,name
					)
				end
			end)

			pos = pos + 22
		end
		interface.Scroll.CanvasSize = UDim2.new(0,0,0,pos)
	end,

	CreateGui = function(parent)
		local gui = Instance.new("ScreenGui",parent)
		gui.Enabled = false
		gui.Name = script.Name
		gui.ResetOnSpawn = false

		local frame = Instance.new("Frame",gui)
		frame.AnchorPoint = Vector2.new(0.5,0.5)
		frame.BackgroundColor3 = preferences.Interface.BackColor
		frame.BorderSizePixel = 0
		frame.Position = UDim2.new(0.5,0,0.5,0)
		frame.Size = preferences.Interface.Size

		local searchbar = Instance.new("TextBox",frame)
		searchbar.BackgroundColor3 = preferences.Interface.ForeColor
		searchbar.BorderSizePixel = 0
		searchbar.ClearTextOnFocus = true
		searchbar.Position = UDim2.new(0,2,0,2)
		searchbar.Size = UDim2.new(1,-24,0,16)
		searchbar.Font = preferences.Interface.Font
		searchbar.PlaceholderColor3 = preferences.Interface.TextIdleColor
		searchbar.PlaceholderText = "Search 🔍"
		searchbar.Text = ""
		searchbar.TextColor3 = preferences.Interface.TextColor
		searchbar.TextScaled = false
		searchbar.TextSize = preferences.Interface.TextSize
		searchbar.TextXAlignment = Enum.TextXAlignment.Left
		searchbar.ZIndex = frame.ZIndex

		local close = Instance.new("TextButton",frame)
		close.BackgroundColor3 = preferences.Interface.CloseButtonColor
		close.BorderSizePixel = 0
		close.Position = UDim2.new(1,-20,0,2)
		close.Size = UDim2.new(0,18,0,16)
		close.ZIndex = frame.ZIndex
		close.Text = ""

		local scroll = Instance.new("ScrollingFrame",frame)
		scroll.BackgroundTransparency = 1
		scroll.Position = UDim2.new(0,2,0,20)
		scroll.Size = UDim2.new(1,-4,1,-20)
		scroll.BottomImage = "rbxassetid://246952627"
		scroll.MidImage = "rbxassetid://246952627"
		scroll.TopImage = "rbxassetid://246952627"
		scroll.ScrollBarThickness = 5
		scroll.ZIndex = frame.ZIndex

		close.MouseButton1Click:Connect(function()
			gui.Enabled = false
			scroll:ClearAllChildren()
		end)

		searchbar.FocusLost:Connect(function(enterPressed,input)
			local search = searchbar.Text
			if not search or search == "" then
				if preferences.Types[interface.Type][search] then
					module.FillScroll(
						interface.Type,
						preferences.Types[interface.Type][search]
					)
				else
					searchbar.Text = ""
				end
			end
		end)

		return {
			Gui = gui,
			Frame = frame,
			Scroll = scroll,
			Close = close,
			Searchbar = searchbar,
			Type = "Flavors"
		}
	end,

	RemoteFunctions = {
		Select = function(typ)
			if interface.Gui.Enabled then return end
			if not preferences then
				preferences = invoke:Invoke(script.Name,"GetPreferences")
			end
			interface.Type = typ
			module.FillScroll(typ)
			interface.Gui.Enabled = true
		end
	}
}

interface = module.CreateGui(me.PlayerGui)

return module
