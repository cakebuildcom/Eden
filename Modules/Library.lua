module = {
	Encrypt = function(length)
		local encryption = ""
		local types = {
			function()
				return string.char(math.random(65,90))
			end,
			function()
				return string.char(math.random(97,122))
			end,
			function()
				return string.char(math.random(48,57))
			end
		}
		for i = 1,length or 20 do
			local mode = math.random(1,3)
			encryption = encryption .. types[mode]()
		end
		return encryption
	end,

	Hide = function(amount)
		local fakes = {}
		for i = 1,amount do
			local file = Instance.new("Folder",game.ReplicatedStorage)
			file.Name = module.Encrypt(20)
			local invoke = Instance.new("RemoteFunction",file)
			invoke.Name = "Invoke"

			local event = Instance.new("RemoteEvent",file)
			event.Name = "Event"

			table.insert(fakes,file)
		end
		return fakes
	end,

	UpdatePreferences = function(new,default)
		for i,v in pairs (default) do
			if new[i] == nil then
				new[i] = default
			end
		end
		return new
	end

}

return module
