-- ============================================================
-- ✦✦✦✦✦ MM2 COSMIC MEGA PACK — ULTIMATE ALL IN ONE ✦✦✦✦✦
-- 6 pestañas · 40+ módulos · 100% Client-Side
-- Incluye: Visual · Combate · MM2 · Cósmico · Extras · Anim
-- ============================================================
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
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

-- Limpieza total
if PG:FindFirstChild("MM2MegaPack") then PG.MM2MegaPack:Destroy() end
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
local ambientMusic = mkSnd("1837879088", 0.15, true)

-- ============================================================
-- UI PRINCIPAL
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "MM2MegaPack"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PG

-- NOTIFICACIONES
local notifFrame = Instance.new("Frame")
notifFrame.Name = "NotifFrame"
notifFrame.Size = UDim2.new(0, 320, 1, 0)
notifFrame.Position = UDim2.new(1, -330, 0, 0)
notifFrame.BackgroundTransparency = 1
notifFrame.Parent = gui

local notifStack = {}
local function notify(text, color)
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

-- FRAME PRINCIPAL
local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, 0, 0, 0)
main.Position = UDim2.new(0, 20, 0.5, -320)
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

TweenService:Create(main, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 420, 0, 620)
}):Play()

-- TÍTULO
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -70, 0, 36)
titleLbl.Position = UDim2.new(0, 16, 0, 8)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "✦ MM2 COSMIC ULTIMATE ✦"
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
subTitle.Text = "40+ módulos · 6 pestañas · 100% local"
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
minBtn.Parent = main
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

local minIcon = Instance.new("TextButton")
minIcon.Size = UDim2.new(0, 55, 0, 55)
minIcon.Position = UDim2.new(0, 15, 0, 15)
minIcon.BackgroundColor3 = THEME.background
minIcon.Text = "✨"
minIcon.TextSize = 26
minIcon.Visible = false
minIcon.AutoButtonColor = false
minIcon.Parent = gui
Instance.new("UICorner", minIcon).CornerRadius = UDim.new(0, 12)
local minStroke = Instance.new("UIStroke")
minStroke.Color = THEME.accentSoft
minStroke.Thickness = 2
minStroke.Parent = minIcon

local isMin = false
minBtn.MouseButton1Click:Connect(function()
    if isMin then return end
    clickSfx:Play()
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
    clickSfx:Play()
    isMin = false
    minIcon.Visible = false
    main.Visible = true
    main.Size = UDim2.new(0,0,0,0)
    main.Position = UDim2.new(0, 20, 0.5, -320)
    main.BackgroundTransparency = 0
    TweenService:Create(main, TweenInfo.new(0.45, Enum.EasingStyle.Back), {Size = UDim2.new(0,420,0,620)}):Play()
end)

-- ============================================================
-- SISTEMA DE PESTAÑAS (6)
-- ============================================================
local tabsBar = Instance.new("Frame")
tabsBar.Name = "TabsBar"
tabsBar.Size = UDim2.new(1, -32, 0, 32)
tabsBar.Position = UDim2.new(0, 16, 0, 64)
tabsBar.BackgroundColor3 = THEME.panel
tabsBar.BorderSizePixel = 0
tabsBar.Parent = main
Instance.new("UICorner", tabsBar).CornerRadius = UDim.new(0, 8)

local tabs = {
    {name = "🎨 Visual",  color = THEME.accent},
    {name = "⚔️ Combate", color = THEME.accent},
    {name = "🎯 MM2",     color = THEME.accent},
    {name = "🌌 Cósmico", color = THEME.accent},
    {name = "🎮 Extras",  color = THEME.accent},
    {name = "🎭 Anim",    color = THEME.accent},
}

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
        clickSfx:Play()
        for n, c in pairs(tabContents) do c.Visible = (n == tab.name) end
        for n, d in pairs(tabButtons) do
            TweenService:Create(d.btn, TweenInfo.new(0.2), {
                BackgroundColor3 = (n == tab.name) and d.color or THEME.panel
            }):Play()
        end
    end)
    btn.MouseEnter:Connect(function()
        hoverSfx:Play()
    end)

    return content
end

for i, t in ipairs(tabs) do createTab(t, i) end

