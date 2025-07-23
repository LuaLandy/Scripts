--credits to Infinite Yield, Nameless Admin for some scripts
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local guiParent = CoreGui

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZephyrAdmin"
screenGui.Parent = guiParent
screenGui.ResetOnSpawn = false
screenGui.Enabled = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
frame.ClipsDescendants = true
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Commands"
titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
titleLabel.Font = Enum.Font.GothamSemibold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local minimizeBtn = Instance.new("TextButton", titleBar)
minimizeBtn.Size = UDim2.new(0, 40, 1, 0)
minimizeBtn.Position = UDim2.new(1, -80, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 73)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 28
minimizeBtn.AutoButtonColor = false
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 40, 1, 0)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(232, 17, 35)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 28
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local searchBar = Instance.new("TextBox", frame)
searchBar.Size = UDim2.new(1, -20, 0, 30)
searchBar.Position = UDim2.new(0, 10, 0, 38)
searchBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
searchBar.Text = ""
searchBar.PlaceholderText = "Search..."
searchBar.TextColor3 = Color3.fromRGB(220, 220, 220)
searchBar.Font = Enum.Font.Code
searchBar.TextSize = 18
searchBar.ClearTextOnFocus = false
Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 6)

local scrollFrame = Instance.new("ScrollingFrame", frame)
scrollFrame.Size = UDim2.new(1, -20, 1, -78)
scrollFrame.Position = UDim2.new(0, 10, 0, 68)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
scrollFrame.ClipsDescendants = true
scrollFrame.Active = false
scrollFrame.Draggable = false
scrollFrame.Selectable = false

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)

local commandBarGui = Instance.new("ScreenGui")
commandBarGui.Name = "CommandBarGui"
commandBarGui.Parent = guiParent
commandBarGui.ResetOnSpawn = false

local barFrame = Instance.new("Frame", commandBarGui)
barFrame.Size = UDim2.new(0, 220, 0, 28)
barFrame.Position = UDim2.new(0.5, -110, 0, 10)
barFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
barFrame.Active = false
barFrame.Draggable = false
Instance.new("UICorner", barFrame).CornerRadius = UDim.new(0, 8)

local commandInput = Instance.new("TextBox", barFrame)
commandInput.Size = UDim2.new(1, -10, 1, -4)
commandInput.Position = UDim2.new(0, 5, 0, 2)
commandInput.BackgroundTransparency = 1
commandInput.TextColor3 = Color3.fromRGB(220, 220, 220)
commandInput.PlaceholderText = "> Insert"
commandInput.Text = ""
commandInput.Font = Enum.Font.Code
commandInput.TextSize = 18
commandInput.TextXAlignment = Enum.TextXAlignment.Left
commandInput.ClearTextOnFocus = false

local notifGui = CoreGui:FindFirstChild("NotificationGui") or Instance.new("ScreenGui")
notifGui.Name = "NotificationGui"
notifGui.ResetOnSpawn = false
notifGui.IgnoreGuiInset = true
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notifGui.Parent = CoreGui

local notifications = {}

local function Notification(title, desc, duration)
	local spacing = 10
	local notifHeight = 60
	local notifWidth = 260
	local offsetY = 20 + (#notifications * (notifHeight + spacing))

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, notifWidth, 0, notifHeight)
	notif.Position = UDim2.new(1, notifWidth + 20, 1, -offsetY)
	notif.AnchorPoint = Vector2.new(1, 1)
	notif.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	notif.BackgroundTransparency = 0
	notif.ClipsDescendants = true
	notif.ZIndex = 10
	notif.Parent = notifGui

	Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)

	local tl = Instance.new("TextLabel", notif)
	tl.Size = UDim2.new(1, -12, 0, 20)
	tl.Position = UDim2.new(0, 6, 0, 5)
	tl.BackgroundTransparency = 1
	tl.Text = title
	tl.TextColor3 = Color3.new(1, 1, 1)
	tl.Font = Enum.Font.GothamBold
	tl.TextSize = 16
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.ZIndex = 11

	local dl = Instance.new("TextLabel", notif)
	dl.Size = UDim2.new(1, -12, 0, 18)
	dl.Position = UDim2.new(0, 6, 0, 26)
	dl.BackgroundTransparency = 1
	dl.Text = desc
	dl.TextColor3 = Color3.fromRGB(200, 200, 200)
	dl.Font = Enum.Font.Gotham
	dl.TextSize = 14
	dl.TextXAlignment = Enum.TextXAlignment.Left
	dl.ZIndex = 11

	local barContainer = Instance.new("Frame", notif)
	barContainer.Size = UDim2.new(1, -12, 0, 4)
	barContainer.Position = UDim2.new(0, 6, 1, -10)
	barContainer.BackgroundTransparency = 1
	barContainer.ClipsDescendants = true
	barContainer.ZIndex = 11

	local bar = Instance.new("Frame", barContainer)
	bar.Size = UDim2.new(0, 0, 1, 0)
	bar.Position = UDim2.new(0, 0, 0, 0)
	bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	bar.BorderSizePixel = 0
	bar.ZIndex = 11

	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

	table.insert(notifications, notif)

	TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -20, 1, -offsetY),
	}):Play()

	TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()

	task.delay(duration, function()
		TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Position = notif.Position + UDim2.new(0, notifWidth + 20, 0, 0),
		}):Play()
		task.wait(0.3)
		notif:Destroy()
		for i, v in ipairs(notifications) do
			if v == notif then
				table.remove(notifications, i)
				break
			end
		end
		for i, v in ipairs(notifications) do
			local newY = - (20 + ((i - 1) * (notifHeight + spacing)))
			TweenService:Create(v, TweenInfo.new(0.2), {
				Position = UDim2.new(1, -20, 1, newY)
			}):Play()
		end
	end)
end

local minimized = false
local commands = {}
local commandLabels = {}

minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		TweenService:Create(frame, TweenInfo.new(0.4), {Size = UDim2.new(0, 300, 0, 38)}):Play()
		scrollFrame.Visible = false
		searchBar.Visible = false
	else
		TweenService:Create(frame, TweenInfo.new(0.4), {Size = UDim2.new(0, 300, 0, 400)}):Play()
		scrollFrame.Visible = true
		searchBar.Visible = true
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
end)

local function AddCommand(names, description, callback)
	local label = Instance.new("TextLabel", scrollFrame)
	label.Size = UDim2.new(1, -10, 0, 26)
	label.BackgroundColor3 = Color3.fromRGB(40, 40, 43)
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.Code
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.TextScaled = false
	label.TextTruncate = Enum.TextTruncate.None
	local displayNames = {}
	for _, n in ipairs(names) do
		table.insert(displayNames, n)
		commands[n:lower()] = callback
	end
	local descText = description or ""
	label.Text = displayNames[1] .. (#displayNames > 1 and " (" .. table.concat(displayNames, ", ", 2) .. ")" or "") .. (descText ~= "" and " " .. descText or "")
	Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
	label.AutomaticSize = Enum.AutomaticSize.Y
	table.insert(commandLabels, {label = label, names = displayNames, description = descText})
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
	label.Selectable = false
	label.Active = false
	label.BackgroundTransparency = 0.5
end

searchBar:GetPropertyChangedSignal("Text"):Connect(function()
	local searchText = searchBar.Text:lower()
	for _, cmd in ipairs(commandLabels) do
		local visible = false
		for _, name in ipairs(cmd.names) do
			if name:lower():find(searchText) then
				visible = true
				break
			end
		end
		if not visible and cmd.description:lower():find(searchText) then
			visible = true
		end
		cmd.label.Visible = visible
	end
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

commandInput.FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end
	local text = commandInput.Text
	local parts = {}
	for part in text:gmatch("%S+") do
		table.insert(parts, part)
	end
	if #parts == 0 then
		commandInput.Text = ""
		return
	end
	local cmdName = parts[1]:lower()
	table.remove(parts, 1)

	local cmd
	for name, callback in pairs(commands) do
		if name == cmdName then
			cmd = callback
			break
		end
	end

	if cmd then
		cmd(table.unpack(parts))
	else
		commandInput.Text = ""
	end
	commandInput.Text = ""
end)

AddCommand({"commands", "cmds"}, nil, function()
	screenGui.Enabled = true
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local desiredWalkSpeed
local walkSpeedConnection

local desiredJumpPower
local jumpPowerConnection

local desiredFOV
local fovConnection

local tpwalking = false
local tpwalkSpeed = 1

local function setupWalkSpeedLoop(humanoid)
	if walkSpeedConnection then
		walkSpeedConnection:Disconnect()
		walkSpeedConnection = nil
	end
	if desiredWalkSpeed and humanoid then
		humanoid.WalkSpeed = desiredWalkSpeed
		walkSpeedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if humanoid.WalkSpeed ~= desiredWalkSpeed then
				humanoid.WalkSpeed = desiredWalkSpeed
			end
		end)
	end
end

local function setupJumpPowerLoop(humanoid)
	if jumpPowerConnection then
		jumpPowerConnection:Disconnect()
		jumpPowerConnection = nil
	end
	if desiredJumpPower and humanoid then
		humanoid.JumpPower = desiredJumpPower
		jumpPowerConnection = humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
			if humanoid.JumpPower ~= desiredJumpPower then
				humanoid.JumpPower = desiredJumpPower
			end
		end)
	end
end

local function setupFOVLoop(cam)
	if fovConnection then
		fovConnection:Disconnect()
		fovConnection = nil
	end
	if desiredFOV and cam then
		cam.FieldOfView = desiredFOV
		fovConnection = cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
			if cam.FieldOfView ~= desiredFOV then
				cam.FieldOfView = desiredFOV
			end
		end)
	end
end

local function onCharacterAdded(char)
	local humanoid = char:WaitForChild("Humanoid", 10)
	if humanoid then
		setupWalkSpeedLoop(humanoid)
		setupJumpPowerLoop(humanoid)
	end
end

player.CharacterAdded:Connect(onCharacterAdded)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	camera = workspace.CurrentCamera
	setupFOVLoop(camera)
end)

AddCommand({"walkspeed", "speed", "ws"}, nil, function(Value)
	Value = tonumber(Value) or 16
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = Value
		end
	end
end)

