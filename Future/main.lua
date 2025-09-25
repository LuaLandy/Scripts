return (function()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local function GetAsset(path)
    path = tostring(path or "")
    if path:lower():find("arrow") then
        return "rbxassetid://8904422926"
    elseif path:lower():find("gear") then
        return "rbxassetid://8905804106"
    end
    return ""
end

local function PlayClickSound()
end

local function CreateSignalContainer()
    local listeners = {}
    local container = {}

    function container:Connect(fn)
        if type(fn) ~= "function" then return end
        table.insert(listeners, fn)
        return function()
            for i, v in ipairs(listeners) do
                if v == fn then
                    table.remove(listeners, i)
                    break
                end
            end
        end
    end

    function container:Fire(...)
        for _, fn in ipairs(listeners) do
            pcall(fn, ...)
        end
    end

    container.connect = container.Connect
    container.Fire = container.Fire

    return container
end

local function DragGui(Frame, Handle)
    if not Frame or not Handle then return end
    local Dragging, DragStart, StartPos

    local function Update(input)
        local Delta = input.Position - DragStart
        Frame.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
        )
    end

    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
            Update(input)
        end
    end)
end

local GuiLibrary = {
    WindowX = 8,
    TextSize = 14,
    Font = Enum.Font.SourceSans,
    ColorTheme = { H = 0.55, S = 0.6, V = 0.6 },
    Signals = {
        UpdateColor = CreateSignalContainer()
    },
    Objects = {},
    Connections = {},
    AllowNotifications = false,
    CreateToast = function(title, text) end
}

local ClickGui = Instance.new("ScreenGui")
ClickGui.Name = "Future"
ClickGui.ResetOnSpawn = false
ClickGui.Parent = CoreGui

