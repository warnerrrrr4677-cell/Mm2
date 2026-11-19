--[[
    WXNNXRX HUB V16 MERGED | Delta Executor
    Modulos incluidos: ESP + WallHop V4 + Movement + Visual+ + Aim + Hitbox Preview + World Tools
    V16 MERGED: integra el paquete Android v14 en la interfaz Dark Glass existente.
    Nota: las funciones son locales al cliente; no cambian el estado autoritativo del servidor.
]]

--// Servicios
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HapticService = game:GetService("HapticService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

--// Evitar duplicados
local GUI_NAME = "WXNNXRX_HUB"
pcall(function()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg and pg:FindFirstChild(GUI_NAME) then
        pg[GUI_NAME]:Destroy()
    end
end)

--// Estado
local State = {
    ESPEnabled = false,
    Glow = true,
    Box = false,
    Names = true,
    Health = true,
    Distance = true,
    TeamColors = true,
    EnemiesOnly = false,
    ShowEnemies = true,
    ShowTeam = true,
    LookLine = false,
    ESPRange = 1500,
    ESPColor = Color3.fromRGB(115, 95, 255),

    WallHopEnabled = false,
    AutoWallHop = false,
    SelectedBrickColor = nil,
    SelectedColor = nil,
    SelectingColor = false,

    -- Modulos adicionales
    SpeedEnabled = false,
    SpeedValue = 24,
    JumpEnabled = false,
    JumpPowerValue = 65,
    InfiniteJumpEnabled = false,
    NoClipEnabled = false,
    AutoVoidRecovery = false,
    LastSafeCFrame = nil,
    Waypoints = {},
    FullBright = false,
    CustomFOV = false,
    CameraFOV = 80,
    CrosshairEnabled = false,
    HUDEnabled = false,

    -- Aim assist local para pruebas en la experiencia propia
    AimEnabled = false,
    AimFOV = 140,
    AimSmoothness = 10,
    AimTeamCheck = true,
    AimVisibleCheck = true,
    AimTargetPart = "Head",

    -- Vista previa visual de hitboxes; no altera hitboxes del servidor
    HitboxPreview = false,
    HitboxScale = 1.6,

    -- Expansiones adicionales (sin temas RGB)
    NPCFinderEnabled = false,
    ItemFinderEnabled = false,
    SpectateEnabled = false,
    CameraZoom = 16,
    LowGraphics = false,
    MM2RoleESP = false,
    MM2DroppedWeaponESP = false,
    TouchFeedback = true,
    UIAudio = true,

    -- WXNNXRX Android v14 feature pack
    BombAutoLoop = false,
    BombBusy = false,
    BombCooldown = 0,
    SpeedGlitchCooldown = 0,
    CameraAimbot = false,
    TriggerBot = false,
    Prediction = true,
    AntiAim = false,
    RoleESP = false,
    RoleESPDistance = false,
    WeaponESP = false,
    AutoFarmCoins = false,
    AutoFarmCandy = false,
    AimbotSmooth = 0.35,
}

local lightingDefaults = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    ExposureCompensation = Lighting.ExposureCompensation,
}
local cameraDefaults = setmetatable({}, { __mode = "k" })
local humanoidDefaults = setmetatable({}, { __mode = "k" })
local lastCamera = Workspace.CurrentCamera
local measuredFPS = 0
local hitboxFolder = Instance.new("Folder")
hitboxFolder.Name = "WXNNXRX_HitboxPreview"
hitboxFolder.Parent = Workspace
local hitboxObjects = {}
local hitboxAccumulator = 0
local noclipOriginal = setmetatable({}, { __mode = "k" })
local noclipAccumulator = 0
local recoveryAccumulator = 0
local waypointMarkers = {}
local waypointFolder = Instance.new("Folder")
waypointFolder.Name = "WXNNXRX_WaypointMarkers"
waypointFolder.Parent = Workspace
local finderFolder = Instance.new("Folder")
finderFolder.Name = "WXNNXRX_FinderVisuals"
finderFolder.Parent = Workspace
local finderObjects = {}

-- MM2/Android additions adapted from the supplied v14 source.
-- These are local visual diagnostics only; no remote events or forced gameplay actions.
local mm2Folder = Instance.new("Folder")
mm2Folder.Name = "WXNNXRX_MM2Visuals"
mm2Folder.Parent = Workspace
local mm2RoleObjects = {}
local mm2WeaponObjects = {}
local mm2Accumulator = 0
local mm2StatusLabel
local finderAccumulator = 0
local sessionStarted = os.clock()
local spectateIndex = 0
local savedCameraSubject = nil
local savedCameraType = nil
local savedZoomMin = LocalPlayer.CameraMinZoomDistance
local savedZoomMax = LocalPlayer.CameraMaxZoomDistance
local lowGraphicsDefaults = {}
local lowGraphicsActive = false
local aimCircle
local aimTarget = nil

local alive = true
local connections = {}
local espObjects = {}
local selectionConnections = {}
local wallHopBusy = false
local lastWallHop = 0
local autoAccumulator = 0
local espAccumulator = 0

local function track(connection)
    if connection then
        table.insert(connections, connection)
    end
    return connection
end

local function disconnectAll(list)
    for _, connection in ipairs(list) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(list)
end

local function safeUnit(vector, fallback)
    if not vector or vector.Magnitude < 0.001 then
        return fallback
    end
    return vector.Unit
end

local function isSameTeam(otherPlayer)
    return LocalPlayer.Team ~= nil and otherPlayer.Team ~= nil and LocalPlayer.Team == otherPlayer.Team
end

local function setFullBright(enabled)
    State.FullBright = enabled and true or false
    if State.FullBright then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        Lighting.ExposureCompensation = 0
    else
        for property, value in pairs(lightingDefaults) do
            pcall(function() Lighting[property] = value end)
        end
    end
end

local function restoreCameraFOV()
    for camera, originalFOV in pairs(cameraDefaults) do
        if camera and camera.Parent then
            pcall(function() camera.FieldOfView = originalFOV end)
        end
        cameraDefaults[camera] = nil
    end
end

local function updateCameraFOV()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    if camera ~= lastCamera then
        lastCamera = camera
    end
    if State.CustomFOV then
        if cameraDefaults[camera] == nil then
            cameraDefaults[camera] = camera.FieldOfView
        end
        camera.FieldOfView = State.CameraFOV
    elseif cameraDefaults[camera] ~= nil then
        camera.FieldOfView = cameraDefaults[camera]
        cameraDefaults[camera] = nil
    end
end

local function getLocalHumanoid()
    local character = LocalPlayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function applyMovement(humanoid)
    humanoid = humanoid or getLocalHumanoid()
    if not humanoid or not humanoid.Parent then return end

    if not humanoidDefaults[humanoid] then
        humanoidDefaults[humanoid] = {
            WalkSpeed = humanoid.WalkSpeed,
            JumpPower = humanoid.JumpPower,
            JumpHeight = humanoid.JumpHeight,
        }
    end
    local baseline = humanoidDefaults[humanoid]

    if State.SpeedEnabled then
        humanoid.WalkSpeed = State.SpeedValue
    else
        humanoid.WalkSpeed = baseline.WalkSpeed
    end

    if State.JumpEnabled then
        if humanoid.UseJumpPower then
            humanoid.JumpPower = State.JumpPowerValue
        else
            local gravity = math.max(Workspace.Gravity, 1)
            humanoid.JumpHeight = (State.JumpPowerValue * State.JumpPowerValue) / (2 * gravity)
        end
    else
        humanoid.JumpPower = baseline.JumpPower
        humanoid.JumpHeight = baseline.JumpHeight
    end
end

local function restoreMovement()
    State.SpeedEnabled = false
    State.JumpEnabled = false
    applyMovement()
end

--// Noclip local: conserva y restaura CanCollide de cada pieza
local function applyNoClipToCharacter(character)
    if not character then return end
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            if noclipOriginal[descendant] == nil then
                noclipOriginal[descendant] = descendant.CanCollide
            end
            descendant.CanCollide = false
        end
    end
end

local function restoreNoClip()
    State.NoClipEnabled = false
    for part, originalValue in pairs(noclipOriginal) do
        if part and part.Parent then
            pcall(function() part.CanCollide = originalValue end)
        end
        noclipOriginal[part] = nil
    end
end

local function setNoClip(enabled)
    State.NoClipEnabled = enabled and true or false
    if State.NoClipEnabled then
        applyNoClipToCharacter(LocalPlayer.Character)
    else
        restoreNoClip()
    end
end

--// Contenedor del ESP: todos los objetos se crean localmente
local espFolder = Instance.new("Folder")
espFolder.Name = "WXNNXRX_LocalESP"
espFolder.Parent = Workspace

local function removeESP(targetPlayer)
    local data = espObjects[targetPlayer]
    if not data then return end
    for _, object in pairs(data) do
        if typeof(object) == "Instance" then
            pcall(function() object:Destroy() end)
        end
    end
    espObjects[targetPlayer] = nil
end

local function createESP(targetPlayer, character)
    removeESP(targetPlayer)
    if not character then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "WXNNXRX_Highlight"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.72
    highlight.OutlineTransparency = 0.08
    highlight.FillColor = State.ESPColor
    highlight.OutlineColor = State.ESPColor
    highlight.Enabled = State.Glow
    highlight.Parent = espFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "WXNNXRX_PlayerInfo"
    billboard.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.fromOffset(190, 52)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = true
    billboard.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local info = Instance.new("TextLabel")
    info.Name = "Info"
    info.BackgroundTransparency = 1
    info.Size = UDim2.fromScale(1, 1)
    info.Font = Enum.Font.GothamSemibold
    info.TextSize = 12
    info.TextColor3 = Color3.fromRGB(245, 245, 255)
    info.TextStrokeTransparency = 0.35
    info.TextWrapped = true
    info.Text = targetPlayer.DisplayName
    info.Parent = billboard

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "WXNNXRX_Box"
    box.Adornee = character:FindFirstChild("HumanoidRootPart")
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.68
    box.Color3 = State.ESPColor
    box.Visible = State.Box
    box.Parent = espFolder

    local line = Instance.new("Part")
    line.Name = "WXNNXRX_LookLine"
    line.Anchored = true
    line.CanCollide = false
    line.CanTouch = false
    line.CanQuery = false
    line.CastShadow = false
    line.Material = Enum.Material.Neon
    line.Color = State.ESPColor
    line.Transparency = 0.18
    line.Size = Vector3.new(0.055, 0.055, 1)
    line.Transparency = State.LookLine and 0.18 or 1
    line.Parent = espFolder

    espObjects[targetPlayer] = {
        Highlight = highlight,
        Billboard = billboard,
        Info = info,
        Box = box,
        LookLine = line,
    }
end

local function updateESPForPlayer(targetPlayer)
    if targetPlayer == LocalPlayer then return end

    local character = targetPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local localCharacter = LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

    if not State.ESPEnabled or not character or not humanoid or not root or humanoid.Health <= 0 or not localRoot then
        removeESP(targetPlayer)
        return
    end

    local sameTeam = isSameTeam(targetPlayer)
    if (sameTeam and not State.ShowTeam) or (not sameTeam and not State.ShowEnemies) then
        removeESP(targetPlayer)
        return
    end
    if State.EnemiesOnly and sameTeam then
        removeESP(targetPlayer)
        return
    end

    local distance = (root.Position - localRoot.Position).Magnitude
    if distance > State.ESPRange then
        removeESP(targetPlayer)
        return
    end

    local data = espObjects[targetPlayer]
    if not data or data.Highlight.Adornee ~= character then
        createESP(targetPlayer, character)
        data = espObjects[targetPlayer]
    end
    if not data then return end

    local color = State.ESPColor
    if State.TeamColors and targetPlayer.Team then
        color = targetPlayer.TeamColor.Color
    end

    data.Highlight.Enabled = State.Glow
    data.Highlight.FillColor = color
    data.Highlight.OutlineColor = color

    data.Billboard.Adornee = character:FindFirstChild("Head") or root
    data.Box.Adornee = root
    data.Box.Visible = State.Box
    data.Box.Color3 = color
    pcall(function() data.Box.Size = character:GetExtentsSize() end)

    local lines = {}
    if State.Names then table.insert(lines, targetPlayer.DisplayName) end
    if State.Health then
        table.insert(lines, string.format("HP: %d/%d", math.max(0, math.floor(humanoid.Health)), math.floor(humanoid.MaxHealth)))
    end
    if State.Distance then table.insert(lines, string.format("%.0f studs", distance)) end
    data.Info.Text = #lines > 0 and table.concat(lines, "  |  ") or " "
    data.Info.TextColor3 = color:Lerp(Color3.new(1, 1, 1), 0.38)

    data.LookLine.Transparency = State.LookLine and 0.18 or 1
    if State.LookLine then
        local head = character:FindFirstChild("Head")
        local origin = head and head.Position or root.Position
        local direction = head and head.CFrame.LookVector or root.CFrame.LookVector
        local length = 7
        local center = origin + direction * (length / 2)
        data.LookLine.Size = Vector3.new(0.055, 0.055, length)
        data.LookLine.CFrame = CFrame.lookAt(center, center + direction)
        data.LookLine.Color = color
    end
end

local function refreshAllESP()
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        updateESPForPlayer(targetPlayer)
    end
    for targetPlayer in pairs(espObjects) do
        if not targetPlayer.Parent then removeESP(targetPlayer) end
    end
end

--// WallHop: deteccion de pared con raycasts + Blockcast
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

local function getWallRaycastResult()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    raycastParams.FilterDescendantsInstances = { character }
    local bestResult = nil
    local bestDistance = 2.6
    local rootCF = root.CFrame

    for index = 0, 7 do
        local angle = math.rad(index * 45)
        local direction = (rootCF * CFrame.Angles(0, angle, 0)).LookVector
        local result = Workspace:Raycast(root.Position, direction * 2.5, raycastParams)
        if result and result.Instance and result.Distance < bestDistance then
            bestDistance = result.Distance
            bestResult = result
        end
    end

    local blockSize = Vector3.new(1.5, 1, 0.5)
    local blockOrigin = rootCF * CFrame.new(0, -1, -0.5)
    local blockResult = nil
    pcall(function()
        blockResult = Workspace:Blockcast(blockOrigin, blockSize, rootCF.LookVector * 1.8, raycastParams)
    end)
    if blockResult and blockResult.Instance and blockResult.Distance < bestDistance then
        bestResult = blockResult
    end

    return bestResult
end

