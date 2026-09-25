-- SimpleAdmin Hub (Client Edition)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer

-- GUI Container with Executor fallbacks
local guiParent
pcall(function()
    if gethui then
        guiParent = gethui()
    elseif game:GetService("CoreGui") then
        guiParent = game:GetService("CoreGui")
    end
end)
if not guiParent then
    guiParent = LocalPlayer:WaitForChild("PlayerGui")
end

if guiParent:FindFirstChild("AdminHubGUI") then
    guiParent.AdminHubGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

--------------------------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------------------------
local Main = Instance.new("Frame")
Main.Name = "MainHub"
Main.Size = UDim2.new(0, 520, 0, 360)
Main.Position = UDim2.new(0.5, -260, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 48, 60)
MainStroke.Thickness = 1.2
MainStroke.Parent = Main

-- Top Title Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(24, 26, 33)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "<b>SIMPLE</b> ADMIN HUB"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(240, 245, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

--------------------------------------------------------------------
-- SIDEBAR (TABS)
--------------------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 23, 29)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 6)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 10)
SidePad.Parent = Sidebar

-- Content Container
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -130, 1, -42)
Content.Position = UDim2.new(0, 130, 0, 42)
Content.BackgroundTransparency = 1
Content.Parent = Main

--------------------------------------------------------------------
-- TAB SWITCHING SYSTEM
--------------------------------------------------------------------
local tabs = {}

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(160, 165, 180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.page.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
            t.btn.TextColor3 = Color3.fromRGB(160, 165, 180)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    tabs[name] = {btn = btn, page = page}
    return page
end

--------------------------------------------------------------------
-- UI COMPONENT HELPERS
--------------------------------------------------------------------
local function addActionButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(28, 31, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 235, 245)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function addToggle(page, text, callback)
    local state = false

    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
    f.Parent = page

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = f

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220, 225, 235)
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local tglBtn = Instance.new("TextButton")
    tglBtn.Size = UDim2.new(0, 42, 0, 22)
    tglBtn.Position = UDim2.new(1, -52, 0.5, -11)
    tglBtn.BackgroundColor3 = Color3.fromRGB(45, 48, 60)
    tglBtn.Text = ""
    tglBtn.Parent = f

    local tglCorner = Instance.new("UICorner")
    tglCorner.CornerRadius = UDim.new(1, 0)
    tglCorner.Parent = tglBtn

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = UDim2.new(0, 3, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    dot.BorderSizePixel = 0
    dot.Parent = tglBtn

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    tglBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            tglBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            dot:TweenPosition(UDim2.new(1, -19, 0.5, -8), "Out", "Quad", 0.15, true)
        else
            tglBtn.BackgroundColor3 = Color3.fromRGB(45, 48, 60)
            dot:TweenPosition(UDim2.new(0, 3, 0.5, -8), "Out", "Quad", 0.15, true)
        end
        callback(state)
    end)
end

local function addValueInput(page, text, defaultVal, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
    f.Parent = page

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = f

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -120, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220, 225, 235)
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 52, 0, 24)
    box.Position = UDim2.new(1, -104, 0.5, -12)
    box.BackgroundColor3 = Color3.fromRGB(36, 40, 52)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 13
    box.Parent = f

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 4)
    bc.Parent = box

    local setBtn = Instance.new("TextButton")
    setBtn.Size = UDim2.new(0, 40, 0, 24)
    setBtn.Position = UDim2.new(1, -48, 0.5, -12)
    setBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    setBtn.Text = "Set"
    setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setBtn.Font = Enum.Font.GothamBold
    setBtn.TextSize = 11
    setBtn.Parent = f

    local setCorner = Instance.new("UICorner")
    setCorner.CornerRadius = UDim.new(0, 4)
    setCorner.Parent = setBtn

    local function applyValue()
        local n = tonumber(box.Text)
        if n then
            callback(n)
            setBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            task.delay(0.4, function()
                if setBtn and setBtn.Parent then
                    setBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                end
            end)
        else
            box.Text = tostring(defaultVal)
        end
    end

    setBtn.MouseButton1Click:Connect(applyValue)
    box.FocusLost:Connect(function(enter)
        applyValue()
    end)
end

--------------------------------------------------------------------
-- CREATE PAGES & FUNCTIONALITY
--------------------------------------------------------------------
local playerPage = createTab("Player")
local combatPage = createTab("Combat")
local visualsPage = createTab("Visuals")
local worldPage = createTab("World")

-- Initial Tab activation
tabs["Player"].btn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
tabs["Player"].btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tabs["Player"].page.Visible = true

-- 1. PLAYER PAGE
local desiredWalkSpeed = 16
local desiredJumpPower = 50
local desiredHipHeight = 0
local lockSpeed = false

local function getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 3)
end

local function applyMovementStats(hum)
    if not hum then return end
    pcall(function()
        hum.WalkSpeed = desiredWalkSpeed
        hum.UseJumpPower = true
        hum.JumpPower = desiredJumpPower
        hum.HipHeight = desiredHipHeight
    end)
end