function GuiLibrary:CreateWindow(Args)
    Args = Args or {}
    local WindowApi = { Expanded = true, ExpandedOptionsButton = nil }
    local WindowName = tostring(Args.Name or "Window")

    local Window = Instance.new("Frame")
    local WindowTopbar = Instance.new("TextButton")
    local WindowTitle = Instance.new("TextLabel")
    local ExpandButton = Instance.new("ImageButton")
    local ButtonContainer = Instance.new("Frame")
    local ButtonListLayout = Instance.new("UIListLayout")

    Window.Name = WindowName .. "Window"
    Window.Parent = ClickGui
    Window.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Window.BackgroundTransparency = 0.45
    Window.BorderSizePixel = 0
    Window.Position = UDim2.new(0, self.WindowX, 0, 25)
    self.WindowX = self.WindowX + (176 + 3)
    Window.Size = UDim2.new(0, 176, 0, 222)

    WindowTopbar.Name = "WindowTopbar"
    WindowTopbar.ZIndex = 2
    WindowTopbar.Parent = Window
    WindowTopbar.BackgroundColor3 = Color3.fromHSV(self.ColorTheme.H, self.ColorTheme.S, self.ColorTheme.V)
    WindowTopbar.BorderSizePixel = 0
    WindowTopbar.Position = UDim2.new(0, 0, 0, 0)
    WindowTopbar.Size = UDim2.new(1, 0, 0, 27)
    WindowTopbar.AutoButtonColor = false
    WindowTopbar.Text = ""
    WindowTopbar.TextColor3 = Color3.fromRGB(0, 0, 0)
    WindowTopbar.TextSize = self.TextSize

    WindowTitle.Name = "WindowTitle"
    WindowTitle.Parent = WindowTopbar
    WindowTitle.AnchorPoint = Vector2.new(0, 0.5)
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.BorderSizePixel = 0
    WindowTitle.Position = UDim2.new(0, 6, 0.5, 0)
    WindowTitle.Size = UDim2.new(1, -46, 0, 20)
    WindowTitle.Font = self.Font
    WindowTitle.Text = WindowName
    WindowTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    WindowTitle.TextTransparency = 0
    WindowTitle.TextSize = self.TextSize
    WindowTitle.TextWrapped = true
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    WindowTitle.ZIndex = 3
    WindowTitle.Visible = true

    ExpandButton.Name = "Expand"
    ExpandButton.Parent = WindowTopbar
    ExpandButton.AnchorPoint = Vector2.new(1, 0.5)
    ExpandButton.BackgroundTransparency = 1
    ExpandButton.Position = UDim2.new(1, -14, 0.5, 0)
    ExpandButton.Size = UDim2.new(0, 20, 0, 19)
    ExpandButton.ZIndex = 4
    ExpandButton.Image = GetAsset("Future/assets/arrow.png")
    ExpandButton.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ExpandButton.ScaleType = Enum.ScaleType.Fit

    ButtonContainer.Name = "ButtonContainer"
    ButtonContainer.Parent = Window
    ButtonContainer.AnchorPoint = Vector2.new(0.5, 0)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Position = UDim2.new(0.5, 0, 0, 36)
    ButtonContainer.Size = UDim2.new(0, 175, 0, 30)

    ButtonListLayout.Parent = ButtonContainer
    ButtonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ButtonListLayout.SortOrder = Enum.SortOrder.Name
    ButtonListLayout.Padding = UDim.new(0, 1)

    function WindowApi:Update()
        for _, v in next, GuiLibrary.Objects do
            if v.Type == "OptionsButton" and v.Window == Window.Name then
                if v.API and v.API.Update then
                    pcall(function() v.API.Update() end)
                end
            end
        end
        local targetHeight = ButtonListLayout.AbsoluteContentSize.Y + 37
        Window.Size = not WindowApi.Expanded and UDim2.new(0, 176, 0, 35) or UDim2.new(0, 176, 0, targetHeight)
    end

    function WindowApi:CreateOptionsButton(ArgsButton)
        ArgsButton = ArgsButton or {}
        local StartTime = tick()
        local ButtonApi = { Enabled = false, Expanded = false, Keybind = nil, IsRecording = false }

        local OptionsButton = Instance.new("TextButton")
        local NameLabel = Instance.new("TextLabel")
        local GearButton = Instance.new("ImageButton")
        local ChildrenContainer = Instance.new("Frame")
        local ChildrenListLayout = Instance.new("UIListLayout")
        local ModuleContainer = Instance.new("Frame")
        local ModuleListLayout = Instance.new("UIListLayout")

        OptionsButton.Name = tostring(ArgsButton.Name or "Option") .. "OptionsButton"
        OptionsButton.Parent = ButtonContainer
        OptionsButton.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ColorTheme.H, GuiLibrary.ColorTheme.S, GuiLibrary.ColorTheme.V)
        OptionsButton.BackgroundTransparency = 0.85
        OptionsButton.BorderSizePixel = 0
        OptionsButton.AnchorPoint = Vector2.new(0.5, 0)
        OptionsButton.Position = UDim2.new(0.5, 0, 0, 0)
        OptionsButton.Size = UDim2.new(0, 168, 0, 30)
        OptionsButton.AutoButtonColor = false
        OptionsButton.Text = ""
        OptionsButton.TextSize = GuiLibrary.TextSize

        GuiLibrary.Signals.UpdateColor:Connect(function(color)
            if color and color.H then
                OptionsButton.BackgroundColor3 = Color3.fromHSV(color.H, color.S, color.V)
            end
        end)

        NameLabel.Name = "Name"
        NameLabel.Parent = OptionsButton
        NameLabel.AnchorPoint = Vector2.new(0, 0.5)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Position = UDim2.new(0.035, 0, 0.5, 0)
        NameLabel.Size = UDim2.new(0, 114, 0, 23)
        NameLabel.Font = GuiLibrary.Font
        NameLabel.Text = ArgsButton.Name or "Option"
        NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLabel.TextSize = GuiLibrary.TextSize
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left

        GearButton.Name = "Gear"
        GearButton.Parent = OptionsButton
        GearButton.AnchorPoint = Vector2.new(0, 0.5)
        GearButton.BackgroundTransparency = 1
        GearButton.Position = UDim2.new(1, -23, 0.5, 0)
        GearButton.Size = UDim2.new(0, 19, 0, 19)
        GearButton.Image = GetAsset("Future/assets/gear.png")
        GearButton.ImageColor3 = Color3.fromRGB(181, 181, 181)

        ChildrenContainer.Name = tostring(ArgsButton.Name or "Option") .. "__ZZZZZ__ChildrenContainer"
        ChildrenContainer.Parent = ButtonContainer
        ChildrenContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        ChildrenContainer.BackgroundTransparency = 1
        ChildrenContainer.Position = UDim2.new(0.5, 0, 0, 48)
        ChildrenContainer.Size = UDim2.new(0, 175, 0, 30)
        ChildrenContainer.Visible = false

        ChildrenListLayout.Parent = ChildrenContainer
        ChildrenListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ChildrenListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ChildrenListLayout.Padding = UDim.new(0, 1)

        ModuleContainer.Name = "ModuleContainer"
        ModuleContainer.Parent = ChildrenContainer
        ModuleContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        ModuleContainer.BackgroundTransparency = 1
        ModuleContainer.Position = UDim2.new(0.5, 0, -0.1, 48)
        ModuleContainer.Size = UDim2.new(0, 175, 0, 90)

        ModuleListLayout.Parent = ModuleContainer
        ModuleListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ModuleListLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local KeybindButton, KeybindContainer, KeybindName
        if not ArgsButton.NoKeybind then
            KeybindButton = Instance.new("TextButton")
            KeybindContainer = Instance.new("Frame")
            local KBListLayout = Instance.new("UIListLayout")
            KeybindName = Instance.new("TextLabel")

            KeybindButton.Name = "Keybind"
            KeybindButton.Parent = ChildrenContainer
            KeybindButton.BackgroundTransparency = 1
            KeybindButton.BorderSizePixel = 0
            KeybindButton.Position = UDim2.new(0.0171428565, 0, 0, 0)
            KeybindButton.Size = UDim2.new(0, 168, 0, 30)
            KeybindButton.AutoButtonColor = true
            KeybindButton.Text = ""
            KeybindButton.TextSize = GuiLibrary.TextSize

            KeybindButton.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ColorTheme.H, GuiLibrary.ColorTheme.S, GuiLibrary.ColorTheme.V)
            GuiLibrary.Signals.UpdateColor:Connect(function(color)
                if color and color.H then
                    KeybindButton.BackgroundColor3 = Color3.fromHSV(color.H, color.S, color.V)
                end
            end)

            KeybindContainer.Name = "KeybindContainer"
            KeybindContainer.Parent = KeybindButton
            KeybindContainer.AnchorPoint = Vector2.new(0.5, 0.5)
            KeybindContainer.BackgroundTransparency = 1
            KeybindContainer.BorderSizePixel = 0
            KeybindContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            KeybindContainer.Size = UDim2.new(0, 158, 0, 30)

            KBListLayout.Parent = KeybindContainer
            KBListLayout.FillDirection = Enum.FillDirection.Horizontal
            KBListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            KBListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            KeybindName.Name = "Name"
            KeybindName.Parent = KeybindContainer
            KeybindName.AnchorPoint = Vector2.new(0, 0.5)
            KeybindName.BackgroundTransparency = 1
            KeybindName.Position = UDim2.new(0, 0, 0.5, 0)
            KeybindName.Size = UDim2.new(0, 76, 0, 23)
            KeybindName.Font = GuiLibrary.Font
            KeybindName.RichText = true
            KeybindName.Text = "Keybind <font color='rgb(170,170,170)'>NONE</font>"
            KeybindName.TextColor3 = Color3.fromRGB(255, 255, 255)
            KeybindName.TextSize = GuiLibrary.TextSize
            KeybindName.TextXAlignment = Enum.TextXAlignment.Left
        end

        function ButtonApi:Update()
            ModuleContainer.Size = not ButtonApi.Expanded and UDim2.new(0, 175, 0, 35) or UDim2.new(0, 175, 0, math.max(35, ModuleListLayout.AbsoluteContentSize.Y - 1))
            ChildrenContainer.Size = not ButtonApi.Expanded and UDim2.new(0, 175, 0, 35) or UDim2.new(0, 175, 0, ChildrenListLayout.AbsoluteContentSize.Y)
            WindowApi:Update()
        end

        local ConnA = ModuleListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pcall(function() ButtonApi:Update() end)
        end)
        local ConnB = ChildrenListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pcall(function() ButtonApi:Update() end)
        end)
        table.insert(GuiLibrary.Connections, ConnA)
        table.insert(GuiLibrary.Connections, ConnB)

        function ButtonApi:Expand(Boolean)
            local DoExpand = (Boolean ~= nil) and Boolean or not ButtonApi.Expanded
            ButtonApi.Expanded = DoExpand
            ChildrenContainer.Visible = DoExpand
            ButtonApi:Update()
            PlayClickSound()
        end

        function ButtonApi:Toggle(Boolean, StopClick, IsConfigLoad)
            local DoToggle = Boolean
            if Boolean == nil then DoToggle = not ButtonApi.Enabled end
            OptionsButton.BackgroundTransparency = DoToggle and 0.35 or 0.85
            ButtonApi.Enabled = DoToggle
            if ArgsButton.Function and type(ArgsButton.Function) == "function" then
                pcall(function() ArgsButton.Function(DoToggle) end)
            end
            if ArgsButton.Name == "ClickGui" and (Args.Name == "Other") then
            end
            if GuiLibrary.AllowNotifications and not IsConfigLoad then
                local Keyword = DoToggle and "Enabled" or "Disabled"
                if not table.find({}, OptionsButton.Name) then
                    GuiLibrary.CreateToast((ArgsButton.Name or "Module").." "..Keyword.."!", "The '"..(ArgsButton.Name or "Module").."' module was "..Keyword..".")
                end
            end
            if not StopClick then PlayClickSound() end
        end

        if (ArgsButton.Default ~= nil) and ButtonApi.Enabled ~= ArgsButton.Default and ArgsButton.Default then
            ButtonApi:Toggle(ArgsButton.Default, false, false)
        end

        function ButtonApi:SetKeybind(Key)
            if KeybindName then
                if Key == nil then
                    KeybindName.Text = "Keybind <font color='rgb(170,170,170)'>NONE</font>"
                else
                    KeybindName.Text = "Keybind <font color='rgb(170,170,170)'>"..tostring(Key).."</font>"
                end
            end
            ButtonApi.Keybind = Key or ArgsButton.DefaultKeybind
            if ArgsButton.OnKeybound then
                pcall(function() ArgsButton.OnKeybound(Key) end)
            end
        end

        if not ArgsButton.NoKeybind and KeybindButton and KeybindName then
            local ExclusionsList = { "Unknown" }
            local BindConn = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                if GameProcessed then return end
                if ButtonApi.IsRecording and Input.KeyCode and not table.find(ExclusionsList, Input.KeyCode.Name) and UserInputService:GetFocusedTextBox() == nil then
                    ButtonApi.IsRecording = false
                    KeybindButton.BackgroundTransparency = 1
                    if Input.KeyCode.Name == "Escape" then
                        ButtonApi:SetKeybind(ArgsButton.DefaultKeybind)
                    else
                        ButtonApi:SetKeybind(Input.KeyCode.Name)
                    end
                    return
                end
                if Input.KeyCode and Input.KeyCode.Name == ButtonApi.Keybind and UserInputService:GetFocusedTextBox() == nil then
                    ButtonApi:Toggle(nil, false, true)
                end
            end)
            table.insert(GuiLibrary.Connections, BindConn)

            KeybindButton.MouseButton1Click:Connect(function()
                PlayClickSound()
                if not ButtonApi.IsRecording then
                    ButtonApi.IsRecording = true
                    KeybindName.Text = "Press a Key..."
                    KeybindButton.BackgroundTransparency = 0
                else
                    ButtonApi.IsRecording = false
                    ButtonApi:SetKeybind(ButtonApi.Keybind)
                    KeybindButton.BackgroundTransparency = 1
                end
            end)
        end

        OptionsButton.MouseButton2Click:Connect(function() ButtonApi:Expand() end)
        OptionsButton.MouseButton1Click:Connect(function() ButtonApi:Toggle() end)
        GearButton.MouseButton1Click:Connect(function() ButtonApi:Expand() end)

        function ButtonApi:CreateToggle(ArgsToggle)
            ArgsToggle = ArgsToggle or {}
            local ToggleApi = { Enabled = false }
            local ToggleBtn = Instance.new("TextButton")
            local ToggleName = Instance.new("TextLabel")

            ToggleBtn.Name = "Toggle" .. tostring(ArgsToggle.Name or "Unnamed")
            ToggleBtn.Parent = ModuleContainer
            ToggleBtn.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ColorTheme.H, GuiLibrary.ColorTheme.S, GuiLibrary.ColorTheme.V)
            ToggleBtn.BorderSizePixel = 0
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Size = UDim2.new(0, 168, 0, 30)
            ToggleBtn.AutoButtonColor = false
            ToggleBtn.Text = ""
            ToggleBtn.TextSize = GuiLibrary.TextSize

            ToggleName.Name = "Name"
            ToggleName.Parent = ToggleBtn
            ToggleName.AnchorPoint = Vector2.new(0, 0.5)
            ToggleName.BackgroundTransparency = 1
            ToggleName.Position = UDim2.new(0.035, 0, 0.5, 0)
            ToggleName.Size = UDim2.new(0, 114, 0, 23)
            ToggleName.Font = GuiLibrary.Font
            ToggleName.Text = ArgsToggle.Name or "Toggle"
            ToggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleName.TextSize = GuiLibrary.TextSize
            ToggleName.TextXAlignment = Enum.TextXAlignment.Left

            function ToggleApi:Toggle(Boolean, SkipClick)
                local DoToggle = Boolean
                if Boolean == nil then DoToggle = not ToggleApi.Enabled end
                ToggleBtn.BackgroundTransparency = DoToggle and 0.35 or 1
                if ArgsToggle.Function and type(ArgsToggle.Function) == "function" then
                    pcall(function() ArgsToggle.Function(DoToggle) end)
                end
                ToggleApi.Enabled = DoToggle
                if not SkipClick then PlayClickSound() end
            end

            if (ArgsToggle.Default ~= nil) then
                ToggleApi:Toggle(ArgsToggle.Default, true)
            end

            ToggleBtn.MouseButton1Click:Connect(function() ToggleApi:Toggle() end)

            GuiLibrary.Objects[OptionsButton.Name .. tostring(ArgsToggle.Name or "Toggle") .. "Toggle"] = {
                API = ToggleApi, Instance = ToggleBtn, Type = "Toggle", OptionsButton = OptionsButton.Name, Window = Window.Name
            }

            return ToggleApi
        end

        function ButtonApi:CreateSelector(ArgsSelector)
            ArgsSelector = ArgsSelector or {}
            local SelectorApi = { Value = nil, List = {} }
            for _, v in ipairs(ArgsSelector.List or {}) do table.insert(SelectorApi.List, v) end
            SelectorApi.Value = ArgsSelector.Default or SelectorApi.List[1]

            local function StringTableFind(tbl, key)
                for i, v in ipairs(tbl) do
                    if tostring(v) == tostring(key) then return i end
                end
            end

            local function WrapIndex(index)
                if index > #SelectorApi.List then return 1 end
                if index < 1 then return #SelectorApi.List end
                return index
            end

            local SelectorBtn = Instance.new("TextButton")
            local SelectorContainer = Instance.new("Frame")
            local SelectorListLayout = Instance.new("UIListLayout")
            local SelectorName = Instance.new("TextLabel")

            SelectorBtn.Name = tostring(ArgsSelector.Name or "Selector") .. "Selector"
            SelectorBtn.Parent = ModuleContainer
            SelectorBtn.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ColorTheme.H, GuiLibrary.ColorTheme.S, GuiLibrary.ColorTheme.V)
            SelectorBtn.BackgroundTransparency = 0.35
            SelectorBtn.BorderSizePixel = 0
            SelectorBtn.Size = UDim2.new(0, 168, 0, 30)
            SelectorBtn.AutoButtonColor = true
            SelectorBtn.Text = ""
            SelectorBtn.TextSize = GuiLibrary.TextSize

            SelectorContainer.Name = "SelectorContainer"
            SelectorContainer.Parent = SelectorBtn
            SelectorContainer.AnchorPoint = Vector2.new(0.5, 0.5)
            SelectorContainer.BackgroundTransparency = 1
            SelectorContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            SelectorContainer.Size = UDim2.new(0, 158, 0, 30)

            SelectorListLayout.Parent = SelectorContainer
            SelectorListLayout.FillDirection = Enum.FillDirection.Horizontal
            SelectorListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SelectorListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            SelectorName.Name = "Name"
            SelectorName.Parent = SelectorContainer
            SelectorName.AnchorPoint = Vector2.new(0, 0.5)
            SelectorName.BackgroundTransparency = 1
            SelectorName.Position = UDim2.new(0, 0, 0.5, 0)
            SelectorName.Size = UDim2.new(0, 76, 0, 23)
            SelectorName.Font = GuiLibrary.Font
            SelectorName.RichText = true
            SelectorName.Text = tostring(ArgsSelector.Name or "Selector") .. " <font color='rgb(170,170,170)'>"..tostring(SelectorApi.Value).."</font>"
            SelectorName.TextColor3 = Color3.fromRGB(255, 255, 255)
            SelectorName.TextSize = GuiLibrary.TextSize
            SelectorName.TextXAlignment = Enum.TextXAlignment.Left

            function SelectorApi:Select(KeyOrIndex)
                local FoundIndex = nil
                if tonumber(KeyOrIndex) then
                    FoundIndex = tonumber(KeyOrIndex)
                else
                    FoundIndex = StringTableFind(SelectorApi.List, KeyOrIndex)
                end
                if FoundIndex then
                    FoundIndex = WrapIndex(FoundIndex)
                    SelectorApi.Value = SelectorApi.List[FoundIndex]
                    SelectorName.Text = tostring(ArgsSelector.Name or "Selector") .. " <font color='rgb(170,170,170)'>"..tostring(SelectorApi.Value).."</font>"
                    if ArgsSelector.Function and type(ArgsSelector.Function) == "function" then
                        pcall(function() ArgsSelector.Function(SelectorApi.Value) end)
                    end
                end
            end

            function SelectorApi:SelectNext()
                local CurIndex = table.find(SelectorApi.List, SelectorApi.Value)
                if CurIndex then
                    CurIndex = WrapIndex(CurIndex + 1)
                    SelectorApi:Select(CurIndex)
                end
                PlayClickSound()
            end

            function SelectorApi:SelectPrevious()
                local CurIndex = table.find(SelectorApi.List, SelectorApi.Value)
                if CurIndex then
                    CurIndex = WrapIndex(CurIndex - 1)
                    SelectorApi:Select(CurIndex)
                end
                PlayClickSound()
            end

            SelectorBtn.MouseButton1Click:Connect(function() SelectorApi:SelectNext() end)
            SelectorBtn.MouseButton2Click:Connect(function() SelectorApi:SelectPrevious() end)

            GuiLibrary.Objects[OptionsButton.Name .. tostring(ArgsSelector.Name or "Selector") .. "Selector"] = {
                API = SelectorApi, Instance = SelectorBtn, Type = "Selector", OptionsButton = OptionsButton.Name, Window = Window.Name
            }

            return SelectorApi
        end

        function ButtonApi:CreateSlider(ArgsSlider)
            ArgsSlider = ArgsSlider or {}
            local SliderApi = { Value = ArgsSlider.Default or (ArgsSlider.Min or 0) }
            local Min, Max = ArgsSlider.Min or 0, ArgsSlider.Max or 100
            local RoundVal = ArgsSlider.Round or 1

            local SliderBtn = Instance.new("TextButton")
            local SliderFill = Instance.new("Frame")
            local SliderContainer = Instance.new("Frame")
            local SliderListLayout = Instance.new("UIListLayout")
            local SliderName = Instance.new("TextLabel")
            local InputTextBtn = Instance.new("TextButton")
            local RealTextbox = Instance.new("TextBox")

            SliderBtn.Name = tostring(ArgsSlider.Name or "Slider") .. "Slider"
            SliderBtn.Parent = ModuleContainer
            SliderBtn.BackgroundTransparency = 1
            SliderBtn.BorderSizePixel = 0
            SliderBtn.Size = UDim2.new(0, 168, 0, 30)
            SliderBtn.AutoButtonColor = false
            SliderBtn.Text = ""
            SliderBtn.TextSize = GuiLibrary.TextSize

            SliderFill.Name = "SliderFill"
            SliderFill.Parent = SliderBtn
            SliderFill.AnchorPoint = Vector2.new(0, 0.5)
            SliderFill.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ColorTheme.H, GuiLibrary.ColorTheme.S, GuiLibrary.ColorTheme.V)
            SliderFill.BackgroundTransparency = 0.35
            SliderFill.BorderSizePixel = 0
            SliderFill.Position = UDim2.new(0, 0, 0.5, 0)
            SliderFill.Size = UDim2.new(0.5, 0, 1, 0)

            SliderContainer.Name = "SliderContainer"
            SliderContainer.Parent = SliderBtn
            SliderContainer.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderContainer.BackgroundTransparency = 1
            SliderContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            SliderContainer.Size = UDim2.new(0, 158, 0, 30)

            SliderListLayout.Parent = SliderContainer
            SliderListLayout.FillDirection = Enum.FillDirection.Horizontal
            SliderListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SliderListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            SliderName.Name = "Name"
            SliderName.Parent = SliderContainer
            SliderName.AnchorPoint = Vector2.new(0, 0.5)
            SliderName.BackgroundTransparency = 1
            SliderName.RichText = true
            SliderName.Position = UDim2.new(0, 0, 0.5, 0)
            SliderName.Size = UDim2.new(0, 61, 0, 23)
            SliderName.Font = GuiLibrary.Font
            SliderName.Text = tostring(ArgsSlider.Name or "Slider") .. "<font color='rgb(170,170,170)'>"..tostring(SliderApi.Value).."</font>"
            SliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderName.TextSize = GuiLibrary.TextSize
            SliderName.TextXAlignment = Enum.TextXAlignment.Left

            InputTextBtn.Name = "InputTextbox"
            InputTextBtn.Parent = ModuleContainer
            InputTextBtn.BackgroundTransparency = 1
            InputTextBtn.Size = UDim2.new(0, 168, 0, 30)
            InputTextBtn.AutoButtonColor = false
            InputTextBtn.Text = ""
            InputTextBtn.Visible = false

            RealTextbox.Name = "RealTextbox"
            RealTextbox.Parent = InputTextBtn
            RealTextbox.AnchorPoint = Vector2.new(0.5, 0.5)
            RealTextbox.BackgroundTransparency = 1
            RealTextbox.Position = UDim2.new(0.51767838, 0, 0.5, 0)
            RealTextbox.Size = UDim2.new(0, 162, 0, 30)
            RealTextbox.ClearTextOnFocus = false
            RealTextbox.Font = GuiLibrary.Font
            RealTextbox.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
            RealTextbox.PlaceholderText = "Input Value"
            RealTextbox.Text = ""
            RealTextbox.TextColor3 = Color3.fromRGB(255, 255, 255)
            RealTextbox.TextSize = GuiLibrary.TextSize
            RealTextbox.TextXAlignment = Enum.TextXAlignment.Left

            RealTextbox.FocusLost:Connect(function()
                local n = tonumber(RealTextbox.Text)
                if n then
                    SliderApi:Set(n, true)
                end
                RealTextbox.Text = ""
                InputTextBtn.Visible = false
                SliderBtn.Visible = true
            end)

            local function Slide(Input)
                if not SliderBtn.AbsoluteSize or SliderBtn.AbsoluteSize.X == 0 then return end
                local px = Input.Position.X - SliderBtn.AbsolutePosition.X
                local sizeX = math.clamp(px / SliderBtn.AbsoluteSize.X, 0, 1)
                SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                local value = math.floor(((((Max - Min) * sizeX) + Min) * (10 ^ RoundVal)) + 0.5) / (10 ^ RoundVal)
                SliderApi.Value = value
                SliderName.Text = tostring(ArgsSlider.Name or "Slider").." <font color='rgb(170,170,170)'>"..tostring(value).."</font>"
                if not ArgsSlider.OnInputEnded and ArgsSlider.Function then
                    pcall(function() ArgsSlider.Function(value) end)
                end
            end

            local Sliding = false
            SliderBtn.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        InputTextBtn.Visible = true
                        SliderBtn.Visible = false
                        RealTextbox:CaptureFocus()
                        return
                    end
                    Sliding = true
                    Slide(Input)
                    PlayClickSound()
                end
            end)

            SliderBtn.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if ArgsSlider.OnInputEnded and ArgsSlider.Function then
                        pcall(function() ArgsSlider.Function(SliderApi.Value) end)
                    end
                    Sliding = false
                end
            end)

            UserInputService.InputChanged:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement and Sliding then
                    Slide(Input)
                end
            end)

            function SliderApi:Set(Value, UseOverMax)
                local Value = not UseOverMax and math.floor((math.clamp(Value, Min, Max) * (10 ^ RoundVal)) + 0.5) / (10 ^ RoundVal) or math.clamp(Value, (ArgsSlider.RealMin or -math.huge), (ArgsSlider.RealMax or math.huge))
                local SizeValue = math.floor((math.clamp(Value, Min, Max) * (10 ^ RoundVal)) + 0.5) / (10 ^ RoundVal)
                SliderApi.Value = Value
                SliderFill.Size = UDim2.new((SizeValue - Min) / math.max((Max - Min), 1), 0, 1, 0)
                SliderName.Text = tostring(ArgsSlider.Name or "Slider").." <font color='rgb(170,170,170)'>"..tostring(Value).."</font>"
                if ArgsSlider.Function then pcall(function() ArgsSlider.Function(Value) end) end
            end

            SliderApi:Set(SliderApi.Value)

            GuiLibrary.Objects[OptionsButton.Name .. tostring(ArgsSlider.Name or "Slider") .. "Slider"] = {
                API = SliderApi, Instance = SliderBtn, Type = "Slider", OptionsButton = OptionsButton.Name, Window = Window.Name
            }

            return SliderApi
        end

        function ButtonApi:CreateTextbox(ArgsTextbox)
            ArgsTextbox = ArgsTextbox or {}
            local TextboxApi = { Value = "" }

            local TextboxBtn = Instance.new("TextButton")
            local RealTextbox = Instance.new("TextBox")

            TextboxBtn.Name = tostring(ArgsTextbox.Name or "Textbox") .. "Textbox"
            TextboxBtn.Parent = ModuleContainer
            TextboxBtn.BackgroundTransparency = 1
            TextboxBtn.BorderSizePixel = 0
            TextboxBtn.Size = UDim2.new(0, 168, 0, 30)
            TextboxBtn.AutoButtonColor = false
            TextboxBtn.Text = ""
            TextboxBtn.TextSize = GuiLibrary.TextSize

            RealTextbox.Name = "RealTextbox"
            RealTextbox.Parent = TextboxBtn
            RealTextbox.AnchorPoint = Vector2.new(0.5, 0.5)
            RealTextbox.BackgroundTransparency = 1
            RealTextbox.Position = UDim2.new(0.51767838, 0, 0.5, 0)
            RealTextbox.Size = UDim2.new(0, 162, 0, 30)
            RealTextbox.ClearTextOnFocus = false
            RealTextbox.Font = GuiLibrary.Font
            RealTextbox.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
            RealTextbox.PlaceholderText = ArgsTextbox.Name or "Input"
            RealTextbox.Text = ""
            RealTextbox.TextColor3 = Color3.fromRGB(255, 255, 255)
            RealTextbox.TextSize = GuiLibrary.TextSize
            RealTextbox.TextXAlignment = Enum.TextXAlignment.Left

            function TextboxApi:Set(Value, SkipFunction)
                local Value = tostring(Value)
                TextboxApi.Value = Value
                RealTextbox.Text = Value
                if not SkipFunction and ArgsTextbox.Function then
                    pcall(function() ArgsTextbox.Function(Value) end)
                end
            end

            TextboxApi:Set(ArgsTextbox.Default or "", true)

            RealTextbox.FocusLost:Connect(function()
                TextboxApi:Set(RealTextbox.Text)
            end)

            GuiLibrary.Objects[OptionsButton.Name .. tostring(ArgsTextbox.Name or "Textbox") .. "Textbox"] = {
                API = TextboxApi, Instance = TextboxBtn, Type = "Textbox", OptionsButton = OptionsButton.Name, Window = Window.Name
            }

            return TextboxApi
        end

        GuiLibrary.Objects[tostring(ArgsButton.Name or "Option") .. "OptionsButton"] = {
            Name = ArgsButton.Name, API = ButtonApi, Instance = OptionsButton, Type = "OptionsButton", Window = Window.Name,
            DisableOnLeave = ArgsButton.DisableOnLeave, ArrayText = ArgsButton.ArrayText
        }

        ButtonApi:Update()

        return ButtonApi
    end

    function WindowApi:Expand(Boolean)
        local DoExpand = (Boolean ~= nil) and Boolean or not WindowApi.Expanded
        WindowApi.Expanded = DoExpand
        ButtonContainer.Visible = DoExpand
        WindowApi:Update()
        PlayClickSound()
    end

    ExpandButton.MouseButton1Click:Connect(function() WindowApi:Expand() end)
    WindowTopbar.MouseButton2Click:Connect(function() WindowApi:Expand() end)
    DragGui(Window, WindowTopbar)

    local Conn = ButtonListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pcall(function() WindowApi:Update() end)
    end)
    table.insert(GuiLibrary.Connections, Conn)

    GuiLibrary.Objects[WindowName .. "Window"] = { API = WindowApi, Instance = Window, Type = "Window" }

    WindowApi:Update()
    return WindowApi