local function executeWallHop(wallResult, source)
    if not alive or wallHopBusy or not wallResult then return end
    if os.clock() - lastWallHop < 0.22 then return end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera
    if not humanoid or not root or not camera or humanoid.Health <= 0 then return end

    local normal = wallResult.Normal
    local away = Vector3.new(normal.X, 0, normal.Z)
    if away.Magnitude < 0.1 then
        local toWall = Vector3.new(wallResult.Position.X - root.Position.X, 0, wallResult.Position.Z - root.Position.Z)
        away = -toWall
    end
    away = safeUnit(away, safeUnit(Vector3.new(-root.CFrame.LookVector.X, 0, -root.CFrame.LookVector.Z), Vector3.new(0, 0, 1)))

    local cameraLook = camera.CFrame.LookVector
    local flatCameraLook = safeUnit(Vector3.new(cameraLook.X, 0, cameraLook.Z), away)
    local dot = math.clamp(away:Dot(flatCameraLook), -1, 1)
    local angle = math.acos(dot)
    local cross = away:Cross(flatCameraLook)
    local sign = -math.sign(cross.Y)
    local maxAngle = math.rad(20)
    if sign < 0 then maxAngle = math.rad(100) end
    if sign == 0 then angle = 0 end
    local adjusted = CFrame.Angles(0, sign * math.min(angle, maxAngle), 0):VectorToWorldSpace(away)
    adjusted = safeUnit(Vector3.new(adjusted.X, 0, adjusted.Z), away)

    wallHopBusy = true
    lastWallHop = os.clock()
    task.spawn(function()
        local ok, err = pcall(function()
            if not alive or not root.Parent or not humanoid.Parent then return end
            root.CFrame = CFrame.lookAt(root.Position, root.Position + adjusted)
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            local jumpVelocity = humanoid.UseJumpPower and humanoid.JumpPower or math.sqrt(2 * Workspace.Gravity * humanoid.JumpHeight)
            local velocity = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(velocity.X, math.max(velocity.Y, jumpVelocity), velocity.Z)
            task.wait(0.12)
            if alive and root.Parent then
                local towardWall = -away
                root.CFrame = CFrame.lookAt(root.Position, root.Position + towardWall)
            end
        end)
        if not ok then warn("[WXNNXRX] WallHop: " .. tostring(err)) end
        wallHopBusy = false
    end)
end

local function performManualWallHop()
    local result = getWallRaycastResult()
    if result then
        executeWallHop(result, "Button")
    end
end

local function clearSelectionMode()
    State.SelectingColor = false
    disconnectAll(selectionConnections)
end

local function startColorSelection()
    clearSelectionMode()
    State.SelectingColor = true
    local mouse = LocalPlayer:GetMouse()

    table.insert(selectionConnections, mouse.Button1Down:Connect(function()
        if not alive or not State.SelectingColor then return end
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            State.SelectedBrickColor = target.BrickColor
            State.SelectedColor = target.Color
            State.SelectingColor = false
            disconnectAll(selectionConnections)
        end
    end))

    pcall(function()
        table.insert(selectionConnections, UserInputService.TouchTapInWorld:Connect(function(_, processed)
            if processed or not alive or not State.SelectingColor then return end
            local target = mouse.Target
            if target and target:IsA("BasePart") then
                State.SelectedBrickColor = target.BrickColor
                State.SelectedColor = target.Color
                State.SelectingColor = false
                disconnectAll(selectionConnections)
            end
        end))
    end)
end

--// UI: Dark Glass, responsive y compatible con toque
local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiParent = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
    if typeof(gethui) == "function" then guiParent = gethui() end
end)
screenGui.Parent = guiParent

--// Indicador FOV para Aim Assist
local aimCircle = Instance.new("Frame")
aimCircle.Name = "WXNNXRX_AimFOV"
aimCircle.AnchorPoint = Vector2.new(0.5, 0.5)
aimCircle.Position = UDim2.fromScale(0.5, 0.5)
aimCircle.Size = UDim2.fromOffset(State.AimFOV * 2, State.AimFOV * 2)
aimCircle.BackgroundTransparency = 1
aimCircle.BorderSizePixel = 0
aimCircle.Visible = false
aimCircle.ZIndex = 90
aimCircle.Parent = screenGui
local aimCircleCorner = Instance.new("UICorner")
aimCircleCorner.CornerRadius = UDim.new(1, 0)
aimCircleCorner.Parent = aimCircle
local aimCircleStroke = Instance.new("UIStroke")
aimCircleStroke.Color = Color3.fromRGB(151, 126, 255)
aimCircleStroke.Thickness = 1.5
aimCircleStroke.Transparency = 0.12
aimCircleStroke.Parent = aimCircle

--// HUD y mira local
local hudLabel = Instance.new("TextLabel")
hudLabel.Name = "WXNNXRX_StatusHUD"
hudLabel.ZIndex = 100
hudLabel.AnchorPoint = Vector2.new(0, 1)
hudLabel.Position = UDim2.new(0, 12, 1, -12)
hudLabel.Size = UDim2.fromOffset(218, 58)
hudLabel.BackgroundColor3 = Color3.fromRGB(13, 14, 23)
hudLabel.BackgroundTransparency = 0.22
hudLabel.BorderSizePixel = 0
hudLabel.Font = Enum.Font.GothamSemibold
hudLabel.TextSize = 10
hudLabel.TextColor3 = Color3.fromRGB(225, 222, 245)
hudLabel.TextXAlignment = Enum.TextXAlignment.Left
hudLabel.TextYAlignment = Enum.TextYAlignment.Center
hudLabel.Text = "FPS: -- | Ping: --\nXYZ: --"
hudLabel.Visible = false
hudLabel.Parent = screenGui

local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 8)
hudCorner.Parent = hudLabel
local hudPadding = Instance.new("UIPadding")
hudPadding.PaddingLeft = UDim.new(0, 9)
hudPadding.Parent = hudLabel

local crosshair = Instance.new("Frame")
crosshair.Name = "WXNNXRX_Crosshair"
crosshair.ZIndex = 100
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.fromScale(0.5, 0.5)
crosshair.Size = UDim2.fromOffset(22, 22)
crosshair.BackgroundTransparency = 1
crosshair.Visible = false
crosshair.Parent = screenGui

local function makeCrosshairPart(name, size, position)
    local part = Instance.new("Frame")
    part.Name = name
    part.ZIndex = 101
    part.Size = size
    part.Position = position
    part.BackgroundColor3 = Color3.fromRGB(245, 245, 255)
    part.BorderSizePixel = 0
    part.Parent = crosshair
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(20, 20, 30)
    stroke.Thickness = 1
    stroke.Parent = part
    return part
end
makeCrosshairPart("Top", UDim2.fromOffset(2, 6), UDim2.new(0.5, -1, 0, 0))
makeCrosshairPart("Bottom", UDim2.fromOffset(2, 6), UDim2.new(0.5, -1, 1, -6))
makeCrosshairPart("Left", UDim2.fromOffset(6, 2), UDim2.new(0, 0, 0.5, -1))
makeCrosshairPart("Right", UDim2.fromOffset(6, 2), UDim2.new(1, -6, 0.5, -1))

local function corner(instance, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius or 10)
    item.Parent = instance
    return item
end

local function outline(instance, color, transparency, thickness)
    local item = Instance.new("UIStroke")
    item.Color = color or Color3.fromRGB(100, 95, 160)
    item.Transparency = transparency or 0.5
    item.Thickness = thickness or 1
    item.Parent = instance
    return item
end

local function makeLabel(parent, text, size, color, font)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = color or Color3.fromRGB(235, 235, 245)
    label.Font = font or Enum.Font.Gotham
    label.TextSize = size or 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
local isSmall = viewport.X < 620
local compactMode = isSmall
local panelWidth = math.max(220, math.min(560, math.floor(viewport.X * 0.94), math.max(220, viewport.X - 16)))
local panelHeight = math.max(230, math.min(580, math.floor(viewport.Y * 0.84), math.max(230, viewport.Y - 18)))
local sidebarWidth = isSmall and 58 or 128

local COLORS = {
    Background = Color3.fromRGB(14, 15, 24),
    Panel = Color3.fromRGB(19, 20, 32),
    PanelSoft = Color3.fromRGB(30, 30, 46),
    PanelHover = Color3.fromRGB(43, 40, 66),
    Accent = Color3.fromRGB(115, 95, 255),
    AccentLight = Color3.fromRGB(151, 126, 255),
    AccentSoft = Color3.fromRGB(58, 49, 94),
    Text = Color3.fromRGB(245, 243, 255),
    Muted = Color3.fromRGB(174, 171, 195),
    Subtle = Color3.fromRGB(135, 133, 157),
    Success = Color3.fromRGB(128, 230, 173),
    Danger = Color3.fromRGB(190, 76, 100),
    Track = Color3.fromRGB(62, 62, 80),
}

local shadow = Instance.new("Frame")
shadow.Name = "WXNNXRX_Shadow"
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.fromScale(0.5, 0.5)
shadow.Size = UDim2.fromOffset(panelWidth + 14, panelHeight + 14)
shadow.BackgroundColor3 = Color3.new(0, 0, 0)
shadow.BackgroundTransparency = 0.58
shadow.BorderSizePixel = 0
shadow.ZIndex = 1
shadow.Parent = screenGui
corner(shadow, 22)

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(panelWidth, panelHeight)
main.BackgroundColor3 = COLORS.Background
main.BackgroundTransparency = 0.06
main.BorderSizePixel = 0
main.ClipsDescendants = false
main.ZIndex = 2
main.Parent = screenGui
corner(main, 17)
outline(main, COLORS.AccentLight, 0.30, 1.25)

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 26, 47)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 14, 24)),
})
gradient.Rotation = 24
gradient.Parent = main

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 52)
topbar.BackgroundColor3 = Color3.fromRGB(24, 22, 40)
topbar.BackgroundTransparency = 0.05
topbar.BorderSizePixel = 0
topbar.ZIndex = 3
topbar.Parent = main
corner(topbar, 17)
local topGradient = Instance.new("UIGradient")
topGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 33, 65)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 22, 36)),
})
topGradient.Parent = topbar

local accentLine = Instance.new("Frame")
accentLine.Name = "AccentLine"
accentLine.Position = UDim2.new(0, 14, 1, -2)
accentLine.Size = UDim2.new(1, -28, 0, 2)
accentLine.BackgroundColor3 = COLORS.Accent
accentLine.BorderSizePixel = 0
accentLine.ZIndex = 4
accentLine.Parent = topbar
corner(accentLine, 2)

local title = makeLabel(topbar, "WXNNXRX  /  HUB", 14, COLORS.Text, Enum.Font.GothamBold)
title.Name = "Title"
title.Position = UDim2.fromOffset(16, 0)
title.Size = UDim2.new(1, -112, 1, 0)
title.ZIndex = 5

local function makeTopButton(name, symbol, xOffset, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Position = UDim2.new(1, xOffset, 0.5, 0)
    button.Size = UDim2.fromOffset(30, 29)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = symbol
    button.TextColor3 = COLORS.Text
    button.TextSize = 17
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.ZIndex = 6
    button.Parent = topbar
    corner(button, 9)
    return button
end

local minimizeButton = makeTopButton("Minimize", "—", -43, Color3.fromRGB(61, 57, 86))
local closeButton = makeTopButton("Close", "×", -9, Color3.fromRGB(124, 49, 75))

local sidebar = Instance.new("ScrollingFrame")
sidebar.Name = "Sidebar"
sidebar.Position = UDim2.fromOffset(0, 52)
sidebar.Size = UDim2.new(0, sidebarWidth, 1, -52)
sidebar.BackgroundColor3 = Color3.fromRGB(17, 18, 29)
sidebar.BackgroundTransparency = 0.12
sidebar.BorderSizePixel = 0
sidebar.CanvasSize = UDim2.new()
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
sidebar.ScrollBarThickness = 2
sidebar.ScrollBarImageColor3 = COLORS.AccentLight
sidebar.Active = true
sidebar.ZIndex = 4
sidebar.Parent = main

local body = Instance.new("Frame")
body.Name = "Body"
body.Position = UDim2.new(0, sidebarWidth, 0, 52)
body.Size = UDim2.new(1, -sidebarWidth, 1, -52)
body.BackgroundTransparency = 1
body.ClipsDescendants = true
body.ZIndex = 4
body.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 7)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = sidebar
local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 14)
tabPadding.PaddingLeft = UDim.new(0, isSmall and 7 or 9)
tabPadding.PaddingRight = UDim.new(0, isSmall and 7 or 9)
tabPadding.Parent = sidebar

local pages = {}
local tabButtons = {}
local tabIndicators = {}
local tabIcons = {}
local activeTab = "Home"
local minimized = false
local dragging = false
local pulseHaptic, playUIAudio

local function selectTab(name)
    if not pages[name] then return end
    activeTab = name
    for pageName, page in pairs(pages) do
        local selected = pageName == name
        page.Visible = selected
        if selected then page.CanvasPosition = Vector2.new(0, 0) end
    end
    for tabName, tab in pairs(tabButtons) do
        local selected = tabName == name
        TweenService:Create(tab, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = selected and 0.08 or 0.56,
            TextColor3 = selected and COLORS.Text or COLORS.Muted,
        }):Play()
        local indicator = tabIndicators[tabName]
        if indicator then
            TweenService:Create(indicator, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundTransparency = selected and 0 or 1,
                Size = UDim2.fromOffset(3, selected and 22 or 14),
            }):Play()
        end
    end
    title.Text = "WXNNXRX  /  " .. string.upper(name)
end

local function makePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = COLORS.AccentLight
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.Visible = false
    page.ZIndex = 4
    page.Parent = body

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 14)
    padding.PaddingBottom = UDim.new(0, 18)
    padding.PaddingLeft = UDim.new(0, isSmall and 10 or 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = page

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 9)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    pages[name] = page
    return page
end