-- ============================================================
-- HELPER TOGGLE
-- ============================================================
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
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local bst = Instance.new("UIStroke")
    bst.Color = accentColor
    bst.Thickness = 1.5
    bst.Transparency = 0.5
    bst.Parent = b

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = emoji .. " " .. text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = THEME.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = b

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 10, 0, 10)
    ind.Position = UDim2.new(1, -20, 0.5, -5)
    ind.BackgroundColor3 = THEME.disabled
    ind.BorderSizePixel = 0
    ind.Parent = b
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1,0)

    local state = false
    b.MouseEnter:Connect(function()
        hoverSfx:Play()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = THEME.panelHover}):Play()
        TweenService:Create(bst, TweenInfo.new(0.2), {Transparency = 0, Thickness = 2.5}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = THEME.panel}):Play()
        TweenService:Create(bst, TweenInfo.new(0.2), {Transparency = 0.5, Thickness = 1.5}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        state = not state
        ind.BackgroundColor3 = state and THEME.enabled or THEME.disabled
        if state then onSfx:Play() else offSfx:Play() end
        TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(0.97,0,0,40)}):Play()
        task.wait(0.1)
        TweenService:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(1,0,0,42)}):Play()
        pcall(cb, state)
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
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local bst = Instance.new("UIStroke")
    bst.Color = accentColor
    bst.Thickness = 1.5
    bst.Transparency = 0.5
    bst.Parent = b

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = emoji .. " " .. text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = THEME.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = b

    b.MouseEnter:Connect(function()
        hoverSfx:Play()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = THEME.panelHover}):Play()
        TweenService:Create(bst, TweenInfo.new(0.2), {Transparency = 0, Thickness = 2.5}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = THEME.panel}):Play()
        TweenService:Create(bst, TweenInfo.new(0.2), {Transparency = 0.5, Thickness = 1.5}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        onSfx:Play()
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
    sep.BackgroundColor3 = color or THEME.border
    sep.BorderSizePixel = 0
    sep.Parent = content
    Instance.new("UICorner", sep).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.Position = UDim2.new(0, 0, 0, yPos + 12)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 12
    lbl.TextColor3 = color or THEME.text
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = content
    content.CanvasSize = UDim2.new(0, 0, 0, yPos + 42)
end

-- ============================================================
-- ✦ PESTAÑA VISUAL ✦
-- ============================================================

-- FUENTES
local fontData = {
    Orbitron  = {url = "https://github.com/google/fonts/raw/main/ofl/orbitron/Orbitron%5Bwght%5D.ttf", name = "CosmicOrbitron"},
    Audiowide = {url = "https://github.com/google/fonts/raw/main/ofl/audiowide/Audiowide-Regular.ttf", name = "CosmicAudiowide"},
    RussoOne  = {url = "https://github.com/google/fonts/raw/main/ofl/russoone/RussoOne-Regular.ttf", name = "CosmicRusso"},
    Michroma  = {url = "https://github.com/google/fonts/raw/main/ofl/michroma/Michroma-Regular.ttf", name = "CosmicMichroma"},
}
local fontConns = {}

local function applyFont(key)
    local data = fontData[key]
    if not data then return end
    local ttf = data.name .. ".ttf"
    local json = data.name .. ".json"
    local ok = pcall(function()
        if not isfile(ttf) then writefile(ttf, game:HttpGet(data.url)) end
    end)
    if not ok then notify("❌ Error con " .. key, Color3.fromRGB(255,100,100)) return end
    local fontObj
    pcall(function()
        writefile(json, HttpService:JSONEncode({
            name = data.name,
            faces = {{name = "Regular", weight = 400, style = "normal", assetId = getcustomasset(ttf)}}
        }))
        fontObj = Font.new(getcustomasset(json))
    end)
    if not fontObj then return end

    for _, c in ipairs(fontConns) do c:Disconnect() end
    fontConns = {}

    local iconFont = tostring(Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"))
    local function change(obj)
        if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
        local cur = tostring(obj.FontFace)
        if cur == iconFont or string.find(cur, "BuilderIcons") then return end
        pcall(function() obj.FontFace = fontObj end)
    end
    for _, v in ipairs(game:GetDescendants()) do task.spawn(change, v) end
    table.insert(fontConns, game.DescendantAdded:Connect(function(o) task.spawn(change, o) end))
    notify("✅ Fuente " .. key, Color3.fromRGB(100,255,150))
end

addToggle("🎨 Visual", "Fuente Orbitron",  "🔤", function(s) if s then applyFont("Orbitron") end end)
addToggle("🎨 Visual", "Fuente Audiowide", "🔤", function(s) if s then applyFont("Audiowide") end end)
addToggle("🎨 Visual", "Fuente Russo One", "🔤", function(s) if s then applyFont("RussoOne") end end)
addToggle("🎨 Visual", "Fuente Michroma",  "🔤", function(s) if s then applyFont("Michroma") end end)

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
        e.Rate = 8; e.Lifetime = NumberRange.new(1.4,2.4)
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

-- NOMBRES MONOCROMÁTICOS
local nameConns = {}
addToggle("🎨 Visual", "Nombres Monocromáticos", "🏷️", function(s)
    for _, c in ipairs(nameConns) do c:Disconnect() end
    nameConns = {}
    if not s then return end
    local function process(char)
        local head = char:FindFirstChild("Head")
        if not head then return end
        local gui3d = head:FindFirstChildOfClass("BillboardGui")
        if gui3d then
            local label = gui3d:FindFirstChildOfClass("TextLabel")
            if label then
                label.TextColor3 = Color3.fromRGB(205, 205, 218)
            end
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then process(p.Character) end
        table.insert(nameConns, p.CharacterAdded:Connect(function(char)
            task.wait(0.25)
            process(char)
        end))
    end
    table.insert(nameConns, Players.PlayerAdded:Connect(function(p)
        table.insert(nameConns, p.CharacterAdded:Connect(function(char)
            task.wait(0.25)
            process(char)
        end))
    end))
end, THEME.accent)

-- NOMBRE PERSONAL
local customNameObj = nil
addToggle("🎨 Visual", "Nombre Personal Degradado", "💫", function(s)
    if customNameObj then customNameObj:Destroy() customNameObj = nil end
    if not s then return end
    local char = LP.Character or LP.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "✦ " .. LP.DisplayName .. " ✦"
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 20
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextStrokeTransparency = 0.4
    lbl.Parent = bb
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 153, 174)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(232, 232, 238)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(171, 174, 190)),
    })
    grad.Parent = lbl
    customNameObj = bb
end, THEME.accent)

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
                    d.TextStrokeColor3 = Color3.fromRGB(80, 30, 130)
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
                o.TextStrokeColor3 = Color3.fromRGB(80, 30, 130)
            end)
        end
    end)
end, Color3.fromRGB(150,200,255))

-- ============================================================
-- ✦ PESTAÑA COMBATE ✦
-- ============================================================

local rainbowConn = nil
addToggle("⚔️ Combate", "Skin Grafito de Armas", "◈", function(s)
    if rainbowConn then rainbowConn:Disconnect() rainbowConn = nil end
    if not s then return end
    rainbowConn = RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char then return end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                for _, p in ipairs(tool:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Color = Color3.fromRGB(133, 135, 148)
                        p.Material = Enum.Material.SmoothPlastic
                    end
                end
            end
        end
    end)
end, THEME.accent)

