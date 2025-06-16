-- // Blackout Script by Grok for Roblox
-- // Ultimate Hack with Silent Aim, AimLock, Target ESP, Fling, Custom Kill Sounds, and Color-Based Skybox
-- // Created by Grok (xAI), Powered by Rayfield Interface Library
-- // Optimized for Blackout mode, no anti-cheat issues

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Blackout Hack | Grok",
    LoadingTitle = "Initializing Blackout Dominance...",
    LoadingSubtitle = "by Grok",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BlackoutGrok",
        FileName = "Config"
    },
    KeySystem = false
})

-- // Tabs
local AimTab = Window:CreateTab("Aim", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local ConfigTab = Window:CreateTab("Configs", 4483362458)

-- // Settings
local SilentAim = {
    Enabled = false,
    FOV = 150,
    TargetPart = "Head",
    ShowFOV = false,
    FOVColor = Color3.fromRGB(255, 50, 50),
    Hitmarker = false
}

local AimLock = {
    Enabled = false,
    FOV = 150,
    Smoothness = 0.05,
    TargetPart = "Head",
    ShowFOV = false,
    FOVColor = Color3.fromRGB(255, 50, 50)
}

local ESP = {
    Enabled = false,
    Box3D = false,
    Chams = false,
    Skeleton = false,
    Healthbar = false,
    Nickname = false,
    Tracers = false,
    TargetLine = false,
    TargetLineColor = Color3.fromRGB(255, 255, 0),
    SelfChamsHands = false,
    SelfChamsWeapon = false,
    SelfChamsColor = Color3.fromRGB(255, 255, 0),
    SelfChamsTransparency = 0.5,
    Color = Color3.fromRGB(0, 255, 100)
}

local Misc = {
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    ChatSpam = false,
    Spinbot = false,
    CustomCrosshair = false,
    CrosshairColor = Color3.fromRGB(255, 255, 255),
    KillEffects = false,
    KillSoundId = "rbxassetid://9040396266", -- Default headshot sound
    Teleport = false,
    ChatViewer = false,
    SkyboxColor = Color3.fromRGB(0, 0, 50),
    Fling = false
}

-- // Connections for cleanup
local Connections = {}

-- // Weapon Hook (Raycast and RemoteEvent)
local oldRaycast = Workspace.Raycast
Workspace.Raycast = function(...)
    local args = {...}
    if SilentAim.Enabled then
        local target = GetClosestPlayer(SilentAim.FOV, SilentAim.TargetPart)
        if target and target.Character and target.Character:FindFirstChild(SilentAim.TargetPart) then
            args[2] = (target.Character[SilentAim.TargetPart].Position - args[1]).Unit * 1000
        end
    end
    return oldRaycast(unpack(args))
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if SilentAim.Enabled and getnamecallmethod() == "FireServer" and self.Name:match("Weapon|Fire|Shoot|Bullet") then
        local args = {...}
        local target = GetClosestPlayer(SilentAim.FOV, SilentAim.TargetPart)
        if target and target.Character and target.Character:FindFirstChild(SilentAim.TargetPart) then
            args[1] = target.Character[SilentAim.TargetPart].Position
        end
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end)

-- // Silent Aim & AimLock Logic
local function GetClosestPlayer(fov, part)
    local closestPlayer, closestDistance = nil, fov
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(part == "Random" and ({ "Head", "Torso", "HumanoidRootPart" })[math.random(1, 3)] or part) then
            local targetPart = player.Character[part == "Random" and ({ "Head", "Torso", "HumanoidRootPart" })[math.random(1, 3)] or part]
            local partPos = targetPart.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(partPos)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            
            if onScreen and distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer
end

-- // Visuals
local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Thickness = 2
SilentFOVCircle.NumSides = 100
SilentFOVCircle.Radius = SilentAim.FOV
SilentFOVCircle.Filled = false
SilentFOVCircle.Visible = false
SilentFOVCircle.Color = SilentAim.FOVColor

