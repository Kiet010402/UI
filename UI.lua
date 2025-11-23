-- Load UI Library với error handling
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not success then
    warn("Lỗi khi tải UI Library: " .. tostring(err))
    -- Thử tải từ URL dự phòng
    pcall(function()
        Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua"))()
        SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)
end

-- Đợi đến khi Fluent được tải hoàn tất
if not Fluent then
    warn("Không thể tải thư viện Fluent!")
    return
end

-- Hệ thống lưu trữ cấu hình
local ConfigSystem = {}
ConfigSystem.FileName = "ScriptConfig_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    SavedPosition = nil, -- Lưu tọa độ {X, Y, Z}
    AutoFishEnabled = false
}
ConfigSystem.CurrentConfig = {}

-- Hàm để lưu cấu hình
ConfigSystem.SaveConfig = function()
    local success, err = pcall(function()
        writefile(ConfigSystem.FileName, game:GetService("HttpService"):JSONEncode(ConfigSystem.CurrentConfig))
    end)
    if success then
        print("Đã lưu cấu hình thành công!")
    else
        warn("Lưu cấu hình thất bại:", err)
    end
end

-- Hàm để tải cấu hình
ConfigSystem.LoadConfig = function()
    local success, content = pcall(function()
        if isfile(ConfigSystem.FileName) then
            return readfile(ConfigSystem.FileName)
        end
        return nil
    end)
    
    if success and content then
        local data = game:GetService("HttpService"):JSONDecode(content)
        ConfigSystem.CurrentConfig = data
        return true
    else
        ConfigSystem.CurrentConfig = table.clone(ConfigSystem.DefaultConfig)
        ConfigSystem.SaveConfig()
        return false
    end
end

-- Tải cấu hình khi khởi động
ConfigSystem.LoadConfig()

-- Lấy tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name

-- Biến lưu trạng thái Auto Fish
local autoFishEnabled = ConfigSystem.CurrentConfig.AutoFishEnabled or false
local savedPosition = ConfigSystem.CurrentConfig.SavedPosition

