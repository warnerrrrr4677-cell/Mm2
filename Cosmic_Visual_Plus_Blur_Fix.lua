-- ============================================================
-- ✦✦✦✦✦ COSMIC VISUAL PLUS — MOBILE EDITION ✦✦✦✦✦
-- 5 pestañas · shaders nativos · controles móviles
-- Incluye: Visual · Cósmico · Extras · Anim · Ajustes
-- ============================================================
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

-- Paleta visual sobria: grafito, plata y violeta apagado.
local THEME = {
    background = Color3.fromRGB(15, 17, 22),
    panel = Color3.fromRGB(24, 27, 34),
    panelHover = Color3.fromRGB(34, 37, 46),
    accent = Color3.fromRGB(142, 135, 164),
    accentSoft = Color3.fromRGB(105, 105, 124),
    text = Color3.fromRGB(225, 226, 233),
    mutedText = Color3.fromRGB(158, 161, 174),
    enabled = Color3.fromRGB(132, 158, 143),
    disabled = Color3.fromRGB(91, 96, 108),
    border = Color3.fromRGB(61, 65, 77),
}

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local notificationsEnabled = true
local uiSoundsEnabled = true

-- Limpieza total
if PG:FindFirstChild("CosmicVisualPlus") then PG.CosmicVisualPlus:Destroy() end
for _, n in ipairs({"CosmicAddon_Sky","CosmicAddon_BH","CosmicCursor"}) do
    local o = Workspace:FindFirstChild(n) or PG:FindFirstChild(n)
    if o then o:Destroy() end
end

-- ============================================================
-- SONIDOS
-- ============================================================
local function mkSnd(id, v, loop)
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. id
    s.Volume = v or 0.35
    s.Looped = loop or false
    s.Parent = SoundService
    return s
end
local clickSfx     = mkSnd("9114056088", 0.3)
local hoverSfx     = mkSnd("9114054653", 0.15)
local onSfx        = mkSnd("9125402730", 0.3)
local offSfx       = mkSnd("9125404106", 0.3)
local ambientMusic = mkSnd("1837879088", 0.12, true)

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
    color = THEME.accent
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
    txt.TextSize = 11
    txt.TextColor3 = THEME.text
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = n
    table.insert(notifStack, n)
    TweenService:Create(n, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0, 0, 0, 20 + (#notifStack - 1) * 50)
    }):Play()
    task.delay(2.5, function()
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
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
main.Parent = gui

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 28, 36)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(15, 17, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 29, 39)),
})
bgGrad.Rotation = 125
bgGrad.Parent = main

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = THEME.border
mainStroke.Thickness = 1
mainStroke.Transparency = 0.12
mainStroke.Parent = main
mainStroke:SetAttribute("ThemeStroke", true)
local mainScale = Instance.new("UIScale")
mainScale.Scale = 1
mainScale.Parent = main

TweenService:Create(main, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, panelWidth, 0, panelHeight)
}):Play()

-- TÍTULO
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -70, 0, 36)
titleLbl.Position = UDim2.new(0, 16, 0, 8)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "✦ COSMIC VISUAL PLUS ✦"
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 18
titleLbl.TextColor3 = Color3.new(1,1,1)
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = main

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(185, 184, 198)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(238, 238, 242)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(155, 157, 176)),
})
titleGrad.Parent = titleLbl

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, -70, 0, 14)
subTitle.Position = UDim2.new(0, 16, 0, 42)
subTitle.BackgroundTransparency = 1
subTitle.Text = "Visual Edition · 5 pestañas · móvil"
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
-- SISTEMA DE PESTAÑAS (5)
-- ============================================================
local tabsBar = Instance.new("Frame")
tabsBar.Name = "TabsBar"
tabsBar.Size = UDim2.new(1, -32, 0, 32)
tabsBar.Position = UDim2.new(0, 16, 0, 64)
tabsBar.BackgroundColor3 = THEME.panel
tabsBar.BorderSizePixel = 0
tabsBar.Parent = main
tabsBar:SetAttribute("ThemePanel", true)
Instance.new("UICorner", tabsBar).CornerRadius = UDim.new(0, 8)

