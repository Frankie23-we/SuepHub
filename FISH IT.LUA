# SuepHub
--========================================================
-- SUEPHUB LOAD
--========================================================
local SuepHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Frankie23-we/SuepHub/refs/heads/main/SuepHubUI.LUA"))()

-- Contoh API SuepHub (SESUIDKAN DENGAN LIB ASLI):
-- Window:CreateTab(name, icon)
-- Tab:CreateSection(name)
-- Section:CreateToggle(name, default, callback)
-- Section:CreateButton(name, callback)
-- Section:CreateSlider(name, min, max, default, callback)

local Window = SuepHub:CreateWindow("Fish It! | By Igcool")

local CreditsTab  = Window:CreateTab("Credits",     "rbxassetid://4483345998")
local FishingTab  = Window:CreateTab("Fishing",     "rbxassetid://4483345998")
local AutoFarmTab = Window:CreateTab("AutoFarm",    "rbxassetid://4483345998")
local TpTab       = Window:CreateTab("Teleports",   "rbxassetid://4483345998")
local MiscTab     = Window:CreateTab("Misc",        "rbxassetid://4483345998")

--========================================================
-- SERVICES
--========================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local StarterPack       = game:GetService("StarterPack")
local player            = Players.LocalPlayer

--========================================================
-- FISHING REMOTES
--========================================================
local StartRemote  = ReplicatedStorage:WaitForChild("FishingStart")
local ReelRemote   = ReplicatedStorage:WaitForChild("FishingReel")
local NotifyRemote = ReplicatedStorage:WaitForChild("FishingNotify")

--========================================================
-- FISHING CONFIG
--========================================================
local DEV = {
    autoFish         = false,
    autoPerfection   = true,
    speedMultiplier  = 1.0,
    instantCatch     = true,
    superFast        = 0,
    delayMode        = 1.0,
    autoEquipRadar   = true,
    animationEnabled = false,
}

--========================================================
-- FISHING UI (STATUS + PROGRESS KECIL DI POJOK)
--========================================================
local screen = Instance.new("ScreenGui")
screen.Name = "FishingUI_v3"
screen.ResetOnSpawn = false
screen.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 300, 0, 90)
main.Position = UDim2.new(0, 12, 0, 12)
main.BackgroundColor3 = Color3.fromRGB(12,12,12)
main.BorderSizePixel = 0
main.AnchorPoint = Vector2.new(0,0)
main.Active = true
main.Draggable = true
main.Parent = screen

local border = Instance.new("UIStroke")
border.Parent = main
border.Color = Color3.fromRGB(190,30,30)
border.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 24)
title.Position = UDim2.new(0,12,0,6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Fishing System v3"
title.TextColor3 = Color3.fromRGB(230,80,80)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -24, 0, 20)
status.Position = UDim2.new(0,12,0,30)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(220,220,220)
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local progressHolder = Instance.new("Frame")
progressHolder.Size = UDim2.new(1, -24, 0, 14)
progressHolder.Position = UDim2.new(0,12,0,56)
progressHolder.BackgroundColor3 = Color3.fromRGB(30,30,30)
progressHolder.BorderSizePixel = 0
progressHolder.Parent = main

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.Position = UDim2.new(0,0,0,0)
progressBar.BackgroundColor3 = Color3.fromRGB(200,60,60)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressHolder

local function setStatus(text)
    status.Text = text or ""
end

local function setProgress(p)
    p = math.clamp(p, 0, 1)
    progressBar.Size = UDim2.new(p, 0, 1, 0)
end

--========================================================
-- FISHING CORE LOGIC
--========================================================
local isFishing = false
local startTick = 0
local biteTick  = nil

local function getEffectiveSpeed()
    return DEV.speedMultiplier * (DEV.superFast > 0 and DEV.superFast or 1)
end

local function tryAutoEquipRadar()
    if not DEV.autoEquipRadar then return end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild("FishingRadar")
        if tool and tool:IsA("Tool") then
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid  = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
                setStatus("Radar auto-equipped.")
            end
            return
        end
    end
    local sp = StarterPack:FindFirstChild("FishingRadar")
    if sp and sp:IsA("Tool") then
        local clone = sp:Clone()
        clone.Parent = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack")
        setStatus("Radar added & equipped.")
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(clone)
        end
    end
end

