local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Zephyr = {}
Zephyr.Windows = {}
Zephyr.Connections = {}
Zephyr.MonoCount = 0
Zephyr.Theme = {
    Background = Color3.fromRGB(0, 0, 0),
    Panel = Color3.fromRGB(12, 12, 12),
    Accent = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    MutedText = Color3.fromRGB(170, 170, 170),
    Font = Enum.Font.Gotham,
    TextSize = 14
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Zephyr_" .. tostring(math.random(1000, 9999))
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local function SafeNew(class, props)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            pcall(function() inst[k] = v end)
        end
    end
    return inst
end

local function MakeDraggable(frame, handle)
    if not frame or not handle then return end
    local dragging, dragStart, startPos
    local function Update(input)
        if not (input and input.Position and startPos) then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            Update(input)
        end
    end)
end

function Zephyr:Reflow()
    local x = 8
    for _, w in ipairs(self.Windows) do
        if w.Root and w.Root:IsA("Frame") then
            w.Root.Position = UDim2.new(0, x, 0, 30)
            x = x + w.Root.Size.X.Offset + 8
        end
    end
end

function Zephyr:ApplyMonochrome(enabled)
    if enabled then
        self.Theme.Background = Color3.fromRGB(255, 255, 255)
        self.Theme.Panel = Color3.fromRGB(0, 0, 0)
        self.Theme.Accent = Color3.fromRGB(255, 255, 255)
        self.Theme.Text = Color3.fromRGB(0, 0, 0)
        self.Theme.MutedText = Color3.fromRGB(100, 100, 100)
    else
        self.Theme.Background = Color3.fromRGB(0, 0, 0)
        self.Theme.Panel = Color3.fromRGB(12, 12, 12)
        self.Theme.Accent = Color3.fromRGB(255, 255, 255)
        self.Theme.Text = Color3.fromRGB(255, 255, 255)
        self.Theme.MutedText = Color3.fromRGB(170, 170, 170)
    end

    for _, w in ipairs(self.Windows) do
        if w.Root and w.Root:IsA("Frame") then
            pcall(function()
                w.Root.BackgroundColor3 = self.Theme.Background
                local top = w.Root:FindFirstChild("Topbar")
                if top then top.BackgroundColor3 = self.Theme.Panel end
                local title = top and top:FindFirstChild("Title")
                if title then title.TextColor3 = self.Theme.Text end
                local content = w.Root:FindFirstChild("Content")
                if content then
                    for _, c in ipairs(content:GetDescendants()) do
                        if (c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox")) and (c.Name == "Title" or c.Name == "Name" or c.Name == "Label" or c.Name == "KeybindLabel") then
                            pcall(function() c.TextColor3 = self.Theme.Text end)
                        elseif c:IsA("Frame") and c.Name == "Fill" then
                            pcall(function() c.BackgroundColor3 = self.Theme.Accent end)
                        end
                    end
                end
            end)
        end
    end
end

function Zephyr:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "Window"
    local width = opts.Width or 176
    local maxHeight = opts.MaxHeight or 420

    local window = {}
    window.Sections = {}
    window.Expanded = true

    local Root = SafeNew("Frame", {
        Parent = ScreenGui,
        Name = title .. "_Window",
        BackgroundColor3 = Zephyr.Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(0, width, 0, 220),
        Position = UDim2.new(0, (8 + (#self.Windows * (width + 8))), 0, 30),
        ClipsDescendants = true
    })

    local Topbar = SafeNew("TextButton", {
        Parent = Root,
        Name = "Topbar",
        BackgroundColor3 = Zephyr.Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 28),
        Text = "",
        AutoButtonColor = false
    })

    local TitleLabel = SafeNew("TextLabel", {
        Parent = Topbar,
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Font = Zephyr.Theme.Font,
        Text = title,
        TextColor3 = Zephyr.Theme.Text,
        TextSize = Zephyr.Theme.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local CollapseBtn = SafeNew("TextButton", {
        Parent = Topbar,
        Name = "Collapse",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -36, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Text = "-",
        Font = Zephyr.Theme.Font,
        TextSize = 18,
        TextColor3 = Zephyr.Theme.Text,
        AutoButtonColor = false
    })

    local Content = SafeNew("Frame", {
        Parent = Root,
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 34),
        Size = UDim2.new(1, 0, 1, -34)
    })

    local List = SafeNew("UIListLayout", { Parent = Content })
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Padding = UDim.new(0, 6)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    function window:Update()
        local contentSize = List.AbsoluteContentSize.Y
        local targetHeight = (not window.Expanded) and 34 or math.clamp(contentSize + 40, 34, maxHeight)
        Root.Size = UDim2.new(0, width, 0, targetHeight)
        CollapseBtn.Text = (window.Expanded and "-") or "+"
    end

    function window:CreateOption(args)
        args = args or {}
        local option = {}
        option.Enabled = false
        option.Keybind = args.DefaultKeybind
        option.Recording = false

        local OptionFrame = SafeNew("TextButton", {
            Parent = Content,
            Name = tostring(args.Name or "Option") .. "_OptionBtn",
            BackgroundColor3 = Zephyr.Theme.Panel,
            BorderSizePixel = 0,
            BackgroundTransparency = 0.85,
            Size = UDim2.new(0, width - 8, 0, 30),
            AutoButtonColor = false,
            Text = ""
        })

        local NameLabel = SafeNew("TextLabel", {
            Parent = OptionFrame,
            Name = "Name",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 6, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            Font = Zephyr.Theme.Font,
            Text = args.Name or "Option",
            TextColor3 = Zephyr.Theme.Text,
            TextSize = Zephyr.Theme.TextSize,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local GearBtn = SafeNew("TextButton", {
            Parent = OptionFrame,
            Name = "Gear",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -36, 0.5, -10),
            Size = UDim2.new(0, 20, 0, 20),
            Text = "+",
            Font = Zephyr.Theme.Font,
            TextSize = 16,
            TextColor3 = Zephyr.Theme.MutedText,
            AutoButtonColor = false
        })

        local Children = SafeNew("Frame", {
            Parent = Content,
            Name = tostring(args.Name or "Option") .. "_Children",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, width - 8, 0, 0),
            Visible = false,
            ClipsDescendants = true
        })

        local ChildrenList = SafeNew("UIListLayout", { Parent = Children })
        ChildrenList.SortOrder = Enum.SortOrder.LayoutOrder
        ChildrenList.Padding = UDim.new(0, 4)

        function option:Refresh()
            Children.Size = option.Expanded and UDim2.new(0, width - 8, 0, math.max(0, ChildrenList.AbsoluteContentSize.Y)) or UDim2.new(0, width - 8, 0, 0)
            window:Update()
            GearBtn.Text = (option.Expanded and "-") or "+"
        end

        option.Expanded = (args.DefaultExpanded == true)

        function option:UpdateEnabled(state)
            option.Enabled = state
            if state then
                OptionFrame.BackgroundTransparency = 0
                OptionFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                NameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
            else
                OptionFrame.BackgroundTransparency = 0.85
                OptionFrame.BackgroundColor3 = Zephyr.Theme.Panel
                NameLabel.TextColor3 = Zephyr.Theme.Text
            end
            if args.Callback and type(args.Callback) == "function" then
                pcall(function() args.Callback(option.Enabled) end)
            end
        end

        function option:Toggle(state)
            local s = (state == nil) and (not option.Enabled) or state
            option:UpdateEnabled(s)
        end

        if not args.NoKeybind then
            local RecordBtn = SafeNew("TextButton", {
                Parent = Children,
                Name = "KeybindButton",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                Text = "",
                AutoButtonColor = false
            })

            local KeybindLabel = SafeNew("TextLabel", {
                Parent = RecordBtn,
                Name = "KeybindLabel",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 0),
                Size = UDim2.new(1, -6, 1, 0),
                Font = Zephyr.Theme.Font,
                RichText = true,
                Text = "Keybind <font color='rgb(170,170,170)'>" .. (option.Keybind or "NONE") .. "</font>",
                TextColor3 = Zephyr.Theme.Text,
                TextSize = Zephyr.Theme.TextSize,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local function UpdateKeyLabel()
                KeybindLabel.Text = "Keybind <font color='rgb(170,170,170)'>" .. (option.Keybind or "NONE") .. "</font>"
            end

            table.insert(Zephyr.Connections, UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if option.Recording and input.KeyCode and input.KeyCode.Name ~= "Unknown" and UserInputService:GetFocusedTextBox() == nil then
                    option.Recording = false
                    RecordBtn.BackgroundTransparency = 1
                    if input.KeyCode.Name == "Escape" then
                        option.Keybind = args.DefaultKeybind
                    else
                        option.Keybind = input.KeyCode.Name
                    end
                    UpdateKeyLabel()
                elseif input.KeyCode and input.KeyCode.Name == option.Keybind and UserInputService:GetFocusedTextBox() == nil then
                    option:Toggle()
                end
            end))

            RecordBtn.MouseButton1Click:Connect(function()
                if not option.Recording then
                    option.Recording = true
                    KeybindLabel.Text = "Press a Key..."
                    RecordBtn.BackgroundTransparency = 0
                    RecordBtn.BackgroundColor3 = Zephyr.Theme.Panel
                else
                    option.Recording = false
                    UpdateKeyLabel()
                    RecordBtn.BackgroundTransparency = 1
                end
            end)
        end

        OptionFrame.MouseButton1Click:Connect(function() option:Toggle() end)
        OptionFrame.MouseButton2Click:Connect(function() option:Expand(not option.Expanded) end)
        GearBtn.MouseButton1Click:Connect(function() option:Expand(not option.Expanded) end)

        function option:Expand(b)
            local doExpand = (b ~= nil) and b or not option.Expanded
            option.Expanded = doExpand
            Children.Visible = doExpand
            option:Refresh()
        end

        function option:CreateToggle(tArgs)
            tArgs = tArgs or {}
            local toggle = {}
            toggle.Value = tArgs.Default == true

            local Btn = SafeNew("TextButton", {
                Parent = Children,
                Name = tostring(tArgs.Name or "Toggle") .. "_Toggle",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                Text = "",
                AutoButtonColor = false
            })

            local Label = SafeNew("TextLabel", {
                Parent = Btn,
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 0),
                Size = UDim2.new(1, -6, 1, 0),
                Font = Zephyr.Theme.Font,
                Text = tArgs.Name or "Toggle",
                TextColor3 = Zephyr.Theme.Text,
                TextSize = Zephyr.Theme.TextSize,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            function toggle:Set(v)
                local was = toggle.Value
                toggle.Value = v
                if v then
                    Btn.BackgroundTransparency = 0
                    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Label.TextColor3 = Color3.fromRGB(0, 0, 0)
                else
                    Btn.BackgroundTransparency = 1
                    Label.TextColor3 = Zephyr.Theme.Text
                end
                if tArgs.Callback and type(tArgs.Callback) == "function" then
                    pcall(function() tArgs.Callback(toggle.Value) end)
                end
            end

            Btn.MouseButton1Click:Connect(function() toggle:Set(not toggle.Value) end)
            toggle:Set(tArgs.Default == true)
            window:Update()
            return toggle
        end

        function option:CreateSelector(sArgs)
            sArgs = sArgs or {}
            local selector = { List = {}, Value = nil }
            for _, v in ipairs(sArgs.List or {}) do table.insert(selector.List, v) end
            selector.Value = sArgs.Default or selector.List[1]

            local Btn = SafeNew("TextButton", {
                Parent = Children,
                Name = tostring(sArgs.Name or "Selector") .. "_Selector",
                BackgroundTransparency = 0.35,
                BackgroundColor3 = Zephyr.Theme.Panel,
                Size = UDim2.new(1, 0, 0, 28),
                Text = "",
                AutoButtonColor = true
            })

            local Label = SafeNew("TextLabel", {
                Parent = Btn,
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 0),
                Size = UDim2.new(1, -6, 1, 0),
                Font = Zephyr.Theme.Font,
                RichText = true,
                Text = tostring(sArgs.Name or "Selector") .. " <font color='rgb(170,170,170)'>" .. tostring(selector.Value) .. "</font>",
                TextColor3 = Zephyr.Theme.Text,
                TextSize = Zephyr.Theme.TextSize,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local function UpdateText()
                Label.Text = tostring(sArgs.Name or "Selector") .. " <font color='rgb(170,170,170)'>" .. tostring(selector.Value) .. "</font>"
            end

            function selector:Select(keyOrIndex)
                local found = nil
                if type(keyOrIndex) == "number" then
                    if keyOrIndex < 1 then keyOrIndex = #selector.List end
                    if keyOrIndex > #selector.List then keyOrIndex = 1 end
                    found = selector.List[keyOrIndex]
                else
                    for _, v in ipairs(selector.List) do
                        if tostring(v) == tostring(keyOrIndex) then
                            found = v
                            break
                        end
                    end
                end
                if found then
                    selector.Value = found
                    UpdateText()
                    if sArgs.Callback and type(sArgs.Callback) == "function" then
                        pcall(function() sArgs.Callback(selector.Value) end)
                    end
                end
            end

            function selector:Next()
                local idx = table.find(selector.List, selector.Value) or 1
                idx = idx + 1
                if idx > #selector.List then idx = 1 end
                selector:Select(idx)
            end

            function selector:Previous()
                local idx = table.find(selector.List, selector.Value) or 1
                idx = idx - 1
                if idx < 1 then idx = #selector.List end
                selector:Select(idx)
            end

            Btn.MouseButton1Click:Connect(function() selector:Next() end)
            Btn.MouseButton2Click:Connect(function() selector:Previous() end)
            UpdateText()
            window:Update()
            return selector
        end

        function option:CreateSlider(slArgs)
            slArgs = slArgs or {}
            local Min = slArgs.Min or 0
            local Max = slArgs.Max or 100
            local Round = slArgs.Round or 1
            local value = slArgs.Default or Min

            local Btn = SafeNew("TextButton", {
                Parent = Children,
                Name = tostring(slArgs.Name or "Slider") .. "_Slider",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                Text = "",
                AutoButtonColor = false
            })

            local Fill = SafeNew("Frame", {
                Parent = Btn,
                Name = "Fill",
                BackgroundColor3 = Zephyr.Theme.Accent,
                BackgroundTransparency = 0.15,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0
            })

            local Label = SafeNew("TextLabel", {
                Parent = Btn,
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 0),
                Size = UDim2.new(1, -6, 1, 0),
                Font = Zephyr.Theme.Font,
                RichText = true,
                Text = tostring(slArgs.Name or "Slider") .. " <font color='rgb(170,170,170)'>" .. tostring(value) .. "</font>",
                TextColor3 = Zephyr.Theme.Text,
                TextSize = Zephyr.Theme.TextSize,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local sliding = false

            local function SetFromPosition(px)
                if not Btn.AbsoluteSize or Btn.AbsoluteSize.X == 0 then return end
                local rel = math.clamp((px - Btn.AbsolutePosition.X) / Btn.AbsoluteSize.X, 0, 1)
                local val = math.floor(((Min + (Max - Min) * rel) * (10 ^ Round)) + 0.5) / (10 ^ Round)
                value = val
                Fill.Size = UDim2.new((value - Min) / math.max((Max - Min), 1), 0, 1, 0)
                Label.Text = tostring(slArgs.Name or "Slider") .. " <font color='rgb(170,170,170)'>" .. tostring(value) .. "</font>"
                if slArgs.Callback and type(slArgs.Callback) == "function" then
                    pcall(function() slArgs.Callback(value) end)
                end
            end

            Btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    SetFromPosition(input.Position.X)
                end
            end)

            Btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            table.insert(Zephyr.Connections, UserInputService.InputChanged:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and sliding then
                    SetFromPosition(input.Position.X)
                end
            end))

            local SliderApi = {}

            function SliderApi:Set(v)
                value = math.floor((math.clamp(v, Min, Max) * (10 ^ Round)) + 0.5) / (10 ^ Round)
                Fill.Size = UDim2.new((value - Min) / math.max((Max - Min), 1), 0, 1, 0)
                Label.Text = tostring(slArgs.Name or "Slider") .. " <font color='rgb(170,170,170)'>" .. tostring(value) .. "</font>"
                if slArgs.Callback and type(slArgs.Callback) == "function" then
                    pcall(function() slArgs.Callback(value) end)
                end
            end

            SliderApi.Value = value
            SliderApi.Set = SliderApi.Set
            SliderApi:Set(value)
            window:Update()
            return SliderApi
        end

        function option:CreateTextbox(tbArgs)
            tbArgs = tbArgs or {}
            local ApiTb = { Value = tostring(tbArgs.Default or "") }

            local Btn = SafeNew("TextButton", {
                Parent = Children,
                Name = tostring(tbArgs.Name or "Textbox") .. "_Textbox",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                Text = "",
                AutoButtonColor = false
            })

            local Box = SafeNew("TextBox", {
                Parent = Btn,
                Name = "RealTextbox",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 0),
                Size = UDim2.new(1, -12, 1, 0),
                ClearTextOnFocus = false,
                Font = Zephyr.Theme.Font,
                PlaceholderColor3 = Zephyr.Theme.MutedText,
                PlaceholderText = tbArgs.Name or "Input",
                Text = tbArgs.Default or "",
                TextColor3 = Zephyr.Theme.Text,
                TextSize = Zephyr.Theme.TextSize,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            Box.FocusLost:Connect(function()
                ApiTb.Value = Box.Text
                if tbArgs.Callback and type(tbArgs.Callback) == "function" then
                    pcall(function() tbArgs.Callback(ApiTb.Value) end)
                end
            end)

            ApiTb.Set = function(v)
                ApiTb.Value = tostring(v or "")
                Box.Text = ApiTb.Value
            end

            window:Update()
            return ApiTb
        end

        table.insert(Zephyr.Connections, ChildrenList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pcall(function() option:Refresh() end)
        end))

        option.Toggle = option.Toggle
        option.CreateToggle = option.CreateToggle
        option.CreateSelector = option.CreateSelector
        option.CreateSlider = option.CreateSlider
        option.CreateTextbox = option.CreateTextbox
        option.Expand = option.Expand
        option.Root = OptionFrame

        if args.Default ~= nil and args.Default == true then
            option:UpdateEnabled(true)
        end

        option:Refresh()
        window:Update()

        table.insert(window.Sections, option)
        return option
    end

    function window:Expand(b)
        local doExpand = (b ~= nil) and b or not window.Expanded
        window.Expanded = doExpand
        Content.Visible = doExpand
        window:Update()
    end

    CollapseBtn.MouseButton1Click:Connect(function() window:Expand() end)
    Topbar.MouseButton2Click:Connect(function() window:Expand() end)
    MakeDraggable(Root, Topbar)

    table.insert(Zephyr.Connections, List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pcall(function() window:Update() end)
    end))

    window.Root = Root
    window.Title = TitleLabel
    window.Content = Content

    table.insert(self.Windows, window)
    self:Reflow()
    window:Update()
    return window
end

local AllVisible = true

local ToggleAllButton = SafeNew("TextButton", {
    Parent = ScreenGui,
    Name = "ToggleAllButton",
    BackgroundColor3 = Zephyr.Theme.Panel,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 8, 0, 5),
    Size = UDim2.new(0, 100, 0, 24),
    Text = "Toggle",
    Font = Zephyr.Theme.Font,
    TextSize = Zephyr.Theme.TextSize,
    TextColor3 = Zephyr.Theme.Text
})

MakeDraggable(ToggleAllButton, ToggleAllButton)

ToggleAllButton.Activated:Connect(function()
    AllVisible = not AllVisible
    for _, w in ipairs(Zephyr.Windows) do
        if w.Root and w.Root:IsA("Frame") then
            w.Root.Visible = AllVisible
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift and UserInputService:GetFocusedTextBox() == nil then
        ToggleAllButton:Activate()
    end
end)

function Zephyr:SetTheme(tbl)
    for k, v in pairs(tbl or {}) do
        if self.Theme[k] ~= nil then
            self.Theme[k] = v
        end
    end
    for _, w in ipairs(self.Windows) do
        if w.Root and w.Root:IsA("Frame") then
            pcall(function()
                w.Root.BackgroundColor3 = self.Theme.Background
                local top = w.Root:FindFirstChild("Topbar")
                if top then top.BackgroundColor3 = self.Theme.Panel end
                local title = top and top:FindFirstChild("Title")
                if title then title.TextColor3 = self.Theme.Text end
            end)
        end
    end
end

function Zephyr:Destroy()
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
    for _, w in ipairs(self.Windows) do
        if w.Root and w.Root.Parent then
            pcall(function() w.Root:Destroy() end)
        end
    end
    if ToggleAllButton and ToggleAllButton.Parent then
        pcall(function() ToggleAllButton:Destroy() end)
    end
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
    end
    Zephyr.Windows = {}
    Zephyr.Connections = {}
end

return Zephyr
