--// Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

--// Load UI Library (MacLib)
local MacLib = nil
local success, err = pcall(function()
    MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()
end)

if not success or not MacLib then
    warn("Lỗi khi tải UI Library (MacLib): " .. tostring(err))
    return
end

--// Config System (tương tự UI.lua, rút gọn cho TheForge)
local ConfigSystem = {}
ConfigSystem.FileName = "TheForgeConfig_" .. Players.LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    SelectedRockType = nil,
    AutoMineEnabled = false,
}
ConfigSystem.CurrentConfig = {}

ConfigSystem.SaveConfig = function()
    local ok, saveErr = pcall(function()
        writefile(ConfigSystem.FileName, HttpService:JSONEncode(ConfigSystem.CurrentConfig))
    end)
    if not ok then
        warn("Lưu cấu hình thất bại:", saveErr)
    end
end

ConfigSystem.LoadConfig = function()
    local ok, content = pcall(function()
        if isfile and isfile(ConfigSystem.FileName) then
            return readfile(ConfigSystem.FileName)
        end
        return nil
    end)

    if ok and content then
        local data = HttpService:JSONDecode(content)
        ConfigSystem.CurrentConfig = data
    else
        ConfigSystem.CurrentConfig = table.clone(ConfigSystem.DefaultConfig)
        ConfigSystem.SaveConfig()
    end
end

ConfigSystem.LoadConfig()

--// UI Window
local playerName = Players.LocalPlayer.Name

local Window = MacLib:Window({
    Title = "DuongTuan Hub",
    Subtitle = "Xin chào, " .. playerName,
    Size = UDim2.fromOffset(720, 500),
    DragStyle = 1,
    DisabledWindowControls = {},
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.LeftAlt,
    AcrylicBlur = true,
})

local function notify(title, desc, duration)
    if Window and Window.Notify then
        Window:Notify({
            Title = title or Window.Settings.Title,
            Description = desc or "",
            Lifetime = duration or 4
        })
    else
        print("[Notify]", tostring(title), tostring(desc))
    end
end

MacLib:SetFolder("DuongTuanHub")

--// Tabs
local tabGroup = Window:TabGroup()
local tabs = {
    Farm = tabGroup:Tab({ Name = "Farm", Image = "rbxassetid://10734923549" }),
    Settings = tabGroup:Tab({ Name = "Settings", Image = "rbxassetid://10734950309" }),
}

--// Mine state
local autoMineEnabled = ConfigSystem.CurrentConfig.AutoMineEnabled
if type(autoMineEnabled) ~= "boolean" then
    autoMineEnabled = ConfigSystem.DefaultConfig.AutoMineEnabled
end

local selectedRockType = ConfigSystem.CurrentConfig.SelectedRockType
local rockTypes = {}
local rockTypeDropdown = nil

--// Sections
local sections = {
    Farm = tabs.Farm:Section({ Side = "Left" }),
    SettingsInfo = tabs.Settings:Section({ Side = "Left" }),
}

--// FARM TAB
sections.Farm:Header({ Name = "Mine" })

local function getDefaultOption(list, target)
    if not list or #list == 0 then
        return nil
    end
    if not target then
        return list[1]
    end
    for _, name in ipairs(list) do
        if name == target then
            return name
        end
    end
    return list[1]
end

local function scanRockTypes()
    rockTypes = {}
    local seen = {}

    local rocksRoot = workspace:FindFirstChild("Rocks")
    if not rocksRoot then
        return rockTypes
    end

    for _, inst in ipairs(rocksRoot:GetDescendants()) do
        if inst:IsA("BasePart") then
            local model = inst:FindFirstAncestorWhichIsA("Model")
            if model and typeof(model.Name) == "string" and model.Name ~= "" then
                local name = model.Name
                -- Loại bỏ tên toàn số và các tên không cần: "Workspace", "Ore"
                local lower = name:lower()
                if not name:match("^%d+$") and lower ~= "workspace" and lower ~= "ore" then
                    if not seen[name] then
                        seen[name] = true
                        table.insert(rockTypes, name)
                    end
                end
            end
        end
    end

    table.sort(rockTypes)

    return rockTypes
end

local function getRockPartsByType(typeName)
    local result = {}

    if not typeName or typeName == "" then
        return result
    end

    local rocksRoot = workspace:FindFirstChild("Rocks")
    if not rocksRoot then
        return result
    end

    for _, inst in ipairs(rocksRoot:GetDescendants()) do
        if inst:IsA("BasePart") then
            local model = inst:FindFirstAncestorWhichIsA("Model")
            if model and model.Name == typeName then
                table.insert(result, inst)
            end
        end
    end

    return result
