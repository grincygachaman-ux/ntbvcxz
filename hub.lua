--[[
    ONYX
    credits: @SuperburkeScript
--]]

local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui        = game:GetService("StarterGui")
local TeleportService   = game:GetService("TeleportService")
local VirtualUser       = game:GetService("VirtualUser")
local HttpService       = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local DiscordLink = "https://discord.gg/njFc7A9rmM"
local HardcodedKey = "ONYX-A9F3"
local GistUrl = "https://gist.github.com/grincygachaman-ux/1d7f1a04942e86eedbb3d39c429b2820"
local ConfigFolder = "OnyxConfigs"

local LP = Players.LocalPlayer

-- ==========================================
-- CLEANUP
-- ==========================================
local uiName = "OnyxUI"
pcall(function() if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end end)
pcall(function() if LP.PlayerGui:FindFirstChild(uiName) then LP.PlayerGui[uiName]:Destroy() end end)

-- ==========================================
-- PALETTE
-- ==========================================
local P = {
    Bg          = Color3.fromRGB(4, 4, 4),
    Bg2         = Color3.fromRGB(6, 6, 6),
    Card        = Color3.fromRGB(11, 11, 11),
    Card2       = Color3.fromRGB(16, 16, 16),
    Card3       = Color3.fromRGB(20, 20, 20),
    White       = Color3.fromRGB(255, 255, 255),
    White80     = Color3.fromRGB(204, 204, 204),
    White60     = Color3.fromRGB(153, 153, 153),
    White30     = Color3.fromRGB(77, 77, 77),
    Line        = Color3.fromRGB(30, 30, 30),
    LineBright  = Color3.fromRGB(60, 60, 60),
    Red         = Color3.fromRGB(255, 60, 80),
}

-- ==========================================
-- HELPERS
-- ==========================================
local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = o
    return c
end

