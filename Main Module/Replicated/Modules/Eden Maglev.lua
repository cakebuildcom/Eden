run = game:GetService("RunService")

module = {
	Lerp = function(obj,target,delta)
		if obj.ClassName == "Model" then
			local start = obj.PrimaryPart.CFrame
			local spent = 0
			while spent < 1 do
				spent = spent + run.RenderStepped:wait()/delta
				obj:SetPrimaryPartCFrame(start:lerp(target,spent))
			end
			obj:SetPrimaryPartCFrame(target)
		elseif obj.ClassName == "Weld" then
			local start = obj.C1
			local spent = 0
			 while spent < 1 do
				spent = spent + run.RenderStepped:wait()/delta
				obj.C1 = start:lerp(target,spent)
			end
			obj.C1 = target
		else
			local start = obj.CFrame
			local spent = 0
			while spent < 1 do
				spent = spent + run.RenderStepped:wait()/delta
				obj.CFrame = start:lerp(target,spent)
			end
			obj.CFrame = target
		end
	end,

	GetDistanceDelta = function(old,new)
		local distance = (old.Node.Position - new.Node.Position).magnitude
		local delta = distance / new.Speed

		return distance,delta
	end,

	RemoteFunctions = {
		Start = function(cart,journey,pref)
			local lerping = true

--			for i,seat in pairs (cart.Seats:GetChildren()) do
--				local occupant = seat.Seat.Occupant
--				if occupant then
--					occupant.RootPart.Anchored = true
--
--					spawn(function()
--						repeat
--							occupant = seat.Seat.Occupant
--							occupant.RootPart.CFrame = seat.Seat.CFrame * CFrame.new(0,2,0)
--							run.RenderStepped:wait()
--						until not lerping or not occupant
--						if occupant then
--							occupant.RootPart.Anchored = false
--						end
--					end)
--				end
--			end
			local start = journey[1]
			cart:SetPrimaryPartCFrame(start.Node.CFrame + Vector3.new(0,pref.Hover,0))
			for i = 2,#journey do
				local _,delta = module.GetDistanceDelta(
					journey[i-1],journey[i]
				)
				module.Lerp(
					cart,
					journey[i].Node.CFrame + Vector3.new(0,pref.Hover,0),
					delta
				)
			end

			lerping = false
		end
	}
}

return module
