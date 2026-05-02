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
print("[Shimmy Hub] Loading Rayfield UI... Please wait. (Sirius servers can be slow)")
local RayfieldSuccess, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not RayfieldSuccess or not Rayfield then
    warn("[Shimmy Hub] Failed to load Rayfield UI. Sirius might be down.")
    return
end

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
   Keybind = Enum.KeyCode.RightShift,
})

-- ==========================================
-- CUSTOM DRAGGABLE MINIMIZE BUTTON
-- ==========================================
local function createMinimizeButton()
    local ScreenGui = Instance.new("ScreenGui")
    local ToggleButton = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")

    ScreenGui.Name = "ShimmyToggle"
    -- Try to put in CoreGui so it doesn't delete on death, fallback to PlayerGui
    local success = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not success then
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    ToggleButton.Parent = ScreenGui
    ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
    ToggleButton.Size = UDim2.new(0, 45, 0, 45)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Text = "💥"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 20.000
    ToggleButton.BorderSizePixel = 0
    ToggleButton.AutoButtonColor = true

    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = ToggleButton

    -- Draggable Logic
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    ToggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Toggle Rayfield Logic
    ToggleButton.MouseButton1Click:Connect(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.RightShift, false, game)
        task.wait(0.01)
        vim:SendKeyEvent(false, Enum.KeyCode.RightShift, false, game)
    end)
end

createMinimizeButton()

-- ==========================================
-- GLOBAL HELPER FUNCTIONS
-- ==========================================
local FastAttackSpeed = 0.05
local function doFastAttack()
    local lp = game:GetService("Players").LocalPlayer
    local success = pcall(function()
        local CombatFramework = require(lp.PlayerScripts.CombatFramework)
        local activeController = debug.getupvalues(CombatFramework)[2].activeController
        activeController:attack()
    end)
    if not success then
        pcall(function()
            if mouse1click then mouse1click() end
        end)
    end
end

local lastInstinctCheck = 0
local function activateAbilities(player)
    if not player or not player.Character then return end
    
    pcall(function()
        -- Auto Haki (Aura)
        if not player.Character:FindFirstChild("HasBuso") then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
        end
        
        -- Auto Instinct (Dodge)
        if tick() - lastInstinctCheck > 2 then
            lastInstinctCheck = tick()
            if player.PlayerGui and player.PlayerGui:FindFirstChild("ScreenGui") and not player.PlayerGui.ScreenGui:FindFirstChild("Dodges") then
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end
    end)
end