local function stroke(o, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or P.Line
    s.Thickness = th or 1
    s.Transparency = tr or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o
    return s
end

local function tween(o, t, props, style, dir)
    local info = TweenInfo.new(t or 0.22, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(o, info, props)
    tw:Play()
    return tw
end

local function track(conn)
    if conn then table.insert(_G.OnyxConnections, conn) end
    return conn
end
_G.OnyxConnections = _G.OnyxConnections or {}

-- ==========================================
-- SCREEN
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = uiName
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local pOK = pcall(function() screenGui.Parent = CoreGui end)
if not pOK then screenGui.Parent = LP.PlayerGui end
_G.OnyxUI = screenGui

-- ==========================================
-- NOTIFY
-- ==========================================
local function notify(title, text, dur)
    local n = Instance.new("Frame")
    n.Size = UDim2.fromOffset(280, 56)
    n.Position = UDim2.new(1, 40, 1, -90)
    n.BackgroundColor3 = P.Card
    n.BorderSizePixel = 0
    n.ZIndex = 500
    n.Parent = screenGui
    corner(n, 10)
    stroke(n, P.Line, 1, 0.2)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -16)
    bar.Position = UDim2.fromOffset(10, 8)
    bar.BackgroundColor3 = P.White
    bar.BorderSizePixel = 0
    bar.ZIndex = 501
    bar.Parent = n
    corner(bar, 2)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -28, 0, 20)
    t.Position = UDim2.fromOffset(22, 8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.Font = Enum.Font.GothamBold
    t.TextSize = 12
    t.TextColor3 = P.White
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 501
    t.Parent = n

    local b = Instance.new("TextLabel")
    b.Size = UDim2.new(1, -28, 0, 24)
    b.Position = UDim2.fromOffset(22, 26)
    b.BackgroundTransparency = 1
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 10
    b.TextColor3 = P.White60
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextWrapped = true
    b.ZIndex = 501
    b.Parent = n

    tween(n, 0.4, {Position = UDim2.new(1, -300, 1, -90)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.delay(dur or 4, function()
        tween(n, 0.3, {Position = UDim2.new(1, 40, 1, -90)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.35, function() pcall(function() n:Destroy() end) end)
    end)
end

-- ==========================================
-- HTTP
-- ==========================================
local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #tostring(res) > 0 then return tostring(res) end
    if type(request) == "function" then
        local ok2, res2 = pcall(function() return request({Url = url, Method = "GET"}).Body end)
        if ok2 and res2 and #tostring(res2) > 0 then return tostring(res2) end
    end
    local ok3, res3 = pcall(function() return HttpService:GetAsync(url) end)
    if ok3 and res3 and #tostring(res3) > 0 then return tostring(res3) end
    return nil
end

local function fetchKeyFromGist()
    local url = GistUrl .. "?t=" .. tostring(os.time()) .. "&r=" .. tostring(math.random(1, 999999))
    local html = httpGet(url)
    if not html then return nil end
    local m1 = html:match('<textarea[^>]-name="gist%[content%]"[^>]->%s*([^<]-)%s*</textarea>')
    if m1 and #m1 > 0 then
        m1 = m1:gsub("^%s+", ""):gsub("%s+$", ""):gsub("&amp;", "&")
        if m1:match("^ONYX%-") then return m1 end
    end
    local m2 = html:match("(ONYX%-[A-Z0-9]+)")
    if m2 then return m2 end
    local plain = html:gsub("<[^>]->", " ")
    local m3 = plain:match("(ONYX%-[A-Z0-9]+)")
    return m3
end

-- Pre-fetch key asynchronously at startup
local cachedRemoteKey = nil
task.spawn(function()
    cachedRemoteKey = fetchKeyFromGist()
end)

-- ==========================================
-- CONFIG STORE
-- ==========================================
local Config = {
    ESPEnabled = false, ESPNames = true, ESPHealth = true, ESPDist = false,
    ESPTracers = false, ESPTeamCheck = true, ESPMaxDist = 500, ESPChams = false,
    SilentEnabled = false, SilentFOV = 150, SilentSmooth = 50,
    SilentWall = true, SilentTeam = true, SilentPredict = true, TriggerBot = false,
    HitboxEnabled = false, HitboxSize = 6, HitboxMode = "UpperTorso",
    SpeedEnabled = false, SpeedValue = 50, JumpEnabled = false, JumpValue = 100,
    InfJump = false, Noclip = false, SafeFall = true, Gravity = 196,
    FlyEnabled = false, FlySpeed = 100,
    Fullbright = false, FogEnabled = false, FOV = 70,
    RapidFire = false, InfAmmo = false, NoRecoil = false,
    Godmode = false, AntiAFK = true,
    AutoFling = false, AutoFlingRange = 30,
    MenuKey = Enum.KeyCode.RightShift,
}

local DefaultConfig = {}
for k, v in pairs(Config) do DefaultConfig[k] = v end

-- ==========================================
-- FILE SYSTEM (FIXED)
-- ==========================================
local function ensureFolder()
    pcall(function()
        if isfolder and not isfolder(ConfigFolder) then
            makefolder(ConfigFolder)
        end
    end)
    -- Double-check with mkdir fallback
    pcall(function()
        if makefolder and not isfolder(ConfigFolder) then
            makefolder(ConfigFolder)
        end
    end)
end

-- convert any value to serializable
local function serializeValue(v)
    if typeof(v) == "EnumItem" then
        return {__t = "enum", name = v.Name, enum = v.EnumType.Name}
    elseif typeof(v) == "Vector3" then
        return {__t = "vec3", x = v.X, y = v.Y, z = v.Z}
    elseif typeof(v) == "Color3" then
        return {__t = "color3", r = v.R, g = v.G, b = v.B}
    elseif type(v) == "table" then
        local out = {}
        for k, vv in pairs(v) do
            out[k] = serializeValue(vv)
        end
        return out
    end
    return v
end

-- convert back from serialized
local function deserializeValue(v)
    if type(v) ~= "table" then return v end
    if v.__t == "enum" then
        local ok, item = pcall(function() return Enum[v.enum][v.name] end)
        if ok then return item end
        return nil
    elseif v.__t == "vec3" then
        return Vector3.new(v.x, v.y, v.z)
    elseif v.__t == "color3" then
        return Color3.new(v.r, v.g, v.b)
    else
        local out = {}
        for k, vv in pairs(v) do
            out[k] = deserializeValue(vv)
        end
        return out
    end
end

local function configPath(name)
    return ConfigFolder .. "/" .. name .. ".json"
end

local function saveConfigToFile(name)
    if not name or name == "" then return false, "no name" end
    ensureFolder()

    local data = {}
    for k, v in pairs(Config) do
        data[k] = serializeValue(v)
    end

    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false, "encode failed: " .. tostring(encoded) end

    local ok2, err = pcall(function()
        if writefile then
            writefile(configPath(name), encoded)
        else
            error("writefile not available")
        end
    end)
    if not ok2 then return false, "write failed: " .. tostring(err) end

    -- verify that file exists
    local verify = pcall(function()
        if isfile and isfile(configPath(name)) then return true end
        return false
    end)
    if not verify then return false, "file not found after write" end

    return true
end

local function loadConfigFromFile(name)
    if not name or name == "" then return false, "no name" end
    ensureFolder()

    local exists = false
    pcall(function()
        if isfile and isfile(configPath(name)) then exists = true end
    end)
    if not exists then return false, "file not found" end

    local ok, content = pcall(function()
        if readfile then return readfile(configPath(name)) end
        return nil
    end)
    if not ok or not content or #content == 0 then return false, "read failed" end

    local ok2, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok2 or type(decoded) ~= "table" then return false, "decode failed" end

    -- apply
    for k, v in pairs(decoded) do
        if Config[k] ~= nil then
            local val = deserializeValue(v)
            if val ~= nil then
                Config[k] = val
            end
        end
    end
    return true
end

local function deleteConfigFile(name)
    if not name or name == "" then return false end
    local ok = pcall(function()
        if delfile and isfile and isfile(configPath(name)) then
            delfile(configPath(name))
        end
    end)
    return ok
end

local function listConfigs()
    ensureFolder()
    local list = {}
    pcall(function()
        if listfiles then
            local files = listfiles(ConfigFolder)
            for _, f in ipairs(files) do
                -- strip path and extension
                local base = f:match("([^/\\]+)$") or f
                local n = base:match("^(.+)%.json$")
                if n then table.insert(list, n) end
            end
        end
    end)
    return list
end

-- ==========================================
-- KEY PANEL
-- ==========================================
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.fromOffset(380, 260)
keyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
keyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
keyFrame.BackgroundColor3 = P.Bg
keyFrame.BorderSizePixel = 0
keyFrame.ZIndex = 10
keyFrame.Parent = screenGui
corner(keyFrame, 14)
stroke(keyFrame, P.Line, 1, 0.2)

for i = 1, 3 do
    local g = Instance.new("Frame")
    g.Name = "KeyGlow_" .. i
    g.Size = UDim2.new(1, 14 * i, 1, 14 * i)
    g.Position = UDim2.new(0.5, 0, 0.5, 0)
    g.AnchorPoint = Vector2.new(0.5, 0.5)
    g.BackgroundColor3 = P.White
    g.BackgroundTransparency = 0.96 + i * 0.006
    g.BorderSizePixel = 0
    g.ZIndex = 8
    g.Parent = screenGui
    corner(g, 14 + i * 4)
end

local kTitle = Instance.new("TextLabel")
kTitle.Text = "ONYX"
kTitle.Font = Enum.Font.GothamBlack
kTitle.TextSize = 32
kTitle.TextColor3 = P.White
kTitle.Size = UDim2.new(1, 0, 0, 46)
kTitle.Position = UDim2.new(0, 0, 0, 26)
kTitle.BackgroundTransparency = 1
kTitle.ZIndex = 11
kTitle.Parent = keyFrame

local kInput = Instance.new("TextBox")
kInput.Size = UDim2.new(1, -60, 0, 44)
kInput.Position = UDim2.new(0, 30, 0, 90)
kInput.BackgroundColor3 = P.Card
kInput.PlaceholderText = "key"
kInput.Text = ""
kInput.Font = Enum.Font.GothamBold
kInput.TextSize = 13
kInput.TextColor3 = P.White
kInput.PlaceholderColor3 = P.White30
kInput.ZIndex = 11
kInput.ClearTextOnFocus = false
kInput.Parent = keyFrame
corner(kInput, 10)
local kInputStroke = stroke(kInput, P.Line, 1, 0.5)

kInput.Focused:Connect(function()
    tween(kInputStroke, 0.2, {Color = P.White, Transparency = 0.2})
end)
kInput.FocusLost:Connect(function()
    tween(kInputStroke, 0.2, {Color = P.Line, Transparency = 0.5})
end)

local kEnter = Instance.new("TextButton")
kEnter.Size = UDim2.new(1, -60, 0, 42)
kEnter.Position = UDim2.new(0, 30, 0, 144)
kEnter.BackgroundColor3 = P.White
kEnter.Text = "UNLOCK"
kEnter.Font = Enum.Font.GothamBlack
kEnter.TextSize = 12
kEnter.TextColor3 = P.Bg
kEnter.AutoButtonColor = false
kEnter.ZIndex = 11
kEnter.Parent = keyFrame
corner(kEnter, 10)

kEnter.MouseEnter:Connect(function() tween(kEnter, 0.15, {BackgroundColor3 = P.White80}) end)
kEnter.MouseLeave:Connect(function() tween(kEnter, 0.15, {BackgroundColor3 = P.White}) end)

local kGetKey = Instance.new("TextButton")
kGetKey.Size = UDim2.new(1, -60, 0, 34)
kGetKey.Position = UDim2.new(0, 30, 0, 196)
kGetKey.BackgroundColor3 = P.Card
kGetKey.Text = "GET KEY"
kGetKey.Font = Enum.Font.GothamBold
kGetKey.TextSize = 11
kGetKey.TextColor3 = P.White
kGetKey.AutoButtonColor = false
kGetKey.ZIndex = 11
kGetKey.Parent = keyFrame
corner(kGetKey, 10)
stroke(kGetKey, P.Line, 1, 0.4)

kGetKey.MouseEnter:Connect(function() tween(kGetKey, 0.15, {BackgroundColor3 = P.Card2}) end)
kGetKey.MouseLeave:Connect(function() tween(kGetKey, 0.15, {BackgroundColor3 = P.Card}) end)

local kStatus = Instance.new("TextLabel")
kStatus.Size = UDim2.new(1, 0, 0, 14)
kStatus.Position = UDim2.new(0, 0, 1, -22)
kStatus.BackgroundTransparency = 1
kStatus.Text = ""
kStatus.Font = Enum.Font.Gotham
kStatus.TextSize = 10
kStatus.TextColor3 = P.White30
kStatus.ZIndex = 11
kStatus.Parent = keyFrame

-- ==========================================
-- MAIN WINDOW
-- ==========================================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = P.Bg
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 2
mainFrame.Parent = screenGui
corner(mainFrame, 16)
stroke(mainFrame, P.Line, 1, 0.15)

for i = 1, 4 do
    local g = Instance.new("Frame")
    g.Name = "MainGlow_" .. i
    g.Size = UDim2.new(1, 10 * i, 1, 10 * i)
    g.Position = UDim2.new(0.5, 0, 0.5, 0)
    g.AnchorPoint = Vector2.new(0.5, 0.5)
    g.BackgroundColor3 = P.White
    g.BackgroundTransparency = 0.97 + i * 0.006
    g.BorderSizePixel = 0
    g.ZIndex = 1
    g.Parent = mainFrame
    corner(g, 18 + i * 3)
end

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 56)
topBar.BackgroundColor3 = P.Bg
topBar.BackgroundTransparency = 0.4
topBar.BorderSizePixel = 0
topBar.ZIndex = 3
topBar.Parent = mainFrame
corner(topBar, 16)

local topHair = Instance.new("Frame")
topHair.Size = UDim2.new(1, 0, 0, 1)
topHair.Position = UDim2.new(0, 0, 1, -1)
topHair.BackgroundColor3 = P.White
topHair.BackgroundTransparency = 0.92
topHair.BorderSizePixel = 0
topHair.ZIndex = 4
topHair.Parent = topBar

local title = Instance.new("TextLabel")
title.Text = "ONYX"
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextColor3 = P.White
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 22, 0, 0)
title.Size = UDim2.new(0, 100, 1, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 4
title.Parent = topBar

local creditsText = Instance.new("TextLabel")
creditsText.Text = "@SuperburkeScript"
creditsText.Font = Enum.Font.Gotham
creditsText.TextSize = 10
creditsText.TextColor3 = P.White30
creditsText.BackgroundTransparency = 1
creditsText.Position = UDim2.new(1, -320, 0, 0)
creditsText.Size = UDim2.new(0, 180, 1, 0)
creditsText.TextXAlignment = Enum.TextXAlignment.Right
creditsText.ZIndex = 4
creditsText.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -44, 0.5, -15)
closeBtn.BackgroundColor3 = P.Card
closeBtn.Text = ""
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 5
closeBtn.Parent = topBar
corner(closeBtn, 8)
stroke(closeBtn, P.Line, 1, 0.4)

local cL1 = Instance.new("Frame")
cL1.Size = UDim2.fromOffset(11, 1.5)
cL1.Position = UDim2.new(0.5, -5.5, 0.5, -0.75)
cL1.Rotation = 45
cL1.BackgroundColor3 = P.White
cL1.BorderSizePixel = 0
cL1.ZIndex = 6
cL1.Parent = closeBtn
corner(cL1, 1)

local cL2 = Instance.new("Frame")
cL2.Size = UDim2.fromOffset(11, 1.5)
cL2.Position = UDim2.new(0.5, -5.5, 0.5, -0.75)
cL2.Rotation = -45
cL2.BackgroundColor3 = P.White
cL2.BorderSizePixel = 0
cL2.ZIndex = 6
cL2.Parent = closeBtn
corner(cL2, 1)

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, 0.2, {BackgroundColor3 = P.White})
    tween(cL1, 0.25, {BackgroundColor3 = P.Bg, Rotation = 135})
    tween(cL2, 0.25, {BackgroundColor3 = P.Bg, Rotation = 45})
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, 0.2, {BackgroundColor3 = P.Card})
    tween(cL1, 0.25, {BackgroundColor3 = P.White, Rotation = 45})
    tween(cL2, 0.25, {BackgroundColor3 = P.White, Rotation = -45})
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    notify("ONYX", "Press " .. tostring(Config.MenuKey.Name) .. " to open", 4)
end)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -80, 0.5, -15)
minBtn.BackgroundColor3 = P.Card
minBtn.Text = ""
minBtn.AutoButtonColor = false
minBtn.ZIndex = 5
minBtn.Parent = topBar
corner(minBtn, 8)
stroke(minBtn, P.Line, 1, 0.4)