local function addTab(name, iconText)
    tabIcons[name] = iconText
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = COLORS.PanelHover
    button.BackgroundTransparency = 0.56
    button.BorderSizePixel = 0
    button.Text = isSmall and iconText or (iconText .. "   " .. name)
    button.TextColor3 = COLORS.Muted
    button.TextSize = isSmall and 17 or 10
    button.Font = Enum.Font.GothamSemibold
    button.TextXAlignment = isSmall and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    button.AutoButtonColor = false
    button.ZIndex = 5
    button.Parent = sidebar
    corner(button, 9)
    if not isSmall then
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 10)
        pad.Parent = button
    end
    local indicator = Instance.new("Frame")
    indicator.Name = "ActiveIndicator"
    indicator.Position = UDim2.new(0, 0, 0.5, -9)
    indicator.Size = UDim2.fromOffset(3, 14)
    indicator.BackgroundColor3 = COLORS.AccentLight
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 7
    indicator.Parent = button
    corner(indicator, 3)
    tabButtons[name] = button
    tabIndicators[name] = indicator
    track(button.Activated:Connect(function()
        if alive then pulseHaptic(); playUIAudio(true); selectTab(name) end
    end))
end

local function refreshResponsiveLayout()
    local currentCamera = Workspace.CurrentCamera
    local size = currentCamera and currentCamera.ViewportSize or viewport
    viewport = size
    isSmall = size.X < 620
    compactMode = isSmall
    panelWidth = math.max(220, math.min(560, math.floor(size.X * 0.94), math.max(220, size.X - 16)))
    panelHeight = math.max(230, math.min(580, math.floor(size.Y * 0.84), math.max(230, size.Y - 18)))
    sidebarWidth = isSmall and 58 or 128
    main.Size = UDim2.fromOffset(panelWidth, minimized and 52 or panelHeight)
    shadow.Size = UDim2.fromOffset(panelWidth + 14, (minimized and 52 or panelHeight) + 14)
    sidebar.Size = UDim2.new(0, sidebarWidth, 1, -52)
    body.Position = UDim2.new(0, sidebarWidth, 0, 52)
    body.Size = UDim2.new(1, -sidebarWidth, 1, -52)
    tabPadding.PaddingLeft = UDim.new(0, isSmall and 7 or 9)
    tabPadding.PaddingRight = UDim.new(0, isSmall and 7 or 9)
    for name, button in pairs(tabButtons) do
        local icon = tabIcons[name] or "•"
        button.Text = isSmall and icon or (icon .. "   " .. name)
        button.TextSize = isSmall and 17 or 10
        button.TextXAlignment = isSmall and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
        for _, child in ipairs(button:GetChildren()) do
            if child:IsA("UIPadding") then
                child.PaddingLeft = UDim.new(0, isSmall and 0 or 10)
            end
        end
    end
    if not dragging then
        main.Position = UDim2.fromScale(0.5, 0.5)
        shadow.Position = main.Position
    end
end

local viewportConnection
local function bindViewport()
    if viewportConnection then viewportConnection:Disconnect(); viewportConnection = nil end
    local currentCamera = Workspace.CurrentCamera
    if currentCamera then
        viewportConnection = track(currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshResponsiveLayout))
    end
end
bindViewport()
track(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport))

local function addSection(parent, text)
    local holder = Instance.new("Frame")
    holder.Name = "SectionHeader"
    holder.Size = UDim2.new(1, 0, 0, 25)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    local label = makeLabel(holder, text:upper(), 10, COLORS.AccentLight, Enum.Font.GothamBold)
    label.Position = UDim2.fromOffset(2, 0)
    label.Size = UDim2.new(1, -12, 1, 0)
    return label
end

--// Feedback tactil Android (opcional)
pulseHaptic = function()
    if not State.TouchFeedback then return end
    pcall(function()
        if HapticService:IsVibrationSupported(Enum.UserInputType.Touch) then
            HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, 0.25)
            task.delay(0.045, function()
                pcall(function()
                    HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, 0)
                end)
            end)
        end
    end)
end

--// Sonido reutilizable de la interfaz (separado del audio del juego)
local uiClickSound = Instance.new("Sound")
uiClickSound.Name = "WXNNXRX_UI_Click"
uiClickSound.SoundId = "rbxassetid://6895079853"
uiClickSound.Volume = 0.14
uiClickSound.Parent = SoundService

playUIAudio = function(success)
    if not State.UIAudio then return end
    pcall(function()
        uiClickSound:Stop()
        uiClickSound.TimePosition = 0
        uiClickSound.PlaybackSpeed = success == false and 0.88 or 1.08
        uiClickSound:Play()
    end)
end

local function addToggle(parent, heading, description, initial, callback)
    local row = Instance.new("Frame")
    row.Name = "ToggleCard"
    row.Size = UDim2.new(1, 0, 0, description and 61 or 49)
    row.BackgroundColor3 = COLORS.PanelSoft
    row.BackgroundTransparency = 0.12
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 11)
    outline(row, COLORS.AccentLight, 0.78, 0.8)

    local titleLabel = makeLabel(row, heading, 11, COLORS.Text, Enum.Font.GothamSemibold)
    titleLabel.Position = UDim2.fromOffset(11, description and 6 or 0)
    titleLabel.Size = UDim2.new(1, -82, 0, 22)
    if description then
        local desc = makeLabel(row, description, 9, COLORS.Muted, Enum.Font.Gotham)
        desc.Position = UDim2.fromOffset(11, 31)
        desc.Size = UDim2.new(1, -82, 0, 17)
        desc.TextTruncate = Enum.TextTruncate.AtEnd
    end

    local toggle = Instance.new("TextButton")
    toggle.Name = "ToggleSwitch"
    toggle.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Size = UDim2.fromOffset(48, 27)
    toggle.Position = UDim2.new(1, -10, 0.5, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(67, 68, 83)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.ZIndex = 7
    toggle.Parent = row
    corner(toggle, 15)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(19, 19)
    dot.Position = UDim2.fromOffset(4, 4)
    dot.BackgroundColor3 = COLORS.Text
    dot.BorderSizePixel = 0
    dot.ZIndex = 8
    dot.Parent = toggle
    corner(dot, 10)

    local value = initial == true
    local function render(animate)
        local goalColor = value and COLORS.Accent or Color3.fromRGB(67, 68, 83)
        local goalPosition = value and UDim2.new(1, -23, 0, 4) or UDim2.fromOffset(4, 4)
        if animate then
            TweenService:Create(toggle, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = goalColor}):Play()
            TweenService:Create(dot, TweenInfo.new(0.17, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = goalPosition}):Play()
        else
            toggle.BackgroundColor3 = goalColor
            dot.Position = goalPosition
        end
    end
    render(false)

    local function setValue(nextValue, fireCallback)
        value = nextValue == true
        render(true)
        if fireCallback and callback then callback(value) end
    end
    track(toggle.Activated:Connect(function()
        if alive then
            pulseHaptic()
            playUIAudio(true)
            setValue(not value, true)
        end
    end))
    if callback then callback(value) end
    return {
        Set = function(nextValue) setValue(nextValue, true) end,
        Get = function() return value end,
        Button = toggle,
    }
end

local function addAction(parent, heading, description, buttonText, callback)
    local row = Instance.new("Frame")
    row.Name = "ActionCard"
    row.Size = UDim2.new(1, 0, 0, 60)
    row.BackgroundColor3 = COLORS.PanelSoft
    row.BackgroundTransparency = 0.12
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 11)
    outline(row, COLORS.AccentLight, 0.80, 0.8)

    local titleLabel = makeLabel(row, heading, 11, COLORS.Text, Enum.Font.GothamSemibold)
    titleLabel.Position = UDim2.fromOffset(11, 6)
    titleLabel.Size = UDim2.new(1, -108, 0, 21)
    local desc = makeLabel(row, description or "", 9, COLORS.Muted, Enum.Font.Gotham)
    desc.Position = UDim2.fromOffset(11, 31)
    desc.Size = UDim2.new(1, -108, 0, 17)
    desc.TextTruncate = Enum.TextTruncate.AtEnd

    local button = Instance.new("TextButton")
    button.Name = "ActionButton"
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Size = UDim2.fromOffset(83, 34)
    button.Position = UDim2.new(1, -10, 0.5, 0)
    button.BackgroundColor3 = COLORS.Accent
    button.BorderSizePixel = 0
    button.Text = buttonText or "Abrir"
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 10
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.ZIndex = 7
    button.Parent = row
    corner(button, 9)
    track(button.Activated:Connect(function()
        if alive then pulseHaptic(); playUIAudio(true) end
        if alive and callback then
            TweenService:Create(button, TweenInfo.new(0.07), {Size = UDim2.fromOffset(79, 32)}):Play()
            task.delay(0.07, function()
                if button and button.Parent then
                    TweenService:Create(button, TweenInfo.new(0.12), {Size = UDim2.fromOffset(83, 34)}):Play()
                end
            end)
            callback(button)
        end
    end))
    return button
end

local function addSlider(parent, heading, minimum, maximum, initial, callback)
    local row = Instance.new("Frame")
    row.Name = "SliderCard"
    row.Size = UDim2.new(1, 0, 0, 68)
    row.BackgroundColor3 = COLORS.PanelSoft
    row.BackgroundTransparency = 0.12
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 11)
    outline(row, COLORS.AccentLight, 0.80, 0.8)

    local label = makeLabel(row, heading, 11, COLORS.Text, Enum.Font.GothamSemibold)
    label.Position = UDim2.fromOffset(11, 5)
    label.Size = UDim2.new(1, -75, 0, 22)
    local valueLabel = makeLabel(row, tostring(initial), 10, COLORS.AccentLight, Enum.Font.GothamBold)
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.Size = UDim2.fromOffset(48, 22)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local trackFrame = Instance.new("Frame")
    trackFrame.Name = "Track"
    trackFrame.Position = UDim2.new(0, 11, 0, 42)
    trackFrame.Size = UDim2.new(1, -22, 0, 7)
    trackFrame.BackgroundColor3 = COLORS.Track
    trackFrame.BorderSizePixel = 0
    trackFrame.Parent = row
    corner(trackFrame, 6)

    local range = math.max(1, maximum - minimum)
    local initialAlpha = math.clamp((initial - minimum) / range, 0, 1)
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(initialAlpha, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.AccentLight
    fill.BorderSizePixel = 0
    fill.Parent = trackFrame
    corner(fill, 6)

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(initialAlpha, 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(15, 15)
    knob.BackgroundColor3 = COLORS.Text
    knob.BorderSizePixel = 0
    knob.Parent = trackFrame
    corner(knob, 10)
    outline(knob, COLORS.AccentLight, 0.35, 1)

    local value = initial
    local dragging = false
    local activeTouch = nil
    local function setFromX(x)
        local width = math.max(1, trackFrame.AbsoluteSize.X)
        local alpha = math.clamp((x - trackFrame.AbsolutePosition.X) / width, 0, 1)
        value = math.floor(minimum + (maximum - minimum) * alpha + 0.5)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    track(trackFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            activeTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
            setFromX(input.Position.X)
        end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        local isMouseMove = input.UserInputType == Enum.UserInputType.MouseMovement
        local isTouchMove = input.UserInputType == Enum.UserInputType.Touch
        if dragging and (isMouseMove or isTouchMove) then
            setFromX(input.Position.X)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            activeTouch = nil
        end
    end))
    return row
end

-- Deteccion heuristica de roles: solo identifica herramientas visibles/equipadas.
-- No puede leer roles privados ni sustituye los datos autoritativos del servidor.
local function detectVisibleRole(character)
    if not character then return "UNKNOWN", Color3.fromRGB(175, 175, 190) end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            local name = string.lower(child.Name)
            if name:find("knife", 1, true) then
                return "MURDERER", Color3.fromRGB(255, 85, 95)
            elseif name:find("gun", 1, true) then
                return "SHERIFF", Color3.fromRGB(90, 155, 255)
            end
        end
    end
    return "UNKNOWN", Color3.fromRGB(175, 175, 190)
end

local function clearMM2Visuals()
    for player, object in pairs(mm2RoleObjects) do
        pcall(function() object:Destroy() end)
        mm2RoleObjects[player] = nil
    end
    for object, visual in pairs(mm2WeaponObjects) do
        pcall(function() visual:Destroy() end)
        mm2WeaponObjects[object] = nil
    end
end

local function refreshMM2Visuals()
    local seenPlayers, seenWeapons = {}, {}
    if State.MM2RoleESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local head = character:FindFirstChild("Head")
                if head then
                    seenPlayers[player] = true
                    local role, color = detectVisibleRole(character)
                    local gui = mm2RoleObjects[player]
                    if not gui or not gui.Parent then
                        gui = Instance.new("BillboardGui")
                        gui.Name = "WXNNXRX_RoleTag"
                        gui.Size = UDim2.fromOffset(130, 26)
                        gui.StudsOffset = Vector3.new(0, 3.2, 0)
                        gui.AlwaysOnTop = true
                        gui.Adornee = head
                        gui.Parent = mm2Folder
                        local label = Instance.new("TextLabel")
                        label.Name = "Role"
                        label.Size = UDim2.fromScale(1, 1)
                        label.BackgroundColor3 = Color3.fromRGB(14, 12, 20)
                        label.BackgroundTransparency = 0.18
                        label.TextStrokeTransparency = 0.55
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 10
                        label.Parent = gui
                        local corner = Instance.new("UICorner")
                        corner.CornerRadius = UDim.new(0, 6)
                        corner.Parent = label
                        mm2RoleObjects[player] = gui
                    end
                    gui.Adornee = head
                    local label = gui:FindFirstChild("Role")
                    if label then
                        label.Text = role == "UNKNOWN" and (player.DisplayName .. " · ?") or (player.DisplayName .. " · " .. role)
                        label.TextColor3 = color
                    end
                end
            end
        end
    end

    if State.MM2DroppedWeaponESP then
        for _, object in ipairs(Workspace:GetDescendants()) do
            if object:IsA("Tool") then
                local name = string.lower(object.Name)
                if name:find("gun", 1, true) or name:find("knife", 1, true) then
                    local parent = object.Parent
                    if parent and not Players:GetPlayerFromCharacter(parent) then
                        seenWeapons[object] = true
                        if not mm2WeaponObjects[object] then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "WXNNXRX_DroppedWeapon"
                            highlight.Adornee = object
                            highlight.FillColor = name:find("gun", 1, true) and Color3.fromRGB(80, 145, 255) or Color3.fromRGB(255, 85, 95)
                            highlight.OutlineColor = highlight.FillColor
                            highlight.FillTransparency = 0.62
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.Parent = mm2Folder
                            mm2WeaponObjects[object] = highlight
                        end
                    end
                end
            end
        end
    end

    for player, gui in pairs(mm2RoleObjects) do
        if not State.MM2RoleESP or not seenPlayers[player] or not player.Parent then
            pcall(function() gui:Destroy() end)
            mm2RoleObjects[player] = nil
        end
    end
    for object, visual in pairs(mm2WeaponObjects) do
        if not State.MM2DroppedWeaponESP or not seenWeapons[object] or not object.Parent then
            pcall(function() visual:Destroy() end)
            mm2WeaponObjects[object] = nil
        end
    end
end



local androidToastHolder
local function makeToast(title, message, color)
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    if not androidToastHolder or not androidToastHolder.Parent then
        androidToastHolder = Instance.new("Frame")
        androidToastHolder.Name = "WXNNXRX_AndroidToasts"
        androidToastHolder.BackgroundTransparency = 1
        androidToastHolder.AnchorPoint = Vector2.new(1, 0)
        androidToastHolder.Position = UDim2.new(1, -12, 0, 12)
        androidToastHolder.Size = UDim2.fromOffset(250, 240)
        androidToastHolder.ZIndex = 200
        androidToastHolder.Parent = playerGui
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.Parent = androidToastHolder
    end
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = Color3.fromRGB(24, 20, 30)
    card.BackgroundTransparency = 0.08
    card.BorderSizePixel = 0
    card.ZIndex = 201
    card.Parent = androidToastHolder
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = card
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -12)
    bar.Position = UDim2.fromOffset(0, 6)
    bar.BackgroundColor3 = color or Color3.fromRGB(180, 80, 255)
    bar.BorderSizePixel = 0
    bar.ZIndex = 202
    bar.Parent = card
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(11, 5)
    label.Size = UDim2.new(1, -18, 0, 16)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = color or Color3.fromRGB(180, 80, 255)
    label.Text = tostring(title)
    label.ZIndex = 202
    label.Parent = card
    local body = Instance.new("TextLabel")
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(11, 22)
    body.Size = UDim2.new(1, -18, 0, 20)
    body.Font = Enum.Font.Gotham
    body.TextSize = 10
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextColor3 = Color3.fromRGB(240, 235, 255)
    body.TextTruncate = Enum.TextTruncate.AtEnd
    body.Text = tostring(message)
    body.ZIndex = 202
    body.Parent = card
    task.delay(2.6, function()
        if card and card.Parent then card:Destroy() end
    end)
