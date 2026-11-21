--[[
    MM2 HUB V2 - INTERFAZ COSMETICA Y CONTROLES LOCALES
    --------------------------------------------------
    Tipo: LocalScript para Roblox Studio.
    Ubicacion sugerida: StarterPlayer > StarterPlayerScripts.

    Incluye:
      - Interfaz oscura con acentos rosas, adaptable a pantallas pequenas.
      - Pestanas, botones animados, minimizar, cerrar y arrastrar.
      - Tema nocturno reversible sin destruir efectos de Lighting ajenos.
      - Bloom opcional y reversible.
      - Shift Lock local con boton y tecla LeftShift.
      - Limpieza de conexiones, GUI y cambios visuales al cerrar.

    No incluye aimbot, wall checks, deteccion de roles ocultos ni ESP de jugadores.
    Esta version esta pensada para experiencias propias en Roblox Studio.
]]

--// Servicios y referencias
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[MM2 HUB V2] Este LocalScript debe ejecutarse en el cliente.")
    return
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GUI_NAME = "MM2_HUB_V2"

--// Paleta
local COLORS = {
    Background = Color3.fromRGB(12, 12, 17),
    Panel = Color3.fromRGB(20, 20, 28),
    PanelAlt = Color3.fromRGB(27, 27, 37),
    Button = Color3.fromRGB(34, 34, 45),
    ButtonHover = Color3.fromRGB(48, 39, 55),
    Accent = Color3.fromRGB(255, 105, 180),
    AccentSoft = Color3.fromRGB(117, 57, 91),
    Text = Color3.fromRGB(245, 241, 247),
    Muted = Color3.fromRGB(164, 158, 173),
    Border = Color3.fromRGB(57, 51, 66),
    Success = Color3.fromRGB(126, 220, 166),
    Off = Color3.fromRGB(190, 183, 198),
}

--// Limpieza y conexiones
local connections = {}
local pageConnections = {}
local buildingPage = false
local unloaded = false

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function connectUI(signal, callback)
    local connection = signal:Connect(callback)
    if buildingPage then
        table.insert(pageConnections, connection)
    else
        table.insert(connections, connection)
    end
    return connection
end

local function disconnectPageConnections()
    for index = #pageConnections, 1, -1 do
        local connection = pageConnections[index]
        if connection and connection.Connected then
            connection:Disconnect()
        end
        pageConnections[index] = nil
    end
end

local function disconnectAll()
    disconnectPageConnections()
    for index = #connections, 1, -1 do
        local connection = connections[index]
        if connection and connection.Connected then
            connection:Disconnect()
        end
        connections[index] = nil
    end
end

-- Elimina una interfaz vieja del mismo nombre si se vuelve a ejecutar.
local previousGui = PlayerGui:FindFirstChild(GUI_NAME)
if previousGui then
    previousGui:Destroy()
end

--// Estado de funciones
local nightEnabled = false
local bloomEnabled = false
local shiftLockEnabled = false
local minimized = false

local savedLighting = {}
local lightingProperties = {
    "ClockTime",
    "Brightness",
    "Ambient",
    "OutdoorAmbient",
    "FogColor",
    "FogStart",
    "FogEnd",
    "ExposureCompensation",
    "GlobalShadows",
    "EnvironmentDiffuseScale",
    "EnvironmentSpecularScale",
}

for _, propertyName in ipairs(lightingProperties) do
    local success, value = pcall(function()
        return Lighting[propertyName]
    end)
    if success then
        savedLighting[propertyName] = value
    end
end

local activeHumanoid = nil
local savedHumanoidSettings = nil
local savedMouseBehavior = nil
local savedMouseIconEnabled = nil
local heartIndicator = nil

local nightEffect = Lighting:FindFirstChild("MM2HubV2_NightColor")
if nightEffect then
    nightEffect:Destroy()
end

local bloomEffect = Lighting:FindFirstChild("MM2HubV2_Bloom")
if bloomEffect then
    bloomEffect:Destroy()
end

local function restoreLightingProperties()
    for propertyName, value in pairs(savedLighting) do
        pcall(function()
            Lighting[propertyName] = value
        end)
    end
