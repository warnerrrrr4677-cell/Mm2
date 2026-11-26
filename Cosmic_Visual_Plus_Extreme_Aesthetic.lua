-- ============================================================
-- ✦✦✦✦✦ COSMIC VISUAL PLUS — MOBILE ULTIMATE ✦✦✦✦✦
-- 6 pestañas · glassmorphism amatista · shaders suaves · MM2 visible · controles móviles
-- Incluye: Visual · MM2 · Cósmico · Extras · Anim · Ajustes
-- ============================================================
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local Workspace = game:GetService("Workspace")

-- Paleta oscura tipo vidrio: grafito, amatista y reflejos suaves.
local THEME = {
    background = Color3.fromRGB(13, 9, 28),
    panel = Color3.fromRGB(29, 19, 49),
    panelHover = Color3.fromRGB(49, 27, 76),
    accent = Color3.fromRGB(194, 139, 255),
    accentSoft = Color3.fromRGB(128, 72, 193),
    text = Color3.fromRGB(250, 246, 255),
    mutedText = Color3.fromRGB(205, 184, 235),
    enabled = Color3.fromRGB(119, 220, 190),
    disabled = Color3.fromRGB(77, 61, 105),
    border = Color3.fromRGB(130, 82, 186),
}

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local notificationsEnabled = true
local uiSoundsEnabled = true
local notificationDuration = 2.5

-- Limpieza total
if PG:FindFirstChild("CosmicVisualPlus") then PG.CosmicVisualPlus:Destroy() end
for _, n in ipairs({"CosmicAddon_Sky","CosmicAddon_BH","CosmicCursor"}) do
    local o = Workspace:FindFirstChild(n) or PG:FindFirstChild(n)
    if o then o:Destroy() end
end
for _, soundName in ipairs({"CVP_Click","CVP_Hover","CVP_On","CVP_Off","CVP_Music"}) do
    local oldSound = SoundService:FindFirstChild(soundName)
    if oldSound then oldSound:Destroy() end
end
local legacyAudioIds = {
    ["rbxassetid://9114056088"] = true,
    ["rbxassetid://9114054653"] = true,
    ["rbxassetid://9125402730"] = true,
    ["rbxassetid://9125404106"] = true,
    ["rbxassetid://1837879088"] = true,
}
for _, child in ipairs(SoundService:GetChildren()) do
    if child:IsA("Sound") and legacyAudioIds[child.SoundId] then
        child:Stop()
        child:Destroy()
    end
end

-- ============================================================
-- SONIDOS
-- ============================================================
local function mkSnd(id, v, loop, soundName)
    local s = Instance.new("Sound")
    s.Name = soundName or "CVP_Sound"
    s.SoundId = (id and tostring(id) ~= "" and ("rbxassetid://" .. tostring(id))) or ""
    s.Volume = v or 0.35
    s.Looped = loop or false
    s.Parent = SoundService
    return s
end
local clickSfx     = mkSnd("9114056088", 0.3, false, "CVP_Click")
local hoverSfx     = mkSnd("9114054653", 0.15, false, "CVP_Hover")
local onSfx        = mkSnd("9125402730", 0.3, false, "CVP_On")
local offSfx       = mkSnd("9125404106", 0.3, false, "CVP_Off")
-- No se incluye una canción comercial por defecto. El usuario configura un audio
-- que tenga permiso de uso en la experiencia.
local ambientMusic = mkSnd(nil, 0.12, true, "CVP_Music")

local function playUi(sound)
    if uiSoundsEnabled and sound then
        pcall(function() sound:Play() end)
    end
end

-- ============================================================
-- UI PRINCIPAL
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "CosmicVisualPlus"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PG

-- NOTIFICACIONES
local notifFrame = Instance.new("Frame")
notifFrame.Name = "NotifFrame"
notifFrame.Size = UDim2.new(0, 286, 1, 0)
notifFrame.Position = UDim2.new(1, -296, 0, 0)
notifFrame.BackgroundTransparency = 1
notifFrame.Parent = gui

local notifStack = {}
local function notify(text, color)
    if not notificationsEnabled then return end
    color = color or THEME.accent
    local n = Instance.new("Frame")
    n.Size = UDim2.new(1, 0, 0, 42)
    n.Position = UDim2.new(1, 340, 0, 20 + #notifStack * 50)
    n.BackgroundColor3 = THEME.panel
    n.BorderSizePixel = 0
    n.Parent = notifFrame
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke")
    st.Color = color; st.Thickness = 1; st.Transparency = 0.18; st.Parent = n
    local acc = Instance.new("Frame")
    acc.Size = UDim2.new(0, 4, 1, 0)
    acc.BackgroundColor3 = color
    acc.BorderSizePixel = 0
    acc.Parent = n
    Instance.new("UICorner", acc).CornerRadius = UDim.new(0, 4)
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -20, 1, 0)
    txt.Position = UDim2.new(0, 14, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = text
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12
    txt.TextColor3 = THEME.text
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = n
    table.insert(notifStack, n)
    TweenService:Create(n, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0, 0, 0, 20 + (#notifStack - 1) * 50)
    }):Play()
    task.delay(notificationDuration, function()
        TweenService:Create(n, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 340, 0, n.Position.Y.Offset)
        }):Play()
        task.wait(0.35)
        for i, v in ipairs(notifStack) do if v == n then table.remove(notifStack, i) break end end
        n:Destroy()
        for i, v in ipairs(notifStack) do
            if v and v.Parent then
                TweenService:Create(v, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 20 + (i-1) * 50)}):Play()
            end
        end
    end)
end

-- FRAME PRINCIPAL RESPONSIVO
local viewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(390, 720)
local panelWidth = math.clamp(viewport.X - 24, 280, 420)
local panelHeight = math.clamp(viewport.Y - 36, 440, 620)
local main = Instance.new("Frame")
main.Name = "MainFrame"
main:SetAttribute("ThemeMain", true)
main.Size = UDim2.new(0, 0, 0, 0)
main.Position = UDim2.new(0.5, -panelWidth/2, 0.5, -panelHeight/2)
main.BackgroundColor3 = THEME.background
main.BackgroundTransparency = 0.045
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
main.Parent = gui

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(54, 27, 83)),
    ColorSequenceKeypoint.new(0.48, Color3.fromRGB(13, 9, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 26, 59)),
})
bgGrad.Rotation = 125
bgGrad.Parent = main

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = THEME.border
mainStroke.Thickness = 1.35
mainStroke.Transparency = 0.22
mainStroke.Parent = main
mainStroke:SetAttribute("ThemeStroke", true)
local mainScale = Instance.new("UIScale")
mainScale.Scale = 1
mainScale.Parent = main

-- Reflejos decorativos de vidrio: discretos, sin llenar la pantalla de RGB.
local function makeGlassOrb(name, size, position, color, transparency)
    local orb = Instance.new("Frame")
    orb.Name = name
    orb.Size = UDim2.new(0, size, 0, size)
    orb.Position = position
    orb.BackgroundColor3 = color
    orb.BackgroundTransparency = transparency
    orb.BorderSizePixel = 0
    orb:SetAttribute("ThemeOrb", true)
    orb.ZIndex = 1
    orb.Parent = main
    Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)
    local outline = Instance.new("UIStroke")
    outline.Color = color
    outline.Transparency = 0.72
    outline.Thickness = 1
    outline.Parent = orb
    outline:SetAttribute("ThemeStroke", true)
    return orb
end

local glassOrbA = makeGlassOrb("GlassOrbA", 190, UDim2.new(1, -118, 0, -82), THEME.accentSoft, 0.91)
local glassOrbB = makeGlassOrb("GlassOrbB", 136, UDim2.new(0, -82, 1, -104), Color3.fromRGB(92, 91, 220), 0.94)

local topHighlight = Instance.new("Frame")
topHighlight.Name = "TopGlassHighlight"
topHighlight.Size = UDim2.new(1, -28, 0, 2)
topHighlight.Position = UDim2.new(0, 14, 0, 59)
topHighlight.BackgroundColor3 = THEME.accent
topHighlight.BorderSizePixel = 0
topHighlight.ZIndex = 5
topHighlight.Parent = main
local topHighlightGradient = Instance.new("UIGradient")
topHighlightGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, THEME.accentSoft),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(245, 222, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 153, 255)),
})
topHighlightGradient.Parent = topHighlight
Instance.new("UICorner", topHighlight).CornerRadius = UDim.new(1, 0)

TweenService:Create(main, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, panelWidth, 0, panelHeight)
}):Play()

-- TÍTULO
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -108, 0, 36)
titleLbl.Position = UDim2.new(0, 16, 0, 8)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "✦ COSMIC VISUAL PLUS ✦"
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 19
titleLbl.TextColor3 = Color3.new(1,1,1)
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = main

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(190, 145, 255)),
    ColorSequenceKeypoint.new(0.48, Color3.fromRGB(255, 246, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 174, 255)),
})
titleGrad.Parent = titleLbl

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, -108, 0, 14)
subTitle.Position = UDim2.new(0, 16, 0, 42)
subTitle.BackgroundTransparency = 1
subTitle.Text = "ULTIMATE · MM2 · visual · móvil"
subTitle.Font = Enum.Font.GothamMedium
subTitle.TextSize = 10
subTitle.TextColor3 = THEME.mutedText
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Parent = main

-- BOTÓN MINIMIZAR
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -40, 0, 12)
minBtn.BackgroundColor3 = THEME.panel
minBtn.Text = "—"
minBtn.TextColor3 = THEME.text
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.AutoButtonColor = false
minBtn:SetAttribute("ThemePanel", true)
minBtn.Parent = main
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 26, 0, 30)
closeBtn.Position = UDim2.new(1, -73, 0, 12)
closeBtn.BackgroundColor3 = Color3.fromRGB(74, 40, 68)
closeBtn.Text = "×"
closeBtn.TextColor3 = THEME.text
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.AutoButtonColor = false
closeBtn.Parent = main
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local minIcon = Instance.new("TextButton")
minIcon.Size = UDim2.new(0, 55, 0, 55)
minIcon.Position = UDim2.new(0, 15, 0, 15)
minIcon.BackgroundColor3 = THEME.background
minIcon.Text = "✦"
minIcon.TextColor3 = THEME.text
minIcon:SetAttribute("ThemeMain", true)
minIcon.TextSize = 26
minIcon.Visible = false
minIcon.AutoButtonColor = false
minIcon.Parent = gui
Instance.new("UICorner", minIcon).CornerRadius = UDim.new(0, 12)
local minStroke = Instance.new("UIStroke")
minStroke.Color = THEME.accentSoft
minStroke.Thickness = 2
minStroke.Parent = minIcon
minStroke:SetAttribute("ThemeStroke", true)

local isMin = false
minBtn.MouseButton1Click:Connect(function()
    if isMin then return end
    playUi(clickSfx)
    isMin = true
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 55, 0, 55),
        Position = UDim2.new(0, 15, 0, 15),
        BackgroundTransparency = 0.9,
        Rotation = 180,
    }):Play()
    task.wait(0.35)
    main.Visible = false
    main.Rotation = 0
    minIcon.Visible = true
    minIcon.Size = UDim2.new(0,0,0,0)
    TweenService:Create(minIcon, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Size = UDim2.new(0,55,0,55)}):Play()
end)
minIcon.MouseButton1Click:Connect(function()
    if not isMin then return end
    playUi(clickSfx)
    isMin = false
    minIcon.Visible = false
    main.Visible = true
    main.Size = UDim2.new(0,0,0,0)
    main.Position = UDim2.new(0.5, -panelWidth/2, 0.5, -panelHeight/2)
    main.BackgroundTransparency = 0
    TweenService:Create(main, TweenInfo.new(0.45, Enum.EasingStyle.Back), {Size = UDim2.new(0,panelWidth,0,panelHeight)}):Play()
end)

-- ============================================================
-- SISTEMA DE PESTAÑAS (6)
-- ============================================================
local tabsBar = Instance.new("Frame")
tabsBar.Name = "TabsBar"
tabsBar.Size = UDim2.new(1, -32, 0, 32)
tabsBar.Position = UDim2.new(0, 16, 0, 64)
tabsBar.BackgroundColor3 = THEME.panel
tabsBar.BackgroundTransparency = 0.06
tabsBar.BorderSizePixel = 0
tabsBar.Parent = main
tabsBar:SetAttribute("ThemePanel", true)
Instance.new("UICorner", tabsBar).CornerRadius = UDim.new(0, 8)

local tabs = {
    {name = "🎨 Visual",  label = "VIS",  color = THEME.accent},
    {name = "🎯 MM2",     label = "MM2",  color = THEME.accent},
    {name = "🌌 Cosmo",   label = "COS",  color = THEME.accent},
    {name = "🎮 Extras",  label = "EX",   color = THEME.accent},
    {name = "🎭 Anim",    label = "ANIM", color = THEME.accent},
    {name = "⚙ Ajustes", label = "CFG",  color = THEME.accent},
}
local selectedTabName = tabs[1].name

local tabContents = {}
local tabButtons = {}

local function createTab(tab, idx)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#tabs, -3, 1, -4)
    btn.Position = UDim2.new((idx-1)/#tabs, 2, 0, 2)
    btn.BackgroundColor3 = idx == 1 and tab.color or THEME.panel
    btn.Text = tab.label or tab.name
    btn.TextColor3 = THEME.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.AutoButtonColor = false
    btn:SetAttribute("ThemeTab", true)
    btn.Parent = tabsBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local tabStroke = Instance.new("UIStroke")
    tabStroke.Name = "TabStroke"
    tabStroke.Color = THEME.border
    tabStroke.Thickness = 1
    tabStroke.Transparency = idx == 1 and 0.18 or 0.72
    tabStroke:SetAttribute("ThemeStroke", true)
    tabStroke.Parent = btn
    tabButtons[tab.name] = {btn = btn, color = tab.color, stroke = tabStroke}

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -32, 1, -150)
    content.Position = UDim2.new(0, 16, 0, 106)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = tab.color
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Visible = idx == 1
    content.Parent = main
    tabContents[tab.name] = content

    btn.MouseButton1Click:Connect(function()
        playUi(clickSfx)
        selectedTabName = tab.name
        for n, c in pairs(tabContents) do c.Visible = (n == tab.name) end
        for n, d in pairs(tabButtons) do
            local active = (n == tab.name)
            TweenService:Create(d.btn, TweenInfo.new(0.22), {
                BackgroundColor3 = active and THEME.accentSoft or THEME.panel
            }):Play()
            if d.stroke then
                TweenService:Create(d.stroke, TweenInfo.new(0.22), {
                    Transparency = active and 0.12 or 0.72,
                    Thickness = active and 1.4 or 1,
                }):Play()
            end
        end
    end)
    btn.MouseEnter:Connect(function()
        playUi(hoverSfx)
    end)

    return content
end

for i, t in ipairs(tabs) do createTab(t, i) end

-- ============================================================
-- HELPER TOGGLE
-- ============================================================
local toggleRegistry = {}
local toggleCallbackRegistry = {}
local globalUIConnections = {}
local function addToggle(tabName, text, emoji, cb, accentColor)
    local content = tabContents[tabName]
    local yPos = content.CanvasSize.Y.Offset
    accentColor = accentColor or THEME.accent

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 42)
    b.Position = UDim2.new(0, 0, 0, yPos)
    b.BackgroundColor3 = THEME.panel
    b.BackgroundTransparency = 0.035
    b.Text = ""
    b.AutoButtonColor = false
    b:SetAttribute("ThemePanel", true)
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local cardGradient = Instance.new("UIGradient")
    cardGradient.Name = "CVP_CardGlassGradient"
    cardGradient.Color = ColorSequence.new(THEME.panelHover, THEME.panel)
    cardGradient.Rotation = 90
    cardGradient:SetAttribute("ThemePanelGradient", true)
    cardGradient.Parent = b

    local bst = Instance.new("UIStroke")
    bst.Color = accentColor
    bst.Thickness = 1.5
    bst.Transparency = 0.5
    bst.Parent = b
    bst:SetAttribute("ThemeStroke", true)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = emoji .. " " .. text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = THEME.text
    lbl:SetAttribute("ThemeText", true)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = b

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 10, 0, 10)
    ind.Position = UDim2.new(1, -20, 0.5, -5)
    ind.BackgroundColor3 = THEME.disabled
    ind.BorderSizePixel = 0
    ind.Parent = b
    ind:SetAttribute("ThemeDot", true)
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1,0)

    local state = false
    local function setState(newState, invokeCallback)
        if state == newState then return end
        state = newState
        ind.BackgroundColor3 = state and THEME.enabled or THEME.disabled
        if invokeCallback then
            if state then playUi(onSfx) else playUi(offSfx) end
            local ok, err = pcall(cb, state)
            if not ok then
                warn("[CosmicVisualPlus] Error en opción '" .. text .. "': " .. tostring(err))
                notify("Error al cambiar: " .. text, Color3.fromRGB(220, 135, 145))
            end
        end
    end
    toggleRegistry[text] = function(newState) setState(newState, false) end
    toggleCallbackRegistry[text] = function(newState) setState(newState, true) end

    b.MouseEnter:Connect(function()
        playUi(hoverSfx)
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = THEME.panelHover}):Play()
        TweenService:Create(bst, TweenInfo.new(0.2), {Transparency = 0, Thickness = 2.5}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = THEME.panel}):Play()
        TweenService:Create(bst, TweenInfo.new(0.2), {Transparency = 0.5, Thickness = 1.5}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        setState(not state, true)
        TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(0.97,0,0,40)}):Play()
        task.wait(0.1)
        TweenService:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(1,0,0,42)}):Play()
    end)
    content.CanvasSize = UDim2.new(0, 0, 0, yPos + 48)
end

-- Helper botón de acción (no toggle)
local function addAction(tabName, text, emoji, cb, accentColor)
    local content = tabContents[tabName]
    local yPos = content.CanvasSize.Y.Offset
    accentColor = accentColor or THEME.accent

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 42)
    b.Position = UDim2.new(0, 0, 0, yPos)
    b.BackgroundColor3 = THEME.panel
    b.BackgroundTransparency = 0.035
    b.Text = ""
    b.AutoButtonColor = false
    b:SetAttribute("ThemePanel", true)
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local cardGradient = Instance.new("UIGradient")
    cardGradient.Name = "CVP_CardGlassGradient"
    cardGradient.Color = ColorSequence.new(THEME.panelHover, THEME.panel)
    cardGradient.Rotation = 90
    cardGradient:SetAttribute("ThemePanelGradient", true)
    cardGradient.Parent = b

    local bst = Instance.new("UIStroke")
    bst.Color = accentColor
    bst.Thickness = 1.5
    bst.Transparency = 0.5
    bst.Parent = b
    bst:SetAttribute("ThemeStroke", true)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = emoji .. " " .. text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = THEME.text
    lbl:SetAttribute("ThemeText", true)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = b

    b.MouseEnter:Connect(function()
        playUi(hoverSfx)
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = THEME.panelHover}):Play()
        TweenService:Create(bst, TweenInfo.new(0.2), {Transparency = 0, Thickness = 2.5}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = THEME.panel}):Play()
        TweenService:Create(bst, TweenInfo.new(0.2), {Transparency = 0.5, Thickness = 1.5}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        playUi(onSfx)
        TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(0.97,0,0,40)}):Play()
        task.wait(0.1)
        TweenService:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(1,0,0,42)}):Play()
        local ok, err = pcall(cb)
        if not ok then
            warn("[CosmicVisualPlus] Error en acción '" .. text .. "': " .. tostring(err))
            notify("Error al ejecutar: " .. text, Color3.fromRGB(220, 135, 145))
        end
    end)
    content.CanvasSize = UDim2.new(0, 0, 0, yPos + 48)
end

-- Helper título de sección
local function addSection(tabName, text, color)
    local content = tabContents[tabName]
    local yPos = content.CanvasSize.Y.Offset
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 3)
    sep.Position = UDim2.new(0, 0, 0, yPos + 4)
    sep.BackgroundColor3 = THEME.accent
    sep.BorderSizePixel = 0
    sep:SetAttribute("ThemeAccent", true)
    sep.Parent = content
    local sectionGradient = Instance.new("UIGradient")
    sectionGradient.Color = ColorSequence.new(THEME.accentSoft, THEME.accent)
    sectionGradient:SetAttribute("ThemeAccentGradient", true)
    sectionGradient.Parent = sep
    Instance.new("UICorner", sep).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.Position = UDim2.new(0, 0, 0, yPos + 12)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 12
    lbl.TextColor3 = THEME.accent
    lbl:SetAttribute("ThemeSection", true)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = content
    content.CanvasSize = UDim2.new(0, 0, 0, yPos + 42)
end

-- Control deslizante táctil para móviles y mouse.
local function addSlider(tabName, labelText, minValue, maxValue, defaultValue, step, formatter, callback)
    local content = tabContents[tabName]
    local yPos = content.CanvasSize.Y.Offset
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 68)
    row.Position = UDim2.new(0, 0, 0, yPos)
    row.BackgroundColor3 = THEME.panel
    row.BackgroundTransparency = 0.035
    row.BorderSizePixel = 0
    row:SetAttribute("ThemePanel", true)
    row.Parent = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 0, 24)
    title.Position = UDim2.new(0, 12, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 10
    title.TextColor3 = THEME.text
    title:SetAttribute("ThemeText", true)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 76, 0, 20)
    valueLabel.Position = UDim2.new(1, -88, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextSize = 9
    valueLabel.TextColor3 = THEME.mutedText
    valueLabel:SetAttribute("ThemeMutedText", true)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -30, 0, 6)
    track.Position = UDim2.new(0, 15, 0, 43)
    track.BackgroundColor3 = THEME.disabled
    track.BorderSizePixel = 0
    track.Active = true
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = THEME.accent
    fill:SetAttribute("ThemeAccent", true)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = THEME.text
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local current = defaultValue
    local dragging = false
    local function renderValue(value, invoke)
        value = math.clamp(value, minValue, maxValue)
        if step and step > 0 then
            value = minValue + math.floor(((value - minValue) / step) + 0.5) * step
        end
        current = math.clamp(value, minValue, maxValue)
        local pct = (current - minValue) / math.max(0.000001, maxValue - minValue)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        valueLabel.Text = formatter and formatter(current) or tostring(current)
        title.Text = labelText
        if invoke and callback then
            local ok, err = pcall(callback, current)
            if not ok then warn("[CosmicVisualPlus] Slider " .. labelText .. ": " .. tostring(err)) end
        end
    end
    local function updateFromX(x)
        local width = math.max(1, track.AbsoluteSize.X)
        local pct = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        renderValue(minValue + (maxValue - minValue) * pct, true)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    table.insert(globalUIConnections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end))
    table.insert(globalUIConnections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    renderValue(defaultValue, false)
    content.CanvasSize = UDim2.new(0, 0, 0, yPos + 74)
end

-- Campo de texto compacto, compatible con pantalla táctil.
local function addTextInput(tabName, labelText, placeholder, defaultValue, callback)
    local content = tabContents[tabName]
    local yPos = content.CanvasSize.Y.Offset
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 68)
    row.Position = UDim2.new(0, 0, 0, yPos)
    row.BackgroundColor3 = THEME.panel
    row.BackgroundTransparency = 0.035
    row.BorderSizePixel = 0
    row:SetAttribute("ThemePanel", true)
    row.Parent = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 21)
    title.Position = UDim2.new(0, 10, 0, 3)
    title.BackgroundTransparency = 1
    title.Text = labelText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 10
    title.TextColor3 = THEME.text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title:SetAttribute("ThemeText", true)
    title.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -82, 0, 29)
    box.Position = UDim2.new(0, 9, 0, 31)
    box.BackgroundColor3 = THEME.background
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.PlaceholderText = placeholder
    box.Text = defaultValue or ""
    box.TextColor3 = THEME.text
    box.PlaceholderColor3 = THEME.mutedText
    box.Font = Enum.Font.Gotham
    box.TextSize = 10
    box.TextXAlignment = Enum.TextXAlignment.Left
    box:SetAttribute("ThemeText", true)
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    local apply = Instance.new("TextButton")
    apply.Size = UDim2.new(0, 64, 0, 29)
    apply.Position = UDim2.new(1, -73, 0, 31)
    apply.BackgroundColor3 = THEME.accentSoft
    apply.Text = "Aplicar"
    apply.TextColor3 = THEME.text
    apply.Font = Enum.Font.GothamBold
    apply.TextSize = 9
    apply.AutoButtonColor = false
    apply:SetAttribute("ThemePanel", true)
    apply.Parent = row
    Instance.new("UICorner", apply).CornerRadius = UDim.new(0, 6)
    apply.MouseButton1Click:Connect(function()
        playUi(clickSfx)
        if callback then
            local ok, err = pcall(callback, box.Text)
            if not ok then
                warn("[CosmicVisualPlus] Text input " .. labelText .. ": " .. tostring(err))
                notify("No se pudo aplicar el valor", Color3.fromRGB(220, 130, 135))
            end
        end
    end)
    content.CanvasSize = UDim2.new(0, 0, 0, yPos + 75)
    return box
end

-- ============================================================
-- ✦ PESTAÑA VISUAL ✦
-- ============================================================