end

--// WXNNXRX Android v14 feature pack
local AndroidCFG = {
    BombCooldown = 5.2,
    AutoLoopDelay = 5.5,
    SpeedCD = 3,
    SpeedPower = 150,
    FOVRadius = 150,
    PredictionFactor = 0.15,
}
local androidCamera = Workspace.CurrentCamera
local function androidRoleOf(character)
    if not character then return "Innocent", Color3.fromRGB(60, 220, 100) end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local n = string.lower(tool.Name)
            if string.find(n, "knife") then return "Murderer", Color3.fromRGB(255, 60, 60) end
            if string.find(n, "gun") then return "Sheriff", Color3.fromRGB(60, 130, 255) end
        end
    end
    return "Innocent", Color3.fromRGB(60, 220, 100)
end
local function androidFindMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and androidRoleOf(p.Character) == "Murderer" then return p end
    end
end
local function androidIsSheriff()
    return LocalPlayer.Character and androidRoleOf(LocalPlayer.Character) == "Sheriff"
end
local function androidGun()
    local character = LocalPlayer.Character
    return character and (character:FindFirstChild("Gun") or (LocalPlayer:FindFirstChildOfClass("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun")))
end

local function androidBombJump(silent)
    if State.BombBusy then return false end
    if os.clock() < State.BombCooldown then
        if not silent then makeToast("Bomb Jump", "Espera " .. math.ceil(State.BombCooldown - os.clock()) .. "s", Color3.fromRGB(255, 200, 60)) end
        return false
    end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not character or not humanoid or not root or humanoid.Health <= 0 then
        if not silent then makeToast("Bomb Jump", "Personaje no disponible", Color3.fromRGB(255, 60, 100)) end
        return false
    end
    State.BombBusy = true
    task.spawn(function()
        local ok, err = pcall(function()
            local bomb
            for _, name in ipairs({"FakeBomb", "PrankBomb", "Fake Bomb", "Prank Bomb"}) do
                local candidate = character:FindFirstChild(name) or (backpack and backpack:FindFirstChild(name))
                if candidate and candidate:IsA("Tool") then bomb = candidate break end
            end
            if not bomb then error("FakeBomb no encontrada") end
            if bomb.Parent ~= character then
                pcall(function() humanoid:EquipTool(bomb) end)
                task.wait(0.1)
            end
            local remote = bomb:FindFirstChild("Remote")
            if not remote or not remote:IsA("RemoteEvent") then error("RemoteEvent no encontrado") end
            State.BombCooldown = os.clock() + AndroidCFG.BombCooldown
            local power = humanoid.UseJumpPower and humanoid.JumpPower or 50
            local velocity = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(velocity.X, power, velocity.Z)
            task.wait(0.12)
            remote:FireServer(CFrame.new(root.Position - Vector3.new(0, 2.5, 0)), 50)
            task.wait(0.22)
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, power, root.AssemblyLinearVelocity.Z)
        end)
        if not silent then
            if ok then makeToast("Bomb Jump", "Acción ejecutada", Color3.fromRGB(100, 230, 140))
            else makeToast("Bomb Jump", tostring(err), Color3.fromRGB(255, 60, 100)) end
        end
        task.wait(0.5)
        State.BombBusy = false
    end)
    return true
end

local function androidSpeedGlitch()
    local now = os.clock()
    if now < State.SpeedGlitchCooldown then makeToast("Speed Glitch", "Cooldown activo", Color3.fromRGB(255, 200, 60)); return end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    State.SpeedGlitchCooldown = now + AndroidCFG.SpeedCD
    local velocity = Instance.new("BodyVelocity")
    velocity.MaxForce = Vector3.new(1e5, 0, 1e5)
    velocity.Velocity = root.CFrame.LookVector * AndroidCFG.SpeedPower
    velocity.Parent = root
    task.delay(0.15, function() if velocity and velocity.Parent then velocity:Destroy() end end)
    makeToast("Speed Glitch", "Impulso aplicado", Color3.fromRGB(180, 80, 255))
    pulseHaptic()
end

local function androidTeleportTo(target)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if target == "Murderer" then
        local murderer = androidFindMurderer()
        local targetRoot = murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0); makeToast("TP", "Destino: " .. murderer.Name, Color3.fromRGB(255, 60, 60))
        else makeToast("TP", "Murderer no encontrado", Color3.fromRGB(255, 200, 60)) end
    elseif target == "Sheriff" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and androidRoleOf(p.Character) == "Sheriff" then
                local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0); makeToast("TP", "Destino: " .. p.Name, Color3.fromRGB(60, 130, 255)); return end
            end
        end
        makeToast("TP", "Sheriff no encontrado", Color3.fromRGB(255, 200, 60))
    elseif target == "Gun" then
        for _, object in ipairs(Workspace:GetDescendants()) do
            if object:IsA("Tool") and string.lower(object.Name) == "gun" then
                local handle = object:FindFirstChild("Handle")
                if handle then root.CFrame = handle.CFrame + Vector3.new(0, 3, 0); makeToast("TP", "Destino: arma", Color3.fromRGB(60, 130, 255)); return end
            end
        end
        makeToast("TP", "Arma no encontrada", Color3.fromRGB(255, 200, 60))
    end
end

local function androidGrabGun()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("Tool") and string.lower(object.Name) == "gun" then
            local parent = object.Parent
            local owningPlayer = parent and Players:GetPlayerFromCharacter(parent)
            if not owningPlayer then
                local ok = pcall(function() object.Parent = backpack end)
                if ok then makeToast("Grab Gun", "Tool movida al Backpack local", Color3.fromRGB(100, 230, 140))
                else makeToast("Grab Gun", "El juego no permite mover esta Tool desde el cliente", Color3.fromRGB(255, 200, 60)) end
                pulseHaptic()
                return
            end
        end
    end
    makeToast("Grab Gun", "No se encontró un arma en el suelo", Color3.fromRGB(255, 200, 60))
end

local function androidShootMurderer()
    if not androidIsSheriff() then makeToast("Shoot", "No eres Sheriff", Color3.fromRGB(255, 200, 60)); return end
    local weapon = androidGun()
    if not weapon or weapon.Parent ~= LocalPlayer.Character then makeToast("Shoot", "Arma no equipada", Color3.fromRGB(255, 200, 60)); return end
    local murderer = androidFindMurderer()
    local targetRoot = murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then makeToast("Shoot", "Objetivo no disponible", Color3.fromRGB(255, 200, 60)); return end
    root.CFrame = CFrame.new(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
    task.spawn(function()
        for _ = 1, 6 do
            if not murderer.Character or not murderer.Character.Parent then break end
            pcall(function() weapon:Activate() end)
            task.wait(0.08)
        end
    end)
    makeToast("Shoot", "Secuencia enviada a " .. murderer.Name, Color3.fromRGB(255, 60, 60))
    pulseHaptic()
end

local androidFOVGui
local function androidSetFOVVisible(enabled)
    if not enabled then
        if androidFOVGui then androidFOVGui:Destroy(); androidFOVGui = nil end
        return
    end
    if androidFOVGui then androidFOVGui:Destroy() end
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    androidFOVGui = Instance.new("ScreenGui")
    androidFOVGui.Name = "WXNNXRX_AndroidFOV"
    androidFOVGui.ResetOnSpawn = false
    androidFOVGui.Parent = playerGui
    local circle = Instance.new("Frame")
    circle.Size = UDim2.fromOffset(AndroidCFG.FOVRadius * 2, AndroidCFG.FOVRadius * 2)
    circle.Position = UDim2.new(0.5, -AndroidCFG.FOVRadius, 0.5, -AndroidCFG.FOVRadius)
    circle.BackgroundTransparency = 1
    circle.Parent = androidFOVGui
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 80, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    stroke.Parent = circle
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = circle
end
local function androidClosestTarget()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local closest, shortest
    shortest = AndroidCFG.FOVRadius
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                local screen, visible = camera:WorldToScreenPoint(root.Position)
                if visible then
                    local distance = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                    if distance < shortest then shortest = distance; closest = p end
                end
            end
        end
    end
    return closest
end

local androidESPHighlights, androidESPBillboards, androidWeaponHighlights = {}, {}, {}
local function androidClearESP()
    for _, object in pairs(androidESPHighlights) do pcall(function() object:Destroy() end) end
    for _, object in pairs(androidESPBillboards) do pcall(function() object:Destroy() end) end
    for _, object in pairs(androidWeaponHighlights) do pcall(function() object:Destroy() end) end
    table.clear(androidESPHighlights); table.clear(androidESPBillboards); table.clear(androidWeaponHighlights)
end
local function androidApplyESP(player)
    if player == LocalPlayer or not player.Character then return end
    local _, color = androidRoleOf(player.Character)
    if androidESPHighlights[player] then androidESPHighlights[player]:Destroy() end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.55
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    androidESPHighlights[player] = highlight
    if State.RoleESPDistance then
        local head = player.Character:FindFirstChild("Head")
        if head then
            if androidESPBillboards[player] then androidESPBillboards[player]:Destroy() end
            local billboard = Instance.new("BillboardGui")
            billboard.Adornee = head
            billboard.Size = UDim2.fromOffset(120, 24)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = player.Character
            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundTransparency = 1
            label.TextColor3 = color
            label.Font = Enum.Font.Code
            label.TextSize = 11
            label.Parent = billboard
            androidESPBillboards[player] = billboard
        end
    end
end

track(RunService.RenderStepped:Connect(function()
    if not alive then return end
    if State.CameraAimbot or State.TriggerBot then
        local target = androidClosestTarget()
        local camera = Workspace.CurrentCamera
        local root = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if root and camera then
            local position = root.Position
            if State.Prediction then position += root.AssemblyLinearVelocity * AndroidCFG.PredictionFactor end
            if State.CameraAimbot then
                local targetCFrame = CFrame.lookAt(camera.CFrame.Position, position)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, State.AimbotSmooth)
            end
            if State.TriggerBot and androidIsSheriff() then
                local weapon = androidGun()
                local screen, visible = camera:WorldToScreenPoint(position)
                local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                if weapon and weapon.Parent == LocalPlayer.Character and visible and (Vector2.new(screen.X, screen.Y) - center).Magnitude < AndroidCFG.FOVRadius then
                    pcall(function() weapon:Activate() end)
                end
            end
        end
    end
end))

local androidAntiAimAngle = 0
track(RunService.Heartbeat:Connect(function(deltaTime)
    if State.AntiAim then
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then androidAntiAimAngle += deltaTime * 3; root.CFrame = root.CFrame * CFrame.Angles(0, androidAntiAimAngle, 0) end
    end
end))

task.spawn(function()
    while alive do
        task.wait(0.5)
        if State.RoleESP then
            for _, player in ipairs(Players:GetPlayers()) do if player ~= LocalPlayer then androidApplyESP(player) end end
            if State.RoleESPDistance then
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    for player, billboard in pairs(androidESPBillboards) do
                        local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        local label = billboard and billboard:FindFirstChildOfClass("TextLabel")
                        if targetRoot and label then label.Text = string.format("[%d studs]", math.floor((targetRoot.Position - myRoot.Position).Magnitude)) end
                    end
                end
            end
        elseif next(androidESPHighlights) then
            for _, object in pairs(androidESPHighlights) do pcall(function() object:Destroy() end) end
            for _, object in pairs(androidESPBillboards) do pcall(function() object:Destroy() end) end
            table.clear(androidESPHighlights); table.clear(androidESPBillboards)
        end
        if State.WeaponESP then
            for _, object in ipairs(Workspace:GetDescendants()) do
                if object:IsA("Tool") and not androidWeaponHighlights[object] then
                    local name = string.lower(object.Name)
                    local color = string.find(name, "gun") and Color3.fromRGB(60, 130, 255) or (string.find(name, "knife") and Color3.fromRGB(255, 60, 60))
                    if color then
                        local highlight = Instance.new("Highlight")
                        highlight.Adornee = object
                        highlight.FillColor = color
                        highlight.OutlineColor = Color3.new(1, 1, 1)
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = object
                        androidWeaponHighlights[object] = highlight
                    end
                end
            end
        else
            for _, object in pairs(androidWeaponHighlights) do pcall(function() object:Destroy() end) end
            table.clear(androidWeaponHighlights)
        end
    end
end)