local tabs = {
    {name = "🎨 Visual",  color = THEME.accent},
    {name = "🌌 Cosmo",   color = THEME.accent},
    {name = "🎮 Extras",  color = THEME.accent},
    {name = "🎭 Anim",    color = THEME.accent},
    {name = "⚙ Ajustes", color = THEME.accent},
}
local selectedTabName = tabs[1].name

local tabContents = {}
local tabButtons = {}

local function createTab(tab, idx)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#tabs, -3, 1, -4)
    btn.Position = UDim2.new((idx-1)/#tabs, 2, 0, 2)
    btn.BackgroundColor3 = idx == 1 and tab.color or THEME.panel
    btn.Text = tab.name
    btn.TextColor3 = THEME.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 8
    btn.AutoButtonColor = false
    btn:SetAttribute("ThemeTab", true)
    btn.Parent = tabsBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    tabButtons[tab.name] = {btn = btn, color = tab.color}

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
            TweenService:Create(d.btn, TweenInfo.new(0.2), {
                BackgroundColor3 = (n == tab.name) and THEME.accentSoft or THEME.panel
            }):Play()
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
local function addToggle(tabName, text, emoji, cb, accentColor)
    local content = tabContents[tabName]
    local yPos = content.CanvasSize.Y.Offset
    accentColor = THEME.accent

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 42)
    b.Position = UDim2.new(0, 0, 0, yPos)
    b.BackgroundColor3 = THEME.panel
    b.Text = ""
    b.AutoButtonColor = false
    b:SetAttribute("ThemePanel", true)
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

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
    lbl.TextSize = 11
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
            pcall(cb, state)
        end
    end
    toggleRegistry[text] = function(newState) setState(newState, false) end

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
    accentColor = THEME.accent

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 42)
    b.Position = UDim2.new(0, 0, 0, yPos)
    b.BackgroundColor3 = THEME.panel
    b.Text = ""
    b.AutoButtonColor = false
    b:SetAttribute("ThemePanel", true)
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

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
    lbl.TextSize = 11
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
        pcall(cb)
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
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    renderValue(defaultValue, false)
    content.CanvasSize = UDim2.new(0, 0, 0, yPos + 74)
end

-- ============================================================
-- ✦ PESTAÑA VISUAL ✦
-- ============================================================

-- FUENTES INTEGRADAS (sin descargas ni APIs externas)
local fontOptions = {
    {name="Gotham", font=Enum.Font.Gotham},
    {name="SciFi", font=Enum.Font.SciFi},
    {name="Code", font=Enum.Font.Code},
    {name="Arcade", font=Enum.Font.Arcade},
}
local savedFonts = {}
local function applyFont(fontName)
    local selected
    for _, item in ipairs(fontOptions) do
        if item.name == fontName then selected = item.font break end
    end
    if not selected then return end
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            if savedFonts[obj] == nil then savedFonts[obj] = obj.Font end
            pcall(function() obj.Font = selected end)
        end
    end
    notify("Fuente " .. fontName .. " aplicada", THEME.accent)
end

for _, item in ipairs(fontOptions) do
    addAction("🎨 Visual", "Fuente " .. item.name, "Aa", function() applyFont(item.name) end)