-- FUENTES PARA TEXTO DE INTERFAZ (ScreenGui dentro de PlayerGui).
-- No toca nombres 3D, BillboardGui, SurfaceGui ni el CoreGui de Roblox.
local fontOptions = {
    {name="Gotham", font=Enum.Font.Gotham},
    {name="Gotham Medium", font=Enum.Font.GothamMedium},
    {name="Gotham Black", font=Enum.Font.GothamBlack},
    {name="Source Sans", font=Enum.Font.SourceSans},
    {name="Source Sans Bold", font=Enum.Font.SourceSansBold},
    {name="Roboto", font=Enum.Font.Roboto},
    {name="Roboto Mono", font=Enum.Font.RobotoMono},
    {name="Ubuntu", font=Enum.Font.Ubuntu},
    {name="Oswald", font=Enum.Font.Oswald},
    {name="Nunito", font=Enum.Font.Nunito},
    {name="Fredoka", font=Enum.Font.FredokaOne},
    {name="Michroma", font=Enum.Font.Michroma},
    {name="Code", font=Enum.Font.Code},
    {name="SciFi", font=Enum.Font.SciFi},
    {name="Arcade", font=Enum.Font.Arcade},
}
local savedFonts = setmetatable({}, {__mode = "k"})
local activeUIFont = nil
local function isScreenGuiText(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
        return false
    end
    local ancestor = obj.Parent
    while ancestor and ancestor ~= PG do
        if ancestor:IsA("BillboardGui") or ancestor:IsA("SurfaceGui") then
            return false
        end
        if ancestor:IsA("ScreenGui") then
            return true
        end
        ancestor = ancestor.Parent
    end
    return false
end
local function applyFontToObject(obj, selected)
    if not obj or not obj.Parent or not isScreenGuiText(obj) then return end
    if savedFonts[obj] == nil then
        savedFonts[obj] = obj.Font
    end
    pcall(function() obj.Font = selected end)
end
local fontWatchConnection = PG.DescendantAdded:Connect(function(obj)
    if activeUIFont then
        task.defer(function()
            if activeUIFont then applyFontToObject(obj, activeUIFont) end
        end)
    end
end)
local function applyFont(fontName)
    local selected
    for _, item in ipairs(fontOptions) do
        if item.name == fontName then selected = item.font break end
    end
    if not selected then return end
    activeUIFont = selected
    for _, obj in ipairs(PG:GetDescendants()) do
        applyFontToObject(obj, selected)
    end
    notify("Fuente " .. fontName .. " aplicada solo a la UI", THEME.accent)
end
for _, item in ipairs(fontOptions) do
    addAction("🎨 Visual", "Fuente " .. item.name, "Aa", function() applyFont(item.name) end)
end
addAction("🎨 Visual", "Restaurar fuentes", "↺", function()
    activeUIFont = nil
    for obj, font in pairs(savedFonts) do
        if obj and obj.Parent then pcall(function() obj.Font = font end) end
    end
    savedFonts = setmetatable({}, {__mode = "k"})
    notify("Fuentes originales de la UI restauradas", THEME.mutedText)
end)

-- AURA 5 CAPAS
local auraParts = {}
local auraConn = nil
local auraCfg = {
    {size=5,  color=Color3.fromRGB(139,137,158), trans=0.86, speed=0.32,  offset=0},
    {size=7,  color=Color3.fromRGB(112,116,137), trans=0.91, speed=-0.34, offset=1.5},
    {size=10, color=Color3.fromRGB(155,151,170), trans=0.94, speed=0.24,  offset=3},
    {size=13, color=Color3.fromRGB(105,111,128), trans=0.965, speed=-0.20,offset=4.5},
    {size=17, color=Color3.fromRGB(175,174,188), trans=0.975, speed=0.16, offset=6},
}
addToggle("🎨 Visual", "Aura Cósmica (5 capas)", "✨", function(s)
    if auraConn then auraConn:Disconnect() auraConn = nil end
    for _, p in ipairs(auraParts) do if p and p.Parent then p:Destroy() end end
    auraParts = {}
    if not s then return end
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    for i, cfg in ipairs(auraCfg) do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(cfg.size, cfg.size, cfg.size)
        p.Color = cfg.color; p.Material = Enum.Material.SmoothPlastic
        p.Transparency = cfg.trans; p.Anchored = true
        p.CanCollide = false; p.CastShadow = false
        p.Parent = char
        table.insert(auraParts, p)
        local e = Instance.new("ParticleEmitter")
        e.Texture = "rbxassetid://243660364"
        e.Rate = 4; e.Lifetime = NumberRange.new(1.2,2.0)
        e.Speed = NumberRange.new(2,4)
        e.SpreadAngle = Vector2.new(180,180)
        e.Size = NumberSequence.new(0.5, 0)
        e.Color = ColorSequence.new(cfg.color, Color3.new(1,1,1))
        e.LightEmission = 0.12
        e.Parent = p
    end
    local t = 0
    auraConn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        if root and root.Parent then
            for i, p in ipairs(auraParts) do
                if p and p.Parent then
                    local c = auraCfg[i]
                    p.CFrame = root.CFrame * CFrame.Angles(0, t*c.speed, 0) * CFrame.new(0, c.offset + math.sin(t*2+i)*0.6, 0)
                    p.Transparency = c.trans + math.sin(t*3+i)*0.03
                end
            end
        end
    end)
end, Color3.fromRGB(150,80,255))

-- ESTELA AL CAMINAR
local trailConn = nil
addToggle("🎨 Visual", "Estela al Caminar", "👣", function(s)
    if trailConn then trailConn:Disconnect() trailConn = nil end
    if not s then return end
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local last = hrp.Position
    trailConn = RunService.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent then return end
        local cur = hrp.Position
        if (cur - last).Magnitude > 1.5 then
            local p = Instance.new("Part")
            p.Size = Vector3.new(1,1,1)
            p.Position = last
            p.Anchored = true; p.CanCollide = false; p.CastShadow = false
            p.Transparency = 0.3
            p.Material = Enum.Material.SmoothPlastic
            p.Color = Color3.fromRGB(137, 135, 153)
            p.Shape = Enum.PartType.Ball
            p.Parent = Workspace
            TweenService:Create(p, TweenInfo.new(0.8), {
                Transparency = 1, Size = Vector3.new(0.2,0.2,0.2)
            }):Play()
            task.delay(0.85, function() p:Destroy() end)
            last = cur
        end
    end)
end, Color3.fromRGB(100,255,200))

-- PERSONAJE BRILLANTE
local glowLight = nil
addToggle("🎨 Visual", "Iluminación Suave del Personaje", "✧", function(s)
    if glowLight then glowLight:Destroy() glowLight = nil end
    if not s then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    glowLight = Instance.new("PointLight")
    glowLight.Color = Color3.fromRGB(166, 164, 184)
    glowLight.Brightness = 1.05
    glowLight.Range = 11
    glowLight.Shadows = false
    glowLight.Parent = hrp
end, THEME.accent)

-- NOMBRES MONOCROMÁTICOS: vuelve a aplicar el estilo cuando el juego recrea sus etiquetas.
local nameConns = {}
local originalNameColors = setmetatable({}, {__mode = "k"})
local namesStyleEnabled = false
local function disconnectNameConnections()
    for _, connection in ipairs(nameConns) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(nameConns)
end
local function styleNameBillboards(char)
    if not namesStyleEnabled or not char or not char.Parent then return end
    for _, item in ipairs(char:GetDescendants()) do
        if item:IsA("BillboardGui") then
            for _, child in ipairs(item:GetDescendants()) do
                if child:IsA("TextLabel") then
                    if originalNameColors[child] == nil then
                        originalNameColors[child] = child.TextColor3
                    end
                    child.TextColor3 = Color3.fromRGB(205, 207, 220)
                end
            end
        end
    end
end
local function watchNameCharacter(char)
    if not char then return end
    task.spawn(function()
        task.wait(0.15)
        styleNameBillboards(char)
    end)
    table.insert(nameConns, char.DescendantAdded:Connect(function(item)
        if item:IsA("BillboardGui") then
            task.delay(0.12, function() styleNameBillboards(char) end)
        elseif item:IsA("TextLabel") then
            local ancestor = item.Parent
            while ancestor and ancestor ~= char and not ancestor:IsA("BillboardGui") do
                ancestor = ancestor.Parent
            end
            if ancestor and ancestor:IsA("BillboardGui") then
                task.defer(function()
                    if namesStyleEnabled and item.Parent then
                        if originalNameColors[item] == nil then originalNameColors[item] = item.TextColor3 end
                        item.TextColor3 = Color3.fromRGB(205, 207, 220)
                    end
                end)
            end
        end
    end))
end
addToggle("🎨 Visual", "Nombres Monocromáticos", "🏷️", function(enabled)
    namesStyleEnabled = enabled
    disconnectNameConnections()
    if enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then watchNameCharacter(player.Character) end
            table.insert(nameConns, player.CharacterAdded:Connect(watchNameCharacter))
        end
        table.insert(nameConns, Players.PlayerAdded:Connect(function(player)
            table.insert(nameConns, player.CharacterAdded:Connect(watchNameCharacter))
            if player.Character then watchNameCharacter(player.Character) end
        end))
    else
        for label, originalColor in pairs(originalNameColors) do
            if label and label.Parent then
                pcall(function() label.TextColor3 = originalColor end)
            end
        end
        originalNameColors = setmetatable({}, {__mode = "k"})
    end
end, THEME.accent)

-- NOMBRE PERSONAL: se reconstruye tras cada reaparición y permanece ocluido por el escenario.
local customNameObj = nil
local customNameEnabled = false
local customNameConnection = nil
local function clearCustomName()
    if customNameObj then
        customNameObj:Destroy()
        customNameObj = nil
    end
end
local function createCustomName(char)
    if not customNameEnabled or not char then return end
    clearCustomName()
    local head = char:WaitForChild("Head", 8)
    if not head or not customNameEnabled or not head.Parent then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "CosmicPersonalNameTag"
    bb.Size = UDim2.new(0, 190, 0, 42)
    bb.StudsOffset = Vector3.new(0, 2.65, 0)
    bb.AlwaysOnTop = false
    bb.MaxDistance = 80
    bb.LightInfluence = 0
    bb.Adornee = head
    bb.Parent = head

    local lbl = Instance.new("TextLabel")
    lbl.Name = "DisplayName"
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "✦ " .. LP.DisplayName .. " ✦"
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 17
    lbl.TextColor3 = Color3.fromRGB(222, 222, 233)
    lbl.TextStrokeColor3 = Color3.fromRGB(22, 23, 30)
    lbl.TextStrokeTransparency = 0.48
    lbl.Parent = bb

    local sub = Instance.new("TextLabel")
    sub.Name = "Username"
    sub.Size = UDim2.new(1, 0, 0, 13)
    sub.Position = UDim2.new(0, 0, 0, 25)
    sub.BackgroundTransparency = 1
    sub.Text = "@" .. LP.Name
    sub.Font = Enum.Font.GothamMedium
    sub.TextSize = 9
    sub.TextColor3 = Color3.fromRGB(164, 166, 181)
    sub.TextStrokeTransparency = 0.65
    sub.Parent = bb

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(158, 159, 177)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 241)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(172, 174, 190)),
    })
    grad.Parent = lbl
    customNameObj = bb
end
addToggle("🎨 Visual", "Nombre Personal Degradado", "💫", function(enabled)
    customNameEnabled = enabled
    clearCustomName()
    if enabled then
        if LP.Character then task.spawn(createCustomName, LP.Character) end
    end
end, THEME.accent)
customNameConnection = LP.CharacterAdded:Connect(function(char)
    if customNameEnabled then task.spawn(createCustomName, char) end
end)
local displayNameConnection = LP:GetPropertyChangedSignal("DisplayName"):Connect(function()
    if customNameObj and customNameObj.Parent then
        local label = customNameObj:FindFirstChild("DisplayName")
        if label then label.Text = "✦ " .. LP.DisplayName .. " ✦" end
    end
end)

-- CURSOR CÓSMICO
local cursorGui = nil
local cursorConns = {}
local savedMouseIconEnabled = UserInputService.MouseIconEnabled
addToggle("🎨 Visual", "Cursor Cósmico", "🎯", function(s)
    for _, c in ipairs(cursorConns) do c:Disconnect() end
    cursorConns = {}
    if cursorGui then cursorGui:Destroy() cursorGui = nil end
    if not s then UserInputService.MouseIconEnabled = savedMouseIconEnabled return end
    savedMouseIconEnabled = UserInputService.MouseIconEnabled
    UserInputService.MouseIconEnabled = false
    cursorGui = Instance.new("ScreenGui")
    cursorGui.Name = "CosmicCursor"
    cursorGui.IgnoreGuiInset = true
    cursorGui.DisplayOrder = 10000
    cursorGui.Parent = PG
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 20, 0, 20)
    dot.BackgroundColor3 = Color3.fromRGB(145, 143, 165)
    dot.BorderSizePixel = 0
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.Parent = cursorGui
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    local dotStroke = Instance.new("UIStroke")
    dotStroke.Color = Color3.new(1,1,1)
    dotStroke.Thickness = 2
    dotStroke.Parent = dot
    table.insert(cursorConns, RunService.RenderStepped:Connect(function()
        local pos = UserInputService:GetMouseLocation()
        dot.Position = UDim2.new(0, pos.X, 0, pos.Y)
    end))
end, Color3.fromRGB(200,150,255))

-- CHAT ESTILIZADO: conserva y restaura el formato original.
local chatConn = nil
local chatOriginalStyle = setmetatable({}, {__mode = "k"})
local function styleChatLabel(label)
    if not label or not label.Parent or not label:IsA("TextLabel") then return end
    if not (label.Name == "ChatTextLabel" or label.Name:lower():find("chat", 1, true)) then return end
    if chatOriginalStyle[label] == nil then
        chatOriginalStyle[label] = {
            TextStrokeTransparency = label.TextStrokeTransparency,
            TextStrokeColor3 = label.TextStrokeColor3,
        }
    end
    pcall(function()
        label.TextStrokeTransparency = 0.34
        label.TextStrokeColor3 = Color3.fromRGB(91, 70, 129)
    end)
end
local function restoreChatStyle()
    for label, original in pairs(chatOriginalStyle) do
        if label and label.Parent then
            pcall(function()
                label.TextStrokeTransparency = original.TextStrokeTransparency
                label.TextStrokeColor3 = original.TextStrokeColor3
            end)
        end
        chatOriginalStyle[label] = nil
    end
end
addToggle("🎨 Visual", "Chat Estilizado", "💬", function(s)
    if chatConn then chatConn:Disconnect() chatConn = nil end
    if not s then restoreChatStyle() return end
    for _, d in ipairs(PG:GetDescendants()) do styleChatLabel(d) end
    chatConn = PG.DescendantAdded:Connect(function(o)
        if o:IsA("TextLabel") then task.defer(styleChatLabel, o) end
    end)
end, Color3.fromRGB(150,200,255))

-- ============================================================
-- ✦ PESTAÑA CÓSMICO ✦
-- ============================================================

local customSky = nil
local nebulas = {}
local nebulaConn = nil
local skyFolder = nil
local savedSkyState = nil
local hiddenOriginalSkies = {}

local function restoreSkyState()
    if savedSkyState then
        for prop, value in pairs(savedSkyState) do
            pcall(function() Lighting[prop] = value end)
        end
        savedSkyState = nil
    end
    for _, oldSky in ipairs(hiddenOriginalSkies) do
        if oldSky and oldSky.Parent == nil then
            oldSky.Parent = Lighting
        end
    end
    hiddenOriginalSkies = {}
end

addToggle("🌌 Cosmo", "Sky + Nebulosas", "🌌", function(s)
    if customSky then customSky:Destroy() customSky = nil end
    for _, oldSky in ipairs(hiddenOriginalSkies) do
        if oldSky and oldSky.Parent == nil then oldSky.Parent = Lighting end
    end
    hiddenOriginalSkies = {}
    for _, n in ipairs(nebulas) do if n and n.Parent then n:Destroy() end end
    nebulas = {}
    if nebulaConn then nebulaConn:Disconnect() nebulaConn = nil end
    if skyFolder then skyFolder:Destroy() skyFolder = nil end
    if not s then
        restoreSkyState()
        return
    end

    if not savedSkyState then
        savedSkyState = {}
        for _, prop in ipairs({"ClockTime", "Brightness", "OutdoorAmbient", "Ambient", "EnvironmentDiffuseScale", "EnvironmentSpecularScale", "FogColor", "FogEnd", "FogStart"}) do
            pcall(function() savedSkyState[prop] = Lighting[prop] end)
        end
    end
    for _, oldSky in ipairs(Lighting:GetChildren()) do
        if oldSky:IsA("Sky") then
            table.insert(hiddenOriginalSkies, oldSky)
            oldSky.Parent = nil
        end
    end

    customSky = Instance.new("Sky")
    local id = "rbxassetid://9670081176"
    customSky.SkyboxBk = id; customSky.SkyboxDn = id; customSky.SkyboxFt = id
    customSky.SkyboxLf = id; customSky.SkyboxRt = id; customSky.SkyboxUp = id
    customSky.StarCount = 4200
    customSky.SunAngularSize = 0; customSky.MoonAngularSize = 0
    customSky.Parent = Lighting

    Lighting.ClockTime = 20.25
    Lighting.Brightness = 1.65
    Lighting.OutdoorAmbient = Color3.fromRGB(76, 78, 94)
    Lighting.Ambient = Color3.fromRGB(47, 49, 62)
    Lighting.EnvironmentDiffuseScale = 0.22
    Lighting.EnvironmentSpecularScale = 0.28
    Lighting.FogColor = Color3.fromRGB(24, 26, 36)
    Lighting.FogEnd = 1900
    Lighting.FogStart = 420

    skyFolder = Instance.new("Folder")
    skyFolder.Name = "CosmicAddon_Sky"
    skyFolder.Parent = Workspace
    local colors = {
        Color3.fromRGB(112, 108, 137),
        Color3.fromRGB(83, 91, 116),
        Color3.fromRGB(137, 132, 151),
        Color3.fromRGB(100, 105, 123),
    }
    for i = 1, 5 do
        local n = Instance.new("Part")
        n.Shape = Enum.PartType.Ball
        local size = math.random(1900, 2900)
        n.Size = Vector3.new(size, size, size)
        n.Color = colors[(i-1)%#colors+1]
        n.Material = Enum.Material.SmoothPlastic
        n.Transparency = 0.968
        n.Anchored = true; n.CanCollide = false; n.CastShadow = false
        n.Position = Vector3.new(math.random(-7000,7000), math.random(1800,4300), math.random(-7000,7000))
        n.Parent = skyFolder
        table.insert(nebulas, {part=n, phase=math.random()*10, baseTrans=0.968})
    end
    local t = 0
    nebulaConn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        for _, n in ipairs(nebulas) do
            if n.part and n.part.Parent then
                n.part.Transparency = n.baseTrans + math.sin(t*0.22+n.phase)*0.012
                n.part.CFrame = n.part.CFrame * CFrame.Angles(dt*0.003, dt*0.004, dt*0.002)
            end
        end
    end)
end, THEME.accent)

-- SHADERS NATIVOS CONFIGURABLES: perfiles suaves y control manual.
local shaderFx = {}
local shaderAtmosphere = nil
local savedAtmosphere = nil
local shaderRefs = {}
local currentShaderProfile = "Amatista Glass"
local shaderSettings = {}
local manualShaderOverrides = {}
local shaderProfiles = {
    ["Cinemático"] = {Brightness=0.006, Contrast=0.095, Saturation=0.095, Bloom=0.16, BloomSize=24, BloomThreshold=0.97, Blur=0.78, Rays=0.007, Density=0.105, Haze=0.40, Tint=Color3.fromRGB(250,238,255), AtmosColor=Color3.fromRGB(177,139,224), Decay=Color3.fromRGB(73,72,145)},
    ["Noir Suave"] = {Brightness=-0.004, Contrast=0.105, Saturation=-0.06, Bloom=0.075, BloomSize=19, BloomThreshold=0.99, Blur=0.65, Rays=0.002, Density=0.085, Haze=0.35, Tint=Color3.fromRGB(232,226,245), AtmosColor=Color3.fromRGB(148,143,184), Decay=Color3.fromRGB(63,69,104)},
    ["Plata Natural"] = {Brightness=0.008, Contrast=0.07, Saturation=0.075, Bloom=0.14, BloomSize=21, BloomThreshold=0.97, Blur=0.55, Rays=0.005, Density=0.065, Haze=0.34, Tint=Color3.fromRGB(248,240,255), AtmosColor=Color3.fromRGB(196,181,225), Decay=Color3.fromRGB(86,91,129)},
    ["Ligero"] = {Brightness=0.003, Contrast=0.04, Saturation=0.035, Bloom=0.025, BloomSize=10, BloomThreshold=0.995, Blur=0.12, Rays=0, Density=0.025, Haze=0.12, Tint=Color3.fromRGB(247,242,255), AtmosColor=Color3.fromRGB(190,183,220), Decay=Color3.fromRGB(93,91,145)},
    ["Amatista Glass"] = {Brightness=0.008, Contrast=0.105, Saturation=0.14, Bloom=0.155, BloomSize=24, BloomThreshold=0.975, Blur=0.72, Rays=0.005, Density=0.095, Haze=0.36, Tint=Color3.fromRGB(250,232,255), AtmosColor=Color3.fromRGB(181,126,239), Decay=Color3.fromRGB(79,63,151)},
    ["Aurora Suave"] = {Brightness=0.008, Contrast=0.075, Saturation=0.12, Bloom=0.12, BloomSize=22, BloomThreshold=0.98, Blur=0.55, Rays=0.006, Density=0.075, Haze=0.31, Tint=Color3.fromRGB(235,240,255), AtmosColor=Color3.fromRGB(132,160,205), Decay=Color3.fromRGB(82,91,150)},
    ["Prisma Suave"] = {Brightness=0.007, Contrast=0.10, Saturation=0.16, Bloom=0.18, BloomSize=26, BloomThreshold=0.965, Blur=0.62, Rays=0.008, Density=0.085, Haze=0.34, Tint=Color3.fromRGB(244,235,255), AtmosColor=Color3.fromRGB(145,132,220), Decay=Color3.fromRGB(77,95,165)},
}

local function refreshShaderValues()
    if shaderRefs.Color and shaderRefs.Color.Parent then
        shaderRefs.Color.Brightness = shaderSettings.Brightness
        shaderRefs.Color.Contrast = shaderSettings.Contrast
        shaderRefs.Color.Saturation = shaderSettings.Saturation
        shaderRefs.Color.TintColor = shaderSettings.Tint
    end
    if shaderRefs.Bloom and shaderRefs.Bloom.Parent then
        shaderRefs.Bloom.Intensity = shaderSettings.Bloom
    end
    if shaderRefs.Rays and shaderRefs.Rays.Parent then
        shaderRefs.Rays.Intensity = shaderSettings.Rays
    end
    if shaderRefs.Blur and shaderRefs.Blur.Parent then
        shaderRefs.Blur.Size = shaderSettings.Blur or 0
    end
    if shaderAtmosphere and shaderAtmosphere.Parent then
        shaderAtmosphere.Density = shaderSettings.Density
        shaderAtmosphere.Haze = shaderSettings.Haze
        shaderAtmosphere.Color = shaderSettings.AtmosColor
        shaderAtmosphere.Decay = shaderSettings.Decay
    end
end

local function clearCinematicShaders()
    for _, effect in ipairs(shaderFx) do
        if effect and effect.Parent then effect:Destroy() end
    end
    shaderFx = {}
    if savedAtmosphere and shaderAtmosphere and shaderAtmosphere.Parent then
        for prop, value in pairs(savedAtmosphere) do
            pcall(function() shaderAtmosphere[prop] = value end)
        end
    elseif shaderAtmosphere and shaderAtmosphere.Parent then
        shaderAtmosphere:Destroy()
    end
    shaderAtmosphere = nil
    savedAtmosphere = nil
    shaderRefs = {}
end

local function applyCinematicShaders(profileName)
    clearCinematicShaders()
    if profileName and shaderProfiles[profileName] then
        currentShaderProfile = profileName
        manualShaderOverrides = {}
    end
    local profile = shaderProfiles[currentShaderProfile] or shaderProfiles["Cinemático"]
    shaderSettings = {}
    for key, value in pairs(profile) do shaderSettings[key] = value end
    for key, value in pairs(manualShaderOverrides) do shaderSettings[key] = value end

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "CosmicVisual_Color"
    cc.Parent = Lighting
    table.insert(shaderFx, cc)
    shaderRefs.Color = cc

    local bloom = Instance.new("BloomEffect")
    bloom.Name = "CosmicVisual_Bloom"
    bloom.Size = shaderSettings.BloomSize
    bloom.Threshold = shaderSettings.BloomThreshold
    bloom.Parent = Lighting
    table.insert(shaderFx, bloom)
    shaderRefs.Bloom = bloom

    local rays = Instance.new("SunRaysEffect")
    rays.Name = "CosmicVisual_Rays"
    rays.Spread = 0.62
    rays.Parent = Lighting
    table.insert(shaderFx, rays)
    shaderRefs.Rays = rays

    local blur = Instance.new("BlurEffect")
    blur.Name = "CosmicVisual_Blur"
    blur.Size = shaderSettings.Blur or 0
    blur.Parent = Lighting
    table.insert(shaderFx, blur)
    shaderRefs.Blur = blur

    shaderAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if shaderAtmosphere then
        savedAtmosphere = {}
        for _, prop in ipairs({"Density", "Offset", "Color", "Decay", "Glare", "Haze"}) do
            pcall(function() savedAtmosphere[prop] = shaderAtmosphere[prop] end)
        end
    else
        shaderAtmosphere = Instance.new("Atmosphere")
        shaderAtmosphere.Name = "CosmicVisual_Atmosphere"
        shaderAtmosphere.Parent = Lighting
        table.insert(shaderFx, shaderAtmosphere)
    end
    shaderAtmosphere.Offset = 0.03
    shaderAtmosphere.Glare = 0.015
    refreshShaderValues()
end

