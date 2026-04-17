--[[
    SoraUI - Ultimate UI Library for Roblox Executors
    Version: 11.0.0 
    Author: KercX



    Features:
    - Custom modern glassmorphism design
    - Custom icon system (80+ built-in, extensible)
    - Custom font support (Gotham, Segoe, etc.)
    - Resizable, draggable windows (not fullscreen)
    - Full key system (license activation, HWID, expiry, offline/online)
    - 30+ UI controls (buttons, toggles, sliders, inputs, dropdowns, color pickers, keybinds, progress bars, checkboxes, radio groups, accordions, listboxes, treeviews, canvas, chart, console, property grid, toolbar, status bar, menu bar, and more)
    - Theme system (Dark/Light/Custom) with live switching
    - Notification queue with icons
    - Global keybind manager
    - Tooltip system with delay
    - Settings persistence (Attribute/DataStore)
    - Smooth animations (TweenService)
    - Fully documented API
--]]

local SoraUI = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")
local DataStoreService = game:GetService("DataStoreService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================================
--  CONFIGURATION
-- ============================================================================
local config = {
    -- Window
    DefaultWindowSize = UDim2.new(0, 850, 0, 650),
    MinWindowSize = Vector2.new(500, 400),
    WindowRounding = 16,
    WindowBorder = true,
    WindowBorderColor = Color3.fromHex("#313244"),
    WindowBorderThickness = 1.5,
    WindowSnapThreshold = 20,
    SaveWindowPosition = true,
    
    -- Visual
    GlassBlur = true,
    BlurIntensity = 14,
    AnimationSpeed = 0.2,
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    FontLight = Enum.Font.Gotham,
    ScrollBarThickness = 6,
    TooltipDelay = 0.5,
    UseGradients = true,
    UseShadows = true,
    
    -- Custom fonts (override)
    CustomFont = nil,          -- e.g., "rbxasset://fonts/Inter.ttf"
    CustomFontBold = nil,
    
    -- Saving
    SaveMethod = "Attribute",   -- "Attribute" or "DataStore"
    DataStoreName = "SoraUI_Settings",
    
    -- Key System
    KeySystemEnabled = true,    -- set to false to disable license requirement
    KeyAPIURL = nil,
    UseOnlineValidation = false,
    
    -- Debug
    DebugMode = false,
    
    -- Theme (Dark default)
    Theme = {
        Name = "Dark",
        Background = Color3.fromHex("#1e1e2f"),
        TopBar = Color3.fromHex("#181825"),
        Card = Color3.fromHex("#2a2a3c"),
        CardHover = Color3.fromHex("#313244"),
        Text = Color3.fromHex("#cdd6f4"),
        TextMuted = Color3.fromHex("#89b4fa"),
        Accent = Color3.fromHex("#89b4fa"),
        AccentHover = Color3.fromHex("#b4befe"),
        Danger = Color3.fromHex("#f38ba8"),
        DangerHover = Color3.fromHex("#eba0ac"),
        Success = Color3.fromHex("#a6e3a1"),
        Warning = Color3.fromHex("#f9e2af"),
        Border = Color3.fromHex("#313244"),
        SliderBg = Color3.fromHex("#45475a"),
        SliderFill = Color3.fromHex("#89b4fa"),
        InputBg = Color3.fromHex("#313244"),
        DropdownBg = Color3.fromHex("#313244"),
        ToggleOn = Color3.fromHex("#a6e3a1"),
        ToggleOff = Color3.fromHex("#45475a"),
        ProgressBg = Color3.fromHex("#313244"),
        ProgressFill = Color3.fromHex("#89b4fa"),
        Separator = Color3.fromHex("#45475a"),
        Shadow = Color3.fromHex("#000000"),
    },
    
    LightTheme = {
        Name = "Light",
        Background = Color3.fromHex("#eff1f5"),
        TopBar = Color3.fromHex("#e6e9ef"),
        Card = Color3.fromHex("#dce0e8"),
        CardHover = Color3.fromHex("#ccd0da"),
        Text = Color3.fromHex("#4c4f69"),
        TextMuted = Color3.fromHex("#7287fd"),
        Accent = Color3.fromHex("#7287fd"),
        AccentHover = Color3.fromHex("#89b4fa"),
        Danger = Color3.fromHex("#d20f39"),
        DangerHover = Color3.fromHex("#e64553"),
        Success = Color3.fromHex("#40a02b"),
        Warning = Color3.fromHex("#df8e1d"),
        Border = Color3.fromHex("#acb0be"),
        SliderBg = Color3.fromHex("#bcc0cc"),
        SliderFill = Color3.fromHex("#7287fd"),
        InputBg = Color3.fromHex("#e6e9ef"),
        DropdownBg = Color3.fromHex("#e6e9ef"),
        ToggleOn = Color3.fromHex("#40a02b"),
        ToggleOff = Color3.fromHex("#bcc0cc"),
        ProgressBg = Color3.fromHex("#bcc0cc"),
        ProgressFill = Color3.fromHex("#7287fd"),
        Separator = Color3.fromHex("#acb0be"),
        Shadow = Color3.fromHex("#000000"),
    },
    
    CustomTheme = nil,
}

-- ============================================================================
--  HELPER FUNCTIONS
-- ============================================================================
local function debugLog(...)
    if config.DebugMode then
        print("[SoraUI]", ...)
    end
end

local function createInstance(className, props, parent)
    local inst = Instance.new(className)
    for k, v in pairs(props) do
        inst[k] = v
    end
    inst.Parent = parent
    return inst
end

local function applyCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or config.WindowRounding)
    corner.Parent = obj
end

local function applyStroke(obj, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or config.Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = obj
end

local function applyShadow(obj, size, color, transparency)
    if not config.UseShadows then return end
    local shadow = Instance.new("UIShadow")
    shadow.Size = size or 8
    shadow.Color = color or config.Theme.Shadow
    shadow.Transparency = transparency or 0.5
    shadow.Parent = obj
end

local function applyGradient(obj, color1, color2, direction)
    if not config.UseGradients then return end
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color1), ColorSequenceKeypoint.new(1, color2)})
    grad.Rotation = direction or 90
    grad.Parent = obj
end

local function getColor(key)
    if config.CustomTheme and config.CustomTheme[key] then
        return config.CustomTheme[key]
    end
    return config.Theme[key] or Color3.new(1,1,1)
end

local function getFont(weight)
    if weight == "bold" and config.CustomFontBold then
        return config.CustomFontBold
    elseif config.CustomFont then
        return config.CustomFont
    end
    if weight == "bold" then return config.FontBold end
    if weight == "light" then return config.FontLight end
    return config.Font
end

-- ============================================================================
--  CUSTOM ICON MANAGER (modern, extensible)
-- ============================================================================
local IconManager = {}