-- ==========================================
-- TABS
-- ==========================================
local MainTab = Window:CreateTab("Main / Farming", 4483362458) -- Icon ID
local VisualsTab = Window:CreateTab("Visuals / ESP", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local ConfigTab = Window:CreateTab("Settings / Config", 4483362458)
local PvPTab = Window:CreateTab("PvP / Combat", 4483362458)
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
                                    activateAbilities(LocalPlayer)
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

local AutoQuestFarmEnabled = false
MainTab:CreateToggle({
   Name = "Autonomous Quest Farm (Compass)",
   CurrentValue = false,
   Flag = "AutoQuestFarm",
   Callback = function(Value)
        AutoQuestFarmEnabled = Value
        if AutoQuestFarmEnabled then
            task.spawn(function()
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local Workspace = game:GetService("Workspace")

                local function getQuestEnemyName()
                    local questUI = LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
                    if questUI and questUI.Visible then
                        local title = questUI:FindFirstChild("Container") and questUI.Container:FindFirstChild("QuestTitle") and questUI.Container.QuestTitle:FindFirstChild("Title")
                        if title and title.Text then
                            local text = title.Text
                            local enemyName = string.match(text, "Defeat %d+ (.*)")
                            if enemyName then
                                if string.sub(enemyName, -1) == "s" then
                                    enemyName = string.sub(enemyName, 1, -2)
                                end
                                return enemyName
                            end
                        end
                    end
                    return nil
                end

                local function getCompassTarget()
                    local compass = LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Compass")
                    if compass and compass.Visible then
                        local textLabel = compass:FindFirstChild("TextLabel")
                        if textLabel and textLabel.Text then
                            return textLabel.Text
                        end
                    end
                    return nil
                end

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

                while AutoQuestFarmEnabled do
                    task.wait(0.5)
                    local currentQuestEnemy = getQuestEnemyName()
                    
                    if currentQuestEnemy then
                        -- We have a quest, find the mob!
                        local foundMob = false
                        local enemiesFolder = Workspace:FindFirstChild("Enemies")
                        if enemiesFolder then
                            for _, mob in pairs(enemiesFolder:GetChildren()) do
                                if string.find(mob.Name, currentQuestEnemy) and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                                    foundMob = true
                                    disableGravity()
                                    activateAbilities(LocalPlayer)
                                    
                                    -- Teleport and Attack
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 8, 5)
                                    
                                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                    if tool then
                                        LocalPlayer.Character.Humanoid:EquipTool(tool)
                                        tool:Activate()
                                    end
                                    break
                                end
                            end
                        end
                    else
                        -- No active quest. Need to find quest giver based on Compass.
                        local compassText = getCompassTarget()
                        if compassText then
                            local npcsFolder = Workspace:FindFirstChild("NPCs")
                            if npcsFolder then
                                local targetNpc = nil
                                for _, npc in pairs(npcsFolder:GetChildren()) do
                                    -- Simple heuristic: Extract main word like "Bandit" from "Bandit Quest [Lv. 5]"
                                    local mainWord = string.match(compassText, "(%w+) Quest") or string.match(compassText, "(%w+)")
                                    if mainWord and string.find(npc.Name, mainWord) then
                                        targetNpc = npc
                                        break
                                    end
                                end
                                
                                if targetNpc and targetNpc:FindFirstChild("HumanoidRootPart") then
                                    disableGravity()
                                    -- Teleport to NPC to grab the quest
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetNpc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                                    
                                    -- Fire CommF_ to take quest (Generic fallback: if we don't know the exact ID, just fire the prompt)
                                    pcall(function()
                                        -- Try to auto accept quest 1 or 2
                                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", compassText, 1)
                                        task.wait(0.5)
                                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", compassText, 2)
                                    end)
                                    task.wait(1)
                                end
                            end
                        end
                    end
                end
                
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local bv = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("ShimmyFarmVelocity")
                    if bv then bv:Destroy() end
                end
            end)
        end
   end,
})

MainTab:CreateSlider({
   Name = "Fast Attack Speed (Sec)",
   Range = {0, 1},
   Increment = 0.01,
   Suffix = "s",
   CurrentValue = 0.05,
   Flag = "FastAttackSpeedSlider",
   Callback = function(Value)
        FastAttackSpeed = Value
   end,
})

local AutoClickEnabled = false
MainTab:CreateToggle({
   Name = "Auto Click / Fast Attack",
   CurrentValue = false,
   Flag = "AutoClickToggle",
   Callback = function(Value)
        AutoClickEnabled = Value
        task.spawn(function()
            while AutoClickEnabled do
                task.wait(FastAttackSpeed)
                doFastAttack()
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
local TargetWalkSpeed = 16
local WalkSpeedEnabled = false
local TargetJumpPower = 50
local JumpPowerEnabled = false

-- Use RunService to enforce Speed/JumpPower against Anti-Cheat resets
game:GetService("RunService").Stepped:Connect(function()
    local lp = game:GetService("Players").LocalPlayer
    if WalkSpeedEnabled and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = TargetWalkSpeed
    end
    if JumpPowerEnabled and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.JumpPower = TargetJumpPower
    end
end)

PlayerTab:CreateToggle({
   Name = "Enable Speed Modifier",
   CurrentValue = false,
   Flag = "WalkSpeedToggle",
   Callback = function(Value)
        WalkSpeedEnabled = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider", 
   Callback = function(Value)
        TargetWalkSpeed = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Enable Jump Modifier",
   CurrentValue = false,
   Flag = "JumpPowerToggle",
   Callback = function(Value)
        JumpPowerEnabled = Value
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
        TargetJumpPower = Value
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
-- PVP / COMBAT TAB
-- ==========================================
local TargetPlayerName = ""
local SelectedWeapon = ""
local AutoPvPEnabled = false
local PvP_TweenSpeed = 300
local PvP_AutoDodge = false

local PvP_AutoClick = false
local PvP_SkillZ = false
local PvP_SkillX = false
local PvP_SkillC = false
local PvP_SkillV = false
local PvP_SkillF = false

PvPTab:CreateSection("Target Settings")

local PvP_FilterTeam = false
PvPTab:CreateToggle({
   Name = "Show PvPable Players Only",
   CurrentValue = false,
   Flag = "PvPFilterTeam",
   Callback = function(Value)
        PvP_FilterTeam = Value
   end,
})

local PlayerDropdown = PvPTab:CreateDropdown({
   Name = "Select Target Player",
   Options = {""},
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "PvPTargetPlayer",
   Callback = function(Option)
        TargetPlayerName = Option[1]
   end,
})

PvPTab:CreateButton({
   Name = "Refresh Players",
   Callback = function()
        local playerNames = {}
        local lp = game:GetService("Players").LocalPlayer
        for _, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v ~= lp then
                if not PvP_FilterTeam or (v.Team ~= lp.Team) then
                    table.insert(playerNames, v.Name)
                end
            end
        end
        PlayerDropdown:Refresh(playerNames)
   end,
})

local WeaponDropdown = PvPTab:CreateDropdown({
    Name = "Select Weapon",
    Options = {""},
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "PvPWeapon",
    Callback = function(Option)
         SelectedWeapon = Option[1]
    end,
})

PvPTab:CreateButton({
   Name = "Refresh Weapons",
   Callback = function()
        local weapons = {}
        local lp = game:GetService("Players").LocalPlayer
        for _, tool in pairs(lp.Backpack:GetChildren()) do
            if tool:IsA("Tool") then table.insert(weapons, tool.Name) end
        end
        if lp.Character then
            for _, tool in pairs(lp.Character:GetChildren()) do
                if tool:IsA("Tool") then table.insert(weapons, tool.Name) end
            end
        end
        WeaponDropdown:Refresh(weapons)
   end,
})

PvPTab:CreateSection("Combat Automation")

PvPTab:CreateSlider({
   Name = "Tween Speed",
   Range = {50, 400},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 300,
   Flag = "PvPTweenSpeed",
   Callback = function(Value)
        PvP_TweenSpeed = Value
   end,
})

PvPTab:CreateToggle({
   Name = "Auto Dodge (Move 30 Studs Away)",
   CurrentValue = false,
   Flag = "PvPDodge",
   Callback = function(Value)
        PvP_AutoDodge = Value
   end,
})

PvPTab:CreateToggle({
   Name = "Auto PvP (Tween to Player)",
   CurrentValue = false,
   Flag = "AutoPvPToggle",
   Callback = function(Value)
        AutoPvPEnabled = Value
        if AutoPvPEnabled then
            task.spawn(function()
                local RunService = game:GetService("RunService")
                local VirtualUser = game:GetService("VirtualUser")
                local VirtualInputManager = game:GetService("VirtualInputManager")
                local lp = game:GetService("Players").LocalPlayer

                local function getTargetPlayer()
                    if TargetPlayerName ~= "" then
                        local target = game:GetService("Players"):FindFirstChild(TargetPlayerName)
                        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
                            return target
                        end
                    end
                    return nil
                end
                
                local function disableGravity()
                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        local bv = lp.Character.HumanoidRootPart:FindFirstChild("ShimmyPvPVelocity")
                        if not bv then
                            bv = Instance.new("BodyVelocity")
                            bv.Name = "ShimmyPvPVelocity"
                            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = lp.Character.HumanoidRootPart
                        end
                    end
                end

                local function enableGravity()
                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        local bv = lp.Character.HumanoidRootPart:FindFirstChild("ShimmyPvPVelocity")
                        if bv then bv:Destroy() end
                    end
                end

                local lastFastAttack = 0
                while AutoPvPEnabled do
                    task.wait()
                    local target = getTargetPlayer()
                    if target and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        disableGravity()
                        activateAbilities(lp)
                        
                        local targetPos = target.Character.HumanoidRootPart.Position
                        local myPos = lp.Character.HumanoidRootPart.Position
                        local distance = (targetPos - myPos).Magnitude
                        
                        local offset = CFrame.new(0, 0, 3)
                        
                        -- Dodge Logic (if opponent uses a skill/move, move 30 studs away)
                        if PvP_AutoDodge then
                            local isEnemyAttacking = false
                            for _, track in pairs(target.Character.Humanoid:GetPlayingAnimationTracks()) do
                                -- Combat/Skill animations typically use Action priorities
                                if track.Priority == Enum.AnimationPriority.Action or track.Priority == Enum.AnimationPriority.Action2 or track.Priority == Enum.AnimationPriority.Action3 or track.Priority == Enum.AnimationPriority.Action4 then
                                    isEnemyAttacking = true
                                    break
                                end
                            end
                            
                            if isEnemyAttacking then
                                offset = CFrame.new(0, 30, 0) -- Move 30 studs up to dodge the skill
                            end
                        end
                        
                        local tweenInfo = TweenInfo.new(distance / PvP_TweenSpeed, Enum.EasingStyle.Linear)
                        local tween = game:GetService("TweenService"):Create(lp.Character.HumanoidRootPart, tweenInfo, {CFrame = target.Character.HumanoidRootPart.CFrame * offset})
                        tween:Play()
                        
                        if SelectedWeapon ~= "" then
                            local tool = lp.Backpack:FindFirstChild(SelectedWeapon) or lp.Character:FindFirstChild(SelectedWeapon)
                            if tool and tool.Parent == lp.Backpack then
                                lp.Character.Humanoid:EquipTool(tool)
                            end
                        end
                        
                        if distance < 25 then
                            if PvP_AutoClick then
                                if tick() - lastFastAttack >= FastAttackSpeed then
                                    lastFastAttack = tick()
                                    doFastAttack()
                                end
                            end
                            
                            if PvP_SkillZ then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game) task.wait(0.01) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game) end
                            if PvP_SkillX then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game) task.wait(0.01) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game) end
                            if PvP_SkillC then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game) task.wait(0.01) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game) end
                            if PvP_SkillV then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.V, false, game) task.wait(0.01) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.V, false, game) end
                            if PvP_SkillF then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game) task.wait(0.01) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game) end
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

PvPTab:CreateSection("Auto Skills & Clicking")
PvPTab:CreateToggle({Name = "Auto Click", CurrentValue = false, Flag = "PvPClick", Callback = function(v) PvP_AutoClick = v end})
PvPTab:CreateToggle({Name = "Use Skill Z", CurrentValue = false, Flag = "PvP_Z", Callback = function(v) PvP_SkillZ = v end})
PvPTab:CreateToggle({Name = "Use Skill X", CurrentValue = false, Flag = "PvP_X", Callback = function(v) PvP_SkillX = v end})
PvPTab:CreateToggle({Name = "Use Skill C", CurrentValue = false, Flag = "PvP_C", Callback = function(v) PvP_SkillC = v end})
PvPTab:CreateToggle({Name = "Use Skill V", CurrentValue = false, Flag = "PvP_V", Callback = function(v) PvP_SkillV = v end})
PvPTab:CreateToggle({Name = "Use Skill F", CurrentValue = false, Flag = "PvP_F", Callback = function(v) PvP_SkillF = v end})

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