end

local function setNightMode(enabled)
    enabled = enabled == true
    if nightEnabled == enabled then
        return
    end

    nightEnabled = enabled

    if enabled then
        Lighting.ClockTime = 20.25
        Lighting.Brightness = 1.35
        Lighting.Ambient = Color3.fromRGB(48, 43, 65)
        Lighting.OutdoorAmbient = Color3.fromRGB(35, 32, 52)
        Lighting.FogColor = Color3.fromRGB(24, 21, 39)
        Lighting.FogStart = 80
        Lighting.FogEnd = 900
        Lighting.ExposureCompensation = 0.05
        Lighting.GlobalShadows = true

        local effect = Instance.new("ColorCorrectionEffect")
        effect.Name = "MM2HubV2_NightColor"
        effect.Brightness = 0.025
        effect.Contrast = 0.22
        effect.Saturation = -0.08
        effect.TintColor = Color3.fromRGB(207, 190, 255)
        effect.Parent = Lighting
        nightEffect = effect
    else
        if nightEffect then
            nightEffect:Destroy()
            nightEffect = nil
        end
        restoreLightingProperties()
    end
end

local function setBloom(enabled)
    enabled = enabled == true
    if bloomEnabled == enabled then
        return
    end

    bloomEnabled = enabled

    if enabled then
        local effect = Instance.new("BloomEffect")
        effect.Name = "MM2HubV2_Bloom"
        effect.Intensity = 0.18
        effect.Size = 18
        effect.Threshold = 1.15
        effect.Parent = Lighting
        bloomEffect = effect
    else
        if bloomEffect then
            bloomEffect:Destroy()
            bloomEffect = nil
        end
    end
end

local function restoreVisuals()
    setNightMode(false)
    setBloom(false)
end

--// Shift Lock local
local function findHumanoid(character)
    if not character then
        return nil
    end
    return character:FindFirstChildOfClass("Humanoid")
end

local function restoreHumanoidShiftLock()
    if activeHumanoid and savedHumanoidSettings then
        if activeHumanoid.Parent then
            pcall(function()
                activeHumanoid.CameraOffset = savedHumanoidSettings.CameraOffset
                activeHumanoid.AutoRotate = savedHumanoidSettings.AutoRotate
            end)
        end
    end
    activeHumanoid = nil
    savedHumanoidSettings = nil
end

local function applyShiftLockToCharacter(character)
    local humanoid = findHumanoid(character)
    if not humanoid then
        humanoid = character:WaitForChild("Humanoid", 5)
    end
    if not humanoid or not shiftLockEnabled or unloaded then
        return
    end

    if activeHumanoid ~= humanoid then
        restoreHumanoidShiftLock()
        activeHumanoid = humanoid
        savedHumanoidSettings = {
            CameraOffset = humanoid.CameraOffset,
            AutoRotate = humanoid.AutoRotate,
        }
    end

    -- Desplazamiento visual de hombro. No modifica la posicion del personaje.
    humanoid.CameraOffset = Vector3.new(1.55, 0.15, 0)
end

local function setShiftLock(enabled)
    enabled = enabled == true
    if shiftLockEnabled == enabled then
        return
    end

    shiftLockEnabled = enabled
    if heartIndicator then
        heartIndicator.Visible = enabled
    end

    if enabled then
        savedMouseBehavior = UserInputService.MouseBehavior
        savedMouseIconEnabled = UserInputService.MouseIconEnabled

        if not UserInputService.TouchEnabled then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseIconEnabled = false
        end

        if LocalPlayer.Character then
            task.defer(applyShiftLockToCharacter, LocalPlayer.Character)
        end
    else
        restoreHumanoidShiftLock()

        if savedMouseBehavior then
            pcall(function()
                UserInputService.MouseBehavior = savedMouseBehavior
            end)
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end

        if savedMouseIconEnabled ~= nil then
            UserInputService.MouseIconEnabled = savedMouseIconEnabled
        end

        savedMouseBehavior = nil
        savedMouseIconEnabled = nil
    end
end

