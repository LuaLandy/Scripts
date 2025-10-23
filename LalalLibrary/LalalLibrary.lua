local UILib = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local function Create(Class, Props)
    local Obj = Instance.new(Class)
    for K, V in pairs(Props or {}) do
        if K == "Parent" then
            Obj.Parent = V
        else
            Obj[K] = V
        end
    end
    return Obj
end

local function Drag(Frame)
    Frame.Active = true
    local Dragging = false
    local DragInput
    local DragStart
    local StartPos = Vector2.new(0, 0)
    local function Update(Input)
        local Delta = Input.Position - DragStart
        Frame.Position = UDim2.new(0, StartPos.X + Delta.X, 0, StartPos.Y + Delta.Y)
    end
    local function Start(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragInput = Input
            DragStart = Input.Position
            StartPos = Vector2.new(Frame.AbsolutePosition.X, Frame.AbsolutePosition.Y)
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end
    Frame.InputBegan:Connect(Start)
    Frame.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            Update(Input)
        end
    end)
    for _, Desc in ipairs(Frame:GetDescendants()) do
        if Desc:IsA("TextLabel") or Desc:IsA("ImageLabel") or Desc:IsA("TextButton") or Desc:IsA("TextBox") then
            Desc.Active = true
            Desc.InputBegan:Connect(Start)
        end
    end
end