-- Built-in icons (Material Design style using Roblox asset IDs)
local Icons = {
    -- Navigation
    home = "rbxassetid://6031094066",
    dashboard = "rbxassetid://6031094066",
    menu = "rbxassetid://6031093921",
    back = "rbxassetid://6031093518",
    forward = "rbxassetid://6031093529",
    refresh = "rbxassetid://6031093723",
    search = "rbxassetid://6031093787",
    settings = "rbxassetid://6031094371",
    -- Actions
    add = "rbxassetid://6031093506",
    remove = "rbxassetid://6031093679",
    delete = "rbxassetid://6031093636",
    edit = "rbxassetid://6031093746",
    save = "rbxassetid://6031093763",
    copy = "rbxassetid://6031093618",
    cut = "rbxassetid://6031093629",
    paste = "rbxassetid://6031093967",
    download = "rbxassetid://6031093682",
    upload = "rbxassetid://6031094085",
    link = "rbxassetid://6031093886",
    external = "rbxassetid://6031093708",
    -- Window controls
    close = "rbxassetid://6031094798",
    minimize = "rbxassetid://6031094563",
    maximize = "rbxassetid://6031094446",
    restore = "rbxassetid://6031094446",
    -- Status
    check = "rbxassetid://6031093550",
    close_circle = "rbxassetid://6031094798",
    info = "rbxassetid://6031093861",
    warning = "rbxassetid://6031094119",
    error = "rbxassetid://6031093699",
    success = "rbxassetid://6031093798",
    lock = "rbxassetid://6031093910",
    unlock = "rbxassetid://6031093934",
    key = "rbxassetid://6031093871",
    -- Users
    user = "rbxassetid://6031094101",
    group = "rbxassetid://6031093847",
    add_user = "rbxassetid://6031093506",
    -- Media
    image = "rbxassetid://6031093839",
    video = "rbxassetid://6031094129",
    music = "rbxassetid://6031093990",
    volume_up = "rbxassetid://6031094142",
    volume_down = "rbxassetid://6031094131",
    volume_off = "rbxassetid://6031094153",
    -- File/Folder
    folder = "rbxassetid://6031093815",
    file = "rbxassetid://6031093829",
    -- Arrows
    arrow_left = "rbxassetid://6031093518",
    arrow_right = "rbxassetid://6031093529",
    arrow_up = "rbxassetid://6031093543",
    arrow_down = "rbxassetid://6031093499",
    -- Text
    bold = "rbxassetid://6031093560",
    italic = "rbxassetid://6031093897",
    underline = "rbxassetid://6031094073",
    align_left = "rbxassetid://6031093479",
    align_center = "rbxassetid://6031093467",
    align_right = "rbxassetid://6031093488",
    -- Misc
    star = "rbxassetid://6031094005",
    heart = "rbxassetid://6031093853",
    clock = "rbxassetid://6031093571",
    calendar = "rbxassetid://6031093534",
    more = "rbxassetid://6031093947",
    dropdown = "rbxassetid://6031093659",
    checkbox_checked = "rbxassetid://6031093580",
    checkbox_unchecked = "rbxassetid://6031093606",
    radio_selected = "rbxassetid://6031093955",
    radio_unselected = "rbxassetid://6031093979",
    -- Additional (40+ more)
    chat = "rbxassetid://6031093548",
    mail = "rbxassetid://6031093925",
    send = "rbxassetid://6031093790",
    print = "rbxassetid://6031093970",
    cloud = "rbxassetid://6031093593",
    wifi = "rbxassetid://6031094165",
    battery = "rbxassetid://6031093521",
    bluetooth = "rbxassetid://6031093558",
    camera = "rbxassetid://6031093537",
    mic = "rbxassetid://6031093931",
    headphone = "rbxassetid://6031093840",
    gamepad = "rbxassetid://6031093821",
    code = "rbxassetid://6031093600",
    terminal = "rbxassetid://6031094081",
    database = "rbxassetid://6031093648",
    server = "rbxassetid://6031093960",
    shield = "rbxassetid://6031093985",
    eye = "rbxassetid://6031093736",
    eye_off = "rbxassetid://6031093720",
    filter = "rbxassetid://6031093758",
    sort = "rbxassetid://6031094013",
    grid = "rbxassetid://6031093832",
    list = "rbxassetid://6031093890",
    map = "rbxassetid://6031093928",
    pin = "rbxassetid://6031093963",
    tag = "rbxassetid://6031094070",
    award = "rbxassetid://6031093500",
    briefcase = "rbxassetid://6031093568",
    bug = "rbxassetid://6031093579",
    calculator = "rbxassetid://6031093527",
    credit_card = "rbxassetid://6031093632",
    gift = "rbxassetid://6031093819",
    globe = "rbxassetid://6031093827",
    help = "rbxassetid://6031093852",
    id_card = "rbxassetid://6031093867",
    lightbulb = "rbxassetid://6031093883",
    location = "rbxassetid://6031093902",
    phone = "rbxassetid://6031093950",
    printer = "rbxassetid://6031093974",
    shopping_cart = "rbxassetid://6031093994",
    ticket = "rbxassetid://6031094086",
    trash = "rbxassetid://6031094105",
    truck = "rbxassetid://6031094115",
    wallet = "rbxassetid://6031094162",
}

function IconManager:GetIcon(iconName)
    return Icons[iconName] or Icons.info
end

function IconManager:CreateIcon(iconName, parent, size, color)
    local img = createInstance("ImageLabel", {
        Image = self:GetIcon(iconName),
        Size = size or UDim2.new(0, 24, 0, 24),
        BackgroundTransparency = 1,
        ImageColor3 = color or getColor("Text"),
    }, parent)
    return img
end

function IconManager:CreateIconButton(iconName, parent, callback, size, color, tooltip)
    local btn = createInstance("ImageButton", {
        Image = self:GetIcon(iconName),
        Size = size or UDim2.new(0, 28, 0, 28),
        BackgroundTransparency = 1,
        ImageColor3 = color or getColor("Text"),
        AutoButtonColor = false,
    }, parent)
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {ImageColor3 = getColor("Accent")}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {ImageColor3 = color or getColor("Text")}):Play()
    end)
    if tooltip then
        -- tooltip will be added later via section API
    end
    return btn
end

-- Register custom icons (user can add their own)
function IconManager:RegisterIcon(name, assetId)
    Icons[name] = assetId
end

SoraUI.Icons = IconManager

-- ============================================================================
--  KEY SYSTEM (Professional License Authentication)
-- ============================================================================
local KeySystem = {}

local licenseData = {
    activated = false,
    licenseKey = "",
    hwid = "",
    expiryDate = nil,
    lastCheck = 0,
}

local function generateHWID()
    local success, result = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if success and result then
        return result
    end
    return tostring(player.UserId) .. "_" .. HttpService:GenerateGUID(false)
end

local function saveLicenseData()
    local data = {
        activated = licenseData.activated,
        licenseKey = licenseData.licenseKey,
        hwid = licenseData.hwid,
        expiryDate = licenseData.expiryDate,
        lastCheck = licenseData.lastCheck,
    }
    local encoded = HttpService:JSONEncode(data)
    player:SetAttribute("SoraUI_License", encoded)
    if config.SaveMethod == "DataStore" then
        pcall(function()
            local ds = DataStoreService:GetDataStore("SoraUI_License")
            ds:SetAsync(player.UserId, data)
        end)
    end
end

local function loadLicenseData()
    local success, encoded = pcall(function()
        return player:GetAttribute("SoraUI_License")
    end)
    if success and encoded then
        local data = HttpService:JSONDecode(encoded)
        licenseData.activated = data.activated or false
        licenseData.licenseKey = data.licenseKey or ""
        licenseData.hwid = data.hwid or ""
        licenseData.expiryDate = data.expiryDate
        licenseData.lastCheck = data.lastCheck or 0
    end
    if config.SaveMethod == "DataStore" then
        pcall(function()
            local ds = DataStoreService:GetDataStore("SoraUI_License")
            local data = ds:GetAsync(player.UserId)
            if data then
                licenseData.activated = data.activated or false
                licenseData.licenseKey = data.licenseKey or ""
                licenseData.hwid = data.hwid or ""
                licenseData.expiryDate = data.expiryDate
                licenseData.lastCheck = data.lastCheck or 0
            end
        end)
    end
    if licenseData.hwid == "" then
        licenseData.hwid = generateHWID()
        saveLicenseData()
    end
end

local function offlineValidate(key)
    if not key:match("^[A-Z0-9]%-[A-Z0-9]%-[A-Z0-9]%-[A-Z0-9]$") then
        return false, "Invalid format. Use XXXX-XXXX-XXXX-XXXX"
    end
    local validKeys = {
        ["FREE-2025-0001-ABCD"] = { expiry = os.time() + 7*86400 },
        ["PREMIUM-1234-5678-90EF"] = { expiry = os.time() + 365*86400 },
        ["ULTIMATE-KERCX-2026"] = { expiry = os.time() + 999*86400 },
    }
    if validKeys[key] then
        return true, "Valid license", validKeys[key].expiry
    end
    return false, "License key not found"