end

local function getClosestRockPartByType(typeName)
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then
        return nil
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return nil
    end

    local parts = getRockPartsByType(typeName)
    local closestPart = nil
    local closestDist = math.huge

    for _, part in ipairs(parts) do
        if part and part.Parent then
            local dist = (hrp.Position - part.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPart = part
            end
        end
    end

    return closestPart
end

local function tweenToMineTarget(targetPart)
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then
        return false
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart or not targetPart.Parent then
        return false
    end

    local targetPos = targetPart.Position + Vector3.new(0, 3, 0)
    local distance = (hrp.Position - targetPos).Magnitude
    -- Giảm tốc độ tween lại để tránh anti-tp (di chuyển chậm hơn, tự nhiên hơn)
    local time = math.clamp(distance / 25, 0.4, 4)

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        { CFrame = CFrame.new(targetPos, targetPart.Position) }
    )

    tween:Play()
    tween.Completed:Wait()

    return true
end

local function swingPickaxeUntilMinedType(targetPart, typeName)
    if not targetPart or not typeName or typeName == "" then
        return
    end

    local model = targetPart:FindFirstAncestorWhichIsA("Model")
    if not model or model.Name ~= typeName then
        return
    end

    local args = { "Pickaxe" }
    local toolRF = game:GetService("ReplicatedStorage")
        :WaitForChild("Shared")
        :WaitForChild("Packages")
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("ToolService")
        :WaitForChild("RF")
        :WaitForChild("ToolActivated")

    while autoMineEnabled do
        if not model or not model.Parent then
            break
        end
        pcall(function()
            toolRF:InvokeServer(unpack(args))
        end)
        task.wait(0.15)
    end
end

rockTypes = scanRockTypes()

rockTypeDropdown = sections.Farm:Dropdown({
    Name = "Select Rock",
    Multi = false,
    Required = false,
    Options = rockTypes,
    Default = getDefaultOption(rockTypes, selectedRockType),
    Callback = function(value)
        if typeof(value) == "table" then
            for name, state in pairs(value) do
                if state then
                    value = name
                    break
                end
            end
        end

        if not value or value == "" then
            selectedRockType = nil
            ConfigSystem.CurrentConfig.SelectedRockType = nil
        else
            selectedRockType = value
            ConfigSystem.CurrentConfig.SelectedRockType = value
            notify("Mine", "Đã chọn loại đá: " .. tostring(value), 3)
        end

        ConfigSystem.SaveConfig()
    end,
}, "SelectRockDropdown")

-- Đảm bảo hiển thị lại lựa chọn đã lưu khi mở script
if selectedRockType and rockTypeDropdown and rockTypeDropdown.UpdateSelection then
    for _, name in ipairs(rockTypes) do
        if name == selectedRockType then
            rockTypeDropdown:UpdateSelection(selectedRockType)
            break
        end
    end
end

sections.Farm:Button({
    Name = "Refresh Rock List",
    Callback = function()
        local list = scanRockTypes()
        if rockTypeDropdown then
            if rockTypeDropdown.ClearOptions then
                rockTypeDropdown:ClearOptions()
            end
            if rockTypeDropdown.InsertOptions then
                rockTypeDropdown:InsertOptions(list)
            end
            if selectedRockType and rockTypeDropdown.UpdateSelection then
                rockTypeDropdown:UpdateSelection(selectedRockType)
            end
        end
        notify("Mine", "Đã cập nhật danh sách đá.", 3)
    end,
}, "RefreshRockListButton")

sections.Farm:Toggle({
    Name = "Auto Mine",
    Default = autoMineEnabled,
    Callback = function(value)
        autoMineEnabled = value
        ConfigSystem.CurrentConfig.AutoMineEnabled = value
        ConfigSystem.SaveConfig()

        if value then
            if not selectedRockType then
                notify("Mine", "Chưa chọn loại đá! Hãy chọn ở dropdown.", 4)
            else
                notify("Mine", "Đã bật Auto Mine cho: " .. tostring(selectedRockType), 3)
            end
        else
            notify("Mine", "Đã tắt Auto Mine", 3)
        end
    end,
}, "AutoMineToggle")