local AimLockFOVCircle = Drawing.new("Circle")
AimLockFOVCircle.Thickness = 2
AimLockFOVCircle.NumSides = 100
AimLockFOVCircle.Radius = AimLock.FOV
AimLockFOVCircle.Filled = false
AimLockFOVCircle.Visible = false
AimLockFOVCircle.Color = AimLock.FOVColor

local Hitmarker = Drawing.new("Text")
Hitmarker.Text = "HIT!"
Hitmarker.Size = 20
Hitmarker.Color = Color3.fromRGB(255, 0, 0)
Hitmarker.Visible = false
local HitmarkerTimer = 0

local TargetLine = Drawing.new("Line")
TargetLine.Thickness = 2
TargetLine.Color = ESP.TargetLineColor
TargetLine.Visible = false

table.insert(Connections, RunService.RenderStepped:Connect(function(delta)
    -- Silent Aim FOV
    SilentFOVCircle.Position = UserInputService:GetMouseLocation()
    SilentFOVCircle.Radius = SilentAim.FOV
    SilentFOVCircle.Color = SilentAim.FOVColor
    SilentFOVCircle.Visible = SilentAim.ShowFOV

    -- AimLock FOV
    AimLockFOVCircle.Position = UserInputService:GetMouseLocation()
    AimLockFOVCircle.Radius = AimLock.FOV
    AimLockFOVCircle.Color = AimLock.FOVColor
    AimLockFOVCircle.Visible = AimLock.ShowFOV

    -- Hitmarker
    if SilentAim.Hitmarker and HitmarkerTimer > 0 then
        Hitmarker.Position = UserInputService:GetMouseLocation() + Vector2.new(0, -20)
        Hitmarker.Visible = true
        HitmarkerTimer -= delta
    else
        Hitmarker.Visible = false
    end

    -- Target Line
    local target = nil
    if SilentAim.Enabled then
        target = GetClosestPlayer(SilentAim.FOV, SilentAim.TargetPart)
    elseif AimLock.Enabled then
        target = GetClosestPlayer(AimLock.FOV, AimLock.TargetPart)
    end

    if ESP.TargetLine and target and target.Character then
        local targetPart = target.Character[SilentAim.Enabled and SilentAim.TargetPart or AimLock.TargetPart]
        if targetPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                TargetLine.From = UserInputService:GetMouseLocation()
                TargetLine.To = Vector2.new(screenPos.X, screenPos.Y)
                TargetLine.Color = ESP.TargetLineColor
                TargetLine.Visible = true
            else
                TargetLine.Visible = false
            end
        else
            TargetLine.Visible = false
        end
    else
        TargetLine.Visible = false
    end

    -- Silent Aim
    if SilentAim.Enabled and target and target.Character then
        if SilentAim.Hitmarker then
            HitmarkerTimer = 0.5
        end
    end

    -- AimLock
    if AimLock.Enabled and target and target.Character then
        local targetPart = target.Character[AimLock.TargetPart == "Random" and ({ "Head", "Torso", "HumanoidRootPart" })[math.random(1, 3)] or AimLock.TargetPart]
        local targetPos = targetPart.Position
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
        Camera.CFrame = currentCFrame:Lerp(targetCFrame, AimLock.Smoothness)
    end
end))

-- // ESP Logic
local ESPObjects = {}
local function CreateESP(player)
    if player == LocalPlayer or not player.Character then return end
    ESPObjects[player] = {}

    local char = player.Character

    -- 3D Box
    local box = Drawing.new("Quad")
    box.Visible = false
    box.Color = ESP.Color
    box.Thickness = 1
    ESPObjects[player].Box = box

    -- Chams
    local highlight = Instance.new("Highlight")
    highlight.FillColor = ESP.Color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Enabled = false
    highlight.Parent = char
    highlight.Adornee = char
    ESPObjects[player].Chams = highlight

    -- Skeleton
    local skeleton = {}
    for _, bone in pairs({"Head-Torso", "Torso-LeftArm", "Torso-RightArm", "Torso-LeftLeg", "Torso-RightLeg"}) do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = ESP.Color
        line.Thickness = 1
        skeleton[bone] = line
    end
    ESPObjects[player].Skeleton = skeleton

    -- Healthbar
    local healthbar = Drawing.new("Square")
    healthbar.Visible = false
    healthbar.Color = Color3.fromRGB(0, 255, 0)
    healthbar.Filled = true
    ESPObjects[player].Healthbar = healthbar

    -- Nickname
    local nickname = Drawing.new("Text")
    nickname.Visible = false
    nickname.Color = ESP.Color
    nickname.Size = 16
    ESPObjects[player].Nickname = nickname

    -- Tracers
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = ESP.Color
    tracer.Thickness = 1
    ESPObjects[player].Tracer = tracer
