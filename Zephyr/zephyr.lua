return (function()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

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
        for _, fn in ipairs(listeners) do pcall(fn, ...) end
    end
    container.connect = container.Connect
    container.Fire = container.Fire
    return container
end

local function DragGui(Frame, Handle)
    if not Frame or not Handle then return end
    local dragging, dragStart, startPos
    local function Update(input)
        if not input or not input.Position or not startPos or not Frame then return end
        local success, delta = pcall(function() return input.Position - dragStart end)
        if not success or not delta then return end
        Frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    Handle.InputBegan:Connect(function(input)
        if not input then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Handle.InputChanged:Connect(function(input)
        if not input then return end
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            Update(input)
        end
    end)
end

local GuiLibrary = {
    WindowX = 8,
    TextSize = 14,
    Font = Enum.Font.SourceSans,
    Signals = { UpdateColor = CreateSignalContainer() },
    Objects = {},
    Connections = {}
}

local function safeConnect(eventLike, callback)
    if not eventLike or type(eventLike.Connect) ~= "function" then return end
    local ok, conn = pcall(function()
        return eventLike:Connect(function(...)
            pcall(callback, ...)
        end)
    end)
    if ok and conn then
        table.insert(GuiLibrary.Connections, conn)
        return conn
    end
    return nil
end

local ClickGui = Instance.new("ScreenGui")
ClickGui.Name = "Zephyr"
ClickGui.ResetOnSpawn = false
ClickGui.Parent = CoreGui

safeConnect(ClickGui.AncestryChanged, function()
    if not ClickGui:IsDescendantOf(game) then
        for _, conn in ipairs(GuiLibrary.Connections) do
            pcall(function() if conn and conn.Disconnect then conn:Disconnect() end end)
        end
        GuiLibrary.Connections = {}
    end
end)

function GuiLibrary:CreateWindow(Args)
    Args = Args or {}
    local WindowApi = { Expanded = true }
    local WindowName = tostring(Args.Name or "Window")
    local layoutIndex = 1

    local Window = Instance.new("Frame")
    local WindowTopbar = Instance.new("TextButton")
    local WindowTitle = Instance.new("TextLabel")
    local ExpandButton = Instance.new("TextButton")
    local ButtonContainer = Instance.new("ScrollingFrame")
    local ButtonListLayout = Instance.new("UIListLayout")

    Window.Name = WindowName .. "Window"
    Window.Parent = ClickGui
    Window.BackgroundColor3 = Color3.fromRGB(8,8,8)
    Window.BorderSizePixel = 0
    Window.Position = UDim2.new(0, self.WindowX, 0, 25)
    self.WindowX = self.WindowX + (176 + 3)
    Window.Size = UDim2.new(0, 176, 0, 222)
    Window.ClipsDescendants = true

    WindowTopbar.Name = "WindowTopbar"
    WindowTopbar.Parent = Window
    WindowTopbar.BackgroundColor3 = Color3.fromRGB(16,16,16)
    WindowTopbar.BorderSizePixel = 0
    WindowTopbar.Position = UDim2.new(0, 0, 0, 0)
    WindowTopbar.Size = UDim2.new(1, 0, 0, 27)
    WindowTopbar.AutoButtonColor = false
    WindowTopbar.Text = ""
    WindowTopbar.TextSize = self.TextSize

    WindowTitle.Name = "WindowTitle"
    WindowTitle.Parent = WindowTopbar
    WindowTitle.AnchorPoint = Vector2.new(0, 0.5)
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.Position = UDim2.new(0, 6, 0.5, 0)
    WindowTitle.Size = UDim2.new(1, -46, 0, 20)
    WindowTitle.Font = self.Font
    WindowTitle.Text = WindowName
    WindowTitle.TextColor3 = Color3.fromRGB(230,230,230)
    WindowTitle.TextSize = self.TextSize
    WindowTitle.TextWrapped = true
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left

    ExpandButton.Name = "Expand"
    ExpandButton.Parent = WindowTopbar
    ExpandButton.AnchorPoint = Vector2.new(1, 0.5)
    ExpandButton.BackgroundTransparency = 1
    ExpandButton.Position = UDim2.new(1, -14, 0.5, 0)
    ExpandButton.Size = UDim2.new(0, 20, 0, 19)
    ExpandButton.Text = (WindowApi.Expanded and "-") or "+"
    ExpandButton.Font = GuiLibrary.Font
    ExpandButton.TextSize = 18
    ExpandButton.TextColor3 = Color3.fromRGB(230,230,230)
    ExpandButton.AutoButtonColor = false

    ButtonContainer.Name = "ButtonContainer"
    ButtonContainer.Parent = Window
    ButtonContainer.AnchorPoint = Vector2.new(0.5, 0)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Position = UDim2.new(0.5, 0, 0, 36)
    ButtonContainer.Size = UDim2.new(0, 175, 0, 180)
    ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ButtonContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ButtonContainer.ScrollBarThickness = 6
    ButtonContainer.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    ButtonContainer.BorderSizePixel = 0

    ButtonListLayout.Parent = ButtonContainer
    ButtonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ButtonListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ButtonListLayout.Padding = UDim.new(0, 1)

    function WindowApi:Update()
        for _, v in next, GuiLibrary.Objects do
            if v.Type == "OptionsButton" and v.Window == Window.Name and v.API and v.API.Update then
                pcall(function() v.API:Update() end)
            end
        end
        local contentSize = 0
        if ButtonListLayout and ButtonListLayout.AbsoluteContentSize then
            local ok, size = pcall(function() return ButtonListLayout.AbsoluteContentSize.Y end)
            if ok and size then contentSize = size end
        end
        local maxH = 220
        local targetHeight = (not WindowApi.Expanded) and 35 or math.clamp(contentSize + 37, 35, maxH)
        Window.Size = UDim2.new(0, 176, 0, targetHeight)
        ButtonContainer.Size = UDim2.new(0, 175, 0, math.max(30, targetHeight - 37))
        if ExpandButton and ExpandButton:IsA("TextButton") then ExpandButton.Text = (WindowApi.Expanded and "-") or "+" end
    end

    function WindowApi:CreateOptionsButton(ArgsButton)
        ArgsButton = ArgsButton or {}
        local ButtonApi = { Enabled = false, Expanded = false, Keybind = nil, IsRecording = false }

        local OptionsButton = Instance.new("TextButton")
        local NameLabel = Instance.new("TextLabel")
        local GearButton = Instance.new("TextButton")
        local ChildrenContainer = Instance.new("Frame")
        local ChildrenListLayout = Instance.new("UIListLayout")
        local ModuleContainer = Instance.new("Frame")
        local ModuleListLayout = Instance.new("UIListLayout")

        local myOrder = layoutIndex
        OptionsButton.LayoutOrder = myOrder
        ChildrenContainer.LayoutOrder = myOrder + 1
        layoutIndex = layoutIndex + 2

        OptionsButton.Name = tostring(ArgsButton.Name or "Option") .. "OptionsButton"
        OptionsButton.Parent = ButtonContainer
        OptionsButton.BackgroundColor3 = Color3.fromRGB(12,12,12)
        OptionsButton.BackgroundTransparency = 0.85
        OptionsButton.BorderSizePixel = 0
        OptionsButton.AnchorPoint = Vector2.new(0.5, 0)
        OptionsButton.Position = UDim2.new(0.5, 0, 0, 0)
        OptionsButton.Size = UDim2.new(0, 168, 0, 30)
        OptionsButton.AutoButtonColor = false
        OptionsButton.Text = ""
        OptionsButton.TextSize = GuiLibrary.TextSize

        NameLabel.Name = "Name"
        NameLabel.Parent = OptionsButton
        NameLabel.AnchorPoint = Vector2.new(0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Position = UDim2.new(0, 6, 0, 0)
        NameLabel.Size = UDim2.new(1, -46, 1, 0)
        NameLabel.Font = GuiLibrary.Font
        NameLabel.Text = ArgsButton.Name or "Option"
        NameLabel.TextColor3 = Color3.fromRGB(230,230,230)
        NameLabel.TextSize = GuiLibrary.TextSize
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.TextWrapped = true

        GearButton.Name = "Gear"
        GearButton.Parent = OptionsButton
        GearButton.AnchorPoint = Vector2.new(0, 0.5)
        GearButton.BackgroundTransparency = 1
        GearButton.Position = UDim2.new(1, -23, 0.5, 0)
        GearButton.Size = UDim2.new(0, 19, 0, 19)
        GearButton.Text = "+"
        GearButton.Font = GuiLibrary.Font
        GearButton.TextSize = 18
        GearButton.TextColor3 = Color3.fromRGB(180,180,180)
        GearButton.AutoButtonColor = false

        local ButtonId = OptionsButton.Name .. "_" .. tostring(math.random(1,1000000000))

        ChildrenContainer.Name = ButtonId .. "__ChildrenContainer"
        ChildrenContainer.Parent = ButtonContainer
        ChildrenContainer.AnchorPoint = Vector2.new(0, 0)
        ChildrenContainer.BackgroundTransparency = 1
        ChildrenContainer.Position = UDim2.new(0, 0, 0, 0)
        ChildrenContainer.Size = UDim2.new(0, 175, 0, 0)
        ChildrenContainer.Visible = false
        ChildrenContainer.ClipsDescendants = true

        ChildrenListLayout.Parent = ChildrenContainer
        ChildrenListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ChildrenListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ChildrenListLayout.Padding = UDim.new(0, 1)

        ModuleContainer.Name = ButtonId .. "__ModuleContainer"
        ModuleContainer.Parent = ChildrenContainer
        ModuleContainer.AnchorPoint = Vector2.new(0, 0)
        ModuleContainer.BackgroundTransparency = 1
        ModuleContainer.Position = UDim2.new(0, 0, 0, 0)
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
            KeybindButton.Position = UDim2.new(0, 0, 0, 0)
            KeybindButton.Size = UDim2.new(0, 168, 0, 30)
            KeybindButton.AutoButtonColor = true
            KeybindButton.Text = ""
            KeybindButton.TextSize = GuiLibrary.TextSize
            KeybindButton.BackgroundColor3 = Color3.fromRGB(12,12,12)

            KeybindContainer.Name = "KeybindContainer"
            KeybindContainer.Parent = KeybindButton
            KeybindContainer.AnchorPoint = Vector2.new(0, 0)
            KeybindContainer.BackgroundTransparency = 1
            KeybindContainer.BorderSizePixel = 0
            KeybindContainer.Position = UDim2.new(0, 6, 0, 0)
            KeybindContainer.Size = UDim2.new(1, -12, 1, 0)

            KBListLayout.Parent = KeybindContainer
            KBListLayout.FillDirection = Enum.FillDirection.Horizontal
            KBListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            KBListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            KeybindName.Name = "Name"
            KeybindName.Parent = KeybindContainer
            KeybindName.AnchorPoint = Vector2.new(0, 0)
            KeybindName.BackgroundTransparency = 1
            KeybindName.Position = UDim2.new(0, 0, 0, 0)
            KeybindName.Size = UDim2.new(1, 0, 1, 0)
            KeybindName.Font = GuiLibrary.Font
            KeybindName.RichText = true
            KeybindName.Text = "Keybind <font color='rgb(170,170,170)'>NONE</font>"
            KeybindName.TextColor3 = Color3.fromRGB(230,230,230)
            KeybindName.TextSize = GuiLibrary.TextSize
            KeybindName.TextXAlignment = Enum.TextXAlignment.Left
            KeybindName.TextWrapped = true
        end

        function ButtonApi:Update()
            local moduleSize = 35
            local childrenSize = 0
            if ModuleListLayout and ModuleListLayout.AbsoluteContentSize then
                pcall(function()
                    moduleSize = math.max(35, ModuleListLayout.AbsoluteContentSize.Y)
                end)
            end
            if ChildrenListLayout and ChildrenListLayout.AbsoluteContentSize then
                pcall(function()
                    childrenSize = ChildrenListLayout.AbsoluteContentSize.Y
                end)
            end
            ModuleContainer.Size = not ButtonApi.Expanded and UDim2.new(0, 175, 0, 35) or UDim2.new(0, 175, 0, moduleSize)
            ChildrenContainer.Size = not ButtonApi.Expanded and UDim2.new(0, 175, 0, 0) or UDim2.new(0, 175, 0, childrenSize)
            WindowApi:Update()
        end

        safeConnect(ModuleListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() pcall(function() ButtonApi:Update() end) end)
        safeConnect(ChildrenListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() pcall(function() ButtonApi:Update() end) end)

        function ButtonApi:Expand(Boolean)
            local DoExpand = (Boolean ~= nil) and Boolean or not ButtonApi.Expanded
            ButtonApi.Expanded = DoExpand
            ChildrenContainer.Visible = DoExpand
            ButtonApi:Update()
            if GearButton and GearButton:IsA("TextButton") then GearButton.Text = (DoExpand and "-") or "+" end
        end

        function ButtonApi:Toggle(Boolean)
            local DoToggle = Boolean
            if Boolean == nil then DoToggle = not ButtonApi.Enabled end
            ButtonApi.Enabled = DoToggle
            if DoToggle then
                OptionsButton.BackgroundTransparency = 0
                OptionsButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
                NameLabel.TextColor3 = Color3.fromRGB(0,0,0)
            else
                OptionsButton.BackgroundTransparency = 0.85
                OptionsButton.BackgroundColor3 = Color3.fromRGB(12,12,12)
                NameLabel.TextColor3 = Color3.fromRGB(230,230,230)
            end
            if ArgsButton.Function and type(ArgsButton.Function) == "function" then pcall(function() ArgsButton.Function(DoToggle) end) end
        end

        if (ArgsButton.Default ~= nil) and ButtonApi.Enabled ~= ArgsButton.Default and ArgsButton.Default then
            ButtonApi:Toggle(ArgsButton.Default)
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
            if ArgsButton.OnKeybound then pcall(function() ArgsButton.OnKeybound(Key) end) end
        end

        if not ArgsButton.NoKeybind and KeybindButton and KeybindName then
            local ExclusionsList = { "Unknown" }
            safeConnect(UserInputService.InputBegan, function(Input, GameProcessed)
                if GameProcessed then return end
                if ButtonApi.IsRecording and Input and Input.KeyCode and not table.find(ExclusionsList, tostring(Input.KeyCode.Name)) and UserInputService:GetFocusedTextBox() == nil then
                    ButtonApi.IsRecording = false
                    KeybindButton.BackgroundTransparency = 1
                    if tostring(Input.KeyCode.Name) == "Escape" then
                        ButtonApi:SetKeybind(ArgsButton.DefaultKeybind)
                    else
                        ButtonApi:SetKeybind(tostring(Input.KeyCode.Name))
                    end
                    return
                end
                if Input and Input.KeyCode and tostring(Input.KeyCode.Name) == tostring(ButtonApi.Keybind) and UserInputService:GetFocusedTextBox() == nil then
                    pcall(function() ButtonApi:Toggle(nil) end)
                end
            end)

            KeybindButton.MouseButton1Click:Connect(function()
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

        OptionsButton.MouseButton2Click:Connect(function() pcall(function() ButtonApi:Expand() end) end)
        OptionsButton.MouseButton1Click:Connect(function() pcall(function() ButtonApi:Toggle() end) end)
        GearButton.MouseButton1Click:Connect(function() pcall(function() ButtonApi:Expand() end) end)

        function ButtonApi:CreateToggle(ArgsToggle)
            ArgsToggle = ArgsToggle or {}
            local ToggleApi = { Enabled = false }
            local ToggleBtn = Instance.new("TextButton")
            local ToggleName = Instance.new("TextLabel")

            ToggleBtn.Name = "Toggle" .. tostring(ArgsToggle.Name or "Unnamed")
            ToggleBtn.Parent = ModuleContainer
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(12,12,12)
            ToggleBtn.BorderSizePixel = 0
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Size = UDim2.new(0, 168, 0, 30)
            ToggleBtn.AutoButtonColor = false
            ToggleBtn.Text = ""
            ToggleBtn.TextSize = GuiLibrary.TextSize

            ToggleName.Name = "Name"
            ToggleName.Parent = ToggleBtn
            ToggleName.AnchorPoint = Vector2.new(0, 0)
            ToggleName.BackgroundTransparency = 1
            ToggleName.Position = UDim2.new(0, 6, 0, 0)
            ToggleName.Size = UDim2.new(1, -40, 1, 0)
            ToggleName.Font = GuiLibrary.Font
            ToggleName.Text = ArgsToggle.Name or "Toggle"
            ToggleName.TextColor3 = Color3.fromRGB(230,230,230)
            ToggleName.TextSize = GuiLibrary.TextSize
            ToggleName.TextXAlignment = Enum.TextXAlignment.Left
            ToggleName.TextWrapped = true

            function ToggleApi:Toggle(Boolean)
                local DoToggle = Boolean
                if Boolean == nil then DoToggle = not ToggleApi.Enabled end
                ToggleApi.Enabled = DoToggle
                if DoToggle then
                    ToggleBtn.BackgroundTransparency = 0
                    ToggleBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
                    ToggleName.TextColor3 = Color3.fromRGB(0,0,0)
                else
                    ToggleBtn.BackgroundTransparency = 1
                    ToggleBtn.BackgroundColor3 = Color3.fromRGB(12,12,12)
                    ToggleName.TextColor3 = Color3.fromRGB(230,230,230)
                end
                if ArgsToggle.Function and type(ArgsToggle.Function) == "function" then pcall(function() ArgsToggle.Function(DoToggle) end) end
            end

            if (ArgsToggle.Default ~= nil) then ToggleApi:Toggle(ArgsToggle.Default) end
            ToggleBtn.MouseButton1Click:Connect(function() pcall(function() ToggleApi:Toggle() end) end)

            GuiLibrary.Objects[ButtonId .. tostring(ArgsToggle.Name or "Toggle") .. "Toggle"] = {
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
                for i, v in ipairs(tbl) do if tostring(v) == tostring(key) then return i end end
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
            SelectorBtn.BackgroundColor3 = Color3.fromRGB(12,12,12)
            SelectorBtn.BackgroundTransparency = 0.35
            SelectorBtn.BorderSizePixel = 0
            SelectorBtn.Size = UDim2.new(0, 168, 0, 30)
            SelectorBtn.AutoButtonColor = true
            SelectorBtn.Text = ""
            SelectorBtn.TextSize = GuiLibrary.TextSize

            SelectorContainer.Name = "SelectorContainer"
            SelectorContainer.Parent = SelectorBtn
            SelectorContainer.AnchorPoint = Vector2.new(0, 0)
            SelectorContainer.BackgroundTransparency = 1
            SelectorContainer.Position = UDim2.new(0, 6, 0, 0)
            SelectorContainer.Size = UDim2.new(1, -12, 1, 0)

            SelectorListLayout.Parent = SelectorContainer
            SelectorListLayout.FillDirection = Enum.FillDirection.Horizontal
            SelectorListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SelectorListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            SelectorName.Name = "Name"
            SelectorName.Parent = SelectorContainer
            SelectorName.AnchorPoint = Vector2.new(0, 0)
            SelectorName.BackgroundTransparency = 1
            SelectorName.Position = UDim2.new(0, 0, 0, 0)
            SelectorName.Size = UDim2.new(1, 0, 1, 0)
            SelectorName.Font = GuiLibrary.Font
            SelectorName.RichText = true
            SelectorName.Text = tostring(ArgsSelector.Name or "Selector") .. " <font color='rgb(170,170,170)'>"..tostring(SelectorApi.Value or "").."</font>"
            SelectorName.TextColor3 = Color3.fromRGB(230,230,230)
            SelectorName.TextSize = GuiLibrary.TextSize
            SelectorName.TextXAlignment = Enum.TextXAlignment.Left
            SelectorName.TextWrapped = true

            function SelectorApi:Select(KeyOrIndex)
                local FoundIndex = nil
                if tonumber(KeyOrIndex) then FoundIndex = tonumber(KeyOrIndex) else FoundIndex = StringTableFind(SelectorApi.List, KeyOrIndex) end
                if FoundIndex then
                    FoundIndex = WrapIndex(FoundIndex)
                    SelectorApi.Value = SelectorApi.List[FoundIndex]
                    SelectorName.Text = tostring(ArgsSelector.Name or "Selector") .. " <font color='rgb(170,170,170)'>"..tostring(SelectorApi.Value or "").."</font>"
                    if ArgsSelector.Function and type(ArgsSelector.Function) == "function" then pcall(function() ArgsSelector.Function(SelectorApi.Value) end) end
                end
            end

            function SelectorApi:SelectNext()
                local CurIndex = table.find(SelectorApi.List, SelectorApi.Value)
                if CurIndex then
                    CurIndex = WrapIndex(CurIndex + 1)
                    SelectorApi:Select(CurIndex)
                end
            end

            function SelectorApi:SelectPrevious()
                local CurIndex = table.find(SelectorApi.List, SelectorApi.Value)
                if CurIndex then
                    CurIndex = WrapIndex(CurIndex - 1)
                    SelectorApi:Select(CurIndex)
                end
            end

            SelectorBtn.MouseButton1Click:Connect(function() pcall(function() SelectorApi:SelectNext() end) end)
            SelectorBtn.MouseButton2Click:Connect(function() pcall(function() SelectorApi:SelectPrevious() end) end)

            GuiLibrary.Objects[ButtonId .. tostring(ArgsSelector.Name or "Selector") .. "Selector"] = {
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
            SliderFill.BackgroundColor3 = Color3.fromRGB(170,170,170)
            SliderFill.BackgroundTransparency = 0.15
            SliderFill.BorderSizePixel = 0
            SliderFill.Position = UDim2.new(0, 0, 0.5, 0)
            SliderFill.Size = UDim2.new(0.5, 0, 1, 0)

            SliderContainer.Name = "SliderContainer"
            SliderContainer.Parent = SliderBtn
            SliderContainer.AnchorPoint = Vector2.new(0, 0)
            SliderContainer.BackgroundTransparency = 1
            SliderContainer.Position = UDim2.new(0, 6, 0, 0)
            SliderContainer.Size = UDim2.new(1, -12, 1, 0)

            SliderListLayout.Parent = SliderContainer
            SliderListLayout.FillDirection = Enum.FillDirection.Horizontal
            SliderListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SliderListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            SliderName.Name = "Name"
            SliderName.Parent = SliderContainer
            SliderName.AnchorPoint = Vector2.new(0, 0)
            SliderName.BackgroundTransparency = 1
            SliderName.RichText = true
            SliderName.Position = UDim2.new(0, 0, 0, 0)
            SliderName.Size = UDim2.new(1, 0, 1, 0)
            SliderName.Font = GuiLibrary.Font
            SliderName.Text = tostring(ArgsSlider.Name or "Slider") .. "<font color='rgb(170,170,170)'>"..tostring(SliderApi.Value or "").."</font>"
            SliderName.TextColor3 = Color3.fromRGB(230,230,230)
            SliderName.TextSize = GuiLibrary.TextSize
            SliderName.TextXAlignment = Enum.TextXAlignment.Left
            SliderName.TextWrapped = true

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
            RealTextbox.TextColor3 = Color3.fromRGB(230,230,230)
            RealTextbox.TextSize = GuiLibrary.TextSize
            RealTextbox.TextXAlignment = Enum.TextXAlignment.Left

            RealTextbox.FocusLost:Connect(function()
                local n = tonumber(RealTextbox.Text)
                if n then SliderApi:Set(n, true) end
                RealTextbox.Text = ""
                InputTextBtn.Visible = false
                SliderBtn.Visible = true
            end)

            local function Slide(Input)
                if not Input or not SliderBtn.AbsoluteSize or SliderBtn.AbsoluteSize.X == 0 then return end
                if not Input.Position then return end
                local ok, px = pcall(function() return Input.Position.X - SliderBtn.AbsolutePosition.X end)
                if not ok or not px then return end
                local sizeX = math.clamp(px / SliderBtn.AbsoluteSize.X, 0, 1)
                SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                local value = math.floor(((((Max - Min) * sizeX) + Min) * (10 ^ RoundVal)) + 0.5) / (10 ^ RoundVal)
                SliderApi.Value = value
                SliderName.Text = tostring(ArgsSlider.Name or "Slider").." <font color='rgb(170,170,170)'>"..tostring(value).."</font>"
                if not ArgsSlider.OnInputEnded and ArgsSlider.Function then pcall(function() ArgsSlider.Function(value) end) end
            end

            local Sliding = false
            SliderBtn.InputBegan:Connect(function(Input)
                if not Input then return end
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        InputTextBtn.Visible = true
                        SliderBtn.Visible = false
                        RealTextbox:CaptureFocus()
                        return
                    end
                    Sliding = true
                    Slide(Input)
                end
            end)

            SliderBtn.InputEnded:Connect(function(Input)
                if not Input then return end
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if ArgsSlider.OnInputEnded and ArgsSlider.Function then pcall(function() ArgsSlider.Function(SliderApi.Value) end) end
                    Sliding = false
                end
            end)

            safeConnect(UserInputService.InputChanged, function(Input)
                if not Input then return end
                if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Sliding then
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

            GuiLibrary.Objects[ButtonId .. tostring(ArgsSlider.Name or "Slider") .. "Slider"] = {
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
            RealTextbox.AnchorPoint = Vector2.new(0, 0)
            RealTextbox.BackgroundTransparency = 1
            RealTextbox.Position = UDim2.new(0, 6, 0, 0)
            RealTextbox.Size = UDim2.new(1, -12, 1, 0)
            RealTextbox.ClearTextOnFocus = false
            RealTextbox.Font = GuiLibrary.Font
            RealTextbox.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
            RealTextbox.PlaceholderText = ArgsTextbox.Name or "Input"
            RealTextbox.Text = ArgsTextbox.Default or ""
            RealTextbox.TextColor3 = Color3.fromRGB(230,230,230)
            RealTextbox.TextSize = GuiLibrary.TextSize
            RealTextbox.TextXAlignment = Enum.TextXAlignment.Left
            RealTextbox.TextWrapped = true

            function TextboxApi:Set(Value, SkipFunction)
                local Value = tostring(Value)
                TextboxApi.Value = Value
                RealTextbox.Text = Value
                if not SkipFunction and ArgsTextbox.Function then pcall(function() ArgsTextbox.Function(Value) end) end
            end

            TextboxApi:Set(ArgsTextbox.Default or "", true)

            RealTextbox.FocusLost:Connect(function()
                pcall(function() TextboxApi:Set(RealTextbox.Text) end)
            end)

            GuiLibrary.Objects[ButtonId .. tostring(ArgsTextbox.Name or "Textbox") .. "Textbox"] = {
                API = TextboxApi, Instance = TextboxBtn, Type = "Textbox", OptionsButton = OptionsButton.Name, Window = Window.Name
            }

            return TextboxApi
        end

        GuiLibrary.Objects[ButtonId .. "OptionsButton"] = {
            Name = ArgsButton.Name, API = ButtonApi, Instance = OptionsButton, Type = "OptionsButton", Window = Window.Name
        }

        pcall(function() ButtonApi:Update() end)

        return ButtonApi
    end

    function WindowApi:Expand(Boolean)
        local DoExpand = (Boolean ~= nil) and Boolean or not WindowApi.Expanded
        WindowApi.Expanded = DoExpand
        ButtonContainer.Visible = DoExpand
        WindowApi:Update()
    end

    ExpandButton.MouseButton1Click:Connect(function() pcall(function() WindowApi:Expand() end) end)
    WindowTopbar.MouseButton2Click:Connect(function() pcall(function() WindowApi:Expand() end) end)
    DragGui(Window, WindowTopbar)

    safeConnect(ButtonListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() pcall(function() WindowApi:Update() end) end)

    GuiLibrary.Objects[WindowName .. "Window"] = { API = WindowApi, Instance = Window, Type = "Window" }

    pcall(function() WindowApi:Update() end)
    return WindowApi
end

function GuiLibrary:UpdateWindows()
    for _, v in next, self.Objects do
        if v.Type == "Window" and v.API and v.API.Update then pcall(function() v.API:Update() end) end
    end
end

if getgenv then
    getgenv().GuiLibraryExample = GuiLibrary
else
    _G.GuiLibraryExample = GuiLibrary
end

local ClickGuiRef = CoreGui:WaitForChild("Zephyr")

local AllVisible = true
local function ToggleAllFrames()
    AllVisible = not AllVisible
    for _, obj in pairs(ClickGuiRef:GetChildren()) do
        if obj:IsA("Frame") then
            pcall(function() obj.Visible = AllVisible end)
        end
    end
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleAllButton"
ToggleButton.Parent = ClickGuiRef
ToggleButton.Position = UDim2.new(0, 8, 0, 5)
ToggleButton.Size = UDim2.new(0, 100, 0, 24)
ToggleButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "Toggle"
ToggleButton.Font = GuiLibrary.Font
ToggleButton.TextSize = GuiLibrary.TextSize
ToggleButton.TextColor3 = Color3.fromRGB(230, 230, 230)
ToggleButton.ZIndex = 5

safeConnect(ToggleButton.Activated, function() ToggleAllFrames() end)

DragGui(ToggleButton, ToggleButton)

safeConnect(UserInputService.InputBegan, function(input, processed)
    if not processed and input and input.KeyCode == Enum.KeyCode.RightShift and not UserInputService:GetFocusedTextBox() then
        ToggleAllFrames()
    end
end)

return GuiLibrary
end)()