addToggle("🌌 Cosmo", "Shaders Cinemáticos", "✧", function(s)
    if s then applyCinematicShaders() else clearCinematicShaders() end
end, THEME.accent)

-- Profundidad de campo discreta, independiente del preset principal.
local depthOfField = nil
addToggle("🌌 Cosmo", "Profundidad de Campo Suave", "◉", function(s)
    if depthOfField then depthOfField:Destroy() depthOfField = nil end
    if not s then return end
    depthOfField = Instance.new("DepthOfFieldEffect")
    depthOfField.Name = "CosmicVisual_DepthOfField"
    depthOfField.FarIntensity = 0.12
    depthOfField.FocusDistance = 28
    depthOfField.InFocusRadius = 32
    depthOfField.NearIntensity = 0.04
    depthOfField.Parent = Lighting
end, THEME.accent)

local savedGlobalShadows = nil
addToggle("🌌 Cosmo", "Sombras Globales", "▧", function(s)
    if s then
        if savedGlobalShadows == nil then savedGlobalShadows = Lighting.GlobalShadows end
        Lighting.GlobalShadows = true
    elseif savedGlobalShadows ~= nil then
        Lighting.GlobalShadows = savedGlobalShadows
        savedGlobalShadows = nil
    end
end, THEME.accent)

-- AGUJERO NEGRO
local bhModel = nil
local bhConns = {}
addToggle("🌌 Cosmo", "Agujero Negro Gigante", "🕳️", function(s)
    if bhModel then bhModel:Destroy() bhModel = nil end
    for _, c in ipairs(bhConns) do c:Disconnect() end
    bhConns = {}
    if not s then return end
    local cam = Workspace.CurrentCamera
    local pos = cam.CFrame.Position + cam.CFrame.LookVector * 180 + Vector3.new(0,45,0)
    bhModel = Instance.new("Model")
    bhModel.Name = "CosmicAddon_BH"
    local core = Instance.new("Part")
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(36,36,36)
    core.Color = Color3.new(0,0,0)
    core.Material = Enum.Material.SmoothPlastic
    core.Anchored = true; core.CanCollide = false; core.CastShadow = false
    core.Parent = bhModel
    for _, l in ipairs({
        {size=43, color=Color3.fromRGB(49,39,77),  trans=0.68},
        {size=49, color=Color3.fromRGB(76,62,111), trans=0.80},
        {size=56, color=Color3.fromRGB(105,86,145), trans=0.88},
        {size=66, color=Color3.fromRGB(143,120,181), trans=0.93},
        {size=78, color=Color3.fromRGB(188,169,218), trans=0.97},
    }) do
        local s2 = Instance.new("Part")
        s2.Shape = Enum.PartType.Ball
        s2.Size = Vector3.new(l.size,l.size,l.size)
        s2.Color = l.color; s2.Material = Enum.Material.SmoothPlastic
        s2.Transparency = l.trans; s2.Anchored = true
        s2.CanCollide = false; s2.CastShadow = false
        s2.Parent = bhModel
    end
    local rings = {}
    for i, cfg in ipairs({
        {size=82, thick=4, color=Color3.fromRGB(112,89,157),  tilt=8,  speed=0.24},
        {size=96, thick=3,  color=Color3.fromRGB(137,112,181),  tilt=22, speed=-0.28},
        {size=112,thick=3,  color=Color3.fromRGB(91,96,146),  tilt=38, speed=0.20},
        {size=128,thick=2,  color=Color3.fromRGB(171,145,206), tilt=52, speed=-0.24},
        {size=146,thick=2,  color=Color3.fromRGB(197,174,223), tilt=68, speed=0.18},
    }) do
        local r = Instance.new("Part")
        r.Shape = Enum.PartType.Cylinder
        r.Size = Vector3.new(cfg.thick, cfg.size, cfg.size)
        r.Color = cfg.color; r.Material = Enum.Material.SmoothPlastic
        r.Transparency = 0.1; r.Anchored = true
        r.CanCollide = false; r.CastShadow = false
        r.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(cfg.tilt), 0, math.rad(90))
        r.Parent = bhModel
        local e = Instance.new("ParticleEmitter")
        e.Texture = "rbxassetid://243660364"
        e.Rate = 4; e.Lifetime = NumberRange.new(1.4,2.2)
        e.Speed = NumberRange.new(4,10)
        e.SpreadAngle = Vector2.new(0,360)
        e.Rotation = NumberRange.new(0,360)
        e.RotSpeed = NumberRange.new(-360,360)
        e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,1.6), NumberSequenceKeypoint.new(1,0)})
        e.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.2), NumberSequenceKeypoint.new(0.7,0.5), NumberSequenceKeypoint.new(1,1)
        })
        e.Color = ColorSequence.new(Color3.new(1,1,1), cfg.color)
        e.LightEmission = 0.18
        e.Parent = r
        table.insert(rings, {part=r, tilt=cfg.tilt, speed=cfg.speed})
    end
    local coreLight = Instance.new("PointLight")
    coreLight.Color = Color3.fromRGB(125, 124, 139)
    coreLight.Brightness = 0.28; coreLight.Range = 58; coreLight.Shadows = false
    coreLight.Parent = core
    bhModel:PivotTo(CFrame.new(pos))
    bhModel.Parent = Workspace
    local acc = 0
    table.insert(bhConns, RunService.Heartbeat:Connect(function(dt)
        if not bhModel or not bhModel.Parent then return end
        acc = acc + dt
        for _, rd in ipairs(rings) do
            if rd.part and rd.part.Parent then
                rd.part.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(rd.tilt), acc*rd.speed, math.rad(90))
            end
        end
        local pulse = 1 + math.sin(acc*1.5)*0.03
        core.Size = Vector3.new(36*pulse, 36*pulse, 36*pulse)
    end))
end, Color3.fromRGB(200,150,255))

-- LUCIÉRNAGAS
local ffParts = {}
local ffConn = nil
addToggle("🌌 Cosmo", "Luciérnagas en Espiral", "🦋", function(s)
    if ffConn then ffConn:Disconnect() ffConn = nil end
    for _, fp in ipairs(ffParts) do if fp.part then fp.part:Destroy() end end
    ffParts = {}
    if not s then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for i = 1, 8 do
        local p = Instance.new("Part")
        p.Size = Vector3.new(0.4,0.4,0.4)
        p.Transparency = 1
        p.Anchored = true; p.CanCollide = false
        p.Parent = Workspace
        local e = Instance.new("ParticleEmitter")
        e.Texture = "rbxassetid://243660364"
        e.Rate = 7; e.Lifetime = NumberRange.new(1,2)
        e.Speed = NumberRange.new(0.5,2)
        e.SpreadAngle = Vector2.new(180,180)
        e.Size = NumberSequence.new(0.35, 0)
        e.Color = ColorSequence.new(
            Color3.fromRGB(160, 158, 177),
            Color3.fromRGB(205, 205, 215))
        e.LightEmission = 0.16
        e.Parent = p
        table.insert(ffParts, {part=p, offset=i/8 * math.pi * 2})
    end
    local t = 0
    ffConn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        if hrp and hrp.Parent then
            for _, fp in ipairs(ffParts) do
                if fp.part and fp.part.Parent then
                    local a = t * 1.5 + fp.offset
                    fp.part.CFrame = hrp.CFrame * CFrame.new(
                        math.cos(a)*3, math.sin(t*2+fp.offset)*1.5 + 2, math.sin(a)*3)
                end
            end
        end
    end)
end, Color3.fromRGB(255,255,150))

-- METEORITOS: conexión administrada y límite de objetos activos.
local meteorConn = nil
local meteorParts = {}
addToggle("🌌 Cosmo", "Lluvia de Meteoritos", "☄️", function(s)
    if meteorConn then meteorConn:Disconnect() meteorConn = nil end
    if not s then
        for _, meteor in ipairs(meteorParts) do
            if meteor and meteor.Parent then meteor:Destroy() end
        end
        meteorParts = {}
        return
    end
    local spawnClock = 0
    meteorConn = RunService.Heartbeat:Connect(function(dt)
        spawnClock = spawnClock + dt
        if spawnClock < 0.65 then return end
        spawnClock = 0
        if #meteorParts >= 6 or math.random() > 0.32 then return end
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local startPos = cam.CFrame.Position + Vector3.new(
            math.random(-900,900), 1300, math.random(-900,900))
        local meteor = Instance.new("Part")
        meteor.Name = "CosmicVisual_Meteor"
        meteor.Size = Vector3.new(1.5,1.5,6)
        meteor.Position = startPos
        meteor.Color = Color3.fromRGB(145, 142, 157)
        meteor.Material = Enum.Material.SmoothPlastic
        meteor.Anchored = true
        meteor.CanCollide = false
        meteor.CanTouch = false
        meteor.CanQuery = false
        meteor.CastShadow = false
        meteor.Parent = Workspace
        table.insert(meteorParts, meteor)
        local a0 = Instance.new("Attachment")
        a0.Position = Vector3.new(0,0,3)
        a0.Parent = meteor
        local a1 = Instance.new("Attachment")
        a1.Position = Vector3.new(0,0,-3)
        a1.Parent = meteor
        local trail = Instance.new("Trail")
        trail.Lifetime = 1.1
        trail.Color = ColorSequence.new(Color3.fromRGB(150,146,164), Color3.fromRGB(90,94,111))
        trail.Transparency = NumberSequence.new(0.45, 1)
        trail.Attachment0 = a0
        trail.Attachment1 = a1
        trail.Parent = meteor
        local target = startPos + Vector3.new(math.random(-220,220), -1500, math.random(-220,220))
        TweenService:Create(meteor, TweenInfo.new(1.8, Enum.EasingStyle.Linear), {Position = target}):Play()
        task.delay(1.9, function()
            if meteor and meteor.Parent then meteor:Destroy() end
            for i, item in ipairs(meteorParts) do
                if item == meteor then table.remove(meteorParts, i) break end
            end
        end)
    end)
end)

-- PORTAL
local portalPart = nil
local portalRing = nil
local portalConn = nil
addToggle("🌌 Cosmo", "Portal Personal", "🌀", function(s)
    if portalConn then portalConn:Disconnect() portalConn = nil end
    if portalPart then portalPart:Destroy() portalPart = nil end
    if portalRing then portalRing:Destroy() portalRing = nil end
    if not s then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    portalPart = Instance.new("Part")
    portalPart.Shape = Enum.PartType.Cylinder
    portalPart.Size = Vector3.new(0.2, 8, 8)
    portalPart.Color = Color3.fromRGB(114, 111, 137)
    portalPart.Material = Enum.Material.SmoothPlastic
    portalPart.Transparency = 0.3
    portalPart.Anchored = true; portalPart.CanCollide = false; portalPart.CastShadow = false
    portalPart.Parent = Workspace
    portalRing = Instance.new("Part")
    portalRing.Shape = Enum.PartType.Cylinder
    portalRing.Size = Vector3.new(0.3, 9, 9)
    portalRing.Color = Color3.fromRGB(165, 163, 180)
    portalRing.Material = Enum.Material.SmoothPlastic
    portalRing.Transparency = 0.6
    portalRing.Anchored = true; portalRing.CanCollide = false; portalRing.CastShadow = false
    portalRing.Parent = Workspace
    local t = 0
    portalConn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        if hrp and hrp.Parent and portalPart and portalPart.Parent then
            local base = hrp.CFrame * CFrame.new(0, 3, -3)
            portalPart.CFrame = base * CFrame.Angles(0, t*0.5, math.rad(90))
            portalRing.CFrame = base * CFrame.Angles(0, -t*0.8, math.rad(90))

        end
    end)
end, Color3.fromRGB(150,80,255))

-- AURAS ELEMENTALES
local elementalConn = nil
local elementalPart = nil
local currentElement = nil
local function toggleElemental(element)
    if elementalConn then elementalConn:Disconnect() elementalConn = nil end
    if elementalPart then elementalPart:Destroy() elementalPart = nil end
    if currentElement == element then currentElement = nil return end
    currentElement = element
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cfg = ({
        Fuego = {color = Color3.fromRGB(139,137,153)},
        Hielo = {color = Color3.fromRGB(174,176,187)},
        Rayo  = {color = Color3.fromRGB(116,120,138)},
    })[element]
    if not cfg then return end
    elementalPart = Instance.new("Part")
    elementalPart.Size = Vector3.new(1,1,1)
    elementalPart.Transparency = 1
    elementalPart.Anchored = true; elementalPart.CanCollide = false
    elementalPart.Parent = Workspace
    local e = Instance.new("ParticleEmitter")
    e.Texture = "rbxassetid://243660364"
    e.Rate = 18; e.Lifetime = NumberRange.new(0.6, 1.3)
    e.Speed = NumberRange.new(5,10)
    e.SpreadAngle = Vector2.new(180,180)
    e.Size = NumberSequence.new(1.5, 0)
    e.Color = ColorSequence.new(cfg.color, Color3.new(1,1,1))
    e.LightEmission = 0.14
    e.Parent = elementalPart
    elementalConn = RunService.Heartbeat:Connect(function()
        if hrp and hrp.Parent and elementalPart and elementalPart.Parent then
            elementalPart.Position = hrp.Position + Vector3.new(0, 2, 0)
        end
    end)
end
addAction("🌌 Cosmo", "Aura Ceniza", "◈", function() toggleElemental("Fuego") end)
addAction("🌌 Cosmo", "Aura Niebla", "◉", function() toggleElemental("Hielo") end)
addAction("🌌 Cosmo", "Aura Plata", "✧", function() toggleElemental("Rayo") end)

-- ============================================================
-- ✦ PESTAÑA EXTRAS ✦
-- ============================================================

addSection("🎮 Extras", "REPRODUCTOR DE AUDIO")
local musicAssetId = ""
local musicLoadToken = 0
local musicPlayToken = 0
local function setMusicAssetId(rawValue)
    local digits = tostring(rawValue or ""):gsub("%D", "")
    if digits == "" then
        notify("Introduce un ID de audio válido", Color3.fromRGB(220, 145, 150))
        return
    end
    musicLoadToken += 1
    musicPlayToken += 1
    local thisToken = musicLoadToken
    ambientMusic:Stop()
    ambientMusic.SoundId = "rbxassetid://" .. digits
    musicAssetId = digits
    notify("Comprobando audio y permisos…", THEME.mutedText)
    task.spawn(function()
        local fetchStatus = nil
        local ok, err = pcall(function()
            ContentProvider:PreloadAsync({ambientMusic}, function(_, status)
                fetchStatus = status
            end)
        end)
        if thisToken ~= musicLoadToken then return end
        if ok and (fetchStatus == Enum.AssetFetchStatus.Success or ambientMusic.IsLoaded) then
            notify("Audio cargado. Ya puedes reproducirlo.", THEME.enabled)
        else
            notify("No se pudo cargar. Revisa el ID y los permisos del audio.", Color3.fromRGB(220, 145, 150))
            if not ok then warn("[CosmicVisualPlus] Audio: " .. tostring(err)) end
        end
    end)
end
addTextInput("🎮 Extras", "ID DE AUDIO PERMITIDO", "Pega aquí tu ID de audio de Roblox", "", setMusicAssetId)
addToggle("🎮 Extras", "Música personalizada", "♫", function(enabled)
    musicPlayToken += 1
    local thisPlayToken = musicPlayToken
    if not enabled then
        ambientMusic:Stop()
        return
    end
    if musicAssetId == "" or ambientMusic.SoundId == "" then
        if toggleRegistry["Música personalizada"] then toggleRegistry["Música personalizada"](false) end
        notify("Primero aplica un ID de audio permitido", Color3.fromRGB(220, 145, 150))
        return
    end
    task.spawn(function()
        if not ambientMusic.IsLoaded then
            local ok = pcall(function() ContentProvider:PreloadAsync({ambientMusic}) end)
            if not ok then
                if toggleRegistry["Música personalizada"] then toggleRegistry["Música personalizada"](false) end
                notify("El audio no está disponible para esta experiencia", Color3.fromRGB(220, 145, 150))
                return
            end
        end
        if thisPlayToken ~= musicPlayToken then return end
        if ambientMusic.IsLoaded then
            ambientMusic:Play()
            notify("Reproduciendo música", THEME.enabled)
        else
            if toggleRegistry["Música personalizada"] then toggleRegistry["Música personalizada"](false) end
            notify("Roblox no pudo cargar ese audio", Color3.fromRGB(220, 145, 150))
        end
    end)
end, THEME.accent)

-- FUEGOS ARTIFICIALES: la conexión se elimina al apagar el interruptor.
local fireworksConn = nil
local fireworksEnabled = false
local function spawnFireworks()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    for i = 1, 5 do
        task.delay((i - 1) * 0.22, function()
            if not fireworksEnabled then return end
            local currentCam = Workspace.CurrentCamera
            if not currentCam then return end
            local pos = currentCam.CFrame.Position + currentCam.CFrame.LookVector * 15
                + Vector3.new(math.random(-8,8), math.random(2,7), math.random(-8,8))
            local p = Instance.new("Part")
            p.Name = "CVP_Firework"
            p.Size = Vector3.new(0.35,0.35,0.35)
            p.Position = pos
            p.Color = Color3.fromRGB(164, 126, 208)
            p.Material = Enum.Material.SmoothPlastic
            p.Anchored = true
            p.CanCollide = false
            p.CanTouch = false
            p.CanQuery = false
            p.CastShadow = false
            p.Parent = Workspace
            local e = Instance.new("ParticleEmitter")
            e.Texture = "rbxassetid://243660364"
            e.Rate = 0
            e.Lifetime = NumberRange.new(0.8,1.4)
            e.Speed = NumberRange.new(8,15)
            e.SpreadAngle = Vector2.new(180,180)
            e.Size = NumberSequence.new(0.8, 0)
            e.Color = ColorSequence.new(p.Color, Color3.fromRGB(224, 204, 246))
            e.LightEmission = 0.14
            e.Parent = p
            e:Emit(18)
            task.delay(1.5, function() if p and p.Parent then p:Destroy() end end)
        end)
    end
end
addToggle("🎮 Extras", "Fuegos Artificiales al reaparecer", "✦", function(enabled)
    fireworksEnabled = enabled
    if fireworksConn then fireworksConn:Disconnect() fireworksConn = nil end
    if not enabled then return end
    fireworksConn = LP.CharacterAdded:Connect(function()
        task.delay(1.5, function()
            if fireworksEnabled then spawnFireworks() end
        end)
    end)
end, THEME.accent)

-- MODO FOTO
addAction("🎮 Extras", "Modo Foto (flash)", "📸", function()
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1,0,1,0)
    flash.BackgroundColor3 = Color3.fromRGB(218,220,228)
    flash.BackgroundTransparency = 0.72
    flash.BorderSizePixel = 0
    flash.ZIndex = 99999
    flash.Parent = gui
    TweenService:Create(flash, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
    task.delay(0.7, function() flash:Destroy() end)
    notify("📸 Foto capturada", THEME.accent)
end, Color3.fromRGB(255,255,255))

-- PARTÍCULAS AMBIENTALES
local ambientConn = nil
local ambientParts = {}
addToggle("🎮 Extras", "Partículas Ambientales", "🌫️", function(s)
    if ambientConn then ambientConn:Disconnect() ambientConn = nil end
    for _, p in ipairs(ambientParts) do if p and p.Parent then p:Destroy() end end
    ambientParts = {}
    if not s then return end
    local cam = Workspace.CurrentCamera
    for i = 1, 10 do
        local p = Instance.new("Part")
        p.Size = Vector3.new(1,1,1)
        p.Transparency = 1
        p.Anchored = true; p.CanCollide = false
        p.Parent = Workspace
        table.insert(ambientParts, p)
        local e = Instance.new("ParticleEmitter")
        e.Texture = "rbxassetid://243660364"
        e.Rate = 2.5; e.Lifetime = NumberRange.new(3,5)
        e.Speed = NumberRange.new(0.5,2)
        e.SpreadAngle = Vector2.new(180,180)
        e.Size = NumberSequence.new(0.3, 0)
        e.Color = ColorSequence.new(Color3.fromRGB(155, 155, 171), Color3.fromRGB(205, 205, 215))
        e.LightEmission = 0.12
        e.Parent = p
        p.Position = cam.CFrame.Position + Vector3.new(
            math.random(-50,50), math.random(-20,20), math.random(-50,50))
    end
    local ambientAccumulator = 0
    ambientConn = RunService.Heartbeat:Connect(function(dt)
        ambientAccumulator = ambientAccumulator + dt
        if ambientAccumulator < 0.22 then return end
        ambientAccumulator = 0
        local cam2 = Workspace.CurrentCamera
        if not cam2 then return end
        for _, p in ipairs(ambientParts) do
            if p and p.Parent then
                p.Position = cam2.CFrame.Position + Vector3.new(
                    math.random(-50,50), math.random(-20,20), math.random(-50,50))
            end
        end
    end)
end, Color3.fromRGB(180,200,255))

-- ============================================================
-- PESTAÑA MM2: funciones recuperadas de la versión anterior.
-- ============================================================
-- ============================================================
-- PESTAÑA MM2 RESTAURADA Y AMPLIADA
-- Las detecciones se basan solo en atributos y herramientas visibles replicados al cliente.
-- No se intenta extraer información oculta del servidor; si no es visible, se muestra "Desconocido".
-- ============================================================
addSection("🎯 MM2", "ROLES Y ESTADO DE JUGADORES")

local roleEnabled = false
local roleRecords = {}
local rolePlayerAddedConn = nil
local rolePlayerRemovingConn = nil
local rolePending = {}

local rolePalette = {
    Murderer = {label = "ASESINO", fill = Color3.fromRGB(174, 58, 70), outline = Color3.fromRGB(255, 112, 124)},
    Sheriff = {label = "SHERIFF", fill = Color3.fromRGB(64, 119, 190), outline = Color3.fromRGB(132, 190, 255)},
    Unknown = {label = "DESCONOCIDO", fill = Color3.fromRGB(111, 113, 132), outline = Color3.fromRGB(190, 190, 207)},
}

local function disconnectList(list)
    for _, connection in ipairs(list or {}) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(list or {})
end

local function clearRoleVisual(character)
    if not character then return end
    local highlight = character:FindFirstChild("CVP_RoleHighlight")
    if highlight then highlight:Destroy() end
    local head = character:FindFirstChild("Head")
    local tag = head and head:FindFirstChild("CVP_RoleTag")
    if tag then tag:Destroy() end
end