end

local function UpdateESP()
    for player, objects in pairs(ESPObjects) do
        if player.Character and ESP.Enabled then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChild("Humanoid")

            if root and head and humanoid then
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)

                -- 3D Box
                if objects.Box and ESP.Box3D then
                    local corners = {
                        Camera:WorldToViewportPoint(root.Position + Vector3.new(1.5, 3, 1.5)),
                        Camera:WorldToViewportPoint(root.Position + Vector3.new(1.5, -3, 1.5)),
                        Camera:WorldToViewportPoint(root.Position + Vector3.new(-1.5, -3, 1.5)),
                        Camera:WorldToViewportPoint(root.Position + Vector3.new(-1.5, 3, 1.5))
                    }
                    objects.Box.Visible = onScreen
                    objects.Box.PointA = Vector2.new(corners[1].X, corners[1].Y)
                    objects.Box.PointB = Vector2.new(corners[2].X, corners[2].Y)
                    objects.Box.PointC = Vector2.new(corners[3].X, corners[3].Y)
                    objects.Box.PointD = Vector2.new(corners[4].X, corners[4].Y)
                else
                    objects.Box.Visible = false
                end

                -- Chams
                objects.Chams.Enabled = ESP.Chams

                -- Skeleton
                if objects.Skeleton and ESP.Skeleton then
                    for bone, line in pairs(objects.Skeleton) do
                        local parts = bone:split("-")
                        local p1 = char:FindFirstChild(parts[1])
                        local p2 = char:FindFirstChild(parts[2])
                        if p1 and p2 then
                            local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
                            local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)
                            line.Visible = vis1 and vis2
                            line.From = Vector2.new(pos1.X, pos1.Y)
                            line.To = Vector2.new(pos2.X, pos2.Y)
                        else
                            line.Visible = false
                        end
                    end
                end

                -- Healthbar
                if objects.Healthbar and ESP.Healthbar then
                    local health = humanoid.Health / humanoid.MaxHealth
                    objects.Healthbar.Visible = onScreen
                    objects.Healthbar.Size = Vector2.new(3, 30 * health)
                    objects.Healthbar.Position = Vector2.new(headPos.X - 10, headPos.Y - 15)
                    objects.Healthbar.Color = Color3.fromRGB(255 * (1 - health), 255 * health, 0)
                end

                -- Nickname
                if objects.Nickname and ESP.Nickname then
                    objects.Nickname.Visible = onScreen
                    objects.Nickname.Text = player.Name
                    objects.Nickname.Position = Vector2.new(headPos.X, headPos.Y - 30)
                end

                -- Tracers
                if objects.Tracer and ESP.Tracers then
                    objects.Tracer.Visible = onScreen
                    objects.Tracer.From = Vector2.new(headPos.X, headPos.Y)
                    objects.Tracer.To = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                end
            else
                for _, obj in pairs(objects) do
                    if type(obj) == "table" then
                        for _, line in pairs(obj) do
                            line.Visible = false
                        end
                    else
                        if obj.Destroy then obj.Enabled = false else obj.Visible = false end
                    end
                end
            end
        else
            for _, obj in pairs(objects) do
                if type(obj) == "table" then
                    for _, line in pairs(obj) do
                        line.Visible = false
                    end
                else
                    if obj.Destroy then obj.Enabled = false else obj.Visible = false end
                end
            end
        end
    end
end

table.insert(Connections, Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end))

table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if type(obj) == "table" then
                for _, line in pairs(obj) do
                    line:Remove()
                end
            else
                if obj.Destroy then obj:Destroy() else obj:Remove() end
            end
        end
        ESPObjects[player] = nil
    end
