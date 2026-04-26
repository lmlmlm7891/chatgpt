-- Roblox Fly Script (LocalScript)
-- Place this script in StarterPlayer > StarterPlayerScripts
-- Controls:
--   F: Toggle fly on/off
--   W/A/S/D: Move
--   Space: Move up
--   LeftControl: Move down
--   LeftShift: Speed boost

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local flyEnabled = false
local normalSpeed = 50
local boostedSpeed = 100
local currentSpeed = normalSpeed

local movement = {
	forward = 0,
	backward = 0,
	left = 0,
	right = 0,
	up = 0,
	down = 0,
}

local bodyVelocity
local bodyGyro
local flyConnection

local function getRootPart()
	local character = player.Character or player.CharacterAdded:Wait()
	return character:WaitForChild("HumanoidRootPart")
end

local function cleanupFly()
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end

	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end
end

local function disableFly()
	flyEnabled = false
	cleanupFly()
end

local function enableFly()
	local rootPart = getRootPart()

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.P = 1e4
	bodyVelocity.Parent = rootPart

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	bodyGyro.P = 1e4
	bodyGyro.CFrame = workspace.CurrentCamera.CFrame
	bodyGyro.Parent = rootPart

	flyConnection = RunService.RenderStepped:Connect(function()
		if not flyEnabled then
			return
		end

		if not rootPart or not rootPart.Parent then
			disableFly()
			return
		end

		local camera = workspace.CurrentCamera
		local camCF = camera.CFrame

		local horizontalDirection =
			(camCF.LookVector * (movement.forward - movement.backward))
			+ (camCF.RightVector * (movement.right - movement.left))

		if horizontalDirection.Magnitude > 0 then
			horizontalDirection = horizontalDirection.Unit
		end

		local vertical = movement.up - movement.down
		local velocity = (horizontalDirection * currentSpeed) + Vector3.new(0, vertical * currentSpeed, 0)

		bodyVelocity.Velocity = velocity
		bodyGyro.CFrame = camCF
	end)
end

local function toggleFly()
	if flyEnabled then
		disableFly()
	else
		flyEnabled = true
		enableFly()
	end
end

local keyMap = {
	[Enum.KeyCode.W] = { "forward", 1 },
	[Enum.KeyCode.S] = { "backward", 1 },
	[Enum.KeyCode.A] = { "left", 1 },
	[Enum.KeyCode.D] = { "right", 1 },
	[Enum.KeyCode.Space] = { "up", 1 },
	[Enum.KeyCode.LeftControl] = { "down", 1 },
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		toggleFly()
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		currentSpeed = boostedSpeed
		return
	end

	local binding = keyMap[input.KeyCode]
	if binding then
		movement[binding[1]] = binding[2]
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		currentSpeed = normalSpeed
		return
	end

	local binding = keyMap[input.KeyCode]
	if binding then
		movement[binding[1]] = 0
	end
end)

player.CharacterAdded:Connect(function()
	if flyEnabled then
		task.wait(0.2)
		disableFly()
		enableFly()
		flyEnabled = true
	end
end)