local function classifyVisibleRole(player)
    -- Primero se comprueba un atributo/valor de rol que el propio juego
    -- haya replicado de forma explícita al cliente.
    local declaredRole = player:GetAttribute("Role") or player:GetAttribute("PlayerRole")
    if type(declaredRole) == "string" then
        local normalized = string.lower(declaredRole)
        if string.find(normalized, "murder", 1, true) or string.find(normalized, "assassin", 1, true) then
            return "Murderer"
        elseif string.find(normalized, "sheriff", 1, true) or string.find(normalized, "police", 1, true) then
            return "Sheriff"
        end
    end
    local roleValue = player:FindFirstChild("Role")
    if roleValue and (roleValue:IsA("StringValue") or roleValue:IsA("IntValue")) then
        local valueText = string.lower(tostring(roleValue.Value))
        if string.find(valueText, "murder", 1, true) or string.find(valueText, "assassin", 1, true) then
            return "Murderer"
        elseif string.find(valueText, "sheriff", 1, true) or string.find(valueText, "police", 1, true) then
            return "Sheriff"
        end
    end

    local hasKnife, hasGun = false, false
    local function inspect(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local itemName = string.lower(item.Name)
                if string.find(itemName, "knife", 1, true) or string.find(itemName, "blade", 1, true) then
                    hasKnife = true
                elseif string.find(itemName, "gun", 1, true) or string.find(itemName, "revolver", 1, true) then
                    hasGun = true
                end
            end
        end
    end
    inspect(player:FindFirstChildOfClass("Backpack"))
    inspect(player.Character)
    if hasKnife then return "Murderer" end
    if hasGun then return "Sheriff" end
    return "Unknown"
end

local function updateRoleVisual(player)
    if not roleEnabled or not player or not player.Parent then return end
    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local role = classifyVisibleRole(player)
    local palette = rolePalette[role] or rolePalette.Unknown

    local highlight = character:FindFirstChild("CVP_RoleHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "CVP_RoleHighlight"
        highlight.Adornee = character
        highlight.Parent = character
    end
    highlight.FillColor = palette.fill
    highlight.OutlineColor = palette.outline
    highlight.FillTransparency = role == "Unknown" and 0.90 or 0.78
    highlight.OutlineTransparency = 0.12
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded

    local tag = head:FindFirstChild("CVP_RoleTag")
    if not tag then
        tag = Instance.new("BillboardGui")
        tag.Name = "CVP_RoleTag"
        tag.Size = UDim2.new(0, 154, 0, 28)
        tag.StudsOffset = Vector3.new(0, 2.65, 0)
        tag.AlwaysOnTop = false
        tag.MaxDistance = 180
        tag.Adornee = head
        tag.Parent = head
        local label = Instance.new("TextLabel")
        label.Name = "RoleText"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextStrokeTransparency = 0.45
        label.TextStrokeColor3 = Color3.fromRGB(12, 12, 18)
        label.Parent = tag
    end
    local label = tag:FindFirstChild("RoleText")
    if label then
        label.Text = player.DisplayName .. " · " .. palette.label
        label.TextColor3 = palette.outline
    end
end

local function scheduleRoleUpdate(player)
    if not roleEnabled or rolePending[player] then return end
    rolePending[player] = true
    task.delay(0.12, function()
        rolePending[player] = nil
        if roleEnabled then
            pcall(updateRoleVisual, player)
        end
    end)
end

local function watchRolePlayer(player)
    if not roleEnabled or roleRecords[player] then return end
    local record = {connections = {}, characterConnections = {}, backpackConnections = {}}
    roleRecords[player] = record

    local function watchBackpack(backpack)
        disconnectList(record.backpackConnections)
        if not backpack then return end
        table.insert(record.backpackConnections, backpack.ChildAdded:Connect(function()
            scheduleRoleUpdate(player)
        end))
        table.insert(record.backpackConnections, backpack.ChildRemoved:Connect(function()
            scheduleRoleUpdate(player)
        end))
    end

    local function watchCharacter(character)
        disconnectList(record.characterConnections)
        if not character then return end
        table.insert(record.characterConnections, character.ChildAdded:Connect(function()
            scheduleRoleUpdate(player)
        end))
        table.insert(record.characterConnections, character.ChildRemoved:Connect(function()
            scheduleRoleUpdate(player)
        end))
        task.delay(0.2, function()
            scheduleRoleUpdate(player)
        end)
    end

    table.insert(record.connections, player.CharacterAdded:Connect(watchCharacter))
    table.insert(record.connections, player:GetAttributeChangedSignal("Role"):Connect(function()
        scheduleRoleUpdate(player)
    end))
    table.insert(record.connections, player:GetAttributeChangedSignal("PlayerRole"):Connect(function()
        scheduleRoleUpdate(player)
    end))
    local existingRoleValue = player:FindFirstChild("Role")
    if existingRoleValue and (existingRoleValue:IsA("StringValue") or existingRoleValue:IsA("IntValue")) then
        table.insert(record.connections, existingRoleValue.Changed:Connect(function()
            scheduleRoleUpdate(player)
        end))
    end
    table.insert(record.connections, player.ChildAdded:Connect(function(child)
        if child.Name == "Role" and (child:IsA("StringValue") or child:IsA("IntValue")) then
            table.insert(record.connections, child.Changed:Connect(function()
                scheduleRoleUpdate(player)
            end))
            scheduleRoleUpdate(player)
        end
    end))
    table.insert(record.connections, player.CharacterRemoving:Connect(function(character)
        clearRoleVisual(character)
        disconnectList(record.characterConnections)
    end))
    table.insert(record.connections, player.ChildAdded:Connect(function(child)
        if child:IsA("Backpack") or child.Name == "Backpack" then
            watchBackpack(child)
            scheduleRoleUpdate(player)
        end
    end))
    table.insert(record.connections, player.ChildRemoved:Connect(function(child)
        if child.Name == "Backpack" then
            disconnectList(record.backpackConnections)
            scheduleRoleUpdate(player)
        end
    end))

    watchBackpack(player:FindFirstChildOfClass("Backpack"))
    if player.Character then watchCharacter(player.Character) end
end

local function stopRoleDetection()
    roleEnabled = false
    if rolePlayerAddedConn then rolePlayerAddedConn:Disconnect() rolePlayerAddedConn = nil end
    if rolePlayerRemovingConn then rolePlayerRemovingConn:Disconnect() rolePlayerRemovingConn = nil end
    for player, record in pairs(roleRecords) do
        disconnectList(record.connections)
        disconnectList(record.characterConnections)
        disconnectList(record.backpackConnections)
        clearRoleVisual(player.Character)
    end
    table.clear(roleRecords)
    table.clear(rolePending)
end

addToggle("🎯 MM2", "Detector de roles visibles", "🎭", function(enabled)
    if not enabled then
        stopRoleDetection()
        return
    end
    stopRoleDetection()
    roleEnabled = true
    for _, player in ipairs(Players:GetPlayers()) do
        watchRolePlayer(player)
    end
    rolePlayerAddedConn = Players.PlayerAdded:Connect(watchRolePlayer)
    rolePlayerRemovingConn = Players.PlayerRemoving:Connect(function(player)
        local record = roleRecords[player]
        if record then
            disconnectList(record.connections)
            disconnectList(record.characterConnections)
            disconnectList(record.backpackConnections)
            roleRecords[player] = nil
        end
        clearRoleVisual(player.Character)
        rolePending[player] = nil
    end)
    notify("Detector activado: usa datos de rol o armas visibles", THEME.accent)
end, Color3.fromRGB(184, 93, 111))

addAction("🎯 MM2", "Actualizar roles visibles", "↻", function()
    if not roleEnabled then
        notify("Activa primero el detector de roles", THEME.mutedText)
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        scheduleRoleUpdate(player)
    end
    notify("Actualizando datos visibles de roles", THEME.accent)
end)

addSection("🎯 MM2", "DETECCIÓN DE PROXIMIDAD")
local nearEnabled = false
local nearRange = 50
local nearConnection = nil
local nearPlayerRemovingConnection = nil
local nearAccumulator = 0

local function clearNearVisual(character)
    if not character then return end
    local highlight = character:FindFirstChild("CVP_NearHighlight")
    if highlight then highlight:Destroy() end
    local head = character:FindFirstChild("Head")
    local tag = head and head:FindFirstChild("CVP_NearTag")
    if tag then tag:Destroy() end
end

local function attachNearVisual(player, character, distance)
    local head = character:FindFirstChild("Head")
    if not head then return end
    local highlight = character:FindFirstChild("CVP_NearHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "CVP_NearHighlight"
        highlight.Adornee = character
        highlight.Parent = character
    end
    highlight.FillColor = Color3.fromRGB(174, 139, 205)
    highlight.OutlineColor = Color3.fromRGB(220, 194, 246)
    highlight.FillTransparency = 0.90
    highlight.OutlineTransparency = 0.20
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded

    local tag = head:FindFirstChild("CVP_NearTag")
    if not tag then
        tag = Instance.new("BillboardGui")
        tag.Name = "CVP_NearTag"
        tag.Size = UDim2.new(0, 140, 0, 22)
        tag.StudsOffset = Vector3.new(0, 1.9, 0)
        tag.AlwaysOnTop = false
        tag.MaxDistance = nearRange + 30
        tag.Adornee = head
        tag.Parent = head
        local label = Instance.new("TextLabel")
        label.Name = "DistanceText"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 10
        label.TextStrokeTransparency = 0.4
        label.TextStrokeColor3 = Color3.fromRGB(10, 10, 16)
        label.TextColor3 = Color3.fromRGB(218, 200, 238)
        label.Parent = tag
    end
    tag.MaxDistance = nearRange + 30
    local label = tag:FindFirstChild("DistanceText")
    if label then
        label.Text = string.format("%s · %d studs", player.DisplayName, math.floor(distance + 0.5))
    end
end

addSlider("🎯 MM2", "Radio de proximidad", 15, 150, nearRange, 5,
    function(value) return tostring(math.floor(value)) .. " studs" end,
    function(value) nearRange = value end)

addToggle("🎯 MM2", "Detectar jugadores cercanos", "📡", function(enabled)
    nearEnabled = enabled
    if nearConnection then nearConnection:Disconnect() nearConnection = nil end
    if nearPlayerRemovingConnection then nearPlayerRemovingConnection:Disconnect() nearPlayerRemovingConnection = nil end
    if not enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            clearNearVisual(player.Character)
        end
        return
    end
    nearAccumulator = 0
    nearPlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        clearNearVisual(player.Character)
    end)
    nearConnection = RunService.Heartbeat:Connect(function(dt)
        nearAccumulator = nearAccumulator + dt
        if nearAccumulator < 0.20 then return end
        nearAccumulator = 0

        local myCharacter = LP.Character
        local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        if not myRoot then
            for _, player in ipairs(Players:GetPlayers()) do clearNearVisual(player.Character) end
            return
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP then
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then
                    local distance = (root.Position - myRoot.Position).Magnitude
                    if distance <= nearRange then
                        attachNearVisual(player, character, distance)
                    else
                        clearNearVisual(character)
                    end
                else
                    clearNearVisual(character)
                end
            end
        end
    end)
    notify("Proximidad activada · radio " .. tostring(nearRange) .. " studs", THEME.accent)
end, Color3.fromRGB(177, 145, 205))

addSection("🎯 MM2", "MONEDAS Y EFECTOS DE MOVIMIENTO")
local coinEnabled = false
local coinConnection = nil
local coinVisuals = {}

local function attachCoinVisual(object)
    if not coinEnabled or not object or not object.Parent then return end
    if not string.find(string.lower(object.Name), "coin", 1, true) then return end
    if not (object:IsA("BasePart") or object:IsA("Model")) then return end
    if object:FindFirstChild("CVP_CoinHighlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "CVP_CoinHighlight"
    highlight.Adornee = object
    highlight.FillColor = Color3.fromRGB(222, 180, 103)
    highlight.OutlineColor = Color3.fromRGB(255, 222, 157)
    highlight.FillTransparency = 0.78
    highlight.OutlineTransparency = 0.12
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = object
    table.insert(coinVisuals, highlight)

    local lightPart = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart", true)
    if lightPart and not lightPart:FindFirstChild("CVP_CoinLight") then
        local light = Instance.new("PointLight")
        light.Name = "CVP_CoinLight"
        light.Color = Color3.fromRGB(235, 194, 121)
        light.Brightness = 0.8
        light.Range = 7
        light.Shadows = false
        light.Parent = lightPart
        table.insert(coinVisuals, light)
    end
end

addToggle("🎯 MM2", "Monedas resaltadas", "🪙", function(enabled)
    coinEnabled = enabled
    if coinConnection then coinConnection:Disconnect() coinConnection = nil end
    if not enabled then
        for _, object in ipairs(coinVisuals) do
            if object and object.Parent then object:Destroy() end
        end
        table.clear(coinVisuals)
        return
    end
    for _, object in ipairs(Workspace:GetDescendants()) do
        attachCoinVisual(object)
    end
    coinConnection = Workspace.DescendantAdded:Connect(function(object)
        if string.find(string.lower(object.Name), "coin", 1, true) then
            task.defer(attachCoinVisual, object)
        end
    end)
end, Color3.fromRGB(222, 180, 103))

local jumpEnabled = false
local jumpPlayerConnection = nil
local jumpCharacterConnections = {}
local function emitMovementBurst(position, landed)
    local anchor = Instance.new("Part")
    anchor.Name = "CVP_MovementBurst"
    anchor.Size = Vector3.new(0.15, 0.15, 0.15)
    anchor.Transparency = 1
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CanTouch = false
    anchor.CanQuery = false
    anchor.CastShadow = false
    anchor.CFrame = CFrame.new(position)
    anchor.Parent = Workspace
    local attachment = Instance.new("Attachment")
    attachment.Parent = anchor
    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://243660364"
    emitter.Rate = 0
    emitter.Lifetime = landed and NumberRange.new(0.35, 0.65) or NumberRange.new(0.35, 0.7)
    emitter.Speed = landed and NumberRange.new(2, 5) or NumberRange.new(2.5, 6)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, landed and 0.32 or 0.28),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Color = landed
        and ColorSequence.new(Color3.fromRGB(203, 180, 224), Color3.fromRGB(245, 235, 255))
        or ColorSequence.new(Color3.fromRGB(162, 174, 226), Color3.fromRGB(238, 240, 255))
    emitter.LightEmission = 0.45
    emitter.Parent = attachment
    emitter:Emit(landed and 10 or 12)
    task.delay(1.0, function()
        if anchor and anchor.Parent then anchor:Destroy() end
    end)
end

local function attachJumpCharacter(character)
    disconnectList(jumpCharacterConnections)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not root or not jumpEnabled then return end
    table.insert(jumpCharacterConnections, humanoid.Jumping:Connect(function(active)
        if active and jumpEnabled and root.Parent then
            emitMovementBurst(root.Position - Vector3.new(0, 2.4, 0), false)
        end
    end))
    local wasFalling = false
    table.insert(jumpCharacterConnections, humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Freefall then
            wasFalling = true
        elseif newState == Enum.HumanoidStateType.Landed and wasFalling then
            wasFalling = false
            if jumpEnabled and root.Parent then
                emitMovementBurst(root.Position - Vector3.new(0, 2.4, 0), true)
            end
        elseif newState == Enum.HumanoidStateType.Running or newState == Enum.HumanoidStateType.RunningNoPhysics then
            wasFalling = false
        end
    end))
end

addToggle("🎯 MM2", "Partículas de salto y aterrizaje", "🦘", function(enabled)
    jumpEnabled = enabled
    disconnectList(jumpCharacterConnections)
    if jumpPlayerConnection then jumpPlayerConnection:Disconnect() jumpPlayerConnection = nil end
    if not enabled then return end
    if LP.Character then task.spawn(attachJumpCharacter, LP.Character) end
    jumpPlayerConnection = LP.CharacterAdded:Connect(function(character)
        task.spawn(attachJumpCharacter, character)
    end)
end, Color3.fromRGB(162, 174, 226))

local stepsEnabled = false
local stepConnection = nil
local stepAccumulator = 0
local lastStepPosition = nil
addToggle("🎯 MM2", "Rastro de pasos", "👣", function(enabled)
    stepsEnabled = enabled
    if stepConnection then stepConnection:Disconnect() stepConnection = nil end
    stepAccumulator = 0
    lastStepPosition = nil
    if not enabled then return end
    stepConnection = RunService.Heartbeat:Connect(function(dt)
        stepAccumulator = stepAccumulator + dt
        if stepAccumulator < 0.11 then return end
        stepAccumulator = 0
        local character = LP.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root or humanoid.MoveDirection.Magnitude < 0.12 then
            lastStepPosition = root and root.Position or nil
            return
        end
        local position = root.Position
        if not lastStepPosition or (position - lastStepPosition).Magnitude >= 2.2 then
            local foot = Instance.new("Part")
            foot.Name = "CVP_Footstep"
            foot.Size = Vector3.new(0.48, 0.06, 0.72)
            foot.CFrame = CFrame.new(position.X, position.Y - 2.65, position.Z)
            foot.Color = Color3.fromRGB(154, 139, 181)
            foot.Material = Enum.Material.SmoothPlastic
            foot.Transparency = 0.28
            foot.Anchored = true
            foot.CanCollide = false
            foot.CanTouch = false
            foot.CanQuery = false
            foot.CastShadow = false
            foot.Parent = Workspace
            TweenService:Create(foot, TweenInfo.new(1.0), {
                Transparency = 1,
                Size = Vector3.new(0.12, 0.03, 0.18),
            }):Play()
            task.delay(1.05, function()
                if foot and foot.Parent then foot:Destroy() end
            end)
            lastStepPosition = position
        end
    end)
end, Color3.fromRGB(154, 139, 181))

addSection("🎯 MM2", "COSMÉTICOS DE ARMAS")
local weaponGlowEnabled = false
local weaponGlowConnection = nil
addToggle("🎯 MM2", "Brillo suave de arma equipada", "🔦", function(enabled)
    weaponGlowEnabled = enabled
    if weaponGlowConnection then weaponGlowConnection:Disconnect() weaponGlowConnection = nil end
    local function clearGlow()
        local containers = {LP.Character, LP:FindFirstChildOfClass("Backpack")}
        for _, container in ipairs(containers) do
            if container then
                for _, object in ipairs(container:GetDescendants()) do
                    if object.Name == "CVP_WeaponGlow" then object:Destroy() end
                end
            end
        end
    end
    if not enabled then
        clearGlow()
        return
    end
    local accumulator = 0
    weaponGlowConnection = RunService.Heartbeat:Connect(function(dt)
        accumulator = accumulator + dt
        if accumulator < 0.25 then return end
        accumulator = 0
        local character = LP.Character
        if not character then return end
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    local light = handle:FindFirstChild("CVP_WeaponGlow")
                    if not light then
                        light = Instance.new("PointLight")
                        light.Name = "CVP_WeaponGlow"
                        light.Range = 8
                        light.Brightness = 0.75
                        light.Shadows = false
                        light.Parent = handle
                    end
                    local name = string.lower(tool.Name)
                    light.Color = string.find(name, "knife", 1, true)
                        and Color3.fromRGB(197, 104, 118)
                        or (string.find(name, "gun", 1, true) and Color3.fromRGB(113, 157, 218) or Color3.fromRGB(180, 166, 207))
                end
            end
        end
    end)
end, Color3.fromRGB(180, 166, 207))

local weaponSkinEnabled = false
local weaponSkinConnection = nil
local originalWeaponParts = setmetatable({}, {__mode = "k"})
local function restoreWeaponSkin()
    for part, data in pairs(originalWeaponParts) do
        if part and part.Parent then
            pcall(function()
                part.Color = data.Color
                part.Material = data.Material
            end)
        end
        originalWeaponParts[part] = nil
    end
end
addToggle("🎯 MM2", "Skin grafito para armas", "◈", function(enabled)
    weaponSkinEnabled = enabled
    if weaponSkinConnection then weaponSkinConnection:Disconnect() weaponSkinConnection = nil end
    if not enabled then
        restoreWeaponSkin()
        return
    end
    local accumulator = 0
    weaponSkinConnection = RunService.Heartbeat:Connect(function(dt)
        accumulator = accumulator + dt
        if accumulator < 0.35 then return end
        accumulator = 0
        local character = LP.Character
        if not character then return end
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                for _, part in ipairs(tool:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not originalWeaponParts[part] then
                            originalWeaponParts[part] = {Color = part.Color, Material = part.Material}
                        end
                        part.Color = Color3.fromRGB(104, 108, 126)
                        part.Material = Enum.Material.SmoothPlastic
                    end
                end
            end
        end
    end)
end, Color3.fromRGB(137, 143, 165))

local weaponTrailEnabled = false
local weaponTrailConnection = nil
local function clearWeaponTrails()
    local containers = {LP.Character, LP:FindFirstChildOfClass("Backpack")}
    for _, container in ipairs(containers) do
        if container then
            for _, object in ipairs(container:GetDescendants()) do
                if object.Name == "CVP_WeaponTrail" then object:Destroy() end
            end
        end
    end
end
addToggle("🎯 MM2", "Estela de partículas en arma", "✧", function(enabled)
    weaponTrailEnabled = enabled
    if weaponTrailConnection then weaponTrailConnection:Disconnect() weaponTrailConnection = nil end
    if not enabled then
        clearWeaponTrails()
        return
    end
    local accumulator = 0
    weaponTrailConnection = RunService.Heartbeat:Connect(function(dt)
        accumulator = accumulator + dt
        if accumulator < 0.35 then return end
        accumulator = 0
        local character = LP.Character
        if not character then return end
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") and not handle:FindFirstChild("CVP_WeaponTrail") then
                    local emitter = Instance.new("ParticleEmitter")
                    emitter.Name = "CVP_WeaponTrail"
                    emitter.Texture = "rbxassetid://243660364"
                    emitter.Rate = 9
                    emitter.Lifetime = NumberRange.new(0.25, 0.5)
                    emitter.Speed = NumberRange.new(0.25, 1.2)
                    emitter.SpreadAngle = Vector2.new(180, 180)
                    emitter.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.18),
                        NumberSequenceKeypoint.new(1, 0),
                    })
                    emitter.Color = ColorSequence.new(Color3.fromRGB(167, 153, 198), Color3.fromRGB(224, 215, 242))
                    emitter.LightEmission = 0.25
                    emitter.Parent = handle
                end
            end
        end
    end)
end, Color3.fromRGB(167, 153, 198))

addAction("🎯 MM2", "Contar monedas visibles", "∑", function()
    local count = 0
    local seenCoins = {}
    for _, object in ipairs(Workspace:GetDescendants()) do
        if string.find(string.lower(object.Name), "coin", 1, true) and (object:IsA("BasePart") or object:IsA("Model")) then
            local coinRoot = object:IsA("Model") and object or object:FindFirstAncestorOfClass("Model") or object
            if not seenCoins[coinRoot] then
                seenCoins[coinRoot] = true
                count += 1
            end
        end
    end
    notify("Objetos de moneda visibles: " .. tostring(count), THEME.accent)
end)

-- Fogonazo y trazadora local: efecto visual; no altera el disparo del juego.
local gunVisualEnabled = false
local gunVisualScanConnection = nil
local gunActivatedConnections = {}
local gunConnectedTools = setmetatable({}, {__mode = "k"})
local function showLocalGunShot(handle)
    if not handle or not handle.Parent then return end
    local flash = Instance.new("Part")
    flash.Name = "CVP_LocalMuzzleFlash"
    flash.Shape = Enum.PartType.Ball
    flash.Size = Vector3.new(0.45, 0.45, 0.45)
    flash.CFrame = handle.CFrame * CFrame.new(0, 0, -0.7)
    flash.Color = Color3.fromRGB(222, 190, 139)
    flash.Material = Enum.Material.Neon
    flash.Anchored = true
    flash.CanCollide = false
    flash.CanTouch = false
    flash.CanQuery = false
    flash.CastShadow = false
    flash.Parent = Workspace
    local light = Instance.new("PointLight")
    light.Color = flash.Color
    light.Range = 6
    light.Brightness = 1.2
    light.Parent = flash
    TweenService:Create(flash, TweenInfo.new(0.14), {
        Size = Vector3.new(1.15, 1.15, 1.15),
        Transparency = 1,
    }):Play()
    task.delay(0.16, function()
        if flash and flash.Parent then flash:Destroy() end
    end)

    local camera = Workspace.CurrentCamera
    if not camera then return end
    local startPosition = handle.Position
    local targetPosition = startPosition + camera.CFrame.LookVector * 70
    local distance = (targetPosition - startPosition).Magnitude
    if distance < 1 then return end
    local tracer = Instance.new("Part")
    tracer.Name = "CVP_LocalTracer"
    tracer.Size = Vector3.new(0.055, 0.055, distance)
    tracer.CFrame = CFrame.lookAt(startPosition, targetPosition) * CFrame.new(0, 0, -distance / 2)
    tracer.Color = Color3.fromRGB(221, 195, 155)
    tracer.Material = Enum.Material.Neon
    tracer.Transparency = 0.18
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.CanTouch = false
    tracer.CanQuery = false
    tracer.CastShadow = false
    tracer.Parent = Workspace
    TweenService:Create(tracer, TweenInfo.new(0.22), {Transparency = 1}):Play()
    task.delay(0.24, function()
        if tracer and tracer.Parent then tracer:Destroy() end
    end)
end

addToggle("🎯 MM2", "Fogonazo y trazadora local", "➤", function(enabled)
    gunVisualEnabled = enabled
    if gunVisualScanConnection then gunVisualScanConnection:Disconnect() gunVisualScanConnection = nil end
    for _, connection in ipairs(gunActivatedConnections) do
        if connection and connection.Connected then connection:Disconnect() end
    end
    table.clear(gunActivatedConnections)
    gunConnectedTools = setmetatable({}, {__mode = "k"})
    if not enabled then return end
    local accumulator = 0
    gunVisualScanConnection = RunService.Heartbeat:Connect(function(dt)
        accumulator = accumulator + dt
        if accumulator < 0.25 then return end
        accumulator = 0
        local character = LP.Character
        if not character then return end
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                local name = string.lower(tool.Name)
                if (string.find(name, "gun", 1, true) or string.find(name, "revolver", 1, true)) and not gunConnectedTools[tool] then
                    gunConnectedTools[tool] = true
                    table.insert(gunActivatedConnections, tool.Activated:Connect(function()
                        if not gunVisualEnabled then return end
                        showLocalGunShot(tool:FindFirstChild("Handle"))
                    end))
                end
            end
        end
    end)
end, Color3.fromRGB(221, 195, 155))

-- Estilo de kill feed limitado a los textos que ya existan en PlayerGui.
local killFeedEnabled = false
local killFeedConnections = {}
local killFeedOriginal = setmetatable({}, {__mode = "k"})
local function isKillFeedText(label)
    local node = label.Parent
    for _ = 1, 3 do
        if not node then break end
        local name = string.lower(node.Name)
        if string.find(name, "kill", 1, true) or string.find(name, "feed", 1, true) then
            return true
        end
        node = node.Parent
    end
    return false
end
local function styleKillFeedObject(object)
    if not killFeedEnabled or not (object:IsA("TextLabel") or object:IsA("TextButton")) or not isKillFeedText(object) then return end
    if not killFeedOriginal[object] then
        killFeedOriginal[object] = {
            TextColor3 = object.TextColor3,
            TextStrokeColor3 = object.TextStrokeColor3,
            TextStrokeTransparency = object.TextStrokeTransparency,
            Font = object.Font,
            TextSize = object.TextSize,
        }
    end
    object.TextColor3 = Color3.fromRGB(241, 229, 255)
    object.TextStrokeColor3 = Color3.fromRGB(39, 25, 62)
    object.TextStrokeTransparency = 0.20
    object.Font = Enum.Font.GothamBold
    object.TextSize = math.clamp(object.TextSize, 11, 16)
end
addToggle("🎯 MM2", "Estilo de kill feed", "▤", function(enabled)
    killFeedEnabled = enabled
    if not enabled then
        disconnectList(killFeedConnections)
        for label, original in pairs(killFeedOriginal) do
            if label and label.Parent then
                pcall(function()
                    label.TextColor3 = original.TextColor3
                    label.TextStrokeColor3 = original.TextStrokeColor3
                    label.TextStrokeTransparency = original.TextStrokeTransparency
                    label.Font = original.Font
                    label.TextSize = original.TextSize
                end)
            end
            killFeedOriginal[label] = nil
        end
        return
    end
    for _, object in ipairs(PG:GetDescendants()) do styleKillFeedObject(object) end
    table.insert(killFeedConnections, PG.DescendantAdded:Connect(function(object)
        task.defer(styleKillFeedObject, object)
    end))
end, Color3.fromRGB(178, 156, 203))