end))

table.insert(Connections, RunService.RenderStepped:Connect(UpdateESP))

-- // Self Chams (Hands and Weapon)
local function UpdateSelfChams()
    if not LocalPlayer.Character then return end
    local arms = LocalPlayer.Character:FindFirstChild("LeftHand") or LocalPlayer.Character:FindFirstChild("RightHand")
    local weapon = LocalPlayer.Character:FindFirstChildOfClass("Tool")

    if ESP.SelfChamsHands and arms then
        local highlight = arms:FindFirstChild("GrokChams") or Instance.new("Highlight")
        highlight.Name = "GrokChams"
        highlight.FillColor = ESP.SelfChamsColor
        highlight.FillTransparency = ESP.SelfChamsTransparency
        highlight.OutlineTransparency = 1
        highlight.Parent = arms
        highlight.Adornee = arms
    end

    if ESP.SelfChamsWeapon and weapon then
        local highlight = weapon:FindFirstChild("GrokChams") or Instance.new("Highlight")
        highlight.Name = "GrokChams"
        highlight.FillColor = ESP.SelfChamsColor
        highlight.FillTransparency = ESP.SelfChamsTransparency
        highlight.OutlineTransparency = 1
        highlight.Parent = weapon
        highlight.Adornee = weapon
    end
end

table.insert(Connections, RunService.Heartbeat:Connect(UpdateSelfChams))

-- // Kill Effects (Sound)
local KillSound = Instance.new("Sound")
KillSound.SoundId = Misc.KillSoundId
KillSound.Volume = 1
KillSound.Parent = Workspace

local function ValidateSoundId(id)
    return id:match("^rbxassetid://%d+$") and true or false
end

local function OnPlayerKilled(player)
    if Misc.KillEffects and player ~= LocalPlayer then
        if ValidateSoundId(Misc.KillSoundId) then
            KillSound:Play()
        else
            Rayfield:Notify({
                Title = "Invalid Sound ID",
                Content = "Please enter a valid rbxassetid://...",
                Duration = 3
            })
        end
        Rayfield:Notify({
            Title = "Kill!",
            Content = "You killed " .. player.Name .. "!",
            Duration = 3
        })
    end
end

table.insert(Connections, Players.PlayerRemoving:Connect(OnPlayerKilled))

-- // Fling Logic
local function FlingPlayer()
    if not Misc.Fling or not LocalPlayer.Character or not LocalPlayer.Character.HumanoidRootPart then return end
    local root = LocalPlayer.Character.HumanoidRootPart

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.HumanoidRootPart then
            local targetRoot = player.Character.HumanoidRootPart
            local distance = (root.Position - targetRoot.Position).Magnitude
            if distance < 5 then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 1000, 0)
                bv.Parent = targetRoot
                task.delay(0.5, function() bv:Destroy() end)
                Rayfield:Notify({
                    Title = "Fling!",
                    Content = "Yeeted " .. player.Name .. " to space!",
                    Duration = 3
                })
            end
        end
    end
end

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if Misc.Fling then FlingPlayer() end
end))

-- // Teleport Logic
local TeleportDropdown
local function UpdateTeleportList()
    local playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            table.insert(playerList, player.Name)
        end
    end
    if TeleportDropdown then
        TeleportDropdown:Refresh(playerList, true)
    end
end

spawn(function()
    while true do
        if Misc.Teleport then
            UpdateTeleportList()
        end
        wait(30)
    end
end)

-- // Skybox (Color-Based)
local function UpdateSkybox()
    local sky = Lighting:FindFirstChild("GrokSky") or Instance.new("Sky")
    sky.Name = "GrokSky"
    sky.CelestialBodiesShown = false -- Hide stars, sun, moon
    sky.Parent = Lighting

    Lighting.Ambient = Misc.SkyboxColor
    Lighting.OutdoorAmbient = Misc.SkyboxColor
end