-- ANIMACIONES DE ARMAS
local animCfg = {
    Knife   = {equip = "rbxassetid://2467567750", attack = "rbxassetid://2467577524"},
    Gun     = {equip = "rbxassetid://1957618848"},
    Default = {equip = "rbxassetid://2470501967"},
}
local function setupAnims(char)
    local hum = char:WaitForChild("Humanoid")
    local anim = hum:WaitForChild("Animator")
    char.ChildAdded:Connect(function(tool)
        if not tool:IsA("Tool") then return end
        local cfg = animCfg[tool.Name] or animCfg.Default
        local a = Instance.new("Animation")
        a.AnimationId = cfg.equip
        pcall(function() anim:LoadAnimation(a):Play() end)
        if cfg.attack then
            tool.Activated:Connect(function()
                local aa = Instance.new("Animation")
                aa.AnimationId = cfg.attack
                pcall(function() anim:LoadAnimation(aa):Play() end)
            end)
        end
    end)
end
addToggle("⚔️ Combate", "Animaciones de Armas", "🗡️", function(s)
    if s then setupAnims(LP.Character or LP.CharacterAdded:Wait()) end
end, Color3.fromRGB(100,180,255))

-- ESTELA PARTÍCULAS ARMAS
local wTrailConn = nil
addToggle("⚔️ Combate", "Estela de Partículas en Armas", "💫", function(s)
    if wTrailConn then wTrailConn:Disconnect() wTrailConn = nil end
    if not s then return end
    local function attach(char)
        char.ChildAdded:Connect(function(tool)
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local e = Instance.new("ParticleEmitter")
                    e.Texture = "rbxassetid://243660364"
                    e.Rate = 80; e.Lifetime = NumberRange.new(0.5,1)
                    e.Speed = NumberRange.new(2,5)
                    e.SpreadAngle = Vector2.new(180,180)
                    e.Size = NumberSequence.new(0.5, 0)
                    e.Color = ColorSequence.new(Color3.fromRGB(200,150,255), Color3.new(1,1,1))
                    e.LightEmission = 1
                    e.Parent = handle
                end
            end
        end)
    end
    if LP.Character then attach(LP.Character) end
    wTrailConn = LP.CharacterAdded:Connect(attach)
end, Color3.fromRGB(200,150,255))

-- TRAZADORAS
local function setupTracerGun(tool)
    if not tool:IsA("Tool") or not tool.Name:lower():find("gun") then return end
    tool.Activated:Connect(function()
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end
        local flash = Instance.new("Part")
        flash.Shape = Enum.PartType.Ball
        flash.Size = Vector3.new(1.5,1.5,1.5)
        flash.Color = Color3.fromRGB(255,200,100)
        flash.Material = Enum.Material.Neon
        flash.Anchored = true; flash.CanCollide = false; flash.CastShadow = false
        flash.CFrame = handle.CFrame * CFrame.new(0,0,-1)
        flash.Parent = Workspace
        local fl = Instance.new("PointLight")
        fl.Color = Color3.fromRGB(255,200,100)
        fl.Brightness = 10; fl.Range = 20
        fl.Parent = flash
        TweenService:Create(flash, TweenInfo.new(0.15), {
            Size = Vector3.new(3,3,3), Transparency = 1
        }):Play()
        task.delay(0.2, function() flash:Destroy() end)
        local cam = Workspace.CurrentCamera
        local target = cam.CFrame.Position + cam.CFrame.LookVector * 500
        local start = handle.Position
        local dist = (target-start).Magnitude
        local tracer = Instance.new("Part")
        tracer.Size = Vector3.new(0.15,0.15,dist)
        tracer.CFrame = CFrame.lookAt(start, target) * CFrame.new(0,0,-dist/2)
        tracer.Color = Color3.fromRGB(255,220,150)
        tracer.Material = Enum.Material.Neon
        tracer.Anchored = true; tracer.CanCollide = false; tracer.CastShadow = false
        tracer.Parent = Workspace
        TweenService:Create(tracer, TweenInfo.new(0.3), {
            Transparency = 1, Size = Vector3.new(0.05,0.05,dist)
        }):Play()
        task.delay(0.35, function() tracer:Destroy() end)
    end)
end
addToggle("⚔️ Combate", "Trazadoras + Fogonazo", "🔫", function(s)
    if not s then return end
    local function attach(char)
        char.ChildAdded:Connect(setupTracerGun)
    end
    if LP.Character then attach(LP.Character) end
    LP.CharacterAdded:Connect(attach)
end, Color3.fromRGB(255,220,150))

-- BOMBA
local bombInit = false
addToggle("⚔️ Combate", "Bomba Cinematográfica", "💣", function(s)
    if not s or bombInit then return end
    bombInit = true
    Workspace.ChildAdded:Connect(function(obj)
        if not obj.Name:lower():find("bomb") then return end
        task.spawn(function()
            local cam = Workspace.CurrentCamera
            local t = 0
            while t < 1.5 do
                t = t + RunService.Heartbeat:Wait()
                cam.CFrame = cam.CFrame * CFrame.new(math.random(-3,3)/10, math.random(-3,3)/10, 0)
            end
        end)
        local wave = Instance.new("Part")
        wave.Shape = Enum.PartType.Ball
        wave.Size = Vector3.new(1,1,1)
        wave.Position = obj.Position
        wave.Anchored = true; wave.CanCollide = false; wave.CastShadow = false
        wave.Material = Enum.Material.Neon
        wave.Color = Color3.fromRGB(255,200,100)
        wave.Transparency = 0.4
        wave.Parent = Workspace
        TweenService:Create(wave, TweenInfo.new(1.2), {
            Size = Vector3.new(60,60,60), Transparency = 1
        }):Play()
        task.delay(1.3, function() wave:Destroy() end)
        local fireP = Instance.new("Part")
        fireP.Size = Vector3.new(1,1,1)
        fireP.Transparency = 1
        fireP.Anchored = true; fireP.CanCollide = false
        fireP.Position = obj.Position
        fireP.Parent = Workspace
        local fe = Instance.new("ParticleEmitter")
        fe.Texture = "rbxassetid://243660364"
        fe.Rate = 100; fe.Lifetime = NumberRange.new(1,2)
        fe.Speed = NumberRange.new(15,30)
        fe.SpreadAngle = Vector2.new(180,180)
        fe.Size = NumberSequence.new(3, 0)
        fe.Color = ColorSequence.new(Color3.fromRGB(255,100,0), Color3.fromRGB(255,255,0))
        fe.LightEmission = 1
        fe.Parent = fireP
        task.delay(3, function() fireP:Destroy() end)
    end)
end, Color3.fromRGB(255,130,100))