end

local function onlineValidate(key)
    if not config.KeyAPIURL or not config.UseOnlineValidation then
        return offlineValidate(key)
    end
    local success, response = pcall(function()
        return HttpService:GetAsync(config.KeyAPIURL .. "?key=" .. key .. "&hwid=" .. licenseData.hwid)
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        if data and data.valid then
            return true, data.message or "Valid", data.expiry
        else
            return false, data.message or "Invalid key"
        end
    else
        return false, "Online validation failed"
    end
end

function KeySystem:Activate(key)
    if licenseData.activated then
        return false, "Already activated"
    end
    local valid, msg, expiry = onlineValidate(key)
    if not valid then
        return false, msg
    end
    licenseData.activated = true
    licenseData.licenseKey = key
    licenseData.expiryDate = expiry or os.time() + 365*86400
    licenseData.lastCheck = os.time()
    saveLicenseData()
    return true, "License activated successfully!"
end

function KeySystem:IsActivated()
    if not config.KeySystemEnabled then return true end
    if not licenseData.activated then return false end
    if licenseData.expiryDate and os.time() > licenseData.expiryDate then
        licenseData.activated = false
        saveLicenseData()
        return false
    end
    return true
end

function KeySystem:GetLicenseInfo()
    return {
        activated = licenseData.activated,
        licenseKey = licenseData.licenseKey,
        hwid = licenseData.hwid,
        expiry = licenseData.expiryDate and os.date("%Y-%m-%d %H:%M:%S", licenseData.expiryDate) or "Never",
        daysLeft = licenseData.expiryDate and math.max(0, math.floor((licenseData.expiryDate - os.time()) / 86400)) or -1,
    }
end

function KeySystem:Reset()
    licenseData.activated = false
    licenseData.licenseKey = ""
    licenseData.expiryDate = nil
    saveLicenseData()
end

function KeySystem:ShowActivationWindow(parentWindow)
    local win = SoraUI:CreateWindow("License Activation", UDim2.new(0, 520, 0, 380), {resizable = false, closable = false})
    local tab = win:AddTab("Activate", "key")
    local sec = tab:AddSection("Enter your license key", "key")
    local input = sec:AddInput("License Key", "XXXX-XXXX-XXXX-XXXX", "", nil)
    local statusLabel = sec:AddLabel("", 12, true)
    sec:AddButton("Activate", function()
        local key = input:Get()
        if key == "" then
            statusLabel.Text = "Please enter a key"
            statusLabel.TextColor3 = getColor("Danger")
            return
        end
        local success, msg = KeySystem:Activate(key)
        if success then
            statusLabel.Text = msg
            statusLabel.TextColor3 = getColor("Success")
            task.wait(1.5)
            win:Close()
            if parentWindow then parentWindow:Show() end
            SoraUI:Notify("Success", "License activated! Welcome.", 4, "success")
        else
            statusLabel.Text = msg
            statusLabel.TextColor3 = getColor("Danger")
        end
    end, false, "check")
    sec:AddSeparator()
    sec:AddLabel("Your HWID: " .. licenseData.hwid, 10, true)
    sec:AddLabel("This key is bound to this machine.", 10, true)
    return win
end

SoraUI.KeySystem = KeySystem

-- ============================================================================
--  NOTIFICATION MANAGER
-- ============================================================================
local notificationContainer = nil
local notificationQueue = {}
local isProcessingNotifications = false

local function setupNotificationContainer(parent)
    if not notificationContainer then
        notificationContainer = createInstance("Frame", {
            Name = "SoraUI_Notifications",
            Size = UDim2.new(0, 380, 0, 0),
            Position = UDim2.new(1, -400, 0, 20),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 1000,
        }, parent or playerGui)
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.Parent = notificationContainer
    end
end

local function processNotificationQueue()
    if isProcessingNotifications then return end
    if #notificationQueue == 0 then return end
    isProcessingNotifications = true
    local notifData = table.remove(notificationQueue, 1)
    local notif = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = getColor("Card"),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
    }, notificationContainer)
    applyCorner(notif, 12)
    if config.WindowBorder then
        applyStroke(notif, getColor("Border"), 0.5)
    end
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = notif
    
    if notifData.icon then
        local icon = IconManager:CreateIcon(notifData.icon, notif, UDim2.new(0, 22, 0, 22))
        icon.Position = UDim2.new(0, 0, 0.5, -11)
        local titleLabel = createInstance("TextLabel", {
            Text = notifData.title,
            Size = UDim2.new(1, -34, 0, 22),
            Position = UDim2.new(0, 34, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = getColor("Text"),
            Font = getFont("bold"),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, notif)
        local textLabel = createInstance("TextLabel", {
            Text = notifData.text,
            Size = UDim2.new(1, -34, 0, 0),
            Position = UDim2.new(0, 34, 0, 24),
            BackgroundTransparency = 1,
            TextColor3 = getColor("TextMuted"),
            Font = getFont(),
            TextSize = 12,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
        }, notif)
    else
        local titleLabel = createInstance("TextLabel", {
            Text = notifData.title,
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            TextColor3 = getColor("Text"),
            Font = getFont("bold"),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, notif)
        local textLabel = createInstance("TextLabel", {
            Text = notifData.text,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = getColor("TextMuted"),
            Font = getFont(),
            TextSize = 12,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
        }, notif)
    end
    
    task.delay(notifData.duration or 3, function()
        local tween = TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Wait()
        notif:Destroy()
        isProcessingNotifications = false
        processNotificationQueue()
    end)
end

function SoraUI:Notify(title, text, duration, icon)
    setupNotificationContainer()
    table.insert(notificationQueue, {title = title, text = text, duration = duration, icon = icon})
    processNotificationQueue()
end

-- ============================================================================
--  THEME MANAGER
-- ============================================================================
local currentColors = {}
local function applyThemeToGui(guiObject)
    for _, child in ipairs(guiObject:GetDescendants()) do
        if child:IsA("GuiObject") and child:GetAttribute("ThemeColor") then
            local colorKey = child:GetAttribute("ThemeColor")
            local col = getColor(colorKey)
            if col then child.BackgroundColor3 = col end
        elseif (child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox")) and child:GetAttribute("ThemeTextColor") then
            local colorKey = child:GetAttribute("ThemeTextColor")
            local col = getColor(colorKey)
            if col then child.TextColor3 = col end
        elseif child:IsA("ImageLabel") and child:GetAttribute("ThemeImageColor") then
            local colorKey = child:GetAttribute("ThemeImageColor")
            local col = getColor(colorKey)
            if col then child.ImageColor3 = col end
        end
    end
end

function SoraUI:SetTheme(themeName, customColors)
    if customColors then
        config.CustomTheme = customColors
        currentColors = customColors
    elseif themeName == "Light" then
        currentColors = config.LightTheme
    else
        currentColors = config.Theme
    end
    config.Theme.Name = themeName
    if self._mainGui then
        applyThemeToGui(self._mainGui)
    end
    for _, win in pairs(self._windows or {}) do
        if win._gui then applyThemeToGui(win._gui) end
    end
    debugLog("Theme set to", themeName)
end

-- ============================================================================
--  SAVE SYSTEM (UI settings)
-- ============================================================================
local savedSettings = {}
local dataStore = nil
if config.SaveMethod == "DataStore" then
    dataStore = DataStoreService:GetDataStore(config.DataStoreName)
end

local function loadSettings()
    savedSettings = {}
    if config.SaveMethod == "Attribute" then
        local success, data = pcall(function()
            return HttpService:JSONDecode(player:GetAttribute("SoraUI_Settings") or "{}")
        end)
        if success and type(data) == "table" then
            savedSettings = data
        end
    elseif config.SaveMethod == "DataStore" and dataStore then
        local success, data = pcall(function()
            return dataStore:GetAsync(player.UserId)
        end)
        if success and data then
            savedSettings = data
        end
    end
end

local function saveSettings()
    if config.SaveMethod == "Attribute" then
        local encoded = HttpService:JSONEncode(savedSettings)
        player:SetAttribute("SoraUI_Settings", encoded)
    elseif config.SaveMethod == "DataStore" and dataStore then
        pcall(function()
            dataStore:SetAsync(player.UserId, savedSettings)
        end)
    end
end

-- ============================================================================
--  KEYBIND MANAGER
-- ============================================================================
local keybindActions = {}
local function onContextAction(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        local callback = keybindActions[actionName]
        if callback then callback() end
        return Enum.ContextActionResult.Sink
    end
    return Enum.ContextActionResult.Pass
end

function SoraUI:RegisterKeybind(name, keyCode, callback)
    if not keyCode then return end
    keybindActions[name] = callback
    ContextActionService:BindAction(name, onContextAction, false, keyCode)
end

function SoraUI:UnregisterKeybind(name)
    keybindActions[name] = nil
    ContextActionService:UnbindAction(name)
end

-- ============================================================================
--  TOOLTIP MANAGER
-- ============================================================================
local tooltipFrame = nil
local tooltipTimer = nil

local function hideTooltip()
    if tooltipFrame then tooltipFrame:Destroy() tooltipFrame = nil end
    if tooltipTimer then tooltipTimer:Disconnect() end
end

local function showTooltip(text, position)
    hideTooltip()
    tooltipFrame = createInstance("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, position.X + 12, 0, position.Y + 24),
        BackgroundColor3 = getColor("Card"),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        ZIndex = 2000,
    }, playerGui)
    applyCorner(tooltipFrame, 6)
    applyStroke(tooltipFrame, getColor("Border"), 0.5)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = tooltipFrame
    local label = createInstance("TextLabel", {
        Text = text,
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = getColor("Text"),
        Font = getFont(),
        TextSize = 12,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, tooltipFrame)
end

local function setupTooltip(element, text)
    element.MouseEnter:Connect(function()
        tooltipTimer = task.delay(config.TooltipDelay, function()
            local pos = UserInputService:GetMouseLocation()
            showTooltip(text, pos)
        end)
    end)
    element.MouseLeave:Connect(hideTooltip)
    element.MouseMoved:Connect(function()
        if tooltipFrame then
            local pos = UserInputService:GetMouseLocation()
            tooltipFrame.Position = UDim2.new(0, pos.X + 12, 0, pos.Y + 24)
        end
    end)
end

-- ============================================================================
--  WINDOW CLASS (Core UI)
-- ============================================================================
local Window = {}
Window.__index = Window

function Window.new(title, size, options)
    local self = setmetatable({}, Window)
    options = options or {}
    self._title = title
    self._size = size or config.DefaultWindowSize
    self._minSize = options.minSize or config.MinWindowSize
    self._resizable = options.resizable ~= false
    self._closable = options.closable ~= false
    self._minimizable = options.minimizable ~= false
    self._snap = options.snap ~= false
    self._visible = true
    self._tabs = {}
    self._currentTab = nil
    self._savedPosition = nil
    
    self._gui = createInstance("ScreenGui", {
        Name = "SoraUI_Window_" .. title,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
    }, playerGui)
    SoraUI._windows = SoraUI._windows or {}
    SoraUI._windows[self] = self
    
    -- Load saved position
    if config.SaveWindowPosition and savedSettings["window_" .. title] then
        local pos = savedSettings["window_" .. title]
        self._size = UDim2.new(0, pos.width, 0, pos.height)
        self._savedPosition = UDim2.new(0, pos.x, 0, pos.y)
    end
    
    self._frame = createInstance("Frame", {
        Size = self._size,
        Position = self._savedPosition or UDim2.new(0.5, -self._size.X.Offset/2, 0.5, -self._size.Y.Offset/2),
        BackgroundColor3 = getColor("Background"),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, self._gui)
    applyCorner(self._frame, config.WindowRounding)
    if config.WindowBorder then
        applyStroke(self._frame, getColor("Border"), config.WindowBorderThickness)
    end
    applyShadow(self._frame, 12, getColor("Shadow"), 0.4)
    if config.GlassBlur then
        local blur = Instance.new("BlurEffect")
        blur.Size = config.BlurIntensity
        blur.Parent = self._frame
    end
    
    -- Top bar
    self._topBar = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = getColor("TopBar"),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
    }, self._frame)
    applyCorner(self._topBar, config.WindowRounding)
    local topOnly = Instance.new("UICorner")
    topOnly.CornerRadius = UDim.new(0, config.WindowRounding)
    topOnly.Parent = self._topBar
    
    self._titleLabel = createInstance("TextLabel", {
        Text = title,
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = getColor("Text"),
        Font = getFont("bold"),
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, self._topBar)
    
    -- Window buttons (icon buttons)
    if self._minimizable then
        self._minimizeBtn = IconManager:CreateIconButton("minimize", self._topBar, function()
            self:Minimize()
        end, UDim2.new(0, 28, 0, 28), getColor("Text"))
        self._minimizeBtn.Position = UDim2.new(1, -74, 0.5, -14)
    end
    if self._closable then
        self._closeBtn = IconManager:CreateIconButton("close", self._topBar, function()
            self:Close()
        end, UDim2.new(0, 28, 0, 28), getColor("Text"))
        self._closeBtn.Position = UDim2.new(1, -40, 0.5, -14)
    end
    
    -- Dragging & snapping
    local dragStart, dragPos, dragging = nil, nil, false
    self._topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            dragPos = self._frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if self._snap and config.WindowSnapThreshold > 0 then
                        local absPos = self._frame.AbsolutePosition
                        local screenSize = playerGui.AbsoluteSize
                        local threshold = config.WindowSnapThreshold
                        local newX, newY = absPos.X, absPos.Y
                        if absPos.X < threshold then newX = 0 end
                        if absPos.Y < threshold then newY = 0 end
                        if absPos.X + self._frame.AbsoluteSize.X > screenSize.X - threshold then newX = screenSize.X - self._frame.AbsoluteSize.X end
                        if absPos.Y + self._frame.AbsoluteSize.Y > screenSize.Y - threshold then newY = screenSize.Y - self._frame.AbsoluteSize.Y end
                        if newX ~= absPos.X or newY ~= absPos.Y then
                            self._frame.Position = UDim2.new(0, newX, 0, newY)
                        end
                    end
                    if config.SaveWindowPosition then
                        savedSettings["window_" .. title] = {
                            x = self._frame.AbsolutePosition.X,
                            y = self._frame.AbsolutePosition.Y,
                            width = self._frame.AbsoluteSize.X,
                            height = self._frame.AbsoluteSize.Y,
                        }
                        saveSettings()
                    end
                end
            end)
        end
    end)
    self._topBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self._frame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Resize handle
    if self._resizable then
        local resizeHandle = createInstance("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(1, -16, 1, -16),
            BackgroundColor3 = getColor("Accent"),
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
        }, self._frame)
        applyCorner(resizeHandle, 4)
        local resizing = false
        local startSize, startPos, startMouse
        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                startSize = self._frame.AbsoluteSize
                startPos = self._frame.AbsolutePosition
                startMouse = input.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - startMouse
                local newWidth = math.max(self._minSize.X, startSize.X + delta.X)
                local newHeight = math.max(self._minSize.Y, startSize.Y + delta.Y)
                self._frame.Size = UDim2.new(0, newWidth, 0, newHeight)
                local screenSize = playerGui.AbsoluteSize
                local newPosX = math.clamp(self._frame.AbsolutePosition.X, 0, screenSize.X - newWidth)
                local newPosY = math.clamp(self._frame.AbsolutePosition.Y, 0, screenSize.Y - newHeight)
                self._frame.Position = UDim2.new(0, newPosX, 0, newPosY)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
                if config.SaveWindowPosition then
                    savedSettings["window_" .. title] = {
                        x = self._frame.AbsolutePosition.X,
                        y = self._frame.AbsolutePosition.Y,
                        width = self._frame.AbsoluteSize.X,
                        height = self._frame.AbsoluteSize.Y,
                    }
                    saveSettings()
                end
            end
        end)
    end
    
    -- Tab sidebar
    self._tabContainer = createInstance("Frame", {
        Size = UDim2.new(0, 180, 1, -46),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = getColor("TopBar"),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
    }, self._frame)
    self._tabList = createInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = config.ScrollBarThickness,
    }, self._tabContainer)
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = self._tabList
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 10)
    tabPadding.PaddingRight = UDim.new(0, 10)
    tabPadding.PaddingTop = UDim.new(0, 12)
    tabPadding.PaddingBottom = UDim.new(0, 12)
    tabPadding.Parent = self._tabList
    
    -- Content container
    self._contentContainer = createInstance("ScrollingFrame", {
        Size = UDim2.new(1, -200, 1, -56),
        Position = UDim2.new(0, 200, 0, 52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = config.ScrollBarThickness,
        ScrollBarImageColor3 = getColor("Accent"),
    }, self._frame)
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 14)
    contentLayout.Parent = self._contentContainer
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 12)
    contentPadding.PaddingRight = UDim.new(0, 12)
    contentPadding.PaddingTop = UDim.new(0, 12)
    contentPadding.PaddingBottom = UDim.new(0, 12)
    contentPadding.Parent = self._contentContainer
    
    return self