end
addAction("🎨 Visual", "Restaurar fuentes", "↺", function()
    for obj, font in pairs(savedFonts) do
        if obj and obj.Parent then pcall(function() obj.Font = font end) end
    end
    savedFonts = {}
    notify("Fuentes originales restauradas", THEME.mutedText)
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
LP:GetPropertyChangedSignal("DisplayName"):Connect(function()
    if customNameObj and customNameObj.Parent then
        local label = customNameObj:FindFirstChild("DisplayName")
        if label then label.Text = "✦ " .. LP.DisplayName .. " ✦" end
    end
end)

-- CURSOR CÓSMICO
local cursorGui = nil
local cursorConns = {}
addToggle("🎨 Visual", "Cursor Cósmico", "🎯", function(s)
    for _, c in ipairs(cursorConns) do c:Disconnect() end
    cursorConns = {}
    if cursorGui then cursorGui:Destroy() cursorGui = nil end
    if not s then UserInputService.MouseIconEnabled = true return end
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

-- CHAT ESTILIZADO
local chatConn = nil
addToggle("🎨 Visual", "Chat Estilizado", "💬", function(s)
    if chatConn then chatConn:Disconnect() chatConn = nil end
    if not s then return end
    local function styleChatFrame()
        for _, d in ipairs(PG:GetDescendants()) do
            if d:IsA("TextLabel") and (d.Name == "ChatTextLabel" or d.Name:lower():find("chat")) then
                pcall(function()
                    d.TextStrokeTransparency = 0.4
                    d.TextStrokeColor3 = Color3.fromRGB(67, 71, 84)
                end)
            end
        end
    end
    styleChatFrame()
    chatConn = PG.DescendantAdded:Connect(function(o)
        if o:IsA("TextLabel") and (o.Name == "ChatTextLabel" or o.Name:lower():find("chat")) then
            task.wait(0.1)
            pcall(function()
                o.TextStrokeTransparency = 0.4
                o.TextStrokeColor3 = Color3.fromRGB(67, 71, 84)
            end)
        end
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
local currentShaderProfile = "Cinemático"
local shaderSettings = {}
local manualShaderOverrides = {}
local shaderProfiles = {
    ["Cinemático"] = {Brightness=-0.006, Contrast=0.12, Saturation=-0.13, Bloom=0.19, BloomSize=22, BloomThreshold=0.96, Blur=1.8, Rays=0.010, Density=0.14, Haze=0.62, Tint=Color3.fromRGB(226,227,238), AtmosColor=Color3.fromRGB(192,195,211), Decay=Color3.fromRGB(78,82,103)},
    ["Noir Suave"] = {Brightness=-0.018, Contrast=0.18, Saturation=-0.40, Bloom=0.09, BloomSize=18, BloomThreshold=0.98, Blur=1.1, Rays=0.002, Density=0.10, Haze=0.42, Tint=Color3.fromRGB(216,218,230), AtmosColor=Color3.fromRGB(171,175,190), Decay=Color3.fromRGB(64,69,85)},
    ["Plata Natural"] = {Brightness=0, Contrast=0.085, Saturation=-0.07, Bloom=0.12, BloomSize=20, BloomThreshold=0.97, Blur=0.7, Rays=0.006, Density=0.075, Haze=0.48, Tint=Color3.fromRGB(234,235,241), AtmosColor=Color3.fromRGB(208,210,220), Decay=Color3.fromRGB(86,90,105)},
    ["Rendimiento"] = {Brightness=0, Contrast=0.035, Saturation=-0.06, Bloom=0, BloomSize=8, BloomThreshold=1, Blur=0, Rays=0, Density=0.025, Haze=0.12, Tint=Color3.fromRGB(240,240,244), AtmosColor=Color3.fromRGB(220,222,230), Decay=Color3.fromRGB(100,103,114)},
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
    local pos = cam.CFrame.Position + cam.CFrame.LookVector * 2500 + Vector3.new(0,800,0)
    bhModel = Instance.new("Model")
    bhModel.Name = "CosmicAddon_BH"
    local core = Instance.new("Part")
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(500,500,500)
    core.Color = Color3.new(0,0,0)
    core.Material = Enum.Material.SmoothPlastic
    core.Anchored = true; core.CanCollide = false; core.CastShadow = false
    core.Parent = bhModel
    for _, l in ipairs({
        {size=530, color=Color3.fromRGB(45,43,60),  trans=0.68},
        {size=590, color=Color3.fromRGB(76,72,96), trans=0.80},
        {size=670, color=Color3.fromRGB(105,101,126), trans=0.88},
        {size=780, color=Color3.fromRGB(143,139,158), trans=0.93},
        {size=920, color=Color3.fromRGB(178,175,190), trans=0.97},
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
        {size=850, thick=10, color=Color3.fromRGB(112,106,125),  tilt=8,  speed=0.24},
        {size=1000,thick=8,  color=Color3.fromRGB(137,132,150),  tilt=22, speed=-0.28},
        {size=1150,thick=6,  color=Color3.fromRGB(91,96,116),  tilt=38, speed=0.20},
        {size=1350,thick=5,  color=Color3.fromRGB(151,147,166), tilt=52, speed=-0.24},
        {size=1600,thick=4,  color=Color3.fromRGB(117,122,141), tilt=68, speed=0.18},
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
        e.Rate = 12; e.Lifetime = NumberRange.new(2,3)
        e.Speed = NumberRange.new(14,38)
        e.SpreadAngle = Vector2.new(0,360)
        e.Rotation = NumberRange.new(0,360)
        e.RotSpeed = NumberRange.new(-360,360)
        e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,5), NumberSequenceKeypoint.new(1,0)})
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
    coreLight.Brightness = 0.22; coreLight.Range = 420; coreLight.Shadows = false
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
        core.Size = Vector3.new(500*pulse, 500*pulse, 500*pulse)
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

addToggle("🎮 Extras", "Música Cósmica de Fondo", "🎵", function(s)
    if s then ambientMusic:Play() else ambientMusic:Stop() end
end, Color3.fromRGB(100,220,200))

-- FUEGOS ARTIFICIALES
local victoryInit = false
addToggle("🎮 Extras", "Fuegos Artificiales", "🎆", function(s)
    if not s or victoryInit then return end
    victoryInit = true
    LP.CharacterAdded:Connect(function()
        task.wait(2)
        for i = 1, 5 do
            task.wait(0.3)
            local cam = Workspace.CurrentCamera
            local pos = cam.CFrame.Position + cam.CFrame.LookVector * 15 + Vector3.new(math.random(-8,8), 5, math.random(-8,8))
            local p = Instance.new("Part")
            p.Size = Vector3.new(0.5,0.5,0.5)
            p.Position = pos
            p.Color = Color3.fromRGB(165, 162, 180)
            p.Material = Enum.Material.SmoothPlastic
            p.Anchored = true; p.CanCollide = false; p.CastShadow = false
            p.Parent = Workspace
            local e = Instance.new("ParticleEmitter")
            e.Texture = "rbxassetid://243660364"
            e.Rate = 0; e.Lifetime = NumberRange.new(1,2)
            e.Speed = NumberRange.new(10,20)
            e.SpreadAngle = Vector2.new(180,180)
            e.Size = NumberSequence.new(1, 0)
            e.Color = ColorSequence.new(p.Color, Color3.new(1,1,1))
            e.LightEmission = 0.18
            e.Parent = p
            e:Emit(24)
            task.delay(1, function() p:Destroy() end)
        end
    end)
end, Color3.fromRGB(255,100,255))

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
    Ninja     = {name="Ninja",     emoji="🥷", color=Color3.fromRGB(80,80,100),
        idle1="507766666", idle2="507766951", walk="507777826", run="507767714",
        jump="507765000", fall="507767968", climb="507765644", swim="507784897", swimidle="507785072"},
    Zombie    = {name="Zombie",    emoji="🧟", color=Color3.fromRGB(100,150,60),
        idle1="616007055", idle2="616007055", walk="616013277", run="616010382",
        jump="616005596", fall="616008714", climb="616004889", swim="616011038", swimidle="616011530"},
    Robot     = {name="Robot",     emoji="🤖", color=Color3.fromRGB(150,150,180),
        idle1="616088211", idle2="616088211", walk="616090535", run="616087089",
        jump="616091356", fall="616088572", climb="616086752", swim="616092463", swimidle="616092747"},
    Mage      = {name="Mage",      emoji="🧙", color=Color3.fromRGB(150,100,255),
        idle1="616116862", idle2="616116862", walk="616119968", run="616117752",
        jump="616121113", fall="616118786", climb="616115240", swim="616119016", swimidle="616119950"},
    Pirate    = {name="Pirate",    emoji="🏴‍☠️", color=Color3.fromRGB(180,120,60),
        idle1="750781874", idle2="750781874", walk="750782230", run="750780456",
        jump="750782743", fall="750781482", climb="750780221", swim="750784051", swimidle="750783897"},
    Astronaut = {name="Astronaut", emoji="👨‍🚀", color=Color3.fromRGB(200,200,220),
        idle1="891621366", idle2="891621366", walk="891633237", run="891627522",
        jump="891617961", fall="891621292", climb="891623919", swim="891644907", swimidle="891641655"},
}

-- Guarda los IDs originales del rig y actualiza solo la subanimación solicitada.
local originalAnimIdsByPath = nil
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
    if originalAnimIdsByPath then return end
    originalAnimIdsByPath = {}
    for _, item in ipairs(animate:GetDescendants()) do
        if item:IsA("Animation") then
            originalAnimIdsByPath[relativeAnimationPath(item, animate)] = item.AnimationId
        end
    end
end

local function setAnimId(animate, category, subName, id)
    local cat = animate:FindFirstChild(category)
    if not cat then return 0 end

    local target = cat
    if subName then
        target = cat:FindFirstChild(subName) or cat:FindFirstChild(subName, true)
        if not target then return 0 end
    end

    local changed = 0
    if target:IsA("Animation") then
        target.AnimationId = "rbxassetid://" .. tostring(id)
        return 1
    end
    for _, item in ipairs(target:GetDescendants()) do
        if item:IsA("Animation") then
            item.AnimationId = "rbxassetid://" .. tostring(id)
            changed += 1
        end
    end
    return changed
end

local function restoreOriginalAnimations(animate)
    if not originalAnimIdsByPath then return false end
    local restored = 0
    for _, item in ipairs(animate:GetDescendants()) do
        if item:IsA("Animation") then
            local originalId = originalAnimIdsByPath[relativeAnimationPath(item, animate)]
            if originalId and originalId ~= "" then
                item.AnimationId = originalId
                restored += 1
            end
        end
    end
    return restored > 0
end

local currentPackage = "Default"
local applyingPackage = false
local function refreshCharacterAnimator(char, animate)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if track.Priority == Enum.AnimationPriority.Core
                or track.Priority == Enum.AnimationPriority.Idle
                or track.Priority == Enum.AnimationPriority.Movement then
                pcall(function() track:Stop(0.12) end)
            end
        end
    end

    -- Reiniciar Animate hace que vuelva a leer los AnimationId editados.
    if animate and animate:IsA("BaseScript") then
        local wasDisabled = false
        pcall(function() wasDisabled = animate.Disabled end)
        if not wasDisabled then
            pcall(function() animate.Disabled = true end)
            task.wait(0.08)
            pcall(function() animate.Disabled = false end)
        end
    end
end

local function applyPackage(pkg)
    if applyingPackage then return end
    applyingPackage = true
    local char = LP.Character or LP.CharacterAdded:Wait()
    local animate = char:WaitForChild("Animate", 8)
    if animate then
        animate:WaitForChild("idle", 4)
        animate:WaitForChild("walk", 4)
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
            -- Compatibilidad con el Animate clásico si no se pudieron capturar IDs.
            setAnimId(animate, "idle", "Animation1", "507766666")
            setAnimId(animate, "idle", "Animation2", "507766951")
            setAnimId(animate, "walk", "WalkAnim", "507777826")
            setAnimId(animate, "run", "RunAnim", "507767714")
            setAnimId(animate, "jump", "JumpAnim", "507765000")
            setAnimId(animate, "fall", "FallAnim", "507767968")
            setAnimId(animate, "climb", "ClimbAnim", "507765644")
            setAnimId(animate, "swim", "Swim", "507784897")
            setAnimId(animate, "swimidle", "SwimIdle", "507785072")
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

LP.CharacterAdded:Connect(function(char)
    task.spawn(function()
        char:WaitForChild("Humanoid", 8)
        char:WaitForChild("Animate", 8)
        task.wait(0.3)
        if currentPackage ~= "Default" then
            applyPackage(currentPackage)
        end
    end)
end)

addSection("🎭 Anim", "PAQUETES DE ANIMACIÓN")
for pkgName, cfg in pairs(animPackages) do
    addAction("🎭 Anim", cfg.name, cfg.emoji, function() applyPackage(pkgName) end, cfg.color)
end

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
    ["Grafito"] = {background=Color3.fromRGB(15,17,22), panel=Color3.fromRGB(24,27,34), panelHover=Color3.fromRGB(34,37,46), accent=Color3.fromRGB(142,145,158), accentSoft=Color3.fromRGB(104,108,123), text=Color3.fromRGB(226,227,233), mutedText=Color3.fromRGB(153,157,169), enabled=Color3.fromRGB(132,153,143), disabled=Color3.fromRGB(82,87,99), border=Color3.fromRGB(59,64,76)},
    ["Niebla"] = {background=Color3.fromRGB(19,21,25), panel=Color3.fromRGB(29,31,37), panelHover=Color3.fromRGB(39,42,49), accent=Color3.fromRGB(159,160,166), accentSoft=Color3.fromRGB(113,115,124), text=Color3.fromRGB(232,232,235), mutedText=Color3.fromRGB(164,165,171), enabled=Color3.fromRGB(145,158,149), disabled=Color3.fromRGB(89,91,98), border=Color3.fromRGB(68,70,78)},
    ["Medianoche"] = {background=Color3.fromRGB(12,17,23), panel=Color3.fromRGB(20,27,35), panelHover=Color3.fromRGB(30,38,48), accent=Color3.fromRGB(128,148,163), accentSoft=Color3.fromRGB(91,111,127), text=Color3.fromRGB(222,229,234), mutedText=Color3.fromRGB(147,160,170), enabled=Color3.fromRGB(126,151,143), disabled=Color3.fromRGB(75,88,99), border=Color3.fromRGB(49,63,74)},
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
    tabsBar.BackgroundColor3 = THEME.panel
    minIcon.BackgroundColor3 = THEME.background
    minIcon.TextColor3 = THEME.text
    minStroke.Color = THEME.border
    for _, obj in ipairs(main:GetDescendants()) do
        if obj:GetAttribute("ThemePanel") then obj.BackgroundColor3 = THEME.panel end
        if obj:GetAttribute("ThemeStroke") and obj:IsA("UIStroke") then obj.Color = THEME.border end
        if obj:GetAttribute("ThemeAccent") then obj.BackgroundColor3 = THEME.accent end
        if obj:GetAttribute("ThemeText") and obj:IsA("TextLabel") then obj.TextColor3 = THEME.text end
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
addAction("⚙ Ajustes", "Medianoche · azul grisáceo", "◈", function() applyTheme("Medianoche") end)

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
addAction("⚙ Ajustes", "Rendimiento · efectos mínimos", "▣", function() chooseShaderProfile("Rendimiento") end)

addSection("⚙ Ajustes", "AJUSTE MANUAL DE SHADERS")
addSlider("⚙ Ajustes", "Bloom · brillo de luces", 0, 0.30, shaderSettings.Bloom or 0.16, 0.01, function(v) return string.format("%.2f", v) end, function(v)
    shaderSettings.Bloom = v
    manualShaderOverrides.Bloom = v
    if shaderRefs.Bloom and shaderRefs.Bloom.Parent then shaderRefs.Bloom.Intensity = v end
end)
addSlider("⚙ Ajustes", "Blur ambiental · suave", 0, 6, shaderSettings.Blur or 1.8, 0.1, function(v) return string.format("%.1f", v) end, function(v)
    shaderSettings.Blur = v
    manualShaderOverrides.Blur = v
    if shaderRefs.Blur and shaderRefs.Blur.Parent then shaderRefs.Blur.Size = v end
end)
addSlider("⚙ Ajustes", "Contraste", 0, 0.30, shaderSettings.Contrast or 0.13, 0.01, function(v) return string.format("%.2f", v) end, function(v)
    shaderSettings.Contrast = v
    manualShaderOverrides.Contrast = v
    if shaderRefs.Color and shaderRefs.Color.Parent then shaderRefs.Color.Contrast = v end
end)
addSlider("⚙ Ajustes", "Saturación · menor = más sobrio", -0.55, 0.15, shaderSettings.Saturation or -0.17, 0.01, function(v) return string.format("%.2f", v) end, function(v)
    shaderSettings.Saturation = v
    manualShaderOverrides.Saturation = v
    if shaderRefs.Color and shaderRefs.Color.Parent then shaderRefs.Color.Saturation = v end
end)
addSlider("⚙ Ajustes", "Brillo de color", -0.08, 0.06, shaderSettings.Brightness or -0.018, 0.005, function(v) return string.format("%.3f", v) end, function(v)
    shaderSettings.Brightness = v
    manualShaderOverrides.Brightness = v
    if shaderRefs.Color and shaderRefs.Color.Parent then shaderRefs.Color.Brightness = v end
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
    notify("Ajustes visuales restaurados", THEME.mutedText)
end)

-- ============================================================
-- MENSAJE INICIAL
-- ============================================================
task.delay(0.8, function()
    notify("COSMIC VISUAL PLUS cargado", THEME.accent)
    task.wait(0.5)
    notify("Blur suave · nombres y animaciones estables", THEME.mutedText)
    task.wait(0.5)
    notify("Interfaz lista", THEME.enabled)
end)

print("✦ COSMIC VISUAL PLUS — listo ✦")