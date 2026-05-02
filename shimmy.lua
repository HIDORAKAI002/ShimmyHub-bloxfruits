-- ==========================================
-- Shimmy Hub: Ultimate Unified Executor
-- ==========================================

-- Initialize Global Variables from Original Scripts
getgenv().Team = "Pirates"
getgenv().FixCrash = false -- Turn it On For Hopping Server, Improve Performance But Silent Aim On Mob And Player
getgenv().FixCrash2 = false -- Turn it On For Hopping Server, Improve Performance But Will Remove Speed Changer
getgenv().WebHookNotify = "here webhook"
getgenv().OnlyMirage = false -- this will only find mirage
getgenv().FindBoth = true -- finds both moon and mirage

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Shimmy Hub 💥",
   LoadingTitle = "Loading Shimmy Hub...",
   LoadingSubtitle = "by josep",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ShimmyHub",
      FileName = "ShimmyHubConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink", 
      RememberJoins = true 
   },
   KeySystem = false,
})

-- ==========================================
-- TABS
-- ==========================================
local MainTab = Window:CreateTab("Main / Farming", 4483362458) -- Icon ID
local VisualsTab = Window:CreateTab("Visuals / ESP", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local ConfigTab = Window:CreateTab("Settings / Config", 4483362458)
local HubsTab = Window:CreateTab("External Hubs", 4483362458)

-- ==========================================
-- MAIN / FARMING TAB
-- ==========================================
local TargetMobName = ""
local AutoFarmEnabled = false
local BringMobsEnabled = false

MainTab:CreateInput({
   Name = "Target Mob Name",
   PlaceholderText = "Enter exact mob name (e.g. Bandit [Lv. 5])",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        TargetMobName = Text
   end,
})

MainTab:CreateToggle({
   Name = "Bring Mobs (Magnet)",
   CurrentValue = false,
   Flag = "BringMobsToggle",
   Callback = function(Value)
        BringMobsEnabled = Value
   end,
})

MainTab:CreateToggle({
   Name = "Auto Farm Mobs",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
        AutoFarmEnabled = Value
        
        if AutoFarmEnabled then
            task.spawn(function()
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local Workspace = game:GetService("Workspace")
                local VirtualUser = game:GetService("VirtualUser")

                -- Prevent falling while auto farming
                local function disableGravity()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local bv = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("ShimmyFarmVelocity")
                        if not bv then
                            bv = Instance.new("BodyVelocity")
                            bv.Name = "ShimmyFarmVelocity"
                            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = LocalPlayer.Character.HumanoidRootPart
                        end
                    end
                end

                local function enableGravity()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local bv = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("ShimmyFarmVelocity")
                        if bv then bv:Destroy() end
                    end
                end

                while AutoFarmEnabled do
                    task.wait()
                    if TargetMobName ~= "" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local enemiesFolder = Workspace:FindFirstChild("Enemies")
                        if enemiesFolder then
                            for _, mob in pairs(enemiesFolder:GetChildren()) do
                                if mob.Name == TargetMobName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                                    
                                    disableGravity()
                                    -- Teleport slightly above and behind the mob to avoid attacks
                                    local targetCFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 8, 5)
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
                                    
                                    -- Bring Mobs (Group them up)
                                    if BringMobsEnabled then
                                        for _, otherMob in pairs(enemiesFolder:GetChildren()) do
                                            if otherMob.Name == TargetMobName and otherMob:FindFirstChild("Humanoid") and otherMob.Humanoid.Health > 0 and otherMob:FindFirstChild("HumanoidRootPart") then
                                                local dist = (otherMob.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                                if dist < 300 then
                                                    -- Teleport other mobs to the target mob and expand hitbox
                                                    otherMob.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame
                                                    otherMob.HumanoidRootPart.CanCollide = false
                                                    otherMob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                                end
                                            end
                                        end
                                    end
                                    
                                    -- Auto Attack (Equips tool and clicks)
                                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                    if not tool then
                                        tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                        if tool then
                                            LocalPlayer.Character.Humanoid:EquipTool(tool)
                                        end
                                    end
                                    
                                    VirtualUser:CaptureController()
                                    VirtualUser:ClickButton1(Vector2.new())
                                    
                                    break -- Focus on one mob per loop cycle
                                end
                            end
                        end
                    else
                        enableGravity()
                    end
                end
                enableGravity()
            end)
        end
   end,
})

local AutoClickEnabled = false
MainTab:CreateToggle({
   Name = "Auto Click / Attack",
   CurrentValue = false,
   Flag = "AutoClickToggle",
   Callback = function(Value)
        AutoClickEnabled = Value
        task.spawn(function()
            while AutoClickEnabled do
                task.wait(0.05)
                -- Trigger virtual user click
                game:GetService("VirtualUser"):ClickButton1(Vector2.new())
            end
        end)
   end,
})

-- ==========================================
-- VISUALS / ESP TAB
-- ==========================================
local ESPEnabled = false
VisualsTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESPToggle",
   Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            -- Simple ESP Logic Structure
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game:GetService("Players").LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Name = "ShimmyESP"
                end
            end
        else
            -- Remove ESP
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ShimmyESP") then
                    player.Character.ShimmyESP:Destroy()
                end
            end
        end
   end,
})