AddCommand({"jumppower", "jp"}, nil, function(Value)
	Value = tonumber(Value) or 50
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.JumpPower = Value
		end
	end
end)

AddCommand({"fieldofview", "fov"}, nil, function(Value)
	Value = tonumber(Value) or 70
	local cam = workspace.CurrentCamera
	if cam then
		cam.FieldOfView = Value
	end
end)

AddCommand({"loopwalkspeed", "loopspeed", "loopws"}, nil, function(Value)
	Value = tonumber(Value)
	desiredWalkSpeed = (Value and Value > 0) and Value or nil
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		setupWalkSpeedLoop(char.Humanoid)
	end
end)

AddCommand({"loopjumppower", "loopjp"}, nil, function(Value)
	Value = tonumber(Value)
	desiredJumpPower = (Value and Value > 0) and Value or nil
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		setupJumpPowerLoop(char.Humanoid)
	end
end)

AddCommand({"loopfov", "loopfieldofview"}, nil, function(Value)
	Value = tonumber(Value)
	desiredFOV = (Value and Value > 0) and Value or nil
	setupFOVLoop(camera)
end)

AddCommand({"unloopwalkspeed", "unloopspeed", "unloopws"}, nil, function()
	if walkSpeedConnection then
		walkSpeedConnection:Disconnect()
		walkSpeedConnection = nil
	end
	desiredWalkSpeed = nil
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = 16
	end
end)

AddCommand({"unloopjumppower", "unloopjp"}, nil, function()
	if jumpPowerConnection then
		jumpPowerConnection:Disconnect()
		jumpPowerConnection = nil
	end
	desiredJumpPower = nil
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.JumpPower = 50
	end
end)

AddCommand({"unloopfov", "unloopfieldofview"}, nil, function()
	if fovConnection then
		fovConnection:Disconnect()
		fovConnection = nil
	end
	desiredFOV = nil
	local cam = workspace.CurrentCamera
	if cam then
		cam.FieldOfView = 70
	end
end)

AddCommand({"teleportwalk", "tpwalk"}, nil, function()
	tpwalking = false
	task.wait()
	tpwalking = true
	task.spawn(function()
		local Players = game:GetService("Players")
		local speaker = Players.LocalPlayer
		local chr = speaker.Character
		if not chr then return end
		local hum = chr:FindFirstChildWhichIsA("Humanoid")
		if not hum then return end
		while tpwalking and chr.Parent and hum.Parent do
			local delta = RunService.Heartbeat:Wait()
			if hum.MoveDirection.Magnitude > 0 then
				chr:TranslateBy(hum.MoveDirection * tpwalkSpeed * delta * 10)
			end
		end
	end)
end)

AddCommand({"unteleportwalk", "untpwalk"}, nil, function()
	tpwalking = false
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

local noclipEnabled = false
local noclipConnection
local characterConnection
local originalCollisions = {}

local function enableNoclip()
	noclipEnabled = true
	originalCollisions = {}

	if noclipConnection then noclipConnection:Disconnect() end

	noclipConnection = RunService.Stepped:Connect(function()
		local character = LocalPlayer.Character
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					if originalCollisions[part] == nil then
						originalCollisions[part] = part.CanCollide
					end
					part.CanCollide = false
				end
			end
		end
	end)

	if characterConnection then characterConnection:Disconnect() end
	characterConnection = LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.5)
		enableNoclip()
	end)
end

local function disableNoclip()
	noclipEnabled = false
	if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	if characterConnection then characterConnection:Disconnect() characterConnection = nil end
	for part, originalValue in pairs(originalCollisions) do
		if part and part:IsDescendantOf(game) then
			part.CanCollide = originalValue
		end
	end
	originalCollisions = {}
end

AddCommand({"noclip"}, nil, function()
	enableNoclip()
	Notification("Noclip", "Enabled Noclip", 5)
end)

AddCommand({"unnoclip", "clip"}, nil, function()
	disableNoclip()
	Notification("Clip", "Disabled Noclip", 5)
end)

local ippConnection

AddCommand({"instantproximityprompt", "instantpp", "ipp"}, nil, function()
	if ippConnection then ippConnection:Disconnect() end
	ippConnection = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
		fireproximityprompt(prompt)
	end)
	Notification("InstantProximityPrompt", "InstantProximityPrompt Enabled", 5)
end)

AddCommand({"uninstantproximityprompt", "uninstantpp", "unipp"}, nil, function()
	if ippConnection then
		ippConnection:Disconnect()
		ippConnection = nil
	end
	Notification("InstantProximityPrompt", "InstantProximityPrompt Disabled", 5)
end)

AddCommand({"fireproximityprompt", "firepp"}, nil, function()
	local Character = LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	if not Root then return end
	local count = 0
	for _, prompt in pairs(workspace:GetDescendants()) do
		if prompt:IsA("ProximityPrompt") and prompt.Enabled then
			local parent = prompt.Parent
			local pos
			if parent:IsA("BasePart") then
				pos = parent.Position
			elseif parent:IsA("Model") and parent.PrimaryPart then
				pos = parent.PrimaryPart.Position
			elseif parent:IsA("Model") then
				local primary = parent:FindFirstChildWhichIsA("BasePart")
				pos = primary and primary.Position
			end
			if pos and (pos - Root.Position).Magnitude <= 20 then
				fireproximityprompt(prompt)
				count += 1
			end
		end
	end
	Notification("FireProximityPrompt", "Fired "..count.." Prompts", 5)
end)

AddCommand({"fireclickdetectors", "fcd"}, nil, function()
	local count = 0
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ClickDetector") then
			fireclickdetector(v)
			count += 1
		end
	end
	Notification("FireClickDetectors", "Fired "..count.." ClickDetectors", 5)
end)

AddCommand({"firetouchinterests", "fti"}, nil, function()
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	local count = 0
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
			pcall(function()
				firetouchinterest(hrp, obj.Parent, 0)
				firetouchinterest(hrp, obj.Parent, 1)
				count += 1
			end)
		end
	end
	Notification("FireTouchInterests", "Fired "..count.." Touch Parts", 5)
end)