addSection("🎯 MM2", "EFECTOS LOCALES DE RONDA")
local deathEffectEnabled = false
local deathCharacterConnection = nil
local deathHumanoidConnection = nil
local deathEffectColor = Color3.fromRGB(176, 145, 224)
local function makeDeathEffect(position)
    -- Anillo de cristal suave más partículas pequeñas; solo aparece en el cliente local.
    local ring = Instance.new("Part")
    ring.Name = "CVP_DeathGlassRing"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.10, 0.7, 0.7)
    ring.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    ring.Color = deathEffectColor
    ring.Material = Enum.Material.Neon
    ring.Transparency = 0.38
    ring.Anchored = true
    ring.CanCollide = false
    ring.CanTouch = false
    ring.CanQuery = false
    ring.CastShadow = false
    ring.Parent = Workspace
    TweenService:Create(ring, TweenInfo.new(0.72, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.06, 10, 10), Transparency = 1,
    }):Play()
    task.delay(0.76, function() if ring and ring.Parent then ring:Destroy() end end)

    for index = 1, 22 do
        local particle = Instance.new("Part")
        particle.Name = "CVP_DeathSpark"
        particle.Shape = Enum.PartType.Ball
        particle.Size = Vector3.new(0.28, 0.28, 0.28)
        particle.Position = position
        particle.Color = deathEffectColor:Lerp(Color3.fromRGB(245, 235, 255), math.random(10, 55) / 100)
        particle.Material = Enum.Material.SmoothPlastic
        particle.Transparency = 0.10
        particle.Anchored = true
        particle.CanCollide = false
        particle.CanTouch = false
        particle.CanQuery = false
        particle.CastShadow = false
        particle.Parent = Workspace
        TweenService:Create(particle, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = position + Vector3.new(math.random(-7, 7), math.random(2, 8), math.random(-7, 7)),
            Transparency = 1,
            Size = Vector3.new(0.035, 0.035, 0.035),
        }):Play()
        task.delay(0.95, function()
            if particle and particle.Parent then particle:Destroy() end
        end)
    end
end

addToggle("🎯 MM2", "Efecto al reaparecer/ser eliminado", "✦", function(enabled)
    deathEffectEnabled = enabled
    if deathHumanoidConnection then deathHumanoidConnection:Disconnect() deathHumanoidConnection = nil end
    if deathCharacterConnection then deathCharacterConnection:Disconnect() deathCharacterConnection = nil end
    if not enabled then return end
    local function attachDeath(char)
        if deathHumanoidConnection then deathHumanoidConnection:Disconnect() deathHumanoidConnection = nil end
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        deathHumanoidConnection = humanoid.Died:Connect(function()
            local root = char:FindFirstChild("HumanoidRootPart")
            if deathEffectEnabled and root then makeDeathEffect(root.Position) end
        end)
    end
    if LP.Character then task.spawn(attachDeath, LP.Character) end
    deathCharacterConnection = LP.CharacterAdded:Connect(attachDeath)
end, Color3.fromRGB(156, 139, 190))
addAction("🎯 MM2", "Color de eliminación · Amatista", "✧", function()
    deathEffectColor = Color3.fromRGB(176,145,224)
    notify("Efecto de eliminación · Amatista",THEME.accent)
end)
addAction("🎯 MM2", "Color de eliminación · Zafiro", "◉", function()
    deathEffectColor = Color3.fromRGB(125,176,235)
    notify("Efecto de eliminación · Zafiro",THEME.accent)
end)
addAction("🎯 MM2", "Color de eliminación · Rosa", "✿", function()
    deathEffectColor = Color3.fromRGB(224,139,185)
    notify("Efecto de eliminación · Rosa",THEME.accent)
end)

local bombEffectEnabled = false
local bombConnection = nil
addToggle("🎯 MM2", "Ondas visuales de bomba", "◉", function(enabled)
    bombEffectEnabled = enabled
    if bombConnection then bombConnection:Disconnect() bombConnection = nil end
    if not enabled then return end
    local function getPosition(object)
        if object:IsA("BasePart") then return object.Position end
        if object:IsA("Model") then
            local ok, pivot = pcall(function() return object:GetPivot() end)
            if ok then return pivot.Position end
        end
        return nil
    end
    bombConnection = Workspace.DescendantAdded:Connect(function(object)
        if not bombEffectEnabled or not string.find(string.lower(object.Name), "bomb", 1, true) then return end
        local position = getPosition(object)
        if not position then return end
        local wave = Instance.new("Part")
        wave.Name = "CVP_BombWave"
        wave.Shape = Enum.PartType.Ball
        wave.Size = Vector3.new(1, 1, 1)
        wave.Position = position
        wave.Color = Color3.fromRGB(190, 153, 111)
        wave.Material = Enum.Material.Glass
        wave.Transparency = 0.68
        wave.Anchored = true
        wave.CanCollide = false
        wave.CanTouch = false
        wave.CanQuery = false
        wave.CastShadow = false
        wave.Parent = Workspace
        TweenService:Create(wave, TweenInfo.new(0.9), {
            Size = Vector3.new(22, 22, 22),
            Transparency = 1,
        }):Play()
        task.delay(0.95, function()
            if wave and wave.Parent then wave:Destroy() end
        end)
    end)
end, Color3.fromRGB(190, 153, 111))

addSection("🎯 MM2", "AJUSTES Y NOTAS")
addAction("🎯 MM2", "Desactivar y limpiar módulos MM2", "⌫", function()
    stopRoleDetection()
    nearEnabled = false
    if nearConnection then nearConnection:Disconnect() nearConnection = nil end
    if nearPlayerRemovingConnection then nearPlayerRemovingConnection:Disconnect() nearPlayerRemovingConnection = nil end
    for _, player in ipairs(Players:GetPlayers()) do clearNearVisual(player.Character) end

    coinEnabled = false
    if coinConnection then coinConnection:Disconnect() coinConnection = nil end
    for _, object in ipairs(coinVisuals) do
        if object and object.Parent then object:Destroy() end
    end
    table.clear(coinVisuals)

    jumpEnabled = false
    if jumpPlayerConnection then jumpPlayerConnection:Disconnect() jumpPlayerConnection = nil end
    disconnectList(jumpCharacterConnections)
    stepsEnabled = false
    if stepConnection then stepConnection:Disconnect() stepConnection = nil end

    weaponGlowEnabled = false
    if weaponGlowConnection then weaponGlowConnection:Disconnect() weaponGlowConnection = nil end
    local weaponContainers = {LP.Character, LP:FindFirstChildOfClass("Backpack")}
    for _, container in ipairs(weaponContainers) do
        if container then
            for _, object in ipairs(container:GetDescendants()) do
                if object.Name == "CVP_WeaponGlow" or object.Name == "CVP_WeaponTrail" then
                    object:Destroy()
                end
            end
        end
    end
    weaponSkinEnabled = false
    if weaponSkinConnection then weaponSkinConnection:Disconnect() weaponSkinConnection = nil end
    restoreWeaponSkin()
    weaponTrailEnabled = false
    if weaponTrailConnection then weaponTrailConnection:Disconnect() weaponTrailConnection = nil end
    clearWeaponTrails()

    deathEffectEnabled = false
    if deathHumanoidConnection then deathHumanoidConnection:Disconnect() deathHumanoidConnection = nil end
    if deathCharacterConnection then deathCharacterConnection:Disconnect() deathCharacterConnection = nil end
    bombEffectEnabled = false
    if bombConnection then bombConnection:Disconnect() bombConnection = nil end
    gunVisualEnabled = false
    if gunVisualScanConnection then gunVisualScanConnection:Disconnect() gunVisualScanConnection = nil end
    for _, connection in ipairs(gunActivatedConnections) do
        if connection and connection.Connected then connection:Disconnect() end
    end
    table.clear(gunActivatedConnections)
    killFeedEnabled = false
    disconnectList(killFeedConnections)
    for label, original in pairs(killFeedOriginal) do
        if label and label.Parent then
            pcall(function()
                label.TextColor3 = original.TextColor3
                label.TextStrokeColor3 = original.TextStrokeColor3
                label.TextStrokeTransparency = original.TextStrokeTransparency
            end)
        end
        killFeedOriginal[label] = nil
    end

    for _, label in ipairs({
        "Detector de roles visibles", "Detectar jugadores cercanos", "Monedas resaltadas",
        "Partículas de salto y aterrizaje", "Rastro de pasos", "Brillo suave de arma equipada",
        "Skin grafito para armas", "Estela de partículas en arma", "Fogonazo y trazadora local",
        "Estilo de kill feed", "Efecto al reaparecer/ser eliminado", "Ondas visuales de bomba",
    }) do
        if toggleRegistry[label] then toggleRegistry[label](false) end
    end
    notify("Módulos MM2 desactivados y limpiados", THEME.mutedText)
end)

-- Fin de la pestaña MM2 restaurada.


-- UTILIDADES PERSONALES PARA MM2.
addSection("🎮 Extras", "MM2 · UTILIDADES PERSONALES")
local timerRunning = false
local timerElapsed = 0
local timerConnection = nil
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0, 30)
timerLabel.Position = UDim2.new(0, 0, 0, tabContents["🎮 Extras"].CanvasSize.Y.Offset)
timerLabel.BackgroundColor3 = THEME.panel
 timerLabel.BorderSizePixel = 0
timerLabel.Text = "Cronómetro: 00:00.0"
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextSize = 12
timerLabel.TextColor3 = THEME.text
timerLabel:SetAttribute("ThemePanel", true)
timerLabel:SetAttribute("ThemeText", true)
timerLabel.Parent = tabContents["🎮 Extras"]
Instance.new("UICorner", timerLabel).CornerRadius = UDim.new(0, 8)
tabContents["🎮 Extras"].CanvasSize = UDim2.new(0, 0, 0, timerLabel.Position.Y.Offset + 36)
-- El HUD flotante se activa desde Ajustes/Extras y puede moverse con mouse o tacto.
timerLabel.Parent = gui
timerLabel.Size = UDim2.new(0, 178, 0, 34)
timerLabel.AnchorPoint = Vector2.new(1, 0)
timerLabel.Position = UDim2.new(1, -16, 0, 104)
timerLabel.Visible = false
timerLabel.ZIndex = 30
timerLabel.BackgroundTransparency = 0.12
local function formatElapsed(seconds)
    local minutes = math.floor(seconds / 60)
    local wholeSeconds = math.floor(seconds % 60)
    local tenths = math.floor((seconds % 1) * 10)
    return string.format("%02d:%02d.%d", minutes, wholeSeconds, tenths)
end
addToggle("🎮 Extras", "Cronómetro personal", "⏱️", function(enabled)
    timerRunning = enabled
    if timerConnection then timerConnection:Disconnect() timerConnection = nil end
    if enabled then
        timerConnection = RunService.Heartbeat:Connect(function(dt)
            timerElapsed += dt
            if timerLabel and timerLabel.Parent then
                timerLabel.Text = "Cronómetro: " .. formatElapsed(timerElapsed)
            end
        end)
    end
end, THEME.accent)
addAction("🎮 Extras", "Reiniciar cronómetro", "↺", function()
    timerElapsed = 0
    if timerLabel and timerLabel.Parent then timerLabel.Text = "Cronómetro: 00:00.0" end
    notify("Cronómetro reiniciado", THEME.mutedText)
end)

local practicePoint = nil
addAction("🎮 Extras", "Guardar punto de práctica", "📍", function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        notify("No se encontró tu personaje", Color3.fromRGB(220, 145, 150))
        return
    end
    practicePoint = root.Position
    notify("Punto personal guardado", THEME.enabled)
end)
addAction("🎮 Extras", "Medir distancia al punto", "⌖", function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not practicePoint or not root then
        notify("Primero guarda un punto de práctica", Color3.fromRGB(220, 145, 150))
        return
    end
    local distance = (root.Position - practicePoint).Magnitude
    notify(string.format("Distancia a tu punto: %.1f studs", distance), THEME.accent)
end)
addAction("🎮 Extras", "Borrar punto de práctica", "✕", function()
    practicePoint = nil
    notify("Punto de práctica borrado", THEME.mutedText)
end)

-- ESTRELLAS ORBITANDO
local orbitParts = {}
local orbitConn = nil
addToggle("🎮 Extras", "Estrellas Orbitando", "🌟", function(s)
    if orbitConn then orbitConn:Disconnect() orbitConn = nil end
    for _, p in ipairs(orbitParts) do if p and p.Parent then p:Destroy() end end
    orbitParts = {}
    if not s then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for i = 1, 10 do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(0.4,0.4,0.4)
        p.Color = Color3.fromRGB(151, 149, 168)
        p.Material = Enum.Material.SmoothPlastic
        p.Anchored = true; p.CanCollide = false; p.CastShadow = false
        p.Parent = Workspace
        table.insert(orbitParts, {part=p, angle=i/10*math.pi*2, radius=4})
    end
    local t = 0
    orbitConn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        if hrp and hrp.Parent then
            for _, o in ipairs(orbitParts) do
                if o.part and o.part.Parent then
                    local a = t*2 + o.angle
                    local yOff = 2 + math.sin(t*1.5 + o.angle)*1.5
                    o.part.CFrame = hrp.CFrame * CFrame.new(
                        math.cos(a)*o.radius, yOff, math.sin(a)*o.radius)

                end
            end
        end
    end)
end, Color3.fromRGB(255,150,255))

-- ============================================================
-- ✦ PESTAÑA ANIM ✦
-- ============================================================

local animPackages = {
    Ninja = {name="Ninja", emoji="🥷", color=Color3.fromRGB(110,99,160),
        idle1="656117400", idle2="656118341", walk="656121766", run="656118852",
        jump="656117878", fall="656115606", climb="656114359", swim="656119721", swimidle="656121397"},
    Zombie = {name="Zombie", emoji="🧟", color=Color3.fromRGB(108,145,91),
        idle1="616007055", idle2="616007055", walk="616013277", run="616010382",
        jump="616005596", fall="616008714", climb="616004889", swim="616011038", swimidle="616011530"},
    Robot = {name="Robot", emoji="🤖", color=Color3.fromRGB(132,143,180),
        idle1="616088211", idle2="616089559", walk="616095330", run="616091570",
        jump="616090535", fall="616087089", climb="616086039", swim="616092998", swimidle="616094091"},
    Mage = {name="Mage", emoji="🧙", color=Color3.fromRGB(150,112,205),
        idle1="707742142", idle2="707855907", walk="707897309", run="707861613",
        jump="707853694", fall="707829716", climb="707826056", swim="707876443", swimidle="707894699"},
    Pirate = {name="Pirate", emoji="🏴‍☠️", color=Color3.fromRGB(174,126,88),
        idle1="750781874", idle2="750782770", walk="750785693", run="750783738",
        jump="750782230", fall="750780242", climb="750779899", swim="750784579", swimidle="750785176"},
    Astronaut = {name="Astronaut", emoji="👨‍🚀", color=Color3.fromRGB(154,164,204),
        idle1="891621366", idle2="1047759695", walk="891633237", run="891636393",
        jump="891627522", fall="891617961", climb="891609353", swim="891639666", swimidle="891663592"},
    Bubbly = {name="Bubbly", emoji="🫧", color=Color3.fromRGB(125,174,199),
        idle1="910004836", idle2="910009958", walk="910034870", run="910025107",
        jump="910016857", fall="910001910", climb="909997997", swim="910028158", swimidle="910030921"},
    Cartoony = {name="Cartoony", emoji="🎨", color=Color3.fromRGB(198,145,122),
        idle1="742637544", idle2="742638445", walk="742640026", run="742638842",
        jump="742637942", fall="742637151", climb="742636889", swim="742639220", swimidle="742639812"},
    Knight = {name="Knight", emoji="🛡️", color=Color3.fromRGB(151,146,171),
        idle1="657595757", idle2="657568135", walk="657552124", run="657564596",
        jump="658409194", fall="657600338", climb="658360781", swim="657560551", swimidle="657557095"},
    Levitation = {name="Levitation", emoji="☁️", color=Color3.fromRGB(155,147,200),
        idle1="616006778", idle2="616008087", walk="616013216", run="616010382",
        jump="616008936", fall="616005863", climb="616003713", swim="616011509", swimidle="616012453"},
    Stylish = {name="Stylish", emoji="🕶️", color=Color3.fromRGB(173,125,178),
        idle1="616136790", idle2="616138447", walk="616146177", run="616140816",
        jump="616139451", fall="616134815", climb="616133594", swim="616143378", swimidle="616144772"},
    Superhero = {name="Superhero", emoji="🦸", color=Color3.fromRGB(179,116,127),
        idle1="616111295", idle2="616113536", walk="616122287", run="616117076",
        jump="616115533", fall="616108001", climb="616104706", swim="616119360", swimidle="616120861"},
    Toy = {name="Toy", emoji="🧸", color=Color3.fromRGB(195,149,115),
        idle1="782841498", idle2="782845736", walk="782843345", run="782842708",
        jump="782847020", fall="782846423", climb="782843869", swim="782844582", swimidle="782845186"},
    Vampire = {name="Vampire", emoji="🦇", color=Color3.fromRGB(139,91,131),
        idle1="1083445855", idle2="1083450166", walk="1083473930", run="1083462077",
        jump="1083455352", fall="1083443587", climb="1083439238", swim="1083464683", swimidle="1083467779"},
    Werewolf = {name="Werewolf", emoji="🐺", color=Color3.fromRGB(137,140,151),
        idle1="1083195517", idle2="1083214717", walk="1083178339", run="1083216690",
        jump="1083218792", fall="1083189019", climb="1083182000", swim="1083222527", swimidle="1083225406"},
}

-- Guarda los IDs originales por cada instancia Animate (cada respawn puede crear otra).
local originalAnimIdsByAnimate = setmetatable({}, {__mode = "k"})
local function relativeAnimationPath(animation, root)
    local names = {}
    local current = animation
    while current and current ~= root do
        table.insert(names, 1, current.Name)
        current = current.Parent
    end
    return table.concat(names, "/")
end

local function captureOriginalAnimations(animate)
    if not animate then return nil end
    local saved = originalAnimIdsByAnimate[animate]
    if saved then return saved end
    saved = {}
    for _, item in ipairs(animate:GetDescendants()) do
        if item:IsA("Animation") then
            saved[relativeAnimationPath(item, animate)] = item.AnimationId
        end
    end
    originalAnimIdsByAnimate[animate] = saved
    return saved
end

local function setAnimId(animate, category, subName, id)
    if not animate or not id then return 0 end
    local cat = animate:FindFirstChild(category)
    if not cat then return 0 end

    local target = nil
    if subName then
        for _, item in ipairs(cat:GetDescendants()) do
            if item:IsA("Animation") and item.Name:lower() == tostring(subName):lower() then
                target = item
                break
            end
        end
    end

    if not target then
        local candidates = {}
        if cat:IsA("Animation") then table.insert(candidates, cat) end
        for _, item in ipairs(cat:GetDescendants()) do
            if item:IsA("Animation") then table.insert(candidates, item) end
        end
        if #candidates == 0 then return 0 end
        if category == "idle" and subName == "Animation2" and #candidates >= 2 then
            target = candidates[2]
        else
            target = candidates[1]
        end
    end

    local normalizedId = tostring(id)
    if not normalizedId:find("rbxassetid://", 1, true) then
        normalizedId = "rbxassetid://" .. normalizedId
    end
    local ok = pcall(function() target.AnimationId = normalizedId end)
    return ok and 1 or 0
end

local function restoreOriginalAnimations(animate)
    local saved = animate and originalAnimIdsByAnimate[animate]
    if not saved then return false end
    local restored = 0
    for _, item in ipairs(animate:GetDescendants()) do
        if item:IsA("Animation") then
            local originalId = saved[relativeAnimationPath(item, animate)]
            if originalId ~= nil then
                local ok = pcall(function() item.AnimationId = originalId end)
                if ok then restored += 1 end
            end
        end
    end
    return restored > 0
end

local currentPackage = "Default"
local applyingPackage = false
local function refreshCharacterAnimator(char, animate)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if animator then
        -- Stop all current tracks so Animate reloads the edited default IDs.
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            pcall(function() track:Stop(0) end)
        end
    end

    if animate and animate:IsA("BaseScript") then
        local wasEnabled = true
        pcall(function() wasEnabled = animate.Enabled end)
        if wasEnabled then
            pcall(function() animate.Enabled = false end)
            task.wait(0.08)
            pcall(function() animate.Enabled = true end)
        end
    end
end

local function applyPackage(pkg)
    if applyingPackage then return end
    applyingPackage = true
    local char = LP.Character or LP.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid", 8)
    if humanoid then humanoid:WaitForChild("Animator", 6) end
    local animate = char:WaitForChild("Animate", 8)
    if animate then
        for _, category in ipairs({"idle", "walk", "run", "jump", "fall"}) do
            animate:WaitForChild(category, 2)
        end
    end
    if not animate then
        applyingPackage = false
        notify("No se encontró el controlador Animate del personaje", Color3.fromRGB(210, 150, 150))
        return
    end
    captureOriginalAnimations(animate)

    if pkg == "Default" then
        local restored = restoreOriginalAnimations(animate)
        if not restored then
            applyingPackage = false
            notify("No se guardaron animaciones originales para este personaje", Color3.fromRGB(220, 145, 150))
            return
        end
        currentPackage = "Default"
        refreshCharacterAnimator(char, animate)
        applyingPackage = false
        notify("Animaciones originales restauradas", THEME.mutedText)
        return
    end

    local cfg = animPackages[pkg]
    if not cfg then
        applyingPackage = false
        return
    end

    -- Estos paquetes de catálogo usan clips R15. En un rig R6 no se deben
    -- forzar IDs incompatibles: se restauran las animaciones nativas del juego.
    if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
        restoreOriginalAnimations(animate)
        currentPackage = "Default"
        refreshCharacterAnimator(char, animate)
        applyingPackage = false
        notify("Rig R6 detectado: se restauró el salto y la caída originales. Los paquetes visuales disponibles son R15.", Color3.fromRGB(222, 174, 130))
        return
    end

    local changed = 0
    changed += setAnimId(animate, "idle", "Animation1", cfg.idle1)
    changed += setAnimId(animate, "idle", "Animation2", cfg.idle2)
    changed += setAnimId(animate, "walk", "WalkAnim", cfg.walk)
    changed += setAnimId(animate, "run", "RunAnim", cfg.run)
    changed += setAnimId(animate, "jump", "JumpAnim", cfg.jump)
    changed += setAnimId(animate, "fall", "FallAnim", cfg.fall)
    changed += setAnimId(animate, "climb", "ClimbAnim", cfg.climb)
    changed += setAnimId(animate, "swim", "Swim", cfg.swim)
    changed += setAnimId(animate, "swimidle", "SwimIdle", cfg.swimidle)

    if changed == 0 then
        applyingPackage = false
        notify("No se encontraron animaciones compatibles en este rig", Color3.fromRGB(210, 150, 150))
        return
    end

    currentPackage = pkg
    local animationsToPreload = {}
    for _, item in ipairs(animate:GetDescendants()) do
        if item:IsA("Animation") and item.AnimationId ~= "" then
            table.insert(animationsToPreload, item)
        end
    end
    if #animationsToPreload > 0 then
        task.spawn(function()
            local failedAssets = {}
            local ok, preloadError = pcall(function()
                ContentProvider:PreloadAsync(animationsToPreload, function(assetId, status)
                    if status ~= Enum.AssetFetchStatus.Success then
                        table.insert(failedAssets, tostring(assetId))
                    end
                end)
            end)
            if not ok then
                warn("[CosmicVisualPlus] No se pudieron precargar las animaciones: " .. tostring(preloadError))
            elseif #failedAssets > 0 and currentPackage == pkg then
                notify("Algunas animaciones no cargaron. Revisa rig y permisos de los assets.", Color3.fromRGB(222, 174, 130))
            end
        end)
    end
    refreshCharacterAnimator(char, animate)
    applyingPackage = false

    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = THEME.accent
    flash.BackgroundTransparency = 0.91
    flash.BorderSizePixel = 0
    flash.ZIndex = 99999
    flash.Parent = gui
    TweenService:Create(flash, TweenInfo.new(0.65), {BackgroundTransparency = 1}):Play()
    task.delay(0.7, function() if flash and flash.Parent then flash:Destroy() end end)
    notify("🎭 " .. cfg.emoji .. " " .. cfg.name .. " aplicado · " .. changed .. " animaciones", THEME.accent)
end

local animationRespawnConnection = LP.CharacterAdded:Connect(function(char)
    task.spawn(function()
        char:WaitForChild("Humanoid", 10)
        char:WaitForChild("Animate", 10)
        task.wait(0.55)
        for _ = 1, 20 do
            if not applyingPackage then break end
            task.wait(0.1)
        end
        if currentPackage ~= "Default" and char == LP.Character then
            applyPackage(currentPackage)
        end
    end)
end)

addSection("🎭 Anim", "PAQUETES DE ANIMACIÓN")
local animationPackageNames = {}
for pkgName in pairs(animPackages) do table.insert(animationPackageNames, pkgName) end
table.sort(animationPackageNames)
for _, pkgName in ipairs(animationPackageNames) do
    local cfg = animPackages[pkgName]
    addAction("🎭 Anim", cfg.name, cfg.emoji, function() applyPackage(pkgName) end, cfg.color)
end
addAction("🎭 Anim", "Reaplicar animación actual", "↻", function()
    if currentPackage == "Default" then
        notify("Ya estás usando las animaciones originales", THEME.mutedText)
    else
        applyPackage(currentPackage)
    end
end)

addSection("🎭 Anim", "EMOTES")

local emotes = {
    {name="Baile 1", emoji="💃", id="507771019"},
    {name="Baile 2", emoji="🕺", id="507776043"},
    {name="Baile 3", emoji="🎉", id="507777268"},
    {name="Saludar", emoji="👋", id="507770239"},
    {name="Reír",    emoji="😂", id="507770818"},
    {name="Señalar", emoji="👉", id="507770453"},
}