-- EXPLOSIÓN AL MORIR
local deathInit = false
addToggle("⚔️ Combate", "Explosión Cósmica al Morir", "💀", function(s)
    if not s or deathInit then return end
    deathInit = true
    LP.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for i = 1, 30 do
                local p = Instance.new("Part")
                p.Shape = Enum.PartType.Ball
                p.Size = Vector3.new(0.8,0.8,0.8)
                p.Position = hrp.Position
                p.Anchored = true; p.CanCollide = false; p.CastShadow = false
                p.Material = Enum.Material.SmoothPlastic
                p.Color = Color3.fromRGB(137, 134, 153)
                p.Parent = Workspace
                TweenService:Create(p, TweenInfo.new(1.5), {
                    Position = hrp.Position + Vector3.new(math.random(-15,15), math.random(5,20), math.random(-15,15)),
                    Transparency = 1,
                    Size = Vector3.new(0.1,0.1,0.1)
                }):Play()
                task.delay(1.6, function() p:Destroy() end)
            end
        end)
    end)
end, Color3.fromRGB(255,100,100))

-- KILL FEED
addToggle("⚔️ Combate", "Kill Feed Estilizado", "📰", function(s)
    if not s then return end
    local function styleEl(d)
        pcall(function()
            d.TextStrokeTransparency = 0.3
            d.TextStrokeColor3 = Color3.fromRGB(100,0,150)
            d.TextColor3 = Color3.fromRGB(255,220,255)
        end)
    end
    for _, d in ipairs(PG:GetDescendants()) do
        if d:IsA("TextLabel") and d.Parent and (d.Parent.Name:lower():find("kill") or (d.Parent.Parent and d.Parent.Parent.Name:lower():find("kill"))) then
            styleEl(d)
        end
    end
    PG.DescendantAdded:Connect(function(d)
        if d:IsA("TextLabel") then
            local parent = d.Parent
            if parent and (parent.Name:lower():find("kill") or (parent.Parent and parent.Parent.Name:lower():find("kill"))) then
                styleEl(d)
            end
        end
    end)
end, Color3.fromRGB(255,220,255))

-- IMPACTO/SANGRE
local hitInit = false
addToggle("⚔️ Combate", "Efecto de Impacto/Sangre", "🩸", function(s)
    if not s or hitInit then return end
    hitInit = true
    local function watch(p)
        local function attach(char)
            local hum = char:WaitForChild("Humanoid")
            hum.HealthChanged:Connect(function(newH)
                if newH < hum.MaxHealth and newH > 0 then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    for i = 1, 6 do
                        local part = Instance.new("Part")
                        part.Shape = Enum.PartType.Ball
                        part.Size = Vector3.new(0.3,0.3,0.3)
                        part.Position = hrp.Position
                        part.Color = Color3.fromRGB(200,30,50)
                        part.Material = Enum.Material.Neon
                        part.Anchored = true; part.CanCollide = false; part.CastShadow = false
                        part.Parent = Workspace
                        TweenService:Create(part, TweenInfo.new(0.6), {
                            Position = part.Position + Vector3.new(math.random(-30,30)/10, math.random(0,20)/10, math.random(-30,30)/10),
                            Transparency = 1, Size = Vector3.new(0.05,0.05,0.05)
                        }):Play()
                        task.delay(0.7, function() part:Destroy() end)
                    end
                end
            end)
        end
        if p.Character then attach(p.Character) end
        p.CharacterAdded:Connect(attach)
    end
    for _, p in ipairs(Players:GetPlayers()) do watch(p) end
    Players.PlayerAdded:Connect(watch)
end, Color3.fromRGB(200,50,80))

-- ============================================================
-- ✦ PESTAÑA MM2 ✦
-- ============================================================

local roleConns = {}
addToggle("🎯 MM2", "Colores de Rol (🔴/🔵/⚪)", "🎭", function(s)
    for _, c in ipairs(roleConns) do c:Disconnect() end
    roleConns = {}
    if not s then return end
    local function process(char, plr)
        local head = char:FindFirstChild("Head")
        if not head then return end
        task.spawn(function()
            task.wait(1)
            local isMurderer, isSheriff = false, false
            local bp = plr:FindFirstChild("Backpack")
            local function check(t)
                if t:IsA("Tool") then
                    if t.Name:lower():find("knife") then isMurderer = true end
                    if t.Name:lower():find("gun") then isSheriff = true end
                end
            end
            if bp then for _, i in ipairs(bp:GetChildren()) do check(i) end end
            for _, i in ipairs(char:GetChildren()) do check(i) end
            local hl = head:FindFirstChild("RoleHL") or Instance.new("Highlight")
            hl.Name = "RoleHL"
            hl.Parent = head
            hl.FillTransparency = 0.7
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            if isMurderer then
                hl.FillColor = Color3.fromRGB(255,30,30)
                hl.OutlineColor = Color3.fromRGB(255,80,80)
            elseif isSheriff then
                hl.FillColor = Color3.fromRGB(30,100,255)
                hl.OutlineColor = Color3.fromRGB(80,150,255)
            elseif plr == LP then
                hl.FillColor = Color3.fromRGB(100,255,150)
                hl.OutlineColor = Color3.fromRGB(150,255,200)
            else
                hl.FillColor = Color3.fromRGB(200,200,200)
                hl.OutlineColor = Color3.fromRGB(255,255,255)
            end
        end)
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then process(p.Character, p) end
        table.insert(roleConns, p.CharacterAdded:Connect(function(c) process(c, p) end))
    end
end, Color3.fromRGB(255,100,100))

