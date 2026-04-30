-- D-DAY Aimbot + ESP | Fixed Version
-- Debug: Press F9 to see console messages

local success, err = pcall(function()
    print("[TUPAISH] Script loading...")

    -- Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local UserInput = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local LP = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    print("[TUPAISH] Services loaded")

    -- Config
    local S = {
        Aimbot = {
            Enabled = false,
            FOV = 150,
            Smooth = 0.16,
            TeamCheck = true,
            VisCheck = true,
            AimPart = "Head"
        },
        ESP = {
            Enabled = false,
            Boxes = false,
            Tracers = false,
            Names = false,
            Health = false,
            TeamCheck = false,
            Distance = false,
            Skeleton = false,
            Box = Color3.fromRGB(255, 50, 50),
            Tracer = Color3.fromRGB(255, 255, 255),
            Text = Color3.fromRGB(255, 255, 255),
            TeamColor = Color3.fromRGB(0, 255, 0)
        },
        Visuals = {
        },
        Misc = {
            TriggerBot = false,
            FullBright = false,
            NoRecoil = false,
            SpeedHack = false,
            Noclip = false
        },
        Movement = { Speed = 1 }
    }

    if not Drawing then
        warn("[TUPAISH] Drawing API not found!")
        return
    end

    -- UI Parent
    local uiParent = CoreGui
    pcall(function() uiParent = gethui() end)

    -- Create UI - Original Style
    local SG = Instance.new("ScreenGui")
    SG.Name = "D"
    SG.ResetOnSpawn = false
    SG.Parent = uiParent

    local MF = Instance.new("Frame", SG)
    MF.Size = UDim2.new(0, 280, 0, 420)
    MF.Position = UDim2.new(0, 40, 0, 40)
    MF.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    MF.BorderSizePixel = 0
    Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 6)

    -- Title bar
    local TB = Instance.new("Frame", MF)
    TB.Size = UDim2.new(1, 0, 0, 28)
    TB.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 6)

    local TL = Instance.new("TextLabel", TB)
    TL.Text = "Tupaish Hub"
    TL.Size = UDim2.new(1, -36, 1, 0)
    TL.Position = UDim2.new(0, 8, 0, 0)
    TL.BackgroundTransparency = 1
    TL.TextColor3 = Color3.fromRGB(240, 240, 240)
    TL.Font = Enum.Font.GothamBold
    TL.TextSize = 13
    TL.TextXAlignment = Enum.TextXAlignment.Left

    local CB = Instance.new("TextButton", TB)
    CB.Size = UDim2.new(0, 24, 0, 24)
    CB.Position = UDim2.new(1, -28, 0, 2)
    CB.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CB.Text = "X"
    CB.TextColor3 = Color3.new(1, 1, 1)
    CB.Font = Enum.Font.GothamBold
    Instance.new("UICorner", CB).CornerRadius = UDim.new(0, 4)

    -- Tabs
    local TabBar = Instance.new("Frame", MF)
    TabBar.Size = UDim2.new(1, 0, 0, 30)
    TabBar.Position = UDim2.new(0, 0, 0, 28)
    TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

    local TabContents = {}
    local Connections = {}

    local closeConn = CB.MouseButton1Click:Connect(function() SG.Enabled = false end)
    table.insert(Connections, closeConn)

    local function CreateTab(name, index)
        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(1/4, 0, 1, 0)
        btn.Position = UDim2.new((index-1)/4, 0, 0, 0)
        btn.BackgroundColor3 = index == 1 and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(30, 30, 35)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        
        local content = Instance.new("ScrollingFrame", MF)
        content.Size = UDim2.new(1, -12, 1, -68)
        content.Position = UDim2.new(0, 6, 0, 62)
        content.BackgroundTransparency = 1
        content.Visible = index == 1
        content.ScrollBarThickness = 4
        Instance.new("UIListLayout", content).Padding = UDim.new(0, 5)
        
        TabContents[index] = content
        
        local tabConn = btn.MouseButton1Click:Connect(function()
            for i, c in pairs(TabContents) do
                c.Visible = (i == index)
            end
            for _, b in ipairs(TabBar:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        end)
        table.insert(Connections, tabConn)
    end

    CreateTab("AIMBOT", 1)
    CreateTab("ESP", 2)
    CreateTab("MOVE", 3)
    CreateTab("VISUALS", 4)

    -- UI Helpers
    local CT = TabContents[1]

    local function MakeToggle(text, default, callback, parent)
        local row = Instance.new("Frame", parent or CT)
        row.Size = UDim2.new(1, 0, 0, 26)
        row.BackgroundTransparency = 1
        
        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 40, 0, 20)
        btn.Position = UDim2.new(1, -44, 0.5, -10)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        btn.Text = default and "ON" or "OFF"
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        local toggleConn = btn.MouseButton1Click:Connect(function()
            local on = btn.Text == "ON"
            local new = not on
            btn.BackgroundColor3 = new and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            btn.Text = new and "ON" or "OFF"
            callback(new)
        end)
        table.insert(Connections, toggleConn)
        
        return btn
    end

    local function MakeSlider(text, min, max, default, callback, parent)
        local row = Instance.new("Frame", parent or CT)
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundTransparency = 1
        
        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(1, 0, 0, 16)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. tostring(default)
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local track = Instance.new("Frame", row)
        track.Size = UDim2.new(1, 0, 0, 6)
        track.Position = UDim2.new(0, 0, 0, 22)
        track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)
        
        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
        
        local knob = Instance.new("TextButton", track)
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.Text = ""
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 6)
        
        local dragging = false
        local function update(input)
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = min + (max - min) * pos
            val = math.floor(val * 100) / 100
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -6, 0.5, -6)
            label.Text = text .. ": " .. tostring(val)
            callback(val)
        end
        
        local knobConn = knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        table.insert(Connections, knobConn)
        
        local sliderMoveConn = UserInput.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
        end)
        table.insert(Connections, sliderMoveConn)
        
        local sliderEndConn = UserInput.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        table.insert(Connections, sliderEndConn)
        
        local trackConn = track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then update(input); dragging = true end
        end)
        table.insert(Connections, trackConn)
    end

    local function MakeDropdown(text, options, defaultIndex, callback, parent)
        local row = Instance.new("Frame", parent or CT)
        row.Size = UDim2.new(1, 0, 0, 26)
        row.BackgroundTransparency = 1
        
        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local idx = defaultIndex
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 90, 0, 20)
        btn.Position = UDim2.new(1, -94, 0.5, -10)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = options[idx]
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        local dropConn = btn.MouseButton1Click:Connect(function()
            idx = idx % #options + 1
            btn.Text = options[idx]
            callback(options[idx])
        end)
        table.insert(Connections, dropConn)
    end

    -- Script control
    local Running = true
    local MainConnection = nil
    local DefaultWalkSpeed = 16

    -- ESP Objects (defined before UI so kill button can access them)
    local ESPObjects = {}
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 64
    FOVCircle.Radius = S.Aimbot.FOV
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)

    -- Build UI content
    CT = TabContents[1]
    local aimbotToggle = MakeToggle("Aimbot", S.Aimbot.Enabled, function(v) S.Aimbot.Enabled = v end, CT)
    MakeToggle("TeamCheck", S.Aimbot.TeamCheck, function(v) S.Aimbot.TeamCheck = v end, CT)
    MakeToggle("VisCheck", S.Aimbot.VisCheck, function(v) S.Aimbot.VisCheck = v end, CT)
    MakeSlider("FOV", 10, 500, S.Aimbot.FOV, function(v) S.Aimbot.FOV = v end, CT)
    MakeSlider("Smooth", 0.01, 1, 0.16, function(v) S.Aimbot.Smooth = v end, CT)
    MakeDropdown("Part", {"Head", "Torso", "HumanoidRootPart"}, 1, function(v) S.Aimbot.AimPart = v end, CT)
    MakeToggle("NoRecoil", S.Misc.NoRecoil, function(v) S.Misc.NoRecoil = v end, CT)

    -- Kill Script button
    local killBtn = Instance.new("TextButton", CT)
    killBtn.Size = UDim2.new(1, -10, 0, 26)
    killBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    killBtn.Text = "STOP SCRIPT"
    killBtn.TextColor3 = Color3.new(1, 1, 1)
    killBtn.Font = Enum.Font.GothamBold
    killBtn.TextSize = 12
    Instance.new("UICorner", killBtn).CornerRadius = UDim.new(0, 4)
    local killConn = killBtn.MouseButton1Click:Connect(function()
        Running = false
        if MainConnection then
            MainConnection:Disconnect()
            MainConnection = nil
        end
        SG:Destroy()
        -- Hide and remove FOV circle
        pcall(function()
            FOVCircle.Visible = false
            FOVCircle:Remove()
        end)
        -- Remove all ESP directly from table
        for player, data in pairs(ESPObjects) do
            pcall(function()
                data.Box.Visible = false
                data.Box:Remove()
            end)
            pcall(function()
                data.Tracer.Visible = false
                data.Tracer:Remove()
            end)
            pcall(function()
                data.Name.Visible = false
                data.Name:Remove()
            end)
            pcall(function()
                data.HealthBar.Visible = false
                data.HealthBar:Remove()
            end)
            pcall(function()
                data.Distance.Visible = false
                data.Distance:Remove()
            end)
            -- Remove skeleton lines
            if data.Skeleton then
                for _, line in ipairs(data.Skeleton) do
                    pcall(function()
                        line.Visible = false
                        line:Remove()
                    end)
                end
            end
            ESPObjects[player] = nil
        end
        -- Reset walkspeed when stopping script
        pcall(function()
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end)
        print("[TUPAISH] Script stopped completely")
        return
    end)
    table.insert(Connections, killConn)

    CT = TabContents[2]
    MakeToggle("ESP", S.ESP.Enabled, function(v) S.ESP.Enabled = v end, CT)
    MakeToggle("Team", S.ESP.TeamCheck, function(v) S.ESP.TeamCheck = v end, CT)
    MakeToggle("Boxes", S.ESP.Boxes, function(v) S.ESP.Boxes = v end, CT)
    MakeToggle("Tracers", S.ESP.Tracers, function(v) S.ESP.Tracers = v end, CT)
    MakeToggle("Names", S.ESP.Names, function(v) S.ESP.Names = v end, CT)
    MakeToggle("Health", S.ESP.Health, function(v) S.ESP.Health = v end, CT)
    MakeToggle("Distance", S.ESP.Distance, function(v) S.ESP.Distance = v end, CT)
    MakeToggle("Skeleton", S.ESP.Skeleton, function(v) S.ESP.Skeleton = v end, CT)

    CT = TabContents[3]
    MakeToggle("SpeedHack", S.Misc.SpeedHack, function(v) 
        S.Misc.SpeedHack = v 
        if not v then
            pcall(function()
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = DefaultWalkSpeed end
            end)
        end
    end, CT)
    MakeSlider("Speed", 1, 5, S.Movement.Speed, function(v) S.Movement.Speed = v end, CT)
    MakeToggle("Noclip", S.Misc.Noclip, function(v) S.Misc.Noclip = v end, CT)

    CT = TabContents[4]
    MakeToggle("FullBright", S.Misc.FullBright, function(v)
        S.Misc.FullBright = v
        pcall(function()
            local Lighting = game:GetService("Lighting")
            if v then
                Lighting.Brightness = 3
            else
                Lighting.Brightness = 2
            end
        end)
    end, CT)

    -- Drag functionality
    local dragging, dragStart, startPos = false, nil, nil
    local dragStartConn = TB.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MF.Position
        end
    end)
    table.insert(Connections, dragStartConn)

    local dragEndConn = TB.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    table.insert(Connections, dragEndConn)

    local dragMoveConn = UserInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MF.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    table.insert(Connections, dragMoveConn)

    -- Hotkeys
    local hotkeyConn = UserInput.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            SG.Enabled = not SG.Enabled
        elseif not gameProcessed and input.KeyCode == Enum.KeyCode.E then
            S.Aimbot.Enabled = not S.Aimbot.Enabled
            -- Update UI button
            if aimbotToggle then
                aimbotToggle.BackgroundColor3 = S.Aimbot.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
                aimbotToggle.Text = S.Aimbot.Enabled and "ON" or "OFF"
            end
            print("[TUPAISH] Aimbot: " .. tostring(S.Aimbot.Enabled))
        end
    end)
    table.insert(Connections, hotkeyConn)

    print("[TUPAISH] UI built")

    -- ESP Functions
    local function WorldToScreen(pos)
        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
        return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
    end

    local function IsTeammate(player)
        if not S.ESP.TeamCheck and not S.Aimbot.TeamCheck then return false end
        if player.Team and LP.Team then
            return player.Team == LP.Team
        end
        return false
    end

    local function IsVisible(targetPart)
        local success, result = pcall(function()
            if not targetPart then return false end
            
            local char = targetPart.Parent
            if not char then return false end
            
            local origin = Camera.CFrame.Position
            local destination = targetPart.Position
            local distance = (destination - origin).Magnitude
            local direction = (destination - origin).Unit * distance
            
            -- Ignore local player character and target character
            local ignoreList = {}
            if LP.Character then
                table.insert(ignoreList, LP.Character)
            end
            table.insert(ignoreList, char)
            
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = ignoreList
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.IgnoreWater = true
            
            local rayResult = Workspace:Raycast(origin, direction, raycastParams)
            
            -- If raycast hits nothing, target is visible
            if not rayResult then return true end
            
            -- If raycast hits the target character, it's visible
            if rayResult.Instance:IsDescendantOf(char) then
                return true
            end
            
            -- Something is blocking the view
            return false
        end)
        
        -- If error occurred, default to treating as visible (safer fallback)
        if not success then return true end
        return result
    end

    local function GetClosestPlayer()
        local closest = nil
        local shortest = S.Aimbot.FOV
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LP then continue end
            if S.Aimbot.TeamCheck and IsTeammate(player) then continue end
            
            local char = player.Character
            if not char then continue end
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 0 then continue end
            
            -- Smart part selection
            local partName = S.Aimbot.AimPart
            if partName == "HumanoidRootPart" then
                partName = math.random() > 0.5 and "Head" or "Torso"
            end
            
            local aimPart = char:FindFirstChild(partName)
            if not aimPart then
                aimPart = char:FindFirstChild("Head") or char:FindFirstChild("Torso")
            end
            
            if aimPart then
                local screenPos, onScreen = WorldToScreen(aimPart.Position)
                if onScreen then
                    -- Visibility check - skip if behind walls and VisCheck is enabled
                    if S.Aimbot.VisCheck and not IsVisible(aimPart) then continue end
                    
                    local dist = (screenPos - screenCenter).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = aimPart
                    end
                end
            end
        end
        return closest
    end

    local function CreateESP(player)
        -- Check if ESP already exists for this player
        if ESPObjects[player] then
            return
        end
        
        local box = Drawing.new("Square")
        box.Thickness = 1
        box.Transparency = 1
        box.Color = S.ESP.Box
        box.Filled = false
        
        local tracer = Drawing.new("Line")
        tracer.Thickness = 1
        tracer.Transparency = 1
        tracer.Color = S.ESP.Tracer
        
        local name = Drawing.new("Text")
        name.Size = 13
        name.Transparency = 1
        name.Color = S.ESP.Text
        name.Center = true
        
        local healthBar = Drawing.new("Square")
        healthBar.Thickness = 1
        healthBar.Filled = true
        
        local distText = Drawing.new("Text")
        distText.Size = 11
        distText.Transparency = 1
        distText.Color = S.ESP.Text
        distText.Center = true
        
        -- Skeleton lines (18 connections for R15 character)
        local skeletonLines = {}
        for i = 1, 18 do
            local line = Drawing.new("Line")
            line.Thickness = 2.5
            line.Transparency = 1
            line.Color = S.ESP.Box
            table.insert(skeletonLines, line)
        end
        
        ESPObjects[player] = {
            Box = box,
            Tracer = tracer,
            Name = name,
            HealthBar = healthBar,
            Distance = distText,
            Skeleton = skeletonLines
        }
    end

    local function RemoveESP(player)
        local data = ESPObjects[player]
        if data then
            pcall(function()
                data.Box:Remove()
                data.Tracer:Remove()
                data.Name:Remove()
                data.HealthBar:Remove()
                data.Distance:Remove()
            end)
            -- Remove skeleton lines
            if data.Skeleton then
                for _, line in ipairs(data.Skeleton) do
                    pcall(function()
                        line.Visible = false
                        line:Remove()
                    end)
                end
            end
            ESPObjects[player] = nil
        end
    end

    local function UpdateESP()
        for player, data in pairs(ESPObjects) do
            local char = player.Character
            if not char or not player.Parent then
                data.Box.Visible = false
                data.Tracer.Visible = false
                data.Name.Visible = false
                data.HealthBar.Visible = false
                data.Distance.Visible = false
                if data.Skeleton then
                    for _, line in ipairs(data.Skeleton) do
                        pcall(function() line.Visible = false end)
                    end
                end
            else
                local hum = char:FindFirstChildOfClass("Humanoid")
                -- Hide ESP if player is dead
                if not hum or hum.Health <= 0 then
                    data.Box.Visible = false
                    data.Tracer.Visible = false
                    data.Name.Visible = false
                    data.HealthBar.Visible = false
                    data.Distance.Visible = false
                    if data.Skeleton then
                        for _, line in ipairs(data.Skeleton) do
                            pcall(function() line.Visible = false end)
                        end
                    end
                elseif player == LP then
                    data.Box.Visible = false
                    data.Tracer.Visible = false
                    data.Name.Visible = false
                    data.HealthBar.Visible = false
                    data.Distance.Visible = false
                    if data.Skeleton then
                        for _, line in ipairs(data.Skeleton) do
                            pcall(function() line.Visible = false end)
                        end
                    end
                elseif not S.ESP.TeamCheck and IsTeammate(player) then
                    data.Box.Visible = false
                    data.Tracer.Visible = false
                    data.Name.Visible = false
                    data.HealthBar.Visible = false
                    data.Distance.Visible = false
                    if data.Skeleton then
                        for _, line in ipairs(data.Skeleton) do
                            pcall(function() line.Visible = false end)
                        end
                    end
                else
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local rootPos, onScreen = WorldToScreen(hrp.Position)
                        if onScreen then
                            local legPos = WorldToScreen(hrp.Position - Vector3.new(0, 3, 0))
                            local boxHeight = (rootPos - legPos).Magnitude
                            local boxWidth = boxHeight * 0.6
                            
                            -- Use team color for teammates
                            local isTeammate = IsTeammate(player)
                            local espColor = isTeammate and S.ESP.TeamColor or S.ESP.Box
                            
                            if S.ESP.Boxes then
                                data.Box.Size = Vector2.new(boxWidth, boxHeight)
                                data.Box.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2)
                                data.Box.Color = espColor
                                data.Box.Visible = true
                            else
                                data.Box.Visible = false
                            end
                            
                            if S.ESP.Tracers then
                                data.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                                data.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + boxHeight/2)
                                data.Tracer.Color = espColor
                                data.Tracer.Visible = true
                            else
                                data.Tracer.Visible = false
                            end
                            
                            if S.ESP.Names then
                                data.Name.Position = Vector2.new(rootPos.X, rootPos.Y - boxHeight/2 - 14)
                                data.Name.Text = player.Name
                                data.Name.Color = espColor
                                data.Name.Visible = true
                            else
                                data.Name.Visible = false
                            end
                            
                            if S.ESP.Distance then
                                local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
                                data.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxHeight/2 + 14)
                                data.Distance.Text = tostring(dist) .. " studs"
                                data.Distance.Color = espColor
                                data.Distance.Visible = true
                            else
                                data.Distance.Visible = false
                            end
                            
                            if S.ESP.Health then
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if hum then
                                    local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                    local barWidth = boxWidth * 0.8
                                    local barHeight = 3
                                    data.HealthBar.Size = Vector2.new(barWidth * healthPercent, barHeight)
                                    data.HealthBar.Position = Vector2.new(rootPos.X - barWidth/2, rootPos.Y - boxHeight/2 - 8)
                                    data.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                                    data.HealthBar.Visible = true
                                else
                                    data.HealthBar.Visible = false
                                end
                            else
                                data.HealthBar.Visible = false
                            end
                            
                            -- Skeleton ESP
                            if S.ESP.Skeleton and data.Skeleton then
                                local connections = {
                                    {"Head", "UpperTorso"},
                                    {"UpperTorso", "LowerTorso"},
                                    {"UpperTorso", "LeftUpperArm"},
                                    {"LeftUpperArm", "LeftLowerArm"},
                                    {"LeftLowerArm", "LeftHand"},
                                    {"UpperTorso", "RightUpperArm"},
                                    {"RightUpperArm", "RightLowerArm"},
                                    {"RightLowerArm", "RightHand"},
                                    {"LowerTorso", "LeftUpperLeg"},
                                    {"LeftUpperLeg", "LeftLowerLeg"},
                                    {"LeftLowerLeg", "LeftFoot"},
                                    {"LowerTorso", "RightUpperLeg"},
                                    {"RightUpperLeg", "RightLowerLeg"},
                                    {"RightLowerLeg", "RightFoot"}
                                }
                                
                                for i, conn in ipairs(connections) do
                                    local part1 = char:FindFirstChild(conn[1])
                                    local part2 = char:FindFirstChild(conn[2])
                                    local line = data.Skeleton[i]
                                    
                                    if part1 and part2 and line then
                                        local pos1, onScreen1 = WorldToScreen(part1.Position)
                                        local pos2, onScreen2 = WorldToScreen(part2.Position)
                                        
                                        if onScreen1 and onScreen2 then
                                            line.From = pos1
                                            line.To = pos2
                                            line.Color = espColor
                                            line.Visible = true
                                        else
                                            line.Visible = false
                                        end
                                    else
                                        line.Visible = false
                                    end
                                end
                            else
                                if data.Skeleton then
                                    for _, line in ipairs(data.Skeleton) do
                                        pcall(function() line.Visible = false end)
                                    end
                                end
                            end
                        else
                            data.Box.Visible = false
                            data.Tracer.Visible = false
                            data.Name.Visible = false
                            data.HealthBar.Visible = false
                            data.Distance.Visible = false
                            if data.Skeleton then
                                for _, line in ipairs(data.Skeleton) do
                                    pcall(function() line.Visible = false end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Initialize ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            CreateESP(player)
        end
    end

    local playerAddedConn = Players.PlayerAdded:Connect(function(player)
        if player ~= LP then
            CreateESP(player)
        end
    end)
    table.insert(Connections, playerAddedConn)

    local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)
    table.insert(Connections, playerRemovingConn)

    -- Main Loop
    MainConnection = RunService.RenderStepped:Connect(function()
        if not Running then return end

        -- FOV Circle
        FOVCircle.Radius = S.Aimbot.FOV
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        FOVCircle.Visible = S.Aimbot.Enabled
        
        -- ESP
        if S.ESP.Enabled then
            UpdateESP()
        else
            for _, data in pairs(ESPObjects) do
                data.Box.Visible = false
                data.Tracer.Visible = false
                data.Name.Visible = false
                data.HealthBar.Visible = false
                data.Distance.Visible = false
            end
        end
        
        -- Aimbot
        if S.Aimbot.Enabled then
            local aimTarget = GetClosestPlayer()
            if aimTarget then
                -- Aim directly at target part
                local targetPos = Camera:WorldToViewportPoint(aimTarget.Position)
                local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local targetScreen = Vector2.new(targetPos.X, targetPos.Y)
                
                local delta = (targetScreen - mousePos) * S.Aimbot.Smooth
                pcall(function()
                    if mousemoverel then mousemoverel(delta.X, delta.Y) end
                end)
                
            end
        end
        
        -- SpeedHack (balanced speed to avoid anti-cheat)
        if S.Misc.SpeedHack then
            pcall(function()
                local char = LP.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local targetSpeed = DefaultWalkSpeed + (S.Movement.Speed * 4)
                        hum.WalkSpeed = targetSpeed
                    end
                end
            end)
        end
        
        -- Noclip
        if S.Misc.Noclip then
            local char = LP.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CanCollide = false end)
                    end
                end
            end
        end
    end)
    table.insert(Connections, MainConnection)

    -- NoRecoil
    if LP.Character then
        local noRecoilConn = LP.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and S.Misc.NoRecoil then
                for _, v in ipairs(child:GetDescendants()) do
                    if v:IsA("NumberValue") and (v.Name:lower():match("recoil") or v.Name:lower():match("kick") or v.Name:lower():match("spread")) then
                        pcall(function() v.Value = 0 end)
                    end
                end
            end
        end)
        table.insert(Connections, noRecoilConn)
    end

    -- Handle walkspeed on character respawn
    local charAddedConn = LP.CharacterAdded:Connect(function(char)
        wait(0.2)
        pcall(function()
            local hum = char:WaitForChild("Humanoid", 2)
            if hum then
                -- Capture default walkspeed on first spawn
                if DefaultWalkSpeed == 16 and hum.WalkSpeed ~= 16 + (S.Movement.Speed * 4) then
                    DefaultWalkSpeed = hum.WalkSpeed
                end
                if S.Misc.SpeedHack and hum.Health > 0 then
                    hum.WalkSpeed = DefaultWalkSpeed + (S.Movement.Speed * 4)
                end
            end
        end)
    end)
    table.insert(Connections, charAddedConn)

    print("[TUPAISH] Loaded successfully!")
end)

if not success then
    warn("[TUPAISH] Error: " .. tostring(err))
end