task.spawn(function()
    while alive do
        task.wait(0.5)
        if (State.AutoFarmCoins or State.AutoFarmCandy) and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local keyword = State.AutoFarmCoins and "coin" or "candy"
                for _, object in ipairs(Workspace:GetDescendants()) do
                    if object:IsA("BasePart") and string.find(string.lower(object.Name), keyword) then
                        root.CFrame = CFrame.new(object.Position + Vector3.new(0, 3, 0))
                        task.wait(0.15)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while alive do
        task.wait(AndroidCFG.AutoLoopDelay)
        if State.BombAutoLoop then androidBombJump(true) end
    end
end)


--// Construir paginas y pestañas
local homePage = makePage("Home")
local espPage = makePage("ESP")
local wallPage = makePage("WallHop")
local movementPage = makePage("Move")
local visualsPage = makePage("Visual+")
local aimPage = makePage("Aim")
local hitboxPage = makePage("Hitbox")
local worldPage = makePage("World")
local settingsPage = makePage("Settings")
local finderPage = makePage("Finder")
local cameraPage = makePage("Camera")
local playerPage = makePage("Player")
local performancePage = makePage("Performance")
local profilesPage = makePage("Profiles")
local mm2Page = makePage("MM2 Tools")
local androidPage = makePage("Android+")

addTab("Home", "⌂")
addTab("ESP", "◉")
addTab("WallHop", "↟")
addTab("Move", "⇧")
addTab("Visual+", "✧")
addTab("Aim", "◎")
addTab("Hitbox", "▣")
addTab("World", "⌖")
addTab("Finder", "⌕")
addTab("Camera", "◉")
addTab("Player", "♙")
addTab("Performance", "▤")
addTab("Profiles", "▦")
addTab("MM2 Tools", "◇")
addTab("Android+", "✦")
addTab("Settings", "⚙")


-- Android+ · funciones añadidas desde el paquete v14
addSection(androidPage, "Jump / Movement")
addToggle(androidPage, "Bomb Jump", "Ejecuta la secuencia FakeBomb del paquete", false, function(value)
    if value then androidBombJump(false) end
end)
addToggle(androidPage, "Auto Bomb Loop", "Repite Bomb Jump con el intervalo configurado", State.BombAutoLoop, function(value)
    State.BombAutoLoop = value
end)
addAction(androidPage, "Speed Glitch", "Aplica un impulso corto hacia delante", "Activar", androidSpeedGlitch)
addSection(androidPage, "Aim / Combat")
addToggle(androidPage, "Camera Aimbot", "Apunta la cámara al objetivo más cercano dentro del FOV", State.CameraAimbot, function(value)
    State.CameraAimbot = value
    androidSetFOVVisible(value or State.TriggerBot)
end)
addToggle(androidPage, "TriggerBot", "Activa el Tool equipado cuando un objetivo entra en el FOV", State.TriggerBot, function(value)
    State.TriggerBot = value
    androidSetFOVVisible(value or State.CameraAimbot)
end)
addToggle(androidPage, "Prediction", "Anticipa el movimiento usando la velocidad del objetivo", State.Prediction, function(value)
    State.Prediction = value
end)
addSlider(androidPage, "Suavidad Aimbot", 5, 100, math.floor(State.AimbotSmooth * 100), function(value)
    State.AimbotSmooth = value / 100
end)
addToggle(androidPage, "Anti-Aim", "Rota el personaje continuamente", State.AntiAim, function(value)
    State.AntiAim = value
end)
addAction(androidPage, "Shoot Murderer", "Orienta el personaje y activa el arma equipada", "Disparar", androidShootMurderer)
addSection(androidPage, "ESP")
addToggle(androidPage, "Role ESP", "Resalta jugadores según Tools visibles", State.RoleESP, function(value)
    State.RoleESP = value
    if not value then
        for _, object in pairs(androidESPHighlights) do pcall(function() object:Destroy() end) end
        for _, object in pairs(androidESPBillboards) do pcall(function() object:Destroy() end) end
        table.clear(androidESPHighlights); table.clear(androidESPBillboards)
    end
end)
addToggle(androidPage, "ESP Distance", "Muestra la distancia en studs", State.RoleESPDistance, function(value)
    State.RoleESPDistance = value
end)
addToggle(androidPage, "Weapon ESP", "Resalta Tools Gun y Knife detectables", State.WeaponESP, function(value)
    State.WeaponESP = value
end)
addSection(androidPage, "Farm")
addToggle(androidPage, "Auto Farm Coins", "Busca partes cuyo nombre contenga coin y se desplaza hacia ellas", State.AutoFarmCoins, function(value)
    State.AutoFarmCoins = value
    if value then State.AutoFarmCandy = false end
end)
addToggle(androidPage, "Auto Farm Candy", "Busca partes cuyo nombre contenga candy y se desplaza hacia ellas", State.AutoFarmCandy, function(value)
    State.AutoFarmCandy = value
    if value then State.AutoFarmCoins = false end
end)
addSection(androidPage, "Misc / Teleports")
addAction(androidPage, "TP Murderer", "Teletransporta al jugador detectado como Murderer", "Teleport", function() androidTeleportTo("Murderer") end)
addAction(androidPage, "TP Sheriff", "Teletransporta al jugador detectado como Sheriff", "Teleport", function() androidTeleportTo("Sheriff") end)
addAction(androidPage, "TP Gun", "Teletransporta hacia una Tool Gun en Workspace", "Teleport", function() androidTeleportTo("Gun") end)
addAction(androidPage, "Grab Gun", "Intenta mover la Tool Gun del suelo al Backpack local", "Obtener", androidGrabGun)
addAction(androidPage, "Clear Android ESP", "Elimina los resaltados creados por esta pestaña", "Limpiar", androidClearESP)
local androidNote = makeLabel(androidPage, "Nota: varias acciones dependen de los nombres de Tools/Parts y de la autoridad del servidor de tu experiencia. Las llamadas del cliente pueden no producir cambios replicados.", 10, Color3.fromRGB(171, 170, 190), Enum.Font.Gotham)
androidNote.Size = UDim2.new(1, 0, 0, 58)
androidNote.TextWrapped = true
androidNote.TextYAlignment = Enum.TextYAlignment.Top



-- Home
addSection(homePage, "Bienvenido")
local welcome = Instance.new("Frame")
welcome.Size = UDim2.new(1, 0, 0, 102)
welcome.BackgroundColor3 = Color3.fromRGB(44, 38, 76)
welcome.BackgroundTransparency = 0.12
welcome.BorderSizePixel = 0
welcome.Parent = homePage
corner(welcome, 12)
local welcomeTitle = makeLabel(welcome, "WXNNXRX HUB", 18, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack)
welcomeTitle.Position = UDim2.fromOffset(13, 13)
welcomeTitle.Size = UDim2.new(1, -26, 0, 28)
local welcomeDesc = makeLabel(welcome, "Visuales + movimiento  •  Delta", 10, Color3.fromRGB(202, 196, 235), Enum.Font.Gotham)
welcomeDesc.Position = UDim2.fromOffset(14, 47)
welcomeDesc.Size = UDim2.new(1, -26, 0, 20)
local welcomeStatus = makeLabel(welcome, "●  Sistema listo", 10, Color3.fromRGB(128, 230, 173), Enum.Font.GothamSemibold)
welcomeStatus.Position = UDim2.fromOffset(14, 72)
welcomeStatus.Size = UDim2.new(1, -26, 0, 18)
addSection(homePage, "Modulos")
addAction(homePage, "ESP de jugadores", "Resaltado, nombre, vida y distancia", "Abrir", function()
    selectTab("ESP")
end)
addAction(homePage, "WallHop V4", "Salto de pared manual y automatico", "Abrir", function()
    selectTab("WallHop")
end)
addAction(homePage, "Movement", "Velocidad y salto ajustables", "Abrir", function()
    selectTab("Move")
end)
addAction(homePage, "Visual+", "FullBright, FOV, mira y HUD", "Abrir", function()
    selectTab("Visual+")
end)
addAction(homePage, "World Tools", "Waypoints, Spawn y recuperacion", "Abrir", function()
    selectTab("World")
end)
addAction(homePage, "Aim Assist", "FOV, suavidad y seleccion de objetivo", "Abrir", function()
    selectTab("Aim")
end)
addAction(homePage, "Hitbox Preview", "Visualiza cabeza y torso", "Abrir", function()
    selectTab("Hitbox")
end)
addAction(homePage, "Finder", "NPCs, herramientas y objetos", "Abrir", function() selectTab("Finder") end)
addAction(homePage, "Camera Pro", "Espectar jugadores y ajustar zoom", "Abrir", function() selectTab("Camera") end)
addAction(homePage, "Player Info", "Estado del personaje y jugadores", "Abrir", function() selectTab("Player") end)
addAction(homePage, "Performance", "Monitor y modo de bajo consumo visual", "Abrir", function() selectTab("Performance") end)
addAction(homePage, "Profiles", "Preajustes rapidos de configuracion", "Abrir", function() selectTab("Profiles") end)

-- ESP
addSection(espPage, "Visuales de jugadores")
local espMasterControl = addToggle(espPage, "Activar ESP", "Muestra informacion local de otros personajes", State.ESPEnabled, function(value)
    State.ESPEnabled = value
    if not value then
        for targetPlayer in pairs(espObjects) do removeESP(targetPlayer) end
    end
end)
addToggle(espPage, "Glow / Highlight", "Resaltado a traves de objetos", State.Glow, function(value) State.Glow = value end)
addToggle(espPage, "Caja 3D", "Contorno alrededor del personaje", State.Box, function(value) State.Box = value end)
addToggle(espPage, "Nombre", "Mostrar nombre del jugador", State.Names, function(value) State.Names = value end)
addToggle(espPage, "Vida", "Mostrar salud actual y maxima", State.Health, function(value) State.Health = value end)
addToggle(espPage, "Distancia", "Mostrar distancia en studs", State.Distance, function(value) State.Distance = value end)
addToggle(espPage, "Color de equipo", "Usa el color de equipo cuando exista", State.TeamColors, function(value) State.TeamColors = value end)
addToggle(espPage, "Solo enemigos", "Oculta jugadores del mismo equipo", State.EnemiesOnly, function(value) State.EnemiesOnly = value end)
addToggle(espPage, "Mostrar enemigos", "Incluye jugadores de otros equipos", State.ShowEnemies, function(value) State.ShowEnemies = value end)
addToggle(espPage, "Mostrar equipo", "Incluye jugadores de tu equipo", State.ShowTeam, function(value) State.ShowTeam = value end)
addToggle(espPage, "Linea de mirada", "Linea corta hacia donde mira el personaje", State.LookLine, function(value) State.LookLine = value end)
addSlider(espPage, "Rango maximo (studs)", 100, 3000, State.ESPRange, function(value) State.ESPRange = value end)

-- WallHop
addSection(wallPage, "WallHop V4")
local autoControl
local wallMasterControl = addToggle(wallPage, "WallHop", "Activa el salto al presionar el boton de salto", State.WallHopEnabled, function(value)
    State.WallHopEnabled = value
    if not value then
        State.AutoWallHop = false
        task.defer(function()
            if autoControl then autoControl.Set(false) end
        end)
    end
end)
autoControl = addToggle(wallPage, "Auto WallHop", "Salta al detectar una pared del color elegido", State.AutoWallHop, function(value)
    if value and not State.SelectedBrickColor then
        State.AutoWallHop = false
        task.defer(function()
            if autoControl then autoControl.Set(false) end
        end)
        return
    end
    State.AutoWallHop = value
end)
local selectedColorText = makeLabel(wallPage, "Color seleccionado: ninguno", 10, Color3.fromRGB(188, 183, 215), Enum.Font.GothamSemibold)
selectedColorText.Size = UDim2.new(1, 0, 0, 24)
local selectButton = addAction(wallPage, "Selector de superficie", "Pulsa y toca/clica una pieza del mapa", "Seleccionar", function(button)
    startColorSelection()
    button.Text = "Esperando..."
    button.BackgroundColor3 = Color3.fromRGB(65, 145, 125)
end)
addAction(wallPage, "Salto manual", "Ejecuta un salto si hay una pared cerca", "JUMP", performManualWallHop)
addSection(wallPage, "Como usar")
local help = makeLabel(wallPage, "1. Activa WallHop.\n2. Pulsa el selector y elige una pieza.\n3. Activa Auto WallHop para saltar al detectar ese color.\nTambien puedes usar el boton JUMP cerca de una pared.", 10, Color3.fromRGB(171, 170, 190), Enum.Font.Gotham)
help.Size = UDim2.new(1, 0, 0, 86)
help.TextYAlignment = Enum.TextYAlignment.Top
help.TextWrapped = true

-- Movement
addSection(movementPage, "Movimiento local")
local speedControl = addToggle(movementPage, "Speed Boost", "Ajusta WalkSpeed en tu cliente", State.SpeedEnabled, function(value)
    State.SpeedEnabled = value
    applyMovement()
end)
addSlider(movementPage, "Velocidad", 16, 60, State.SpeedValue, function(value)
    State.SpeedValue = value
    if State.SpeedEnabled then applyMovement() end
end)
local jumpControl = addToggle(movementPage, "Jump Boost", "Ajusta la fuerza del salto local", State.JumpEnabled, function(value)
    State.JumpEnabled = value
    applyMovement()
end)
addSlider(movementPage, "Fuerza de salto", 50, 120, State.JumpPowerValue, function(value)
    State.JumpPowerValue = value
    if State.JumpEnabled then applyMovement() end
end)
addToggle(movementPage, "Infinite Jump", "Permite volver a saltar mientras estas en el aire", State.InfiniteJumpEnabled, function(value)
    State.InfiniteJumpEnabled = value
end)
addToggle(movementPage, "Noclip", "Desactiva colisiones locales; restaura al apagar", State.NoClipEnabled, function(value)
    setNoClip(value)
end)
addToggle(movementPage, "Auto Void Recovery", "Regresa a la ultima posicion segura si caes fuera del mapa", State.AutoVoidRecovery, function(value)
    State.AutoVoidRecovery = value
    if value then
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then State.LastSafeCFrame = root.CFrame end
    end
end)
addAction(movementPage, "Restaurar movimiento", "Devuelve velocidad y salto a sus valores previos", "Restaurar", function()
    State.SpeedEnabled = false
    State.JumpEnabled = false
    speedControl.Set(false)
    jumpControl.Set(false)
    applyMovement()
end)
local movementNote = makeLabel(movementPage, "Estos ajustes cambian propiedades del Humanoid en tu cliente. Algunos juegos pueden volver a imponer sus valores desde el servidor.", 10, Color3.fromRGB(171, 170, 190), Enum.Font.Gotham)
movementNote.Size = UDim2.new(1, 0, 0, 48)
movementNote.TextWrapped = true
movementNote.TextYAlignment = Enum.TextYAlignment.Top