local mLine = Instance.new("Frame")
mLine.Size = UDim2.fromOffset(11, 1.5)
mLine.Position = UDim2.new(0.5, -5.5, 0.5, -0.75)
mLine.BackgroundColor3 = P.White
mLine.BorderSizePixel = 0
mLine.ZIndex = 6
mLine.Parent = minBtn
corner(mLine, 1)

minBtn.MouseEnter:Connect(function() tween(minBtn, 0.15, {BackgroundColor3 = P.Card2}) end)
minBtn.MouseLeave:Connect(function() tween(minBtn, 0.15, {BackgroundColor3 = P.Card}) end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tween(mainFrame, 0.35, {Size = UDim2.fromOffset(940, 56)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        tween(mainFrame, 0.35, {Size = UDim2.fromOffset(940, 620)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

do
    local dragging, ds, sp
    track(topBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            ds = i.Position
            sp = mainFrame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end))
    track(UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            mainFrame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end))
end

local sideBar = Instance.new("Frame")
sideBar.Size = UDim2.new(0, 210, 1, -72)
sideBar.Position = UDim2.fromOffset(14, 66)
sideBar.BackgroundColor3 = P.Bg
sideBar.BackgroundTransparency = 0.4
sideBar.BorderSizePixel = 0
sideBar.ZIndex = 3
sideBar.Parent = mainFrame
corner(sideBar, 12)
stroke(sideBar, P.Line, 1, 0.3)

local sideScroll = Instance.new("ScrollingFrame")
sideScroll.Size = UDim2.new(1, -4, 1, -4)
sideScroll.Position = UDim2.fromOffset(2, 2)
sideScroll.BackgroundTransparency = 1
sideScroll.BorderSizePixel = 0
sideScroll.ScrollBarThickness = 2
sideScroll.ScrollBarImageColor3 = P.White
sideScroll.ScrollBarImageTransparency = 0.8
sideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sideScroll.ZIndex = 4
sideScroll.Parent = sideBar

local sideLayout = Instance.new("UIListLayout")
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding = UDim.new(0, 2)
sideLayout.Parent = sideScroll

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 8)
sidePad.PaddingBottom = UDim.new(0, 8)
sidePad.PaddingLeft = UDim.new(0, 8)
sidePad.PaddingRight = UDim.new(0, 8)
sidePad.Parent = sideScroll

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -238, 1, -72)
contentContainer.Position = UDim2.fromOffset(238, 66)
contentContainer.BackgroundTransparency = 1
contentContainer.ZIndex = 3
contentContainer.Parent = mainFrame

-- ==========================================
-- AUTH
-- ==========================================
local function CheckKey()
    kStatus.Text = "verifying"
    kStatus.TextColor3 = P.White60
    local input = kInput.Text
    local expected = HardcodedKey

    if not cachedRemoteKey then
        cachedRemoteKey = fetchKeyFromGist()
    end
    if cachedRemoteKey then expected = cachedRemoteKey end

    if input == expected then
        kStatus.Text = "access granted"
        kStatus.TextColor3 = P.White
        task.wait(0.3)

        tween(keyFrame, 0.35, {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        for _, ch in ipairs(screenGui:GetChildren()) do
            if ch.Name:match("^KeyGlow_") then
                tween(ch, 0.35, {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            end
        end
        for _, d in ipairs(keyFrame:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("TextButton") then
                tween(d, 0.2, {TextTransparency = 1, BackgroundTransparency = 1})
            elseif d:IsA("UIStroke") then
                tween(d, 0.2, {Transparency = 1})
            elseif d:IsA("Frame") then
                tween(d, 0.2, {BackgroundTransparency = 1})
            end
        end
        task.wait(0.4)
        keyFrame.Visible = false
        for _, ch in ipairs(screenGui:GetChildren()) do
            if ch.Name:match("^KeyGlow_") then ch.Visible = false end
        end

        mainFrame.Visible = true
        mainFrame.Size = UDim2.fromOffset(760, 500)
        tween(mainFrame, 0.5, {Size = UDim2.fromOffset(940, 620)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        kStatus.Text = "invalid"
        kStatus.TextColor3 = P.Red
        local orig = kInput.Position
        for i = 1, 5 do
            tween(kInput, 0.045, {Position = UDim2.new(0, 30 + (i % 2 == 0 and 8 or -8), 0, 90)})
            task.wait(0.045)
        end
        kInput.Position = orig
    end
end

kEnter.MouseButton1Click:Connect(CheckKey)
kInput.FocusLost:Connect(function(enter) if enter then CheckKey() end end)

kGetKey.MouseButton1Click:Connect(function()
    pcall(function() if setclipboard then setclipboard(DiscordLink) end end)
    kStatus.Text = "copied"
    kStatus.TextColor3 = P.White
end)

-- ==========================================
-- TAB LIBRARY
-- ==========================================
local Window = { Tabs = {}, ActiveTab = nil }

-- Global slider tracker (fixes multiple sliders fighting over drag)
local activeSlider = nil

track(UserInputService.InputChanged:Connect(function(input)
    if activeSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        activeSlider(input)
    end
end))

track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if activeSlider then
            if _G._OnyxSliderOnEnd then _G._OnyxSliderOnEnd() end
            activeSlider = nil
            _G._OnyxSliderOnEnd = nil
        end
    end
end))

function Window:CreateTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.BackgroundColor3 = P.Card
    tabBtn.BackgroundTransparency = 0.7
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.ZIndex = 5
    tabBtn.Parent = sideScroll
    corner(tabBtn, 8)

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 0, 16)
    accentBar.Position = UDim2.new(0, 6, 0.5, -8)
    accentBar.BackgroundColor3 = P.White
    accentBar.BackgroundTransparency = 1
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 6
    accentBar.Parent = tabBtn
    corner(accentBar, 2)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -26, 1, 0)
    label.Position = UDim2.new(0, 18, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextColor3 = P.White60
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    label.Parent = tabBtn

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.fromScale(1, 1)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = P.White
    scroll.ScrollBarImageTransparency = 0.7
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.ZIndex = 4
    scroll.Parent = contentContainer

    local scPad = Instance.new("UIPadding", scroll)
    scPad.PaddingTop = UDim.new(0, 6)
    scPad.PaddingBottom = UDim.new(0, 16)
    scPad.PaddingLeft = UDim.new(0, 6)
    scPad.PaddingRight = UDim.new(0, 12)

    local scLayout = Instance.new("UIListLayout", scroll)
    scLayout.Padding = UDim.new(0, 6)
    scLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local lockedIdx = #self.Tabs + 1
    local lockedBtn = tabBtn
    local lockedLabel = label
    local lockedBar = accentBar

    tabBtn.MouseEnter:Connect(function()
        if Window.ActiveTab ~= lockedIdx then
            tween(lockedBtn, 0.15, {BackgroundColor3 = P.Card2, BackgroundTransparency = 0.4})
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if Window.ActiveTab ~= lockedIdx then
            tween(lockedBtn, 0.15, {BackgroundColor3 = P.Card, BackgroundTransparency = 0.7})
        end
    end)

    tabBtn.MouseButton1Click:Connect(function()
        Window.ActiveTab = lockedIdx
        for i, t in ipairs(Window.Tabs) do
            local active = (i == lockedIdx)
            tween(t.Btn, 0.2, {
                BackgroundColor3 = active and P.Card2 or P.Card,
                BackgroundTransparency = active and 0.2 or 0.7,
            })
            tween(t.Label, 0.2, {TextColor3 = active and P.White or P.White60})
            tween(t.Bar, 0.2, {BackgroundTransparency = active and 0 or 1})
            if active then
                t.Content.Visible = true
                t.Content.Position = UDim2.fromOffset(0, 15)
                tween(t.Content, 0.3, {Position = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            else
                t.Content.Visible = false
            end
        end
    end)

    table.insert(self.Tabs, {Btn = tabBtn, Label = label, Bar = accentBar, Content = scroll})

    if #self.Tabs == 1 then
        Window.ActiveTab = 1
        tabBtn.BackgroundColor3 = P.Card2
        tabBtn.BackgroundTransparency = 0.2
        label.TextColor3 = P.White
        accentBar.BackgroundTransparency = 0
        scroll.Visible = true
    end

    local Tab = {}

    local function makeCard(h)
        local c = Instance.new("Frame")
        c.Size = UDim2.new(1, -4, 0, h or 52)
        c.BackgroundColor3 = P.Card
        c.BackgroundTransparency = 0.1
        c.BorderSizePixel = 0
        c.ZIndex = 5
        c.Parent = scroll
        corner(c, 10)
        stroke(c, P.Line, 1, 0.4)

        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new(P.Card2, P.Card)
        g.Rotation = 90
        g.Parent = c

        return c
    end

    function Tab:CreateSection(text)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -4, 0, 24)
        holder.BackgroundTransparency = 1
        holder.ZIndex = 5
        holder.Parent = scroll

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 2, 0, 10)
        bar.Position = UDim2.new(0, 0, 0.5, -5)
        bar.BackgroundColor3 = P.White
        bar.BorderSizePixel = 0
        bar.ZIndex = 6
        bar.Parent = holder
        corner(bar, 1)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.upper(text)
        lbl.TextColor3 = P.White60
        lbl.TextSize = 10
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 6
        lbl.Parent = holder
    end

    function Tab:CreateLabel(text, height)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -4, 0, height or 20)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = P.White30
        l.TextSize = 11
        l.Font = Enum.Font.Gotham
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
        l.TextWrapped = true
        l.ZIndex = 6
        l.Parent = scroll
        return l
    end

    function Tab:CreateToggle(text, default, callback)
        local state = default or false
        local c = makeCard(48)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.72, 0, 1, 0)
        lbl.Position = UDim2.fromOffset(16, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = P.White
        lbl.TextSize = 13
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 6
        lbl.Parent = c

        local sw = Instance.new("Frame")
        sw.Size = UDim2.fromOffset(46, 24)
        sw.Position = UDim2.new(1, -62, 0.5, -12)
        sw.BackgroundColor3 = state and P.White or P.Card2
        sw.BorderSizePixel = 0
        sw.ZIndex = 6
        sw.Parent = c
        corner(sw, 12)
        stroke(sw, P.Line, 1, state and 0.1 or 0.5)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(16, 16)
        dot.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.fromOffset(4, 4)
        dot.BackgroundColor3 = state and P.Bg or P.White
        dot.BorderSizePixel = 0
        dot.ZIndex = 7
        dot.Parent = sw
        corner(dot, 8)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromScale(1, 1)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 8
        btn.Parent = c

        local function apply(v, animate)
            state = v
            local tPos = v and UDim2.new(1, -19, 0.5, -8) or UDim2.fromOffset(4, 4)
            local tBg = v and P.White or P.Card2
            local tDot = v and P.Bg or P.White
            if animate then
                tween(dot, 0.28, {Position = tPos, BackgroundColor3 = tDot}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                tween(sw, 0.22, {BackgroundColor3 = tBg})
            else
                dot.Position = tPos
                dot.BackgroundColor3 = tDot
                sw.BackgroundColor3 = tBg
            end
        end

        btn.MouseButton1Click:Connect(function()
            apply(not state, true)
            if callback then pcall(callback, state) end
        end)

        return {Set = function(_, v) apply(v, true) end, Get = function() return state end}
    end

    function Tab:CreateSlider(text, min, max, default, callback)
        local val = default or min
        local c = makeCard(58)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 0, 22)
        lbl.Position = UDim2.fromOffset(16, 8)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = P.White
        lbl.TextSize = 13
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 6
        lbl.Parent = c

        local vBg = Instance.new("Frame")
        vBg.Size = UDim2.fromOffset(56, 22)
        vBg.Position = UDim2.new(1, -72, 0, 8)
        vBg.BackgroundColor3 = P.Card2
        vBg.BorderSizePixel = 0
        vBg.ZIndex = 6
        vBg.Parent = c
        corner(vBg, 6)
        stroke(vBg, P.Line, 1, 0.5)

        local vLabel = Instance.new("TextLabel")
        vLabel.Size = UDim2.fromScale(1, 1)
        vLabel.BackgroundTransparency = 1
        vLabel.Text = tostring(val)
        vLabel.Font = Enum.Font.GothamBold
        vLabel.TextSize = 11
        vLabel.TextColor3 = P.White
        vLabel.ZIndex = 7
        vLabel.Parent = vBg

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -32, 0, 4)
        track.Position = UDim2.fromOffset(16, 44)
        track.BackgroundColor3 = P.Card3
        track.BorderSizePixel = 0
        track.ZIndex = 6
        track.Parent = c
        corner(track, 2)

        local pct = (val - min) / (max - min)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(pct, 0, 1, 0)
        fill.BackgroundColor3 = P.White
        fill.BorderSizePixel = 0
        fill.ZIndex = 7
        fill.Parent = track
        corner(fill, 2)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(12, 12)
        knob.Position = UDim2.new(pct, -6, 0.5, -6)
        knob.BackgroundColor3 = P.White
        knob.BorderSizePixel = 0
        knob.ZIndex = 8
        knob.Parent = track
        corner(knob, 6)

        local function setValue(newVal)
            val = newVal
            local p = math.clamp((val - min) / (max - min), 0, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -6, 0.5, -6)
            vLabel.Text = tostring(val)
            if callback then pcall(callback, val) end
        end

        local function update(input)
            local ap = track.AbsolutePosition.X
            local sz = track.AbsoluteSize.X
            local a = math.clamp((input.Position.X - ap) / sz, 0, 1)
            setValue(math.floor(min + (max - min) * a + 0.5))
        end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromScale(1, 1)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 9
        btn.Parent = c

        btn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                -- set this as the only active slider
                activeSlider = update
                _G._OnyxSliderOnEnd = function()
                    tween(knob, 0.15, {Size = UDim2.fromOffset(12, 12)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end
                tween(knob, 0.15, {Size = UDim2.fromOffset(16, 16), Position = knob.Position - UDim2.fromOffset(2, 2)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                update(i)
            end
        end)

        return {
            Set = function(_, v) setValue(v) end,
            Get = function() return val end
        }
    end

    function Tab:CreateButton(text, callback, danger)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -4, 0, 38)
        b.BackgroundColor3 = danger and P.Red or P.Card
        b.BackgroundTransparency = danger and 0.2 or 0.1
        b.Text = text
        b.TextColor3 = P.White
        b.TextSize = 12
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.ZIndex = 6
        b.Parent = scroll
        corner(b, 19)
        stroke(b, P.Line, 1, 0.4)

        b.MouseEnter:Connect(function()
            tween(b, 0.18, {
                BackgroundColor3 = danger and P.Red or P.White,
                BackgroundTransparency = 0,
                TextColor3 = P.Bg,
            })
        end)
        b.MouseLeave:Connect(function()
            tween(b, 0.18, {
                BackgroundColor3 = danger and P.Red or P.Card,
                BackgroundTransparency = danger and 0.2 or 0.1,
                TextColor3 = P.White,
            })
        end)
        b.MouseButton1Click:Connect(function()
            if callback then pcall(callback) end
        end)
        return b
    end

    function Tab:CreateTextBox(placeholder, default, callback)
        local c = makeCard(48)
        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1, -32, 1, 0)
        tb.Position = UDim2.fromOffset(16, 0)
        tb.BackgroundTransparency = 1
        tb.PlaceholderText = placeholder or ""
        tb.PlaceholderColor3 = P.White30
        tb.Text = default or ""
        tb.Font = Enum.Font.GothamMedium
        tb.TextSize = 12
        tb.TextColor3 = P.White
        tb.TextXAlignment = Enum.TextXAlignment.Left
        tb.ClearTextOnFocus = false
        tb.ZIndex = 7
        tb.Parent = c
        tb.FocusLost:Connect(function()
            if callback then pcall(callback, tb.Text) end
        end)
        return tb
    end

    function Tab:CreateDropdown(text, options, default, callback)
        local current = default or options[1]
        local c = makeCard(48)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.fromOffset(16, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = P.White
        lbl.TextSize = 13
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 6
        lbl.Parent = c

        local dd = Instance.new("TextButton")
        dd.Size = UDim2.fromOffset(120, 28)
        dd.Position = UDim2.new(1, -136, 0.5, -14)
        dd.BackgroundColor3 = P.Card2
        dd.Text = current
        dd.Font = Enum.Font.GothamBold
        dd.TextSize = 11
        dd.TextColor3 = P.White
        dd.AutoButtonColor = false
        dd.ZIndex = 7
        dd.Parent = c
        corner(dd, 6)
        stroke(dd, P.Line, 1, 0.5)

        local listFrame
        dd.MouseButton1Click:Connect(function()
            if listFrame then listFrame:Destroy(); listFrame = nil; return end
            listFrame = Instance.new("Frame")
            listFrame.Size = UDim2.new(0, 120, 0, #options * 24 + 6)
            listFrame.Position = UDim2.new(1, -136, 1, 4)
            listFrame.BackgroundColor3 = P.Bg
            listFrame.BorderSizePixel = 0
            listFrame.ZIndex = 20
            listFrame.Parent = c
            corner(listFrame, 8)
            stroke(listFrame, P.Line, 1, 0.3)

            for i, opt in ipairs(options) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1, -6, 0, 22)
                ob.Position = UDim2.fromOffset(3, 3 + (i - 1) * 24)
                ob.BackgroundColor3 = P.Card
                ob.BackgroundTransparency = 0.3
                ob.Text = opt
                ob.Font = Enum.Font.GothamMedium
                ob.TextSize = 11
                ob.TextColor3 = P.White
                ob.BorderSizePixel = 0
                ob.AutoButtonColor = false
                ob.ZIndex = 21
                ob.Parent = listFrame
                corner(ob, 4)

                ob.MouseEnter:Connect(function()
                    tween(ob, 0.12, {BackgroundColor3 = P.White, TextColor3 = P.Bg, BackgroundTransparency = 0})
                end)
                ob.MouseLeave:Connect(function()
                    tween(ob, 0.12, {BackgroundColor3 = P.Card, TextColor3 = P.White, BackgroundTransparency = 0.3})
                end)
                ob.MouseButton1Click:Connect(function()
                    current = opt
                    dd.Text = opt
                    if listFrame then listFrame:Destroy(); listFrame = nil end
                    if callback then pcall(callback, opt) end
                end)
            end
        end)
    end

    return Tab
end

-- ==========================================
-- UTILS
-- ==========================================
local function resolveRig(char)
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("RootPart") or char:FindFirstChild("Root")
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HeadHB") or char:FindFirstChild("head")
    if not head and hrp then head = hrp end
    return {Humanoid = hum, HRP = hrp, Head = head}
end

local function isTeammate(plr)
    if not plr or not LP.Team or not plr.Team then return false end
    return plr.Team == LP.Team
end

local function isDead(model)
    if not model then return true end
    local n = model.Name:lower()
    if (n:find("dead") or n:find("ragdoll") or n:find("corpse")) and not Players:GetPlayerFromCharacter(model) then
        return true
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 and not model:FindFirstChild("HumanoidRootPart") then
        return true
    end
    return false
end

-- ==========================================
-- ESP
-- ==========================================
local ESPLayer = Instance.new("Frame")
ESPLayer.Size = UDim2.fromScale(1, 1)
ESPLayer.BackgroundTransparency = 1
ESPLayer.ZIndex = 100
ESPLayer.Visible = false
ESPLayer.Parent = screenGui

local ESPCache = {}

local function createESPEntry()
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.ZIndex = 101
    box.Parent = ESPLayer

    local lines = {}
    for i = 1, 4 do
        local l = Instance.new("Frame")
        l.BackgroundColor3 = P.White
        l.BorderSizePixel = 0
        l.ZIndex = 101
        l.Parent = box
        table.insert(lines, l)
    end

    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.TextColor3 = P.White
    name.TextSize = 11
    name.Font = Enum.Font.GothamBold
    name.TextStrokeTransparency = 0
    name.TextStrokeColor3 = P.Bg
    name.ZIndex = 102
    name.Parent = ESPLayer

    local hpBg = Instance.new("Frame")
    hpBg.BackgroundColor3 = P.Bg
    hpBg.BorderSizePixel = 0
    hpBg.ZIndex = 101
    hpBg.Parent = ESPLayer
    corner(hpBg, 2)

    local hpFill = Instance.new("Frame")
    hpFill.BackgroundColor3 = P.White
    hpFill.BorderSizePixel = 0
    hpFill.ZIndex = 102
    hpFill.Parent = hpBg
    corner(hpFill, 2)

    local dist = Instance.new("TextLabel")
    dist.BackgroundTransparency = 1
    dist.TextColor3 = P.White60
    dist.TextSize = 10
    dist.Font = Enum.Font.Gotham
    dist.TextStrokeTransparency = 0
    dist.TextStrokeColor3 = P.Bg
    dist.ZIndex = 102
    dist.Parent = ESPLayer

    local tracer = Instance.new("Frame")
    tracer.BackgroundColor3 = P.White
    tracer.BorderSizePixel = 0
    tracer.ZIndex = 101
    tracer.AnchorPoint = Vector2.new(0.5, 0.5)
    tracer.Visible = false
    tracer.Parent = ESPLayer

    return {Box=box, Lines=lines, Name=name, HPBg=hpBg, HPFill=hpFill, Distance=dist, Tracer=tracer}
end

local function removeESPEntry(e)
    pcall(function() e.Box:Destroy() end)
    pcall(function() e.Name:Destroy() end)
    pcall(function() e.HPBg:Destroy() end)
    pcall(function() e.Distance:Destroy() end)
    pcall(function() e.Tracer:Destroy() end)
end

track(RunService.RenderStepped:Connect(function()
    if not Config.ESPEnabled then
        if ESPLayer.Visible then
            ESPLayer.Visible = false
            for plr, e in pairs(ESPCache) do removeESPEntry(e); ESPCache[plr] = nil end
        end
        return
    end
    ESPLayer.Visible = true

    local cam = Workspace.CurrentCamera
    if not cam then return end

    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP or not plr.Character or isDead(plr.Character) then
            if ESPCache[plr] then removeESPEntry(ESPCache[plr]); ESPCache[plr] = nil end
        else
            if Config.ESPTeamCheck and isTeammate(plr) then
                if ESPCache[plr] then removeESPEntry(ESPCache[plr]); ESPCache[plr] = nil end
            else
                local rig = resolveRig(plr.Character)
                if rig and rig.Humanoid and rig.Humanoid.Health > 0 and (rig.HRP or rig.Head) then
                    local anchor = rig.HRP or rig.Head
                    local dist = 0
                    if myPos then dist = (anchor.Position - myPos).Magnitude end

                    if dist > Config.ESPMaxDist then
                        if ESPCache[plr] then
                            ESPCache[plr].Box.Visible = false
                            ESPCache[plr].Name.Visible = false
                            ESPCache[plr].HPBg.Visible = false
                            ESPCache[plr].Distance.Visible = false
                            ESPCache[plr].Tracer.Visible = false
                        end
                    else
                        if not ESPCache[plr] then ESPCache[plr] = createESPEntry() end
                        local e = ESPCache[plr]

                        local topW = anchor.Position + Vector3.new(0, 3.5, 0)
                        local botW = anchor.Position - Vector3.new(0, 3, 0)
                        local topS, tV = cam:WorldToViewportPoint(topW)
                        local botS, bV = cam:WorldToViewportPoint(botW)

                        if tV or bV then
                            local h = math.abs(botS.Y - topS.Y)
                            local w = h * 0.5
                            local x = topS.X - w / 2
                            local y = topS.Y

                            e.Box.Visible = true
                            e.Box.Position = UDim2.fromOffset(x, y)
                            e.Box.Size = UDim2.fromOffset(w, h)

                            local len = math.min(w, h) * 0.25
                            local t = 2
                            e.Lines[1].Position = UDim2.fromOffset(0, 0); e.Lines[1].Size = UDim2.fromOffset(len, t)
                            e.Lines[2].Position = UDim2.fromOffset(w - len, 0); e.Lines[2].Size = UDim2.fromOffset(len, t)
                            e.Lines[3].Position = UDim2.fromOffset(0, h - t); e.Lines[3].Size = UDim2.fromOffset(len, t)
                            e.Lines[4].Position = UDim2.fromOffset(w - len, h - t); e.Lines[4].Size = UDim2.fromOffset(len, t)

                            if Config.ESPNames then
                                e.Name.Text = plr.Name
                                e.Name.Position = UDim2.fromOffset(x, y - 15)
                                e.Name.Size = UDim2.fromOffset(w, 13)
                                e.Name.Visible = true
                            else e.Name.Visible = false end

                            if Config.ESPHealth then
                                local hpR = math.clamp(rig.Humanoid.Health / rig.Humanoid.MaxHealth, 0, 1)
                                e.HPBg.Position = UDim2.fromOffset(x - 8, y)
                                e.HPBg.Size = UDim2.fromOffset(3, h)
                                e.HPBg.Visible = true
                                e.HPFill.Position = UDim2.fromOffset(0, h * (1 - hpR))
                                e.HPFill.Size = UDim2.new(1, 0, hpR, 0)
                            else e.HPBg.Visible = false end

                            if Config.ESPDist then
                                e.Distance.Text = math.floor(dist) .. "m"
                                e.Distance.Position = UDim2.fromOffset(x, y + h + 2)
                                e.Distance.Size = UDim2.fromOffset(w, 12)
                                e.Distance.Visible = true
                            else e.Distance.Visible = false end

                            if Config.ESPTracers then
                                local vp = cam.ViewportSize
                                local from = Vector2.new(vp.X / 2, vp.Y)
                                local to = Vector2.new(topS.X, botS.Y)
                                local diff = to - from
                                local length = diff.Magnitude
                                local angle = math.deg(math.atan2(diff.Y, diff.X))
                                e.Tracer.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
                                e.Tracer.Size = UDim2.fromOffset(length, 1)
                                e.Tracer.Rotation = angle
                                e.Tracer.Visible = true
                            else e.Tracer.Visible = false end
                        else
                            e.Box.Visible = false; e.Name.Visible = false; e.HPBg.Visible = false; e.Distance.Visible = false; e.Tracer.Visible = false
                        end
                    end
                end
            end
        end
    end
end))

local ChamsCache = {}
track(RunService.RenderStepped:Connect(function()
    if not Config.ESPChams then
        for model, hl in pairs(ChamsCache) do pcall(function() hl:Destroy() end); ChamsCache[model] = nil end
        return
    end
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and not isDead(plr.Character) and not (Config.ESPTeamCheck and isTeammate(plr)) then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                seen[plr.Character] = true
                local hl = ChamsCache[plr.Character]
                if not hl or not hl.Parent then
                    hl = Instance.new("Highlight")
                    hl.Name = "OnyxChams"
                    hl.Adornee = plr.Character
                    hl.Parent = plr.Character
                    ChamsCache[plr.Character] = hl
                end
                hl.FillColor = P.White
                hl.OutlineColor = P.White
                hl.FillTransparency = 0.7
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
        end
    end
    for model, hl in pairs(ChamsCache) do
        if not seen[model] then pcall(function() hl:Destroy() end); ChamsCache[model] = nil end
    end
end))

-- ==========================================
-- SILENT AIM
-- ==========================================
local silentActive = false
local lastTarget = nil

track(UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then silentActive = true end
end))
track(UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then silentActive = false; lastTarget = nil end
end))

local function findTarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bd = nil, Config.SilentFOV
    local myChar = LP.Character
    local myRig = resolveRig(myChar)
    local myHead = myRig and myRig.Head

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and not isDead(plr.Character) then
            if not (Config.SilentTeam and isTeammate(plr)) then
                local rig = resolveRig(plr.Character)
                if rig and rig.Humanoid and rig.Humanoid.Health > 0 then
                    local part = rig.Head or rig.HRP
                    if part then
                        local pos = part.Position
                        if Config.SilentPredict and part.AssemblyLinearVelocity then
                            pos = pos + part.AssemblyLinearVelocity * 0.15
                        end
                        local blocked = false
                        if Config.SilentWall and myHead then
                            local params = RaycastParams.new()
                            params.FilterType = Enum.RaycastFilterType.Exclude
                            params.FilterDescendantsInstances = {myChar, plr.Character}
                            if Workspace:Raycast(myHead.Position, pos - myHead.Position, params) then blocked = true end
                        end
                        if not blocked then
                            local sp, on = cam:WorldToViewportPoint(pos)
                            if on then
                                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if d < bd then bd = d; best = {part = part, pos = pos} end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

track(RunService.RenderStepped:Connect(function()
    if not Config.SilentEnabled or not silentActive then lastTarget = nil; return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local t = findTarget()
    if not t then lastTarget = nil; return end
    lastTarget = t
    local goal = CFrame.new(cam.CFrame.Position, t.pos)
    cam.CFrame = cam.CFrame:Lerp(goal, Config.SilentSmooth / 100)
end))

track(RunService.Heartbeat:Connect(function()
    if not Config.TriggerBot or not Config.SilentEnabled then return end
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = findTarget()
        if t then
            pcall(function()
                local cam = Workspace.CurrentCamera
                VirtualInputManager:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, true, game, 0)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, false, game, 0)
            end)
        end
    end
end))

pcall(function()
    local mouse = LP:GetMouse()
    if not mouse then return end
    local mt = getrawmetatable and getrawmetatable(mouse)
    if not mt or not setreadonly then return end
    local oldIdx = mt.__index
    setreadonly(mt, false)
    mt.__index = function(self, key)
        if Config.SilentEnabled and silentActive and lastTarget then
            if key == "Hit" then return CFrame.new(lastTarget.pos) end
            if key == "Target" then return lastTarget.part end
        end
        return oldIdx(self, key)
    end
    setreadonly(mt, true)
end)

-- ==========================================
-- HITBOX
-- ==========================================
local HBState = {SizeCache={}, CollideCache={}, MassCache={}, TouchCache={}}

local function savePart(p)
    local k = p:GetFullName()
    if HBState.SizeCache[k] == nil then
        HBState.SizeCache[k] = p.Size
        HBState.CollideCache[k] = p.CanCollide
        HBState.MassCache[k] = p.Massless
        HBState.TouchCache[k] = p.CanTouch
    end
end

local function expandPart(p)
    savePart(p)
    local sz = Config.HitboxSize
    pcall(function()
        p.Size = Vector3.new(sz, sz, sz)
        p.CanCollide = false
        p.Massless = true
        p.CanTouch = false
    end)
end

local function restorePart(p)
    local k = p:GetFullName()
    pcall(function()
        if HBState.SizeCache[k] then p.Size = HBState.SizeCache[k] end
        if HBState.CollideCache[k] ~= nil then p.CanCollide = HBState.CollideCache[k] end
        if HBState.MassCache[k] ~= nil then p.Massless = HBState.MassCache[k] end
        if HBState.TouchCache[k] ~= nil then p.CanTouch = HBState.TouchCache[k] end
    end)
    HBState.SizeCache[k] = nil; HBState.CollideCache[k] = nil; HBState.MassCache[k] = nil; HBState.TouchCache[k] = nil
end

local function restoreAllHB()
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") then
            for _, p in ipairs(model:GetDescendants()) do
                if p:IsA("BasePart") and HBState.SizeCache[p:GetFullName()] then restorePart(p) end
            end
        end
    end
end

track(task.spawn(function()
    while screenGui.Parent do
        task.wait(0.5)
        pcall(function()
            if Config.HitboxEnabled then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        local parts = {}
                        if Config.HitboxMode == "Head" or Config.HitboxMode == "Both" then
                            local h = plr.Character:FindFirstChild("Head")
                            if h then table.insert(parts, h) end
                        end
                        if Config.HitboxMode == "UpperTorso" or Config.HitboxMode == "Both" then
                            local ut = plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso")
                            if ut then table.insert(parts, ut) end
                        end
                        for _, p in ipairs(parts) do expandPart(p) end
                    end
                end
            elseif next(HBState.SizeCache) then
                restoreAllHB()
            end
        end)
    end
end))

-- ==========================================
-- MOVEMENT
-- ==========================================
track(RunService.Heartbeat:Connect(function()
    pcall(function()
        if LP.Character then
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if Config.SpeedEnabled then
                    hum.WalkSpeed = Config.SpeedValue
                elseif hum.WalkSpeed ~= 16 then
                    hum.WalkSpeed = 16
                end
                if Config.JumpEnabled then
                    hum.UseJumpPower = true
                    hum.JumpPower = Config.JumpValue
                elseif hum.JumpPower ~= 50 then
                    hum.JumpPower = 50
                end
                if Config.Godmode then
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                end
                if Config.SafeFall then
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
                end
            end
        end
    end)
end))

track(RunService.Stepped:Connect(function()
    if LP.Character and Config.Noclip then
        for _, v in ipairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
end))

track(task.spawn(function()
    while screenGui.Parent do
        task.wait()
        pcall(function()
            if Config.FlyEnabled and LP.Character then
                local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bv = hrp:FindFirstChild("OnyxFly") or Instance.new("BodyVelocity")
                    bv.Name = "OnyxFly"; bv.MaxForce = Vector3.new(1e9,1e9,1e9); bv.Parent = hrp
                    local bg = hrp:FindFirstChild("OnyxFlyG") or Instance.new("BodyGyro")
                    bg.Name = "OnyxFlyG"; bg.MaxTorque = Vector3.new(1e9,1e9,1e9); bg.P = 1e4; bg.Parent = hrp
                    local cam = Workspace.CurrentCamera
                    if cam then
                        local dir = Vector3.zero
                        local cf = cam.CFrame
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
                        bv.Velocity = dir.Magnitude > 0 and dir.Unit * Config.FlySpeed or Vector3.zero
                        bg.CFrame = cf
                    end
                end
            else
                if LP.Character then
                    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local bv = hrp:FindFirstChild("OnyxFly"); local bg = hrp:FindFirstChild("OnyxFlyG")
                        if bv then bv:Destroy() end
                        if bg then bg:Destroy() end
                    end
                end
            end
        end)
    end
end))

track(UserInputService.JumpRequest:Connect(function()
    if Config.InfJump and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- ==========================================
-- WORLD
-- ==========================================
track(RunService.RenderStepped:Connect(function()
    pcall(function()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        if Config.Fullbright then
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.OutdoorAmbient = Color3.new(1,1,1)
            Lighting.Brightness = 3
        end
        if Config.FogEnabled then
            Lighting.FogEnd = 500
            Lighting.FogStart = 0
        end
        if math.abs(cam.FieldOfView - Config.FOV) > 0.1 then
            cam.FieldOfView = Config.FOV
        end
    end)
end))

-- ==========================================
-- WEAPON
-- ==========================================
track(task.spawn(function()
    while screenGui.Parent do
        task.wait(Config.RapidFire and 0.03 or 0.5)
        pcall(function()
            if Config.RapidFire then
                local weapons = ReplicatedStorage:FindFirstChild("Weapons")
                if weapons then
                    for _, w in ipairs(weapons:GetChildren()) do
                        local fr = w:FindFirstChild("FireRate"); if fr and fr:IsA("NumberValue") then fr.Value = 0.03 end
                        local au = w:FindFirstChild("Auto"); if au and au:IsA("BoolValue") then au.Value = true end
                    end
                end
                local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
            if Config.InfAmmo then
                for _, c in ipairs({LP.Character, LP:FindFirstChildOfClass("Backpack")}) do
                    if c then
                        for _, tool in ipairs(c:GetChildren()) do
                            if tool:IsA("Tool") then
                                for _, v in ipairs(tool:GetDescendants()) do
                                    if v:IsA("IntValue") or v:IsA("NumberValue") then
                                        local n = v.Name:lower()
                                        if n:find("ammo") or n:find("clip") or n:find("mag") then v.Value = 9999 end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if Config.NoRecoil then
                local weapons = ReplicatedStorage:FindFirstChild("Weapons")
                if weapons then
                    for _, w in ipairs(weapons:GetChildren()) do
                        local rc = w:FindFirstChild("RecoilControl")
                        if rc and rc:IsA("NumberValue") then rc.Value = 0 end
                    end
                end
            end
        end)
    end
end))

track(LP.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end))

-- ==========================================
-- AUTO FLING
-- ==========================================
track(task.spawn(function()
    while screenGui.Parent do
        task.wait(0.5)
        pcall(function()
            if Config.AutoFling and LP.Character then
                local myHRP = LP.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LP and plr.Character then
                            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and (hrp.Position - myHRP.Position).Magnitude <= Config.AutoFlingRange then
                                local bv = Instance.new("BodyVelocity", hrp)
                                bv.Velocity = Vector3.new(math.random(-2000,2000), math.random(500,2500), math.random(-2000,2000))
                                bv.MaxForce = Vector3.new(1e9,1e9,1e9)
                                task.delay(1.2, function() pcall(function() bv:Destroy() end) end)
                            end
                        end
                    end
                end
            end
        end)
    end
end))

-- ==========================================
-- REMOTE SPY
-- ==========================================
local SpyLog = {}
local spyActive = false

if hookmetamethod then
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        if spyActive and (getnamecallmethod() == "FireServer" or getnamecallmethod() == "InvokeServer") then
            table.insert(SpyLog, {Time=os.time(), Remote=self:GetFullName(), Method=getnamecallmethod()})
            if #SpyLog > 200 then table.remove(SpyLog, 1) end
        end
        return old(self, ...)
    end)
end

-- ==========================================
-- BUILD TABS
-- ==========================================
local tHome    = Window:CreateTab("home")
local tVisuals = Window:CreateTab("visuals")
local tCombat  = Window:CreateTab("combat")
local tMove    = Window:CreateTab("movement")
local tFly     = Window:CreateTab("fly")
local tHitbox  = Window:CreateTab("hitbox")
local tESP     = Window:CreateTab("esp")
local tTroll   = Window:CreateTab("troll")
local tSpy     = Window:CreateTab("spy")
local tConfigs = Window:CreateTab("configs")

-- HOME
tHome:CreateSection("info")
local infoLbl = tHome:CreateLabel("", 100)
track(task.spawn(function()
    while screenGui.Parent do
        pcall(function()
            local ch = LP.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            infoLbl.Text = string.format(
                "%s\n%d / %d hp\n%.0f, %.0f, %.0f\n%.1f ws",
                LP.Name,
                hum and hum.Health or 0, hum and hum.MaxHealth or 0,
                hrp and hrp.Position.X or 0, hrp and hrp.Position.Y or 0, hrp and hrp.Position.Z or 0,
                hum and hum.WalkSpeed or 0
            )
        end)
        task.wait(0.5)
    end
end))
tHome:CreateSection("quick")
tHome:CreateButton("rejoin", function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end)
tHome:CreateButton("reset", function() if LP.Character then LP.Character:BreakJoints() end end)
tHome:CreateButton("copy jobid", function() pcall(function() if setclipboard then setclipboard(game.JobId) end end) end)

-- VISUALS
tVisuals:CreateSection("lighting")
tVisuals:CreateToggle("fullbright", Config.Fullbright, function(v) Config.Fullbright = v end)
tVisuals:CreateToggle("fog", Config.FogEnabled, function(v)
    Config.FogEnabled = v
    if not v then
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
    end
end)
tVisuals:CreateSection("camera")
tVisuals:CreateSlider("fov", 40, 180, 70, function(v) Config.FOV = v end)
tVisuals:CreateSection("sky")
tVisuals:CreateButton("reset sky", function()
    pcall(function()
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
    end)
end)

-- COMBAT
tCombat:CreateSection("silent aim")
tCombat:CreateToggle("enabled", Config.SilentEnabled, function(v) Config.SilentEnabled = v end)
tCombat:CreateSlider("fov", 20, 500, 150, function(v) Config.SilentFOV = v end)
tCombat:CreateSlider("smooth", 10, 100, 50, function(v) Config.SilentSmooth = v end)
tCombat:CreateToggle("wall check", Config.SilentWall, function(v) Config.SilentWall = v end)
tCombat:CreateToggle("team check", Config.SilentTeam, function(v) Config.SilentTeam = v end)
tCombat:CreateToggle("prediction", Config.SilentPredict, function(v) Config.SilentPredict = v end)
tCombat:CreateToggle("triggerbot", Config.TriggerBot, function(v) Config.TriggerBot = v end)
tCombat:CreateSection("weapon")
tCombat:CreateToggle("rapid fire", Config.RapidFire, function(v) Config.RapidFire = v end)
tCombat:CreateToggle("infinite ammo", Config.InfAmmo, function(v) Config.InfAmmo = v end)
tCombat:CreateToggle("no recoil", Config.NoRecoil, function(v) Config.NoRecoil = v end)
tCombat:CreateSection("character")
tCombat:CreateToggle("godmode", Config.Godmode, function(v) Config.Godmode = v end)
tCombat:CreateToggle("anti-afk", Config.AntiAFK, function(v) Config.AntiAFK = v end)
tCombat:CreateSection("action")
tCombat:CreateButton("heal", function()
    if LP.Character then local h = LP.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health = h.MaxHealth end end
end)
tCombat:CreateButton("kill all", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h then h.Health = 0 end
        end
    end
end, true)

-- MOVEMENT
tMove:CreateSection("speed")
tMove:CreateToggle("enabled", Config.SpeedEnabled, function(v) Config.SpeedEnabled = v end)
tMove:CreateSlider("walkspeed", 16, 500, 50, function(v) Config.SpeedValue = v end)
tMove:CreateSection("jump")
tMove:CreateToggle("enabled", Config.JumpEnabled, function(v) Config.JumpEnabled = v end)
tMove:CreateSlider("jumppower", 50, 500, 100, function(v) Config.JumpValue = v end)
tMove:CreateToggle("infinite jump", Config.InfJump, function(v) Config.InfJump = v end)
tMove:CreateSection("safety")
tMove:CreateToggle("noclip", Config.Noclip, function(v) Config.Noclip = v end)
tMove:CreateToggle("safe fall", Config.SafeFall, function(v) Config.SafeFall = v end)
tMove:CreateSlider("gravity", 0, 500, 196, function(v) Workspace.Gravity = v end)

-- FLY
tFly:CreateSection("fly")
tFly:CreateToggle("enabled", Config.FlyEnabled, function(v) Config.FlyEnabled = v end)
tFly:CreateSlider("speed", 10, 500, 100, function(v) Config.FlySpeed = v end)
tFly:CreateSection("controls")
tFly:CreateLabel("w/a/s/d — move\nspace — up\nlctrl — down", 50)

-- HITBOX
tHitbox:CreateSection("expander")
tHitbox:CreateToggle("enabled", Config.HitboxEnabled, function(v)
    Config.HitboxEnabled = v
    if not v then restoreAllHB() end
end)
tHitbox:CreateSlider("size", 3, 12, 6, function(v) Config.HitboxSize = v end)
tHitbox:CreateDropdown("mode", {"Head", "UpperTorso", "Both"}, Config.HitboxMode, function(v) Config.HitboxMode = v end)
tHitbox:CreateButton("restore all", function() restoreAllHB() end)

-- ESP
tESP:CreateSection("esp")
tESP:CreateToggle("enabled", Config.ESPEnabled, function(v)
    Config.ESPEnabled = v
    if not v then
        for plr, e in pairs(ESPCache) do removeESPEntry(e); ESPCache[plr] = nil end
    end
end)
tESP:CreateToggle("names", Config.ESPNames, function(v) Config.ESPNames = v end)
tESP:CreateToggle("health", Config.ESPHealth, function(v) Config.ESPHealth = v end)
tESP:CreateToggle("distance", Config.ESPDist, function(v) Config.ESPDist = v end)
tESP:CreateToggle("tracers", Config.ESPTracers, function(v) Config.ESPTracers = v end)
tESP:CreateToggle("team check", Config.ESPTeamCheck, function(v) Config.ESPTeamCheck = v end)
tESP:CreateSlider("max dist", 100, 2000, 500, function(v) Config.ESPMaxDist = v end)
tESP:CreateSection("chams")
tESP:CreateToggle("enabled", Config.ESPChams, function(v) Config.ESPChams = v end)

-- TROLL
tTroll:CreateSection("visibility")
tTroll:CreateButton("invisible", function()
    if LP.Character then
        for _, v in ipairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
        end
    end
end)
tTroll:CreateButton("visible", function()
    if LP.Character then
        for _, v in ipairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
        end
    end
end)
tTroll:CreateSection("auto fling")
tTroll:CreateToggle("enabled", Config.AutoFling, function(v) Config.AutoFling = v end)
tTroll:CreateSlider("range", 5, 100, 30, function(v) Config.AutoFlingRange = v end)
tTroll:CreateSection("mass")
tTroll:CreateButton("fling all", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.Velocity = Vector3.new(math.random(-2000,2000), math.random(500,2500), math.random(-2000,2000))
                bv.MaxForce = Vector3.new(1e9,1e9,1e9)
                task.delay(1.5, function() pcall(function() bv:Destroy() end) end)
            end
        end
    end
end, true)
tTroll:CreateButton("teleport all to me", function()
    if not LP.Character then return end
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos = hrp.Position
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then h.CFrame = CFrame.new(pos + Vector3.new(math.random(-6,6), 4, math.random(-6,6))) end
        end
    end
end)

-- SPY
tSpy:CreateSection("remote spy")
tSpy:CreateToggle("enabled", false, function(v) spyActive = v end)
tSpy:CreateButton("clear", function() table.clear(SpyLog) end)
local spyLbl = tSpy:CreateLabel("", 320)
spyLbl.TextXAlignment = Enum.TextXAlignment.Left
spyLbl.TextYAlignment = Enum.TextYAlignment.Top
spyLbl.Font = Enum.Font.Code
spyLbl.TextSize = 10
track(task.spawn(function()
    while screenGui.Parent do
        task.wait(0.8)
        pcall(function()
            if spyActive and #SpyLog > 0 then
                local txt = ""
                for i = math.max(1, #SpyLog - 20), #SpyLog do
                    local e = SpyLog[i]
                    txt = txt .. "[" .. os.date("%H:%M:%S", e.Time) .. "] " .. e.Remote .. "\n"
                end
                spyLbl.Text = txt
            end
        end)
    end
end))

-- CONFIGS
tConfigs:CreateSection("create")
local cfgNameBox = tConfigs:CreateTextBox("config name", "default", function() end)
tConfigs:CreateButton("save", function()
    local n = cfgNameBox.Text
    if n and n ~= "" then
        if saveConfigToFile(n) then
            notify("ONYX", "saved: " .. n, 3)
        else
            notify("ONYX", "save failed (no file access)", 3)
        end
    end
end)
tConfigs:CreateSection("load")
local cfgLoadBox = tConfigs:CreateTextBox("config name", "default", function() end)
tConfigs:CreateButton("load", function()
    local n = cfgLoadBox.Text
    if n and n ~= "" then
        if loadConfigFromFile(n) then
            notify("ONYX", "loaded: " .. n, 3)
        else
            notify("ONYX", "config not found", 3)
        end
    end
end)
tConfigs:CreateSection("manage")
tConfigs:CreateButton("list configs", function()
    local list = listConfigs()
    if #list == 0 then
        notify("ONYX", "no configs", 3)
    else
        notify("ONYX", table.concat(list, ", "), 5)
    end
end)
tConfigs:CreateButton("delete", function()
    local n = cfgLoadBox.Text
    if n and n ~= "" then
        if deleteConfigFile(n) then
            notify("ONYX", "deleted: " .. n, 3)
        else
            notify("ONYX", "delete failed", 3)
        end
    end
end, true)
tConfigs:CreateSection("session")
tConfigs:CreateButton("reset defaults", function()
    for k, v in pairs(DefaultConfig) do Config[k] = v end
    notify("ONYX", "reset", 3)
end, true)
tConfigs:CreateButton("unload", function()
    for _, c in ipairs(_G.OnyxConnections) do pcall(function() c:Disconnect() end) end
    if screenGui then screenGui:Destroy() end
    _G.OnyxUI = nil
end, true)

-- ==========================================
-- MENU TOGGLE (isolated, reliable)
-- ==========================================
local menuVisible = false
track(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.MenuKey then
        menuVisible = not menuVisible
        if menuVisible then
            mainFrame.Visible = true
            mainFrame.Size = UDim2.fromOffset(760, 500)
            tween(mainFrame, 0.35, {Size = UDim2.fromOffset(940, 620)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            tween(mainFrame, 0.25, {Size = UDim2.fromOffset(760, 500)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.delay(0.28, function()
                mainFrame.Visible = false
                mainFrame.Size = UDim2.fromOffset(940, 620)
            end)
        end
    end
end))

print("ONYX loaded | credits @SuperburkeScript")