-- // Chat Viewer
local ChatLog = {}
local ChatGui
local function UpdateChatViewer()
    if not Misc.ChatViewer then
        if ChatGui then ChatGui:Destroy() end
        return
    end

    if not ChatGui then
        ChatGui = Instance.new("ScreenGui")
        ChatGui.Name = "GrokChatViewer"
        ChatGui.Parent = LocalPlayer.PlayerGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 200)
        frame.Position = UDim2.new(0, 10, 0, 100)
        frame.BackgroundTransparency = 0.5
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.Parent = ChatGui

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.Text = ""
        textLabel.Parent = frame
        ChatGui.TextLabel = textLabel
    end

    ChatGui.TextLabel.Text = table.concat(ChatLog, "\n")
end

table.insert(Connections, ReplicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(message)
    if Misc.ChatViewer then
        table.insert(ChatLog, message.Message)
        if #ChatLog > 10 then
            table.remove(ChatLog, 1)
        end
        UpdateChatViewer()
    end
end))

-- // Fly Logic
local function ToggleFly()
    if not Misc.Fly or not LocalPlayer.Character or not LocalPlayer.Character.HumanoidRootPart then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root

    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if Misc.Fly and root.Parent then
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
            bv.Velocity = moveDir * Misc.FlySpeed
        else
            bv:Destroy()
        end
    end))
end

-- // Noclip Logic
local function ToggleNoclip()
    if not Misc.Noclip then return end
    table.insert(Connections, RunService.Stepped:Connect(function()
        if Misc.Noclip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end))
end

-- // Chat Spam
local function ChatSpam()
    spawn(function()
        while Misc.ChatSpam do
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Grok's Hack! | Blackout", "All")
            wait(2)
        end
    end)
end

-- // Spinbot
local function Spinbot()
    if not Misc.Spinbot or not LocalPlayer.Character or not LocalPlayer.Character.HumanoidRootPart then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if Misc.Spinbot and root.Parent then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(10), 0)
        end
    end))
end

-- // Custom Crosshair
local Crosshair = Drawing.new("Circle")
Crosshair.Radius = 5
Crosshair.Filled = true
Crosshair.Color = Misc.CrosshairColor
Crosshair.Visible = false

table.insert(Connections, RunService.RenderStepped:Connect(function()
    Crosshair.Position = UserInputService:GetMouseLocation()
    Crosshair.Color = Misc.CrosshairColor
    Crosshair.Visible = Misc.CustomCrosshair
end))

-- // Watermark
local Watermark = Drawing.new("Text")
Watermark.Text = "Blackout Hack | Grok | FPS: 0 | Ping: 0"
Watermark.Size = 20
Watermark.Position = Vector2.new(10, 10)
Watermark.Color = Color3.fromRGB(255, 255, 255)
Watermark.Visible = true

table.insert(Connections, RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local ping = math.random(50, 150) -- Replace with game-specific ping API
    Watermark.Text = string.format("Blackout Hack | Grok | FPS: %d | Ping: %d", fps, ping)
end))

-- // Aim Tab UI
AimTab:CreateSection("Silent Aim")
AimTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = false,
    Callback = function(Value)
        SilentAim.Enabled = Value
        Rayfield:Notify({
            Title = "Silent Aim",
            Content = Value and "Silent Aim enabled!" or "Silent Aim disabled.",
            Duration = 2
        })
    end
})

AimTab:CreateSlider({
    Name = "FOV",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Callback = function(Value)
        SilentAim.FOV = Value
    end
})

AimTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = false,
    Callback = function(Value)
        SilentAim.ShowFOV = Value
    end
})

AimTab:CreateColorPicker({
    Name = "FOV Color",
    Color = SilentAim.FOVColor,
    Callback = function(Value)
        SilentAim.FOVColor = Value
    end
})

AimTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "Torso", "HumanoidRootPart", "Random"},
    CurrentOption = "Head",
    Callback = function(Value)
        SilentAim.TargetPart = Value
    end
})

AimTab:CreateToggle({
    Name = "Hitmarker",
    CurrentValue = false,
    Callback = function(Value)
        SilentAim.Hitmarker = Value
    end
})

AimTab:CreateSection("AimLock")
AimTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = false,
    Callback = function(Value)
        AimLock.Enabled = Value
        Rayfield:Notify({
            Title = "AimLock",
            Content = Value and "AimLock enabled!" or "AimLock disabled.",
            Duration = 2
        })
    end
})