-- Visual+
addSection(visualsPage, "Mejoras visuales")
addToggle(visualsPage, "FullBright", "Iluminacion clara; restaura los valores originales al apagar", State.FullBright, function(value)
    setFullBright(value)
end)
local fovControl = addToggle(visualsPage, "FOV personalizado", "Activa el campo de vision elegido", State.CustomFOV, function(value)
    State.CustomFOV = value
    if not value then restoreCameraFOV() else updateCameraFOV() end
end)
addSlider(visualsPage, "Campo de vision (FOV)", 60, 110, State.CameraFOV, function(value)
    State.CameraFOV = value
    if State.CustomFOV then updateCameraFOV() end
end)
addToggle(visualsPage, "Mira central", "Muestra una pequena mira en el centro", State.CrosshairEnabled, function(value)
    State.CrosshairEnabled = value
    crosshair.Visible = value
end)
addToggle(visualsPage, "HUD de FPS y coordenadas", "Muestra FPS estimados y posicion XYZ", State.HUDEnabled, function(value)
    State.HUDEnabled = value
    hudLabel.Visible = value
end)
addAction(visualsPage, "Restaurar FOV", "Devuelve la camara a su campo de vision previo", "Restaurar", function()
    State.CustomFOV = false
    fovControl.Set(false)
    restoreCameraFOV()
end)

-- Aim Assist
addSection(aimPage, "Aim Assist local")
local aimToggle = addToggle(aimPage, "Aim Assist", "Suaviza la camara hacia el objetivo elegido en tu propia experiencia", State.AimEnabled, function(value)
    State.AimEnabled = value
    aimCircle.Visible = value
    if not value then aimTarget = nil end
end)
addSlider(aimPage, "Radio FOV", 40, 300, State.AimFOV, function(value)
    State.AimFOV = value
    aimCircle.Size = UDim2.fromOffset(value * 2, value * 2)
end)
addSlider(aimPage, "Suavidad", 1, 25, State.AimSmoothness, function(value)
    State.AimSmoothness = value
end)
addToggle(aimPage, "Team Check", "Ignora jugadores del mismo equipo", State.AimTeamCheck, function(value)
    State.AimTeamCheck = value
end)
addToggle(aimPage, "Visibility Check", "Solo selecciona objetivos visibles", State.AimVisibleCheck, function(value)
    State.AimVisibleCheck = value
end)
local aimNote = makeLabel(aimPage, "Apunta solo a jugadores vivos dentro del FOV. No dispara automaticamente. Para impactos reales, valida el objetivo desde el servidor de tu juego.", 10, Color3.fromRGB(171, 170, 190), Enum.Font.Gotham)
aimNote.Size = UDim2.new(1, 0, 0, 55)
aimNote.TextWrapped = true
aimNote.TextYAlignment = Enum.TextYAlignment.Top

-- Hitbox preview
addSection(hitboxPage, "Hitbox Expander / Preview")
addToggle(hitboxPage, "Mostrar hitboxes ampliadas", "Vista visual local alrededor de cabeza y torso", State.HitboxPreview, function(value)
    State.HitboxPreview = value
    if not value then
        for model, adornments in pairs(hitboxObjects) do
            for _, adornment in ipairs(adornments) do pcall(function() adornment:Destroy() end) end
            hitboxObjects[model] = nil
        end
    end
end)
addSlider(hitboxPage, "Escala visual", 12, 30, math.floor(State.HitboxScale * 10), function(value)
    State.HitboxScale = value / 10
end)
local hitboxNote = makeLabel(hitboxPage, "IMPORTANTE: esto solo dibuja una previsualizacion de hitboxes. No agranda las partes reales ni cambia el registro de impactos. En tu propio juego, la expansion funcional debe implementarse y validarse en el servidor.", 10, Color3.fromRGB(171, 170, 190), Enum.Font.Gotham)
hitboxNote.Size = UDim2.new(1, 0, 0, 72)
hitboxNote.TextWrapped = true
hitboxNote.TextYAlignment = Enum.TextYAlignment.Top

-- World / Waypoints: herramientas locales de prueba para la experiencia propia
addSection(worldPage, "Waypoints")
local worldStatus = makeLabel(worldPage, "Guarda hasta 3 posiciones de prueba.", 10, Color3.fromRGB(188, 183, 215), Enum.Font.GothamSemibold)
worldStatus.Size = UDim2.new(1, 0, 0, 28)
worldStatus.TextWrapped = true

local function removeWaypointMarker(slot)
    local marker = waypointMarkers[slot]
    if marker then
        pcall(function() marker:Destroy() end)
        waypointMarkers[slot] = nil
    end
end