--// Construccion de interfaz
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 50
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local UIScale = Instance.new("UIScale")
UIScale.Parent = ScreenGui

heartIndicator = Instance.new("TextLabel")
heartIndicator.Name = "ShiftLockHeart"
heartIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
heartIndicator.Position = UDim2.fromScale(0.5, 0.5)
heartIndicator.Size = UDim2.fromOffset(34, 34)
heartIndicator.BackgroundTransparency = 1
heartIndicator.Text = "♥"
heartIndicator.TextColor3 = COLORS.Accent
heartIndicator.TextStrokeColor3 = Color3.fromRGB(35, 12, 27)
heartIndicator.TextStrokeTransparency = 0.15
heartIndicator.Font = Enum.Font.GothamBold
heartIndicator.TextSize = 26
heartIndicator.Visible = false
heartIndicator.ZIndex = 100
heartIndicator.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.Size = UDim2.fromOffset(380, 470)
MainFrame.BackgroundColor3 = COLORS.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.Border
mainStroke.Thickness = 1
mainStroke.Transparency = 0.12
mainStroke.Parent = MainFrame

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

local function addStroke(object, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.Border
    stroke.Thickness = 1
    stroke.Transparency = transparency or 0
    stroke.Parent = object
    return stroke
end

local function createLabel(parent, name, text, position, size, textSize, color, font)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Position = position
    label.Size = size
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or COLORS.Text
    label.Font = font or Enum.Font.Gotham
    label.TextSize = textSize or 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextWrapped = true
    label.Parent = parent
    return label
end

local function createButton(parent, name, text, position, size, callback, accent)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = accent and COLORS.AccentSoft or COLORS.Button
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = text
    button.TextColor3 = COLORS.Text
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 12
    button.TextWrapped = true
    button.Parent = parent
    addCorner(button, 8)
    addStroke(button, accent and COLORS.Accent or COLORS.Border, 0.35)

    connectUI(button.MouseEnter, function()
        TweenService:Create(button, TweenInfo.new(0.14), {
            BackgroundColor3 = accent and COLORS.AccentSoft or COLORS.ButtonHover,
        }):Play()
    end)

    connectUI(button.MouseLeave, function()
        TweenService:Create(button, TweenInfo.new(0.14), {
            BackgroundColor3 = accent and COLORS.AccentSoft or COLORS.Button,
        }):Play()
    end)

    connectUI(button.Activated, function()
        if callback and not unloaded then
            callback()
        end
    end)

    return button
end

--// Barra superior
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = COLORS.Panel
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = TopBar

local DragArea = Instance.new("Frame")
DragArea.Name = "DragArea"
DragArea.Position = UDim2.fromOffset(0, 0)
DragArea.Size = UDim2.new(1, -92, 1, 0)
DragArea.BackgroundTransparency = 1
DragArea.Parent = TopBar

local AccentBar = Instance.new("Frame")
AccentBar.Position = UDim2.fromOffset(13, 13)
AccentBar.Size = UDim2.fromOffset(3, 22)
AccentBar.BackgroundColor3 = COLORS.Accent
AccentBar.BorderSizePixel = 0
AccentBar.Parent = DragArea
addCorner(AccentBar, 3)

local Title = createLabel(
    DragArea,
    "Title",
    "MM2 HUB",
    UDim2.fromOffset(24, 5),
    UDim2.fromOffset(145, 21),
    15,
    COLORS.Text,
    Enum.Font.GothamBold
)

local Subtitle = createLabel(
    DragArea,
    "Subtitle",
    "VERSION 2.0  •  CLIENT UI",
    UDim2.fromOffset(25, 25),
    UDim2.fromOffset(180, 13),
    8,
    COLORS.Muted,
    Enum.Font.GothamMedium
)

local MinimizeButton = createButton(
    TopBar,
    "MinimizeButton",
    "—",
    UDim2.new(1, -77, 0, 9),
    UDim2.fromOffset(29, 29),
    function()
        minimized = not minimized
        local targetHeight = minimized and 48 or 470
        TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(380, targetHeight),
        }):Play()
        for _, object in ipairs(MainFrame:GetChildren()) do
            if object ~= TopBar and object ~= mainCorner and object ~= mainStroke then
                if object:IsA("GuiObject") then
                    object.Visible = not minimized
                end
            end
        end
        MinimizeButton.Text = minimized and "+" or "—"
    end
)
MinimizeButton.TextSize = 15