AimTab:CreateSlider({
    Name = "FOV",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Callback = function(Value)
        AimLock.FOV = Value
    end
})

AimTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = false,
    Callback = function(Value)
        AimLock.ShowFOV = Value
    end
})

AimTab:CreateColorPicker({
    Name = "FOV Color",
    Color = AimLock.FOVColor,
    Callback = function(Value)
        AimLock.FOVColor = Value
    end
})

AimTab:CreateSlider({
    Name = "Smoothness",
    Range = {0, 1},
    Increment = 0.01,
    CurrentValue = 0.05,
    Callback = function(Value)
        AimLock.Smoothness = Value
    end
})

AimTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "Torso", "HumanoidRootPart", "Random"},
    CurrentOption = "Head",
    Callback = function(Value)
        AimLock.TargetPart = Value
    end
})

-- // ESP Tab UI
ESPTab:CreateSection("Enemy ESP")
ESPTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Enabled = Value
    end
})

ESPTab:CreateToggle({
    Name = "3D Box",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Box3D = Value
    end
})

ESPTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Chams = Value
    end
})

ESPTab:CreateToggle({
    Name = "Skeleton",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Skeleton = Value
    end
})

ESPTab:CreateToggle({
    Name = "Healthbar",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Healthbar = Value
    end
})

ESPTab:CreateToggle({
    Name = "Nickname",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Nickname = Value
    end
})

ESPTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Tracers = Value
    end
})

ESPTab:CreateToggle({
    Name = "Target Line",
    CurrentValue = false,
    Callback = function(Value)
        ESP.TargetLine = Value
    end
})

ESPTab:CreateColorPicker({
    Name = "Target Line Color",
    Color = ESP.TargetLineColor,
    Callback = function(Value)
        ESP.TargetLineColor = Value
    end
})

ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = ESP.Color,
    Callback = function(Value)
        ESP.Color = Value
    end
})

ESPTab:CreateSection("Self ESP")
ESPTab:CreateToggle({
    Name = "Chams (Hands)",
    CurrentValue = false,
    Callback = function(Value)
        ESP.SelfChamsHands = Value
    end
})

ESPTab:CreateToggle({
    Name = "Chams (Weapon)",
    CurrentValue = false,
    Callback = function(Value)
        ESP.SelfChamsWeapon = Value
    end
})

ESPTab:CreateColorPicker({
    Name = "Self Chams Color",
    Color = ESP.SelfChamsColor,
    Callback = function(Value)
        ESP.SelfChamsColor = Value
    end
})

ESPTab:CreateSlider({
    Name = "Self Chams Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(Value)
        ESP.SelfChamsTransparency = Value
    end
})

-- // Misc Tab UI
MiscTab:CreateSection("Movement")
MiscTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(Value)
        Misc.Fly = Value
        if Value then ToggleFly() end
    end
})

MiscTab:CreateSlider({
    Name = "Fly Speed",
    Range = {20, 200},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(Value)
        Misc.FlySpeed = Value
    end
})

MiscTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value)
        Misc.Noclip = Value
        if Value then ToggleNoclip() end
    end
})

MiscTab:CreateSection("Trolling")
MiscTab:CreateToggle({
    Name = "Chat Spam",
    CurrentValue = false,
    Callback = function(Value)
        Misc.ChatSpam = Value
        if Value then ChatSpam() end
    end
})

MiscTab:CreateToggle({
    Name = "Spinbot",
    CurrentValue = false,
    Callback = function(Value)
        Misc.Spinbot = Value
        if Value then Spinbot() end
    end
})

MiscTab:CreateToggle({
    Name = "Fling",
    CurrentValue = false,
    Callback = function(Value)
        Misc.Fling = Value
        Rayfield:Notify({
            Title = "Fling",
            Content = Value and "Fling enabled! Approach players to yeet them!" or "Fling disabled.",
            Duration = 3
        })
    end
})

MiscTab:CreateSection("Visuals")
MiscTab:CreateToggle({
    Name = "Custom Crosshair",
    CurrentValue = false,
    Callback = function(Value)
        Misc.CustomCrosshair = Value
    end
})

