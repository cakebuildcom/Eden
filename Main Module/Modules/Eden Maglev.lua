items = script.Parent.Parent.Items

module = {
	Products = {},
	Install = function(product)
		local pref = product.Settings
		local track = module.MakeTrack(
			product.Track:GetChildren(),
			product.Settings.Speeds
		)

		product.Track.Parent = game.ReplicatedStorage

		local cart = product.Cart

		local current = 1
		local dir = 1

		cart:SetPrimaryPartCFrame(track[1].Node.CFrame + Vector3.new(0,pref.Hover,0))
		for _,v in pairs (cart.Seats:GetChildren()) do
			local seat = v.Seat
			local occupant = nil
			seat.ChildAdded:Connect(function(child)
				occupant = seat.Occupant.Parent
				occupant.Parent = cart
			end)
			seat.ChildRemoved:Connect(function(child)
				if occupant then
					occupant.Parent = workspace
				end
			end)
		end
		wait(pref.StationWait)
		while true do
			local journey = nil
			repeat
				journey = module.MakeJourney(track,track[current],dir,pref)
				items.Broadcast:Fire(
					script.Name,"Start",cart,journey,pref
				)
				wait(module.GetJourneyDuration(journey) + pref.StationWait)

				current = journey[#journey].Index
			until current == 1 or current == #track

			dir = dir * -1
		end
	end,

	GetSeated = function(seats)
		local seated = {}

	end,

	MakeJourney = function(track,start,dir,pref)
		--Collects all the nodes from the start until the next station
		local journey = {start}
		local i = dir

		local node = start
		repeat
			node = track[start.Index + i]
			table.insert(journey,node)
			i = i + dir
		until node.Type == "Station"

		return journey
	end,

	GetDistanceDelta = function(old,new)
		--Calculates the distance and time from one node to the next one
		local distance = (old.Node.Position - new.Node.Position).magnitude
		local delta = distance / new.Speed

		return distance,delta
	end,

	GetJourneyDuration = function(journey)
		--Calculates the entire duration of a journey
		local totalDelta = 0
		for i,node in pairs (journey) do
			if journey[i+1] then
				local _,delta = module.GetDistanceDelta(node,journey[i+1])
				totalDelta = totalDelta + delta
			end
		end
		return totalDelta
	end,

	MakeTrack = function(trail,speeds)
		--Converts the track into a table format
		local track = {}
		for _,node in pairs (trail) do
			local info = module.NodeInfo(node,speeds)
			table.insert(track,info.Index,info)
		end
		return track
	end,

	Split = function(text)
		--Splits a string so I can get the node information
		local sep = "%s"
		local t = {}
		local i = 1
		for str in string.gmatch(text, "([^%s]+)") do
			t[i] = str
			i = i + 1
		end
		return t
	end,

	NodeInfo = function(node,speeds)
		--Gets the information of a node and formats it
		local t = module.Split(node.Name)
		local info = {
			Index = tonumber(t[1]),
			Type = "Rail",
			Speed = speeds["DefaultSpeed"],
			Node = node
		}

		if t[2] == "Station" then
			info["Type"] = "Station"
			info["Speed"] = speeds["StationSpeed"]
			info["Name"] = t[3]
		else
			if tonumber(t[2]) then
				info["Speed"] = tonumber(t[2])
			end
		end

		return info
	end,

--	GetNext = function(track,current,dir)
--		if dir == 1 then
--			if current + 1 <= #track then
--				return current + 1, dir
--			else
--				return current - 1, -1
--			end
--		elseif dir == -1 then
--			if current - 1 >= 1 then
--				return current - 1, -1
--			else
--				return current +1, 1
--			end
--		end
--	end

}

return module