local CloseButton = createButton(
    TopBar,
    "CloseButton",
    "×",
    UDim2.new(1, -40, 0, 9),
    UDim2.fromOffset(29, 29),
    function()
        -- La funcion se asigna despues de definir cleanup.
    end
)
CloseButton.TextColor3 = COLORS.Accent
CloseButton.TextSize = 19

--// Navegacion
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Position = UDim2.fromOffset(12, 57)
TabBar.Size = UDim2.new(1, -24, 0, 34)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = TabBar

local ContentHost = Instance.new("Frame")
ContentHost.Name = "ContentHost"
ContentHost.Position = UDim2.fromOffset(12, 101)
ContentHost.Size = UDim2.new(1, -24, 1, -131)
ContentHost.BackgroundTransparency = 1
ContentHost.Parent = MainFrame

local Footer = createLabel(
    MainFrame,
    "Footer",
    "●  SISTEMA LISTO  •  CONFIGURACION LOCAL",
    UDim2.new(0, 14, 1, -23),
    UDim2.new(1, -28, 0, 14),
    8,
    COLORS.Muted,
    Enum.Font.GothamMedium
)

local activeTab = "Inicio"
local tabButtons = {}
local refreshVisualButtons = function() end
local refreshControlButtons = function() end

local function makePage()
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Page"
    scroll.Size = UDim2.fromScale(1, 1)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = COLORS.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.Parent = ContentHost

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 3)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 2)
    padding.PaddingRight = UDim.new(0, 5)
    padding.Parent = scroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    return scroll
end

local function makeCard(parent, titleText, descriptionText, height)
    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(1, -2, 0, height or 86)
    card.BackgroundColor3 = COLORS.Panel
    card.BorderSizePixel = 0
    card.Parent = parent
    addCorner(card, 10)
    addStroke(card, COLORS.Border, 0.35)

    createLabel(
        card,
        "CardTitle",
        titleText,
        UDim2.fromOffset(13, 9),
        UDim2.new(1, -26, 0, 20),
        13,
        COLORS.Text,
        Enum.Font.GothamBold
    )

    createLabel(
        card,
        "CardDescription",
        descriptionText,
        UDim2.fromOffset(13, 31),
        UDim2.new(1, -26, 1, -38),
        10,
        COLORS.Muted,
        Enum.Font.Gotham
    )

    return card
end

local function makeActionCard(parent, titleText, descriptionText, buttonText, callback, buttonAccent)
    local card = makeCard(parent, titleText, descriptionText, 106)
    local description = card:FindFirstChild("CardDescription")
    if description then
        description.Size = UDim2.new(1, -145, 1, -38)
    end

    local action = createButton(
        card,
        "ActionButton",
        buttonText,
        UDim2.new(1, -126, 1, -39),
        UDim2.fromOffset(112, 27),
        callback,
        buttonAccent
    )
    action.TextSize = 10
    return card, action
end

local function clearContent()
    disconnectPageConnections()
    for _, child in ipairs(ContentHost:GetChildren()) do
        child:Destroy()
    end
end

local function renderHome()
    local page = makePage()
    makeCard(
        page,
        "Bemvenido a MM2 HUB V2",
        "Una interfaz ligera para controles locales y personalizacion visual. Usa las pestanas para explorar las opciones.",
        92
    )
    makeCard(
        page,
        "Interfaz renovada",
        "Diseno oscuro con detalles rosas, controles tactiles, ventanas redimensionadas automaticamente y botones con estados visibles.",
        92
    )
    makeCard(
        page,
        "Importante",
        "Este proyecto esta preparado como LocalScript para tu propia experiencia en Roblox Studio. No revela informacion privada ni roles ocultos de otros jugadores.",
        104
    )
end