local function saveWaypoint(slot)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        worldStatus.Text = "No se pudo guardar: personaje no disponible."
        return
    end
    State.Waypoints[slot] = root.CFrame
    removeWaypointMarker(slot)

    local marker = Instance.new("Part")
    marker.Name = "WXNNXRX_WP" .. tostring(slot)
    marker.Shape = Enum.PartType.Ball
    marker.Size = Vector3.new(1.25, 1.25, 1.25)
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanTouch = false
    marker.CanQuery = false
    marker.CastShadow = false
    marker.Material = Enum.Material.Neon
    marker.Color = Color3.fromRGB(155, 125, 255)
    marker.Position = root.Position + Vector3.new(0, 1.5, 0)
    marker.Parent = waypointFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Label"
    billboard.Adornee = marker
    billboard.Size = UDim2.fromOffset(90, 25)
    billboard.StudsOffset = Vector3.new(0, 1.1, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = marker
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(235, 230, 255)
    label.TextStrokeTransparency = 0.35
    label.Text = "WAYPOINT " .. tostring(slot)
    label.Parent = billboard

    waypointMarkers[slot] = marker
    worldStatus.Text = "Waypoint " .. tostring(slot) .. " guardado."
end

local function teleportToWaypoint(slot)
    local saved = State.Waypoints[slot]
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not saved or not root then
        worldStatus.Text = "Waypoint " .. tostring(slot) .. " no existe o el personaje no esta listo."
        return
    end
    root.CFrame = saved + Vector3.new(0, 3, 0)
    root.AssemblyLinearVelocity = Vector3.zero
    worldStatus.Text = "Movido al waypoint " .. tostring(slot) .. " (local)."
end

for slot = 1, 3 do
    local currentSlot = slot
    addAction(worldPage, "Guardar Waypoint " .. currentSlot, "Guarda tu posicion actual y crea un marcador", "Guardar", function()
        saveWaypoint(currentSlot)
    end)
    addAction(worldPage, "Ir a Waypoint " .. currentSlot, "Vuelve a la posicion guardada", "Ir", function()
        teleportToWaypoint(currentSlot)
    end)
end

addAction(worldPage, "Ir al Spawn", "Busca un SpawnLocation en el mapa y te lleva alli", "Spawn", function()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        worldStatus.Text = "Personaje no disponible."
        return
    end
    local spawnLocation = nil
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("SpawnLocation") then
            spawnLocation = item
            break
        end
    end
    if spawnLocation then
        root.CFrame = spawnLocation.CFrame + Vector3.new(0, 4, 0)
        root.AssemblyLinearVelocity = Vector3.zero
        worldStatus.Text = "Movido al Spawn (local)."
    else
        worldStatus.Text = "No se encontro ningun SpawnLocation."
    end
end)

addAction(worldPage, "Borrar Waypoints", "Elimina los 3 puntos y sus marcadores", "Limpiar", function()
    for slot = 1, 3 do
        State.Waypoints[slot] = nil
        removeWaypointMarker(slot)
    end
    worldStatus.Text = "Waypoints eliminados."
end)

addAction(worldPage, "Reiniciar personaje", "Solicita el reinicio de tu personaje", "Reset", function()
    local humanoid = getLocalHumanoid()
    if humanoid then humanoid.Health = 0 end
end)

local worldNote = makeLabel(worldPage, "NOTA: los waypoints y teletransportes son herramientas locales de prueba. En un juego con movimiento validado por servidor, este puede corregir o rechazar el cambio de posicion.", 10, Color3.fromRGB(171, 170, 190), Enum.Font.Gotham)
worldNote.Size = UDim2.new(1, 0, 0, 58)
worldNote.TextWrapped = true
worldNote.TextYAlignment = Enum.TextYAlignment.Top

-- MM2 Tools: indicadores locales basados unicamente en objetos visibles
addSection(mm2Page, "MM2 · Escaneo local")
addToggle(mm2Page, "Role Scanner", "Etiqueta roles solo si detecta una herramienta equipada visible", State.MM2RoleESP, function(v)
    State.MM2RoleESP = v
    if not v then
        for player, gui in pairs(mm2RoleObjects) do pcall(function() gui:Destroy() end); mm2RoleObjects[player] = nil end
    end
end)
addToggle(mm2Page, "Dropped Weapon ESP", "Resalta Tools de arma que esten en Workspace y no equipadas", State.MM2DroppedWeaponESP, function(v)
    State.MM2DroppedWeaponESP = v
    if not v then
        for object, visual in pairs(mm2WeaponObjects) do pcall(function() visual:Destroy() end); mm2WeaponObjects[object] = nil end
    end
end)
mm2StatusLabel = makeLabel(mm2Page, "Escaner inactivo · roles no confirmados", 10, Color3.fromRGB(171, 170, 190), Enum.Font.Gotham)
mm2StatusLabel.Size = UDim2.new(1, 0, 0, 42)
mm2StatusLabel.TextWrapped = true
addAction(mm2Page, "Actualizar escaneo", "Actualiza etiquetas y armas visibles ahora", "Escanear", function()
    refreshMM2Visuals()
    if mm2StatusLabel then
        mm2StatusLabel.Text = string.format("Jugadores: %d · Etiquetas: %d · Armas: %d", #Players:GetPlayers(), (function() local n=0 for _ in pairs(mm2RoleObjects) do n+=1 end return n end)(), (function() local n=0 for _ in pairs(mm2WeaponObjects) do n+=1 end return n end)())
    end
end)
addSection(mm2Page, "Android")
addToggle(mm2Page, "Vibracion tactil", "Pequena respuesta haptica en controles compatibles", State.TouchFeedback, function(v)
    State.TouchFeedback = v
    if v then pulseHaptic() end
end)
addToggle(mm2Page, "Sonido de interfaz", "Pequeno sonido al pulsar controles del hub", State.UIAudio, function(v)
    State.UIAudio = v
    if v then playUIAudio(true) end
end)
local mm2Note = makeLabel(mm2Page, "Nota: la deteccion de roles se basa en nombres de Tools visibles (Knife/Gun). Si el juego guarda los roles en atributos o datos del servidor, esta lectura puede mostrar UNKNOWN o ser incorrecta.", 9, Color3.fromRGB(171, 170, 190), Enum.Font.Gotham)
mm2Note.Size = UDim2.new(1, 0, 0, 66)
mm2Note.TextWrapped = true

-- Settings
addSection(settingsPage, "Interfaz")
local compactToggle
addAction(settingsPage, "Restablecer posicion", "Centra nuevamente la ventana", "Centrar", function()
    main.Position = UDim2.fromScale(0.5, 0.5)
end)
addAction(settingsPage, "Limpiar ESP", "Elimina todos los marcadores visuales", "Limpiar", function()
    for targetPlayer in pairs(espObjects) do removeESP(targetPlayer) end
end)
-- Finder: resalta NPCs y objetos/herramientas detectables por nombre
addSection(finderPage, "NPC & Item Finder")
addToggle(finderPage, "NPC ESP", "Resalta modelos con Humanoid que no sean jugadores", State.NPCFinderEnabled, function(v)
    State.NPCFinderEnabled = v
end)
addToggle(finderPage, "Item Finder", "Busca Tools y objetos con nombres comunes de loot", State.ItemFinderEnabled, function(v)
    State.ItemFinderEnabled = v
end)
local finderInfo = makeLabel(finderPage, "El buscador usa nombres y tipos visibles en Workspace. No adivina roles ni revela datos ocultos del juego.", 10, Color3.fromRGB(171,170,190), Enum.Font.Gotham)
finderInfo.Size = UDim2.new(1,0,0,48)
finderInfo.TextWrapped = true
addAction(finderPage, "Limpiar marcadores", "Elimina todos los resaltados del Finder", "Limpiar", function()
    for object, visual in pairs(finderObjects) do pcall(function() visual:Destroy() end); finderObjects[object] = nil end
end)

-- Camera: espectador y zoom local
addSection(cameraPage, "Camera Pro")
addAction(cameraPage, "Espectar siguiente jugador", "Cambia la camara al siguiente jugador vivo", "Siguiente", function()
    local candidates = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if plr ~= LocalPlayer and hum and hum.Health > 0 then table.insert(candidates, plr) end
    end
    table.sort(candidates, function(a,b) return a.Name < b.Name end)
    if #candidates == 0 then return end
    spectateIndex = (spectateIndex % #candidates) + 1
    local targetHum = candidates[spectateIndex].Character:FindFirstChildOfClass("Humanoid")
    local camera = Workspace.CurrentCamera
    if camera and targetHum then
        if not savedCameraSubject then savedCameraSubject = camera.CameraSubject; savedCameraType = camera.CameraType end
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = targetHum
        State.SpectateEnabled = true
    end
end)
addAction(cameraPage, "Volver a mi personaje", "Restaura la camara al personaje local", "Volver", function()
    local camera = Workspace.CurrentCamera
    local hum = getLocalHumanoid()
    if camera and hum then camera.CameraType = Enum.CameraType.Custom; camera.CameraSubject = hum end
    savedCameraSubject, savedCameraType = nil, nil
    State.SpectateEnabled = false
end)
addSlider(cameraPage, "Zoom maximo", 8, 80, math.floor(savedZoomMax), function(v)
    LocalPlayer.CameraMaxZoomDistance = v
    LocalPlayer.CameraMinZoomDistance = math.min(savedZoomMin, v)
end)
addAction(cameraPage, "Restaurar zoom", "Devuelve los limites originales de camara", "Reset", function()
    LocalPlayer.CameraMinZoomDistance = savedZoomMin
    LocalPlayer.CameraMaxZoomDistance = savedZoomMax
end)

-- Player inspector and session stats
addSection(playerPage, "Player Inspector")
local playerInfoLabel = makeLabel(playerPage, "Cargando informacion...", 10, Color3.fromRGB(220,218,238), Enum.Font.Gotham)
playerInfoLabel.Size = UDim2.new(1,0,0,112)
playerInfoLabel.TextWrapped = true
playerInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
addAction(playerPage, "Copiar mi UserId", "Muestra tu identificador en la consola", "Mostrar", function()
    print("[WXNNXRX] UserId: " .. tostring(LocalPlayer.UserId))
    playerInfoLabel.Text = "Nombre: "..LocalPlayer.Name.."\nDisplay: "..LocalPlayer.DisplayName.."\nUserId: "..tostring(LocalPlayer.UserId)
end)
addAction(playerPage, "Refrescar datos", "Actualiza salud, velocidad y jugadores", "Actualizar", function()
    local h = getLocalHumanoid()
    if h then playerInfoLabel.Text = string.format("Jugador: %s\nSalud: %.0f / %.0f\nVelocidad: %.1f\nJugadores: %d", LocalPlayer.Name, h.Health, h.MaxHealth, h.WalkSpeed, #Players:GetPlayers()) end
end)

-- Performance tools
addSection(performancePage, "Performance Monitor")
local performanceLabel = makeLabel(performancePage, "FPS: --\nPing: --\nJugadores: --\nSesion: --", 11, Color3.fromRGB(225,222,245), Enum.Font.GothamSemibold)
performanceLabel.Size = UDim2.new(1,0,0,86)
performanceLabel.TextYAlignment = Enum.TextYAlignment.Top
addToggle(performancePage, "Low Graphics", "Desactiva sombras y efectos locales compatibles", State.LowGraphics, function(v)
    State.LowGraphics = v
    if v then
        lowGraphicsDefaults.GlobalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
        for _, obj in ipairs(Lighting:GetDescendants()) do
            if obj:IsA("PostEffect") then
                lowGraphicsDefaults[obj] = obj.Enabled
                obj.Enabled = false
            end
        end
    else
        if lowGraphicsDefaults.GlobalShadows ~= nil then Lighting.GlobalShadows = lowGraphicsDefaults.GlobalShadows end
        for obj, enabled in pairs(lowGraphicsDefaults) do
            if typeof(obj) == "Instance" and obj.Parent then pcall(function() obj.Enabled = enabled end) end
        end
        table.clear(lowGraphicsDefaults)
    end
end)
addAction(performancePage, "Limpiar Finder", "Elimina adornos locales del buscador", "Limpiar", function()
    for object, visual in pairs(finderObjects) do pcall(function() visual:Destroy() end); finderObjects[object] = nil end
end)

-- Profiles: presets no persistentes para evitar APIs de archivo del executor
addSection(profilesPage, "Quick Profiles")
addAction(profilesPage, "Perfil Visual", "Activa ESP, HUD y mira central", "Aplicar", function()
    if espMasterControl then espMasterControl.Set(true) end
    State.HUDEnabled = true; hudLabel.Visible = true
    State.CrosshairEnabled = true; crosshair.Visible = true
end)
addAction(profilesPage, "Perfil Exploracion", "Activa FullBright y herramientas de ubicacion", "Aplicar", function()
    if not State.FullBright then setFullBright(true) end
    State.HUDEnabled = true; hudLabel.Visible = true
end)
addAction(profilesPage, "Perfil Rendimiento", "Apaga efectos visuales opcionales y aplica Low Graphics", "Aplicar", function()
    State.ESPEnabled = false
    for targetPlayer in pairs(espObjects) do removeESP(targetPlayer) end
    State.HitboxPreview = false
    for model, adornments in pairs(hitboxObjects) do
        for _, adornment in ipairs(adornments) do pcall(function() adornment:Destroy() end) end
        hitboxObjects[model] = nil
    end
    if lowGraphicsDefaults.GlobalShadows == nil then lowGraphicsDefaults.GlobalShadows = Lighting.GlobalShadows end
    State.LowGraphics = true
    Lighting.GlobalShadows = false
    for _, obj in ipairs(Lighting:GetDescendants()) do if obj:IsA("PostEffect") then if lowGraphicsDefaults[obj] == nil then lowGraphicsDefaults[obj] = obj.Enabled end; obj.Enabled = false end end
end)
addAction(profilesPage, "Restaurar perfil", "Apaga mejoras locales y restaura valores", "Reset", function()
    State.HUDEnabled = false; hudLabel.Visible = false
    State.CrosshairEnabled = false; crosshair.Visible = false
    State.HitboxPreview = false
    for model, adornments in pairs(hitboxObjects) do
        for _, adornment in ipairs(adornments) do pcall(function() adornment:Destroy() end) end
        hitboxObjects[model] = nil
    end
    State.LowGraphics = false
    if lowGraphicsDefaults.GlobalShadows ~= nil then Lighting.GlobalShadows = lowGraphicsDefaults.GlobalShadows end
    for obj, enabled in pairs(lowGraphicsDefaults) do if typeof(obj) == "Instance" and obj.Parent then pcall(function() obj.Enabled = enabled end) end end
    table.clear(lowGraphicsDefaults)
    if State.FullBright then setFullBright(false) end
end)
local profileNote = makeLabel(profilesPage, "Los perfiles se aplican durante esta sesion; no se guardan en disco. No se incluye tema RGB.", 10, Color3.fromRGB(171,170,190), Enum.Font.Gotham)
profileNote.Size = UDim2.new(1,0,0,38)
profileNote.TextWrapped = true

addAction(settingsPage, "Restaurar mejoras", "Apaga movimiento, FOV y FullBright", "Reset", function()
    speedControl.Set(false)
    jumpControl.Set(false)
    fovControl.Set(false)
    if State.FullBright then setFullBright(false) end
    setNoClip(false)
    State.InfiniteJumpEnabled = false
    State.AutoVoidRecovery = false
    State.CrosshairEnabled = false
    State.HUDEnabled = false
    crosshair.Visible = false
    hudLabel.Visible = false
end)
addSection(settingsPage, "Informacion")
local note = makeLabel(settingsPage, "WXNNXRX HUB • modulo local\nLos efectos visuales y WallHop se ejecutan en tu cliente. Las mecanicas que deban afectar a todos los jugadores necesitan soporte del servidor del juego.", 10, Color3.fromRGB(161, 160, 181), Enum.Font.Gotham)
note.Size = UDim2.new(1, 0, 0, 68)
note.TextWrapped = true
note.TextYAlignment = Enum.TextYAlignment.Top

--// Reproductor de musica local: requiere un ID de audio que puedas utilizar.
local musicSound = Instance.new("Sound")
musicSound.Name = "WXNNXRX_BackgroundMusic"
musicSound.Volume = 0.25
musicSound.Looped = true
musicSound.Parent = SoundService

addSection(settingsPage, "Reproductor de musica")
local musicCard = Instance.new("Frame")
musicCard.Name = "MusicPlayerCard"
musicCard.Size = UDim2.new(1, 0, 0, 106)
musicCard.BackgroundColor3 = COLORS.PanelSoft
musicCard.BackgroundTransparency = 0.12
musicCard.BorderSizePixel = 0
musicCard.Parent = settingsPage
corner(musicCard, 11)
outline(musicCard, COLORS.AccentLight, 0.80, 0.8)

local musicIdBox = Instance.new("TextBox")
musicIdBox.Name = "MusicAssetId"
musicIdBox.Position = UDim2.fromOffset(10, 9)
musicIdBox.Size = UDim2.new(1, -20, 0, 31)
musicIdBox.BackgroundColor3 = Color3.fromRGB(13, 14, 23)
musicIdBox.BackgroundTransparency = 0.05
musicIdBox.BorderSizePixel = 0
musicIdBox.PlaceholderText = "ID de audio autorizado"
musicIdBox.PlaceholderColor3 = COLORS.Subtle
musicIdBox.Text = ""
musicIdBox.TextColor3 = COLORS.Text
musicIdBox.TextSize = 10
musicIdBox.Font = Enum.Font.Gotham
musicIdBox.ClearTextOnFocus = false
musicIdBox.TextXAlignment = Enum.TextXAlignment.Left
musicIdBox.Parent = musicCard
corner(musicIdBox, 8)
local musicInputPadding = Instance.new("UIPadding")
musicInputPadding.PaddingLeft = UDim.new(0, 9)
musicInputPadding.PaddingRight = UDim.new(0, 9)
musicInputPadding.Parent = musicIdBox

local musicStatus = makeLabel(musicCard, "Estado: detenido", 9, COLORS.Muted, Enum.Font.Gotham)
musicStatus.Position = UDim2.fromOffset(11, 43)
musicStatus.Size = UDim2.new(1, -22, 0, 15)

local musicButtonHolder = Instance.new("Frame")
musicButtonHolder.Position = UDim2.fromOffset(9, 64)
musicButtonHolder.Size = UDim2.new(1, -18, 0, 33)
musicButtonHolder.BackgroundTransparency = 1
musicButtonHolder.Parent = musicCard
local musicButtonLayout = Instance.new("UIListLayout")
musicButtonLayout.FillDirection = Enum.FillDirection.Horizontal
musicButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
musicButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
musicButtonLayout.Padding = UDim.new(0, 7)
musicButtonLayout.Parent = musicButtonHolder

local function makeMusicButton(buttonText)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1/3, -5, 0, 31)
    button.BackgroundColor3 = COLORS.AccentSoft
    button.BorderSizePixel = 0
    button.Text = buttonText
    button.TextColor3 = COLORS.Text
    button.TextSize = 9
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = musicButtonHolder
    corner(button, 8)
    return button
end

local musicPlay = makeMusicButton("▶  Play")
local musicPause = makeMusicButton("Ⅱ  Pause")
local musicStop = makeMusicButton("■  Stop")

musicPlay.Activated:Connect(function()
    local raw = string.match(musicIdBox.Text, "^%s*(.-)%s*$") or ""
    local id = string.match(raw, "^(%d+)$") or string.match(raw, "^rbxassetid://(%d+)$")
    if not id then
        musicStatus.Text = "Estado: escribe un ID numerico valido"
        musicStatus.TextColor3 = COLORS.Danger
        playUIAudio(false)
        return
    end
    musicSound:Stop()
    musicSound.SoundId = "rbxassetid://" .. id
    local ok = pcall(function() musicSound:Play() end)
    musicStatus.Text = ok and "Estado: solicitando reproduccion" or "Estado: audio no disponible"
    musicStatus.TextColor3 = ok and COLORS.Success or COLORS.Danger
    playUIAudio(ok)
end)

musicPause.Activated:Connect(function()
    if musicSound.IsPlaying then musicSound:Pause() end
    musicStatus.Text = "Estado: pausado"
    musicStatus.TextColor3 = COLORS.Muted
    playUIAudio(true)
end)

musicStop.Activated:Connect(function()
    musicSound:Stop()
    musicStatus.Text = "Estado: detenido"
    musicStatus.TextColor3 = COLORS.Muted
    playUIAudio(true)
end)

addSlider(settingsPage, "Volumen de musica", 0, 100, 25, function(value)
    musicSound.Volume = value / 100
end)
local musicNote = makeLabel(settingsPage, "Usa solo IDs de audio con permiso para tu experiencia. Roblox puede bloquear audios privados o sin permiso.", 9, COLORS.Muted, Enum.Font.Gotham)
musicNote.Size = UDim2.new(1, 0, 0, 34)
musicNote.TextWrapped = true
musicNote.TextYAlignment = Enum.TextYAlignment.Top

--// FAB: accesos rapidos a inicio, ESP, WallHop y configuracion.
local fabDock = Instance.new("Frame")
fabDock.Name = "QuickFAB"
fabDock.AnchorPoint = Vector2.new(1, 1)
fabDock.Position = UDim2.new(1, -12, 1, -12)
fabDock.Size = UDim2.fromOffset(48, 238)
fabDock.BackgroundTransparency = 1
fabDock.ZIndex = 80
fabDock.Parent = main
local fabLayout = Instance.new("UIListLayout")
fabLayout.FillDirection = Enum.FillDirection.Vertical
fabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
fabLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
fabLayout.Padding = UDim.new(0, 7)
fabLayout.SortOrder = Enum.SortOrder.LayoutOrder
fabLayout.Parent = fabDock

local fabMain = Instance.new("TextButton")
fabMain.Name = "MainFAB"
fabMain.Size = UDim2.fromOffset(46, 46)
fabMain.BackgroundColor3 = COLORS.Accent
fabMain.BorderSizePixel = 0
fabMain.Text = "+"
fabMain.TextColor3 = Color3.new(1, 1, 1)
fabMain.TextSize = 23
fabMain.Font = Enum.Font.GothamBold
fabMain.AutoButtonColor = false
fabMain.LayoutOrder = 5
fabMain.ZIndex = 82
fabMain.Parent = fabDock
corner(fabMain, 23)
outline(fabMain, Color3.fromRGB(190, 177, 255), 0.25, 1.2)

local fabOpen = false
local function addFabItem(symbol, order, callback)
    local button = Instance.new("TextButton")
    button.Name = "QuickAction" .. tostring(order)
    button.Size = UDim2.fromOffset(39, 39)
    button.BackgroundColor3 = Color3.fromRGB(47, 43, 73)
    button.BorderSizePixel = 0
    button.Text = symbol
    button.TextColor3 = COLORS.Text
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Visible = false
    button.LayoutOrder = order
    button.ZIndex = 81
    button.Parent = fabDock
    corner(button, 20)
    outline(button, COLORS.AccentLight, 0.48, 1)
    track(button.Activated:Connect(function()
        if not alive then return end
        if callback then callback() end
        fabOpen = false
        fabMain.Text = "+"
        TweenService:Create(fabMain, TweenInfo.new(0.15), {Rotation = 0}):Play()
        for _, item in ipairs(fabDock:GetChildren()) do
            if item:IsA("TextButton") and item ~= fabMain then item.Visible = false end
        end
        pulseHaptic()
        playUIAudio(true)
    end))
    return button
end

addFabItem("⌂", 1, function() selectTab("Home") end)
addFabItem("◉", 2, function()
    if espMasterControl then espMasterControl.Set(not espMasterControl.Get()) end
end)
addFabItem("↟", 3, function()
    if wallMasterControl then wallMasterControl.Set(not wallMasterControl.Get()) end
end)
addFabItem("⚙", 4, function() selectTab("Settings") end)

fabMain.Activated:Connect(function()
    if not alive then return end
    fabOpen = not fabOpen
    fabMain.Text = fabOpen and "×" or "+"
    TweenService:Create(fabMain, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Rotation = fabOpen and 45 or 0,
    }):Play()
    for _, item in ipairs(fabDock:GetChildren()) do
        if item:IsA("TextButton") and item ~= fabMain then
            item.Visible = fabOpen
            if fabOpen then
                item.BackgroundTransparency = 1
                TweenService:Create(item, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0,
                }):Play()
            end
        end
    end
    pulseHaptic()
    playUIAudio(true)
end)

--// Seleccion inicial, arrastre y minimizacion.
selectTab("Home")
refreshResponsiveLayout()

local dragStart = nil
local startPosition = nil
track(topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end))
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        shadow.Position = main.Position
    end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

