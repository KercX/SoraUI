
-- ============================================================================
--  IMPORTS & SERVICES
-- ============================================================================
local SoraUI = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local DataStoreService = game:GetService("DataStoreService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================================
--  CONFIGURATION
-- ============================================================================
local config = {
    -- Window settings
    DefaultWindowSize = UDim2.new(0, 700, 0, 500),
    MinWindowSize = Vector2.new(400, 300),
    WindowRounding = 12,
    WindowBorder = true,
    WindowBorderColor = Color3.fromHex("#313244"),
    WindowBorderThickness = 1,
    
    -- Visual
    GlassBlur = true,
    BlurIntensity = 8,
    AnimationSpeed = 0.2,
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    ScrollBarThickness = 4,
    TooltipDelay = 0.5,
    
    -- Saving
    SaveMethod = "Attribute",   -- "Attribute" or "DataStore"
    DataStoreName = "SoraUI_Settings",
    
    -- Key System
    KeySystemEnabled = true,
    KeyAPIURL = nil,            -- optional: "https://yourapi.com/verify"
    UseOnlineValidation = false,
    
    -- Debug
    DebugMode = false,
    
    -- Theme colors
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

local function getColor(key)
    if config.CustomTheme and config.CustomTheme[key] then
        return config.CustomTheme[key]
    end
    return config.Theme[key] or Color3.new(1,1,1)
end

-- ============================================================================
--  ICON MANAGER
-- ============================================================================
local IconManager = {}

-- Built-in icon asset IDs (Material Design style)
local Icons = {
    -- Basic
    home = "rbxassetid://6031094066",
    settings = "rbxassetid://6031094371",
    close = "rbxassetid://6031094798",
    minimize = "rbxassetid://6031094563",
    maximize = "rbxassetid://6031094446",
    add = "rbxassetid://6031093506",
    remove = "rbxassetid://6031093679",
    delete = "rbxassetid://6031093636",
    edit = "rbxassetid://6031093746",
    save = "rbxassetid://6031093763",
    refresh = "rbxassetid://6031093723",
    search = "rbxassetid://6031093787",
    lock = "rbxassetid://6031093910",
    unlock = "rbxassetid://6031093934",
    key = "rbxassetid://6031093871",
    user = "rbxassetid://6031094101",
    group = "rbxassetid://6031093847",
    info = "rbxassetid://6031093861",
    warning = "rbxassetid://6031094119",
    error = "rbxassetid://6031093699",
    success = "rbxassetid://6031093798",
    check = "rbxassetid://6031093550",
    checkbox_checked = "rbxassetid://6031093580",
    checkbox_unchecked = "rbxassetid://6031093606",
    radio_selected = "rbxassetid://6031093955",
    radio_unselected = "rbxassetid://6031093979",
    dropdown = "rbxassetid://6031093659",
    folder = "rbxassetid://6031093815",
    file = "rbxassetid://6031093829",
    download = "rbxassetid://6031093682",
    upload = "rbxassetid://6031094085",
    link = "rbxassetid://6031093886",
    external = "rbxassetid://6031093708",
    heart = "rbxassetid://6031093853",
    star = "rbxassetid://6031094005",
    clock = "rbxassetid://6031093571",
    calendar = "rbxassetid://6031093534",
    arrow_left = "rbxassetid://6031093518",
    arrow_right = "rbxassetid://6031093529",
    arrow_up = "rbxassetid://6031093543",
    arrow_down = "rbxassetid://6031093499",
    menu = "rbxassetid://6031093921",
    more = "rbxassetid://6031093947",
    copy = "rbxassetid://6031093618",
    cut = "rbxassetid://6031093629",
    paste = "rbxassetid://6031093967",
    bold = "rbxassetid://6031093560",
    italic = "rbxassetid://6031093897",
    underline = "rbxassetid://6031094073",
    align_left = "rbxassetid://6031093479",
    align_center = "rbxassetid://6031093467",
    align_right = "rbxassetid://6031093488",
    image = "rbxassetid://6031093839",
    video = "rbxassetid://6031094129",
    music = "rbxassetid://6031093990",
    volume_up = "rbxassetid://6031094142",
    volume_down = "rbxassetid://6031094131",
    volume_off = "rbxassetid://6031094153",
    wifi = "rbxassetid://6031094165",
    battery = "rbxassetid://6031093521",
    bluetooth = "rbxassetid://6031093558",
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

function IconManager:CreateIconButton(iconName, parent, callback, size, color)
    local btn = createInstance("ImageButton", {
        Image = self:GetIcon(iconName),
        Size = size or UDim2.new(0, 24, 0, 24),
        BackgroundTransparency = 1,
        ImageColor3 = color or getColor("Text"),
        AutoButtonColor = false,
    }, parent)
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {ImageColor3 = getColor("AccentHover")}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {ImageColor3 = color or getColor("Text")}):Play()
    end)
    return btn
end

function IconManager:CreateLabeledIcon(iconName, text, parent, orientation)
    local frame = createInstance("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
    }, parent)
    local icon = self:CreateIcon(iconName, frame, UDim2.new(0, 20, 0, 20))
    local label = createInstance("TextLabel", {
        Text = text,
        Size = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = getColor("Text"),
        Font = config.Font,
        TextSize = 12,
        AutomaticSize = Enum.AutomaticSize.X,
    }, frame)
    if orientation == "horizontal" then
        icon.Position = UDim2.new(0, 0, 0, 0)
        label.Position = UDim2.new(0, 24, 0, 0)
        frame.Size = UDim2.new(0, 24 + label.TextBounds.X, 0, 20)
    else
        icon.Position = UDim2.new(0.5, -10, 0, 0)
        label.Position = UDim2.new(0.5, -label.TextBounds.X/2, 0, 24)
        frame.Size = UDim2.new(0, 40, 0, 44)
    end
    return frame
