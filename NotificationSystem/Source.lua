local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local gui = Instance.new("ScreenGui")
gui.Name = "NotificationGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = CoreGui

local container = Instance.new("Frame")
container.Name = "NotificationContainer"
container.Size = UDim2.new(0, 300, 1, 0)
container.AnchorPoint = Vector2.new(1, 1)
container.Position = UDim2.new(1, -10, 1, -20)
container.BackgroundTransparency = 1
container.Parent = gui

local activeNotifications = {}
local NOTIF_HEIGHT = 90
local NOTIF_GAP = 10
local INITIAL_Y_OFFSET = 40

local function shiftNotifications()
	for i, notif in ipairs(activeNotifications) do
		local targetY = -((i - 1) * (NOTIF_HEIGHT + NOTIF_GAP)) - INITIAL_Y_OFFSET
		local tween = TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, 0, 1, targetY)
		})
		tween:Play()
	end
end

return function(titleText, descText, duration, soundId)
	duration = duration or 5

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, NOTIF_HEIGHT)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.AnchorPoint = Vector2.new(1, 1)
	frame.Position = UDim2.new(1, 320, 1, 0)

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 12)

	local padding = Instance.new("UIPadding", frame)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)

	local title = Instance.new("TextLabel")
	title.Text = titleText
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = Color3.new(1, 1, 1)
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 20)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local desc = Instance.new("TextLabel")
	desc.Text = descText
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 14
	desc.TextColor3 = Color3.fromRGB(220, 220, 220)
	desc.BackgroundTransparency = 1
	desc.Position = UDim2.new(0, 0, 0, 24)
	desc.Size = UDim2.new(1, 0, 1, -28)
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextWrapped = true
	desc.TextYAlignment = Enum.TextYAlignment.Top
	desc.Parent = frame

	local barBack = Instance.new("Frame", frame)
	barBack.Size = UDim2.new(1, 0, 0, 4)
	barBack.Position = UDim2.new(0, 0, 1, -4)
	barBack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	barBack.BorderSizePixel = 0

	local bar = Instance.new("Frame", barBack)
	bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	bar.Size = UDim2.new(1, 0, 1, 0)
	bar.BorderSizePixel = 0

	local cornerBar = Instance.new("UICorner", bar)
	cornerBar.CornerRadius = UDim.new(1, 0)

	frame.Parent = container
	table.insert(activeNotifications, frame)

	if soundId then
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. tostring(soundId)
		sound.Volume = 1
		sound.Parent = frame
		sound:Play()
		game.Debris:AddItem(sound, 5)
	end

	local slideIn = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
		Position = UDim2.new(1, 0, 1, 0)
	})
	slideIn:Play()

	shiftNotifications()

	TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 1, 0)
	}):Play()

	task.delay(duration, function()
		local slideOut = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
			Position = frame.Position + UDim2.new(0, 320, 0, 0)
		})
		slideOut:Play()
		slideOut.Completed:Wait()

		for i, v in ipairs(activeNotifications) do
			if v == frame then
				table.remove(activeNotifications, i)
				break
			end
		end

		frame:Destroy()
		shiftNotifications()
	end)
end
