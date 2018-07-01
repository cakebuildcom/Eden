--This is a script inside Modules["Eden Coffee Machines"]

tool = script.Parent
anim = nil

tool.Equipped:Connect(function()
	local human = tool.Parent:FindFirstChild("Humanoid")
	if not human then return end
	anim = human:LoadAnimation(script.Anim)
end)

tool.Activated:Connect(function()
	if tool.Parent.Humanoid.Health > 0 and tool.Enabled then
		if not anim then return end
		tool.Enabled = false
		anim:Play()
		wait(anim.Length)
		tool.Enabled = true
	end
end)

tool.Unequipped:Connect(function()
	if anim then anim:Stop() end
end)