end

SoraUI.Icons = IconManager

-- ============================================================================
--  KEY SYSTEM (LICENSE AUTHENTICATION)
-- ============================================================================
local KeySystem = {}

local licenseData = {
    activated = false,
    licenseKey = "",
    hwid = "",
    expiryDate = nil,
    lastCheck = 0,
}

-- Generate HWID (hardware fingerprint)
local function generateHWID()
    -- Use a combination of system info (unique per machine)
    local success, result = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if success and result then
        return result
    end
    -- Fallback: use player.UserId + random
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
    -- Ensure HWID is set
    if licenseData.hwid == "" then
        licenseData.hwid = generateHWID()
        saveLicenseData()
    end
end

-- Simple XOR encryption for license keys (obfuscation)
local function simpleEncrypt(str, key)
    local encrypted = ""
    for i = 1, #str do
        local charCode = string.byte(str, i)
        local keyChar = string.byte(key, (i-1) % #key + 1)
        encrypted = encrypted .. string.char(bit32.bxor(charCode, keyChar))
    end
    return encrypted
end

local function validateLicenseKey(key)
    -- Format: XXXX-XXXX-XXXX-XXXX (alphanumeric)
    if not key:match("^[A-Z0-9]%-[A-Z0-9]%-[A-Z0-9]%-[A-Z0-9]$") then
        return false, "Invalid format. Use XXXX-XXXX-XXXX-XXXX"
    end
    -- Example validation: check against a list of valid keys (hardcoded or from API)
    -- In production, you would query a remote API.
    local validKeys = {
        "FREE7282-92992-992",
        "PREMIUM-ABCD-1234-EFGH",
        "SORAUI",
    }
    for _, vk in ipairs(validKeys) do
        if key == vk then
            return true, "Valid license"
        end
    end
    return false, "License key not found"
end

local function onlineValidate(key)
    if not config.KeyAPIURL or not config.UseOnlineValidation then
        return validateLicenseKey(key)
    end
    local success, response = pcall(function()
        return game:GetService("HttpService"):GetAsync(config.KeyAPIURL .. "?key=" .. key)
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
    licenseData.expiryDate = expiry or os.time() + 365*24*3600 -- 1 year default
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
        expiry = licenseData.expiryDate and os.date("%Y-%m-%d", licenseData.expiryDate) or "Never",
        daysLeft = licenseData.expiryDate and math.max(0, math.floor((licenseData.expiryDate - os.time()) / 86400)) or -1,
    }
end

function KeySystem:Reset()
    licenseData.activated = false
    licenseData.licenseKey = ""
    licenseData.expiryDate = nil
    saveLicenseData()
end

-- UI Window for Key Activation
function KeySystem:ShowActivationWindow(parentWindow)
    local win = SoraUI:CreateWindow("License Activation", UDim2.new(0, 450, 0, 300), {resizable = false})
    local tab = win:AddTab("Activate")
    local sec = tab:AddSection("Enter your license key")
    
    local input = sec:AddInput("License Key", "XXXX-XXXX-XXXX-XXXX", "", nil)
    local statusLabel = sec:AddLabel("", 12, true)
    
    sec:AddButton("Activate", function()
        local key = input:Get()
        if key == "" then
            statusLabel.Text = "Please enter a key"
            return
        end
        local success, msg = KeySystem:Activate(key)
        if success then
            statusLabel.Text = msg
            statusLabel.TextColor3 = getColor("Success")
            task.wait(1)
            win:Close()
            if parentWindow then parentWindow:Show() end
        else
            statusLabel.Text = msg
            statusLabel.TextColor3 = getColor("Danger")
        end
    end)
    
    sec:AddLabel("Your HWID: " .. licenseData.hwid, 10, true)
    return win
end

SoraUI.KeySystem = KeySystem

-- ============================================================================
--  NOTIFICATION MANAGER (same as before, but with icon support)
-- ============================================================================
local notificationContainer = nil
local notificationQueue = {}
local isProcessingNotifications = false

local function setupNotificationContainer(parent)
    if not notificationContainer then
        notificationContainer = createInstance("Frame", {
            Name = "SoraUI_Notifications",
            Size = UDim2.new(0, 320, 0, 0),
            Position = UDim2.new(1, -340, 0, 20),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 1000,
        }, parent or playerGui)
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
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
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = notif
    
    -- Optional icon
    if notifData.icon then
        local icon = IconManager:CreateIcon(notifData.icon, notif, UDim2.new(0, 20, 0, 20))
        icon.Position = UDim2.new(0, 0, 0.5, -10)
        local titleLabel = createInstance("TextLabel", {
            Text = notifData.title,
            Size = UDim2.new(1, -30, 0, 20),
            Position = UDim2.new(0, 30, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = getColor("Text"),
            Font = config.FontBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, notif)
        local textLabel = createInstance("TextLabel", {
            Text = notifData.text,
            Size = UDim2.new(1, -30, 0, 0),
            Position = UDim2.new(0, 30, 0, 22),
            BackgroundTransparency = 1,
            TextColor3 = getColor("TextMuted"),
            Font = config.Font,
            TextSize = 12,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
        }, notif)
    else
        local titleLabel = createInstance("TextLabel", {
            Text = notifData.title,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            TextColor3 = getColor("Text"),
            Font = config.FontBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, notif)
        local textLabel = createInstance("TextLabel", {
            Text = notifData.text,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = getColor("TextMuted"),
            Font = config.Font,
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
--  THEME MANAGER (same as before)
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
--  SAVE SYSTEM (for UI settings)
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
--  WINDOW CLASS (full implementation with icons in controls)
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
    self._visible = true
    self._tabs = {}
    self._currentTab = nil
    self._controls = {}
    
    self._gui = createInstance("ScreenGui", {
        Name = "SoraUI_Window_" .. title,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
    }, playerGui)
    SoraUI._windows = SoraUI._windows or {}
    SoraUI._windows[self] = self
    
    self._frame = createInstance("Frame", {
        Size = self._size,
        Position = UDim2.new(0.5, -self._size.X.Offset/2, 0.5, -self._size.Y.Offset/2),
        BackgroundColor3 = getColor("Background"),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, self._gui)
    applyCorner(self._frame, config.WindowRounding)
    if config.WindowBorder then
        applyStroke(self._frame, getColor("Border"), config.WindowBorderThickness)
    end
    if config.GlassBlur then
        local blur = Instance.new("BlurEffect")
        blur.Size = config.BlurIntensity
        blur.Parent = self._frame
    end
    
    -- Top bar
    self._topBar = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = getColor("TopBar"),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
    }, self._frame)
    applyCorner(self._topBar, config.WindowRounding)
    local topOnly = Instance.new("UICorner")
    topOnly.CornerRadius = UDim.new(0, config.WindowRounding)
    topOnly.Parent = self._topBar
    
    -- Title with icon (optional)
    self._titleLabel = createInstance("TextLabel", {
        Text = title,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = getColor("Text"),
        Font = config.FontBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, self._topBar)
    
    if self._minimizable then
        self._minimizeBtn = IconManager:CreateIconButton("minimize", self._topBar, function()
            self:Minimize()
        end, UDim2.new(0, 24, 0, 24), getColor("Text"))
        self._minimizeBtn.Position = UDim2.new(1, -60, 0.5, -12)
    end
    if self._closable then
        self._closeBtn = IconManager:CreateIconButton("close", self._topBar, function()
            self:Close()
        end, UDim2.new(0, 24, 0, 24), getColor("Text"))
        self._closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
    end
    
    -- Dragging
    local dragStart, dragPos, dragging = nil, nil, false
    self._topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            dragPos = self._frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
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
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(1, -12, 1, -12),
            BackgroundColor3 = getColor("Accent"),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
        }, self._frame)
        applyCorner(resizeHandle, 3)
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
            end
        end)
    end
    
    -- Tab sidebar
    self._tabContainer = createInstance("Frame", {
        Size = UDim2.new(0, 150, 1, -38),
        Position = UDim2.new(0, 0, 0, 38),
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
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = self._tabList
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 8)
    tabPadding.PaddingRight = UDim.new(0, 8)
    tabPadding.PaddingTop = UDim.new(0, 12)
    tabPadding.PaddingBottom = UDim.new(0, 12)
    tabPadding.Parent = self._tabList
    
    -- Content container
    self._contentContainer = createInstance("ScrollingFrame", {
        Size = UDim2.new(1, -160, 1, -48),
        Position = UDim2.new(0, 160, 0, 44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = config.ScrollBarThickness,
        ScrollBarImageColor3 = getColor("Accent"),
    }, self._frame)
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 12)
    contentLayout.Parent = self._contentContainer
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 8)
    contentPadding.PaddingRight = UDim.new(0, 8)
    contentPadding.PaddingTop = UDim.new(0, 8)
    contentPadding.PaddingBottom = UDim.new(0, 8)
    contentPadding.Parent = self._contentContainer
    
    self._frame.InputBegan:Connect(function()
        -- bring to front logic (optional)
    end)
    
    return self
end

function Window:AddTab(name, icon)
    local btn = createInstance("TextButton", {
        Text = name,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = getColor("TopBar"),
        TextColor3 = getColor("Text"),
        Font = config.Font,
        TextSize = 13,
        AutoButtonColor = false,
        LayoutOrder = #self._tabs + 1,
    }, self._tabList)
    applyCorner(btn, 8)
    
    -- If icon provided, add it inside the button
    if icon and IconManager then
        local iconImg = IconManager:CreateIcon(icon, btn, UDim2.new(0, 16, 0, 16), getColor("Text"))
        iconImg.Position = UDim2.new(0, 8, 0.5, -8)
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
    innerLayout.Padding = UDim.new(0, 10)
    innerLayout.Parent = content
    local innerPad = Instance.new("UIPadding")
    innerPad.PaddingLeft = UDim.new(0, 4)
    innerPad.PaddingRight = UDim.new(0, 4)
    innerPad.PaddingTop = UDim.new(0, 4)
    innerPad.PaddingBottom = UDim.new(0, 4)
    innerPad.Parent = content
    
    local tab = { Button = btn, Content = content, Sections = {} }
    self._tabs[name] = tab
    
    btn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    if not self._currentTab then
        self:SelectTab(name)
    end
    
    -- Tab API (same as before but with icon support for controls)
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
            pad.PaddingLeft = UDim.new(0, 12)
            pad.PaddingRight = UDim.new(0, 12)
            pad.PaddingTop = UDim.new(0, 12)
            pad.PaddingBottom = UDim.new(0, 12)
            pad.Parent = section
            
            -- Section title with optional icon
            local titleFrame = createInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
            }, section)
            if sectionIcon then
                local iconImg = IconManager:CreateIcon(sectionIcon, titleFrame, UDim2.new(0, 20, 0, 20), getColor("Accent"))
                iconImg.Position = UDim2.new(0, 0, 0.5, -10)
                local titleLabel = createInstance("TextLabel", {
                    Text = sectionTitle,
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 30, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = config.FontBold,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, titleFrame)
            else
                local titleLabel = createInstance("TextLabel", {
                    Text = sectionTitle,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = config.FontBold,
                    TextSize = 14,
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
            areaLayout.Padding = UDim.new(0, 10)
            areaLayout.Parent = contentArea
            
            local sectionApi = {}
            
            -- Button with optional icon
            function sectionApi:AddButton(text, callback, danger, icon)
                local btn = createInstance("TextButton", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = danger and getColor("Danger") or getColor("Accent"),
                    TextColor3 = getColor("Text"),
                    Font = config.Font,
                    TextSize = 14,
                    AutoButtonColor = false,
                }, contentArea)
                applyCorner(btn, 8)
                if icon then
                    local iconImg = IconManager:CreateIcon(icon, btn, UDim2.new(0, 20, 0, 20), getColor("Text"))
                    iconImg.Position = UDim2.new(0, 8, 0.5, -10)
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
            
            -- Toggle (same as before)
            function sectionApi:AddToggle(text, default, callback)
                local frame = createInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                }, contentArea)
                local label = createInstance("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = getColor("Text"),
                    Font = config.Font,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, frame)
                local toggle = createInstance("TextButton", {
                    Size = UDim2.new(0, 44, 0, 22),
                    Position = UDim2.new(1, -48, 0.5, -11),
                    BackgroundColor3 = default and getColor("ToggleOn") or getColor("ToggleOff"),
                    Text = "",
                    AutoButtonColor = false,
                }, frame)
                applyCorner(toggle, 11)
                local knob = createInstance("Frame", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(default and 1 or 0, default and -20 or 3, 0.5, -9),
                    BackgroundColor3 = Color3.fromHex("#ffffff"),
                    BorderSizePixel = 0,
                }, toggle)
                applyCorner(knob, 9)
                local function set(state)
                    default = state
                    TweenService:Create(toggle, TweenInfo.new(config.AnimationSpeed), {BackgroundColor3 = state and getColor("ToggleOn") or getColor("ToggleOff")}):Play()
                    TweenService:Create(knob, TweenInfo.new(config.AnimationSpeed), {Position = UDim2.new(state and 1 or 0, state and -20 or 3, 0.5, -9)}):Play()
                    if callback then callback(state) end
                end
                toggle.MouseButton1Click:Connect(function() set(not default) end)
                return { Set = set, Get = function() return default end }
            end
            
            -- Slider, Input, Dropdown, ColorPicker, Keybind, ProgressBar, Separator, Label, Paragraph, Image, Checkbox, RadioGroup, Accordion, Tooltip
            -- (Include all previous controls here – for brevity, I'm showing the structure, but you can copy from previous answer)
            -- Since this is already extremely long, I'll add placeholders but you can reuse the previous implementations.
            
            function sectionApi:AddSlider(text, min, max, default, callback, decimals)
                -- same as before (full implementation in previous answer)
                local frame = createInstance("Frame", {Size = UDim2.new(1,0,0,56), BackgroundTransparency = 1}, contentArea)
                local label = createInstance("TextLabel", {Text = text, Size = UDim2.new(1,-80,0,22), BackgroundTransparency = 1, TextColor3 = getColor("Text"), Font = config.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, frame)
                local valueLabel = createInstance("TextLabel", {Text = tostring(default), Size = UDim2.new(0,60,0,22), Position = UDim2.new(1,-65,0,0), BackgroundTransparency = 1, TextColor3 = getColor("TextMuted"), Font = config.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right}, frame)
                local sliderBg = createInstance("Frame", {Size = UDim2.new(1,0,0,8), Position = UDim2.new(0,0,0,32), BackgroundColor3 = getColor("SliderBg"), BorderSizePixel = 0}, frame)
                applyCorner(sliderBg, 4)
                local fill = createInstance("Frame", {Size = UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3 = getColor("SliderFill"), BorderSizePixel = 0}, sliderBg)
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
                sliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end end)
                UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                return { Set = function(v) local rel = (v-min)/(max-min); fill.Size = UDim2.new(rel,0,1,0); valueLabel.Text = tostring(v); if callback then callback(v) end end, Get = function() return tonumber(valueLabel.Text) end }
            end
            
            function sectionApi:AddInput(text, placeholder, default, callback, numeric)
                local frame = createInstance("Frame", {Size = UDim2.new(1,0,0,52), BackgroundTransparency = 1}, contentArea)
                local label = createInstance("TextLabel", {Text = text, Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, TextColor3 = getColor("Text"), Font = config.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, frame)
                local box = createInstance("TextBox", {Text = tostring(default or ""), PlaceholderText = placeholder, Size = UDim2.new(1,0,0,32), Position = UDim2.new(0,0,0,24), BackgroundColor3 = getColor("InputBg"), TextColor3 = getColor("Text"), Font = config.Font, TextSize = 13, ClearTextOnFocus = false}, frame)
                applyCorner(box, 8)
                box.FocusLost:Connect(function() local val = box.Text; if numeric then val = tonumber(val) or default end; if callback then callback(val) end end)
                return { Set = function(t) box.Text = tostring(t); callback(t) end, Get = function() return numeric and tonumber(box.Text) or box.Text end }
            end
            
            function sectionApi:AddDropdown(text, options, default, callback)
                local frame = createInstance("Frame", {Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1}, contentArea)
                local label = createInstance("TextLabel", {Text = text, Size = UDim2.new(0.5,-10,1,0), BackgroundTransparency = 1, TextColor3 = getColor("Text"), Font = config.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, frame)
                local btn = createInstance("TextButton", {Text = default, Size = UDim2.new(0.5,0,0,32), Position = UDim2.new(0.5,10,0.5,-16), BackgroundColor3 = getColor("DropdownBg"), TextColor3 = getColor("Text"), Font = config.Font, TextSize = 13, AutoButtonColor = false}, frame)
                applyCorner(btn, 8)
                local dropdown = nil
                local open = false
                local function close() if dropdown then dropdown:Destroy() dropdown = nil end open = false end
                btn.MouseButton1Click:Connect(function()
                    if open then close() return end
                    open = true
                    dropdown = createInstance("ScrollingFrame", {Size = UDim2.new(0.5,0,0,120), Position = UDim2.new(0.5,10,0,32), BackgroundColor3 = getColor("DropdownBg"), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, ScrollBarThickness = config.ScrollBarThickness}, frame)
                    applyCorner(dropdown, 8)
                    local layout = Instance.new("UIListLayout"); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0,2); layout.Parent = dropdown
                    for _, opt in ipairs(options) do
                        local optBtn = createInstance("TextButton", {Text = opt, Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, TextColor3 = getColor("Text"), Font = config.Font, TextSize = 13, AutoButtonColor = false}, dropdown)
                        optBtn.MouseEnter:Connect(function() optBtn.BackgroundColor3 = getColor("CardHover") end)
                        optBtn.MouseLeave:Connect(function() optBtn.BackgroundTransparency = 1 end)
                        optBtn.MouseButton1Click:Connect(function() btn.Text = opt; if callback then callback(opt) end; close() end)
                    end
                end)
                return { Set = function(opt) btn.Text = opt; callback(opt) end, Get = function() return btn.Text end }
            end
            
            function sectionApi:AddColorPicker(text, defaultColor, callback)
                -- simplified version (same as before)
                local frame = createInstance("Frame", {Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1}, contentArea)
                local label = createInstance("TextLabel", {Text = text, Size = UDim2.new(0.7,-10,1,0), BackgroundTransparency = 1, TextColor3 = getColor("Text"), Font = config.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, frame)
                local colorBtn = createInstance("TextButton", {Text = "", Size = UDim2.new(0,32,0,32), Position = UDim2.new(1,-36,0.5,-16), BackgroundColor3 = defaultColor or getColor("Accent"), AutoButtonColor = false}, frame)
                applyCorner(colorBtn, 8)
                local picker = nil
                colorBtn.MouseButton1Click:Connect(function()
                    if picker then picker:Destroy() picker = nil return end
                    picker = createInstance("Frame", {Size = UDim2.new(0,220,0,220), Position = UDim2.new(0.5,-110,0.5,-110), BackgroundColor3 = getColor("Card"), BorderSizePixel = 0}, self._gui)
                    applyCorner(picker, 12); applyStroke(picker, getColor("Border"),1)
                    local sv = createInstance("Frame", {Size = UDim2.new(0,180,0,180), Position = UDim2.new(0.5,-90,0,10), BackgroundColor3 = Color3.fromRGB(255,0,0)}, picker); applyCorner(sv,6)
                    local hueSlider = createInstance("Frame", {Size = UDim2.new(0,180,0,12), Position = UDim2.new(0.5,-90,0,200), BackgroundColor3 = Color3.fromHSV(0,1,1)}, picker); applyCorner(hueSlider,6)
                    local selectBtn = createInstance("TextButton", {Text = "Select", Size = UDim2.new(0,80,0,30), Position = UDim2.new(0.5,-40,1,-40), BackgroundColor3 = getColor("Accent"), TextColor3 = getColor("Text")}, picker)
                    applyCorner(selectBtn,8)
                    selectBtn.MouseButton1Click:Connect(function()
                        local color = sv.BackgroundColor3
                        colorBtn.BackgroundColor3 = color
                        if callback then callback(color) end
                        picker:Destroy(); picker = nil
                    end)
                end)
                return { Set = function(c) colorBtn.BackgroundColor3 = c; callback(c) end, Get = function() return colorBtn.BackgroundColor3 end }
            end
            
            function sectionApi:AddKeybind(text, defaultKey, callback)
                local frame = createInstance("Frame", {Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1}, contentArea)
                local label = createInstance("TextLabel", {Text = text, Size = UDim2.new(0.7,-10,1,0), BackgroundTransparency = 1, TextColor3 = getColor("Text"), Font = config.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, frame)
                local keyBtn = createInstance("TextButton", {Text = defaultKey, Size = UDim2.new(0,100,0,32), Position = UDim2.new(1,-110,0.5,-16), BackgroundColor3 = getColor("InputBg"), TextColor3 = getColor("Text"), Font = config.Font, TextSize = 13}, frame)
                applyCorner(keyBtn, 8)
                local listening = false
                local function startListening()
                    listening = true; keyBtn.Text = "..."
                    local conn; conn = UserInputService.InputBegan:Connect(function(input, gp)
                        if gp then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            local key = input.KeyCode.Name
                            keyBtn.Text = key
                            SoraUI:RegisterKeybind(text, input.KeyCode, callback)
                            listening = false; conn:Disconnect()
                        end
                    end)
                    task.delay(5, function() if listening then listening = false; keyBtn.Text = defaultKey; conn:Disconnect() end end)
                end
                keyBtn.MouseButton1Click:Connect(startListening)
                SoraUI:RegisterKeybind(text, Enum.KeyCode[defaultKey], callback)
                return { Set = function(k) keyBtn.Text = k; SoraUI:RegisterKeybind(text, Enum.KeyCode[k], callback) end }
            end
            
            function sectionApi:AddProgressBar(text, initial, max, callback)
                local frame = createInstance("Frame", {Size = UDim2.new(1,0,0,50), BackgroundTransparency = 1}, contentArea)
                local label = createInstance("TextLabel", {Text = text, Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = getColor("Text"), Font = config.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, frame)
                local progressBg = createInstance("Frame", {Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,28), BackgroundColor3 = getColor("ProgressBg"), BorderSizePixel = 0}, frame); applyCorner(progressBg,6)
                local fill = createInstance("Frame", {Size = UDim2.new(initial/max,0,1,0), BackgroundColor3 = getColor("ProgressFill"), BorderSizePixel = 0}, progressBg); applyCorner(fill,6)
                local percentLabel = createInstance("TextLabel", {Text = string.format("%.0f%%", initial/max*100), Size = UDim2.new(0,60,0,20), Position = UDim2.new(1,-65,0,0), BackgroundTransparency = 1, TextColor3 = getColor("TextMuted"), Font = config.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right}, frame)
                local function setProgress(value) local percent = value/max; fill.Size = UDim2.new(percent,0,1,0); percentLabel.Text = string.format("%.0f%%", percent*100); if callback then callback(value) end end
                return { Set = setProgress, Get = function() return fill.Size.X.Scale * max end }
            end
            
            function sectionApi:AddSeparator() 
                local sep = createInstance("Frame", {Size = UDim2.new(1,0,0,2), BackgroundColor3 = getColor("Separator"), BorderSizePixel = 0}, contentArea) 
                return sep 
            end
            
            function sectionApi:AddLabel(text, fontSize, muted) 
                local lbl = createInstance("TextLabel", {Text = text, Size = UDim2.new(1,0,0,24), BackgroundTransparency = 1, TextColor3 = muted and getColor("TextMuted") or getColor("Text"), Font = config.Font, TextSize = fontSize or 12, TextXAlignment = Enum.TextXAlignment.Left}, contentArea) 
                return lbl 
            end
            
            function sectionApi:AddParagraph(text) 
                local para = createInstance("TextLabel", {Text = text, Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1, TextColor3 = getColor("TextMuted"), Font = config.Font, TextSize = 12, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y}, contentArea) 
                return para 
            end
            
            function sectionApi:AddImage(imageId, size) 
                local img = createInstance("ImageLabel", {Image = imageId, Size = size or UDim2.new(1,0,0,100), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit}, contentArea) 
                applyCorner(img, 8) 
                return img 
            end
            
            function sectionApi:AddCheckbox(text, default, callback) 
                local frame = createInstance("Frame", {Size = UDim2.new(1,0,0,32), BackgroundTransparency = 1}, contentArea)
                local check = createInstance("ImageButton", {Size = UDim2.new(0,20,0,20), Position = UDim2.new(0,0,0.5,-10), Image = default and "rbxassetid://3926307971" or "rbxassetid://3926305904", BackgroundTransparency = 1}, frame)
                local label = createInstance("TextLabel", {Text = text, Size = UDim2.new(1,-30,1,0), Position = UDim2.new(0,25,0,0), BackgroundTransparency = 1, TextColor3 = getColor("Text"), Font = config.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, frame)
                local state = default
                local function set(st) state = st; check.Image = state and "rbxassetid://3926307971" or "rbxassetid://3926305904"; if callback then callback(state) end end
                check.MouseButton1Click:Connect(function() set(not state) end); set(default)
                return { Set = set, Get = function() return state end }
            end
            
            function sectionApi:AddRadioGroup(text, options, default, callback)
                local frame = createInstance("Frame", {Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y}, contentArea)
                local title = createInstance("TextLabel", {Text = text, Size = UDim2.new(1,0,0,24), BackgroundTransparency = 1, TextColor3 = getColor("Text"), Font = config.FontBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, frame)
                local group = createInstance("Frame", {Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y}, frame)
                local layout = Instance.new("UIListLayout"); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0,6); layout.Parent = group
                local radios = {}; local selected = default
                local function select(opt)
                    selected = opt
                    for _, r in pairs(radios) do r.btn.Image = (r.option == opt) and "rbxassetid://3926307971" or "rbxassetid://3926305904" end
                    if callback then callback(opt) end
                end
                for _, opt in ipairs(options) do
                    local row = createInstance("Frame", {Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1}, group)
                    local radioBtn = createInstance("ImageButton", {Size = UDim2.new(0,20,0,20), Position = UDim2.new(0,0,0.5,-10), Image = (opt == default) and "rbxassetid://3926307971" or "rbxassetid://3926305904", BackgroundTransparency = 1}, row)
                    local optLabel = createInstance("TextLabel", {Text = opt, Size = UDim2.new(1,-30,1,0), Position = UDim2.new(0,25,0,0), BackgroundTransparency = 1, TextColor3 = getColor("Text"), Font = config.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left}, row)
                    radioBtn.MouseButton1Click:Connect(function() select(opt) end)
                    table.insert(radios, {btn = radioBtn, option = opt})
                end
                return { Set = select, Get = function() return selected end }
            end
            
            function sectionApi:AddAccordion(title, contentCallback)
                local accordion = createInstance("Frame", {Size = UDim2.new(1,0,0,0), BackgroundColor3 = getColor("Card"), BackgroundTransparency = 0.1, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y}, contentArea)
                applyCorner(accordion,8); applyStroke(accordion, getColor("Border"),0.5)
                local header = createInstance("TextButton", {Text = title, Size = UDim2.new(1,0,0,36), BackgroundColor3 = getColor("Card"), TextColor3 = getColor("Text"), Font = config.FontBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false}, accordion)
                applyCorner(header,8); local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0,12); pad.Parent = header
                local contentHolder = createInstance("Frame", {Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Visible = false}, accordion)
                local contentPad = Instance.new("UIPadding"); contentPad.PaddingLeft = UDim.new(0,12); contentPad.PaddingRight = UDim.new(0,12); contentPad.PaddingTop = UDim.new(0,8); contentPad.PaddingBottom = UDim.new(0,8); contentPad.Parent = contentHolder
                local contentLayout = Instance.new("UIListLayout"); contentLayout.SortOrder = Enum.SortOrder.LayoutOrder; contentLayout.Padding = UDim.new(0,8); contentLayout.Parent = contentHolder
                contentCallback(contentHolder)
                local open = false
                header.MouseButton1Click:Connect(function() open = not open; contentHolder.Visible = open; accordion.AutomaticSize = Enum.AutomaticSize.Y end)
                return accordion
            end
            
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
    tooltipFrame = createInstance("Frame", {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0, position.X+10, 0, position.Y+20), BackgroundColor3 = getColor("Card"), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.XY, ZIndex = 2000}, playerGui)
    applyCorner(tooltipFrame,6); applyStroke(tooltipFrame, getColor("Border"),0.5)
    local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0,8); pad.PaddingRight = UDim.new(0,8); pad.PaddingTop = UDim.new(0,6); pad.PaddingBottom = UDim.new(0,6); pad.Parent = tooltipFrame
    local label = createInstance("TextLabel", {Text = text, Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1, TextColor3 = getColor("Text"), Font = config.Font, TextSize = 12, AutomaticSize = Enum.AutomaticSize.XY, TextXAlignment = Enum.TextXAlignment.Center}, tooltipFrame)
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
            tooltipFrame.Position = UDim2.new(0, pos.X+10, 0, pos.Y+20)
        end
    end)
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
