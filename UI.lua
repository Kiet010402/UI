-- ============================================
-- UI Library - Sidebar Layout Design
-- ============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- UI Library Core
-- ============================================

local UILib = {}

-- Colors
local SidebarColor = Color3.fromRGB(180, 160, 220) -- Light purple
local BackgroundColor = Color3.fromRGB(35, 35, 40) -- Dark grey
local SecondaryColor = Color3.fromRGB(45, 45, 50)
local AccentColor = Color3.fromRGB(150, 120, 200) -- Purple accent
local TextColor = Color3.fromRGB(255, 255, 255)
local TextSecondary = Color3.fromRGB(200, 200, 200)

-- Helper Functions
local function CreateCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

local function CreateStroke(color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(60, 60, 60)
    stroke.Thickness = thickness or 1
    stroke.Transparency = 0.5
    return stroke
end

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

-- ============================================
-- Window Creation
-- ============================================

function UILib:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Hub"
    local version = options.Version or "v1.0.0"
    local size = options.Size or UDim2.new(0, 900, 0, 600)
    
    local ScreenGui = CreateScreenGui()
    
    -- Main Window
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Parent = ScreenGui
    Window.BackgroundColor3 = BackgroundColor
    Window.Size = size
    Window.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    Window.BorderSizePixel = 0
    CreateCorner(10).Parent = Window
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = Window
    TopBar.BackgroundColor3 = SecondaryColor
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BorderSizePixel = 0
    CreateCorner(10).Parent = TopBar
    
    -- Title and Version
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TopBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title .. " " .. version
    TitleLabel.TextColor3 = TextColor
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.Gotham
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Current Tab Label
    local TabLabel = Instance.new("TextLabel")
    TabLabel.Name = "TabLabel"
    TabLabel.Parent = TopBar
    TabLabel.BackgroundTransparency = 1
    TabLabel.Text = "Main"
    TabLabel.TextColor3 = TextColor
    TabLabel.TextSize = 14
    TabLabel.Font = Enum.Font.Gotham
    TabLabel.Size = UDim2.new(0, 100, 1, 0)
    TabLabel.Position = UDim2.new(0, 220, 0, 0)
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Icon (placeholder)
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Parent = TopBar
    Icon.BackgroundTransparency = 1
    Icon.Size = UDim2.new(0, 30, 0, 30)
    Icon.Position = UDim2.new(0.5, -15, 0, 7.5)
    Icon.Image = "rbxassetid://13311802307" -- Default icon
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TopBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 7.5)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = TextColor
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CreateCorner(6).Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Drag Functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TopBar.InputBegan:Connect(function(input)
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
    
    -- Sidebar
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Window
    Sidebar.BackgroundColor3 = SidebarColor
    Sidebar.Size = UDim2.new(0, 180, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 6
    Sidebar.ScrollBarImageColor3 = AccentColor
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Parent = Sidebar
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Content Area
    local ContentArea = Instance.new("ScrollingFrame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = Window
    ContentArea.BackgroundTransparency = 1
    ContentArea.Size = UDim2.new(1, -180, 1, -45)
    ContentArea.Position = UDim2.new(0, 180, 0, 45)
    ContentArea.BorderSizePixel = 0
    ContentArea.ScrollBarThickness = 6
    ContentArea.ScrollBarImageColor3 = AccentColor
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local ContentLayout = Instance.new("UIGridLayout")
    ContentLayout.Parent = ContentArea
    ContentLayout.CellSize = UDim2.new(0, 340, 0, 0)
    ContentLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Update Canvas Sizes
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10)
    end)
    
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Window Object
    local WindowObj = {}
    WindowObj.Window = Window
    WindowObj.Sidebar = Sidebar
    WindowObj.ContentArea = ContentArea
    WindowObj.TabLabel = TabLabel
    WindowObj.ScreenGui = ScreenGui
    WindowObj.Tabs = {}
    WindowObj.CurrentTab = nil
    
    -- Add Tab Method
    function WindowObj:AddTab(options)
        options = options or {}
        local tabName = options.Title or "Tab"
        local tabIcon = options.Icon or "rbxassetid://13311802307"
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.Parent = self.Sidebar
        TabButton.BackgroundColor3 = SidebarColor
        TabButton.Size = UDim2.new(1, -10, 0, 40)
        TabButton.Position = UDim2.new(0, 5, 0, 0)
        TabButton.Text = ""
        TabButton.BorderSizePixel = 0
        CreateCorner(6).Parent = TabButton
        
        -- Tab Icon
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Parent = TabButton
        TabIcon.BackgroundTransparency = 1
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Position = UDim2.new(0, 10, 0, 10)
        TabIcon.Image = tabIcon
        
        -- Tab Text
        local TabText = Instance.new("TextLabel")
        TabText.Parent = TabButton
        TabText.BackgroundTransparency = 1
        TabText.Text = tabName
        TabText.TextColor3 = TextColor
        TabText.TextSize = 13
        TabText.Font = Enum.Font.Gotham
        TabText.Size = UDim2.new(1, -40, 1, 0)
        TabText.Position = UDim2.new(0, 35, 0, 0)
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Tab Content Frame
        local TabContent = Instance.new("Frame")
        TabContent.Name = tabName .. "Content"
        TabContent.Parent = self.ContentArea
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(0, 340, 0, 0)
        TabContent.Visible = false
        
        local TabContentLayout = Instance.new("UIListLayout")
        TabContentLayout.Parent = TabContent
        TabContentLayout.Padding = UDim.new(0, 10)
        TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.Size = UDim2.new(0, 340, 0, TabContentLayout.AbsoluteContentSize.Y)
        end)
        
        -- Tab Selection
        local function SelectTab()
            if self.CurrentTab then
                self.CurrentTab.Content.Visible = false
                local oldBtn = self.Sidebar:FindFirstChild(self.CurrentTab.Name)
                if oldBtn then
                    TweenService:Create(oldBtn, TweenInfo.new(0.2), {BackgroundColor3 = SidebarColor}):Play()
                end
            end
            
            self.CurrentTab = {Name = tabName, Content = TabContent}
            TabContent.Visible = true
            self.TabLabel.Text = tabName
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = AccentColor}):Play()
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        -- Select first tab
        if not self.CurrentTab then
            SelectTab()
        end
        
        -- Tab Object
        local TabObj = {}
        TabObj.Content = TabContent
        TabObj.Layout = TabContentLayout
        
        -- Add Section
        function TabObj:AddSection(title)
            local Section = Instance.new("Frame")
            Section.Name = "Section"
            Section.Parent = self.Content
            Section.BackgroundColor3 = SecondaryColor
            Section.Size = UDim2.new(1, -20, 0, 0)
            Section.Position = UDim2.new(0, 10, 0, 0)
            Section.BorderSizePixel = 0
            CreateCorner(8).Parent = Section
            
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.Parent = Section
            SectionLayout.Padding = UDim.new(0, 8)
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            -- Section Title
            if title then
                local SectionTitle = Instance.new("TextLabel")
                SectionTitle.Parent = Section
                SectionTitle.BackgroundTransparency = 1
                SectionTitle.Text = title
                SectionTitle.TextColor3 = AccentColor
                SectionTitle.TextSize = 14
                SectionTitle.Font = Enum.Font.GothamBold
                SectionTitle.Size = UDim2.new(1, -20, 0, 25)
                SectionTitle.Position = UDim2.new(0, 10, 0, 5)
                SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            end
            
            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Size = UDim2.new(1, -20, 0, SectionLayout.AbsoluteContentSize.Y + 15)
            end)
            
            local SectionObj = {}
            SectionObj.Section = Section
            SectionObj.Layout = SectionLayout
            
            -- Add Dropdown
            function SectionObj:AddDropdown(name, options)
                options = options or {}
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = "Dropdown"
                dropdownFrame.Parent = self.Section
                dropdownFrame.BackgroundColor3 = BackgroundColor
                dropdownFrame.Size = UDim2.new(1, -20, 0, 30)
                dropdownFrame.Position = UDim2.new(0, 10, 0, 0)
                dropdownFrame.BorderSizePixel = 0
                CreateCorner(6).Parent = dropdownFrame
                
                local label = Instance.new("TextLabel")
                label.Parent = dropdownFrame
                label.BackgroundTransparency = 1
                label.Text = options.Title or name
                label.TextColor3 = TextSecondary
                label.TextSize = 12
                label.Font = Enum.Font.Gotham
                label.Size = UDim2.new(0, 80, 1, 0)
                label.Position = UDim2.new(0, 8, 0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Name = "Button"
                dropdownButton.Parent = dropdownFrame
                dropdownButton.BackgroundColor3 = SecondaryColor
                dropdownButton.Size = UDim2.new(1, -100, 0, 25)
                dropdownButton.Position = UDim2.new(0, 90, 0, 2.5)
                dropdownButton.Text = options.Default or (options.Values and options.Values[1]) or "Select"
                dropdownButton.TextColor3 = TextColor
                dropdownButton.TextSize = 12
                dropdownButton.Font = Enum.Font.Gotham
                dropdownButton.BorderSizePixel = 0
                CreateCorner(4).Parent = dropdownButton
                
                local dropdownList = Instance.new("Frame")
                dropdownList.Name = "List"
                dropdownList.Parent = dropdownFrame
                dropdownList.BackgroundColor3 = SecondaryColor
                dropdownList.Size = UDim2.new(1, -100, 0, 0)
                dropdownList.Position = UDim2.new(0, 90, 1, 5)
                dropdownList.BorderSizePixel = 0
                dropdownList.Visible = false
                dropdownList.ClipsDescendants = true
                CreateCorner(4).Parent = dropdownList
                
                local listLayout = Instance.new("UIListLayout")
                listLayout.Parent = dropdownList
                
                local isOpen = false
                local selectedValue = options.Default or (options.Values and options.Values[1])
                
                local function updateList()
                    dropdownList:ClearAllChildren()
                    listLayout.Parent = dropdownList
                    
                    if options.Values then
                        for i, value in ipairs(options.Values) do
                            local option = Instance.new("TextButton")
                            option.Parent = dropdownList
                            option.BackgroundColor3 = BackgroundColor
                            option.Size = UDim2.new(1, -10, 0, 25)
                            option.Position = UDim2.new(0, 5, 0, 0)
                            option.Text = tostring(value)
                            option.TextColor3 = TextColor
                            option.TextSize = 12
                            option.Font = Enum.Font.Gotham
                            option.BorderSizePixel = 0
                            CreateCorner(4).Parent = option
                            
                            option.MouseButton1Click:Connect(function()
                                selectedValue = value
                                dropdownButton.Text = tostring(value)
                                isOpen = false
                                dropdownList.Visible = false
                                TweenService:Create(dropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, -100, 0, 0)}):Play()
                                if options.Callback then
                                    options.Callback(value)
                                end
                            end)
                        end
                        
                        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                            if isOpen then
                                dropdownList.Size = UDim2.new(1, -100, 0, math.min(listLayout.AbsoluteContentSize.Y, 120))
                            end
                        end)
                    end
                end
                
                updateList()
                
                dropdownButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    dropdownList.Visible = isOpen
                    if isOpen then
                        TweenService:Create(dropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, -100, 0, math.min(listLayout.AbsoluteContentSize.Y, 120))}):Play()
                    else
                        TweenService:Create(dropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, -100, 0, 0)}):Play()
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
            
            -- Add Toggle
            function SectionObj:AddToggle(name, options)
                options = options or {}
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = "Toggle"
                toggleFrame.Parent = self.Section
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Size = UDim2.new(1, -20, 0, 25)
                toggleFrame.Position = UDim2.new(0, 10, 0, 0)
                
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Parent = toggleFrame
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = options.Title or name
                toggleLabel.TextColor3 = TextColor
                toggleLabel.TextSize = 13
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.Size = UDim2.new(1, -60, 1, 0)
                toggleLabel.Position = UDim2.new(0, 0, 0, 0)
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local toggle = Instance.new("TextButton")
                toggle.Name = "ToggleButton"
                toggle.Parent = toggleFrame
                toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                toggle.Size = UDim2.new(0, 40, 0, 20)
                toggle.Position = UDim2.new(1, -40, 0, 2.5)
                toggle.Text = ""
                toggle.BorderSizePixel = 0
                CreateCorner(10).Parent = toggle
                
                local toggleIndicator = Instance.new("Frame")
                toggleIndicator.Name = "Indicator"
                toggleIndicator.Parent = toggle
                toggleIndicator.BackgroundColor3 = AccentColor
                toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
                toggleIndicator.Position = UDim2.new(0, 2, 0, 2)
                toggleIndicator.BorderSizePixel = 0
                CreateCorner(8).Parent = toggleIndicator
                
                local isToggled = options.Default or false
                
                local function updateToggle()
                    if isToggled then
                        TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 22, 0, 2)}):Play()
                        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = AccentColor}):Play()
                    else
                        TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
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
            
            -- Add Button
            function SectionObj:AddButton(options)
                options = options or {}
                local button = Instance.new("TextButton")
                button.Name = "Button"
                button.Parent = self.Section
                button.BackgroundColor3 = AccentColor
                button.Size = UDim2.new(1, -20, 0, 35)
                button.Position = UDim2.new(0, 10, 0, 0)
                button.Text = options.Title or "Button"
                button.TextColor3 = TextColor
                button.TextSize = 13
                button.Font = Enum.Font.Gotham
                button.BorderSizePixel = 0
                CreateCorner(6).Parent = button
                
                if options.Icon then
                    local icon = Instance.new("ImageLabel")
                    icon.Parent = button
                    icon.BackgroundTransparency = 1
                    icon.Size = UDim2.new(0, 20, 0, 20)
                    icon.Position = UDim2.new(0, 10, 0, 7.5)
                    icon.Image = options.Icon
                end
                
                button.MouseButton1Click:Connect(function()
                    if options.Callback then
                        options.Callback()
                    end
                end)
                
                return button
            end
            
            -- Add Slider
            function SectionObj:AddSlider(name, options)
                options = options or {}
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = "Slider"
                sliderFrame.Parent = self.Section
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Size = UDim2.new(1, -20, 0, 40)
                sliderFrame.Position = UDim2.new(0, 10, 0, 0)
                
                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Parent = sliderFrame
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = options.Title or name
                sliderLabel.TextColor3 = TextColor
                sliderLabel.TextSize = 13
                sliderLabel.Font = Enum.Font.Gotham
                sliderLabel.Size = UDim2.new(1, -80, 0, 20)
                sliderLabel.Position = UDim2.new(0, 0, 0, 0)
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Parent = sliderFrame
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(options.Default or 50) .. (options.Suffix or "")
                valueLabel.TextColor3 = TextSecondary
                valueLabel.TextSize = 12
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.Size = UDim2.new(0, 80, 0, 20)
                valueLabel.Position = UDim2.new(1, -80, 0, 0)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                
                local sliderTrack = Instance.new("Frame")
                sliderTrack.Name = "Track"
                sliderTrack.Parent = sliderFrame
                sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                sliderTrack.Size = UDim2.new(1, 0, 0, 4)
                sliderTrack.Position = UDim2.new(0, 0, 0, 22)
                sliderTrack.BorderSizePixel = 0
                CreateCorner(2).Parent = sliderTrack
                
                local sliderFill = Instance.new("Frame")
                sliderFill.Name = "Fill"
                sliderFill.Parent = sliderTrack
                sliderFill.BackgroundColor3 = AccentColor
                sliderFill.Size = UDim2.new(0, 0, 1, 0)
                sliderFill.Position = UDim2.new(0, 0, 0, 0)
                sliderFill.BorderSizePixel = 0
                CreateCorner(2).Parent = sliderFill
                
                local sliderButton = Instance.new("TextButton")
                sliderButton.Name = "Button"
                sliderButton.Parent = sliderTrack
                sliderButton.BackgroundColor3 = TextColor
                sliderButton.Size = UDim2.new(0, 12, 0, 12)
                sliderButton.Position = UDim2.new(0, -6, 0, -4)
                sliderButton.Text = ""
                sliderButton.BorderSizePixel = 0
                CreateCorner(6).Parent = sliderButton
                
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
                    sliderButton.Position = UDim2.new(percentage, -6, 0, -4)
                    valueLabel.Text = tostring(currentValue) .. (options.Suffix or "")
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
            
            -- Add Number Input
            function SectionObj:AddNumberInput(name, options)
                options = options or {}
                local inputFrame = Instance.new("Frame")
                inputFrame.Name = "NumberInput"
                inputFrame.Parent = self.Section
                inputFrame.BackgroundColor3 = BackgroundColor
                inputFrame.Size = UDim2.new(1, -20, 0, 30)
                inputFrame.Position = UDim2.new(0, 10, 0, 0)
                inputFrame.BorderSizePixel = 0
                CreateCorner(6).Parent = inputFrame
                
                local label = Instance.new("TextLabel")
                label.Parent = inputFrame
                label.BackgroundTransparency = 1
                label.Text = options.Title or name
                label.TextColor3 = TextSecondary
                label.TextSize = 12
                label.Font = Enum.Font.Gotham
                label.Size = UDim2.new(0, 80, 1, 0)
                label.Position = UDim2.new(0, 8, 0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                
                local textbox = Instance.new("TextBox")
                textbox.Parent = inputFrame
                textbox.BackgroundColor3 = SecondaryColor
                textbox.Size = UDim2.new(0, 60, 0, 22)
                textbox.Position = UDim2.new(0, 90, 0, 4)
                textbox.Text = tostring(options.Default or 1)
                textbox.TextColor3 = TextColor
                textbox.TextSize = 12
                textbox.Font = Enum.Font.Gotham
                textbox.BorderSizePixel = 0
                CreateCorner(4).Parent = textbox
                
                local upBtn = Instance.new("TextButton")
                upBtn.Parent = inputFrame
                upBtn.BackgroundColor3 = AccentColor
                upBtn.Size = UDim2.new(0, 20, 0, 10)
                upBtn.Position = UDim2.new(0, 155, 0, 4)
                upBtn.Text = "▲"
                upBtn.TextColor3 = TextColor
                upBtn.TextSize = 8
                upBtn.Font = Enum.Font.Gotham
                upBtn.BorderSizePixel = 0
                CreateCorner(2).Parent = upBtn
                
                local downBtn = Instance.new("TextButton")
                downBtn.Parent = inputFrame
                downBtn.BackgroundColor3 = AccentColor
                downBtn.Size = UDim2.new(0, 20, 0, 10)
                downBtn.Position = UDim2.new(0, 155, 0, 14)
                downBtn.Text = "▼"
                downBtn.TextColor3 = TextColor
                downBtn.TextSize = 8
                downBtn.Font = Enum.Font.Gotham
                downBtn.BorderSizePixel = 0
                CreateCorner(2).Parent = downBtn
                
                local currentValue = options.Default or 1
                local min = options.Min or 0
                local max = options.Max or 999
                
                local function updateValue(value)
                    currentValue = math.clamp(value, min, max)
                    textbox.Text = tostring(currentValue)
                    if options.Callback then
                        options.Callback(currentValue)
                    end
                end
                
                upBtn.MouseButton1Click:Connect(function()
                    updateValue(currentValue + 1)
                end)
                
                downBtn.MouseButton1Click:Connect(function()
                    updateValue(currentValue - 1)
                end)
                
                textbox.FocusLost:Connect(function()
                    local num = tonumber(textbox.Text)
                    if num then
                        updateValue(num)
                    else
                        textbox.Text = tostring(currentValue)
                    end
                end)
                
                local inputObj = {}
                function inputObj:Set(value)
                    updateValue(value)
                end
                function inputObj:Get()
                    return currentValue
                end
                
                return inputObj
            end
            
            return SectionObj
        end
        
        return TabObj
    end
    
    return WindowObj
end

-- ============================================
-- Example Usage
-- ============================================

local Window = UILib:CreateWindow({
    Title = "buanghub",
    Version = "v1.1.1.1",
    Size = UDim2.new(0, 900, 0, 600)
})

-- Add Tabs
local MainTab = Window:AddTab({
    Title = "Main",
    Icon = "rbxassetid://13311802307" -- House icon
})

local FarmTab = Window:AddTab({
    Title = "Farm",
    Icon = "rbxassetid://13311798537" -- Monitor icon
})

-- Main Tab Sections
local AutoJoinSection = MainTab:AddSection("Auto Join")
AutoJoinSection:AddDropdown("Mode", {
    Title = "Mode",
    Values = {"ElementalCaverns", "Normal", "Hard"},
    Default = "ElementalCaverns",
    Callback = function(value)
        print("Mode:", value)
    end
})

AutoJoinSection:AddDropdown("Map", {
    Title = "Map",
    Values = {"Water", "Fire", "Earth", "Air"},
    Default = "Water",
    Callback = function(value)
        print("Map:", value)
    end
})

AutoJoinSection:AddNumberInput("Act", {
    Title = "Act",
    Default = 1,
    Min = 1,
    Max = 10,
    Callback = function(value)
        print("Act:", value)
    end
})

AutoJoinSection:AddDropdown("Difficulty", {
    Title = "Difficulty",
    Values = {"Normal", "Hard", "Extreme"},
    Default = "Normal",
    Callback = function(value)
        print("Difficulty:", value)
    end
})

AutoJoinSection:AddToggle("FriendsOnly", {
    Title = "Friends Only",
    Default = false,
    Callback = function(value)
        print("Friends Only:", value)
    end
})

AutoJoinSection:AddToggle("AutoJoinMap", {
    Title = "Auto Join Map",
    Default = false,
    Callback = function(value)
        print("Auto Join Map:", value)
    end
})

local MainSettingsSection = MainTab:AddSection("Main Settings")
MainSettingsSection:AddToggle("AutoLeave", {
    Title = "Auto Leave",
    Default = false,
    Callback = function(value)
        print("Auto Leave:", value)
    end
})

MainSettingsSection:AddToggle("AutoReplay", {
    Title = "Auto Replay",
    Default = false,
    Callback = function(value)
        print("Auto Replay:", value)
    end
})

MainSettingsSection:AddToggle("AutoNext", {
    Title = "Auto Next",
    Default = false,
    Callback = function(value)
        print("Auto Next:", value)
    end
})

MainSettingsSection:AddToggle("AutoGameSpeed", {
    Title = "Auto Game Speed",
    Default = false,
    Callback = function(value)
        print("Auto Game Speed:", value)
    end
})

MainSettingsSection:AddToggle("AutoGameReady", {
    Title = "Auto Game Ready",
    Default = false,
    Callback = function(value)
        print("Auto Game Ready:", value)
    end
})

MainSettingsSection:AddToggle("DeleteMap", {
    Title = "Delete Map",
    Default = false,
    Callback = function(value)
        print("Delete Map:", value)
    end
})

MainSettingsSection:AddButton({
    Title = "Teleport to Lobby",
    Icon = "rbxassetid://13311802307",
    Callback = function()
        print("Teleport to Lobby clicked!")
    end
})

MainSettingsSection:AddSlider("TPDelay", {
    Title = "TP Delay",
    Min = 0,
    Max = 60,
    Default = 16.3,
    Rounding = 0.1,
    Suffix = " seconds",
    Callback = function(value)
        print("TP Delay:", value)
    end
})

MainSettingsSection:AddSlider("AutoRestartMatch", {
    Title = "Auto Restart Match",
    Min = 0,
    Max = 500,
    Default = 200,
    Rounding = 1,
    Suffix = " Matches",
    Callback = function(value)
        print("Auto Restart Match:", value)
    end
})

MainSettingsSection:AddToggle("AutoRestartEnabled", {
    Title = "Auto Restart Enabled",
    Default = false,
    Callback = function(value)
        print("Auto Restart Enabled:", value)
    end
})

MainSettingsSection:AddSlider("AutoLobbyTime", {
    Title = "Auto Lobby Time",
    Min = 0,
    Max = 60,
    Default = 0,
    Rounding = 1,
    Suffix = " mins",
    Callback = function(value)
        print("Auto Lobby Time:", value)
    end
})

MainSettingsSection:AddToggle("AutoTPLobby", {
    Title = "Auto TP Lobby",
    Default = false,
    Callback = function(value)
        print("Auto TP Lobby:", value)
    end
})

local AutoStartSection = MainTab:AddSection("Auto Start")
AutoStartSection:AddSlider("StartDelay", {
    Title = "Start Delay",
    Min = 0,
    Max = 10,
    Default = 1.5,
    Rounding = 0.1,
    Suffix = " seconds",
    Callback = function(value)
        print("Start Delay:", value)
    end
})

AutoStartSection:AddToggle("AutoStart", {
    Title = "Auto Start",
    Default = false,
    Callback = function(value)
        print("Auto Start:", value)
    end
})

print("UI Library đã tải thành công!")