-- GLOW ARMA POR ROL
local roleGlowConn = nil
addToggle("🎯 MM2", "Glow de Arma por Rol", "🔦", function(s)
    if roleGlowConn then roleGlowConn:Disconnect() roleGlowConn = nil end
    if not s then return end
    roleGlowConn = RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char then return end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local light = handle:FindFirstChild("RoleGlow") or Instance.new("PointLight")
                    light.Name = "RoleGlow"
                    light.Range = 15; light.Brightness = 4; light.Shadows = false
                    light.Parent = handle
                    if tool.Name:lower():find("knife") then
                        light.Color = Color3.fromRGB(255,40,40)
                    elseif tool.Name:lower():find("gun") then
                        light.Color = Color3.fromRGB(40,120,255)
                    else
                        light.Color = Color3.fromRGB(255,255,255)
                    end
                end
            end
        end
    end)
end, Color3.fromRGB(255,150,100))

-- MONEDAS
local coinConns = {}
addToggle("🎯 MM2", "Monedas Brillantes", "🪙", function(s)
    for _, c in ipairs(coinConns) do c:Disconnect() end
    coinConns = {}
    if not s then
        for _, o in ipairs(Workspace:GetChildren()) do
            if o.Name:lower():find("coin") and o:FindFirstChild("CoinGlow") then o.CoinGlow:Destroy() end
        end
        return
    end
    local function attach(coin)
        if coin:FindFirstChild("CoinGlow") then return end
        local h = Instance.new("Highlight")
        h.Name = "CoinGlow"
        h.FillColor = Color3.fromRGB(255,215,0)
        h.OutlineColor = Color3.fromRGB(255,255,150)
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = coin
        local l = Instance.new("PointLight")
        l.Name = "CoinGlow"
        l.Color = Color3.fromRGB(255,215,0)
        l.Brightness = 5; l.Range = 10
        l.Parent = coin
    end
    for _, o in ipairs(Workspace:GetChildren()) do
        if o.Name:lower():find("coin") then attach(o) end
    end
    table.insert(coinConns, Workspace.ChildAdded:Connect(function(o)
        if o.Name:lower():find("coin") then attach(o) end
    end))
end, Color3.fromRGB(255,215,0))

-- SALTO/ATERRIZAJE
local jumpConns = {}
addToggle("🎯 MM2", "Partículas Salto/Aterrizaje", "🦘", function(s)
    for _, c in ipairs(jumpConns) do c:Disconnect() end
    jumpConns = {}
    if not s then return end
    local function attach(char)
        local hum = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")
        table.insert(jumpConns, hum.Jumping:Connect(function()
            local p = Instance.new("Part")
            p.Size = Vector3.new(0.1,0.1,0.1)
            p.Transparency = 1
            p.Anchored = true; p.CanCollide = false
            p.CFrame = hrp.CFrame
            p.Parent = Workspace
            local e = Instance.new("ParticleEmitter")
            e.Texture = "rbxassetid://243660364"
            e.Rate = 0; e.Lifetime = NumberRange.new(0.5,1)
            e.Speed = NumberRange.new(3,8)
            e.SpreadAngle = Vector2.new(180,180)
            e.Size = NumberSequence.new(0.5, 0)
            e.Color = ColorSequence.new(Color3.fromRGB(150,200,255), Color3.new(1,1,1))
            e.LightEmission = 1
            e.Parent = p
            e:Emit(15)
            task.delay(1.2, function() p:Destroy() end)
        end))
        table.insert(jumpConns, hum.StateChanged:Connect(function(old, new)
            if new == Enum.HumanoidStateType.Landed and old == Enum.HumanoidStateType.Freefall then
                local p = Instance.new("Part")
                p.Size = Vector3.new(0.1,0.1,0.1)
                p.Transparency = 1
                p.Anchored = true; p.CanCollide = false
                p.CFrame = hrp.CFrame
                p.Parent = Workspace
                local e = Instance.new("ParticleEmitter")
                e.Texture = "rbxassetid://243660364"
                e.Rate = 0; e.Lifetime = NumberRange.new(0.4,0.8)
                e.Speed = NumberRange.new(2,6)
                e.SpreadAngle = Vector2.new(180,180)
                e.Size = NumberSequence.new(0.4, 0)
                e.Color = ColorSequence.new(Color3.fromRGB(200,255,150), Color3.new(1,1,1))
                e.LightEmission = 1
                e.Parent = p
                e:Emit(12)
                task.delay(1, function() p:Destroy() end)
            end
        end))
    end
    if LP.Character then attach(LP.Character) end
    LP.CharacterAdded:Connect(attach)
end, Color3.fromRGB(150,200,255))