local function setMinimized(value)
    minimized = value == true
    sidebar.Visible = not minimized
    body.Visible = not minimized
    fabDock.Visible = not minimized
    local targetHeight = minimized and 52 or panelHeight
    TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(panelWidth, targetHeight),
    }):Play()
    TweenService:Create(shadow, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(panelWidth + 14, targetHeight + 14),
    }):Play()
    minimizeButton.Text = minimized and "+" or "—"
end

track(minimizeButton.Activated:Connect(function()
    if alive then
        setMinimized(not minimized)
        playUIAudio(true)
    end
end))

--// Aim Assist y previsualizacion de hitboxes (solo cliente)
local function getAimPart(character)
    if not character then return nil end
    return character:FindFirstChild(State.AimTargetPart) or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

local function hasLineOfSight(part, character)
    local camera = Workspace.CurrentCamera
    if not camera or not part then return false end
    local origin = camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, camera }
    local result = Workspace:Raycast(origin, direction, params)
    return result == nil or result.Instance:IsDescendantOf(character)
end

local function updateAimAssist(deltaTime)
    local camera = Workspace.CurrentCamera
    if not State.AimEnabled or not camera then
        aimTarget = nil
        aimCircle.Visible = false
        return
    end
    aimCircle.Visible = true
    aimCircle.Size = UDim2.fromOffset(State.AimFOV * 2, State.AimFOV * 2)
    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
    local bestPart, bestDistance = nil, State.AimFOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (not State.AimTeamCheck or not isSameTeam(player)) then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local part = getAimPart(character)
            if humanoid and humanoid.Health > 0 and part then
                local point, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen and point.Z > 0 then
                    local distance = (Vector2.new(point.X, point.Y) - center).Magnitude
                    if distance < bestDistance and (not State.AimVisibleCheck or hasLineOfSight(part, character)) then
                        bestDistance, bestPart = distance, part
                    end
                end
            end
        end
    end
    aimTarget = bestPart
    if bestPart then
        local goal = CFrame.lookAt(camera.CFrame.Position, bestPart.Position)
        local alpha = 1 - math.exp(-State.AimSmoothness * math.max(deltaTime, 0))
        camera.CFrame = camera.CFrame:Lerp(goal, math.clamp(alpha, 0, 1))
    end
end

local function clearHitboxPreview()
    for model, adornments in pairs(hitboxObjects) do
        for _, adornment in ipairs(adornments) do pcall(function() adornment:Destroy() end) end
        hitboxObjects[model] = nil
    end
end

local function updateHitboxPreview()
    if not State.HitboxPreview then
        clearHitboxPreview()
        return
    end
    local seen = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if character and humanoid and humanoid.Health > 0 then
                seen[character] = true
                local parts = { character:FindFirstChild("Head"), character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") }
                local current = hitboxObjects[character]
                if not current then current = {}; hitboxObjects[character] = current end
                for index, part in ipairs(parts) do
                    if part and part:IsA("BasePart") then
                        local adornment = current[index]
                        if not adornment or not adornment.Parent then
                            adornment = Instance.new("BoxHandleAdornment")
                            adornment.Name = "WXNNXRX_HitboxPreview"
                            adornment.Adornee = part
                            adornment.AlwaysOnTop = true
                            adornment.ZIndex = 8
                            adornment.Transparency = 0.62
                            adornment.Color3 = Color3.fromRGB(255, 105, 125)
                            adornment.Parent = hitboxFolder
                            current[index] = adornment
                        end
                        adornment.Size = part.Size * State.HitboxScale
                    end
                end
            end
        end
    end
    for model, adornments in pairs(hitboxObjects) do
        if not seen[model] or not model.Parent then
            for _, adornment in ipairs(adornments) do pcall(function() adornment:Destroy() end) end
            hitboxObjects[model] = nil
        end
    end
end

--// Cierre y limpieza completa
local function destroyHub()
    if not alive then return end
    alive = false
    State.BombAutoLoop = false
    State.CameraAimbot = false
    State.TriggerBot = false
    State.AntiAim = false
    State.RoleESP = false
    State.WeaponESP = false
    State.AutoFarmCoins = false
    State.AutoFarmCandy = false
    if androidFOVGui then androidFOVGui:Destroy(); androidFOVGui = nil end
    androidClearESP()
    if androidToastHolder then androidToastHolder:Destroy(); androidToastHolder = nil end
    State.ESPEnabled = false
    State.AutoWallHop = false
    State.WallHopEnabled = false
    State.CustomFOV = false
    State.CrosshairEnabled = false
    State.HUDEnabled = false
    State.AimEnabled = false
    State.HitboxPreview = false
    State.NPCFinderEnabled = false
    State.ItemFinderEnabled = false
    State.InfiniteJumpEnabled = false
    State.AutoVoidRecovery = false
    State.LastSafeCFrame = nil
    aimCircle.Visible = false
    clearHitboxPreview()
    restoreNoClip()
    if State.FullBright then setFullBright(false) end
    restoreCameraFOV()
    restoreMovement()
    LocalPlayer.CameraMinZoomDistance = savedZoomMin
    LocalPlayer.CameraMaxZoomDistance = savedZoomMax
    local camera = Workspace.CurrentCamera
    local localHumanoid = getLocalHumanoid()
    if camera and localHumanoid then camera.CameraType = Enum.CameraType.Custom; camera.CameraSubject = localHumanoid end
    if State.LowGraphics then
        if lowGraphicsDefaults.GlobalShadows ~= nil then Lighting.GlobalShadows = lowGraphicsDefaults.GlobalShadows end
        for obj, enabled in pairs(lowGraphicsDefaults) do if typeof(obj) == "Instance" and obj.Parent then pcall(function() obj.Enabled = enabled end) end end
        table.clear(lowGraphicsDefaults)
    end
    for object, visual in pairs(finderObjects) do pcall(function() visual:Destroy() end); finderObjects[object] = nil end
    clearMM2Visuals()
    pcall(function() mm2Folder:Destroy() end)
    pcall(function() finderFolder:Destroy() end)
    clearSelectionMode()
    pcall(function() musicSound:Stop(); musicSound:Destroy() end)
    pcall(function() uiClickSound:Stop(); uiClickSound:Destroy() end)
    disconnectAll(connections)
    for targetPlayer in pairs(espObjects) do removeESP(targetPlayer) end
    pcall(function() espFolder:Destroy() end)
    pcall(function() hitboxFolder:Destroy() end)
    pcall(function() waypointFolder:Destroy() end)
    table.clear(waypointMarkers)
    table.clear(State.Waypoints)
    pcall(function() screenGui:Destroy() end)
end
track(closeButton.Activated:Connect(destroyHub))

--// Controles de gameplay
track(UserInputService.JumpRequest:Connect(function()
    if not alive then return end
    if State.InfiniteJumpEnabled then
        local humanoid = getLocalHumanoid()
        if humanoid and humanoid.Health > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    if State.WallHopEnabled then
        local result = getWallRaycastResult()
        if result then executeWallHop(result, "Manual") end
    end
end))

--// Un solo ciclo Heartbeat compartido para ESP y Auto WallHop
track(RunService.Heartbeat:Connect(function(deltaTime)
    if not alive then return end

    espAccumulator += deltaTime
    if espAccumulator >= 0.12 then
        espAccumulator = 0
        if State.ESPEnabled then
            refreshAllESP()
        end
    end

    finderAccumulator += deltaTime
    if finderAccumulator >= 0.65 then
        finderAccumulator = 0
        local wanted = {}
        if State.NPCFinderEnabled then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChildWhichIsA("BasePart") then
                    wanted[obj] = "NPC"
                end
            end
        end
        if State.ItemFinderEnabled then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if obj:IsA("Tool") or n:find("coin") or n:find("gun") or n:find("knife") or n:find("key") or n:find("loot") or n:find("item") then
                    if obj:IsA("BasePart") or obj:IsA("Tool") or obj:IsA("Model") then wanted[obj] = "ITEM" end
                end
            end
        end
        for object, labelText in pairs(wanted) do
            if object.Parent and not finderObjects[object] then
                local adornee = object:IsA("Model") and (object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")) or (object:IsA("Tool") and object:FindFirstChildWhichIsA("BasePart")) or object
                if adornee and adornee:IsA("BasePart") then
                    local h = Instance.new("Highlight")
                    h.Name = "WXNNXRX_FinderHighlight"
                    h.Adornee = object:IsA("Model") and object or adornee
                    h.FillColor = labelText == "NPC" and Color3.fromRGB(255,110,110) or Color3.fromRGB(110,210,255)
                    h.OutlineColor = h.FillColor
                    h.FillTransparency = 0.72
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = finderFolder
                    finderObjects[object] = h
                end
            end
        end
        for object, visual in pairs(finderObjects) do
            if not object.Parent or not wanted[object] then pcall(function() visual:Destroy() end); finderObjects[object] = nil end
        end
    end

    mm2Accumulator += deltaTime
    if mm2Accumulator >= 1.0 then
        mm2Accumulator = 0
        if State.MM2RoleESP or State.MM2DroppedWeaponESP then
            refreshMM2Visuals()
        end
        if mm2StatusLabel and mm2StatusLabel.Parent then
            local roleCount, weaponCount = 0, 0
            for _ in pairs(mm2RoleObjects) do roleCount += 1 end
            for _ in pairs(mm2WeaponObjects) do weaponCount += 1 end
            mm2StatusLabel.Text = string.format("Etiquetas visibles: %d · Armas detectadas: %d", roleCount, weaponCount)
        end
    end

    hitboxAccumulator += deltaTime
    if hitboxAccumulator >= 0.18 then
        hitboxAccumulator = 0
        updateHitboxPreview()
    end

    if State.NoClipEnabled then
        noclipAccumulator += deltaTime
        if noclipAccumulator >= 0.12 then
            noclipAccumulator = 0
            applyNoClipToCharacter(LocalPlayer.Character)
        end
    end

    if State.AutoVoidRecovery then
        recoveryAccumulator += deltaTime
        if recoveryAccumulator >= 0.2 then
            recoveryAccumulator = 0
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and root and humanoid.Health > 0 then
                local safeY = Workspace.FallenPartsDestroyHeight + 35
                if humanoid.FloorMaterial ~= Enum.Material.Air and root.Position.Y > safeY then
                    State.LastSafeCFrame = root.CFrame
                elseif root.Position.Y <= safeY and State.LastSafeCFrame then
                    root.CFrame = State.LastSafeCFrame + Vector3.new(0, 3, 0)
                    root.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end
    end

    autoAccumulator += deltaTime
    if autoAccumulator >= 0.12 then
        autoAccumulator = 0
        if State.WallHopEnabled and State.AutoWallHop and State.SelectedBrickColor and not wallHopBusy then
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local result = getWallRaycastResult()
                local hit = result and result.Instance
                if hit and hit:IsA("BasePart") and hit.BrickColor == State.SelectedBrickColor then
                    executeWallHop(result, "Auto")
                end
            end
        end
    end
end))

--// Mantener el selector/UI al dia
local fpsFrames = 0
local fpsElapsed = 0
track(RunService.RenderStepped:Connect(function(deltaTime)
    if not alive then return end
    updateCameraFOV()
    updateAimAssist(deltaTime)
    fpsFrames += 1
    fpsElapsed += deltaTime
    if fpsElapsed >= 0.5 then
        measuredFPS = math.floor(fpsFrames / math.max(fpsElapsed, 0.001) + 0.5)
        fpsFrames = 0
        fpsElapsed = 0
        if performanceLabel and performanceLabel.Parent then
            local ping = 0
            pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5) end)
            performanceLabel.Text = string.format("FPS: %d\nPing: %d ms\nJugadores: %d\nSesion: %02d:%02d", measuredFPS, ping, #Players:GetPlayers(), math.floor((os.clock()-sessionStarted)/60), math.floor((os.clock()-sessionStarted)%60))
        end
        if State.HUDEnabled then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local p = root.Position
                local pingMs = 0
                pcall(function() pingMs = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5) end)
                hudLabel.Text = string.format("FPS: %d | Ping: %d ms\nXYZ: %.0f, %.0f, %.0f", measuredFPS, pingMs, p.X, p.Y, p.Z)
            else
                hudLabel.Text = string.format("FPS: %d | Ping: --\nXYZ: --", measuredFPS)
            end
        end
    end
    if State.SelectedBrickColor then
        selectedColorText.Text = "Color seleccionado: " .. State.SelectedBrickColor.Name
        selectedColorText.TextColor3 = State.SelectedColor or Color3.fromRGB(188, 183, 215)
    elseif State.SelectingColor then
        selectedColorText.Text = "Toca/clica una pieza del mapa..."
        selectedColorText.TextColor3 = Color3.fromRGB(255, 205, 115)
    else
        selectedColorText.Text = "Color seleccionado: ninguno"
        selectedColorText.TextColor3 = Color3.fromRGB(188, 183, 215)
    end
    if selectButton and selectButton.Parent then
        if State.SelectingColor then
            selectButton.Text = "Esperando..."
            selectButton.BackgroundColor3 = Color3.fromRGB(65, 145, 125)
        else
            selectButton.Text = "Seleccionar"
            selectButton.BackgroundColor3 = Color3.fromRGB(91, 75, 183)
        end
    end
end))

track(LocalPlayer.CharacterAdded:Connect(function(character)
    task.spawn(function()
        local humanoid = character:WaitForChild("Humanoid", 8)
        if alive and humanoid and (State.SpeedEnabled or State.JumpEnabled) then
            applyMovement(humanoid)
        end
    end)
end))

print("[WXNNXRX HUB] Cargado: UI Dark Glass integrada + ESP + WallHop + Movement + Visual+ + Aim + Hitbox Preview + World Tools + Waypoints + MM2 Tools + Android Haptics + UI Audio + FAB + Music")