end

function Window:AddTab(name, icon)
    local btn = createInstance("TextButton", {
        Text = name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = getColor("TopBar"),
        TextColor3 = getColor("Text"),
        Font = getFont(),
        TextSize = 13,
        AutoButtonColor = false,
        LayoutOrder = #self._tabs + 1,
    }, self._tabList)
    applyCorner(btn, 10)
    if icon then
        local iconImg = IconManager:CreateIcon(icon, btn, UDim2.new(0, 18, 0, 18), getColor("Text"))
        iconImg.Position = UDim2.new(0, 12, 0.5, -9)
        btn.Text = "   " .. name
        btn.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    local content = createInstance("ScrollingFrame", {
        Name = name .. "_Content",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = config.ScrollBarThickness,
        Visible = false,
    }, self._contentContainer)
    local innerLayout = Instance.new("UIListLayout")
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    innerLayout.Padding = UDim.new(0, 12)
    innerLayout.Parent = content
    local innerPad = Instance.new("UIPadding")
    innerPad.PaddingLeft = UDim.new(0, 6)
    innerPad.PaddingRight = UDim.new(0, 6)
    innerPad.PaddingTop = UDim.new(0, 6)
    innerPad.PaddingBottom = UDim.new(0, 6)
    innerPad.Parent = content
    
    local tab = { Button = btn, Content = content, Sections = {} }
    self._tabs[name] = tab
    btn.MouseButton1Click:Connect(function() self:SelectTab(name) end)
    if not self._currentTab then self:SelectTab(name) end
    
    -- Tab API
    local tabApi = {
        AddSection = function(sectionTitle, sectionIcon)
            local section = createInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = getColor("Card"),
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, content)
            applyCorner(section, config.WindowRounding - 2)
            applyStroke(section, getColor("Border"), 0.5)
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 14)
            pad.PaddingRight = UDim.new(0, 14)
            pad.PaddingTop = UDim.new(0, 14)
            pad.PaddingBottom = UDim.new(0, 14)
            pad.Parent = section
            
            local titleFrame = createInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundTransparency = 1,
            }, section)
            if sectionIcon then
                local iconImg = IconManager:CreateIcon(sectionIcon, titleFrame, UDim2.new(0, 22, 0, 22), getColor("Accent"))
                iconImg.Position = UDim2.new(0, 0, 0.5, -11)
                local titleLabel = createInstance("TextLabel", {
                    Text = sectionTitle,
                    Size = UDim2.new(1, -34, 1, 0),
                    Position = UDim2.new(0, 34, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont("bold"),
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, titleFrame)
            else
                local titleLabel = createInstance("TextLabel", {
                    Text = sectionTitle,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont("bold"),
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, titleFrame)
            end
            
            local contentArea = createInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, section)
            local areaLayout = Instance.new("UIListLayout")
            areaLayout.SortOrder = Enum.SortOrder.LayoutOrder
            areaLayout.Padding = UDim.new(0, 12)
            areaLayout.Parent = contentArea
            
            local sectionApi = {}
            
            -- Button
            function sectionApi:AddButton(text, callback, danger, icon)
                local btn = createInstance("TextButton", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundColor3 = danger and getColor("Danger") or getColor("Accent"),
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    AutoButtonColor = false,
                }, contentArea)
                applyCorner(btn, 10)
                if icon then
                    local iconImg = IconManager:CreateIcon(icon, btn, UDim2.new(0, 20, 0, 20), getColor("Text"))
                    iconImg.Position = UDim2.new(0, 14, 0.5, -10)
                    btn.Text = "   " .. text
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                end
                btn.MouseButton1Click:Connect(callback)
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(config.AnimationSpeed), {BackgroundColor3 = danger and getColor("DangerHover") or getColor("AccentHover")}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(config.AnimationSpeed), {BackgroundColor3 = danger and getColor("Danger") or getColor("Accent")}):Play()
                end)
                return btn
            end
            
            -- Toggle
            function sectionApi:AddToggle(text, default, callback)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, -80, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local toggle = createInstance("TextButton", {
                    Size = UDim2.new(0, 52, 0, 26),
                    Position = UDim2.new(1, -60, 0.5, -13),
                    BackgroundColor3 = default and getColor("ToggleOn") or getColor("ToggleOff"),
                    Text = "",
                    AutoButtonColor = false,
                }, frame)
                applyCorner(toggle, 13)
                local knob = createInstance("Frame", {
                    Size = UDim2.new(0, 22, 0, 22),
                    Position = UDim2.new(default and 1 or 0, default and -24 or 3, 0.5, -11),
                    BackgroundColor3 = Color3.fromHex("#ffffff"),
                    BorderSizePixel = 0,
                }, toggle)
                applyCorner(knob, 11)
                local function set(state)
                    default = state
                    TweenService:Create(toggle, TweenInfo.new(config.AnimationSpeed), {BackgroundColor3 = state and getColor("ToggleOn") or getColor("ToggleOff")}):Play()
                    TweenService:Create(knob, TweenInfo.new(config.AnimationSpeed), {Position = UDim2.new(state and 1 or 0, state and -24 or 3, 0.5, -11)}):Play()
                    if callback then callback(state) end
                end
                toggle.MouseButton1Click:Connect(function() set(not default) end)
                return { Set = set, Get = function() return default end }
            end
            
            -- Slider
            function sectionApi:AddSlider(text, min, max, default, callback, decimals)
                decimals = decimals or 0
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 68),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, -100, 0, 28),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local valueLabel = createInstance("TextLabel", {
                    Text = tostring(default),
                    Size = UDim2.new(0, 80, 0, 28),
                    Position = UDim2.new(1, -85, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("TextMuted"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, frame)
                local sliderBg = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 42),
                    BackgroundColor3 = getColor("SliderBg"),
                    BorderSizePixel = 0,
                }, frame)
                applyCorner(sliderBg, 4)
                local fill = createInstance("Frame", {
                    Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
                    BackgroundColor3 = getColor("SliderFill"),
                    BorderSizePixel = 0,
                }, sliderBg)
                applyCorner(fill, 4)
                local function update(input)
                    local rel = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
                    local val = math.clamp(min + (max-min) * rel, min, max)
                    if decimals == 0 then val = math.floor(val) else val = tonumber(string.format("%."..decimals.."f", val)) end
                    valueLabel.Text = tostring(val)
                    fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
                    if callback then callback(val) end
                    return val
                end
                local dragging = false
                sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        update(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                return {
                    Set = function(v)
                        local rel = (v-min)/(max-min)
                        fill.Size = UDim2.new(rel, 0, 1, 0)
                        valueLabel.Text = tostring(v)
                        if callback then callback(v) end
                    end,
                    Get = function() return tonumber(valueLabel.Text) end
                }
            end
            
            -- Slider with input
            function sectionApi:AddSliderWithInput(text, min, max, default, callback, decimals)
                decimals = decimals or 0
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 88),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local valueBox = createInstance("TextBox", {
                    Text = tostring(default),
                    Size = UDim2.new(0, 90, 0, 32),
                    Position = UDim2.new(1, -95, 0, 0),
                    BackgroundColor3 = getColor("InputBg"),
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 13,
                    ClearTextOnFocus = false,
                }, frame)
                applyCorner(valueBox, 8)
                local sliderBg = createInstance("Frame", {
                    Size = UDim2.new(1, -110, 0, 8),
                    Position = UDim2.new(0, 0, 0, 44),
                    BackgroundColor3 = getColor("SliderBg"),
                    BorderSizePixel = 0,
                }, frame)
                applyCorner(sliderBg, 4)
                local fill = createInstance("Frame", {
                    Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
                    BackgroundColor3 = getColor("SliderFill"),
                    BorderSizePixel = 0,
                }, sliderBg)
                applyCorner(fill, 4)
                local function updateValue(val)
                    if decimals == 0 then val = math.floor(val) else val = tonumber(string.format("%."..decimals.."f", val)) end
                    valueBox.Text = tostring(val)
                    fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
                    if callback then callback(val) end
                end
                local function updateSlider(input)
                    local rel = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
                    local val = math.clamp(min + (max-min) * rel, min, max)
                    updateValue(val)
                end
                local dragging = false
                sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                valueBox.FocusLost:Connect(function()
                    local val = tonumber(valueBox.Text) or default
                    val = math.clamp(val, min, max)
                    updateValue(val)
                end)
                return { Set = updateValue, Get = function() return tonumber(valueBox.Text) end }
            end
            
            -- Input
            function sectionApi:AddInput(text, placeholder, default, callback, numeric)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 62),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local box = createInstance("TextBox", {
                    Text = tostring(default or ""),
                    PlaceholderText = placeholder,
                    Size = UDim2.new(1, 0, 0, 36),
                    Position = UDim2.new(0, 0, 0, 30),
                    BackgroundColor3 = getColor("InputBg"),
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 13,
                    ClearTextOnFocus = false,
                }, frame)
                applyCorner(box, 8)
                box.FocusLost:Connect(function()
                    local val = box.Text
                    if numeric then val = tonumber(val) or default end
                    if callback then callback(val) end
                end)
                return {
                    Set = function(t) box.Text = tostring(t); callback(t) end,
                    Get = function() return numeric and tonumber(box.Text) or box.Text end
                }
            end
            
            -- Dropdown
            function sectionApi:AddDropdown(text, options, default, callback)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(0.5, -10, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local btn = createInstance("TextButton", {
                    Text = default,
                    Size = UDim2.new(0.5, 0, 0, 38),
                    Position = UDim2.new(0.5, 10, 0.5, -19),
                    BackgroundColor3 = getColor("DropdownBg"),
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 13,
                    AutoButtonColor = false,
                }, frame)
                applyCorner(btn, 8)
                local dropdown = nil
                local open = false
                local function close()
                    if dropdown then dropdown:Destroy() dropdown = nil end
                    open = false
                end
                btn.MouseButton1Click:Connect(function()
                    if open then close() return end
                    open = true
                    dropdown = createInstance("ScrollingFrame", {
                        Size = UDim2.new(0.5, 0, 0, 150),
                        Position = UDim2.new(0.5, 10, 0, 38),
                        BackgroundColor3 = getColor("DropdownBg"),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = config.ScrollBarThickness,
                    }, frame)
                    applyCorner(dropdown, 8)
                    local layout = Instance.new("UIListLayout")
                    layout.SortOrder = Enum.SortOrder.LayoutOrder
                    layout.Padding = UDim.new(0, 2)
                    layout.Parent = dropdown
                    for _, opt in ipairs(options) do
                        local optBtn = createInstance("TextButton", {
                            Text = opt,
                            Size = UDim2.new(1, 0, 0, 34),
                            BackgroundTransparency = 1,
                            TextColor3 = getColor("Text"),
                            Font = getFont(),
                            TextSize = 13,
                            AutoButtonColor = false,
                        }, dropdown)
                        optBtn.MouseEnter:Connect(function() optBtn.BackgroundColor3 = getColor("CardHover") end)
                        optBtn.MouseLeave:Connect(function() optBtn.BackgroundTransparency = 1 end)
                        optBtn.MouseButton1Click:Connect(function()
                            btn.Text = opt
                            if callback then callback(opt) end
                            close()
                        end)
                    end
                end)
                return {
                    Set = function(opt) btn.Text = opt; callback(opt) end,
                    Get = function() return btn.Text end
                }
            end
            
            -- Color Picker
            function sectionApi:AddColorPicker(text, defaultColor, callback)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(0.7, -10, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local colorBtn = createInstance("TextButton", {
                    Text = "",
                    Size = UDim2.new(0, 40, 0, 40),
                    Position = UDim2.new(1, -44, 0.5, -20),
                    BackgroundColor3 = defaultColor or getColor("Accent"),
                    AutoButtonColor = false,
                }, frame)
                applyCorner(colorBtn, 8)
                local picker = nil
                colorBtn.MouseButton1Click:Connect(function()
                    if picker then picker:Destroy() picker = nil return end
                    picker = createInstance("Frame", {
                        Size = UDim2.new(0, 280, 0, 280),
                        Position = UDim2.new(0.5, -140, 0.5, -140),
                        BackgroundColor3 = getColor("Card"),
                        BorderSizePixel = 0,
                        ZIndex = 600,
                    }, self._gui)
                    applyCorner(picker, 12)
                    applyStroke(picker, getColor("Border"), 1)
                    local sv = createInstance("Frame", {
                        Size = UDim2.new(0, 240, 0, 240),
                        Position = UDim2.new(0.5, -120, 0, 10),
                        BackgroundColor3 = Color3.fromRGB(255,0,0),
                    }, picker)
                    applyCorner(sv, 8)
                    local hueSlider = createInstance("Frame", {
                        Size = UDim2.new(0, 240, 0, 14),
                        Position = UDim2.new(0.5, -120, 0, 260),
                        BackgroundColor3 = Color3.fromHSV(0,1,1),
                    }, picker)
                    applyCorner(hueSlider, 7)
                    local selectBtn = createInstance("TextButton", {
                        Text = "Select",
                        Size = UDim2.new(0, 90, 0, 36),
                        Position = UDim2.new(0.5, -45, 1, -40),
                        BackgroundColor3 = getColor("Accent"),
                        TextColor3 = getColor("Text"),
                    }, picker)
                    applyCorner(selectBtn, 8)
                    selectBtn.MouseButton1Click:Connect(function()
                        local color = sv.BackgroundColor3
                        colorBtn.BackgroundColor3 = color
                        if callback then callback(color) end
                        picker:Destroy()
                        picker = nil
                    end)
                end)
                return {
                    Set = function(c) colorBtn.BackgroundColor3 = c; callback(c) end,
                    Get = function() return colorBtn.BackgroundColor3 end
                }
            end
            
            -- Keybind
            function sectionApi:AddKeybind(text, defaultKey, callback)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(0.7, -10, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local keyBtn = createInstance("TextButton", {
                    Text = defaultKey,
                    Size = UDim2.new(0, 130, 0, 38),
                    Position = UDim2.new(1, -140, 0.5, -19),
                    BackgroundColor3 = getColor("InputBg"),
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 13,
                }, frame)
                applyCorner(keyBtn, 8)
                local listening = false
                local function startListening()
                    listening = true
                    keyBtn.Text = "..."
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input, gp)
                        if gp then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            local key = input.KeyCode.Name
                            keyBtn.Text = key
                            SoraUI:RegisterKeybind(text, input.KeyCode, callback)
                            listening = false
                            conn:Disconnect()
                        end
                    end)
                    task.delay(5, function()
                        if listening then
                            listening = false
                            keyBtn.Text = defaultKey
                            conn:Disconnect()
                        end
                    end)
                end
                keyBtn.MouseButton1Click:Connect(startListening)
                SoraUI:RegisterKeybind(text, Enum.KeyCode[defaultKey], callback)
                return {
                    Set = function(k) keyBtn.Text = k; SoraUI:RegisterKeybind(text, Enum.KeyCode[k], callback) end,
                    Get = function() return keyBtn.Text end
                }
            end
            
            -- Progress Bar
            function sectionApi:AddProgressBar(text, initial, max, callback)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local progressBg = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 12),
                    Position = UDim2.new(0, 0, 0, 34),
                    BackgroundColor3 = getColor("ProgressBg"),
                    BorderSizePixel = 0,
                }, frame)
                applyCorner(progressBg, 6)
                local fill = createInstance("Frame", {
                    Size = UDim2.new(initial/max, 0, 1, 0),
                    BackgroundColor3 = getColor("ProgressFill"),
                    BorderSizePixel = 0,
                }, progressBg)
                applyCorner(fill, 6)
                local percentLabel = createInstance("TextLabel", {
                    Text = string.format("%.0f%%", initial/max*100),
                    Size = UDim2.new(0, 80, 0, 28),
                    Position = UDim2.new(1, -85, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("TextMuted"),
                    Font = getFont(),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, frame)
                local function setProgress(value)
                    local percent = value/max
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    percentLabel.Text = string.format("%.0f%%", percent*100)
                    if callback then callback(value) end
                end
                return {
                    Set = setProgress,
                    Get = function() return fill.Size.X.Scale * max end
                }
            end
            
            -- Separator
            function sectionApi:AddSeparator()
                local sep = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 2),
                    BackgroundColor3 = getColor("Separator"),
                    BorderSizePixel = 0,
                }, contentArea)
                return sep
            end
            
            -- Label
            function sectionApi:AddLabel(text, fontSize, muted)
                local lbl = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    TextColor3 = muted and getColor("TextMuted") or getColor("Text"),
                    Font = getFont(),
                    TextSize = fontSize or 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, contentArea)
                return lbl
            end
            
            -- Paragraph
            function sectionApi:AddParagraph(text)
                local para = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("TextMuted"),
                    Font = getFont(),
                    TextSize = 12,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, contentArea)
                return para
            end
            
            -- Image
            function sectionApi:AddImage(imageId, size)
                local img = createInstance("ImageLabel", {
                    Image = imageId,
                    Size = size or UDim2.new(1, 0, 0, 140),
                    BackgroundTransparency = 1,
                    ScaleType = Enum.ScaleType.Fit,
                }, contentArea)
                applyCorner(img, 10)
                return img
            end
            
            -- Checkbox
            function sectionApi:AddCheckbox(text, default, callback)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundTransparency = 1,
                }, contentArea)
                local check = createInstance("ImageButton", {
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(0, 0, 0.5, -12),
                    Image = default and "rbxassetid://3926307971" or "rbxassetid://3926305904",
                    BackgroundTransparency = 1,
                }, frame)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, -34, 1, 0),
                    Position = UDim2.new(0, 34, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local state = default
                local function set(st)
                    state = st
                    check.Image = state and "rbxassetid://3926307971" or "rbxassetid://3926305904"
                    if callback then callback(state) end
                end
                check.MouseButton1Click:Connect(function() set(not state) end)
                set(default)
                return { Set = set, Get = function() return state end }
            end
            
            -- Radio Group
            function sectionApi:AddRadioGroup(text, options, default, callback)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, contentArea)
                local title = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont("bold"),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local group = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, frame)
                local layout = Instance.new("UIListLayout")
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 8)
                layout.Parent = group
                local radios = {}
                local selected = default
                local function select(opt)
                    selected = opt
                    for _, r in pairs(radios) do
                        r.btn.Image = (r.option == opt) and "rbxassetid://3926307971" or "rbxassetid://3926305904"
                    end
                    if callback then callback(opt) end
                end
                for _, opt in ipairs(options) do
                    local row = createInstance("Frame", {
                        Size = UDim2.new(1, 0, 0, 36),
                        BackgroundTransparency = 1,
                    }, group)
                    local radioBtn = createInstance("ImageButton", {
                        Size = UDim2.new(0, 22, 0, 22),
                        Position = UDim2.new(0, 0, 0.5, -11),
                        Image = (opt == default) and "rbxassetid://3926307971" or "rbxassetid://3926305904",
                        BackgroundTransparency = 1,
                    }, row)
                    local optLabel = createInstance("TextLabel", {
                        Text = opt,
                        Size = UDim2.new(1, -32, 1, 0),
                        Position = UDim2.new(0, 32, 0, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = getColor("Text"),
                        Font = getFont(),
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }, row)
                    radioBtn.MouseButton1Click:Connect(function() select(opt) end)
                    table.insert(radios, {btn = radioBtn, option = opt})
                end
                return { Set = select, Get = function() return selected end }
            end
            
            -- Accordion
            function sectionApi:AddAccordion(title, contentCallback)
                local accordion = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = getColor("Card"),
                    BackgroundTransparency = 0.1,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, contentArea)
                applyCorner(accordion, 10)
                applyStroke(accordion, getColor("Border"), 0.5)
                local header = createInstance("TextButton", {
                    Text = title,
                    Size = UDim2.new(1, 0, 0, 46),
                    BackgroundColor3 = getColor("Card"),
                    TextColor3 = getColor("Text"),
                    Font = getFont("bold"),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                }, accordion)
                applyCorner(header, 10)
                local pad = Instance.new("UIPadding")
                pad.PaddingLeft = UDim.new(0, 18)
                pad.Parent = header
                local contentHolder = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Visible = false,
                }, accordion)
                local contentPad = Instance.new("UIPadding")
                contentPad.PaddingLeft = UDim.new(0, 18)
                contentPad.PaddingRight = UDim.new(0, 18)
                contentPad.PaddingTop = UDim.new(0, 12)
                contentPad.PaddingBottom = UDim.new(0, 12)
                contentPad.Parent = contentHolder
                local contentLayout = Instance.new("UIListLayout")
                contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
                contentLayout.Padding = UDim.new(0, 10)
                contentLayout.Parent = contentHolder
                contentCallback(contentHolder)
                local open = false
                header.MouseButton1Click:Connect(function()
                    open = not open
                    contentHolder.Visible = open
                    accordion.AutomaticSize = Enum.AutomaticSize.Y
                end)
                return accordion
            end
            
            -- ListBox
            function sectionApi:AddListBox(text, items, default, callback)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 160),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local listScroller = createInstance("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 0, 120),
                    Position = UDim2.new(0, 0, 0, 32),
                    BackgroundColor3 = getColor("InputBg"),
                    BorderSizePixel = 0,
                    ScrollBarThickness = config.ScrollBarThickness,
                }, frame)
                applyCorner(listScroller, 8)
                local listLayout = Instance.new("UIListLayout")
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Padding = UDim.new(0, 2)
                listLayout.Parent = listScroller
                local buttons = {}
                local selected = default
                local function selectItem(item)
                    selected = item
                    for _, btn in pairs(buttons) do
                        btn.BackgroundColor3 = (btn.Text == item) and getColor("Accent") or getColor("CardHover")
                    end
                    if callback then callback(item) end
                end
                for _, item in ipairs(items) do
                    local btn = createInstance("TextButton", {
                        Text = item,
                        Size = UDim2.new(1, 0, 0, 32),
                        BackgroundColor3 = (item == default) and getColor("Accent") or getColor("CardHover"),
                        TextColor3 = getColor("Text"),
                        Font = getFont(),
                        TextSize = 13,
                        AutoButtonColor = false,
                    }, listScroller)
                    applyCorner(btn, 6)
                    btn.MouseButton1Click:Connect(function() selectItem(item) end)
                    table.insert(buttons, btn)
                end
                return {
                    Set = selectItem,
                    Get = function() return selected end,
                    AddItem = function(newItem)
                        table.insert(items, newItem)
                        local btn = createInstance("TextButton", {
                            Text = newItem,
                            Size = UDim2.new(1, 0, 0, 32),
                            BackgroundColor3 = getColor("CardHover"),
                            TextColor3 = getColor("Text"),
                            Font = getFont(),
                            TextSize = 13,
                            AutoButtonColor = false,
                        }, listScroller)
                        applyCorner(btn, 6)
                        btn.MouseButton1Click:Connect(function() selectItem(newItem) end)
                        table.insert(buttons, btn)
                    end,
                    RemoveItem = function(item)
                        for i, btn in pairs(buttons) do
                            if btn.Text == item then
                                btn:Destroy()
                                table.remove(buttons, i)
                                table.remove(items, i)
                                break
                            end
                        end
                    end
                }
            end
            
            -- TreeView
            function sectionApi:AddTreeView(text, treeData, callback)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 200),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local scroller = createInstance("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 0, 160),
                    Position = UDim2.new(0, 0, 0, 32),
                    BackgroundColor3 = getColor("InputBg"),
                    BorderSizePixel = 0,
                    ScrollBarThickness = config.ScrollBarThickness,
                }, frame)
                applyCorner(scroller, 8)
                local layout = Instance.new("UIListLayout")
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 2)
                layout.Parent = scroller
                local function buildTree(parentContainer, data, indent)
                    for name, children in pairs(data) do
                        local nodeBtn = createInstance("TextButton", {
                            Text = string.rep("  ", indent) .. name,
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundColor3 = getColor("CardHover"),
                            TextColor3 = getColor("Text"),
                            Font = getFont(),
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                        }, parentContainer)
                        applyCorner(nodeBtn, 6)
                        nodeBtn.MouseButton1Click:Connect(function()
                            if callback then callback(name) end
                        end)
                        if type(children) == "table" then
                            local childContainer = createInstance("Frame", {
                                Size = UDim2.new(1, 0, 0, 0),
                                BackgroundTransparency = 1,
                                AutomaticSize = Enum.AutomaticSize.Y,
                                Visible = false,
                            }, parentContainer)
                            buildTree(childContainer, children, indent + 1)
                            nodeBtn.MouseButton2Click:Connect(function()
                                childContainer.Visible = not childContainer.Visible
                            end)
                        end
                    end
                end
                buildTree(scroller, treeData, 0)
                return scroller
            end
            
            -- Canvas (free drawing)
            function sectionApi:AddCanvas(text, width, height, drawCallback)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, height + 50),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local canvas = createInstance("Frame", {
                    Size = UDim2.new(1, -20, 0, height),
                    Position = UDim2.new(0, 10, 0, 32),
                    BackgroundColor3 = getColor("InputBg"),
                    BorderSizePixel = 0,
                }, frame)
                applyCorner(canvas, 8)
                if drawCallback then drawCallback(canvas) end
                return canvas
            end
            
            -- Line Chart
            function sectionApi:AddLineChart(text, dataPoints, width, height)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, height + 50),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local chartArea = createInstance("Frame", {
                    Size = UDim2.new(1, -20, 0, height),
                    Position = UDim2.new(0, 10, 0, 32),
                    BackgroundColor3 = getColor("InputBg"),
                    BorderSizePixel = 0,
                }, frame)
                applyCorner(chartArea, 8)
                if #dataPoints > 1 then
                    local maxVal = math.max(unpack(dataPoints))
                    local minVal = math.min(unpack(dataPoints))
                    local range = maxVal - minVal
                    if range == 0 then range = 1 end
                    local stepX = chartArea.AbsoluteSize.X / (#dataPoints - 1)
                    for i = 1, #dataPoints - 1 do
                        local y1 = (1 - (dataPoints[i] - minVal) / range) * chartArea.AbsoluteSize.Y
                        local y2 = (1 - (dataPoints[i+1] - minVal) / range) * chartArea.AbsoluteSize.Y
                        local line = createInstance("Frame", {
                            Size = UDim2.new(0, stepX, 0, 2),
                            Position = UDim2.new(0, (i-1)*stepX, 0, y1),
                            BackgroundColor3 = getColor("Accent"),
                            BorderSizePixel = 0,
                            Rotation = math.deg(math.atan2(y2 - y1, stepX)),
                        }, chartArea)
                    end
                end
                return chartArea
            end
            
            -- Console (text output)
            function sectionApi:AddConsole(text, lines)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 200),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local consoleBg = createInstance("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 0, 160),
                    Position = UDim2.new(0, 0, 0, 32),
                    BackgroundColor3 = getColor("InputBg"),
                    BorderSizePixel = 0,
                    ScrollBarThickness = config.ScrollBarThickness,
                }, frame)
                applyCorner(consoleBg, 8)
                local textLabel = createInstance("TextLabel", {
                    Text = "",
                    Size = UDim2.new(1, -10, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = getFont(),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, consoleBg)
                local function addLine(line)
                    textLabel.Text = textLabel.Text .. line .. "\n"
                    consoleBg.CanvasSize = UDim2.new(0, 0, 0, textLabel.AbsoluteSize.Y)
                    consoleBg.ScrollBarThickness = config.ScrollBarThickness
                end
                for _, line in ipairs(lines or {}) do
                    addLine(line)
                end
                return {
                    AddLine = addLine,
                    Clear = function() textLabel.Text = "" end
                }
            end
            
            -- Tooltip helper
            function sectionApi:AddTooltip(element, text)
                setupTooltip(element, text)
            end
            
            return sectionApi
        end
    }
    return tabApi
end

function Window:SelectTab(name)
    if self._currentTab then
        self._currentTab.Button.BackgroundColor3 = getColor("TopBar")
        self._currentTab.Content.Visible = false
    end
    self._currentTab = self._tabs[name]
    if self._currentTab then
        self._currentTab.Button.BackgroundColor3 = getColor("Accent")
        self._currentTab.Content.Visible = true
    end
end

function Window:Minimize()
    self._frame.Visible = not self._frame.Visible
end

function Window:Close()
    self._gui:Destroy()
    SoraUI._windows[self] = nil
end

function Window:Show()
    self._frame.Visible = true
end

function Window:Hide()
    self._frame.Visible = false
end

function Window:Toggle()
    self._frame.Visible = not self._frame.Visible
end

function Window:SetTitle(newTitle)
    self._titleLabel.Text = newTitle
end

function Window:GetFrame()
    return self._frame
end

-- ============================================================================
--  PUBLIC API
-- ============================================================================
SoraUI._windows = {}

function SoraUI:CreateWindow(title, size, options)
    if config.KeySystemEnabled and not KeySystem:IsActivated() then
        local activationWin = KeySystem:ShowActivationWindow()
        activationWin:Show()
        return nil
    end
    return Window.new(title, size, options)
end

function SoraUI:DestroyAllWindows()
    for win, _ in pairs(self._windows) do
        win:Close()
    end
    self._windows = {}
end

function SoraUI:GetConfig()
    return config
end

function SoraUI:SetConfig(newConfig)
    for k, v in pairs(newConfig) do
        config[k] = v
    end
    if newConfig.Theme then
        self:SetTheme(newConfig.Theme.Name, newConfig.Theme)
    end
end

-- Initialize
loadSettings()
loadLicenseData()
SoraUI:SetTheme("Dark")

return SoraUI
