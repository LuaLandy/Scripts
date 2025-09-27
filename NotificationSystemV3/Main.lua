return (function()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer
local Gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local NotificationsList = {}
local Spacing = 5
local Height = 30
local StartX, StartY = 614, 284
local MinWidth = 180
local MaxWidth = 1000000
local OffscreenPadding = 50

local function GetScreenWidth()
	return (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X) or 1280
end

local function GetTextWidth(Text, Font, Size)
	local Bounds = TextService:GetTextSize(tostring(Text), Size, Font, Vector2.new(10000, 10000))
	return math.clamp(math.ceil(Bounds.X) + 24, MinWidth, MaxWidth)
end

local function Reposition(Duration)
	Duration = Duration or 0.2
	local ScreenW = GetScreenWidth()
	local AnchorRight = math.min(StartX + MinWidth, ScreenW - 10)
	for i, Entry in ipairs(NotificationsList) do
		local W = math.clamp(Entry.Width, 40, ScreenW - 20)
		local TX = math.max(10, AnchorRight - W)
		local TY = StartY - (Height + Spacing) * (i - 1)
		TweenService:Create(Entry.Frame, TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, TX, 0, TY)}):Play()
		Entry.TargetX = TX
		Entry.TargetY = TY
	end
end

local function CreateNotif(Message, Duration, SoundId, Rainbow, BarColor)
	Duration = Duration or 3
	local ScreenW = GetScreenWidth()
	local TextWidth = GetTextWidth(Message, Enum.Font.SourceSansBold, 18)
	if TextWidth > ScreenW - 20 then TextWidth = math.max(100, ScreenW - 20) end

	local Frame = Instance.new("Frame", Gui)
	Frame.Size = UDim2.new(0, TextWidth, 0, Height)
	Frame.Position = UDim2.new(0, ScreenW + OffscreenPadding, 0, StartY)
	Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BackgroundTransparency = 0.5
	Frame.BorderSizePixel = 0

	local TextLabel = Instance.new("TextLabel", Frame)
	TextLabel.Size = UDim2.new(1, -8, 1, -6)
	TextLabel.Position = UDim2.new(0, 4, 0, 2)
	TextLabel.BackgroundTransparency = 1
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextWrapped = true
	TextLabel.TextScaled = false
	TextLabel.TextSize = 18
	TextLabel.Font = Enum.Font.SourceSansBold
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.TextYAlignment = Enum.TextYAlignment.Center
	TextLabel.Text = tostring(Message)

	local Bar = Instance.new("Frame", Frame)
	Bar.Size = UDim2.new(1, 0, 0, 3)
	Bar.Position = UDim2.new(0, 0, 1, -3)
	Bar.BorderSizePixel = 0

	if Rainbow then
		local startTime = tick()
		task.spawn(function()
			while Bar and Bar.Parent do
				local hue = ((tick() - startTime) * 0.1) % 1
				Bar.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
				task.wait(0.05)
			end
		end)
	else
		Bar.BackgroundColor3 = BarColor or Color3.fromRGB(0, 128, 255)
	end

	if SoundId then
		local Sound = Instance.new("Sound", Frame)
		Sound.SoundId = "rbxassetid://"..tostring(SoundId)
		Sound.Volume = 1
		Sound:Play()
	end

	local Entry = {Frame = Frame, Width = TextWidth}
	table.insert(NotificationsList, Entry)
	Reposition(0.35)

	local BarTween = TweenService:Create(Bar, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)})
	BarTween:Play()
	BarTween.Completed:Wait()

	local OutX = ScreenW + OffscreenPadding
	local SlideOut = TweenService:Create(Frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0, OutX, 0, Frame.Position.Y.Offset)})
	SlideOut:Play()
	SlideOut.Completed:Wait()

	for i, E in ipairs(NotificationsList) do
		if E == Entry then
			table.remove(NotificationsList, i)
			break
		end
	end
	Frame:Destroy()
	Reposition(0.18)
end

local function Notification(Message, Duration, SoundId, Rainbow, BarColor)
	task.spawn(CreateNotif, tostring(Message), Duration or 5, SoundId, Rainbow, BarColor)
end

return {
	Notification = Notification
}
end)()