end

function GuiLibrary:UpdateWindows()
    for _, v in next, self.Objects do
        if v.Type == "Window" and v.API and v.API.Update then
            pcall(function() v.API.Update() end)
        end
    end
end

if getgenv then
    getgenv().GuiLibraryExample = GuiLibrary
else
    _G.GuiLibraryExample = GuiLibrary
end

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ClickGui = CoreGui:WaitForChild("Future")

local AllVisible = true

local function ToggleAllFrames()
	AllVisible = not AllVisible
	for _, obj in pairs(ClickGui:GetChildren()) do
		if obj:IsA("Frame") and obj ~= ToggleButton then
			obj.Visible = AllVisible
		end
	end
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleAllButton"
ToggleButton.Parent = ClickGui
ToggleButton.AnchorPoint = Vector2.new(0, 0)
ToggleButton.Position = UDim2.new(0, 8, 0, 5)
ToggleButton.Size = UDim2.new(0, 100, 0, 24)
ToggleButton.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ColorTheme.H, GuiLibrary.ColorTheme.S, GuiLibrary.ColorTheme.V)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "Toggle"
ToggleButton.Font = GuiLibrary.Font
ToggleButton.TextSize = GuiLibrary.TextSize
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.ZIndex = 5

ToggleButton.Activated:Connect(ToggleAllFrames)

local function DragGui(guiObject)
	local dragging = false
	local dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		guiObject.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				update(input)
			end
		end
	end)
end

DragGui(ToggleButton)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightShift and UserInputService:GetFocusedTextBox() == nil then
		ToggleAllFrames()
	end
end)

return GuiLibrary
end)()