local activeEmoteTrack = nil
for _, e in ipairs(emotes) do
    addAction("🎭 Anim", e.name, e.emoji, function()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if not animator then
            notify("No se encontró Animator", Color3.fromRGB(210, 150, 150))
            return
        end
        if activeEmoteTrack then
            pcall(function() activeEmoteTrack:Stop(0.12) end)
            activeEmoteTrack = nil
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. e.id
        local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
        if not ok or not track then
            anim:Destroy()
            notify("No se pudo cargar este emote", Color3.fromRGB(210, 150, 150))
            return
        end
        track.Looped = false
        track.Priority = Enum.AnimationPriority.Action
        track:Play(0.12)
        activeEmoteTrack = track
        local duration = (track.Length and track.Length > 0) and math.clamp(track.Length, 1.5, 12) or 3.5
        task.delay(duration, function()
            if activeEmoteTrack == track then activeEmoteTrack = nil end
            pcall(function() track:Stop(0.15) end)
            anim:Destroy()
        end)
    end, Color3.fromRGB(180, 176, 194))
end

addSection("🎭 Anim", "PRESET CINEMATOGRÁFICO")

local superAuraParts = {}
local superAuraConn = nil
local superGhostConn = nil
local superPresetEnabled = false
local function clearSuperPreset()
    if superAuraConn then superAuraConn:Disconnect() superAuraConn = nil end
    if superGhostConn then superGhostConn:Disconnect() superGhostConn = nil end
    for _, entry in ipairs(superAuraParts) do
        local part = entry and entry.part
        if part and part.Parent then part:Destroy() end
    end
    superAuraParts = {}
end

addAction("🎭 Anim", "SUPER MEJORAR TODO", "✦", function()
    if superPresetEnabled then
        superPresetEnabled = false
        clearSuperPreset()
        clearCinematicShaders()
        if toggleRegistry["Shaders Cinemáticos"] then toggleRegistry["Shaders Cinemáticos"](false) end
        notify("Preset visual desactivado", THEME.mutedText)
        return
    end

    superPresetEnabled = true
    applyCinematicShaders()
    if toggleRegistry["Shaders Cinemáticos"] then toggleRegistry["Shaders Cinemáticos"](true) end
    clearSuperPreset()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local auraConfig = {
            {size=4.5, y=0.3, transparency=0.90, color=Color3.fromRGB(119, 117, 139), speed=0.25},
            {size=7.0, y=1.4, transparency=0.945, color=Color3.fromRGB(148, 145, 164), speed=-0.18},
            {size=10.0, y=2.7, transparency=0.972, color=Color3.fromRGB(174, 172, 187), speed=0.12},
        }
        for _, cfg in ipairs(auraConfig) do
            local part = Instance.new("Part")
            part.Name = "CinematicAuraLayer"
            part.Shape = Enum.PartType.Ball
            part.Size = Vector3.new(cfg.size, cfg.size, cfg.size)
            part.Color = cfg.color
            part.Material = Enum.Material.SmoothPlastic
            part.Transparency = cfg.transparency
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.CastShadow = false
            part.Parent = Workspace
            table.insert(superAuraParts, {part=part, config=cfg})
        end

        local elapsed = 0
        superAuraConn = RunService.Heartbeat:Connect(function(dt)
            if not hrp or not hrp.Parent then return end
            elapsed = elapsed + dt
            for _, entry in ipairs(superAuraParts) do
                local part = entry.part
                local cfg = entry.config
                if part and part.Parent then
                    part.CFrame = hrp.CFrame * CFrame.Angles(0, elapsed*cfg.speed, 0)
                        * CFrame.new(0, cfg.y + math.sin(elapsed*1.1 + cfg.y)*0.12, 0)
                end
            end
        end)

        local lastPos = hrp.Position
        local lastGhostAt = 0
        superGhostConn = RunService.Heartbeat:Connect(function()
            if not hrp or not hrp.Parent then return end
            local currentPos = hrp.Position
            if (currentPos-lastPos).Magnitude >= 5 and tick()-lastGhostAt >= 0.32 then
                lastGhostAt = tick()
                local ghost = Instance.new("Part")
                ghost.Name = "CinematicTrail"
                ghost.Shape = Enum.PartType.Ball
                ghost.Size = Vector3.new(1.25, 1.25, 1.25)
                ghost.Position = lastPos
                ghost.Color = Color3.fromRGB(135, 133, 151)
                ghost.Material = Enum.Material.SmoothPlastic
                ghost.Transparency = 0.76
                ghost.Anchored = true
                ghost.CanCollide = false
                ghost.CanTouch = false
                ghost.CanQuery = false
                ghost.CastShadow = false
                ghost.Parent = Workspace
                TweenService:Create(ghost, TweenInfo.new(0.75), {
                    Transparency = 1,
                    Size = Vector3.new(0.15, 0.15, 0.15),
                }):Play()
                task.delay(0.8, function()
                    if ghost and ghost.Parent then ghost:Destroy() end
                end)
                lastPos = currentPos
            end
        end)
    end
    notify("Preset cinematográfico activado · pulsa otra vez para apagar", THEME.accent)
end, THEME.accent)

addAction("🎭 Anim", "Restaurar Default", "🔄", function()
    applyPackage("Default")
end, Color3.fromRGB(150, 150, 150))


-- ============================================================
-- ✦ PESTAÑA AJUSTES ✦
-- ============================================================

local themePresets = {
    ["Grafito"] = {background=Color3.fromRGB(11,12,24), panel=Color3.fromRGB(25,21,42), panelHover=Color3.fromRGB(43,31,66), accent=Color3.fromRGB(171,132,238), accentSoft=Color3.fromRGB(113,77,174), text=Color3.fromRGB(248,243,255), mutedText=Color3.fromRGB(190,176,218), enabled=Color3.fromRGB(112,204,174), disabled=Color3.fromRGB(79,73,103), border=Color3.fromRGB(103,73,151)},
    ["Niebla"] = {background=Color3.fromRGB(22,17,35), panel=Color3.fromRGB(36,27,52), panelHover=Color3.fromRGB(52,38,73), accent=Color3.fromRGB(191,151,231), accentSoft=Color3.fromRGB(135,96,185), text=Color3.fromRGB(249,241,255), mutedText=Color3.fromRGB(197,178,219), enabled=Color3.fromRGB(130,202,173), disabled=Color3.fromRGB(91,76,111), border=Color3.fromRGB(105,75,135)},
    ["Medianoche"] = {background=Color3.fromRGB(10,17,34), panel=Color3.fromRGB(19,30,52), panelHover=Color3.fromRGB(29,45,72), accent=Color3.fromRGB(133,169,235), accentSoft=Color3.fromRGB(86,120,190), text=Color3.fromRGB(235,243,255), mutedText=Color3.fromRGB(165,190,224), enabled=Color3.fromRGB(108,199,177), disabled=Color3.fromRGB(74,94,124), border=Color3.fromRGB(62,88,139)},
    ["Violeta Cristal"] = {background=Color3.fromRGB(17,11,31), panel=Color3.fromRGB(31,20,49), panelHover=Color3.fromRGB(51,29,76), accent=Color3.fromRGB(190,139,250), accentSoft=Color3.fromRGB(130,79,192), text=Color3.fromRGB(250,243,255), mutedText=Color3.fromRGB(201,174,232), enabled=Color3.fromRGB(119,211,183), disabled=Color3.fromRGB(84,67,111), border=Color3.fromRGB(123,76,175)},
    ["Azul Profundo"] = {background=Color3.fromRGB(8,16,31), panel=Color3.fromRGB(16,28,49), panelHover=Color3.fromRGB(26,43,70), accent=Color3.fromRGB(120,169,235), accentSoft=Color3.fromRGB(73,119,187), text=Color3.fromRGB(238,246,255), mutedText=Color3.fromRGB(165,192,222), enabled=Color3.fromRGB(103,203,184), disabled=Color3.fromRGB(67,91,123), border=Color3.fromRGB(58,97,151)},
    ["Rosa Nebulosa"] = {background=Color3.fromRGB(27,10,31), panel=Color3.fromRGB(46,19,49), panelHover=Color3.fromRGB(70,28,69), accent=Color3.fromRGB(255,145,205), accentSoft=Color3.fromRGB(185,76,145), text=Color3.fromRGB(255,244,251), mutedText=Color3.fromRGB(235,184,215), enabled=Color3.fromRGB(135,224,190), disabled=Color3.fromRGB(109,62,96), border=Color3.fromRGB(174,82,140)},
    ["Océano Cristal"] = {background=Color3.fromRGB(7,20,34), panel=Color3.fromRGB(13,35,54), panelHover=Color3.fromRGB(20,54,78), accent=Color3.fromRGB(91,210,225), accentSoft=Color3.fromRGB(39,133,164), text=Color3.fromRGB(239,253,255), mutedText=Color3.fromRGB(165,219,229), enabled=Color3.fromRGB(115,226,190), disabled=Color3.fromRGB(56,101,118), border=Color3.fromRGB(56,156,178)},
    ["Esmeralda Nocturna"] = {background=Color3.fromRGB(8,24,23), panel=Color3.fromRGB(15,43,39), panelHover=Color3.fromRGB(24,63,55), accent=Color3.fromRGB(105,218,173), accentSoft=Color3.fromRGB(48,145,112), text=Color3.fromRGB(238,255,248), mutedText=Color3.fromRGB(166,222,201), enabled=Color3.fromRGB(132,235,184), disabled=Color3.fromRGB(56,100,82), border=Color3.fromRGB(56,153,119)},
    ["Rosa Cristal"] = {background=Color3.fromRGB(25,10,29), panel=Color3.fromRGB(44,19,49), panelHover=Color3.fromRGB(68,28,72), accent=Color3.fromRGB(255,166,219), accentSoft=Color3.fromRGB(184,91,158), text=Color3.fromRGB(255,246,252), mutedText=Color3.fromRGB(226,184,212), enabled=Color3.fromRGB(131,220,187), disabled=Color3.fromRGB(103,65,94), border=Color3.fromRGB(170,91,144)},
    ["Zafiro Glass"] = {background=Color3.fromRGB(7,14,32), panel=Color3.fromRGB(17,29,57), panelHover=Color3.fromRGB(29,47,83), accent=Color3.fromRGB(126,177,255), accentSoft=Color3.fromRGB(76,116,194), text=Color3.fromRGB(242,248,255), mutedText=Color3.fromRGB(175,198,232), enabled=Color3.fromRGB(117,220,196), disabled=Color3.fromRGB(64,83,125), border=Color3.fromRGB(76,111,182)},
    ["Lavanda Perla"] = {background=Color3.fromRGB(19,14,34), panel=Color3.fromRGB(36,27,57), panelHover=Color3.fromRGB(56,42,82), accent=Color3.fromRGB(201,174,255), accentSoft=Color3.fromRGB(139,111,202), text=Color3.fromRGB(250,247,255), mutedText=Color3.fromRGB(205,193,231), enabled=Color3.fromRGB(133,218,191), disabled=Color3.fromRGB(88,75,120), border=Color3.fromRGB(133,107,187)},
}
local function applyTheme(themeName)
    local palette = themePresets[themeName]
    if not palette then return end
    for key, value in pairs(palette) do THEME[key] = value end
    main.BackgroundColor3 = THEME.background
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.panelHover),
        ColorSequenceKeypoint.new(0.55, THEME.background),
        ColorSequenceKeypoint.new(1, THEME.panel),
    })
    mainStroke.Color = THEME.border
    topHighlight.BackgroundColor3 = THEME.accent
    topHighlightGradient.Color = ColorSequence.new(THEME.accentSoft, THEME.accent)
    tabsBar.BackgroundColor3 = THEME.panel
    minIcon.BackgroundColor3 = THEME.background
    minIcon.TextColor3 = THEME.text
    minStroke.Color = THEME.border
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:GetAttribute("ThemePanel") then obj.BackgroundColor3 = THEME.panel end
        if obj:GetAttribute("ThemeOrb") then obj.BackgroundColor3 = THEME.accentSoft end
        if obj:IsA("UIGradient") and obj:GetAttribute("ThemePanelGradient") then
            obj.Color = ColorSequence.new(THEME.panelHover, THEME.panel)
        end
        if obj:IsA("UIGradient") and obj:GetAttribute("ThemeAccentGradient") then
            obj.Color = ColorSequence.new(THEME.accentSoft, THEME.accent)
        end
        if obj:GetAttribute("ThemeStroke") and obj:IsA("UIStroke") then obj.Color = THEME.border end
        if obj:GetAttribute("ThemeAccent") then obj.BackgroundColor3 = THEME.accent end
        if obj:GetAttribute("ThemeText") and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
            obj.TextColor3 = THEME.text
        end
        if obj:GetAttribute("ThemeSection") and obj:IsA("TextLabel") then obj.TextColor3 = THEME.accent end
        if obj:GetAttribute("ThemeMutedText") and obj:IsA("TextLabel") then obj.TextColor3 = THEME.mutedText end
        if obj:IsA("TextLabel") and obj.Text == "—" then obj.TextColor3 = THEME.text end
    end
    for name, data in pairs(tabButtons) do
        data.color = THEME.accent
        data.btn.BackgroundColor3 = (name == selectedTabName) and THEME.accentSoft or THEME.panel
        data.btn.TextColor3 = THEME.text
    end
    notify("Tema " .. themeName .. " aplicado", THEME.accent)
end

addSection("⚙ Ajustes", "TEMAS MONOCROMÁTICOS")
addAction("⚙ Ajustes", "Grafito · gris violeta suave", "◈", function() applyTheme("Grafito") end)
addAction("⚙ Ajustes", "Niebla · gris neutro", "◈", function() applyTheme("Niebla") end)
addAction("⚙ Ajustes", "Medianoche · azul profundo", "◈", function() applyTheme("Medianoche") end)
addAction("⚙ Ajustes", "Violeta Cristal · amatista", "✧", function() applyTheme("Violeta Cristal") end)
addAction("⚙ Ajustes", "Azul Profundo · nocturno", "◉", function() applyTheme("Azul Profundo") end)
addAction("⚙ Ajustes", "Rosa Nebulosa · rosa elegante", "✿", function() applyTheme("Rosa Nebulosa") end)
addAction("⚙ Ajustes", "Océano Cristal · azul turquesa", "◉", function() applyTheme("Océano Cristal") end)
addAction("⚙ Ajustes", "Esmeralda Nocturna · verde suave", "❖", function() applyTheme("Esmeralda Nocturna") end)
addAction("⚙ Ajustes", "Rosa Cristal · vidrio rosado", "✿", function() applyTheme("Rosa Cristal") end)
addAction("⚙ Ajustes", "Zafiro Glass · azul profundo", "◉", function() applyTheme("Zafiro Glass") end)
addAction("⚙ Ajustes", "Lavanda Perla · violeta suave", "✧", function() applyTheme("Lavanda Perla") end)

addSection("⚙ Ajustes", "PERFILES DE SHADERS")
local function chooseShaderProfile(name)
    currentShaderProfile = name
    applyCinematicShaders(name)
    if toggleRegistry["Shaders Cinemáticos"] then toggleRegistry["Shaders Cinemáticos"](true) end
    notify("Perfil " .. name .. " aplicado", THEME.accent)
end
addAction("⚙ Ajustes", "Cinemático · contraste y bloom suave", "✧", function() chooseShaderProfile("Cinemático") end)
addAction("⚙ Ajustes", "Noir Suave · casi monocromático", "◐", function() chooseShaderProfile("Noir Suave") end)
addAction("⚙ Ajustes", "Plata Natural · luz equilibrada", "◉", function() chooseShaderProfile("Plata Natural") end)
addAction("⚙ Ajustes", "Ligero · efectos mínimos", "▣", function() chooseShaderProfile("Ligero") end)
addAction("⚙ Ajustes", "Amatista Glass · brillo de vidrio", "✧", function() chooseShaderProfile("Amatista Glass") end)
addAction("⚙ Ajustes", "Aurora Suave · color natural", "◉", function() chooseShaderProfile("Aurora Suave") end)
addAction("⚙ Ajustes", "Prisma Suave · brillo y color premium", "✧", function() chooseShaderProfile("Prisma Suave") end)

addSection("⚙ Ajustes", "AJUSTE MANUAL DE SHADERS")
addSlider("⚙ Ajustes", "Bloom · brillo de luces", 0, 0.30, shaderSettings.Bloom or 0.16, 0.01, function(v) return string.format("%.2f", v) end, function(v)
    shaderSettings.Bloom = v
    manualShaderOverrides.Bloom = v
    if shaderRefs.Bloom and shaderRefs.Bloom.Parent then shaderRefs.Bloom.Intensity = v end
end)
addSlider("⚙ Ajustes", "Blur ambiental · suave", 0, 3, shaderSettings.Blur or 0.85, 0.1, function(v) return string.format("%.1f", v) end, function(v)
    shaderSettings.Blur = v
    manualShaderOverrides.Blur = v
    if shaderRefs.Blur and shaderRefs.Blur.Parent then shaderRefs.Blur.Size = v end
end)
addSlider("⚙ Ajustes", "Contraste", 0, 0.30, shaderSettings.Contrast or 0.085, 0.01, function(v) return string.format("%.2f", v) end, function(v)
    shaderSettings.Contrast = v
    manualShaderOverrides.Contrast = v
    if shaderRefs.Color and shaderRefs.Color.Parent then shaderRefs.Color.Contrast = v end
end)
addSlider("⚙ Ajustes", "Saturación · color natural", -0.55, 0.20, shaderSettings.Saturation or 0.045, 0.01, function(v) return string.format("%.2f", v) end, function(v)
    shaderSettings.Saturation = v
    manualShaderOverrides.Saturation = v
    if shaderRefs.Color and shaderRefs.Color.Parent then shaderRefs.Color.Saturation = v end
end)
addSlider("⚙ Ajustes", "Brillo de color", -0.08, 0.06, shaderSettings.Brightness or 0.004, 0.005, function(v) return string.format("%.3f", v) end, function(v)
    shaderSettings.Brightness = v
    manualShaderOverrides.Brightness = v
    if shaderRefs.Color and shaderRefs.Color.Parent then shaderRefs.Color.Brightness = v end
end)
addSlider("⚙ Ajustes", "Matiz amatista", 0, 1, 0.38, 0.02, function(v) return string.format("%d%%", math.floor(v*100+0.5)) end, function(v)
    local tint = Color3.new(1, 1, 1):Lerp(Color3.fromRGB(203, 177, 246), v)
    shaderSettings.Tint = tint
    manualShaderOverrides.Tint = tint
    if shaderRefs.Color and shaderRefs.Color.Parent then shaderRefs.Color.TintColor = tint end
end)

addSection("⚙ Ajustes", "INTERFAZ DE VIDRIO")
local function setGlassLevel(value)
    local panelTransparency = math.clamp(value, 0, 0.22)
    main.BackgroundTransparency = 0.025 + panelTransparency
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:GetAttribute("ThemePanel") and obj:IsA("GuiObject") then
            obj.BackgroundTransparency = 0.035 + panelTransparency * 0.45
        end
    end
end
addSlider("⚙ Ajustes", "Transparencia del vidrio", 0, 0.18, 0.07, 0.01, function(v) return string.format("%d%%", math.floor(v*100+0.5)) end, setGlassLevel)
addSlider("⚙ Ajustes", "Intensidad del borde luminoso", 0.15, 0.9, 0.52, 0.05, function(v) return string.format("%d%%", math.floor(v*100+0.5)) end, function(v)
    local transparency = 1 - v
    for _, obj in ipairs(main:GetDescendants()) do
        if obj:IsA("UIStroke") and obj:GetAttribute("ThemeStroke") then
            obj.Transparency = transparency
        end
    end
end)

addSection("⚙ Ajustes", "INTERFAZ Y AUDIO")
addSlider("⚙ Ajustes", "Escala de interfaz", 0.78, 1.12, 1, 0.01, function(v) return string.format("%.2fx", v) end, function(v)
    mainScale.Scale = v
end)
addSlider("⚙ Ajustes", "Volumen de sonidos UI", 0, 0.50, 0.30, 0.01, function(v) return string.format("%d%%", math.floor(v*200+0.5)) end, function(v)
    clickSfx.Volume = v; hoverSfx.Volume = v*0.45; onSfx.Volume = v; offSfx.Volume = v
end)
addSlider("⚙ Ajustes", "Volumen de música", 0, 0.35, 0.12, 0.01, function(v) return string.format("%d%%", math.floor(v*100+0.5)) end, function(v)
    ambientMusic.Volume = v
end)
addToggle("⚙ Ajustes", "Sonidos de interfaz", "♫", function(s) uiSoundsEnabled = s end)
addToggle("⚙ Ajustes", "Notificaciones", "▤", function(s) notificationsEnabled = s end)

local camera = Workspace.CurrentCamera
local originalFov = camera and camera.FieldOfView or 70
addSlider("⚙ Ajustes", "Campo de visión", 60, 90, originalFov, 1, function(v) return string.format("%d°", math.floor(v+0.5)) end, function(v)
    local currentCamera = Workspace.CurrentCamera
    if currentCamera then currentCamera.FieldOfView = v end
end)
addAction("⚙ Ajustes", "Restaurar campo de visión", "↺", function()
    local currentCamera = Workspace.CurrentCamera
    if currentCamera then currentCamera.FieldOfView = originalFov end
    notify("Campo de visión restaurado", THEME.mutedText)
end)
addAction("⚙ Ajustes", "Quitar shaders", "◌", function()
    clearCinematicShaders()
    if toggleRegistry["Shaders Cinemáticos"] then toggleRegistry["Shaders Cinemáticos"](false) end
    notify("Shaders desactivados", THEME.mutedText)
end)
addAction("⚙ Ajustes", "Restaurar interfaz y cámara", "↺", function()
    clearCinematicShaders()
    if toggleRegistry["Shaders Cinemáticos"] then toggleRegistry["Shaders Cinemáticos"](false) end
    if depthOfField then depthOfField:Destroy() depthOfField = nil end
    if customNameEnabled then
        customNameEnabled = false
        clearCustomName()
    end
    if namesStyleEnabled then
        namesStyleEnabled = false
        disconnectNameConnections()
        for label, originalColor in pairs(originalNameColors) do
            if label and label.Parent then pcall(function() label.TextColor3 = originalColor end) end
        end
        originalNameColors = setmetatable({}, {__mode = "k"})
    end
    if savedGlobalShadows ~= nil then
        Lighting.GlobalShadows = savedGlobalShadows
        savedGlobalShadows = nil
    end
    if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = originalFov end
    mainScale.Scale = 1
    applyTheme("Grafito")
    ambientMusic:Stop()
    if timerConnection then timerConnection:Disconnect() timerConnection = nil end
    timerRunning = false
    timerElapsed = 0
    if timerLabel and timerLabel.Parent then timerLabel.Text = "Cronómetro: 00:00.0" end
    notify("Ajustes visuales restaurados", THEME.mutedText)
end)