-- Persist movement stats across character deaths/respawns
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        task.wait(0.2)
        applyMovementStats(hum)
    end
end)

-- Continuous enforcer for games that try to reset WalkSpeed every frame
RunService.Heartbeat:Connect(function()
    if lockSpeed then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= desiredWalkSpeed then
            hum.WalkSpeed = desiredWalkSpeed
        end
    end
end)

addValueInput(playerPage, "Walk Speed", 16, function(val)
    desiredWalkSpeed = val
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = val end
end)

addToggle(playerPage, "Lock Walk Speed (Bypass In-Game Resets)", function(enabled)
    lockSpeed = enabled
    if lockSpeed then
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = desiredWalkSpeed end
    end
end)

addValueInput(playerPage, "Jump Power", 50, function(val)
    desiredJumpPower = val
    local hum = getHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = val
    end
end)

addValueInput(playerPage, "Hip Height", 0, function(val)
    desiredHipHeight = val
    local hum = getHumanoid()
    if hum then hum.HipHeight = val end
end)

-- Noclip feature
local noclip = false
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

addToggle(playerPage, "Noclip (Walk Through Walls)", function(enabled)
    noclip = enabled
end)

-- Fly feature
local flying = false
local flySpeed = 50
local flyBodyPos, flyBodyGyro

local function toggleFly(enable)
    flying = enable
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    if flying then
        flyBodyPos = Instance.new("BodyPosition")
        flyBodyPos.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyPos.Position = root.Position
        flyBodyPos.Parent = root

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.CFrame = root.CFrame
        flyBodyGyro.Parent = root

        task.spawn(function()
            while flying do
                local cam = workspace.CurrentCamera
                local dir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end

                flyBodyPos.Position = flyBodyPos.Position + (dir * (flySpeed / 30))
                flyBodyGyro.CFrame = cam.CFrame
                task.wait()
            end
            if flyBodyPos then flyBodyPos:Destroy() end
            if flyBodyGyro then flyBodyGyro:Destroy() end
        end)
    else
        if flyBodyPos then flyBodyPos:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
    end
end

addToggle(playerPage, "Fly Mode", function(enabled)
    toggleFly(enabled)
end)

addActionButton(playerPage, "Reset Character", function()
    local hum = getHumanoid()
    if hum then hum.Health = 0 end
end)

--------------------------------------------------------------------
-- 2. COMBAT PAGE (Aimbot & Targeting)
--------------------------------------------------------------------
local aimbotEnabled = false
local aimbotRequireHold = false
local aimbotTeamCheck = false
local aimbotWallCheck = false
local showFovCircle = false
local aimbotFovRadius = 150
local aimbotSmoothness = 0.2
local aimbotTargetPart = "Head"

-- FOV Circle Visual using Drawing API or GUI fallback
local fovCircleDrawing = nil
pcall(function()
    if Drawing and Drawing.new then
        fovCircleDrawing = Drawing.new("Circle")
        fovCircleDrawing.Thickness = 1.5
        fovCircleDrawing.NumSides = 36
        fovCircleDrawing.Radius = aimbotFovRadius
        fovCircleDrawing.Filled = false
        fovCircleDrawing.Visible = false
        fovCircleDrawing.Color = Color3.fromRGB(0, 170, 255)
        fovCircleDrawing.Transparency = 1
    end
end)

local fovCircleGuiFrame = nil
if not fovCircleDrawing then
    fovCircleGuiFrame = Instance.new("Frame")
    fovCircleGuiFrame.Name = "FOVCircle"
    fovCircleGuiFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircleGuiFrame.BackgroundTransparency = 1
    fovCircleGuiFrame.Visible = false
    fovCircleGuiFrame.Parent = ScreenGui

    local fovCorner = Instance.new("UICorner")
    fovCorner.CornerRadius = UDim.new(1, 0)
    fovCorner.Parent = fovCircleGuiFrame

    local fovStroke = Instance.new("UIStroke")
    fovStroke.Color = Color3.fromRGB(0, 170, 255)
    fovStroke.Thickness = 1.5
    fovStroke.Parent = fovCircleGuiFrame
end

