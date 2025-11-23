-- ============================================
-- UI Library tự tạo - Custom UI Framework
-- ============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- UI Library Core
-- ============================================

local UILib = {}
UILib.Themes = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(100, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        Border = Color3.fromRGB(60, 60, 60)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Secondary = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(100, 150, 255),
        Text = Color3.fromRGB(30, 30, 30),
        TextSecondary = Color3.fromRGB(100, 100, 100),
        Border = Color3.fromRGB(200, 200, 200)
    }
}

UILib.CurrentTheme = UILib.Themes.Dark

-- Tạo ScreenGui
local function CreateScreenGui()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    return ScreenGui
end

-- Tạo UI Corner
local function CreateCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

-- Tạo UI Stroke
local function CreateStroke(color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or UILib.CurrentTheme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = 0.5
    return stroke
end

-- Tạo Text Label
local function CreateLabel(parent, text, size, position)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = UILib.CurrentTheme.Text
    label.TextSize = size or 14
    label.Font = Enum.Font.Gotham
    label.Size = UDim2.new(1, -20, 0, size or 14)
    label.Position = position or UDim2.new(0, 10, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

-- ============================================
-- Window Class
-- ============================================

function UILib:CreateWindow(options)
    options = options or {}
    local title = options.Title or "UI Window"
    local size = options.Size or UDim2.new(0, 500, 0, 400)
    local theme = options.Theme or "Dark"
    local minimizeKey = options.MinimizeKey or Enum.KeyCode.LeftControl
    
    UILib.CurrentTheme = UILib.Themes[theme] or UILib.Themes.Dark
    local ScreenGui = CreateScreenGui()
    
    -- Main Window Frame
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Parent = ScreenGui
    Window.BackgroundColor3 = UILib.CurrentTheme.Background
    Window.Size = size
    Window.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    Window.BorderSizePixel = 0
    CreateCorner(12).Parent = Window
    CreateStroke(UILib.CurrentTheme.Border, 2).Parent = Window
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Window
    TitleBar.BackgroundColor3 = UILib.CurrentTheme.Secondary
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BorderSizePixel = 0
    CreateCorner(12).Parent = TitleBar
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Text = title
    TitleText.TextColor3 = UILib.CurrentTheme.Text
    TitleText.TextSize = 16
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Size = UDim2.new(1, -80, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Parent = TitleBar
    MinimizeBtn.BackgroundColor3 = UILib.CurrentTheme.Accent
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 20
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.BorderSizePixel = 0
    CreateCorner(6).Parent = MinimizeBtn
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CreateCorner(6).Parent = CloseBtn
    
    -- Content Frame
    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.Parent = Window
    Content.BackgroundTransparency = 1
    Content.Size = UDim2.new(1, 0, 1, -40)
    Content.Position = UDim2.new(0, 0, 0, 40)
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 6
    Content.ScrollBarImageColor3 = UILib.CurrentTheme.Accent
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Parent = Content
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Drag Functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Window.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Minimize Functionality
    local isMinimized = false
    local originalSize = Window.Size
    local originalPosition = Window.Position
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Window.Size = UDim2.new(0, originalSize.X.Offset, 0, 40)
            Content.Visible = false
        else
            Window.Size = originalSize
            Content.Visible = true
        end
    end)
    
    -- Keyboard Minimize
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == minimizeKey then
            isMinimized = not isMinimized
            if isMinimized then
                Window.Size = UDim2.new(0, originalSize.X.Offset, 0, 40)
                Content.Visible = false
            else
                Window.Size = originalSize
                Content.Visible = true
            end
        end
    end)
    
    -- Close Functionality
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Update Canvas Size
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Window Object
    local WindowObj = {}
    WindowObj.Window = Window
    WindowObj.Content = Content
    WindowObj.ScreenGui = ScreenGui
    
    -- Add Section Method
    function WindowObj:AddSection(title)
        local Section = Instance.new("Frame")
        Section.Name = "Section"
        Section.Parent = self.Content
        Section.BackgroundColor3 = UILib.CurrentTheme.Secondary
        Section.Size = UDim2.new(1, -20, 0, 0)
        Section.Position = UDim2.new(0, 10, 0, 0)
        Section.BorderSizePixel = 0
        CreateCorner(8).Parent = Section
        
        local SectionLayout = Instance.new("UIListLayout")
        SectionLayout.Parent = Section
        SectionLayout.Padding = UDim.new(0, 10)
        SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        -- Section Title
        if title then
            local SectionTitle = CreateLabel(Section, title, 16)
            SectionTitle.Position = UDim2.new(0, 10, 0, 10)
            SectionTitle.TextColor3 = UILib.CurrentTheme.Accent
        end
        
        local SectionObj = {}
        SectionObj.Section = Section
        SectionObj.Layout = SectionLayout
        
        -- Add Button
        function SectionObj:AddButton(options)
            options = options or {}
            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.Parent = self.Section
            button.BackgroundColor3 = UILib.CurrentTheme.Accent
            button.Size = UDim2.new(1, -20, 0, 35)
            button.Position = UDim2.new(0, 10, 0, 0)
            button.Text = options.Title or "Button"
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 14
            button.Font = Enum.Font.Gotham
            button.BorderSizePixel = 0
            CreateCorner(6).Parent = button
            
            local buttonObj = {}
            
            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UILib.CurrentTheme.Accent:lerp(Color3.fromRGB(255, 255, 255), 0.2)}):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UILib.CurrentTheme.Accent}):Play()
            end)
            
            button.MouseButton1Click:Connect(function()
                if options.Callback then
                    options.Callback()
                end
            end)
            
            return buttonObj
        end
        
        -- Add Toggle
        function SectionObj:AddToggle(name, options)
            options = options or {}
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = "Toggle"
            toggleFrame.Parent = self.Section
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Size = UDim2.new(1, -20, 0, 30)
            toggleFrame.Position = UDim2.new(0, 10, 0, 0)
            
            local toggleLabel = CreateLabel(toggleFrame, options.Title or "Toggle", 14)
            toggleLabel.Position = UDim2.new(0, 0, 0, 0)
            
            local toggle = Instance.new("TextButton")
            toggle.Name = "ToggleButton"
            toggle.Parent = toggleFrame
            toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            toggle.Size = UDim2.new(0, 50, 0, 25)
            toggle.Position = UDim2.new(1, -50, 0, 2.5)
            toggle.Text = ""
            toggle.BorderSizePixel = 0
            CreateCorner(12).Parent = toggle
            
            local toggleIndicator = Instance.new("Frame")
            toggleIndicator.Name = "Indicator"
            toggleIndicator.Parent = toggle
            toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
            toggleIndicator.Position = UDim2.new(0, 2.5, 0, 2.5)
            toggleIndicator.BorderSizePixel = 0
            CreateCorner(10).Parent = toggleIndicator
            
            local isToggled = options.Default or false
            
            local function updateToggle()
                if isToggled then
                    TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 27.5, 0, 2.5)}):Play()
                    TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = UILib.CurrentTheme.Accent}):Play()
                else
                    TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2.5, 0, 2.5)}):Play()
                    TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                end
            end
            
            updateToggle()
            
            toggle.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                updateToggle()
                if options.Callback then
                    options.Callback(isToggled)
                end
            end)
            
            local toggleObj = {}
            function toggleObj:Set(value)
                isToggled = value
                updateToggle()
            end
            function toggleObj:Get()
                return isToggled
            end
            
            return toggleObj
        end
        
        -- Add Dropdown
        function SectionObj:AddDropdown(name, options)
            options = options or {}
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = "Dropdown"
            dropdownFrame.Parent = self.Section
            dropdownFrame.BackgroundColor3 = UILib.CurrentTheme.Secondary
            dropdownFrame.Size = UDim2.new(1, -20, 0, 30)
            dropdownFrame.Position = UDim2.new(0, 10, 0, 0)
            dropdownFrame.BorderSizePixel = 0
            CreateCorner(6).Parent = dropdownFrame
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Name = "DropdownButton"
            dropdownButton.Parent = dropdownFrame
            dropdownButton.BackgroundTransparency = 1
            dropdownButton.Size = UDim2.new(1, -30, 1, 0)
            dropdownButton.Position = UDim2.new(0, 10, 0, 0)
            dropdownButton.Text = options.Default or (options.Values and options.Values[1]) or "Select"
            dropdownButton.TextColor3 = UILib.CurrentTheme.Text
            dropdownButton.TextSize = 14
            dropdownButton.Font = Enum.Font.Gotham
            dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
            
            local dropdownArrow = Instance.new("TextLabel")
            dropdownArrow.Parent = dropdownFrame
            dropdownArrow.BackgroundTransparency = 1
            dropdownArrow.Size = UDim2.new(0, 20, 1, 0)
            dropdownArrow.Position = UDim2.new(1, -20, 0, 0)
            dropdownArrow.Text = "▼"
            dropdownArrow.TextColor3 = UILib.CurrentTheme.Text
            dropdownArrow.TextSize = 12
            dropdownArrow.Font = Enum.Font.Gotham
            
            local dropdownList = Instance.new("Frame")
            dropdownList.Name = "DropdownList"
            dropdownList.Parent = dropdownFrame
            dropdownList.BackgroundColor3 = UILib.CurrentTheme.Secondary
            dropdownList.Size = UDim2.new(1, 0, 0, 0)
            dropdownList.Position = UDim2.new(0, 0, 1, 5)
            dropdownList.BorderSizePixel = 0
            dropdownList.Visible = false
            dropdownList.ClipsDescendants = true
            CreateCorner(6).Parent = dropdownList
            CreateStroke(UILib.CurrentTheme.Border, 1).Parent = dropdownList
            
            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = dropdownList
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local isOpen = false
            local selectedValue = options.Default or (options.Values and options.Values[1])
            
            local function updateList()
                dropdownList:ClearAllChildren()
                listLayout.Parent = dropdownList
                
                if options.Values then
                    for i, value in ipairs(options.Values) do
                        local option = Instance.new("TextButton")
                        option.Name = "Option"
                        option.Parent = dropdownList
                        option.BackgroundColor3 = UILib.CurrentTheme.Background
                        option.Size = UDim2.new(1, -10, 0, 25)
                        option.Position = UDim2.new(0, 5, 0, 0)
                        option.Text = tostring(value)
                        option.TextColor3 = UILib.CurrentTheme.Text
                        option.TextSize = 13
                        option.Font = Enum.Font.Gotham
                        option.BorderSizePixel = 0
                        CreateCorner(4).Parent = option
                        
                        option.MouseEnter:Connect(function()
                            option.BackgroundColor3 = UILib.CurrentTheme.Accent
                        end)
                        
                        option.MouseLeave:Connect(function()
                            option.BackgroundColor3 = UILib.CurrentTheme.Background
                        end)
                        
                        option.MouseButton1Click:Connect(function()
                            selectedValue = value
                            dropdownButton.Text = tostring(value)
                            isOpen = false
                            dropdownList.Visible = false
                            TweenService:Create(dropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                            if options.Callback then
                                options.Callback(value)
                            end
                        end)
                    end
                    
                    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        if isOpen then
                            dropdownList.Size = UDim2.new(1, 0, 0, math.min(listLayout.AbsoluteContentSize.Y, 150))
                        end
                    end)
                end
            end
            
            updateList()
            
            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                dropdownList.Visible = isOpen
                if isOpen then
                    TweenService:Create(dropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, math.min(listLayout.AbsoluteContentSize.Y, 150))}):Play()
                else
                    TweenService:Create(dropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                end
            end)
            
            local dropdownObj = {}
            function dropdownObj:Set(value)
                selectedValue = value
                dropdownButton.Text = tostring(value)
            end
            function dropdownObj:Get()
                return selectedValue
            end
            
            return dropdownObj
        end
        
        -- Add TextBox
        function SectionObj:AddTextBox(name, options)
            options = options or {}
            local textboxFrame = Instance.new("Frame")
            textboxFrame.Name = "TextBox"
            textboxFrame.Parent = self.Section
            textboxFrame.BackgroundColor3 = UILib.CurrentTheme.Secondary
            textboxFrame.Size = UDim2.new(1, -20, 0, 30)
            textboxFrame.Position = UDim2.new(0, 10, 0, 0)
            textboxFrame.BorderSizePixel = 0
            CreateCorner(6).Parent = textboxFrame
            
            local textbox = Instance.new("TextBox")
            textbox.Name = "Input"
            textbox.Parent = textboxFrame
            textbox.BackgroundTransparency = 1
            textbox.Size = UDim2.new(1, -20, 1, 0)
            textbox.Position = UDim2.new(0, 10, 0, 0)
            textbox.Text = options.Default or ""
            textbox.PlaceholderText = options.PlaceholderText or "Nhập text..."
            textbox.TextColor3 = UILib.CurrentTheme.Text
            textbox.PlaceholderColor3 = UILib.CurrentTheme.TextSecondary
            textbox.TextSize = 14
            textbox.Font = Enum.Font.Gotham
            textbox.ClearTextOnFocus = false
            
            textbox.FocusLost:Connect(function(enterPressed)
                if options.Callback then
                    options.Callback(textbox.Text)
                end
            end)
            
            local textboxObj = {}
            function textboxObj:Set(value)
                textbox.Text = tostring(value)
            end
            function textboxObj:Get()
                return textbox.Text
            end
            
            return textboxObj
        end
        
        -- Add Slider
        function SectionObj:AddSlider(name, options)
            options = options or {}
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = "Slider"
            sliderFrame.Parent = self.Section
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.Size = UDim2.new(1, -20, 0, 50)
            sliderFrame.Position = UDim2.new(0, 10, 0, 0)
            
            local sliderLabel = CreateLabel(sliderFrame, options.Title or "Slider", 14)
            sliderLabel.Position = UDim2.new(0, 0, 0, 0)
            
            local valueLabel = CreateLabel(sliderFrame, tostring(options.Default or 50), 14)
            valueLabel.Position = UDim2.new(1, -50, 0, 0)
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Name = "Track"
            sliderTrack.Parent = sliderFrame
            sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            sliderTrack.Size = UDim2.new(1, 0, 0, 5)
            sliderTrack.Position = UDim2.new(0, 0, 0, 25)
            sliderTrack.BorderSizePixel = 0
            CreateCorner(2).Parent = sliderTrack
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "Fill"
            sliderFill.Parent = sliderTrack
            sliderFill.BackgroundColor3 = UILib.CurrentTheme.Accent
            sliderFill.Size = UDim2.new(0, 0, 1, 0)
            sliderFill.Position = UDim2.new(0, 0, 0, 0)
            sliderFill.BorderSizePixel = 0
            CreateCorner(2).Parent = sliderFill
            
            local sliderButton = Instance.new("TextButton")
            sliderButton.Name = "Button"
            sliderButton.Parent = sliderTrack
            sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderButton.Size = UDim2.new(0, 15, 0, 15)
            sliderButton.Position = UDim2.new(0, -7.5, 0, -5)
            sliderButton.Text = ""
            sliderButton.BorderSizePixel = 0
            CreateCorner(7).Parent = sliderButton
            
            local min = options.Min or 0
            local max = options.Max or 100
            local rounding = options.Rounding or 0
            local currentValue = options.Default or 50
            local isDragging = false
            
            local function updateSlider(value)
                currentValue = math.clamp(value, min, max)
                if rounding > 0 then
                    currentValue = math.floor((currentValue / rounding) + 0.5) * rounding
                end
                local percentage = (currentValue - min) / (max - min)
                sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                sliderButton.Position = UDim2.new(percentage, -7.5, 0, -5)
                valueLabel.Text = tostring(currentValue)
                if options.Callback then
                    options.Callback(currentValue)
                end
            end
            
            updateSlider(currentValue)
            
            sliderButton.MouseButton1Down:Connect(function()
                isDragging = true
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mouseX = input.Position.X
                    local trackAbsolutePos = sliderTrack.AbsolutePosition.X
                    local trackAbsoluteSize = sliderTrack.AbsoluteSize.X
                    local relativeX = math.clamp(mouseX - trackAbsolutePos, 0, trackAbsoluteSize)
                    local percentage = relativeX / trackAbsoluteSize
                    local value = min + (max - min) * percentage
                    updateSlider(value)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)
            
            local sliderObj = {}
            function sliderObj:Set(value)
                updateSlider(value)
            end
            function sliderObj:Get()
                return currentValue
            end
            
            return sliderObj
        end
        
        -- Add Label
        function SectionObj:AddLabel(text)
            local label = CreateLabel(self.Section, text, 14)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.TextColor3 = UILib.CurrentTheme.TextSecondary
            return label
        end
        
        -- Update Section Size
        SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Section.Size = UDim2.new(1, -20, 0, SectionLayout.AbsoluteContentSize.Y + 20)
        end)
        
        return SectionObj
    end
    
    return WindowObj