local function startFishing()
    if isFishing then
        setStatus("Already fishing...")
        return
    end
    isFishing = true
    startTick = tick()
    setStatus("Casting...")
    setProgress(0)

    local req = {
        speed = getEffectiveSpeed(),
        delay = DEV.delayMode
    }

    StartRemote:FireServer(startTick, req)
    tryAutoEquipRadar()
end

NotifyRemote.OnClientEvent:Connect(function(payload)
    if not payload or not payload.event then return end

    if payload.event == "Started" then
        setStatus("Waiting for bite...")
        local target = (payload.when or tick())
        task.spawn(function()
            while isFishing and tick() < target do
                local total   = math.max(0.01, (target - startTick))
                local elapsed = tick() - startTick
                setProgress(elapsed / total)
                task.wait(0.03)
            end
        end)

    elseif payload.event == "Bite" then
        biteTick = payload.serverTime or tick()
        if DEV.animationEnabled then
            setStatus("Fish is biting! Press E / auto...")
        else
            setStatus("Fish biting (anim off)")
        end
        setProgress(1)

        local speed = math.max(getEffectiveSpeed(), 0.01)

        if DEV.instantCatch then
            ReelRemote:FireServer(0)
        elseif DEV.autoPerfection then
            local perfect = 3.0 / speed
            delay(perfect, function()
                if isFishing then
                    local elapsed = tick() - startTick
                    ReelRemote:FireServer(elapsed)
                end
            end)
        elseif DEV.autoFish then
            local elapsed = 3.0 / speed
            ReelRemote:FireServer(elapsed)
        end

    elseif payload.event == "Result" then
        local res = payload.result or {}
        setStatus("Result: " .. (res.quality or "Unknown") .. " +" .. tostring(res.reward or 0))
        isFishing = false
        biteTick  = nil
        task.wait(2)
        setStatus("Ready")
        setProgress(0)
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E and isFishing then
        local elapsed = tick() - startTick
        ReelRemote:FireServer(elapsed)
    end
end)

task.spawn(function()
    while true do
        if DEV.autoFish and not isFishing then
            startFishing()
        end
        task.wait(0.6)
    end
end)

--========================================================
-- CREDITS TAB
--========================================================
local CreditsSection = CreditsTab:CreateSection("Credits")
CreditsSection:CreateButton("Info", function()
    print("Fish It! UI by Igcool, Fishing System v3 merged with SuepHub UI.")
end)

--========================================================
-- FISHING TAB (SUEPHUB)
--========================================================
local FishingMain     = FishingTab:CreateSection("Fishing Control")
local FishingSettings = FishingTab:CreateSection("Fishing Settings")

FishingMain:CreateButton("Start Fishing (Manual)", function()
    startFishing()
end)

FishingMain:CreateToggle("Auto Fish", false, function(state)
    DEV.autoFish = state
    setStatus(state and "Auto fish enabled." or "Auto fish disabled.")
end)

FishingSettings:CreateToggle("Instant Catch", DEV.instantCatch, function(state)
    DEV.instantCatch = state
end)

FishingSettings:CreateToggle("Auto Perfection (if not instant)", DEV.autoPerfection, function(state)
    DEV.autoPerfection = state
end)

FishingSettings:CreateToggle("Animation Hint Text", DEV.animationEnabled, function(state)
    DEV.animationEnabled = state
end)

FishingSettings:CreateToggle("Auto-Equip Radar", DEV.autoEquipRadar, function(state)
    DEV.autoEquipRadar = state
    if state then
        tryAutoEquipRadar()
    end
end)

FishingSettings:CreateSlider("Speed Multiplier", 1, 50, 10, function(val)
    -- slider integer, jadi kita bagi 10 biar 0.1 step
    DEV.speedMultiplier = val / 10
    print("Speed x" .. tostring(getEffectiveSpeed()))
end)

FishingSettings:CreateSlider("SuperFast (0 / 8 / 10x)", 0, 10, 0, function(val)
    if val < 4 then
        DEV.superFast = 0
    elseif val < 9 then
        DEV.superFast = 8
    else
        DEV.superFast = 10
    end
    print("SuperFast -> effective speed x" .. tostring(getEffectiveSpeed()))
end)

FishingSettings:CreateToggle("Delay x2", false, function(state)
    DEV.delayMode = state and 2.0 or 1.0
end)

--========================================================
-- AUTOFARM / TELEPORT / MISC (DARI SCRIPT KEDUA)
--========================================================
local AutoSection = AutoFarmTab:CreateSection("Auto Farms")