local function getClosestPlayerToCursor()
    local Camera = workspace.CurrentCamera
    if not Camera then return nil end

    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local shortestDistance = aimbotFovRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Team check
            if aimbotTeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                continue
            end

            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(aimbotTargetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")

            if hum and hum.Health > 0 and part then
                -- Wall check / Visibility check
                if aimbotWallCheck then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                    raycastParams.IgnoreWater = true

                    local rayDirection = part.Position - Camera.CFrame.Position
                    local rayResult = workspace:Raycast(Camera.CFrame.Position, rayDirection, raycastParams)
                    if rayResult and not rayResult.Instance:IsDescendantOf(char) then
                        continue -- Blocked by wall
                    end
                end

                -- Screen projection check (WorldToScreenPoint matches GetMouseLocation)
                local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    local Camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()

    -- FOV Circle Rendering
    if showFovCircle and aimbotEnabled and Camera then
        if fovCircleDrawing then
            fovCircleDrawing.Position = mousePos
            fovCircleDrawing.Radius = aimbotFovRadius
            fovCircleDrawing.Visible = true
        elseif fovCircleGuiFrame then
            fovCircleGuiFrame.Size = UDim2.new(0, aimbotFovRadius * 2, 0, aimbotFovRadius * 2)
            fovCircleGuiFrame.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
            fovCircleGuiFrame.Visible = true
        end
    else
        if fovCircleDrawing then fovCircleDrawing.Visible = false end
        if fovCircleGuiFrame then fovCircleGuiFrame.Visible = false end
    end

    -- Aimbot Tracking
    if aimbotEnabled and Camera then
        local isHolding = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        local shouldAim = not aimbotRequireHold or isHolding

        if shouldAim then
            local targetPlayer = getClosestPlayerToCursor()
            if targetPlayer and targetPlayer.Character then
                local part = targetPlayer.Character:FindFirstChild(aimbotTargetPart) or targetPlayer.Character:FindFirstChild("Head")
                if part then
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                    if aimbotSmoothness > 0 then
                        local alpha = math.clamp(1 - aimbotSmoothness, 0.05, 1)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
                    else
                        Camera.CFrame = targetCFrame
                    end
                end
            end
        end
    end
end)

addToggle(combatPage, "Enable Aimbot", function(enabled)
    aimbotEnabled = enabled
end)

addToggle(combatPage, "Hold Right-Click To Aim", function(enabled)
    aimbotRequireHold = enabled
end)

addToggle(combatPage, "Team Check (Ignore Teammates)", function(enabled)
    aimbotTeamCheck = enabled
end)

addToggle(combatPage, "Wall Check (Visibility Filter)", function(enabled)
    aimbotWallCheck = enabled
end)

addToggle(combatPage, "Show FOV Circle", function(enabled)
    showFovCircle = enabled
end)

addValueInput(combatPage, "FOV Radius", 150, function(val)
    aimbotFovRadius = math.clamp(val, 10, 1000)
end)

addValueInput(combatPage, "Smoothness (0 = Snap, 9 = Slow)", 2, function(val)
    aimbotSmoothness = math.clamp(val / 10, 0, 0.9)
end)

local targetPartBtn
targetPartBtn = addActionButton(combatPage, "Target Part: Head", function()
    if aimbotTargetPart == "Head" then
        aimbotTargetPart = "HumanoidRootPart"
        targetPartBtn.Text = "Target Part: HumanoidRootPart"
    else
        aimbotTargetPart = "Head"
        targetPartBtn.Text = "Target Part: Head"
    end
end)

-- 3. VISUALS PAGE (ESP / Highlights)
local espActive = false
local espHighlights = {}

local function applyESP(player)
    if player == LocalPlayer then return end
    if player.Character and not player.Character:FindFirstChild("AdminESP") then
        local hl = Instance.new("Highlight")
        hl.Name = "AdminESP"
        hl.FillColor = Color3.fromRGB(255, 60, 60)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Parent = player.Character
        table.insert(espHighlights, hl)
    end
end

addToggle(visualsPage, "Player ESP (Chams)", function(enabled)
    espActive = enabled
    if espActive then
        for _, p in pairs(Players:GetPlayers()) do
            applyESP(p)
            p.CharacterAdded:Connect(function()
                if espActive then task.wait(0.5); applyESP(p) end
            end)
        end
    else
        for _, hl in pairs(espHighlights) do
            if hl and hl.Parent then hl:Destroy() end
        end
        espHighlights = {}
    end
end)

addValueInput(visualsPage, "Field Of View (FOV)", 70, function(val)
    workspace.CurrentCamera.FieldOfView = math.clamp(val, 20, 120)
end)

-- 3. WORLD PAGE
addActionButton(worldPage, "Full Brightness (No Shadows)", function()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").ClockTime = 14
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end)

addActionButton(worldPage, "Remove Fog", function()
    game:GetService("Lighting").FogEnd = 9e9
end)

--------------------------------------------------------------------
-- TOGGLE KEYBIND & FLOATING BUTTON
--------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-- Floating Quick-Open Badge
local FloatingBadge = Instance.new("TextButton")
FloatingBadge.Size = UDim2.new(0, 100, 0, 30)
FloatingBadge.Position = UDim2.new(0, 16, 0.5, -15)
FloatingBadge.BackgroundColor3 = Color3.fromRGB(24, 26, 33)
FloatingBadge.Text = "Toggle Menu"
FloatingBadge.TextColor3 = Color3.fromRGB(0, 170, 255)
FloatingBadge.Font = Enum.Font.GothamBold
FloatingBadge.TextSize = 12
FloatingBadge.Active = true
FloatingBadge.Draggable = true
FloatingBadge.Parent = ScreenGui

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 8)
BadgeCorner.Parent = FloatingBadge

local BadgeStroke = Instance.new("UIStroke")
BadgeStroke.Color = Color3.fromRGB(50, 55, 70)
BadgeStroke.Thickness = 1
BadgeStroke.Parent = FloatingBadge

FloatingBadge.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)