local function findPlayer(name)
	name = name and name:lower() or ""
	local matched = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if plr.Name:lower():sub(1, #name) == name or (plr.DisplayName and plr.DisplayName:lower():sub(1, #name) == name) then
				table.insert(matched, plr)
			end
		end
	end
	if #matched > 0 then
		return matched[1]
	elseif name == "random" then
		local others = {}
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				table.insert(others, plr)
			end
		end
		if #others > 0 then
			return others[math.random(1, #others)]
		end
	end
	return nil
end

AddCommand({"goto", "to"}, nil, function(Value)
	local target = findPlayer(Value)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local myChar = LocalPlayer.Character
		if myChar and myChar:FindFirstChild("HumanoidRootPart") then
			myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
		end
	end
end)

local loopGotoRunning = false
local loopGotoTarget = nil
local loopGotoConnection

AddCommand({"loopgoto", "loopto"}, nil, function(Value)
	local target = findPlayer(Value)
	if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
		loopGotoRunning = false
		if loopGotoConnection then loopGotoConnection:Disconnect() loopGotoConnection = nil end
		return
	end
	loopGotoTarget = target
	loopGotoRunning = true
	if loopGotoConnection then loopGotoConnection:Disconnect() end
	loopGotoConnection = RunService.Heartbeat:Connect(function()
		if not loopGotoRunning then
			loopGotoConnection:Disconnect()
			loopGotoConnection = nil
			return
		end
		local playerChar = LocalPlayer.Character
		if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then return end
		local hrp = playerChar.HumanoidRootPart
		local tgtChar = loopGotoTarget.Character
		if not tgtChar or not tgtChar:FindFirstChild("HumanoidRootPart") then return end
		hrp.CFrame = tgtChar.HumanoidRootPart.CFrame
	end)
end)

AddCommand({"unloopgoto", "unloopto"}, nil, function()
	loopGotoRunning = false
	if loopGotoConnection then loopGotoConnection:Disconnect() loopGotoConnection = nil end
end)

local currentViewConnection
local currentTargetPlayer

local function notifyViewing(targetPlayer)
	if targetPlayer and targetPlayer.Name then
		Notification("View", "Viewing "..targetPlayer.Name, 5)
	end
end

local function viewPlayer(targetPlayer)
	if not targetPlayer then return end
	if currentViewConnection then
		currentViewConnection:Disconnect()
		currentViewConnection = nil
	end
	currentTargetPlayer = targetPlayer
	local function updateCameraSubject(character)
		if not character then return end
		local humanoid = character:WaitForChild("Humanoid", 5) or character:FindFirstChildOfClass("Humanoid")
		workspace.CurrentCamera.CameraSubject = humanoid or character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	end
	if targetPlayer.Character then updateCameraSubject(targetPlayer.Character) end
	currentViewConnection = targetPlayer.CharacterAdded:Connect(updateCameraSubject)
	notifyViewing(targetPlayer)
end

AddCommand({"view"}, nil, function(targetName)
	targetName = targetName and targetName:lower() or ""
	local targetPlayer
	if targetName == "random" then
		local players = Players:GetPlayers()
		if #players > 1 then
			repeat
				targetPlayer = players[math.random(#players)]
			until targetPlayer ~= LocalPlayer
		end
	else
		for _, p in pairs(Players:GetPlayers()) do
			if p.Name:lower():find(targetName) or (p.DisplayName and p.DisplayName:lower():find(targetName)) then
				targetPlayer = p
				break
			end
		end
	end
	if targetPlayer then
		viewPlayer(targetPlayer)
	end
end)

AddCommand({"unview"}, nil, function()
	if currentViewConnection then
		currentViewConnection:Disconnect()
		currentViewConnection = nil
		currentTargetPlayer = nil
	end
	local playerChar = LocalPlayer.Character
	if playerChar then
		local humanoid = playerChar:FindFirstChildOfClass("Humanoid")
		if humanoid then
			workspace.CurrentCamera.CameraSubject = humanoid
		end
	end
end)

local spinInstance
local spinSpeed = 10

AddCommand({"spin"}, nil, function(Value)
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local rootPart = character:WaitForChild("HumanoidRootPart")
	if spinInstance then
		spinInstance:Destroy()
		spinInstance = nil
		return
	end
	spinSpeed = tonumber(Value) or spinSpeed
	spinInstance = Instance.new("BodyAngularVelocity")
	spinInstance.Name = "Spin"
	spinInstance.Parent = rootPart
	spinInstance.MaxTorque = Vector3.new(0, math.huge, 0)
	spinInstance.AngularVelocity = Vector3.new(0, spinSpeed, 0)
end)

AddCommand({"spinspeed"}, nil, function(Value)
	local speed = tonumber(Value)
	if speed and spinInstance then
		spinSpeed = speed
		spinInstance.AngularVelocity = Vector3.new(0, spinSpeed, 0)
	end
end)

AddCommand({"unspin"}, nil, function()
	if spinInstance then
		spinInstance:Destroy()
		spinInstance = nil
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local swimming = false
local oldGravity = workspace.Gravity
local swimHeartbeatConn, gravReset

AddCommand({"swim"}, nil, function()
	if swimming then return end
	local player = Players.LocalPlayer
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then return end

	oldGravity = workspace.Gravity
	workspace.Gravity = 0

	local function onDied()
		workspace.Gravity = oldGravity
		swimming = false
		if swimHeartbeatConn then
			swimHeartbeatConn:Disconnect()
			swimHeartbeatConn = nil
		end
		if gravReset then
			gravReset:Disconnect()
			gravReset = nil
		end
	end

	gravReset = humanoid.Died:Connect(onDied)

	local states = Enum.HumanoidStateType:GetEnumItems()
	table.remove(states, table.find(states, Enum.HumanoidStateType.None))
	for _, state in pairs(states) do
		humanoid:SetStateEnabled(state, false)
	end

	humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

	swimHeartbeatConn = RunService.Heartbeat:Connect(function()
		pcall(function()
			local moveDir = humanoid.MoveDirection
			local shouldMove = (moveDir.Magnitude > 0) or UserInputService:IsKeyDown(Enum.KeyCode.Space)
			if shouldMove then
				hrp.Velocity = hrp.Velocity
			else
				hrp.Velocity = Vector3.new()
			end
		end)
	end)

	swimming = true
end)

AddCommand({"unswim"}, nil, function()
	local player = Players.LocalPlayer
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end

	workspace.Gravity = oldGravity
	swimming = false

	if gravReset then
		gravReset:Disconnect()
		gravReset = nil
	end

	if swimHeartbeatConn then
		swimHeartbeatConn:Disconnect()
		swimHeartbeatConn = nil
	end

	local states = Enum.HumanoidStateType:GetEnumItems()
	table.remove(states, table.find(states, Enum.HumanoidStateType.None))
	for _, state in pairs(states) do
		humanoid:SetStateEnabled(state, true)
	end
end)

local defaultFog = {
	FogStart = Lighting.FogStart,
	FogEnd = Lighting.FogEnd
}

local noFogConfig = {
	FogStart = 0,
	FogEnd = 1e10
}

local defaultLighting = {
	GlobalShadows = Lighting.GlobalShadows,
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ExposureCompensation = Lighting.ExposureCompensation,
}

local fullBrightConfig = {
	GlobalShadows = false,
	Brightness = 1,
	ClockTime = 14,
	OutdoorAmbient = Color3.fromRGB(192, 192, 192),
	ExposureCompensation = 0.25,
}

local nofogConnection
local fbConnection
local nofogLoopActive = false
local fullbrightLoopActive = false

local function applyNoFog()
	for prop, val in pairs(noFogConfig) do
		Lighting[prop] = val
	end
end

local function restoreFogDefaults()
	for prop, val in pairs(defaultFog) do
		Lighting[prop] = val
	end
end

local function applyFullBright()
	for prop, value in pairs(fullBrightConfig) do
		Lighting[prop] = value
	end
end

local function restoreLightingDefaults()
	for prop, value in pairs(defaultLighting) do
		Lighting[prop] = value
	end
end

AddCommand({"fullbright", "fb"}, nil, function()
	if fbConnection then fbConnection:Disconnect() fbConnection = nil end
	fullbrightLoopActive = false
	restoreLightingDefaults()
	applyFullBright()
end)

AddCommand({"nofog"}, nil, function()
	if nofogConnection then nofogConnection:Disconnect() nofogConnection = nil end
	nofogLoopActive = false
	restoreFogDefaults()
	applyNoFog()
end)

AddCommand({"loopnofog"}, nil, function()
	if nofogLoopActive then return end
	nofogLoopActive = true
	if nofogConnection then nofogConnection:Disconnect() nofogConnection = nil end
	nofogConnection = Lighting.Changed:Connect(function(prop)
		if noFogConfig[prop] ~= nil and Lighting[prop] ~= noFogConfig[prop] then
			Lighting[prop] = noFogConfig[prop]
		end
	end)
	applyNoFog()
end)

AddCommand({"loopfullbright", "loopfb"}, nil, function()
	if fullbrightLoopActive then return end
	fullbrightLoopActive = true
	if fbConnection then fbConnection:Disconnect() fbConnection = nil end
	fbConnection = Lighting.Changed:Connect(function(prop)
		if fullBrightConfig[prop] ~= nil and Lighting[prop] ~= fullBrightConfig[prop] then
			Lighting[prop] = fullBrightConfig[prop]
		end
	end)
	applyFullBright()
end)

AddCommand({"unloopfullbright", "unloopfb"}, nil, function()
	if fbConnection then fbConnection:Disconnect() fbConnection = nil end
	fullbrightLoopActive = false
	restoreLightingDefaults()
end)

AddCommand({"unloopnofog"}, nil, function()
	if nofogConnection then nofogConnection:Disconnect() nofogConnection = nil end
	nofogLoopActive = false
	restoreFogDefaults()
end)

AddCommand({"day"}, nil, function()
	game.Lighting.ClockTime = 14
end)

AddCommand({"night"}, nil, function()
	game.Lighting.ClockTime = 0
end)

AddCommand({"restorelighting", "rlighting"}, nil, function()
	if fbConnection then fbConnection:Disconnect() fbConnection = nil end
	if nofogConnection then nofogConnection:Disconnect() nofogConnection = nil end
	fullbrightLoopActive = false
	nofogLoopActive = false
	restoreLightingDefaults()
	restoreFogDefaults()
end)

AddCommand({"maxzoom"}, nil, function(v)
	local zoomDistance = tonumber(v)
	if zoomDistance and zoomDistance > 0 then
		LocalPlayer.CameraMaxZoomDistance = zoomDistance
	end
end)

AddCommand({"spook", "scare"}, nil, function(Value)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local target = findPlayer(Value)
if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

local targetHRP = target.Character.HumanoidRootPart
local myHRP = LocalPlayer.Character.HumanoidRootPart
local originalCFrame = myHRP.CFrame

local frontPosition = targetHRP.Position + targetHRP.CFrame.LookVector * 2
local lookAtCFrame = CFrame.new(frontPosition, targetHRP.Position)
myHRP.CFrame = lookAtCFrame

task.delay(0.5, function()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character.HumanoidRootPart.CFrame = originalCFrame
	end
end)
end)

local function FindPlayerByName(name)
	if not name then return nil end
	name = name:lower()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Name:lower():find(name) or (p.DisplayName and p.DisplayName:lower():find(name)) then
			return p
		end
	end
	return nil
end

local function SkidFling(TargetCharacter)
	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Humanoid and Character:FindFirstChild("HumanoidRootPart")
	local THumanoid = TargetCharacter:FindFirstChildOfClass("Humanoid")
	local TRootPart = THumanoid and TargetCharacter:FindFirstChild("HumanoidRootPart")
	local THead = TargetCharacter:FindFirstChild("Head")
	local Accessory = TargetCharacter:FindFirstChildOfClass("Accessory")
	local Handle = Accessory and Accessory:FindFirstChild("Handle")

	if Character and Humanoid and RootPart then
		if RootPart.Velocity.Magnitude < 50 then
			getgenv().OldPos = RootPart.CFrame
		end
		local Base = TargetCharacter:FindFirstChildWhichIsA("BasePart")
		if not Base then return end
		local function FPos(BasePart, Pos, Ang)
			RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
			Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
			RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
			RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
		end
		local function SFBasePart(BasePart)
			local Time = tick()
			local Angle = 0
			repeat
				Angle += 100
				FPos(BasePart, CFrame.new(0, 1.5, 0), CFrame.Angles(math.rad(Angle), 0, 0))
				task.wait()
				FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(Angle), 0, 0))
				task.wait()
			until BasePart.Velocity.Magnitude > 500 or Humanoid.Health <= 0 or tick() > Time + 2
		end

		workspace.FallenPartsDestroyHeight = 0/0
		local BV = Instance.new("BodyVelocity")
		BV.Name = "EpixVel"
		BV.Parent = RootPart
		BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
		BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

		if TRootPart and THead then
			if (TRootPart.Position - THead.Position).Magnitude > 5 then
				SFBasePart(THead)
			else
				SFBasePart(TRootPart)
			end
		elseif TRootPart then
			SFBasePart(TRootPart)
		elseif THead then
			SFBasePart(THead)
			elseif Handle then
			SFBasePart(Handle)
		end

		BV:Destroy()
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

		repeat
			RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
			Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
			Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			for _, part in ipairs(Character:GetChildren()) do
				if part:IsA("BasePart") then
					part.Velocity = Vector3.new(0, 0, 0)
					part.RotVelocity = Vector3.new(0, 0, 0)
				end
			end
			task.wait()
		until (RootPart.Position - getgenv().OldPos.Position).Magnitude < 25
	end
end

AddCommand({"fling"}, nil, function(Value)
	Value = Value and Value:lower() or ""

	local targets = {}

	if Value == "random" then
		local players = Players:GetPlayers()
		if #players > 1 then
			repeat
				local target = players[math.random(#players)]
				if target ~= LocalPlayer then
					targets = {target}
					break
				end
			until false
		end
	elseif Value == "all" then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				table.insert(targets, p)
			end
		end
	else
		local targetPlayer = FindPlayerByName(Value)
		if targetPlayer and targetPlayer.Character then
			targets = {targetPlayer}
		end
	end

	task.spawn(function()
		for _, target in ipairs(targets) do
			SkidFling(target.Character)
		end
	end)
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local controlModule = require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

local walkFlinger
local hiddenFling = false
local respawnConn

local function getRoot(char)
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function startWalkFling()
	if walkFlinger then return end
	hiddenFling = true
	walkFlinger = RunService.Heartbeat:Connect(function()
		local char = player.Character
		local hrp = getRoot(char)
		if hrp and hiddenFling then
			local origVel = hrp.Velocity
			hrp.Velocity = origVel * 10000 + Vector3.new(0, 10000, 0)
			RunService.RenderStepped:Wait()
			if hrp and char then hrp.Velocity = origVel end
			RunService.Stepped:Wait()
			if hrp and char then hrp.Velocity = origVel + Vector3.new(0, 0.1, 0) end
		end
	end)
	if respawnConn then respawnConn:Disconnect() respawnConn=nil end
	respawnConn = player.CharacterAdded:Connect(function()
		if hiddenFling and not walkFlinger then
			startWalkFling()
		end
	end)
end

AddCommand({"walkfling"}, nil, function()
	startWalkFling()
	Notification("Walk Fling", "Enabled Walk Fling", 5)
end)

AddCommand({"unwalkfling"}, nil, function()
	hiddenFling = false
	if walkFlinger then walkFlinger:Disconnect() walkFlinger=nil end
	if respawnConn then respawnConn:Disconnect() respawnConn=nil end
	Notification("Walk Fling", "Disabled Walk Fling", 5)
end)

local collisionStates = {}
local antiflingConn

local function applyAntifling()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local saved = collisionStates[plr] or {}
			for _, part in pairs(plr.Character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide and saved[part] ~= false then
					saved[part] = true
					part.CanCollide = false
				end
			end
			collisionStates[plr] = saved
		end
	end
end

AddCommand({"antifling"}, nil, function()
	if antiflingConn then antiflingConn:Disconnect() end
	antiflingConn = RunService.RenderStepped:Connect(applyAntifling)
	Notification("Anti Fling", "Enabled Anti Fling", 5)
end)

AddCommand({"unantifling"}, nil, function()
	if antiflingConn then
		antiflingConn:Disconnect()
		antiflingConn = nil
	end
	for plr, parts in pairs(collisionStates) do
		for part, wasCollidable in pairs(parts) do
			if wasCollidable and part and part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end
	table.clear(collisionStates)
	Notification("Anti Fling", "Disabled Anti Fling", 5)
end)

AddCommand({"reset"}, nil, function()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.Health=0 end
end)

AddCommand({"respawn","re"}, nil, function()
	task.spawn(function()
		local char = player.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not hum or not root then return end
		local oldCFrame = root.CFrame
		hum.Health=0
		player.CharacterAdded:Wait()
		local newChar = player.Character or player.CharacterAdded:Wait()
		local newRoot = newChar:WaitForChild("HumanoidRootPart",5)
		if newRoot then newRoot.CFrame=oldCFrame end
	end)
end)

local velocityHandlerName = "VelocityHandler"
local gyroHandlerName = "GyroHandler"
local v3zero = Vector3.zero
local v3inf = Vector3.new(1/0,1/0,1/0)

local flying = false
local FlightSpeed = 50
local renderStepConn

local function setupFlyingParts(char)
	local root = char:WaitForChild("HumanoidRootPart")
	for _,c in pairs(root:GetChildren()) do
		if c.Name==velocityHandlerName or c.Name==gyroHandlerName then
			c:Destroy()
		end
	end
	local bv=Instance.new("BodyVelocity")
	bv.Name=velocityHandlerName
	bv.MaxForce=v3zero
	bv.Velocity=v3zero
	bv.Parent=root
	local bg=Instance.new("BodyGyro")
	bg.Name=gyroHandlerName
	bg.MaxTorque=v3inf
	bg.P=1000
	bg.D=50
	bg.Parent=root
end

local function disableFlying(char)
	local root=char:FindFirstChild("HumanoidRootPart")
	if root then
		for _,c in pairs(root:GetChildren()) do
			if c.Name==velocityHandlerName or c.Name==gyroHandlerName then
				c:Destroy()
			end
		end
	end
	local hum=char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand=false end
end

local function flyStep()
	local char=player.Character
	if not char then return end
	local root=char:FindFirstChild("HumanoidRootPart")
	local hum=char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	local bv=root:FindFirstChild(velocityHandlerName)
	local bg=root:FindFirstChild(gyroHandlerName)
	if not bv or not bg then return end
	bv.MaxForce=v3inf
	bg.MaxTorque=v3inf
	hum.PlatformStand=true
	bg.CFrame=camera.CFrame
	bv.Velocity=v3zero
	local move=controlModule:GetMoveVector()
	if move.X~=0 then bv.Velocity=bv.Velocity+camera.CFrame.RightVector*(move.X*FlightSpeed) end
	if move.Z~=0 then bv.Velocity=bv.Velocity-camera.CFrame.LookVector*(move.Z*FlightSpeed) end
end

local function startFlying()
	if not player.Character then return end
	flying=true
	setupFlyingParts(player.Character)
	if renderStepConn then renderStepConn:Disconnect() end
	renderStepConn=RunService.RenderStepped:Connect(flyStep)
end

local function stopFlying()
	flying=false
	if renderStepConn then renderStepConn:Disconnect() end
	renderStepConn=nil
	if player.Character then
		disableFlying(player.Character)
	end
end

player.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart")
	if flying then
		task.wait(0.25)
		startFlying()
	end
end)

AddCommand({"fly"}, nil, function()
	startFlying()
end)

AddCommand({"unfly"}, nil, function()
	stopFlying()
end)

AddCommand({"flyspeed"}, nil, function(v)
	local s=tonumber(v)
	if s and s>0 then FlightSpeed=s end
end)

local velocityHandlerName = "VelocityHandler"
local gyroHandlerName = "GyroHandler"
local v3zero = Vector3.zero
local v3inf = Vector3.new(1/0,1/0,1/0)

local vflying = false
local VehicleFlightSpeed = 50
local renderStepConn

local function setupVehicleFlyingParts(char)
	local root = char:WaitForChild("HumanoidRootPart")
	for _,c in pairs(root:GetChildren()) do
		if c.Name==velocityHandlerName or c.Name==gyroHandlerName then
			c:Destroy()
		end
	end
	local bv=Instance.new("BodyVelocity")
	bv.Name=velocityHandlerName
	bv.MaxForce=v3zero
	bv.Velocity=v3zero
	bv.Parent=root
	local bg=Instance.new("BodyGyro")
	bg.Name=gyroHandlerName
	bg.MaxTorque=v3inf
	bg.P=1000
	bg.D=50
	bg.Parent=root
end

local function disableVehicleFlying(char)
	local root=char:FindFirstChild("HumanoidRootPart")
	if root then
		for _,c in pairs(root:GetChildren()) do
			if c.Name==velocityHandlerName or c.Name==gyroHandlerName then
				c:Destroy()
			end
		end
	end
	local hum=char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Sit = false
	end
end

local function vehicleFlyStep()
	local char=player.Character
	if not char then return end
	local root=char:FindFirstChild("HumanoidRootPart")
	local hum=char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	local bv=root:FindFirstChild(velocityHandlerName)
	local bg=root:FindFirstChild(gyroHandlerName)
	if not bv or not bg then return end
	bv.MaxForce=v3inf
	bg.MaxTorque=v3inf
	bg.CFrame=camera.CFrame
	bv.Velocity=v3zero
	local move=controlModule:GetMoveVector()
	if move.X~=0 then bv.Velocity=bv.Velocity+camera.CFrame.RightVector*(move.X*VehicleFlightSpeed) end
	if move.Z~=0 then bv.Velocity=bv.Velocity-camera.CFrame.LookVector*(move.Z*VehicleFlightSpeed) end
end

local function startVehicleFlying()
	if not player.Character then return end
	vflying=true
	setupVehicleFlyingParts(player.Character)
	if renderStepConn then renderStepConn:Disconnect() end
	renderStepConn=RunService.RenderStepped:Connect(vehicleFlyStep)
end

local function stopVehicleFlying()
	vflying=false
	if renderStepConn then renderStepConn:Disconnect() end
	renderStepConn=nil
	if player.Character then
		disableVehicleFlying(player.Character)
	end
end

player.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart")
	if vflying then
		task.wait(0.25)
		startVehicleFlying()
	end
end)

AddCommand({"vehiclefly", "vfly"}, nil, function()
	startVehicleFlying()
end)

AddCommand({"unvehiclefly", "unvfly"}, nil, function()
	stopVehicleFlying()
end)

AddCommand({"vehicleflyspeed", "vflyspeed"}, nil, function(v)
	local s=tonumber(v)
	if s and s>0 then VehicleFlightSpeed=s end
end)

local infiniteJumpEnabled=false
local jumpConnection

AddCommand({"flyjump"}, nil, function()
	if infiniteJumpEnabled then return end
	infiniteJumpEnabled=true
	jumpConnection=UserInputService.JumpRequest:Connect(function()
		if not infiniteJumpEnabled then return end
		local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
end)

AddCommand({"unflyjump"}, nil, function()
	if not infiniteJumpEnabled then return end
	infiniteJumpEnabled=false
	if jumpConnection then jumpConnection:Disconnect() jumpConnection=nil end
end)

local KillAura=false
local KillAuraReach=30

local function getSwordTool()
	local char=player.Character
	if not char then return nil end
	for _,item in pairs(char:GetChildren()) do
		if item:IsA("Tool") and item:FindFirstChild("Handle") then
			return item
		end
	end
	return nil
end

local function getTargetsInRange(range)
	local targets={}
	local char=player.Character
	if not char then return targets end
	local root=char:FindFirstChild("HumanoidRootPart")
	if not root then return targets end
	for _,otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer~=player then
			local targetChar=otherPlayer.Character
			if targetChar then
				local hum=targetChar:FindFirstChildOfClass("Humanoid")
				local targetRoot=targetChar:FindFirstChild("HumanoidRootPart")
				if hum and hum.Health>0 and targetRoot then
					if (targetRoot.Position - root.Position).Magnitude <= range then
						table.insert(targets,targetChar)
					end
				end
			end
		end
	end
	return targets
end

RunService.Heartbeat:Connect(function()
	if not KillAura then return end
	local tool=getSwordTool()
	if not tool then return end
	local handle=tool:FindFirstChild("Handle")
	if not handle then return end
	local targets=getTargetsInRange(KillAuraReach)
	if #targets>0 then
		tool:Activate()
		for _,targetChar in pairs(targets) do
			local targetPart=targetChar:FindFirstChild("HumanoidRootPart")
			if targetPart then
				firetouchinterest(handle,targetPart,0)
				firetouchinterest(handle,targetPart,1)
			end
		end
	end
end)

AddCommand({"killaura","ka"}, nil, function()
	KillAura=true
end)

AddCommand({"unkillaura","unka"}, nil, function()
	KillAura=false
end)

AddCommand({"killaurareach","kareach"}, nil, function(v)
	local val=tonumber(v)
	if val and val>0 then
		KillAuraReach=val
	end
end)

local infiniteAura=false
local infiniteAuraReach=math.huge

RunService.Heartbeat:Connect(function()
	if not infiniteAura then return end
	local tool=getSwordTool()
	if not tool then return end
	local handle=tool:FindFirstChild("Handle")
	if not handle then return end
	local targets=getTargetsInRange(infiniteAuraReach)
	if #targets>0 then
		tool:Activate()
		for _,targetChar in pairs(targets) do
			local targetPart=targetChar:FindFirstChild("HumanoidRootPart")
			if targetPart then
				firetouchinterest(handle,targetPart,0)
				firetouchinterest(handle,targetPart,1)
			end
		end
	end
end)

AddCommand({"infiniteaura","infaura"}, nil, function()
	infiniteAura=true
end)

AddCommand({"uninfiniteaura","uninfaura"}, nil, function()
	infiniteAura=false
end)

local activeLoopKills = {}

RunService.Heartbeat:Connect(function()
	if next(activeLoopKills) == nil then return end
	local tool=getSwordTool()
	if not tool then return end
	local handle=tool:FindFirstChild("Handle")
	if not handle then return end
	local myChar=player.Character
	local myRoot=myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myChar or not myRoot then return end
	for _,target in pairs(activeLoopKills) do
		local targetChar=target.Character
		local targetRoot=targetChar and targetChar:FindFirstChild("HumanoidRootPart")
		local hum=targetChar and targetChar:FindFirstChildOfClass("Humanoid")
		if targetRoot and hum and hum.Health>0 then
			tool:Activate()
			firetouchinterest(handle,targetRoot,0)
			firetouchinterest(handle,targetRoot,1)
		end
	end
end)

local function matchPlayers(partialName)
	local results = {}
	partialName = partialName:lower()
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= player then
			if p.Name:lower():find(partialName) or (p.DisplayName and p.DisplayName:lower():find(partialName)) then
				table.insert(results,p)
			end
		end
	end
	return results
end

AddCommand({"loopkill"}, nil, function(name)
	for _,target in pairs(matchPlayers(name)) do
		activeLoopKills[target] = target
	end
end)

AddCommand({"unloopkill"}, nil, function()
	activeLoopKills = {}
end)

AddCommand({"chat"}, nil, function(...)
    local msg = table.concat({...}, " ")
    local ChatService = game:GetService("TextChatService").TextChannels.RBXGeneral
    ChatService:SendAsync(msg)
end)

AddCommand({"rejoin","rj"}, nil, function()
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
	Notification("Rejoin", "Rejoining...", 5)
end)

AddCommand({"serverhop","shop"}, nil, function()
	local servers = {}
	local req = syn and syn.request or http_request or request
	local response = req({
		Url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId),
		Method = "GET"
	})
	if response and response.Body then
		local data = HttpService:JSONDecode(response.Body)
		for _,server in pairs(data.data) do
			if server.id ~= game.JobId and server.playing < server.maxPlayers then
				table.insert(servers, server.id)
			end
		end
	end
	if #servers > 0 then
		TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], player)
		Notification("Serverhop", "Finding server...", 5)
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local followLoop, followTarget

local function getPlr(name)
	name = name:lower()
	local matches = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local uname = plr.Name:lower()
			local dname = plr.DisplayName:lower()
			if uname:sub(1, #name) == name or dname:sub(1, #name) == name then
				table.insert(matches, plr)
			end
		end
	end
	if name == "random" and #matches > 0 then
		return matches[math.random(1, #matches)]
	end
	return matches[1]
end

local function SafeDisconnect(conn)
	if conn and typeof(conn) == "RBXScriptConnection" then
		conn:Disconnect()
	end
end

AddCommand({"follow"}, nil, function(name)
	local plr = getPlr(name)
	if not plr then return end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local targetChar = plr.Character
	local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	if not hrp or not hum or not targetHRP then return end
	followTarget = targetHRP
	SafeDisconnect(followLoop)
	followLoop = RunService.RenderStepped:Connect(function()
		if not followTarget or not followTarget.Parent or not hum or not hum.Parent then return end
			hum:MoveTo(followTarget.Position)
	end)
end)

AddCommand({"unfollow"}, nil, function()
	SafeDisconnect(followLoop)
	followLoop = nil
	followTarget = nil
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum:MoveTo(hum.Parent:GetPivot().Position) end
end)

AddCommand({"sit"}, nil, function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.Sit = true end
end)

AddCommand({"unsit"}, nil, function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.Sit = false end
end)

AddCommand({"lay"}, nil, function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	hum.Sit = true
	task.wait(0.1)
	local root = hum.RootPart or hum.Parent:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = root.CFrame * CFrame.Angles(math.pi/2, 0, 0)
	end
	for _,a in pairs(hum:GetPlayingAnimationTracks()) do a:Stop() end
end)

AddCommand({"unlay"}, nil, function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.Sit = false end
end)

AddCommand({"jump"}, nil, function()
	game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
end)

local headSit

AddCommand({"headsit"}, nil, function(targetPartialName)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local speakerRoot = character:WaitForChild("HumanoidRootPart")

	local targetPlayer

	if targetPartialName:lower() == "random" then
		local allPlayers = {}
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				table.insert(allPlayers, p)
			end
		end
		if #allPlayers == 0 then return end
		targetPlayer = allPlayers[math.random(1, #allPlayers)]
	else
		local lowerPartial = targetPartialName:lower()
		for _, p in pairs(Players:GetPlayers()) do
			if p.Name:lower():find(lowerPartial, 1, true) or (p.DisplayName and p.DisplayName:lower():find(lowerPartial, 1, true)) then
				targetPlayer = p
				break
			end
		end
	end

	if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

	if headSit then headSit:Disconnect() end
	humanoid.Sit = true

	local targetRoot = targetPlayer.Character.HumanoidRootPart

	headSit = RunService.Heartbeat:Connect(function()
		if Players:FindFirstChild(targetPlayer.Name) and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and character and speakerRoot and humanoid.Sit then
			speakerRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 1.6, 0.4)
		else
			if headSit then
				headSit:Disconnect()
				headSit = nil
				humanoid.Sit = false
			end
		end
	end)
end)

AddCommand({"unheadsit"}, nil, function()
	if headSit then
		headSit:Disconnect()
		headSit = nil
	end
	local player = game.Players.LocalPlayer
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Sit = false
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
end)

local InvisibleParts = {}

local function isDescendantOfPlayerCharacter(part)
	for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
		local char = plr.Character
		if char and part:IsDescendantOf(char) then
			return true
		end
	end
	return false
end

AddCommand({"removeinvisibleparts","removeinvisparts"}, nil, function()
	InvisibleParts = {}
	local count = 0
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 and not isDescendantOfPlayerCharacter(v) then
			table.insert(InvisibleParts, {Instance = v, Parent = v.Parent})
			v.Parent = nil
			count += 1
		end
	end
	Notification("RemoveInvisibleParts", tostring(count) .. " Invisible Parts Removed", 5)
end)

AddCommand({"restoreinvisibleparts","restoreinvisparts"}, nil, function()
	local count = 0
	for _, data in ipairs(InvisibleParts) do
		if data.Instance and data.Parent then
			data.Instance.Parent = data.Parent
			count += 1
		end
	end
	Notification("RestoreInvisibleParts", tostring(count) .. " Parts Restored", 5)
	InvisibleParts = {}
end)

AddCommand({"teleporttool","tptool"}, nil, function()
local tool = Instance.new("Tool")
tool.Name = "Teleport Tool"
tool.RequiresHandle = false
tool.CanBeDropped = false
tool.Parent = game.Players.LocalPlayer.Backpack

tool.Activated:Connect(function()
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local targetPos = mouse.Hit.p
    player.Character:MoveTo(targetPos)
end)
end)

AddCommand({"jerk"}, nil, function()
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
	if not humanoid or not backpack then return end

	local tool = Instance.new("Tool")
	tool.Name = "Jerk"
	tool.RequiresHandle = false
	tool.Parent = backpack

	local jorkin = false
	local track = nil

	local function stopTomfoolery()
		jorkin = false
		if track then
			track:Stop()
			track = nil
		end
	end

	tool.Equipped:Connect(function() jorkin = true end)
	tool.Unequipped:Connect(stopTomfoolery)
	humanoid.Died:Connect(stopTomfoolery)

	coroutine.wrap(function()
		while wait() do
			if not jorkin then continue end
			if not track then
				local anim = Instance.new("Animation")
				local r15 = humanoid.RigType == Enum.HumanoidRigType.R15
				anim.AnimationId = r15 and "rbxassetid://698251653" or "rbxassetid://72042024"
				track = humanoid:LoadAnimation(anim)
			end
			track:Play()
			track:AdjustSpeed(humanoid.RigType == Enum.HumanoidRigType.R15 and 0.7 or 0.65)
			track.TimePosition = 0.6
			wait(0.2)
			while track and track.TimePosition < (humanoid.RigType == Enum.HumanoidRigType.R15 and 0.7 or 0.65) do
				wait(0.2)
			end
			if track then
				track:Stop()
				track = nil
			end
		end
	end)()
end)

AddCommand({"equiptools"}, nil, function()
	local player = game:GetService("Players").LocalPlayer
	local Backpack = player:FindFirstChild("Backpack")
	local Character = player.Character

	if Backpack and Character then
		for _, tool in pairs(Backpack:GetChildren()) do
			if tool:IsA("Tool") then
				tool.Parent = Character
			end
		end
	end
end)

AddCommand({"droptools"}, nil, function()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
	if tool:IsA("Tool") then
		tool.Parent = LocalPlayer.Character
	end
end

for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
	if tool:IsA("Tool") then
		tool.Parent = workspace
	end
end
end)

AddCommand({"deletetools","notools"}, nil, function()
	local player = game:GetService("Players").LocalPlayer
	local Backpack = player:FindFirstChild("Backpack")
	local Character = player.Character

	if Backpack then
		for _, tool in pairs(Backpack:GetChildren()) do
			if tool:IsA("Tool") then
				tool:Destroy()
			end
		end
	end

	if Character then
		for _, tool in pairs(Character:GetChildren()) do
			if tool:IsA("Tool") then
				tool:Destroy()
			end
		end
	end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function formatNumber(n)
	return math.floor(n) == n and tostring(n) or string.format("%.1f", n)
end

AddCommand({"teleportposition", "teleportpos", "tppos"}, nil, function(...)
	local args = {...}
	local x, y, z

	for i = 1, #args do
		args[i] = args[i]:gsub(",", "")
	end

	if #args == 1 then
		local parts = {}
		for part in args[1]:gmatch("[^,%s]+") do
			table.insert(parts, part)
		end
		x, y, z = parts[1], parts[2], parts[3]
	else
		x, y, z = args[1], args[2], args[3]
	end

	x = tonumber(x)
	y = tonumber(y)
	z = tonumber(z)

	if not x or not y or not z then
		Notification("Teleport Position", "Invalid Coordinates Usage: <x> <y> <z>", 5)
		return
	end

	local character = LocalPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	hrp.CFrame = CFrame.new(x, y, z)
	Notification("Teleport Position", ("Teleported To %s, %s, %s"):format(formatNumber(x), formatNumber(y), formatNumber(z)), 5)
end)

AddCommand({"copyposition", "copypos"}, nil, function()
	local character = LocalPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local pos = hrp.Position
	local str = ("%d, %d, %d"):format(pos.X, pos.Y, pos.Z)
	pcall(setclipboard, str)
	Notification("Copy Position", "Copied Position: " .. str, 5)
end)

local savedTransparency = {}

local function isDescendantOfPlayerOrNPC(part)
	for _, plr in pairs(Players:GetPlayers()) do
		local char = plr.Character
		if char and part:IsDescendantOf(char) then
			return true
		end
	end
	local NPCFolder = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("Monsters")
	if NPCFolder then
		for _, npc in pairs(NPCFolder:GetChildren()) do
			if part:IsDescendantOf(npc) then
				return true
			end
		end
	end
	return false
end

local savedTransparency = {}

local function isDescendantOfPlayerOrNPC(part)
	for _, plr in pairs(Players:GetPlayers()) do
		local char = plr.Character
		if char and part:IsDescendantOf(char) then
			return true
		end
	end
	local NPCFolder = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("Monsters")
	if NPCFolder then
		for _, npc in pairs(NPCFolder:GetChildren()) do
			if part:IsDescendantOf(npc) then
				return true
			end
		end
	end
	return false
end

AddCommand({"xray"}, nil, function()
	savedTransparency = {}
	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and not isDescendantOfPlayerOrNPC(part) and part.Transparency < 1 then
			savedTransparency[part] = part.Transparency
			part.Transparency = 0.5
		end
	end
	Notification("Xray", "Xray Enabled", 5)
end)

AddCommand({"unxray"}, nil, function()
	for part, oldTransparency in pairs(savedTransparency) do
		if part and part:IsA("BasePart") then
			part.Transparency = oldTransparency
		end
	end
	savedTransparency = {}
	Notification("Xray", "Xray Disabled", 5)
end)

workspace.DescendantAdded:Connect(function(part)
	if savedTransparency[part] == nil and part:IsA("BasePart") and not isDescendantOfPlayerOrNPC(part) and next(savedTransparency) ~= nil and part.Transparency < 1 then
		savedTransparency[part] = part.Transparency
		part.Transparency = 0.5
	end
end)

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local speaker = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local orbiting = false
local orbitTarget
local orbitSpeed = 10
local orbitDistance = 5
local orbitConnection
local viewConnection

local function getCharacterHRP()
	local character = speaker.Character
	if character then
		return character:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function moveCharacter(cframe)
	local hrp = getCharacterHRP()
	if hrp then
		hrp.CFrame = cframe
	end
end

local function matchPlayer(input)
	input = input:lower()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= speaker then
			if player.Name:lower():sub(1, #input) == input or player.DisplayName:lower():sub(1, #input) == input then
				return player
			end
		end
	end
end

AddCommand({"orbit"}, nil, function(arg)
	if orbiting and orbitConnection then orbitConnection:Disconnect() end
	if viewConnection then viewConnection:Disconnect() end

	local target
	if arg == "random" then
		local plrs = Players:GetPlayers()
		if #plrs > 1 then
			repeat target = plrs[math.random(1, #plrs)] until target ~= speaker
		end
	else
		target = matchPlayer(arg)
	end

	if not target or not target.Character then return end
	Notification("Orbit", "Orbiting " .. target.Name, 4)

	orbiting = true
	orbitTarget = target
	local angle = 0

	orbitConnection = RunService.RenderStepped:Connect(function(dt)
		if not orbiting then return end
		local tChar = orbitTarget.Character
		local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
		if not tHRP then return end
		angle += orbitSpeed * dt
		local offset = Vector3.new(math.cos(angle) * orbitDistance, 0, math.sin(angle) * orbitDistance)
		local orbitPos = tHRP.Position + offset
		moveCharacter(CFrame.new(orbitPos, tHRP.Position))
	end)

	viewConnection = RunService.RenderStepped:Connect(function()
		if not orbiting then return end
		local tChar = orbitTarget.Character
		local head = tChar and tChar:FindFirstChild("Head")
		if head then
			camera.CameraSubject = head
		end
	end)
end)

AddCommand({"orbitspeed"}, nil, function(val)
	local v = tonumber(val)
	if v then orbitSpeed = v end
end)

AddCommand({"orbitdistance"}, nil, function(val)
	local v = tonumber(val)
	if v then orbitDistance = v end
end)

AddCommand({"unorbit"}, nil, function()
	if orbiting and orbitConnection then orbitConnection:Disconnect() end
	if viewConnection then viewConnection:Disconnect() end
	camera.CameraSubject = speaker.Character and speaker.Character:FindFirstChild("Humanoid")
	orbiting = false
end)

AddCommand({"killnpcs"}, nil, function()
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and not Players:GetPlayerFromCharacter(npc) then
			local humanoid = npc:FindFirstChildOfClass("Humanoid")
			local root = npc:FindFirstChild("HumanoidRootPart")
			if humanoid and root and not root.Anchored then
				humanoid.Health = 0
			end
		end
	end
end)

AddCommand({"bringnpcs"}, nil, function()
	local root = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and not Players:GetPlayerFromCharacter(npc) then
			local humanoid = npc:FindFirstChildOfClass("Humanoid")
			local npcRoot = npc:FindFirstChild("HumanoidRootPart")
			if humanoid and npcRoot and not npcRoot.Anchored then
				npcRoot.CFrame = root.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
			end
		end
	end
end)

AddCommand({"sitnpcs"}, nil, function()
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and not Players:GetPlayerFromCharacter(npc) then
			local humanoid = npc:FindFirstChildOfClass("Humanoid")
			local root = npc:FindFirstChild("HumanoidRootPart")
			if humanoid and root and not root.Anchored then
				humanoid.Sit = true
			end
		end
	end
end)

AddCommand({"unsitnpcs"}, nil, function()
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and not Players:GetPlayerFromCharacter(npc) then
			local humanoid = npc:FindFirstChildOfClass("Humanoid")
			local root = npc:FindFirstChild("HumanoidRootPart")
			if humanoid and root and not root.Anchored then
				humanoid.Sit = false
			end
		end
	end
end)

AddCommand({"freezenpcs"}, nil, function()
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and not Players:GetPlayerFromCharacter(npc) then
			local humanoid = npc:FindFirstChildOfClass("Humanoid")
			local root = npc:FindFirstChild("HumanoidRootPart")
			if humanoid and root and not root.Anchored then
				humanoid.WalkSpeed = 0
				humanoid.JumpPower = 0
			end
		end
	end
end)

AddCommand({"punishnpcs"}, nil, function()
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and not Players:GetPlayerFromCharacter(npc) then
			local humanoid = npc:FindFirstChildOfClass("Humanoid")
			local root = npc:FindFirstChild("HumanoidRootPart")
			if humanoid and root and not root.Anchored then
				root.CFrame = root.CFrame + Vector3.new(0, 9999999, 0)
			end
		end
	end
end)

AddCommand({"remotespy","rspy"}, nil, function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

AddCommand({"teleportunanchored", "tpua"}, nil, function(targetName)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    local targetPlayer
    local nameLower = targetName:lower()
    if nameLower == "random" then
        local all = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(all, p)
            end
        end
        if #all == 0 then return end
        targetPlayer = all[math.random(1, #all)]
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():find(nameLower, 1, true) or (p.DisplayName and p.DisplayName:lower():find(nameLower, 1, true)) then
                targetPlayer = p
                break
            end
        end
    end
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local character = targetPlayer.Character
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if getgenv()._teleportFolder then getgenv()._teleportFolder:Destroy() end
    local folder = Instance.new("Folder", Workspace)
    getgenv()._teleportFolder = folder
    local part = Instance.new("Part", folder)
    local attachment1 = Instance.new("Attachment", part)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1,1,1)
    if not getgenv().Network then
        getgenv().Network = {
            BaseParts = {},
            Velocity = Vector3.new(14.46, 14.46, 14.46)
        }
        Network.RetainPart = function(p)
            if p:IsA("BasePart") and p:IsDescendantOf(Workspace) then
                table.insert(Network.BaseParts, p)
                p.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                p.CanCollide = false
            end
        end
        RunService.Heartbeat:Connect(function()
            pcall(function()
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end)
            for _, p in pairs(Network.BaseParts) do
                if p:IsDescendantOf(Workspace) then
                    p.Velocity = Network.Velocity
                end
            end
        end)
    end
    local modifiedParts = {}
    getgenv()._modifiedParts = modifiedParts
    local function ForcePart(v)
        if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(LocalPlayer.Character) and not v.Parent:FindFirstChildOfClass("Humanoid") and v.Name ~= "Handle" then
            for _, x in ipairs(v:GetChildren()) do
                if x:IsA("BodyMover") or x:IsA("RocketPropulsion") or x:IsA("Attachment") or x:IsA("AlignPosition") or x:IsA("Torque") then
                    x:Destroy()
                end
            end
            if v.CanCollide then
                modifiedParts[v] = true
                v.CanCollide = false
            end
            local Torque = Instance.new("Torque", v)
            Torque.Torque = Vector3.new(100000, 100000, 100000)
            local AlignPosition = Instance.new("AlignPosition", v)
            AlignPosition.MaxForce = math.huge
            AlignPosition.MaxVelocity = math.huge
            AlignPosition.Responsiveness = 200
            local Attachment2 = Instance.new("Attachment", v)
            Torque.Attachment0 = Attachment2
            AlignPosition.Attachment0 = Attachment2
            AlignPosition.Attachment1 = attachment1
        end
    end
    for _, v in ipairs(Workspace:GetDescendants()) do
        ForcePart(v)
    end
    if getgenv()._descendantConn then getgenv()._descendantConn:Disconnect() end
    getgenv()._descendantConn = Workspace.DescendantAdded:Connect(ForcePart)
    if getgenv()._renderConn then getgenv()._renderConn:Disconnect() end
    getgenv()._renderConn = RunService.RenderStepped:Connect(function()
        if humanoidRootPart and attachment1 then
            attachment1.WorldCFrame = humanoidRootPart.CFrame
        end
    end)
end)

AddCommand({"unteleportunanchored", "untpua"}, nil, function()
    if getgenv()._renderConn then
        getgenv()._renderConn:Disconnect()
        getgenv()._renderConn = nil
    end
    if getgenv()._descendantConn then
        getgenv()._descendantConn:Disconnect()
        getgenv()._descendantConn = nil
    end
    if getgenv()._teleportFolder then
        getgenv()._teleportFolder:Destroy()
        getgenv()._teleportFolder = nil
    end
    if getgenv()._modifiedParts then
        for part, wasCollidable in pairs(getgenv()._modifiedParts) do
            if part and part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        getgenv()._modifiedParts = {}
    end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local storedAnims = {}

local function storeAnimations(hum)
    local animate = hum.Parent:FindFirstChild("Animate")
    if not animate then return end
    if storedAnims[hum] then return end
    local store = {}
    for _, obj in pairs(animate:GetChildren()) do
        if obj:IsA("StringValue") then
            local anim = obj:FindFirstChildWhichIsA("Animation")
            if anim then
                store[obj.Name] = anim.AnimationId
            end
        end
    end
    storedAnims[hum] = store
end

local function setAnim(hum, name, id)
    local animate = hum.Parent:FindFirstChild("Animate")
    if not animate then return end
    local obj = animate:FindFirstChild(name)
    if obj and obj:IsA("StringValue") then
        local anim = obj:FindFirstChildWhichIsA("Animation")
        if anim then
            anim.AnimationId = "rbxassetid://"..tostring(id)
        end
    end
end

local function getHum()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return character:FindFirstChildWhichIsA("Humanoid")
end

local function SafeStop(animTrack)
    if animTrack and typeof(animTrack.Stop) == "function" then
        animTrack:Stop()
    end
end

local function SafeDestroy(obj)
    if obj and typeof(obj.Destroy) == "function" then
        obj:Destroy()
    end
end

local function SafeDisconnect(conn)
    if conn and typeof(conn.Disconnect) == "function" then
        conn:Disconnect()
    end
end

AddCommand({"killeranimation", "killeranim"}, nil, function()
    local hum = getHum()
    if not hum then return end
    storeAnimations(hum)
    setAnim(hum, "walk", 252557606)
    setAnim(hum, "run", 252557606)
    setAnim(hum, "jump", 165167557)
    setAnim(hum, "fall", 97170520)
end)

AddCommand({"psychoanimation", "psychoanim"}, nil, function()
    local hum = getHum()
    if not hum then return end
    storeAnimations(hum)
    setAnim(hum, "walk", 95415492)
    setAnim(hum, "run", 95415492)
    setAnim(hum, "jump", 165167557)
    setAnim(hum, "fall", 97170520)
end)

local psychoTrack

AddCommand({"tweak"}, nil, function()
	local hum = getHum()
	if not hum then return end
	for _, tr in ipairs(hum:GetPlayingAnimationTracks()) do
		SafeStop(tr)
	end
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://33796059"
	psychoTrack = hum:LoadAnimation(anim)
	psychoTrack:Play()
	psychoTrack:AdjustSpeed(50)
end)

AddCommand({"untweak"}, nil, function()
	if psychoTrack then
		SafeStop(psychoTrack)
		SafeDestroy(psychoTrack)
		psychoTrack = nil
	end
end)

AddCommand({"noanimation", "noanim"}, nil, function()
game.Players.LocalPlayer.Character.Animate.Disabled = true
end)

AddCommand({"reanimation", "reanim"}, nil, function()
game.Players.LocalPlayer.Character.Animate.Disabled = false
end)

AddCommand({"animationspeed", "animspeed"}, nil, function(speed)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
	local Char = LocalPlayer.Character
	local Hum = Char and (Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController"))
	if not Hum then return end
	for _, v in next, Hum:GetPlayingAnimationTracks() do
		v:AdjustSpeed(tonumber(speed) or 1)
	end
end)

AddCommand({"restoreanimations", "restoreanims"}, nil, function()
    local hum = getHum()
    if not hum then return end
    local animate = hum.Parent:FindFirstChild("Animate")
    if not animate then return end
    local store = storedAnims[hum]
    if not store then return end
    for name, id in pairs(store) do
        local obj = animate:FindFirstChild(name)
        if obj and obj:IsA("StringValue") then
            local anim = obj:FindFirstChildWhichIsA("Animation")
            if anim then
                anim.AnimationId = id
            end
        end
    end
    storedAnims[hum] = nil
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    wait(1)
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local function getChar(plr)
	plr = plr or LocalPlayer
	return plr.Character
end

local function getHum(plr)
	local char = getChar(plr)
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot(char)
	char = char or getChar()
	return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function IsR15(plr)
	local char = getChar(plr)
	return char and char:FindFirstChild("UpperTorso") ~= nil
end

local function IsR6(plr)
	local char = getChar(plr)
	return char and char:FindFirstChild("UpperTorso") == nil
end

local function getPlr(name)
	name = name and name:lower()
	local players = {}
	if not name or name == "" then return players end
	if name == "random" then
		local allPlayers = Players:GetPlayers()
		if #allPlayers <= 1 then return players end
		local filtered = {}
		for _, p in pairs(allPlayers) do
			if p ~= LocalPlayer then
				table.insert(filtered, p)
			end
		end
		if #filtered == 0 then return players end
		table.insert(players, filtered[math.random(1, #filtered)])
		return players
	end
	for _, p in pairs(Players:GetPlayers()) do
		if p.Name:lower():find(name, 1, true) or (p.DisplayName and p.DisplayName:lower():find(name, 1, true)) then
			table.insert(players, p)
		end
	end
	return players
end

local function InstanceNew(class)
	return Instance.new(class)
end

local function Insert(tbl, val)
	table.insert(tbl, val)
end

local function Wait(t)
	RunService.RenderStepped:Wait()
	if t then task.wait(t) end
end

local function NACaller(func)
	local success, err = pcall(func)
	if not success then warn(err) end
end

local inversebangLoop, inversebangAnim, inversebangAnim2, inversebangDied, doInversebang, doInversebang2
local INVERSEBANGPARTS = {}

AddCommand({"inversebang"}, nil, function(h)
	if inversebangLoop then inversebangLoop = nil end
	if doInversebang then doInversebang:Stop() end
	if inversebangAnim then inversebangAnim:Destroy() end
	if inversebangAnim2 then inversebangAnim2:Destroy() end
	if inversebangDied then inversebangDied:Disconnect() end
	for _, p in pairs(INVERSEBANGPARTS) do p:Destroy() end
	INVERSEBANGPARTS = {}

	local speed = 10
	local targets = getPlr(h)
	if #targets == 0 then return end
	local plr = targets[1]
	if plr == LocalPlayer then return end

	inversebangAnim = InstanceNew("Animation")
	local isR15 = IsR15(LocalPlayer)
	if not isR15 then
		inversebangAnim.AnimationId = "rbxassetid://189854234"
		inversebangAnim2 = InstanceNew("Animation")
		inversebangAnim2.AnimationId = "rbxassetid://106772613"
	else
		inversebangAnim.AnimationId = "rbxassetid://10714360343"
		inversebangAnim2 = nil
	end

	local hum = getHum()
	if not hum then return end
	doInversebang = hum:LoadAnimation(inversebangAnim)
	doInversebang:Play(0.1,1,1)
	doInversebang:AdjustSpeed(speed)
	if not isR15 and inversebangAnim2 then
		doInversebang2 = hum:LoadAnimation(inversebangAnim2)
		doInversebang2:Play(0.1,1,1)
		doInversebang2:AdjustSpeed(speed)
	end

	inversebangDied = hum.Died:Connect(function()
		if inversebangLoop then inversebangLoop = nil end
		doInversebang:Stop()
		if doInversebang2 then doInversebang2:Stop() end
		inversebangAnim:Destroy()
		inversebangDied:Disconnect()
		for _, part in pairs(INVERSEBANGPARTS) do part:Destroy() end
		INVERSEBANGPARTS = {}
	end)

	local thick, halfWidth, halfDepth, halfHeight = 0.2, 2, 2, 3
	local walls = {
		{offset = CFrame.new(0, 0, halfDepth + thick/500),    size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(0, 0, -(halfDepth + thick/500)), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(halfWidth + thick/500, 0, 0),    size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(-(halfWidth + thick/500), 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(0, halfHeight + thick/500, 0),   size = Vector3.new(4, thick, 4)},
		{offset = CFrame.new(0, -(halfHeight + thick/500), 0),size = Vector3.new(4, thick, 4)},
	}
	for i, wall in ipairs(walls) do
		local part = InstanceNew("Part")
		part.Size = wall.size
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 1
		part.Parent = workspace
		Insert(INVERSEBANGPARTS, part)
	end

	inversebangLoop = coroutine.wrap(function()
		while true do
			local targetPlayer = Players:FindFirstChild(plr.Name)
			local targetCharacter = targetPlayer and targetPlayer.Character
			local localCharacter = getChar()
			if targetCharacter and getRoot(targetCharacter) and localCharacter and getRoot(localCharacter) then
				local targetHRP = getRoot(targetCharacter)
				local localHRP = getRoot(localCharacter)
				local forwardCFrame = targetHRP.CFrame * CFrame.new(0,0,-2.5)
				local backwardCFrame = targetHRP.CFrame * CFrame.new(0,0,-1.3)
				local tweenForward = TweenService:Create(localHRP,TweenInfo.new(0.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CFrame=forwardCFrame})
				tweenForward:Play()
				tweenForward.Completed:Wait()
				local tweenBackward = TweenService:Create(localHRP,TweenInfo.new(0.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CFrame=backwardCFrame})
				tweenBackward:Play()
				tweenBackward.Completed:Wait()
				for i, wall in ipairs(walls) do
					INVERSEBANGPARTS[i].CFrame = localHRP.CFrame * wall.offset
				end
			end
			wait(0.1)
		end
	end)
	inversebangLoop()
end)

AddCommand({"uninversebang"}, nil, function()
	if inversebangLoop then inversebangLoop = nil end
	if doInversebang then doInversebang:Stop() end
	if doInversebang2 then doInversebang2:Stop() end
	if inversebangAnim then inversebangAnim:Destroy() end
	if inversebangDied then inversebangDied:Disconnect() end
	for _, p in pairs(INVERSEBANGPARTS) do p:Destroy() end
	INVERSEBANGPARTS = {}
end)

local jerkAnim, jerkTrack, jerkLoop, jerkDied, jerkParts = nil, nil, nil, nil, {}

AddCommand({"jerkuser"}, nil, function(h)
	if not IsR6() then return end
	local players = getPlr(h)
	if #players == 0 then return end
	local plr = players[1]
	local char = getChar()
	if not char then return end
	local humanoid = getHum()
	if not humanoid then return end
	if jerkLoop then jerkLoop:Disconnect() end
	if jerkTrack then jerkTrack:Stop() end
	if jerkAnim then jerkAnim:Destroy() end
	if jerkDied then jerkDied:Disconnect() end
	for _, p in pairs(jerkParts) do p:Destroy() end
	jerkParts = {}

	jerkAnim = InstanceNew("Animation")
	jerkAnim.AnimationId = "rbxassetid://95383980"
	jerkTrack = humanoid:LoadAnimation(jerkAnim)
	jerkTrack.Looped = true
	jerkTrack:Play()

	humanoid.Sit = true
	wait(0.1)

	local root = getRoot(char)
	if not root then return end

	root.CFrame = root.CFrame * CFrame.Angles(math.pi * 0.5, math.pi, 0)

	local thick, halfWidth, halfDepth, halfHeight = 0.2, 2, 2, 3
	local walls = {
		{offset = CFrame.new(0, 0, halfDepth + thick / 500), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(0, 0, -(halfDepth + thick / 500)), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(halfWidth + thick / 500, 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(-(halfWidth + thick / 500), 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(0, halfHeight + thick / 500, 0), size = Vector3.new(4, thick, 4)},
		{offset = CFrame.new(0, -(halfHeight + thick / 500), 0), size = Vector3.new(4, thick, 4)},
	}

	for i, wall in ipairs(walls) do
		local part = InstanceNew("Part")
		part.Size = wall.size
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 1
		part.Parent = workspace
		Insert(jerkParts, part)
	end

	jerkLoop = RunService.Stepped:Connect(function()
		for i, wall in ipairs(walls) do
			jerkParts[i].CFrame = root.CFrame * wall.offset
		end
		local targetChar = plr.Character
		local targetRoot = targetChar and getRoot(targetChar)
		if targetRoot then
			root.CFrame = targetRoot.CFrame * CFrame.new(0, -2.5, -0.25) * CFrame.Angles(math.pi * 0.5, 0, math.pi)
		end
	end)

	jerkDied = humanoid.Died:Connect(function()
		if jerkLoop then jerkLoop:Disconnect() end
		if jerkTrack then jerkTrack:Stop() end
		if jerkAnim then jerkAnim:Destroy() end
		if jerkDied then jerkDied:Disconnect() end
		for _, p in pairs(jerkParts) do p:Destroy() end
		jerkParts = {}
	end)
end)

AddCommand({"unjerkuser"}, nil, function()
	if jerkLoop then jerkLoop:Disconnect() end
	if jerkTrack then jerkTrack:Stop() end
	if jerkAnim then jerkAnim:Destroy() end
	if jerkDied then jerkDied:Disconnect() end

	local char = getChar()
	local root = getRoot(char)
	if root then
		root.CFrame = root.CFrame * CFrame.Angles(0, math.pi, 0)
	end

	local humanoid = getHum()
	if humanoid then
		humanoid.Sit = false
	end

	for _, p in pairs(jerkParts) do
		p:Destroy()
	end
	jerkParts = {}
end)

local suckLOOP, suckANIM, suckDIED, doSUCKING
local SUCKYSUCKY = {}

AddCommand({"dicksuck"}, nil, function(h)
	suckLOOP = nil
	if doSUCKING then doSUCKING:Stop() end
	if suckANIM then suckANIM:Destroy() end
	if suckDIED then suckDIED:Disconnect() end
	for _, p in pairs(SUCKYSUCKY) do p:Destroy() end
	SUCKYSUCKY = {}

	local speed = 10
	local tweenDuration = 1 / speed
	local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local targets = getPlr(h)
	if #targets == 0 then return end
	local plr = targets[1]
	local targetName = plr.Name

	suckANIM = InstanceNew("Animation")
	if not IsR15(LocalPlayer) then
		suckANIM.AnimationId = "rbxassetid://189854234"
	else
		suckANIM.AnimationId = "rbxassetid://5918726674"
	end

	local hum = getHum()
	if not hum then return end
	doSUCKING = hum:LoadAnimation(suckANIM)
	doSUCKING:Play(0.1, 1, 1)
	doSUCKING:AdjustSpeed(speed)

	suckDIED = hum.Died:Connect(function()
		suckLOOP = nil
		if doSUCKING then doSUCKING:Stop() end
		if suckANIM then suckANIM:Destroy() end
		if suckDIED then suckDIED:Disconnect() end
		for _, p in pairs(SUCKYSUCKY) do p:Destroy() end
		SUCKYSUCKY = {}
	end)

	local thick, halfWidth, halfDepth, halfHeight = 0.2, 2, 2, 3
	local walls = {
		{offset = CFrame.new(0, 0, halfDepth + thick / 500), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(0, 0, -(halfDepth + thick / 500)), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(halfWidth + thick / 500, 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(-(halfWidth + thick / 500), 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(0, halfHeight + thick / 500, 0), size = Vector3.new(4, thick, 4)},
		{offset = CFrame.new(0, -(halfHeight + thick / 500), 0), size = Vector3.new(4, thick, 4)},
	}

	for _, wall in ipairs(walls) do
		local part = InstanceNew("Part")
		part.Size = wall.size
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 1
		part.Parent = workspace
		Insert(SUCKYSUCKY, part)
	end

	suckLOOP = coroutine.wrap(function()
		while true do
			local targetPlayer = Players:FindFirstChild(targetName)
			local targetChar = targetPlayer and targetPlayer.Character
			local localChar = getChar()
			if targetChar and getRoot(targetChar) and localChar and getRoot(localChar) then
				local targetHRP = getRoot(targetChar)
				local localHRP = getRoot(localChar)
				local forwardCFrame = targetHRP.CFrame * CFrame.new(0, -2.3, -2.5) * CFrame.Angles(0, math.pi, 0)
				local backwardCFrame = targetHRP.CFrame * CFrame.new(0, -2.3, -1.3) * CFrame.Angles(0, math.pi, 0)
				local tweenForward = TweenService:Create(localHRP, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = forwardCFrame})
				tweenForward:Play()
				tweenForward.Completed:Wait()
				local tweenBackward = TweenService:Create(localHRP, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = backwardCFrame})
				tweenBackward:Play()
				tweenBackward.Completed:Wait()
				for i, wall in ipairs(walls) do
					SUCKYSUCKY[i].CFrame = localHRP.CFrame * wall.offset
				end
			end
			Wait(0.1)
		end
	end)
	suckLOOP()
end)

AddCommand({"undicksuck"}, nil, function()
	suckLOOP = nil
	if doSUCKING then doSUCKING:Stop() end
	if suckANIM then suckANIM:Destroy() end
	if suckDIED then suckDIED:Disconnect() end
	for _, p in pairs(SUCKYSUCKY) do p:Destroy() end
	SUCKYSUCKY = {}
end)

local originalFallenPartsDestroyHeight = workspace.FallenPartsDestroyHeight

AddCommand({"enablevoid", "ev"}, nil, function()
    workspace.FallenPartsDestroyHeight = originalFallenPartsDestroyHeight
    Notification("Enable Void", "Enabled Roblox Void", 5)
end)

AddCommand({"disablevoid", "nv"}, nil, function()
    workspace.FallenPartsDestroyHeight = -math.huge
    Notification("Disable Void", "Disabled Roblox Void", 5)
end)

Notification("Zephyr Admin", "Welcome to Zephyr Admin", 5)