task.spawn(function()
    while task.wait(0.3) do
        if autoMineEnabled and selectedRockType then
            local target = getClosestRockPartByType(selectedRockType)
            if target then
                tweenToMineTarget(target)
                swingPickaxeUntilMinedType(target, selectedRockType)
            end
        end
    end
end)

-- Tab Settings: thông tin cơ bản
sections.SettingsInfo:Header({ Name = "Thông tin Script" })
sections.SettingsInfo:Label({
    Text = "The Forge Script\nNgười chơi: " .. playerName
})

sections.SettingsInfo:Button({
    Name = "Copy Player Name",
    Callback = function()
        if setclipboard then
            setclipboard(playerName)
            notify("Thông báo", "Đã sao chép tên người chơi.", 3)
        else
            notify("Thông báo", playerName, 3)
        end
    end,
}, "CopyPlayerNameButton")

sections.SettingsInfo:SubLabel({
    Text = "Phím tắt: Left Alt (hoặc icon mobile) để ẩn/hiện UI"
})

-- Global settings giống style UI.lua
local globalSettings = {
    UIBlurToggle = Window:GlobalSetting({
        Name = "UI Blur",
        Default = Window:GetAcrylicBlurState(),
        Callback = function(bool)
            Window:SetAcrylicBlurState(bool)
            notify(Window.Settings.Title, (bool and "Enabled" or "Disabled") .. " UI Blur", 4)
        end,
    }),
    NotificationToggle = Window:GlobalSetting({
        Name = "Notifications",
        Default = Window:GetNotificationsState(),
        Callback = function(bool)
            Window:SetNotificationsState(bool)
            notify(Window.Settings.Title, (bool and "Enabled" or "Disabled") .. " Notifications", 4)
        end,
    }),
    UserInfoToggle = Window:GlobalSetting({
        Name = "Show User Info",
        Default = Window:GetUserInfoState(),
        Callback = function(bool)
            Window:SetUserInfoState(bool)
            notify(Window.Settings.Title, (bool and "Showing" or "Redacted") .. " User Info", 4)
        end,
    })
}

tabs.Farm:Select()

Window.onUnloaded(function()
    notify("DuongTuan Hub", "UI đã được đóng.", 3)
end)

MacLib:LoadAutoLoadConfig()

-- Auto save config đơn giản (5s/lần)
task.spawn(function()
    while task.wait(5) do
        pcall(ConfigSystem.SaveConfig)
    end
end)

-- Tạo icon floating để giả lập nút Left Alt cho mobile (copy style từ UI.lua)
task.spawn(function()
    local ok, errorMsg = pcall(function()
        if not getgenv().LoadedTheForgeMobileUI == true then
            getgenv().LoadedTheForgeMobileUI = true
            local OpenUI = Instance.new("ScreenGui")
            local ImageButton = Instance.new("ImageButton")
            local UICorner = Instance.new("UICorner")

            if syn and syn.protect_gui then
                syn.protect_gui(OpenUI)
                OpenUI.Parent = game:GetService("CoreGui")
            elseif gethui then
                OpenUI.Parent = gethui()
            else
                OpenUI.Parent = game:GetService("CoreGui")
            end

            OpenUI.Name = "TheForge_MobileUIButton"
            OpenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            OpenUI.ResetOnSpawn = false

            ImageButton.Parent = OpenUI
            ImageButton.BackgroundColor3 = Color3.fromRGB(105, 105, 105)
            ImageButton.BackgroundTransparency = 0.8
            ImageButton.Position = UDim2.new(0.9, 0, 0.1, 0)
            ImageButton.Size = UDim2.new(0, 50, 0, 50)
            ImageButton.Image = "rbxassetid://90319448802378"
            ImageButton.Draggable = true
            ImageButton.Transparency = 0.2

            UICorner.CornerRadius = UDim.new(0, 200)
            UICorner.Parent = ImageButton

            ImageButton.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(ImageButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.5,
                    Transparency = 0
                }):Play()
            end)

            ImageButton.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(ImageButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.8,
                    Transparency = 0.2
                }):Play()
            end)

            ImageButton.MouseButton1Click:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftAlt, false, game)
                task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.LeftAlt, false, game)
            end)
        end
    end)

    if not ok then
        warn("Lỗi khi tạo nút Mobile UI (DuongTuan Hub): " .. tostring(errorMsg))
    end
end)

notify("DuongTuan Hub", "Script đã tải thành công!\nNhấn Left Alt hoặc icon để ẩn/hiện UI", 5)
print("DuongTuan Hub.lua đã tải thành công!")