-- RASTRO PASOS
local stepConn = nil
addToggle("🎯 MM2", "Rastro de Pasos", "👣", function(s)
    if stepConn then stepConn:Disconnect() stepConn = nil end
    if not s then return end
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local last = hrp.Position
    stepConn = RunService.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent then return end
        local cur = hrp.Position
        if (cur-last).Magnitude > 0.5 and hum.MoveDirection.Magnitude > 0.1 then
            if math.random() < 0.15 then
                local foot = Instance.new("Part")
                foot.Size = Vector3.new(0.6,0.1,0.9)
                foot.Position = Vector3.new(cur.X, cur.Y-2.5, cur.Z)
                foot.Color = Color3.fromRGB(142, 141, 158)
                foot.Material = Enum.Material.SmoothPlastic
                foot.Anchored = true; foot.CanCollide = false; foot.CastShadow = false
                foot.Parent = Workspace
                TweenService:Create(foot, TweenInfo.new(1.5), {
                    Transparency = 1, Size = Vector3.new(0.2,0.1,0.3)
                }):Play()
                task.delay(1.6, function() foot:Destroy() end)
            end
        end
        last = cur
    end)
end, Color3.fromRGB(150,200,255))

-- CERCANOS
local nearConn = nil
addToggle("🎯 MM2", "Destacar Jugadores Cercanos", "🎯", function(s)
    if nearConn then nearConn:Disconnect() nearConn = nil end
    if not s then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then local n = head:FindFirstChild("NearHL") if n then n:Destroy() end end
            end
        end
        return
    end
    nearConn = RunService.Heartbeat:Connect(function()
        local myChar = LP.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local head = p.Character:FindFirstChild("Head")
                if hrp and head then
                    local dist = (hrp.Position - myRoot.Position).Magnitude
                    local h = head:FindFirstChild("NearHL")
                    if dist < 50 then
                        if not h then
                            h = Instance.new("Highlight")
                            h.Name = "NearHL"
                            h.FillColor = Color3.fromRGB(255,255,100)
                            h.OutlineColor = Color3.fromRGB(255,200,50)
                            h.FillTransparency = 0.75
                            h.OutlineTransparency = 0.3
                            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            h.Parent = head
                        end
                    else
                        if h then h:Destroy() end
                    end
                end
            end
        end
    end)
end, Color3.fromRGB(255,255,100))

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

addToggle("🌌 Cósmico", "Sky + Nebulosas", "🌌", function(s)
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
    for i = 1, 7 do
        local n = Instance.new("Part")
        n.Shape = Enum.PartType.Ball
        local size = math.random(2200, 3600)
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

-- SHADERS CINEMÁTICOS: contraste suave, color contenido y bloom discreto.
local shaderFx = {}
local shaderAtmosphere = nil
local savedAtmosphere = nil
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
end

local function applyCinematicShaders()
    clearCinematicShaders()

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "MM2_Cinematic_Color"
    cc.Brightness = -0.018
    cc.Contrast = 0.13
    cc.Saturation = -0.17
    cc.TintColor = Color3.fromRGB(224, 225, 237)
    cc.Parent = Lighting
    table.insert(shaderFx, cc)

    local bloom = Instance.new("BloomEffect")
    bloom.Name = "MM2_Cinematic_Bloom"
    bloom.Intensity = 0.24
    bloom.Size = 22
    bloom.Threshold = 0.92
    bloom.Parent = Lighting
    table.insert(shaderFx, bloom)

    local rays = Instance.new("SunRaysEffect")
    rays.Name = "MM2_Cinematic_Rays"
    rays.Intensity = 0.018
    rays.Spread = 0.68
    rays.Parent = Lighting
    table.insert(shaderFx, rays)

    shaderAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if shaderAtmosphere then
        savedAtmosphere = {}
        for _, prop in ipairs({"Density", "Offset", "Color", "Decay", "Glare", "Haze"}) do
            pcall(function() savedAtmosphere[prop] = shaderAtmosphere[prop] end)
        end
    else
        shaderAtmosphere = Instance.new("Atmosphere")
        shaderAtmosphere.Name = "MM2_Cinematic_Atmosphere"
        shaderAtmosphere.Parent = Lighting
        table.insert(shaderFx, shaderAtmosphere)
    end
    shaderAtmosphere.Density = 0.18
    shaderAtmosphere.Offset = 0.04
    shaderAtmosphere.Color = Color3.fromRGB(190, 193, 209)
    shaderAtmosphere.Decay = Color3.fromRGB(76, 80, 101)
    shaderAtmosphere.Glare = 0.025
    shaderAtmosphere.Haze = 1.15
end

addToggle("🌌 Cósmico", "Shaders Cinemáticos", "✧", function(s)
    if s then
        applyCinematicShaders()
    else
        clearCinematicShaders()
    end
end, THEME.accent)

-- AGUJERO NEGRO
local bhModel = nil
local bhConns = {}
addToggle("🌌 Cósmico", "Agujero Negro Gigante", "🕳️", function(s)
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
        e.Rate = 32; e.Lifetime = NumberRange.new(2,4)
        e.Speed = NumberRange.new(30,80)
        e.SpreadAngle = Vector2.new(0,360)
        e.Rotation = NumberRange.new(0,360)
        e.RotSpeed = NumberRange.new(-360,360)
        e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,5), NumberSequenceKeypoint.new(1,0)})
        e.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.2), NumberSequenceKeypoint.new(0.7,0.5), NumberSequenceKeypoint.new(1,1)
        })
        e.Color = ColorSequence.new(Color3.new(1,1,1), cfg.color, cfg.color)
        e.LightEmission = 0.18
        e.Parent = r
        table.insert(rings, {part=r, tilt=cfg.tilt, speed=cfg.speed})
    end
    for i = 1, 3 do
        local l = Instance.new("PointLight")
        l.Color = Color3.fromRGB(139, 136, 157)
        l.Brightness = 0.65; l.Range = 850; l.Shadows = false
        l.Parent = core
    end
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
addToggle("🌌 Cósmico", "Luciérnagas en Espiral", "🦋", function(s)
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
        e.Rate = 15; e.Lifetime = NumberRange.new(1,2)
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

-- METEORITOS
local meteorInit = false
addToggle("🌌 Cósmico", "Lluvia de Meteoritos", "☄️", function(s)
    if not s or meteorInit then return end
    meteorInit = true
    RunService.Heartbeat:Connect(function()
        if math.random() < 0.05 then
            local cam = Workspace.CurrentCamera
            local startPos = cam.CFrame.Position + Vector3.new(
                math.random(-2000,2000), 3000, math.random(-2000,2000))
            local meteor = Instance.new("Part")
            meteor.Size = Vector3.new(2,2,8)
            meteor.Position = startPos
            meteor.Color = Color3.fromRGB(145, 140, 158)
            meteor.Material = Enum.Material.SmoothPlastic
            meteor.Anchored = true; meteor.CanCollide = false; meteor.CastShadow = false
            meteor.Parent = Workspace
            local a0 = Instance.new("Attachment"); a0.Position = Vector3.new(0,0,4); a0.Parent = meteor
            local a1 = Instance.new("Attachment"); a1.Position = Vector3.new(0,0,-4); a1.Parent = meteor
            local trail = Instance.new("Trail")
            trail.Lifetime = 2
            trail.Color = ColorSequence.new(Color3.fromRGB(150, 146, 164), Color3.fromRGB(90, 94, 111))
            trail.Transparency = NumberSequence.new(0.3, 1)
            trail.Attachment0 = a0
            trail.Attachment1 = a1
            trail.Parent = meteor
            local target = startPos + Vector3.new(math.random(-500,500), -3000, math.random(-500,500))
            TweenService:Create(meteor, TweenInfo.new(2, Enum.EasingStyle.Linear), {Position = target}):Play()
            task.delay(2.1, function() meteor:Destroy() end)
        end
    end)
end, Color3.fromRGB(255,200,100))

-- PORTAL
local portalPart = nil
local portalRing = nil
local portalConn = nil
addToggle("🌌 Cósmico", "Portal Personal", "🌀", function(s)
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
        Fuego = {color = Color3.fromRGB(255,100,0)},
        Hielo = {color = Color3.fromRGB(100,200,255)},
        Rayo  = {color = Color3.fromRGB(200,255,100)},
    })[element]
    if not cfg then return end
    elementalPart = Instance.new("Part")
    elementalPart.Size = Vector3.new(1,1,1)
    elementalPart.Transparency = 1
    elementalPart.Anchored = true; elementalPart.CanCollide = false
    elementalPart.Parent = Workspace
    local e = Instance.new("ParticleEmitter")
    e.Texture = "rbxassetid://243660364"
    e.Rate = 60; e.Lifetime = NumberRange.new(0.5, 1.5)
    e.Speed = NumberRange.new(5,10)
    e.SpreadAngle = Vector2.new(180,180)
    e.Size = NumberSequence.new(1.5, 0)
    e.Color = ColorSequence.new(cfg.color, Color3.new(1,1,1))
    e.LightEmission = 1
    e.Parent = elementalPart
    elementalConn = RunService.Heartbeat:Connect(function()
        if hrp and hrp.Parent and elementalPart and elementalPart.Parent then
            elementalPart.Position = hrp.Position + Vector3.new(0, 2, 0)
        end
    end)
