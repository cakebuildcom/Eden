run = game:GetService("RunService")
uis = game:GetService("UserInputService")
debris = game:GetService("Debris")

me = game.Players.LocalPlayer
mouse = me:GetMouse()
cam = workspace.CurrentCamera
gui = nil

module = {
	Settings = script.Parent.Parent.Items.Invoke:InvokeServer(
		script.Name,"GetSettings"
	),
	Drone = nil,
	Vars = {
		Speed = 0,
		Ready = true,
		Armed = false,
		InDrone = false,
		MouseDown = false
	},

	OnTick = function(step)
		if module.Vars.InDrone and module.Drone then
			if uis:IsKeyDown(Enum.KeyCode.W) then
				module.Vars.Speed = module.Vars.Speed +
				(module.Settings.Acceleration * step)
			else
				module.Vars.Speed = 0
			end
			if module.Vars.Speed > module.Settings.Speed then
				module.Vars.Speed = module.Settings.Speed
			end
			module.Drone.Gyro.CFrame = CFrame.new(
				module.Drone.Core.Position,mouse.Hit.p
			)
			module.Drone.Velocity.Velocity = module.Drone.Core.CFrame.lookVector
				* module.Vars.Speed


		end
	end,

	Castray = function(start, stop, ignore, distance)
		local newRay = Ray.new(start.p, (stop.p - start.p).unit * distance)
		return workspace:FindPartOnRayWithIgnoreList(
			newRay,ignore,false,true
		)
	end,

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

	MoveShoulder = function(dir)
		spawn(function()
			module.Lerp(
				module.Drone.Left.Shoulder.Weld,
				module.Drone.Left.Shoulder.Weld.C1 * CFrame.new(0.7*dir,0,0),
				0.5
			)
		end)

		spawn(function()
			module.Lerp(
				module.Drone.Right.Shoulder.Weld,
				module.Drone.Right.Shoulder.Weld.C1 * CFrame.new(-0.7*dir,0,0),
				0.5
			)
		end)
	end,

	MoveBarrel = function(dir)
		spawn(function()
			module.Lerp(
				module.Drone.Left.Barrel.Weld,
				module.Drone.Left.Barrel.Weld.C1 * CFrame.new(0,0,2*dir),
				0.5
			)
		end)

		spawn(function()
			module.Lerp(
				module.Drone.Right.Barrel.Weld,
				module.Drone.Right.Barrel.Weld.C1 * CFrame.new(0,0,2*dir),
				0.5
			)
		end)
	end,

	Recoil = function()
		spawn(function()
			module.Lerp(
				module.Drone.Left.Barrel.Weld,
				module.Drone.Left.Barrel.Weld.C1 * CFrame.new(0,0,-0.5),
				0.1
			)

			module.Lerp(
				module.Drone.Left.Barrel.Weld,
				module.Drone.Left.Barrel.Weld.C1 * CFrame.new(0,0,0.5),
				0.1
			)
		end)

		spawn(function()
			module.Lerp(
				module.Drone.Right.Barrel.Weld,
				module.Drone.Right.Barrel.Weld.C1 * CFrame.new(0,0,-0.5),
				0.1
			)

			module.Lerp(
				module.Drone.Right.Barrel.Weld,
				module.Drone.Right.Barrel.Weld.C1 * CFrame.new(0,0,0.5),
				0.1
			)
		end)
	end,

	ToggleArm = function()
		if not module.Vars.Ready then return end
		module.Vars.Ready = false
		module.Vars.Armed = not module.Vars.Armed
		if module.Vars.Armed then
			module.MoveShoulder(1)
			module.MoveBarrel(1)
			script.Parent.Parent.Items.Event:FireServer(
				script.Name,"Eyecolor",module.Drone,"Armed"
			)
		else
			module.MoveShoulder(-1)
			module.MoveBarrel(-1)
			script.Parent.Parent.Items.Event:FireServer(
				script.Name,"Eyecolor",module.Drone,"Neutral"
			)
		end

		wait(0.5)
		module.Vars.Ready = true
	end,

	EquipDrone = function()
		module.Vars.InDrone = true
		cam.CameraSubject = module.Drone.Core
		mouse.TargetFilter = module.Drone.Drone
		me.Character.Humanoid.WalkSpeed = 0
	end,

	ExitDrone = function()
		module.Vars.InDrone = false
		cam.CameraSubject = me.Character.Humanoid
		mouse.TargetFilter = nil
		me.Character.Humanoid.WalkSpeed = 16
	end,

	Fire = function()
		local hit,pos = module.Castray(
			module.Drone.Core.CFrame,
			mouse.Hit,{cam,module.Drone.Drone},
			module.Settings.Range
		)
		local tag = {
			Hit = CFrame.new(pos),
			Target = hit,
			Human = (hit and hit.Parent ~= workspace)
				and hit.Parent:FindFirstChild("Humanoid")
		}

		script.Parent.Parent.Items.Event:FireServer(
			script.Name,"Fire",module.Drone,tag
		)

		module.RemoteFunctions.Laser(
			{
				module.Drone.Left.Gun1,
				module.Drone.Left.Gun2,
				module.Drone.Right.Gun1,
				module.Drone.Right.Gun2,
			},
			tag.Hit
		)
	end,

	RemoteFunctions = {
		GiveDrone = function(drone)
			module["Default"] = {
				Left = {
					Barrel = drone.Left.Barrel.Weld.C1,
					Shoulder = drone.Left.Shoulder.Weld.C1,
				},
				Right = {
					Barrel = drone.Right.Barrel.Weld.C1,
					Shoulder = drone.Right.Shoulder.Weld.C1,
				}
			}
			local vel = Instance.new("BodyVelocity",drone.Core)
			vel.MaxForce = Vector3.new(1000000, 1000000, 1000000)
			vel.Velocity = Vector3.new(0,0,0)

			local gyro = Instance.new("BodyGyro",drone.Core)
			gyro.MaxTorque = Vector3.new(1000000, 1000000, 1000000)
			gyro.CFrame = drone.Core.CFrame

			drone["Velocity"] = vel
			drone["Gyro"] = gyro
			module.Drone = drone

			me.Character.Humanoid.Died:Connect(function()
				module.Drone = nil
			end)
		end,
		Laser = function(froms,to)
			for i,from in pairs (froms) do
				local mag = (from.Position - to.p).magnitude
				local laser = Instance.new("Part")
				laser.Anchored = true
				laser.CanCollide = false
				laser.BrickColor = BrickColor.new("Cyan")
				laser.Material = Enum.Material.Neon
				laser.Size = Vector3.new(0.2,0.2,mag)
				laser.CFrame = CFrame.new(from.Position,to.p)
					* CFrame.new(0,0,-mag/2)
				local mesh = Instance.new("SpecialMesh",laser)
				mesh.MeshType = Enum.MeshType.Brick
				mesh.Scale = Vector3.new(0.25,0.25,1)
				laser.Parent = cam
				debris:AddItem(laser,0.05)
			end
		end
	}
}

mouse.Button1Down:Connect(function()
	if not module.Drone or not module.Vars.Ready then return end
	module.Vars.MouseDown = true
	repeat
		module.Fire()
		wait(module.Settings.Cooldown)
	until not module.Vars.MouseDown or not module.Drone or not module.Vars.InDrone
end)

mouse.Button1Up:Connect(function()
	if not module.Drone then return end
	module.Vars.MouseDown = false
end)

run.RenderStepped:Connect(module.OnTick)
uis.InputBegan:Connect(function(input,process)
	if not module.Drone or process or not module.Vars.Ready then return end
	if input.KeyCode == module.Settings.ToggleKey then
		if module.Vars.InDrone then
			module.ExitDrone()
		else
			module.EquipDrone()
		end
	elseif input.KeyCode == module.Settings.ArmKey then
		module.ToggleArm()
	end
end)


return module