-- ============================================================
-- ✦ EXPANSIÓN ESTÉTICA · CLIMA · HUD · CINEMÁTICAS · EMOTES ✦
-- Solo efectos cosméticos locales y tarjetas de demostración manuales.
-- No consulta roles privados ni datos ocultos de otros jugadores.
-- ============================================================
local expansionCleanup = function() end
do
    local expansionConnections = {}
    local function keepConnection(connection)
        if connection then table.insert(expansionConnections, connection) end
        return connection
    end
    local function disconnectExpansionConnections()
        for _, connection in ipairs(expansionConnections) do
            if connection and connection.Connected then connection:Disconnect() end
        end
        table.clear(expansionConnections)
    end

    -- Drag helper: compatible con mouse y pantalla táctil.
    local function makeMovable(frame)
        if not frame or not frame.Parent then return end
        frame.Active = true
        local dragging = false
        local dragInput = nil
        local dragStart = nil
        local startPosition = nil
        keepConnection(frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragInput = input
                dragStart = input.Position
                startPosition = frame.Position
            end
        end))
        keepConnection(UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input == dragInput then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPosition.X.Scale, startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
                )
            end
        end))
        keepConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input == dragInput then
                dragging = false
                dragInput = nil
            end
        end))
    end

    local function styleCard(frame, strokeColor)
        frame.BackgroundColor3 = THEME.panel
        frame.BackgroundTransparency = 0.09
        frame.BorderSizePixel = 0
        frame:SetAttribute("ThemePanel", true)
        if frame:IsA("TextLabel") or frame:IsA("TextButton") or frame:IsA("TextBox") then
            frame:SetAttribute("ThemeText", true)
        end
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
        local stroke = Instance.new("UIStroke")
        stroke.Color = strokeColor or THEME.accent
        stroke.Transparency = 0.25
        stroke.Thickness = 1.2
        stroke:SetAttribute("ThemeStroke", true)
        stroke.Parent = frame
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new(THEME.panelHover, THEME.panel)
        gradient.Rotation = 115
        gradient:SetAttribute("ThemePanelGradient", true)
        gradient.Parent = frame
        return stroke
    end

    local function makeText(parent, text, size, font, color)
        local label = Instance.new("TextLabel")
        label:SetAttribute("ThemeText", true)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = font or Enum.Font.GothamBold
        label.TextSize = size or 12
        label.TextColor3 = color or THEME.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = parent
        return label
    end

    -- 4 + 23: clima configurable, con densidad y viento.
    local weatherEnabled = false
    local weatherStyle = "Nieve"
    local weatherDensity = 22
    local weatherWind = 0
    local weatherAnchor = nil
    local weatherEmitter = nil
    local weatherConnection = nil
    local weatherProfiles = {
        ["Nieve"] = {color=Color3.fromRGB(223,235,255), rate=22, speed=NumberRange.new(3,7), life=NumberRange.new(3,5), size=NumberSequence.new(0.16,0.08), accel=Vector3.new(1,-0.5,0)},
        ["Lluvia"] = {color=Color3.fromRGB(167,198,233), rate=42, speed=NumberRange.new(42,60), life=NumberRange.new(0.7,1.1), size=NumberSequence.new(0.055,0.035), accel=Vector3.new(0,-5,0)},
        ["Pétalos"] = {color=Color3.fromRGB(255,190,221), rate=14, speed=NumberRange.new(2,5), life=NumberRange.new(3,5), size=NumberSequence.new(0.18,0.10), accel=Vector3.new(2,-0.3,0)},
        ["Bruma"] = {color=Color3.fromRGB(190,183,222), rate=10, speed=NumberRange.new(0.3,1.1), life=NumberRange.new(4,6), size=NumberSequence.new(0.30,0.48), accel=Vector3.new(0,0.2,0)},
    }
    local function applyWeatherProfile()
        if not weatherEmitter then return end
        local profile = weatherProfiles[weatherStyle] or weatherProfiles.Nieve
        weatherEmitter.Color = ColorSequence.new(profile.color, profile.color:Lerp(Color3.new(1,1,1), 0.38))
        weatherEmitter.Speed = profile.speed
        weatherEmitter.Lifetime = profile.life
        weatherEmitter.Size = profile.size
        weatherEmitter.Acceleration = profile.accel + Vector3.new(weatherWind, 0, 0)
        weatherEmitter.Rate = math.floor(weatherDensity * (profile.rate / 22))
        if weatherStyle == "Lluvia" then
            weatherEmitter.EmissionDirection = Enum.NormalId.Bottom
            weatherEmitter.LightEmission = 0.04
        else
            weatherEmitter.EmissionDirection = Enum.NormalId.Bottom
            weatherEmitter.LightEmission = 0.24
        end
    end
    local function stopWeather()
        weatherEnabled = false
        if weatherConnection then weatherConnection:Disconnect() weatherConnection = nil end
        if weatherAnchor and weatherAnchor.Parent then weatherAnchor:Destroy() end
        weatherAnchor = nil
        weatherEmitter = nil
    end
    local function startWeather()
        stopWeather()
        weatherEnabled = true
        local camera = Workspace.CurrentCamera
        if not camera then
            notify("No se encontró la cámara para el clima", Color3.fromRGB(224,156,165))
            weatherEnabled = false
            return
        end
        weatherAnchor = Instance.new("Part")
        weatherAnchor.Name = "CVP_LocalWeatherAnchor"
        weatherAnchor.Size = Vector3.new(1,1,1)
        weatherAnchor.Transparency = 1
        weatherAnchor.Anchored = true
        weatherAnchor.CanCollide = false
        weatherAnchor.CanTouch = false
        weatherAnchor.CanQuery = false
        weatherAnchor.CastShadow = false
        weatherAnchor.Parent = Workspace
        local attachment = Instance.new("Attachment")
        attachment.Parent = weatherAnchor
        weatherEmitter = Instance.new("ParticleEmitter")
        weatherEmitter.Name = "CVP_WeatherEmitter"
        weatherEmitter.Texture = "rbxassetid://243660364"
        weatherEmitter.SpreadAngle = Vector2.new(12, 12)
        weatherEmitter.Drag = 0.4
        weatherEmitter.RotSpeed = NumberRange.new(-35,35)
        weatherEmitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.25), NumberSequenceKeypoint.new(1,0.70)})
        weatherEmitter.Parent = attachment
        applyWeatherProfile()
        weatherConnection = RunService.Heartbeat:Connect(function()
            local currentCamera = Workspace.CurrentCamera
            if weatherEnabled and weatherAnchor and weatherAnchor.Parent and currentCamera then
                weatherAnchor.CFrame = currentCamera.CFrame * CFrame.new(0, 17, -9)
            end
        end)
        notify("Clima " .. weatherStyle .. " activado", THEME.accent)
    end
    addSection("🌌 Cosmo", "CLIMA AMBIENTAL CONFIGURABLE")
    addToggle("🌌 Cosmo", "Clima visual configurable", "❄", function(enabled)
        if enabled then startWeather() else stopWeather() end
    end, Color3.fromRGB(156,190,231))
    for _, styleName in ipairs({"Nieve","Lluvia","Pétalos","Bruma"}) do
        addAction("🌌 Cosmo", "Clima · " .. styleName, "☁", function()
            weatherStyle = styleName
            if weatherEnabled then applyWeatherProfile() end
            notify("Estilo de clima: " .. styleName, THEME.accent)
        end, Color3.fromRGB(165,183,224))
    end
    addSlider("🌌 Cosmo", "Densidad del clima", 4, 65, weatherDensity, 1, function(v) return tostring(math.floor(v)) end, function(v)
        weatherDensity = v
        applyWeatherProfile()
    end)
    addSlider("🌌 Cosmo", "Viento lateral", -12, 12, weatherWind, 1, function(v) return tostring(math.floor(v)) end, function(v)
        weatherWind = v
        applyWeatherProfile()
    end)

    -- 21: tema del mapa configurable y restaurable.
    local mapThemeEnabled = false
    local mapThemeStyle = "Amatista"
    local mapThemeIntensity = 0.72
    local mapThemeCC = nil
    local mapThemeAtmosphere = nil
    local originalMapLighting = nil
    local mapThemeProfiles = {
        ["Amatista"] = {tint=Color3.fromRGB(222,196,255), ambient=Color3.fromRGB(91,70,129), outdoor=Color3.fromRGB(112,93,151), saturation=0.12, contrast=0.08, haze=0.42, density=0.22},
        ["Azul noche"] = {tint=Color3.fromRGB(187,215,255), ambient=Color3.fromRGB(50,70,112), outdoor=Color3.fromRGB(76,101,151), saturation=0.08, contrast=0.10, haze=0.30, density=0.18},
        ["Rosa aurora"] = {tint=Color3.fromRGB(255,210,235), ambient=Color3.fromRGB(111,69,105), outdoor=Color3.fromRGB(145,91,132), saturation=0.15, contrast=0.07, haze=0.48, density=0.23},
        ["Esmeralda"] = {tint=Color3.fromRGB(200,255,225), ambient=Color3.fromRGB(54,100,83), outdoor=Color3.fromRGB(83,132,108), saturation=0.13, contrast=0.07, haze=0.34, density=0.19},
    }
    local function saveMapLighting()
        if originalMapLighting then return end
        originalMapLighting = {
            Ambient=Lighting.Ambient,
            OutdoorAmbient=Lighting.OutdoorAmbient,
        }
    end
    local function applyMapTheme()
        if not mapThemeEnabled then return end
        saveMapLighting()
        local profile = mapThemeProfiles[mapThemeStyle] or mapThemeProfiles.Amatista
        if not mapThemeCC or not mapThemeCC.Parent then
            mapThemeCC = Instance.new("ColorCorrectionEffect")
            mapThemeCC.Name = "CVP_MapThemeColor"
            mapThemeCC.Parent = Lighting
        end
        if not mapThemeAtmosphere or not mapThemeAtmosphere.Parent then
            mapThemeAtmosphere = Instance.new("Atmosphere")
            mapThemeAtmosphere.Name = "CVP_MapThemeAtmosphere"
            mapThemeAtmosphere.Parent = Lighting
        end
        mapThemeCC.TintColor = Color3.new(1,1,1):Lerp(profile.tint, mapThemeIntensity)
        mapThemeCC.Saturation = profile.saturation * mapThemeIntensity
        mapThemeCC.Contrast = profile.contrast * mapThemeIntensity
        mapThemeCC.Brightness = 0.006 * mapThemeIntensity
        mapThemeAtmosphere.Color = profile.tint
        mapThemeAtmosphere.Decay = profile.ambient
        mapThemeAtmosphere.Density = profile.density * mapThemeIntensity
        mapThemeAtmosphere.Haze = profile.haze * mapThemeIntensity
        mapThemeAtmosphere.Glare = 0.06 * mapThemeIntensity
        Lighting.Ambient = originalMapLighting.Ambient:Lerp(profile.ambient, mapThemeIntensity)
        Lighting.OutdoorAmbient = originalMapLighting.OutdoorAmbient:Lerp(profile.outdoor, mapThemeIntensity)
    end
    local function stopMapTheme()
        mapThemeEnabled = false
        if mapThemeCC and mapThemeCC.Parent then mapThemeCC:Destroy() end
        if mapThemeAtmosphere and mapThemeAtmosphere.Parent then mapThemeAtmosphere:Destroy() end
        mapThemeCC = nil
        mapThemeAtmosphere = nil
        if originalMapLighting then
            Lighting.Ambient = originalMapLighting.Ambient
            Lighting.OutdoorAmbient = originalMapLighting.OutdoorAmbient
            originalMapLighting = nil
        end
    end
    addSection("🌌 Cosmo", "MAP THEME · ILUMINACIÓN DEL ESCENARIO")
    addToggle("🌌 Cosmo", "Tema de mapa configurable", "🌃", function(enabled)
        mapThemeEnabled = enabled
        if enabled then applyMapTheme() else stopMapTheme() end
    end, Color3.fromRGB(171,150,222))
    for _, styleName in ipairs({"Amatista","Azul noche","Rosa aurora","Esmeralda"}) do
        addAction("🌌 Cosmo", "Mapa · " .. styleName, "✧", function()
            mapThemeStyle = styleName
            if mapThemeEnabled then applyMapTheme() end
            notify("Tema de mapa: " .. styleName, THEME.accent)
        end)
    end
    addSlider("🌌 Cosmo", "Intensidad del tema de mapa", 0.15, 1, mapThemeIntensity, 0.05, function(v) return string.format("%d%%", math.floor(v*100+0.5)) end, function(v)
        mapThemeIntensity = v
        applyMapTheme()
    end)

    -- 5 + 25: cinematic round intro and map transition previews.
    local cinematicOverlay = Instance.new("Frame")
    cinematicOverlay.Name = "CVP_CinematicOverlay"
    cinematicOverlay.Size = UDim2.new(1,0,1,0)
    cinematicOverlay.BackgroundColor3 = Color3.fromRGB(8,7,19)
    cinematicOverlay.BackgroundTransparency = 1
    cinematicOverlay.Visible = false
    cinematicOverlay.ZIndex = 200
    cinematicOverlay.Parent = gui
    local overlayGradient = Instance.new("UIGradient")
    overlayGradient.Color = ColorSequence.new(Color3.fromRGB(19,11,38), Color3.fromRGB(6,12,30))
    overlayGradient.Rotation = 25
    overlayGradient.Parent = cinematicOverlay
    local cinematicLine = Instance.new("Frame")
    cinematicLine.Size = UDim2.new(0,0,0,2)
    cinematicLine.AnchorPoint = Vector2.new(0.5,0.5)
    cinematicLine.Position = UDim2.new(0.5,0,0.43,0)
    cinematicLine.BackgroundColor3 = THEME.accent
    cinematicLine.BorderSizePixel = 0
    cinematicLine.ZIndex = 202
    cinematicLine.Parent = cinematicOverlay
    local cinematicTitle = Instance.new("TextLabel")
    cinematicTitle.Size = UDim2.new(0.86,0,0,50)
    cinematicTitle.AnchorPoint = Vector2.new(0.5,0.5)
    cinematicTitle.Position = UDim2.new(0.5,0,0.49,16)
    cinematicTitle.BackgroundTransparency = 1
    cinematicTitle.Text = "MURDER MYSTERY 2"
    cinematicTitle.TextColor3 = THEME.text
    cinematicTitle.TextTransparency = 1
    cinematicTitle.TextSize = 24
    cinematicTitle.Font = Enum.Font.GothamBlack
    cinematicTitle.ZIndex = 203
    cinematicTitle.Parent = cinematicOverlay
    local cinematicSubtitle = Instance.new("TextLabel")
    cinematicSubtitle.Size = UDim2.new(0.86,0,0,25)
    cinematicSubtitle.AnchorPoint = Vector2.new(0.5,0.5)
    cinematicSubtitle.Position = UDim2.new(0.5,0,0.55,24)
    cinematicSubtitle.BackgroundTransparency = 1
    cinematicSubtitle.Text = "PREPÁRATE PARA LA RONDA"
    cinematicSubtitle.TextColor3 = THEME.mutedText
    cinematicSubtitle.TextTransparency = 1
    cinematicSubtitle.TextSize = 11
    cinematicSubtitle.Font = Enum.Font.GothamMedium
    cinematicSubtitle.ZIndex = 203
    cinematicSubtitle.Parent = cinematicOverlay
    local cinematicBusy = false
    local function showCinematic(titleText, subtitleText, holdTime)
        if cinematicBusy then return end
        cinematicBusy = true
        cinematicOverlay.Visible = true
        cinematicTitle.Text = titleText
        cinematicSubtitle.Text = subtitleText
        cinematicOverlay.BackgroundTransparency = 1
        cinematicTitle.TextTransparency = 1
        cinematicSubtitle.TextTransparency = 1
        cinematicLine.Size = UDim2.new(0,0,0,2)
        cinematicLine.BackgroundColor3 = THEME.accent
        TweenService:Create(cinematicOverlay, TweenInfo.new(0.42, Enum.EasingStyle.Quad), {BackgroundTransparency=0.16}):Play()
        TweenService:Create(cinematicLine, TweenInfo.new(0.55, Enum.EasingStyle.Quart), {Size=UDim2.new(0.62,0,0,2)}):Play()
        TweenService:Create(cinematicTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {TextTransparency=0, Position=UDim2.new(0.5,0,0.49,0)}):Play()
        TweenService:Create(cinematicSubtitle, TweenInfo.new(0.55), {TextTransparency=0}):Play()
        task.delay(holdTime or 1.65, function()
            if not cinematicOverlay or not cinematicOverlay.Parent then return end
            TweenService:Create(cinematicOverlay, TweenInfo.new(0.5), {BackgroundTransparency=1}):Play()
            TweenService:Create(cinematicTitle, TweenInfo.new(0.28), {TextTransparency=1}):Play()
            TweenService:Create(cinematicSubtitle, TweenInfo.new(0.28), {TextTransparency=1}):Play()
            TweenService:Create(cinematicLine, TweenInfo.new(0.35), {Size=UDim2.new(0,0,0,2)}):Play()
            task.wait(0.55)
            if cinematicOverlay and cinematicOverlay.Parent then cinematicOverlay.Visible = false end
            cinematicBusy = false
        end)
    end
    addSection("🎮 Extras", "CINEMÁTICAS")
    addAction("🎮 Extras", "Previsualizar intro de ronda", "🎬", function()
        showCinematic("RONDA INICIADA", "MURDER MYSTERY 2 · QUE COMIENCE LA PARTIDA", 1.8)
    end)
    addAction("🎮 Extras", "Previsualizar transición de mapa", "▰", function()
        showCinematic("CAMBIANDO ESCENARIO", "PREPARANDO EL SIGUIENTE MAPA", 1.45)
    end)

    -- 11 + 14: fondos decorativos del panel, con presets no-RGB.
    local backgroundStyles = {
        ["Amatista Nebula"] = {a=Color3.fromRGB(76,38,113), b=Color3.fromRGB(16,12,34), c=Color3.fromRGB(34,37,76), rotation=128, orb=Color3.fromRGB(151,99,212)},
        ["Océano Nocturno"] = {a=Color3.fromRGB(22,68,100), b=Color3.fromRGB(7,15,32), c=Color3.fromRGB(22,42,72), rotation=138, orb=Color3.fromRGB(81,151,198)},
        ["Rosa Aurora"] = {a=Color3.fromRGB(87,35,76), b=Color3.fromRGB(20,10,32), c=Color3.fromRGB(52,25,60), rotation=120, orb=Color3.fromRGB(205,111,167)},
        ["Esmeralda Velvet"] = {a=Color3.fromRGB(25,75,62), b=Color3.fromRGB(8,21,25), c=Color3.fromRGB(20,43,42), rotation=132, orb=Color3.fromRGB(85,166,133)},
    }
    local currentBackgroundStyle = "Amatista Nebula"
    local function applyBackgroundStyle(name)
        local cfg = backgroundStyles[name]
        if not cfg then return end
        currentBackgroundStyle = name
        bgGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,cfg.a),
            ColorSequenceKeypoint.new(0.52,cfg.b),
            ColorSequenceKeypoint.new(1,cfg.c),
        })
        bgGrad.Rotation = cfg.rotation
        glassOrbA.BackgroundColor3 = cfg.orb
        glassOrbB.BackgroundColor3 = cfg.orb:Lerp(Color3.fromRGB(100,130,210),0.38)
        TweenService:Create(mainStroke, TweenInfo.new(0.35), {Color=cfg.orb, Transparency=0.2}):Play()
        notify("Fondo " .. name .. " aplicado", THEME.accent)
    end
    addSection("🎨 Visual", "FONDOS GLASS PERSONALIZADOS")
    for _, styleName in ipairs({"Amatista Nebula","Océano Nocturno","Rosa Aurora","Esmeralda Velvet"}) do
        addAction("🎨 Visual", "Fondo · " .. styleName, "✧", function() applyBackgroundStyle(styleName) end)
    end

    -- 13 + 16: microinteracciones, notificaciones ajustables.
    addSection("⚙ Ajustes", "NOTIFICACIONES Y MICROANIMACIONES")
    addSlider("⚙ Ajustes", "Duración de notificaciones", 1, 6, notificationDuration, 0.5, function(v) return string.format("%.1fs",v) end, function(v)
        notificationDuration = v
    end)
    addAction("⚙ Ajustes", "Probar notificación premium", "✦", function()
        notify("Efecto de cristal activado · Cosmic Visual Plus", THEME.accent)
    end)

    -- 17: sound pack selector using existing UI sound assets, with pitch profiles only.
    addSection("⚙ Ajustes", "PAQUETES DE SONIDO UI")
    local soundPackName = "Glass"
    local function setSoundPack(name)
        soundPackName = name
        local speed = ({Glass=0.92, Soft=0.82, Arcade=1.12, Studio=1.0})[name] or 1
        clickSfx.PlaybackSpeed = speed
        hoverSfx.PlaybackSpeed = speed * 1.04
        onSfx.PlaybackSpeed = speed * 0.98
        offSfx.PlaybackSpeed = speed * 0.94
        notify("Sonido UI · " .. name, THEME.accent)
        playUi(clickSfx)
    end
    for _, packName in ipairs({"Glass","Soft","Arcade","Studio"}) do
        addAction("⚙ Ajustes", "Sonido · " .. packName, "♫", function() setSoundPack(packName) end)
    end

    -- 15: floating music player. It only plays a user-supplied audio asset with permissions.
    local musicWidget = Instance.new("Frame")
    musicWidget.Name = "CVP_FloatingMusicPlayer"
    musicWidget.Size = UDim2.new(0,226,0,76)
    musicWidget.Position = UDim2.new(0,16,1,-94)
    musicWidget.BackgroundColor3 = THEME.panel
    musicWidget.BackgroundTransparency = 0.08
    musicWidget.BorderSizePixel = 0
    musicWidget.Visible = false
    musicWidget.ZIndex = 40
    musicWidget.Parent = gui
    styleCard(musicWidget, THEME.accent)
    makeMovable(musicWidget)
    local musicTitle = makeText(musicWidget, "COSMIC PLAYER", 11, Enum.Font.GothamBlack, THEME.text)
    musicTitle.Position = UDim2.new(0,12,0,7)
    musicTitle.Size = UDim2.new(1,-24,0,18)
    local musicSubtitle = makeText(musicWidget, "Audio autorizado · listo", 9, Enum.Font.Gotham, THEME.mutedText)
    musicSubtitle.Position = UDim2.new(0,12,0,25)
    musicSubtitle.Size = UDim2.new(1,-24,0,15)
    local function musicButton(text, x, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0,42,0,25)
        button.Position = UDim2.new(0,x,0,46)
        button.BackgroundColor3 = THEME.panelHover
        button.BackgroundTransparency = 0.03
        button.Text = text
        button.TextColor3 = THEME.text
        button.Font = Enum.Font.GothamBold
        button.TextSize = 11
        button.AutoButtonColor = false
        button.ZIndex = 42
        button.Parent = musicWidget
        Instance.new("UICorner",button).CornerRadius = UDim.new(0,7)
        button.MouseButton1Click:Connect(callback)
        return button
    end
    musicButton("▶",10,function()
        if musicAssetId == "" or ambientMusic.SoundId == "" then
            notify("Primero agrega un ID de audio autorizado", Color3.fromRGB(222,150,155))
            return
        end
        if not ambientMusic.IsLoaded then
            task.spawn(function()
                pcall(function() ContentProvider:PreloadAsync({ambientMusic}) end)
                if ambientMusic.IsLoaded then ambientMusic:Play() end
            end)
        else
            ambientMusic:Play()
        end
        musicSubtitle.Text = "Reproduciendo audio"
    end)
    musicButton("Ⅱ",58,function()
        if ambientMusic.IsPlaying then ambientMusic:Pause() end
        musicSubtitle.Text = "En pausa"
    end)
    musicButton("■",106,function()
        ambientMusic:Stop()
        musicSubtitle.Text = "Detenido"
    end)
    addSection("🎮 Extras", "REPRODUCTOR FLOTANTE")
    addToggle("🎮 Extras", "Mostrar reproductor flotante", "♫", function(enabled)
        musicWidget.Visible = enabled
        if enabled then notify("Reproductor flotante listo · arrástralo", THEME.accent) end
    end)

    -- 34 + 35: movable coin counter and round timer HUD.
    local hudStrokeColor = THEME.accent
    local coinHud = Instance.new("TextLabel")
    coinHud.Name = "CVP_CoinCounterHUD"
    coinHud.Size = UDim2.new(0,156,0,34)
    coinHud.Position = UDim2.new(0,16,0,105)
    coinHud.BackgroundColor3 = THEME.panel
    coinHud.BackgroundTransparency = 0.10
    coinHud.BorderSizePixel = 0
    coinHud.Text = "◈  Monedas: —"
    coinHud.TextColor3 = THEME.text
    coinHud.TextSize = 11
    coinHud.Font = Enum.Font.GothamBold
    coinHud.Visible = false
    coinHud.ZIndex = 35
    coinHud.Parent = gui
    styleCard(coinHud, hudStrokeColor)
    makeMovable(coinHud)
    local coinHudEnabled = false
    local coinHudConnection = nil
    local function findOwnCoinValue()
        local stats = LP:FindFirstChild("leaderstats")
        if not stats then return nil end
        for _, value in ipairs(stats:GetChildren()) do
            if (value:IsA("IntValue") or value:IsA("NumberValue")) then
                local name = string.lower(value.Name)
                if string.find(name,"coin",1,true) or string.find(name,"moneda",1,true) then
                    return value.Value
                end
            end
        end
        return nil
    end
    local function refreshCoinHud()
        local value = findOwnCoinValue()
        coinHud.Text = value ~= nil and ("◈  Monedas: " .. tostring(value)) or "◈  Monedas: —"
    end
    addSection("🎮 Extras", "HUD FLOTANTES · ARRASTRA PARA MOVER")
    addToggle("🎮 Extras", "Contador de monedas flotante", "◈", function(enabled)
        coinHudEnabled = enabled
        coinHud.Visible = enabled
        if coinHudConnection then coinHudConnection:Disconnect() coinHudConnection = nil end
        if enabled then
            refreshCoinHud()
            local acc = 0
            coinHudConnection = RunService.Heartbeat:Connect(function(dt)
                acc += dt
                if acc >= 0.6 then acc = 0; refreshCoinHud() end
            end)
            notify("HUD de monedas activado · arrástralo", THEME.accent)
        end
    end)
    addToggle("🎮 Extras", "Cronómetro flotante movible", "⏱", function(enabled)
        timerLabel.Visible = enabled
        if enabled then notify("HUD de tiempo activado · arrástralo", THEME.accent) end
    end)
    makeMovable(timerLabel)

    local roundHud = Instance.new("TextLabel")
    roundHud.Name = "CVP_RoundTimerHUD"
    roundHud.Size = UDim2.new(0,178,0,34)
    roundHud.Position = UDim2.new(0,16,0,145)
    roundHud.BackgroundColor3 = THEME.panel
    roundHud.BackgroundTransparency = 0.10
    roundHud.BorderSizePixel = 0
    roundHud.Text = "◷  Ronda: —"
    roundHud.TextColor3 = THEME.text
    roundHud.TextSize = 11
    roundHud.Font = Enum.Font.GothamBold
    roundHud.Visible = false
    roundHud.ZIndex = 35
    roundHud.Parent = gui
    styleCard(roundHud,hudStrokeColor)
    makeMovable(roundHud)
    local roundTimerConnection = nil
    local function guiBranchVisible(object)
        local node = object
        while node and node ~= PG do
            if node:IsA("GuiObject") and not node.Visible then return false end
            if node:IsA("ScreenGui") and not node.Enabled then return false end
            node = node.Parent
        end
        return true
    end
    local function getVisibleRoundTimer()
        for _, object in ipairs(PG:GetDescendants()) do
            if (object:IsA("TextLabel") or object:IsA("TextButton")) and guiBranchVisible(object) then
                local name = string.lower(object.Name)
                local likelyTimer = string.find(name,"timer",1,true) or string.find(name,"time",1,true)
                    or string.find(name,"roundclock",1,true) or string.find(name,"round_time",1,true)
                local textValue = tostring(object.Text or "")
                if likelyTimer and string.match(textValue,"%d%d?:%d%d") then
                    return textValue
                end
            end
        end
        return nil
    end
    addToggle("🎮 Extras", "Temporizador de ronda flotante", "◷", function(enabled)
        roundHud.Visible=enabled
        if roundTimerConnection then roundTimerConnection:Disconnect() roundTimerConnection=nil end
        if enabled then
            local accumulator=0
            roundTimerConnection=RunService.Heartbeat:Connect(function(dt)
                accumulator+=dt
                if accumulator<0.5 then return end
                accumulator=0
                local visibleTime=getVisibleRoundTimer()
                roundHud.Text=visibleTime and ("◷  Ronda: " .. visibleTime) or "◷  Ronda: sin reloj visible"
            end)
            notify("HUD de ronda activado · arrástralo",THEME.accent)
        end
    end)
    addAction("🎮 Extras", "Restablecer posiciones HUD", "⌖", function()
        coinHud.Position = UDim2.new(0,16,0,105)
        roundHud.Position = UDim2.new(0,16,0,145)
        timerLabel.Position = UDim2.new(1,-16,0,104)
        notify("Posiciones HUD restauradas", THEME.mutedText)
    end)

    -- 36: role card template. It is a manual design preview, not a hidden-role detector.
    addSection("🎯 MM2", "ROLE CARDS · VISTA PREVIA COSMÉTICA")
    local roleCard = Instance.new("Frame")
    roleCard.Size = UDim2.new(1,0,0,96)
    roleCard.Position = UDim2.new(0,0,0,tabContents["🎯 MM2"].CanvasSize.Y.Offset)
    roleCard.BackgroundColor3 = THEME.panel
    roleCard.BorderSizePixel = 0
    roleCard.Parent = tabContents["🎯 MM2"]
    roleCard:SetAttribute("ThemePanel", true)
    styleCard(roleCard, THEME.accent)
    local roleCardTitle = makeText(roleCard,"ROLE CARD · PREVIEW",10,Enum.Font.GothamBlack,THEME.mutedText)
    roleCardTitle.Position = UDim2.new(0,12,0,8)
    roleCardTitle.Size = UDim2.new(1,-24,0,16)
    local roleCardName = makeText(roleCard,"INOCENTE",18,Enum.Font.GothamBlack,THEME.text)
    roleCardName.Position = UDim2.new(0,12,0,30)
    roleCardName.Size = UDim2.new(1,-24,0,28)
    local roleCardNote = makeText(roleCard,"Vista previa manual · no detecta roles ocultos",8,Enum.Font.Gotham,THEME.mutedText)
    roleCardNote.Position = UDim2.new(0,12,0,66)
    roleCardNote.Size = UDim2.new(1,-24,0,18)
    tabContents["🎯 MM2"].CanvasSize = UDim2.new(0,0,0,roleCard.Position.Y.Offset+104)
    local roleCardStyles = {
        ["INOCENTE"]={fill=Color3.fromRGB(72,130,170),stroke=Color3.fromRGB(145,211,245)},
        ["SHERIFF"]={fill=Color3.fromRGB(62,111,178),stroke=Color3.fromRGB(146,198,255)},
        ["ASESINO"]={fill=Color3.fromRGB(148,61,88),stroke=Color3.fromRGB(255,139,164)},
    }
    local function setRoleCardPreview(roleName)
        local cfg = roleCardStyles[roleName]
        if not cfg then return end
        roleCardName.Text = roleName
        roleCardName.TextColor3 = cfg.stroke
        local stroke = roleCard:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = cfg.stroke end
        local grad = roleCard:FindFirstChildOfClass("UIGradient")
        if grad then grad.Color = ColorSequence.new(cfg.fill:Lerp(THEME.panel,0.2),THEME.panel) end
    end
    addAction("🎯 MM2", "Role Card · Inocente", "◈", function() setRoleCardPreview("INOCENTE") end)
    addAction("🎯 MM2", "Role Card · Sheriff", "★", function() setRoleCardPreview("SHERIFF") end)
    addAction("🎯 MM2", "Role Card · Asesino", "✦", function() setRoleCardPreview("ASESINO") end)

    -- 32: radial emote wheel using the emote list already included in the project.
    local function playWheelEmote(emote)
        local character = LP.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            notify("No se encontró el Animator del personaje", Color3.fromRGB(220,145,150))
            return
        end
        if activeEmoteTrack then
            pcall(function() activeEmoteTrack:Stop(0.12) end)
            activeEmoteTrack = nil
        end
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. tostring(emote.id)
        local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
        if not ok or not track then
            animation:Destroy()
            notify("No se pudo cargar ese emote en este rig", Color3.fromRGB(220,145,150))
            return
        end
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = false
        track:Play(0.12)
        activeEmoteTrack = track
        local duration = (track.Length and track.Length > 0) and math.clamp(track.Length,1.5,12) or 3.5
        task.delay(duration,function()
            pcall(function() track:Stop(0.15) end)
            if activeEmoteTrack == track then activeEmoteTrack=nil end
            animation:Destroy()
        end)
    end
    local emoteWheel = Instance.new("Frame")
    emoteWheel.Name = "CVP_EmoteWheel"
    emoteWheel.Size = UDim2.new(0,300,0,300)
    emoteWheel.AnchorPoint = Vector2.new(0.5,0.5)
    emoteWheel.Position = UDim2.new(0.5,0,0.5,0)
    emoteWheel.BackgroundColor3 = THEME.background
    emoteWheel.BackgroundTransparency = 0.08
    emoteWheel.Visible = false
    emoteWheel.ZIndex = 80
    emoteWheel.Parent = gui
    styleCard(emoteWheel,THEME.accent)
    local wheelCenter = Instance.new("TextButton")
    wheelCenter.Size = UDim2.new(0,82,0,82)
    wheelCenter.AnchorPoint = Vector2.new(0.5,0.5)
    wheelCenter.Position = UDim2.new(0.5,0,0.5,0)
    wheelCenter.BackgroundColor3 = THEME.panelHover
    wheelCenter.Text = "CERRAR"
    wheelCenter.TextColor3 = THEME.text
    wheelCenter.TextSize = 10
    wheelCenter.Font = Enum.Font.GothamBold
    wheelCenter.ZIndex = 84
    wheelCenter.Parent = emoteWheel
    Instance.new("UICorner",wheelCenter).CornerRadius = UDim.new(1,0)
    wheelCenter.MouseButton1Click:Connect(function() emoteWheel.Visible=false end)
    for index, emote in ipairs(emotes) do
        local angle = ((index-1)/#emotes)*math.pi*2 - math.pi/2
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0,76,0,58)
        button.AnchorPoint = Vector2.new(0.5,0.5)
        button.Position = UDim2.new(0.5,math.cos(angle)*100,0.5,math.sin(angle)*100)
        button.BackgroundColor3 = THEME.panelHover
        button.BackgroundTransparency = 0.04
        button.Text = emote.emoji .. "\n" .. emote.name
        button.TextColor3 = THEME.text
        button.TextSize = 10
        button.Font = Enum.Font.GothamBold
        button.AutoButtonColor = false
        button.ZIndex = 83
        button.Parent = emoteWheel
        Instance.new("UICorner",button).CornerRadius = UDim.new(0,12)
        local buttonStroke = Instance.new("UIStroke")
        buttonStroke.Color = THEME.accent
        buttonStroke.Transparency = 0.4
        buttonStroke.Parent = button
        button.MouseButton1Click:Connect(function()
            emoteWheel.Visible=false
            playWheelEmote(emote)
        end)
    end
    addAction("🎭 Anim", "Abrir rueda radial de emotes", "✺", function()
        emoteWheel.Visible = not emoteWheel.Visible
    end)

    -- 29 + 30: independent walk/run and jump/fall packs from the existing catalog.
    local movementOriginals = setmetatable({}, {__mode="k"})
    local selectedWalkPack = nil
    local selectedJumpPack = nil
    local function findAnimationObject(animate, category, preferredName)
        local folder = animate and animate:FindFirstChild(category)
        if not folder then return nil end
        for _, object in ipairs(folder:GetDescendants()) do
            if object:IsA("Animation") and string.lower(object.Name)==string.lower(preferredName) then
                return object
            end
        end
        for _, object in ipairs(folder:GetDescendants()) do
            if object:IsA("Animation") then return object end
        end
        return nil
    end
    local function setMovementAnimation(char, category, preferredName, id)
        local animate = char and char:FindFirstChild("Animate")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not animate or not humanoid then return false end
        if humanoid.RigType == Enum.HumanoidRigType.R6 then return false end
        local object = findAnimationObject(animate,category,preferredName)
        if not object then return false end
        if movementOriginals[object] == nil then movementOriginals[object] = object.AnimationId end
        object.AnimationId = "rbxassetid://" .. tostring(id)
        return true
    end
    local function applyWalkPack(name)
        local config = animPackages[name]
        local character = LP.Character
        local okA = config and setMovementAnimation(character,"walk","WalkAnim",config.walk)
        local okB = config and setMovementAnimation(character,"run","RunAnim",config.run)
        if okA or okB then
            selectedWalkPack = name
            if character then refreshCharacterAnimator(character,character:FindFirstChild("Animate")) end
            notify("Caminata " .. name .. " aplicada",THEME.accent)
        else
            notify("Caminata no disponible para este rig; usa R15 y assets permitidos",Color3.fromRGB(220,145,150))
        end
    end
    local function applyJumpPack(name)
        local config = animPackages[name]
        local character = LP.Character
        local okA = config and setMovementAnimation(character,"jump","JumpAnim",config.jump)
        local okB = config and setMovementAnimation(character,"fall","FallAnim",config.fall)
        if okA or okB then
            selectedJumpPack = name
            if character then refreshCharacterAnimator(character,character:FindFirstChild("Animate")) end
            notify("Salto y caída " .. name .. " aplicados",THEME.accent)
        else
            notify("Salto no disponible para este rig; usa R15 y assets permitidos",Color3.fromRGB(220,145,150))
        end
    end
    addSection("🎭 Anim", "CAMINATAS INDEPENDIENTES")
    for _, name in ipairs({"Ninja","Bubbly","Stylish","Zombie","Robot","Mage"}) do
        addAction("🎭 Anim", "Caminar · " .. name, "➜", function() applyWalkPack(name) end)
    end
    addSection("🎭 Anim", "SALTOS Y CAÍDAS INDEPENDIENTES")
    for _, name in ipairs({"Ninja","Bubbly","Astronaut","Cartoony","Superhero","Levitation"}) do
        addAction("🎭 Anim", "Saltar/caer · " .. name, "↗", function() applyJumpPack(name) end)
    end
    addAction("🎭 Anim", "Restaurar caminata y salto", "↺", function()
        for animation, animationId in pairs(movementOriginals) do
            if animation and animation.Parent then pcall(function() animation.AnimationId=animationId end) end
        end
        selectedWalkPack=nil
        selectedJumpPack=nil
        if LP.Character then refreshCharacterAnimator(LP.Character,LP.Character:FindFirstChild("Animate")) end
        notify("Movimientos originales restaurados",THEME.mutedText)
    end)
    local movementRespawnConnection = LP.CharacterAdded:Connect(function(character)
        task.wait(0.8)
        if not character or character ~= LP.Character then return end
        if selectedWalkPack then
            local cfg=animPackages[selectedWalkPack]
            setMovementAnimation(character,"walk","WalkAnim",cfg.walk)
            setMovementAnimation(character,"run","RunAnim",cfg.run)
        end
        if selectedJumpPack then
            local cfg=animPackages[selectedJumpPack]
            setMovementAnimation(character,"jump","JumpAnim",cfg.jump)
            setMovementAnimation(character,"fall","FallAnim",cfg.fall)
        end
        if selectedWalkPack or selectedJumpPack then
            refreshCharacterAnimator(character,character:FindFirstChild("Animate"))
        end
    end)
    keepConnection(movementRespawnConnection)

    -- 31: landing animation effect: soft expanding glass ring, configurable through color presets.
    local landingEnabled = false
    local landingConnection = nil
    local landingCharacterConnection = nil
    local landingColor = Color3.fromRGB(185,165,235)
    local function spawnLandingRing(position)
        local ring = Instance.new("Part")
        ring.Name = "CVP_LandingGlassRing"
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(0.12,0.5,0.5)
        ring.CFrame = CFrame.new(position-Vector3.new(0,2.55,0)) * CFrame.Angles(0,0,math.rad(90))
        ring.Color = landingColor
        ring.Material = Enum.Material.Neon
        ring.Transparency = 0.34
        ring.Anchored = true
        ring.CanCollide = false
        ring.CanTouch = false
        ring.CanQuery = false
        ring.CastShadow = false
        ring.Parent = Workspace
        TweenService:Create(ring,TweenInfo.new(0.58,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
            Size=Vector3.new(0.08,8.5,8.5), Transparency=1
        }):Play()
        task.delay(0.62,function() if ring and ring.Parent then ring:Destroy() end end)
    end
    local function bindLanding(character)
        if landingConnection then landingConnection:Disconnect() landingConnection=nil end
        local humanoid = character and character:WaitForChild("Humanoid",5)
        local root = character and character:WaitForChild("HumanoidRootPart",5)
        if not landingEnabled or not humanoid or not root then return end
        local wasAirborne = false
        landingConnection = humanoid.StateChanged:Connect(function(_,newState)
            if newState == Enum.HumanoidStateType.Freefall or newState == Enum.HumanoidStateType.Jumping then
                wasAirborne=true
            elseif newState == Enum.HumanoidStateType.Landed and wasAirborne then
                wasAirborne=false
                if landingEnabled and root.Parent then spawnLandingRing(root.Position) end
            end
        end)
    end
    addSection("🎭 Anim", "EFECTO DE ATERRIZAJE")
    addToggle("🎭 Anim", "Aterrizaje con anillo de cristal", "◎", function(enabled)
        landingEnabled=enabled
        if landingConnection then landingConnection:Disconnect() landingConnection=nil end
        if landingCharacterConnection then landingCharacterConnection:Disconnect() landingCharacterConnection=nil end
        if enabled then
            if LP.Character then task.spawn(bindLanding,LP.Character) end
            landingCharacterConnection=LP.CharacterAdded:Connect(bindLanding)
        end
    end)

    -- 33: local character highlight presets, fully restorable.
    local characterHighlight = nil
    local characterHighlightPresets = {
        ["Perla"]={fill=Color3.fromRGB(232,226,255),outline=Color3.fromRGB(255,255,255)},
        ["Amatista"]={fill=Color3.fromRGB(148,94,216),outline=Color3.fromRGB(220,184,255)},
        ["Zafiro"]={fill=Color3.fromRGB(70,130,220),outline=Color3.fromRGB(174,218,255)},
        ["Rosa"]={fill=Color3.fromRGB(220,105,166),outline=Color3.fromRGB(255,195,226)},
        ["Esmeralda"]={fill=Color3.fromRGB(74,170,131),outline=Color3.fromRGB(168,255,211)},
    }
    local function applyCharacterPreset(name)
        local config=characterHighlightPresets[name]
        local character=LP.Character
        if not config or not character then
            notify("No se encontró tu personaje",Color3.fromRGB(220,145,150))
            return
        end
        if characterHighlight then characterHighlight:Destroy() end
        characterHighlight=Instance.new("Highlight")
        characterHighlight.Name="CVP_LocalCharacterPreset"
        characterHighlight.Adornee=character
        characterHighlight.FillColor=config.fill
        characterHighlight.OutlineColor=config.outline
        characterHighlight.FillTransparency=0.78
        characterHighlight.OutlineTransparency=0.12
        characterHighlight.DepthMode=Enum.HighlightDepthMode.Occluded
        characterHighlight.Parent=character
        notify("Preset de personaje · " .. name,THEME.accent)
    end
    addSection("🎭 Anim", "PRESETS DE COLOR DEL PERSONAJE")
    for _, name in ipairs({"Perla","Amatista","Zafiro","Rosa","Esmeralda"}) do
        addAction("🎭 Anim", "Color · " .. name, "✧", function() applyCharacterPreset(name) end)
    end
    addAction("🎭 Anim", "Quitar preset del personaje", "↺", function()
        if characterHighlight then characterHighlight:Destroy() characterHighlight=nil end
        notify("Preset de personaje quitado",THEME.mutedText)
    end)

    -- 38: elegant lobby decorations built into the panel's glass ornaments.
    local lobbyDecorEnabled = false
    local lobbyDecorToken = 0
    local originalOrbA = {Position=glassOrbA.Position, Size=glassOrbA.Size, Rotation=glassOrbA.Rotation}
    local originalOrbB = {Position=glassOrbB.Position, Size=glassOrbB.Size, Rotation=glassOrbB.Rotation}
    local function setLobbyDecor(enabled)
        lobbyDecorEnabled=enabled
        lobbyDecorToken+=1
        local token=lobbyDecorToken
        if not enabled then
            TweenService:Create(glassOrbA,TweenInfo.new(0.4),{Position=originalOrbA.Position,Size=originalOrbA.Size,Rotation=originalOrbA.Rotation}):Play()
            TweenService:Create(glassOrbB,TweenInfo.new(0.4),{Position=originalOrbB.Position,Size=originalOrbB.Size,Rotation=originalOrbB.Rotation}):Play()
            return
        end
        task.spawn(function()
            while lobbyDecorEnabled and token==lobbyDecorToken and gui.Parent do
                TweenService:Create(glassOrbA,TweenInfo.new(3.0,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
                    Position=UDim2.new(1,-150,0,-45), Size=UDim2.new(0,230,0,230), Rotation=26
                }):Play()
                TweenService:Create(glassOrbB,TweenInfo.new(3.3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
                    Position=UDim2.new(0,-60,1,-130), Size=UDim2.new(0,160,0,160), Rotation=-18
                }):Play()
                task.wait(3.1)
                if not lobbyDecorEnabled or token~=lobbyDecorToken then break end
                TweenService:Create(glassOrbA,TweenInfo.new(3.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
                    Position=UDim2.new(1,-95,0,-88), Size=UDim2.new(0,180,0,180), Rotation=-14
                }):Play()
                TweenService:Create(glassOrbB,TweenInfo.new(3.0,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
                    Position=UDim2.new(0,-95,1,-90), Size=UDim2.new(0,132,0,132), Rotation=20
                }):Play()
                task.wait(3.2)
            end
        end)
    end
    addSection("🎮 Extras", "DECORACIÓN PREMIUM DEL LOBBY")
    addToggle("🎮 Extras", "Decoraciones premium del lobby", "✧", setLobbyDecor)

    -- Mobile buttons and the existing toggles remain animated; these presets refine click feel.
    addAction("⚙ Ajustes", "Animación de botones · rebote suave", "◌", function()
        notify("Los botones ya usan hover y rebote táctil",THEME.accent)
    end)

    -- Cleanup called by Reset All / Close.
    expansionCleanup = function(shouldClose)
        stopWeather()
        stopMapTheme()
        if coinHudConnection then coinHudConnection:Disconnect() coinHudConnection=nil end
        if roundTimerConnection then roundTimerConnection:Disconnect() roundTimerConnection=nil end
        coinHudEnabled=false
        if coinHud and coinHud.Parent then coinHud.Visible=false end
        if roundHud and roundHud.Parent then roundHud.Visible=false end
        if timerLabel and timerLabel.Parent then timerLabel.Visible=false end
        if musicWidget and musicWidget.Parent then musicWidget.Visible=false end
        if cinematicOverlay and cinematicOverlay.Parent then cinematicOverlay.Visible=false end
        if emoteWheel and emoteWheel.Parent then emoteWheel.Visible=false end
        if landingConnection then landingConnection:Disconnect() landingConnection=nil end
        if landingCharacterConnection then landingCharacterConnection:Disconnect() landingCharacterConnection=nil end
        landingEnabled=false
        if characterHighlight then characterHighlight:Destroy() characterHighlight=nil end
        setLobbyDecor(false)
        for animation, animationId in pairs(movementOriginals) do
            if animation and animation.Parent then pcall(function() animation.AnimationId=animationId end) end
        end
        selectedWalkPack=nil
        selectedJumpPack=nil
        if LP.Character then
            local animate=LP.Character:FindFirstChild("Animate")
            if animate then pcall(function() refreshCharacterAnimator(LP.Character,animate) end) end
        end
        if shouldClose then
            disconnectExpansionConnections()
        end
    end