-- Cấu hình UI
local Window = Fluent:CreateWindow({
    Title = "Script Hub",
    SubTitle = "Chào mừng, " .. playerName,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark", -- Có thể thay đổi: "Dark", "Light", "Darker", "Rose", "Amethyst"
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tạo các Tab
local MainTab = Window:AddTab({ Title = "Main", Icon = "rbxassetid://13311802307" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://13311798537" })

-- ========== TAB MAIN ==========
-- Section: Auto Farm
local AutoFarmSection = MainTab:AddSection("Auto Farm")

-- Button Save Pos
AutoFarmSection:AddButton({
    Title = "Save Pos",
    Description = "Lưu tọa độ hiện tại",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local pos = hrp.Position
            savedPosition = {pos.X, pos.Y, pos.Z}
            ConfigSystem.CurrentConfig.SavedPosition = savedPosition
            ConfigSystem.SaveConfig()
            
            Fluent:Notify({
                Title = "Save Pos",
                Content = string.format("Đã lưu tọa độ: X=%.2f, Y=%.2f, Z=%.2f", pos.X, pos.Y, pos.Z),
                Duration = 5
            })
        else
            Fluent:Notify({
                Title = "Lỗi",
                Content = "Không tìm thấy nhân vật!",
                Duration = 3
            })
        end
    end
})

-- Hàm kiểm tra và di chuyển đến tọa độ đã lưu
local function moveToSavedPosition()
    if not savedPosition then
        return false
    end
    
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local hrp = character.HumanoidRootPart
    local currentPos = hrp.Position
    local targetPos = Vector3.new(savedPosition[1], savedPosition[2], savedPosition[3])
    
    -- Kiểm tra khoảng cách (nếu cách xa hơn 5 studs thì di chuyển)
    local distance = (currentPos - targetPos).Magnitude
    if distance > 5 then
        hrp.CFrame = CFrame.new(targetPos)
        wait(0.5) -- Đợi một chút để đảm bảo di chuyển xong
        return true
    end
    
    return true
end

-- Hàm thực thi Auto Fish
local function executeAutoFish()
    if not autoFishEnabled then
        return
    end
    
    -- Kiểm tra và di chuyển đến tọa độ đã lưu nếu cần
    if savedPosition then
        moveToSavedPosition()
        wait(0.5)
    end
    
    local success, err = pcall(function()
        -- Bước 0: Equip Tool From Hotbar
        local args = {
            1
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/EquipToolFromHotbar"):FireServer(unpack(args))
        
        -- Bước 1: Charge Fishing Rod
        wait(0.5)
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/ChargeFishingRod"):InvokeServer()
        
        -- Bước 2: Đợi 1 giây rồi Request Fishing Minigame
        wait(1)
        local args = {
            -1.233184814453125,
            0.9940152067553181,
            1763908713.407927
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(unpack(args))
        
        -- Bước 3: Đợi 4 giây rồi Fire Fishing Completed
        wait(4)
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/FishingCompleted"):FireServer()
    end)
    
    if not success then
        warn("Lỗi Auto Fish: " .. tostring(err))
    end
end

-- Toggle Auto Fish
AutoFarmSection:AddToggle("AutoFishToggle", {
    Title = "Auto Fish",
    Description = "Tự động câu cá",
    Default = ConfigSystem.CurrentConfig.AutoFishEnabled or false,
    Callback = function(Value)
        autoFishEnabled = Value
        ConfigSystem.CurrentConfig.AutoFishEnabled = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            if not savedPosition then
                Fluent:Notify({
                    Title = "Cảnh báo",
                    Content = "Chưa lưu tọa độ! Vui lòng Save Pos trước.",
                    Duration = 5
                })
            else
                Fluent:Notify({
                    Title = "Auto Fish",
                    Content = "Đã bật Auto Fish",
                    Duration = 3
                })
            end
        else
            Fluent:Notify({
                Title = "Auto Fish",
                Content = "Đã tắt Auto Fish",
                Duration = 3
            })
        end
    end
})

-- ========== TAB SETTINGS ==========
-- Integration with SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:SetFolder("ScriptHub")
SaveManager:SetFolder("ScriptHub/" .. playerName)

-- Thông tin
SettingsTab:AddParagraph({
    Title = "Thông tin Script",
    Content = "Script Hub v1.0\nNgười chơi: " .. playerName
})

SettingsTab:AddParagraph({
    Title = "Phím tắt",
    Content = "Nhấn LeftControl để ẩn/hiện giao diện"
})

-- Theme Selector
local ThemeSection = SettingsTab:AddSection("Giao diện")

ThemeSection:AddDropdown("ThemeSelector", {
    Title = "Chọn Theme",
    Description = "Thay đổi giao diện",
    Values = {"Dark", "Light", "Darker", "Rose", "Amethyst"},
    Default = "Dark",
    Multi = false,
    Callback = function(Value)
        Window:SetTheme(Value)
        Fluent:Notify({
            Title = "Theme",
            Content = "Đã đổi theme thành " .. Value,
            Duration = 3
        })
    end
})

-- Auto Save Config
local function AutoSaveConfig()
    spawn(function()
        while wait(5) do -- Lưu mỗi 5 giây
            pcall(function()
                ConfigSystem.SaveConfig()
            end)
        end
    end)
end

-- Thực thi tự động lưu cấu hình
AutoSaveConfig()

-- Loop chính cho Auto Fish
spawn(function()
    while true do
        wait(3) -- Đợi 3 giây giữa mỗi lần thực hiện
        
        if autoFishEnabled then
            executeAutoFish()
        end
    end
end)

-- Thêm hỗ trợ Logo khi minimize
repeat task.wait(0.25) until game:IsLoaded()
getgenv().Image = "rbxassetid://13099788281" -- ID tài nguyên hình ảnh logo
getgenv().ToggleUI = "LeftControl" -- Phím để bật/tắt giao diện
-- Tạo logo để mở lại UI khi đã minimize
task.spawn(function()
    local success, errorMsg = pcall(function()
        if not getgenv().LoadedMobileUI == true then 
            getgenv().LoadedMobileUI = true
            local OpenUI = Instance.new("ScreenGui")
            local ImageButton = Instance.new("ImageButton")
            local UICorner = Instance.new("UICorner")
            
            -- Kiểm tra môi trường
            if syn and syn.protect_gui then
                syn.protect_gui(OpenUI)
                OpenUI.Parent = game:GetService("CoreGui")
            elseif gethui then
                OpenUI.Parent = gethui()
            else
                OpenUI.Parent = game:GetService("CoreGui")
            end
            
            OpenUI.Name = "OpenUI"
            OpenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            ImageButton.Parent = OpenUI
            ImageButton.BackgroundColor3 = Color3.fromRGB(105,105,105)
            ImageButton.BackgroundTransparency = 0.8
            ImageButton.Position = UDim2.new(0.9,0,0.1,0)
            ImageButton.Size = UDim2.new(0,50,0,50)
            ImageButton.Image = "rbxassetid://13099788281" -- Có thể thay đổi logo
            ImageButton.Draggable = true
            ImageButton.Transparency = 0.2
            
            UICorner.CornerRadius = UDim.new(0,200)
            UICorner.Parent = ImageButton
            
            -- Khi click vào logo sẽ mở lại UI
            ImageButton.MouseButton1Click:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.LeftControl,false,game)
            end)
        end
    end)
    
    if not success then
        warn("Lỗi khi tạo nút Logo UI: " .. tostring(errorMsg))
    end
end)

print("Script Hub đã tải thành công!")
print("Sử dụng Left Ctrl để thu nhỏ/mở rộng UI")