end
addAction("🌌 Cósmico", "Aura de Fuego", "🔥", function() toggleElemental("Fuego") end, Color3.fromRGB(255,100,0))
addAction("🌌 Cósmico", "Aura de Hielo", "❄️", function() toggleElemental("Hielo") end, Color3.fromRGB(100,200,255))
addAction("🌌 Cósmico", "Aura de Rayo", "⚡", function() toggleElemental("Rayo") end, Color3.fromRGB(200,255,100))

-- ============================================================
-- ✦ PESTAÑA EXTRAS ✦
-- ============================================================

addToggle("🎮 Extras", "Música Cósmica de Fondo", "🎵", function(s)
    if s then ambientMusic:Play() else ambientMusic:Stop() end
end, Color3.fromRGB(100,220,200))

-- CONTADOR MONEDAS
local coinHUD = nil
addToggle("🎮 Extras", "Contador de Monedas", "🪙", function(s)
    if coinHUD then coinHUD:Destroy() coinHUD = nil end
    if not s then return end
    coinHUD = Instance.new("Frame")
    coinHUD.Size = UDim2.new(0, 180, 0, 50)
    coinHUD.Position = UDim2.new(0.5, -90, 0, 20)
    coinHUD.BackgroundColor3 = Color3.fromRGB(12, 6, 25)
    coinHUD.BorderSizePixel = 0
    coinHUD.Parent = gui
    Instance.new("UICorner", coinHUD).CornerRadius = UDim.new(0, 12)
    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(255,215,0)
    st.Thickness = 2
    st.Parent = coinHUD
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "🪙 Monedas: 0"
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(255, 220, 100)
    lbl.Parent = coinHUD
    task.spawn(function()
        while coinHUD and coinHUD.Parent do
            local count = 0
            for _, o in ipairs(Workspace:GetChildren()) do
                if o.Name:lower():find("coin") then count = count + 1 end
            end
            lbl.Text = "🪙 Monedas: " .. count
            task.wait(1)
        end
    end)
end, Color3.fromRGB(255,215,0))

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
    flash.BackgroundColor3 = Color3.new(1,1,1)
    flash.BackgroundTransparency = 0.3
    flash.BorderSizePixel = 0
    flash.ZIndex = 99999
    flash.Parent = gui
    TweenService:Create(flash, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
    task.delay(0.7, function() flash:Destroy() end)
    notify("📸 ¡Foto capturada!", Color3.fromRGB(255,255,255))
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
    for i = 1, 15 do
        local p = Instance.new("Part")
        p.Size = Vector3.new(1,1,1)
        p.Transparency = 1
        p.Anchored = true; p.CanCollide = false
        p.Parent = Workspace
        table.insert(ambientParts, p)
        local e = Instance.new("ParticleEmitter")
        e.Texture = "rbxassetid://243660364"
        e.Rate = 5; e.Lifetime = NumberRange.new(3,6)
        e.Speed = NumberRange.new(0.5,2)
        e.SpreadAngle = Vector2.new(180,180)
        e.Size = NumberSequence.new(0.3, 0)
        e.Color = ColorSequence.new(Color3.fromRGB(155, 155, 171), Color3.fromRGB(205, 205, 215))
        e.LightEmission = 0.12
        e.Parent = p
        p.Position = cam.CFrame.Position + Vector3.new(
            math.random(-50,50), math.random(-20,20), math.random(-50,50))
    end
    ambientConn = RunService.Heartbeat:Connect(function()
        local cam2 = Workspace.CurrentCamera
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

local function setAnimId(animate, category, subName, id)
    local cat = animate:FindFirstChild(category)
    if not cat then return end
    local target = subName and cat:FindFirstChild(subName) or cat
    if target:IsA("Animation") then
        target.AnimationId = "rbxassetid://" .. id
        return
    end
    for _, d in ipairs(target:GetDescendants()) do
        if d:IsA("Animation") then
            d.AnimationId = "rbxassetid://" .. id
        end
    end
end

local currentPackage = "Default"

local function applyPackage(pkg)
    local char = LP.Character or LP.CharacterAdded:Wait()
    local animate = char:FindFirstChild("Animate")
    if not animate then
        notify("❌ No se encontró Animate", Color3.fromRGB(255,100,100))
        return
    end
    if pkg == "Default" then
        setAnimId(animate, "idle", "Animation1", "507766666")
        setAnimId(animate, "idle", "Animation2", "507766951")
        setAnimId(animate, "walk", "WalkAnim", "507777826")
        setAnimId(animate, "run", "RunAnim", "507767714")
        setAnimId(animate, "jump", "JumpAnim", "507765000")
        setAnimId(animate, "fall", "FallAnim", "507767968")
        setAnimId(animate, "climb", "ClimbAnim", "507765644")
        setAnimId(animate, "swim", "Swim", "507784897")
        setAnimId(animate, "swimidle", "SwimIdle", "507785072")
        currentPackage = "Default"
        notify("🎭 Animaciones default", Color3.fromRGB(150,150,150))
        return
    end
    local cfg = animPackages[pkg]
    if not cfg then return end
    setAnimId(animate, "idle", "Animation1", cfg.idle1)
    setAnimId(animate, "idle", "Animation2", cfg.idle2)
    setAnimId(animate, "walk", "WalkAnim", cfg.walk)
    setAnimId(animate, "run", "RunAnim", cfg.run)
    setAnimId(animate, "jump", "JumpAnim", cfg.jump)
    setAnimId(animate, "fall", "FallAnim", cfg.fall)
    setAnimId(animate, "climb", "ClimbAnim", cfg.climb)
    setAnimId(animate, "swim", "Swim", cfg.swim)
    setAnimId(animate, "swimidle", "SwimIdle", cfg.swimidle)
    currentPackage = pkg
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = cfg.color
    flash.BackgroundTransparency = 0.7
    flash.BorderSizePixel = 0
    flash.ZIndex = 99999
    flash.Parent = gui
    TweenService:Create(flash, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    task.delay(0.9, function() flash:Destroy() end)
    notify("🎭 " .. cfg.emoji .. " " .. cfg.name .. " activado", cfg.color)
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if currentPackage ~= "Default" then
        applyPackage(currentPackage)
    end
end)

addSection("🎭 Anim", "🎬 PAQUETES DE ANIMACIÓN", Color3.fromRGB(255, 100, 200))
for pkgName, cfg in pairs(animPackages) do
    addAction("🎭 Anim", cfg.name, cfg.emoji, function() applyPackage(pkgName) end, cfg.color)
end

addSection("🎭 Anim", "✨ EMOTES", Color3.fromRGB(255, 150, 255))

local emotes = {
    {name="Baile 1", emoji="💃", id="507771019"},
    {name="Baile 2", emoji="🕺", id="507776043"},
    {name="Baile 3", emoji="🎉", id="507777268"},
    {name="Saludar", emoji="👋", id="507770239"},
    {name="Reír",    emoji="😂", id="507770818"},
    {name="Señalar", emoji="👉", id="507770453"},
}

for _, e in ipairs(emotes) do
    addAction("🎭 Anim", e.name, e.emoji, function()
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChild("Animator")
        if not animator then return end
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. e.id
        local track = animator:LoadAnimation(anim)
        track:Play()
        task.delay(track.Length or 3, function()
            if track then track:Stop() end
        end)
    end, Color3.fromRGB(255, 150, 255))
end

addSection("🎭 Anim", "⚡ MEJORAS EXTREMAS", Color3.fromRGB(255, 200, 100))

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
        notify("Preset visual desactivado", THEME.mutedText)
        return
    end

    superPresetEnabled = true
    applyCinematicShaders()
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
            if (currentPos-lastPos).Magnitude >= 4 and tick()-lastGhostAt >= 0.18 then
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
-- MENSAJE INICIAL
-- ============================================================
task.delay(0.8, function()
    notify("MM2 COSMIC ULTIMATE cargado", THEME.accent)
    task.wait(0.5)
    notify("40+ módulos en 6 pestañas", THEME.mutedText)
    task.wait(0.5)
    notify("Interfaz lista", THEME.enabled)
end)

print("✦✦✦✦✦ MM2 COSMIC ULTIMATE — ALL IN ONE cargado ✦✦✦✦✦")
print("40+ módulos · 6 pestañas · 100% client-side")