function UILib:CreateWindow(Title, Options)
    local Options = Options or {}
    local Colors = Options.Colors or {Background = Color3.fromRGB(15,15,15), Text = Color3.fromRGB(255,255,255), Transparency = 0.5}
    local Window = {}

    local ScreenGui = Create("ScreenGui", {Parent = CoreGui})
    CollectionService:AddTag(ScreenGui, "Main")

    local Topbar = Create("Frame", {
        Parent = ScreenGui,
        BorderSizePixel = 0,
        BackgroundColor3 = Colors.Background,
        Size = UDim2.new(0, 700, 0, 28),
        Position = UDim2.new(0, 60, 0, 60),
        Name = "Topbar"
    })

    local TitleLabel = Create("TextLabel", {
        Parent = Topbar,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextColor3 = Colors.Text,
        Size = UDim2.new(1, -64, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Text = Title or "Window",
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansSemibold,
        TextSize = 18
    })

    local ExpandButton = Create("TextButton", {
        Parent = Topbar,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextColor3 = Colors.Text,
        Size = UDim2.new(0, 36, 1, 0),
        Text = "v",
        Position = UDim2.new(1, -40, 0, 0),
        AutoButtonColor = true,
        Font = Enum.Font.SourceSansBold,
        TextSize = 18
    })

    Drag(Topbar)

    local MainFrame = Create("Frame", {
        Parent = Topbar,
        BorderSizePixel = 0,
        BackgroundColor3 = Colors.Background,
        Size = UDim2.new(0, 700, 0, 360),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = Colors.Transparency,
        Name = "MainFrame",
        ClipsDescendants = true
    })

    local TabsHolder = Create("Frame", {
        Parent = MainFrame,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, 8, 0, 8)
    })

    local ContentHolder = Create("Frame", {
        Parent = MainFrame,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -136, 1, -16),
        Position = UDim2.new(0, 128, 0, 8),
        ClipsDescendants = true
    })

    ExpandButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        ExpandButton.Text = MainFrame.Visible and "v" or ">"
    end)

    function Window:CreateTab(Name)
        local Tab = {}

        local TabButton = Create("TextButton", {
            Parent = TabsHolder,
            BorderSizePixel = 0,
            BackgroundColor3 = Colors.Background,
            TextColor3 = Colors.Text,
            Size = UDim2.new(1, 0, 0, 34),
            Position = UDim2.new(0, 0, 0, (#TabsHolder:GetChildren()-0)*36),
            Text = Name,
            AutoButtonColor = true,
            Font = Enum.Font.SourceSans,
            TextSize = 16
        })
        Create("UICorner", {Parent = TabButton})

        local ContentFrame = Create("Frame", {
            Parent = ContentHolder,
            BorderSizePixel = 0,
            BackgroundColor3 = Colors.Background,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Name = Name.."Content",
            ClipsDescendants = true
        })

        local Scroll = Create("ScrollingFrame", {
            Parent = ContentFrame,
            Active = true,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 8
        })

        local ListLayout = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
        end)

        local function ShowContent()
            for _, Child in ipairs(ContentHolder:GetChildren()) do
                if Child:IsA("Frame") then
                    Child.Visible = false
                end
            end
            ContentFrame.Visible = true
        end

        TabButton.MouseButton1Click:Connect(ShowContent)
        if #TabsHolder:GetChildren() == 1 then
            ShowContent()
        end

        function Tab:CreateToggle(Text, Callback)
            if type(Text) == "table" then
                local t = Text
                Text = t.Text or t.Label or "Toggle"
                Callback = Callback or t.Callback or t.OnToggle or t.OnChanged
            end
            local Holder = Create("Frame", {Parent = Scroll, BorderSizePixel = 0, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36)})
            local ToggleButton = Create("TextButton", {
                Parent = Holder,
                BorderSizePixel = 0,
                BackgroundColor3 = Colors.Background,
                TextColor3 = Colors.Text,
                Size = UDim2.new(0, 28, 0, 28),
                Position = UDim2.new(0, 0, 0, 4),
                Text = "",
                AutoButtonColor = true
            })
            Create("UICorner", {Parent = ToggleButton})
            local CheckLabel = Create("TextLabel", {
                Parent = ToggleButton,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                TextColor3 = Colors.Text,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = "",
                Font = Enum.Font.SourceSansBold,
                TextSize = 18
            })
            local ToggleText = Create("TextLabel", {
                Parent = Holder,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                TextColor3 = Colors.Text,
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 40, 0, 0),
                Text = Text or "Toggle",
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.SourceSans,
                TextSize = 16
            })
            local State = false
            ToggleButton.MouseButton1Click:Connect(function()
                State = not State
                CheckLabel.Text = State and "✔" or ""
                if Callback then Callback(State) end
            end)
            return Holder
        end

        function Tab:CreateDropdown(Text, Choices, Callback)
            if type(Text) == "table" then
                local t = Text
                Text = t.Text or t.Label or "Dropdown"
                Choices = t.Choices or t.Items or {}
                Callback = Callback or t.Callback or t.OnChanged or t.OnSelect
            end

            local Holder = Create("Frame", {Parent = Scroll, BorderSizePixel = 0, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36)})
            local DropdownButton = Create("TextButton", {
                Parent = Holder,
                BorderSizePixel = 0,
                BackgroundColor3 = Colors.Background,
                TextColor3 = Colors.Text,
                Size = UDim2.new(0, 120, 0, 30),
                Position = UDim2.new(0, 6, 0, 4),
                Text = "Select",
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = true,
                Font = Enum.Font.SourceSans,
                TextSize = 16
            })
            Create("UICorner", {Parent = DropdownButton})
            local Arrow = Create("TextButton", {
                Parent = DropdownButton,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Text = ">",
                TextColor3 = Colors.Text,
                Size = UDim2.new(0, 24, 1, 0),
                Position = UDim2.new(1, -24, 0, 0),
                AutoButtonColor = true,
                Font = Enum.Font.SourceSansBold,
                TextSize = 18
            })
            local DropdownLabel = Create("TextLabel", {
                Parent = Holder,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                TextColor3 = Colors.Text,
                Size = UDim2.new(1, -132, 1, 0),
                Position = UDim2.new(0, 132, 0, 0),
                Text = Text or "Dropdown",
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.SourceSans,
                TextSize = 16
            })

            local DropdownFrame = Create("Frame", {
                Parent = ScreenGui,
                BorderSizePixel = 0,
                BackgroundColor3 = Colors.Background,
                Size = UDim2.new(0, 300, 0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ClipsDescendants = true,
                ZIndex = 50,
                Visible = false
            })
            Create("UICorner", {Parent = DropdownFrame})

            local DropdownScroll = Create("ScrollingFrame", {
                Parent = DropdownFrame,
                Active = true,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 8,
                ZIndex = 50
            })

            local DropdownListLayout = Create("UIListLayout", {Parent = DropdownScroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
            DropdownListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, DropdownListLayout.AbsoluteContentSize.Y + 8)
                if Expanded then UpdateDropdownPlacement() end
            end)

            Choices = Choices or {}
            local Buttons = {}
            local Expanded = false
            local MaxVisibleItems = 8
            local ItemHeight = 34
            local function UpdateDropdownPlacement()
                local absPos = DropdownButton.AbsolutePosition
                local absSize = DropdownButton.AbsoluteSize
                DropdownFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y)
                local totalHeight = (#Choices * ItemHeight) + 8
                local visibleHeight = math.min(totalHeight, MaxVisibleItems * ItemHeight + 8)
                DropdownFrame.Size = UDim2.new(0, absSize.X, 0, Expanded and visibleHeight or 0)
            end

            local function SetExpanded(E)
                Expanded = E
                DropdownFrame.Visible = E
                Arrow.Text = Expanded and "v" or ">"
                UpdateDropdownPlacement()
            end

            local function ToggleExpanded()
                SetExpanded(not Expanded)
            end

            DropdownButton.MouseButton1Click:Connect(ToggleExpanded)
            Arrow.MouseButton1Click:Connect(ToggleExpanded)

            DropdownButton:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() if Expanded then UpdateDropdownPlacement() end end)
            DropdownButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() if Expanded then UpdateDropdownPlacement() end end)
            Topbar:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() if Expanded then UpdateDropdownPlacement() end end)
            RunService.RenderStepped:Connect(function() if Expanded then UpdateDropdownPlacement() end end)

            for I, Choice in ipairs(Choices) do
                local ChoiceButton = Create("TextButton", {
                    Parent = DropdownScroll,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Colors.Background,
                    TextColor3 = Colors.Text,
                    Size = UDim2.new(1, -8, 0, 30),
                    Text = Choice,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = true,
                    Font = Enum.Font.SourceSans,
                    TextSize = 16,
                    ZIndex = 51
                })
                Create("UICorner", {Parent = ChoiceButton})
                ChoiceButton.MouseButton1Click:Connect(function()
                    DropdownButton.Text = Choice
                    SetExpanded(false)
                    if Callback then Callback(Choice) end
                end)
                table.insert(Buttons, ChoiceButton)
            end

            local Dropdown = {}

            function Dropdown:Add(NewChoice)
                if not NewChoice then return end
                table.insert(Choices, NewChoice)
                local ChoiceText = NewChoice
                local ChoiceButton = Create("TextButton", {
                    Parent = DropdownScroll,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Colors.Background,
                    TextColor3 = Colors.Text,
                    Size = UDim2.new(1, -8, 0, 30),
                    Text = ChoiceText,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = true,
                    Font = Enum.Font.SourceSans,
                    TextSize = 16,
                    ZIndex = 51
                })
                Create("UICorner", {Parent = ChoiceButton})
                ChoiceButton.MouseButton1Click:Connect(function()
                    DropdownButton.Text = ChoiceText
                    SetExpanded(false)
                    if Callback then Callback(ChoiceText) end
                end)
                table.insert(Buttons, ChoiceButton)
                if Expanded then UpdateDropdownPlacement() end
            end

            function Dropdown:Remove(ChoiceName)
                if not ChoiceName then return end
                local idx = nil
                for i, v in ipairs(Choices) do
                    if v == ChoiceName then
                        idx = i
                        break
                    end
                end
                if not idx then return end
                if Buttons[idx] and Buttons[idx].Destroy then
                    Buttons[idx]:Destroy()
                end
                table.remove(Buttons, idx)
                table.remove(Choices, idx)
                if DropdownButton.Text == ChoiceName then
                    DropdownButton.Text = "Select"
                end
                if Expanded then UpdateDropdownPlacement() end
            end

            function Dropdown:Clear()
                for _, btn in ipairs(Buttons) do
                    if btn and btn.Destroy then
                        btn:Destroy()
                    end
                end
                Buttons = {}
                Choices = {}
                DropdownButton.Text = "Select"
                if Expanded then UpdateDropdownPlacement() end
            end

            return Dropdown
        end

        function Tab:CreateButton(Text, Callback)
            if type(Text) == "table" then
                local t = Text
                Text = t.Text or t.Label or "Button"
                Callback = Callback or t.Callback or t.OnClick or t.Function
            end
            local Btn = Create("TextButton", {
                Parent = Scroll,
                BorderSizePixel = 0,
                BackgroundColor3 = Colors.Background,
                TextColor3 = Colors.Text,
                Size = UDim2.new(1, -12, 0, 36),
                Position = UDim2.new(0, 6, 0, 0),
                Text = Text or "Button",
                AutoButtonColor = true,
                Font = Enum.Font.SourceSans,
                TextSize = 16
            })
            Create("UICorner", {Parent = Btn})
            Btn.MouseButton1Click:Connect(function()
                if Callback then Callback() end
            end)
            return Btn
        end

        function Tab:CreateTextBox(Placeholder, Callback)
            if type(Placeholder) == "table" then
                local t = Placeholder
                Placeholder = t.Placeholder or t.Text or t.Label or ""
                Callback = Callback or t.Callback or t.OnSubmit or t.OnEnter
            end
            local Box = Create("TextBox", {
                Parent = Scroll,
                BorderSizePixel = 0,
                BackgroundColor3 = Colors.Background,
                TextColor3 = Colors.Text,
                Size = UDim2.new(1, -12, 0, 36),
                Position = UDim2.new(0, 6, 0, 0),
                Text = "",
                PlaceholderText = Placeholder or "",
                ClearTextOnFocus = false,
                Font = Enum.Font.SourceSans,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Create("UICorner", {Parent = Box})
            Box.FocusLost:Connect(function(EnterPressed)
                if Callback then Callback(Box.Text, EnterPressed) end
            end)
            return Box
        end

        function Tab:CreateSlider(LabelText, Min, Max, Default, Callback, Step, ColorOverride)
            if type(LabelText) == "table" then
                local t = LabelText
                LabelText = t.Text or t.Label or "Slider"
                Min = t.Min or t.MinValue or t.Minimum or Min
                Max = t.Max or t.MaxValue or t.Maximum or Max
                Default = t.Default or t.Value or t.DefaultValue or Default
                Callback = Callback or t.Callback or t.OnChange or t.OnChanged
                Step = t.Step or t.Increment or Step
                ColorOverride = t.Color or t.ColorOverride or t.Color3 or ColorOverride
            end
            Min = Min or 0
            Max = Max or 100
            Default = Default or Min
            if Min > Max then Min, Max = Max, Min end
            Step = Step or 1
            local Color = ColorOverride or Colors.Background

            local Holder = Create("Frame", {Parent = Scroll, BorderSizePixel = 0, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36)})
            local Label = Create("TextLabel", {
                Parent = Holder,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                TextColor3 = Colors.Text,
                Size = UDim2.new(1, -90, 0, 16),
                Position = UDim2.new(0, 6, 0, 2),
                Text = LabelText or "Slider",
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.SourceSans,
                TextSize = 16
            })
            local ValueLabel = Create("TextLabel", {
                Parent = Holder,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                TextColor3 = Colors.Text,
                Size = UDim2.new(0, 80, 0, 16),
                Position = UDim2.new(1, -86, 0, 2),
                Text = tostring(Default),
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.SourceSans,
                TextSize = 16
            })

            local Track = Create("Frame", {
                Parent = Holder,
                BorderSizePixel = 0,
                BackgroundColor3 = Colors.Background,
                Size = UDim2.new(1, -12, 0, 10),
                Position = UDim2.new(0, 6, 0, 20),
            })
            Create("UICorner", {Parent = Track})
            Track.Active = true

            local Fill = Create("Frame", {
                Parent = Track,
                BorderSizePixel = 0,
                BackgroundColor3 = Color,
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = 2
            })
            Create("UICorner", {Parent = Fill})

            local Knob = Create("TextButton", {
                Parent = Track,
                BorderSizePixel = 0,
                BackgroundColor3 = Color,
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, -6, 0, -1),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 3
            })
            Create("UICorner", {Parent = Knob})
            Knob.Active = true

            local function SnapValue(v)
                if Step and Step > 0 then
                    v = math.floor((v / Step) + 0.5) * Step
                end
                return math.clamp(v, Min, Max)
            end

            local function FormatValue(v)
                if math.floor(v) == v then
                    return tostring(v)
                else
                    return tostring(math.floor(v * 100 + 0.5) / 100)
                end
            end

            local function setToPercentage(pct, call)
                pct = math.clamp(pct, 0, 1)
                local raw = Min + (Max - Min) * pct
                raw = SnapValue(raw)
                local newPct = (Max - Min) == 0 and 0 or ((raw - Min) / (Max - Min))
                Fill.Size = UDim2.new(newPct, 0, 1, 0)
                Knob.Position = UDim2.new(newPct, -6, 0, -1)
                ValueLabel.Text = FormatValue(raw)
                if call and Callback then
                    Callback(raw)
                end
            end

            local initialSnapped = SnapValue(Default)
            local initialPct = 0
            if Max - Min ~= 0 then
                initialPct = math.clamp((initialSnapped - Min) / (Max - Min), 0, 1)
            end
            RunService.RenderStepped:Wait()
            setToPercentage(initialPct, false)

            local dragging = false
            local currentInput = nil
            local draggingSource = nil
            local dragConnection = nil

            local function updateFromInputPosition(pos)
                local absPos = Track.AbsolutePosition
                local absSize = Track.AbsoluteSize
                local x = math.clamp(pos.X - absPos.X, 0, absSize.X)
                local pct = 0
                if absSize.X > 0 then
                    pct = x / absSize.X
                end
                setToPercentage(pct, true)
            end

            local function startDrag(inputType, input)
                dragging = true
                currentInput = input
                draggingSource = inputType
                if dragConnection then
                    dragConnection:Disconnect()
                    dragConnection = nil
                end
                dragConnection = RunService.RenderStepped:Connect(function()
                    if not dragging then return end
                    local pos
                    if draggingSource == "Mouse" then
                        pos = UserInputService:GetMouseLocation()
                    else
                        if currentInput and currentInput.Position then
                            pos = currentInput.Position
                        end
                    end
                    if pos then
                        updateFromInputPosition(pos)
                    end
                end)
            end

            local function stopDrag()
                dragging = false
                currentInput = nil
                draggingSource = nil
                if dragConnection then
                    dragConnection:Disconnect()
                    dragConnection = nil
                end
            end

            Knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    startDrag("Mouse", input)
                elseif input.UserInputType == Enum.UserInputType.Touch then
                    startDrag("Touch", input)
                end
            end)
            Knob.InputEnded:Connect(function(input)
                if input == currentInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    stopDrag()
                end
            end)

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if input.Position then
                        updateFromInputPosition(input.Position)
                    end
                    startDrag(input.UserInputType == Enum.UserInputType.Touch and "Touch" or "Mouse", input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if not dragging then return end
                if draggingSource == "Mouse" and input.UserInputType == Enum.UserInputType.MouseMovement then
                elseif draggingSource == "Touch" and input == currentInput and input.Position then
                    updateFromInputPosition(input.Position)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input == currentInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    stopDrag()
                end
            end)

            Track:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                local curVal = tonumber(ValueLabel.Text) or initialSnapped
                local pct = (Max - Min) == 0 and 0 or ((curVal - Min) / (Max - Min))
                setToPercentage(math.clamp(pct, 0, 1), false)
            end)
            Track:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                local curVal = tonumber(ValueLabel.Text) or initialSnapped
                local pct = (Max - Min) == 0 and 0 or ((curVal - Min) / (Max - Min))
                setToPercentage(math.clamp(pct, 0, 1), false)
            end)

            return Holder
        end

        Tab.AddToggle = Tab.CreateToggle
        Tab.AddDropdown = Tab.CreateDropdown
        Tab.AddButton = Tab.CreateButton
        Tab.AddTextBox = Tab.CreateTextBox
        Tab.AddSlider = Tab.CreateSlider

        return Tab
    end

    return Window
end

return UILib