local function renderVisuals()
    local page = makePage()
    makeCard(
        page,
        "APARIENCIA",
        "Los cambios se aplican localmente. Puedes desactivarlos para recuperar los valores de iluminacion guardados al iniciar.",
        78
    )

    local nightCard, nightButton = makeActionCard(
        page,
        "Tema nocturno",
        "Tonos oscuros con una correccion de color suave. No elimina Sky ni efectos de otros sistemas.",
        "ACTIVAR",
        function()
            setNightMode(not nightEnabled)
            refreshVisualButtons()
        end,
        true
    )

    local bloomCard, bloomButton = makeActionCard(
        page,
        "Bloom suave",
        "Anade un brillo ligero a las zonas luminosas. Se administra como un efecto propio del hub.",
        "ACTIVAR",
        function()
            setBloom(not bloomEnabled)
            refreshVisualButtons()
        end
    )

    createButton(
        page,
        "RestoreVisualsButton",
        "RESTAURAR ILUMINACION",
        UDim2.new(0, 0, 0, 0),
        UDim2.new(1, -2, 0, 34),
        function()
            restoreVisuals()
            refreshVisualButtons()
        end
    )

    refreshVisualButtons = function()
        if nightButton and nightButton.Parent then
            nightButton.Text = nightEnabled and "ACTIVADO" or "ACTIVAR"
            nightButton.BackgroundColor3 = nightEnabled and COLORS.AccentSoft or COLORS.Button
        end
        if bloomButton and bloomButton.Parent then
            bloomButton.Text = bloomEnabled and "ACTIVADO" or "ACTIVAR"
            bloomButton.BackgroundColor3 = bloomEnabled and COLORS.AccentSoft or COLORS.Button
        end
    end
    refreshVisualButtons()
end

local function renderControls()
    local page = makePage()
    makeCard(
        page,
        "CONTROLES",
        "Ajustes de camara locales. El bloqueo del raton solo se activa en dispositivos que usan raton; en pantallas tactiles se conserva el control tactil.",
        90
    )

    local shiftCard, shiftButton = makeActionCard(
        page,
        "Shift Lock con camara lateral",
        "Activa el desplazamiento de hombro y, en PC, centra el cursor. Tambien puedes usar LeftShift.",
        "DESACTIVADO",
        function()
            setShiftLock(not shiftLockEnabled)
            refreshControlButtons()
        end,
        true
    )

    makeCard(
        page,
        "Atajo de teclado",
        "Pulsa LeftShift para alternar el Shift Lock. En movil, usa el boton de esta seccion.",
        74
    )

    refreshControlButtons = function()
        if shiftButton and shiftButton.Parent then
            shiftButton.Text = shiftLockEnabled and "ACTIVADO" or "DESACTIVADO"
            shiftButton.BackgroundColor3 = shiftLockEnabled and COLORS.AccentSoft or COLORS.Button
        end
    end
    refreshControlButtons()
end

local function renderSettings()
    local page = makePage()
    makeCard(
        page,
        "AJUSTES DEL HUB",
        "Restaura los cambios hechos por este hub. Los efectos visuales que ya existian en Lighting no se destruyen.",
        82
    )

    createButton(
        page,
        "RestoreAllButton",
        "RESTAURAR TODOS LOS AJUSTES",
        UDim2.new(0, 0, 0, 0),
        UDim2.new(1, -2, 0, 36),
        function()
            setShiftLock(false)
            restoreVisuals()
            refreshVisualButtons()
            refreshControlButtons()
            Footer.Text = "●  AJUSTES RESTAURADOS"
        end,
        true
    )

    makeCard(
        page,
        "Compatibilidad",
        "Coloca este archivo como LocalScript en StarterPlayerScripts de tu propia experiencia. No esta pensado para ejecutores externos.",
        88
    )

    createButton(
        page,
        "UnloadButton",
        "CERRAR Y LIMPIAR HUB",
        UDim2.new(0, 0, 0, 0),
        UDim2.new(1, -2, 0, 36),
        function()
            if ScreenGui and ScreenGui.Parent then
                ScreenGui:Destroy()
            end
        end
    )
end