-- ==========================================
-- PLAYER TAB
-- ==========================================
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider", 
   Callback = function(Value)
        local lp = game:GetService("Players").LocalPlayer
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = Value
        end
   end,
})

PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "JumpPowerSlider", 
   Callback = function(Value)
        local lp = game:GetService("Players").LocalPlayer
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.JumpPower = Value
        end
   end,
})

-- ==========================================
-- SETTINGS / CONFIG TAB
-- ==========================================
ConfigTab:CreateSection("Global Variables")

ConfigTab:CreateToggle({
    Name = "Fix Crash (Hop Server)",
    CurrentValue = getgenv().FixCrash,
    Flag = "FixCrashToggle",
    Callback = function(Value)
        getgenv().FixCrash = Value
    end,
})

ConfigTab:CreateToggle({
    Name = "Only Find Mirage",
    CurrentValue = getgenv().OnlyMirage,
    Flag = "OnlyMirageToggle",
    Callback = function(Value)
        getgenv().OnlyMirage = Value
    end,
})

ConfigTab:CreateInput({
   Name = "Discord Webhook",
   PlaceholderText = "Paste Webhook URL here...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        getgenv().WebHookNotify = Text
        print("Webhook updated to: " .. Text)
   end,
})

-- ==========================================
-- EXTERNAL HUBS TAB
-- ==========================================
HubsTab:CreateSection("Load Obfuscated Hubs")
HubsTab:CreateParagraph({Title = "Notice", Content = "These buttons will execute the loaders for the external scripts you provided."})

HubsTab:CreateButton({
   Name = "Load Redz Hub",
   Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/huy384/redzHub/refs/heads/main/redzHub.lua"))()
   end,
})

HubsTab:CreateButton({
   Name = "Load Luarmor Blox Fruits Loader",
   Callback = function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/3b2169cf53bc6104dabe8e19562e5cc2.lua"))()
   end,
})

HubsTab:CreateButton({
   Name = "Load Speed Hub X",
   Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
   end,
})

HubsTab:CreateButton({
   Name = "Load Alchemy Hub",
   Callback = function()
        loadstring(game:HttpGet("https://scripts.alchemyhub.xyz"))()
   end,
})

HubsTab:CreateButton({
   Name = "Load Kncrypt",
   Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/Kncrypt/refs/heads/main/sources/BloxFruit.lua"))()
   end,
})

Rayfield:Notify({
    Title = "Shimmy Hub",
    Content = "Loaded successfully!",
    Duration = 3,
    Image = 4483362458,
})