end

-- ============================================================
-- RESTABLECIMIENTO TOTAL Y CIERRE LIMPIO
-- ============================================================
local allToggleLabels = {
    "Aura Cósmica (5 capas)", "Estela al Caminar", "Iluminación Suave del Personaje",
    "Nombres Monocromáticos", "Nombre Personal Degradado", "Cursor Cósmico", "Chat Estilizado",
    "Sky + Nebulosas", "Shaders Cinemáticos", "Profundidad de Campo Suave", "Sombras Globales",
    "Agujero Negro Gigante", "Luciérnagas en Espiral", "Lluvia de Meteoritos", "Portal Personal",
    "Música personalizada", "Fuegos Artificiales al reaparecer", "Partículas Ambientales",
    "Detector de roles visibles", "Detectar jugadores cercanos", "Monedas resaltadas",
    "Partículas de salto y aterrizaje", "Rastro de pasos", "Brillo suave de arma equipada",
    "Skin grafito para armas", "Estela de partículas en arma", "Fogonazo y trazadora local",
    "Estilo de kill feed", "Efecto al reaparecer/ser eliminado", "Ondas visuales de bomba",
    "Cronómetro personal", "Estrellas Orbitando",
    "Sonidos de interfaz", "Notificaciones",
    "Clima visual configurable", "Tema de mapa configurable", "Mostrar reproductor flotante",
    "Contador de monedas flotante", "Cronómetro flotante movible", "Temporizador de ronda flotante", "Aterrizaje con anillo de cristal",
    "Decoraciones premium del lobby",
}

local function resetEverything(closeInterface)
    pcall(expansionCleanup, closeInterface)
    for _, label in ipairs(allToggleLabels) do
        local setter = toggleCallbackRegistry[label]
        if setter then
            local ok, err = pcall(setter, false)
            if not ok then warn("[CosmicVisualPlus] No se pudo apagar '" .. label .. "': " .. tostring(err)) end
        end
    end

    -- Clean up action-based effects and restore local settings.
    if elementalConn then elementalConn:Disconnect() elementalConn = nil end
    if elementalPart then elementalPart:Destroy() elementalPart = nil end
    currentElement = nil
    superPresetEnabled = false
    clearSuperPreset()
    clearCinematicShaders()
    restoreSkyState()
    if depthOfField then depthOfField:Destroy() depthOfField = nil end
    if savedGlobalShadows ~= nil then
        Lighting.GlobalShadows = savedGlobalShadows
        savedGlobalShadows = nil
    end
    if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = originalFov end
    ambientMusic:Stop()
    if activeEmoteTrack then
        pcall(function() activeEmoteTrack:Stop(0.12) end)
        activeEmoteTrack = nil
    end
    if currentPackage ~= "Default" then
        task.spawn(function() pcall(function() applyPackage("Default") end) end)
    end
    if timerConnection then timerConnection:Disconnect() timerConnection = nil end
    timerRunning = false
    timerElapsed = 0
    if timerLabel and timerLabel.Parent then timerLabel.Text = "Cronómetro: 00:00.0" end

    -- Restore source UI styles and input state.
    activeUIFont = nil
    for obj, font in pairs(savedFonts) do
        if obj and obj.Parent then pcall(function() obj.Font = font end) end
    end
    savedFonts = setmetatable({}, {__mode = "k"})
    restoreChatStyle()
    UserInputService.MouseIconEnabled = savedMouseIconEnabled
    if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = originalFov end
    if mainScale and mainScale.Parent then mainScale.Scale = 1 end
    uiSoundsEnabled = true
    notificationsEnabled = true
    notificationDuration = 2.5
    clickSfx.PlaybackSpeed = 1
    hoverSfx.PlaybackSpeed = 1
    onSfx.PlaybackSpeed = 1
    offSfx.PlaybackSpeed = 1
    if toggleRegistry["Sonidos de interfaz"] then toggleRegistry["Sonidos de interfaz"](true) end
    if toggleRegistry["Notificaciones"] then toggleRegistry["Notificaciones"](true) end
    setGlassLevel(0.07)

    if closeInterface then
        for _, connection in ipairs(globalUIConnections) do
            if connection and connection.Connected then connection:Disconnect() end
        end
        table.clear(globalUIConnections)
        if fontWatchConnection and fontWatchConnection.Connected then fontWatchConnection:Disconnect() end
        if displayNameConnection and displayNameConnection.Connected then displayNameConnection:Disconnect() end
        if customNameConnection and customNameConnection.Connected then customNameConnection:Disconnect() end
        if animationRespawnConnection and animationRespawnConnection.Connected then animationRespawnConnection:Disconnect() end

        for _, sound in ipairs({clickSfx, hoverSfx, onSfx, offSfx, ambientMusic}) do
            pcall(function() sound:Stop(); sound:Destroy() end)
        end
        if gui and gui.Parent then gui:Destroy() end
    else
        applyTheme("Grafito")
        notify("Efectos apagados y valores locales restaurados", THEME.enabled)
    end
end

addAction("⚙ Ajustes", "RESTABLECER TODO · apagar efectos", "↺", function()
    resetEverything(false)
end, Color3.fromRGB(112, 204, 174))

closeBtn.MouseButton1Click:Connect(function()
    resetEverything(true)
end)

-- ============================================================
-- MENSAJE INICIAL
-- ============================================================
task.delay(0.8, function()
    notify("COSMIC VISUAL PLUS cargado", THEME.accent)
    task.wait(0.5)
    notify("UI, animaciones y audio revisados", THEME.mutedText)
    task.wait(0.5)
    notify("Interfaz lista", THEME.enabled)
end)

print("✦ COSMIC VISUAL PLUS — listo ✦")