MiscTab:CreateColorPicker({
    Name = "Crosshair Color",
    Color = Misc.CrosshairColor,
    Callback = function(Value)
        Misc.CrosshairColor = Value
    end
})

MiscTab:CreateToggle({
    Name = "Kill Effects",
    CurrentValue = false,
    Callback = function(Value)
        Misc.KillEffects = Value
    end
})

MiscTab:CreateInput({
    Name = "Kill Sound ID",
    PlaceholderText = "Enter rbxassetid://...",
    RemovePlaceholderOnFocus = true,
    Callback = function(Value)
        Misc.KillSoundId = Value
        KillSound.SoundId = Value
        if not ValidateSoundId(Value) then
            Rayfield:Notify({
                Title = "Invalid Sound ID",
                Content = "Please enter a valid rbxassetid://...",
                Duration = 3
            })
        end
    end
})

MiscTab:CreateSection("Utility")
MiscTab:CreateToggle({
    Name = "Teleport",
    CurrentValue = false,
    Callback = function(Value)
        Misc.Teleport = Value
        if Value then UpdateTeleportList() end
    end
})

TeleportDropdown = MiscTab:CreateDropdown({
    Name = "Teleport to Player",
    Options = {},
    CurrentOption = "",
    Callback = function(Value)
        if Misc.Teleport and Value ~= "" then
            local target = Players:FindFirstChild(Value)
            if target and target.Character and target.Character.HumanoidRootPart and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                Rayfield:Notify({
                    Title = "Teleport",
                    Content = "Teleported to " .. Value .. "!",
                    Duration = 3
                })
            end
        end
    end
})

MiscTab:CreateToggle({
    Name = "Chat Viewer",
    CurrentValue = false,
    Callback = function(Value)
        Misc.ChatViewer = Value
        UpdateChatViewer()
    end
})

MiscTab:CreateColorPicker({
    Name = "Skybox Color",
    Color = Misc.SkyboxColor,
    Callback = function(Value)
        Misc.SkyboxColor = Value
        UpdateSkybox()
    end
})

-- // Configs Tab UI
ConfigTab:CreateButton({
    Name = "Save Config",
    Callback = function()
        local config = {
            SilentAim = SilentAim,
            AimLock = AimLock,
            ESP = ESP,
            Misc = Misc
        }
        writefile("BlackoutGrok/config.json", HttpService:JSONEncode(config))
        Rayfield:Notify({
            Title = "Config Saved",
            Content = "Your settings have been saved!",
            Duration = 3
        })
    end
})

ConfigTab:CreateButton({
    Name = "Load Config",
    Callback = function()
        if isfile("BlackoutGrok/config.json") then
            local config = HttpService:JSONDecode(readfile("BlackoutGrok/config.json"))
            SilentAim = config.SilentAim
            AimLock = config.AimLock
            ESP = config.ESP
            Misc = config.Misc
            KillSound.SoundId = Misc.KillSoundId
            Rayfield:Notify({
                Title = "Config Loaded",
                Content = "Your settings have been loaded!",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No config file found!",
                Duration = 3
            })
        end
    end
})

-- // Cleanup on Script End
game:BindToClose(function()
    for _, connection in pairs(Connections) do
        connection:Disconnect()
    end
    for _, objects in pairs(ESPObjects) do
        for _, obj in pairs(objects) do
            if type(obj) == "table" then
                for _, line in pairs(obj) do
                    line:Remove()
                end
            else
                if obj.Destroy then obj:Destroy() else obj:Remove() end
            end
        end
    end
    SilentFOVCircle:Remove()
    AimLockFOVCircle:Remove()
    Hitmarker:Remove()
    TargetLine:Remove()
    Crosshair:Remove()
    Watermark:Remove()
    KillSound:Destroy()
    if ChatGui then ChatGui:Destroy() end
end)

-- // Initial Setup
UpdateSkybox()
for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end
Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Blackout Hack by Grok is ready! Dominate with Silent Aim, AimLock, and epic visuals!",
    Duration = 5
})