end

-- ============================================
-- Example Usage
-- ============================================

local Window = UILib:CreateWindow({
    Title = "My Custom UI",
    Size = UDim2.new(0, 500, 0, 500),
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainSection = Window:AddSection("Main Functions")

-- Button Example
MainSection:AddButton({
    Title = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})

-- Toggle Example
local Toggle = MainSection:AddToggle("MyToggle", {
    Title = "Enable Feature",
    Default = false,
    Callback = function(value)
        print("Toggle:", value)
    end
})

-- Dropdown Example
local Dropdown = MainSection:AddDropdown("MyDropdown", {
    Values = {"Option 1", "Option 2", "Option 3", "Option 4"},
    Default = "Option 1",
    Callback = function(value)
        print("Selected:", value)
    end
})

-- TextBox Example
local TextBox = MainSection:AddTextBox("MyTextBox", {
    PlaceholderText = "Nhập text...",
    Default = "",
    Callback = function(value)
        print("Text:", value)
    end
})

-- Slider Example
local Slider = MainSection:AddSlider("MySlider", {
    Title = "Slider Value",
    Min = 0,
    Max = 100,
    Default = 50,
    Rounding = 1,
    Callback = function(value)
        print("Slider:", value)
    end
})

-- Label Example
MainSection:AddLabel("Đây là một label mô tả")

print("Custom UI Library đã tải thành công!")
print("Sử dụng Left Ctrl để thu nhỏ/mở rộng UI")