local function showTab(tabName)
    activeTab = tabName
    clearContent()

    for name, button in pairs(tabButtons) do
        local selected = name == tabName
        button.BackgroundColor3 = selected and COLORS.AccentSoft or COLORS.Button
        button.TextColor3 = selected and COLORS.Text or COLORS.Muted
    end

    buildingPage = true
    if tabName == "Inicio" then
        renderHome()
    elseif tabName == "Visual" then
        renderVisuals()
    elseif tabName == "Controles" then
        renderControls()
    elseif tabName == "Ajustes" then
        renderSettings()
    end
    buildingPage = false
end

local tabs = { "Inicio", "Visual", "Controles", "Ajustes" }
for index, tabName in ipairs(tabs) do
    local tabButton = createButton(
        TabBar,
        tabName .. "Tab",
        string.upper(tabName),
        UDim2.new(),
        UDim2.new(0.25, -5, 1, 0),
        function()
            showTab(tabName)
        end
    )
    tabButton.LayoutOrder = index
    tabButton.TextSize = 9
    tabButtons[tabName] = tabButton
end

--// Escala adaptable
local function updateScale()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
    local scaleX = viewport.X / 430
    local scaleY = viewport.Y / 540
    UIScale.Scale = math.clamp(math.min(scaleX, scaleY), 0.68, 1)
end

updateScale()

local currentCameraConnection
local function bindCamera(camera)
    if currentCameraConnection and currentCameraConnection.Connected then
        currentCameraConnection:Disconnect()
    end
    if camera then
        currentCameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        table.insert(connections, currentCameraConnection)
    end
    updateScale()
end

connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
    bindCamera(workspace.CurrentCamera)
end)
bindCamera(workspace.CurrentCamera)

--// Arrastre de la ventana (raton y tactil)
local dragging = false
local dragStart = nil
local startPosition = nil

connect(DragArea.InputBegan, function(input)
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = MainFrame.Position
    end
end)

connect(UserInputService.InputChanged, function(input)
    if not dragging or not dragStart or not startPosition then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
        local halfWidth = MainFrame.AbsoluteSize.X / 2
        local halfHeight = MainFrame.AbsoluteSize.Y / 2
        local desiredX = viewport.X / 2 + startPosition.X.Offset + delta.X
        local desiredY = viewport.Y / 2 + startPosition.Y.Offset + delta.Y
        local clampedX = math.clamp(desiredX, halfWidth, math.max(halfWidth, viewport.X - halfWidth))
        local clampedY = math.clamp(desiredY, halfHeight, math.max(halfHeight, viewport.Y - halfHeight))
        MainFrame.Position = UDim2.fromOffset(clampedX, clampedY)
        MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    end
end)

connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        dragStart = nil
        startPosition = nil
    end
end)

--// Atajo Shift Lock
connect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed or unloaded then
        return
    end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        setShiftLock(not shiftLockEnabled)
        refreshControlButtons()
    end
end)

--// Respawn: vuelve a aplicar el desplazamiento de camara si estaba activo.
connect(LocalPlayer.CharacterAdded, function(character)
    task.defer(function()
        if not unloaded and shiftLockEnabled then
            applyShiftLockToCharacter(character)
        end
    end)
end)

connect(LocalPlayer.CharacterRemoving, function(character)
    if activeHumanoid and activeHumanoid.Parent == character then
        restoreHumanoidShiftLock()
    end
end)

--// Limpieza centralizada
local function cleanup(destroyGui)
    if unloaded then
        return
    end
    unloaded = true

    setShiftLock(false)
    restoreVisuals()
    disconnectAll()

    if destroyGui and ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end

connect(CloseButton.Activated, function()
    cleanup(true)
end)
connect(ScreenGui.Destroying, function()
    cleanup(false)
end)
if script then
    connect(script.Destroying, function()
        cleanup(true)
    end)
end

--// Primera vista
showTab("Inicio")
Footer.Text = "●  SISTEMA LISTO  •  " .. LocalPlayer.DisplayName:upper()

print("[MM2 HUB V2] Cargado correctamente como LocalScript.")