local TpSection   = TpTab:CreateSection("Locations")

local MiscSection = MiscTab:CreateSection("Extra Features")

getgenv().autoFarmEnabled   = false
getgenv().coralFarmEnabled  = false
getgenv().depthsFarmEnabled = false
getgenv().volcanoFarmEnabled= false
local platform = nil

local function makePlatform()
    if platform then platform:Destroy() platform = nil end
    platform = Instance.new("Part")
    platform.Size = Vector3.new(5, 1, 5)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
    platform.Parent = workspace
end

-- tombol disable semua autofarm (T)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        getgenv().autoFarmEnabled   = false
        getgenv().coralFarmEnabled  = false
        getgenv().depthsFarmEnabled = false
        getgenv().volcanoFarmEnabled= false
        if platform then platform:Destroy() platform = nil end
        print("All autofarm toggles disabled (T).")
    end
end)

-- Autofarm Kohana
AutoSection:CreateToggle("Autofarm Kohana", false, function(state)
    getgenv().autoFarmEnabled = state
    if state then
        makePlatform()
        task.spawn(function()
            while getgenv().autoFarmEnabled do
                pcall(function()
                    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                    hrp.CFrame = CFrame.new(-759.0910034179688, 24.309707641601562, 429.12823486328125)
                    platform.Position = hrp.Position - Vector3.new(0, 3, 0)
                    mouse1click()
                end)
                task.wait()
            end
        end)
    else
        if platform then platform:Destroy() platform = nil end
    end
end)

-- Autofarm Coral Reefs
AutoSection:CreateToggle("Autofarm Coral Reefs", false, function(state)
    getgenv().coralFarmEnabled = state
    if state then
        makePlatform()
        task.spawn(function()
            while getgenv().coralFarmEnabled do
                pcall(function()
                    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                    hrp.CFrame = CFrame.new(-3222.68994140625, 9.972307205200195, 1898.0626220703125)
                    platform.Position = hrp.Position - Vector3.new(0, 3, 0)
                    mouse1click()
                end)
                task.wait()
            end
        end)
    else
        if platform then platform:Destroy() platform = nil end
    end
end)

-- Autofarm Depths
AutoSection:CreateToggle("Autofarm Depths", false, function(state)
    getgenv().depthsFarmEnabled = state
    if state then
        makePlatform()
        task.spawn(function()
            while getgenv().depthsFarmEnabled do
                pcall(function()
                    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                    hrp.CFrame = CFrame.new(3239.964599609375, -1298.2198486328125, 1353.6944580078125)
                    platform.Position = hrp.Position - Vector3.new(0, 3, 0)
                    mouse1click()
                end)
                task.wait()
            end
        end)
    else
        if platform then platform:Destroy() platform = nil end
    end
end)

-- TELEPORTS
local locations = {
    ["Starter Island"] = CFrame.new(23.435884475708008, 4.625000953674316, 2868.347412109375),
    ["Kohana Island"]  = CFrame.new(-842.8712158203125, 55.500057220458984, 146.21389770507812),
    ["Kohana Volcano"] = CFrame.new(-606.581787109375, 59.000057220458984, 105.82990264892578),
    ["Coral Reefs"]    = CFrame.new(-2853.76318359375, 47.499996185302734, 1988.1397705078125),
    ["The Depths"]     = CFrame.new(2002.4705810546875, 12.10128402709961, 1385.3233642578125),
    ["Altar Enchant"]  = CFrame.new(3177.329345703125, -1302.72998046875, 1427.3759765625),
}

for name, cf in pairs(locations) do
    TpSection:CreateButton("Teleport to "..name, function()
        pcall(function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = cf
        end)
        print("Teleported to "..name)
    end)
end

-- MISC
MiscSection:CreateButton("Load Infinite Yield", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    print("Infinite Yield loaded.")
end)

MiscSection:CreateToggle("Auto Collect Items", false, function(state)
    getgenv().autoCollect = state
    task.spawn(function()
        while getgenv().autoCollect do
            for _,v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") then
                    pcall(function()
                        v.Handle.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    end)
                end
            end
            task.wait()
        end
    end)
end)

MiscSection:CreateSlider("WalkSpeed (16-500)", 16, 500, 16, function(Value)
    pcall(function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end)
end)

print("Combined Fish It! Script (Fishing v3 + SuepHub UI) Loaded.")
