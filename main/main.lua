

local SoraUI = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========================
-- КОНФІГУРАЦІЯ ЗА ЗАМОВЧУВАННЯМ
-- ========================
local config = {
    Theme = "Dark",                 -- "Dark", "Light", або власна назва
    SaveMethod = "Attribute",       -- "Attribute" або "DataStore"
    DataStoreName = "SoraUI_Settings",
    NotificationDuration = 3,       -- секунди
    DefaultWindowSize = UDim2.new(0, 700, 0, 500),
    AnimationSpeed = 0.2,
    UseContextActions = true,       -- чи реєструвати глобальні хоткеї
    DebugMode = false,              -- виводити логи в консоль
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    Rounding = 6,                   -- заокруглення кутів
    ScrollBarThickness = 5,
    
    -- Кольорові схеми
    Colors = {
        Dark = {
            Background = Color3.fromRGB(30, 30, 36),
            TopBar = Color3.fromRGB(45, 45, 55),
            TabActive = Color3.fromRGB(70, 70, 90),
            TabInactive = Color3.fromRGB(45, 45, 55),
            Section = Color3.fromRGB(40, 40, 48),
            Text = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(200, 200, 200),
            Accent = Color3.fromRGB(0, 120, 215),
            Button = Color3.fromRGB(0, 120, 215),
            ButtonHover = Color3.fromRGB(0, 100, 180),
            Danger = Color3.fromRGB(220, 53, 69),
            DangerHover = Color3.fromRGB(200, 40, 50),
            Success = Color3.fromRGB(40, 167, 69),
            ToggleOn = Color3.fromRGB(0, 200, 100),
            ToggleOff = Color3.fromRGB(100, 100, 100),
            SliderBackground = Color3.fromRGB(60, 60, 70),
            SliderFill = Color3.fromRGB(0, 120, 215),
            InputBackground = Color3.fromRGB(50, 50, 60),
            DropdownBackground = Color3.fromRGB(50, 50, 60),
            DropdownItemHover = Color3.fromRGB(70, 70, 80),
            ColorPickerBackground = Color3.fromRGB(45, 45, 55),
            KeybindBackground = Color3.fromRGB(50, 50, 60),
            Separator = Color3.fromRGB(80, 80, 90),
            NotificationBackground = Color3.fromRGB(30, 30, 36),
        },
        Light = {
            Background = Color3.fromRGB(240, 240, 245),
            TopBar = Color3.fromRGB(220, 220, 230),
            TabActive = Color3.fromRGB(200, 200, 210),
            TabInactive = Color3.fromRGB(230, 230, 240),
            Section = Color3.fromRGB(245, 245, 250),
            Text = Color3.fromRGB(0, 0, 0),
            TextSecondary = Color3.fromRGB(60, 60, 60),
            Accent = Color3.fromRGB(0, 120, 215),
            Button = Color3.fromRGB(0, 120, 215),
            ButtonHover = Color3.fromRGB(0, 100, 180),
            Danger = Color3.fromRGB(220, 53, 69),
            DangerHover = Color3.fromRGB(200, 40, 50),
            Success = Color3.fromRGB(40, 167, 69),
            ToggleOn = Color3.fromRGB(0, 200, 100),
            ToggleOff = Color3.fromRGB(150, 150, 160),
            SliderBackground = Color3.fromRGB(220, 220, 230),
            SliderFill = Color3.fromRGB(0, 120, 215),
            InputBackground = Color3.fromRGB(235, 235, 240),
            DropdownBackground = Color3.fromRGB(235, 235, 240),
            DropdownItemHover = Color3.fromRGB(210, 210, 220),
            ColorPickerBackground = Color3.fromRGB(230, 230, 240),
            KeybindBackground = Color3.fromRGB(235, 235, 240),
            Separator = Color3.fromRGB(180, 180, 190),
            NotificationBackground = Color3.fromRGB(240, 240, 245),
        }
    },
    
    -- Власна тема (перевизначає Dark/Light якщо задана)
    CustomTheme = nil,
}

-- ========================
-- ДОПОМІЖНІ ФУНКЦІЇ
-- ========================
local function debugLog(...)
    if config.DebugMode then
        print("[SoraUI]", ...)
    end
end

local function createInstance(className, properties, parent)
    local inst = Instance.new(className)
    for prop, value in pairs(properties) do
        inst[prop] = value
    end
    inst.Parent = parent
    return inst
end

local function applyCorner(guiObject, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = type(radius) == "number" and UDim.new(0, radius) or radius
    corner.Parent = guiObject
    return corner
end

local function applyPadding(guiObject, padding)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = padding.Left or UDim.new(0,0)
    pad.PaddingRight = padding.Right or UDim.new(0,0)
    pad.PaddingTop = padding.Top or UDim.new(0,0)
    pad.PaddingBottom = padding.Bottom or UDim.new(0,0)
    pad.Parent = guiObject
    return pad
end

-- ========================
-- СИСТЕМА ЗБЕРЕЖЕННЯ
-- ========================
local dataStore
if config.SaveMethod == "DataStore" then
    dataStore = DataStoreService:GetDataStore(config.DataStoreName)
end

local savedSettings = {}

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
    debugLog("Settings loaded:", savedSettings)
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
    debugLog("Settings saved")
end

-- ========================
-- СИСТЕМА ТЕМ
-- ========================
local currentTheme = config.Theme
local activeColors = config.Colors[config.Theme] or config.Colors.Dark

local function getColor(key)
    if config.CustomTheme and config.CustomTheme[key] then
        return config.CustomTheme[key]
    end
    return activeColors[key] or Color3.new(1,1,1)
end

local function applyThemeToDescendants(guiObject)
    for _, child in ipairs(guiObject:GetDescendants()) do
        if child:IsA("GuiObject") and child:GetAttribute("ThemeColor") then
            local colorKey = child:GetAttribute("ThemeColor")
            local color = getColor(colorKey)
            if color then
                child.BackgroundColor3 = color
            end
        elseif child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            if child:GetAttribute("ThemeTextColor") then
                local colorKey = child:GetAttribute("ThemeTextColor")
                local color = getColor(colorKey)
                if color then
                    child.TextColor3 = color
                end
            end
        end
    end
end

function SoraUI:SetTheme(themeName, customColors)
    if customColors then
        config.CustomTheme = customColors
        activeColors = customColors
    else
        config.CustomTheme = nil
        activeColors = config.Colors[themeName] or config.Colors.Dark
    end
    currentTheme = themeName
    if self._mainGui then
        applyThemeToDescendants(self._mainGui)
    end
    debugLog("Theme set to", themeName)
end

-- ========================
-- ГЛОБАЛЬНІ СПОВІЩЕННЯ
-- ========================
local notificationContainer
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
        createInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        }, notificationContainer)
    end
end

function SoraUI:Notify(title, text, duration, type)
    type = type or "info"
    setupNotificationContainer()
    local colors = activeColors
    local notif = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = colors.NotificationBackground,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0.1,
        LayoutOrder = #notificationContainer:GetChildren(),
    }, notificationContainer)
    applyCorner(notif, config.Rounding)
    applyPadding(notif, {Left = UDim.new(0,12), Right = UDim.new(0,12), Top = UDim.new(0,8), Bottom = UDim.new(0,8)})
    
    local titleLabel = createInstance("TextLabel", {
        Text = title,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = config.FontBold,
        TextSize = 14,
    }, notif)
    local textLabel = createInstance("TextLabel", {
        Text = text,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Font = config.Font,
        TextSize = 12,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, notif)
    
    duration = duration or config.NotificationDuration
    task.spawn(function()
        task.wait(duration)
        local tween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Wait()
        notif:Destroy()
    end)
end

-- ========================
-- СИСТЕМА ХОТКЕЇВ
-- ========================
local keybindActions = {}

local function onAction(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        local callback = keybindActions[actionName]
        if callback then
            callback()
        end
        return Enum.ContextActionResult.Sink
    end
    return Enum.ContextActionResult.Pass
end

function SoraUI:RegisterKeybind(name, keyCode, callback)
    if not config.UseContextActions then return end
    keybindActions[name] = callback
    ContextActionService:BindAction(name, onAction, false, keyCode)
    debugLog("Keybind registered:", name, keyCode)
end

function SoraUI:UnregisterKeybind(name)
    if not config.UseContextActions then return end
    keybindActions[name] = nil
    ContextActionService:UnbindAction(name)
end

-- ========================
-- ОСНОВНЕ ВІКНО
-- ========================
local mainGui = nil
local windows = {} -- підтримка кількох вікон (необов'язково)

function SoraUI:CreateWindow(title, customSize, options)
    options = options or {}
    local size = customSize or config.DefaultWindowSize
    
    -- Якщо вже є головне вікно, можна створити додаткове (але для простоти зробимо одне)
    if mainGui then mainGui:Destroy() end
    
    mainGui = createInstance("ScreenGui", {
        Name = "SoraUI_Main",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
    }, playerGui)
    self._mainGui = mainGui
    
    local windowFrame = createInstance("Frame", {
        Name = "Window",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = getColor("Background"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, mainGui)
    applyCorner(windowFrame, config.Rounding)
    
    -- Верхня панель
    local topBar = createInstance("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = getColor("TopBar"),
        BorderSizePixel = 0,
    }, windowFrame)
    applyCorner(topBar, config.Rounding)
    -- Окремий кут тільки зверху
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, config.Rounding)
    topCorner.Parent = topBar
    -- Заголовок
    local titleLabel = createInstance("TextLabel", {
        Text = title,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = getColor("Text"),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = config.FontBold,
        TextSize = 14,
    }, topBar)
    -- Кнопки вікна
    local closeBtn = createInstance("TextButton", {
        Text = "✕",
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = getColor("Text"),
        Font = config.FontBold,
        TextSize = 16,
    }, topBar)
    closeBtn.MouseButton1Click:Connect(function()
        windowFrame.Visible = false
    end)
    
    -- Перетягування
    local dragging = false
    local dragInput, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = windowFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            windowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Бокова панель вкладок
    local tabContainer = createInstance("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 160, 1, -32),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundColor3 = getColor("TopBar"),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    }, windowFrame)
    local tabList = createInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = config.ScrollBarThickness,
    }, tabContainer)
    local tabLayout = createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }, tabList)
    applyPadding(tabList, {Left = UDim.new(0,8), Right = UDim.new(0,8), Top = UDim.new(0,8), Bottom = UDim.new(0,8)})
    
    -- Контейнер контенту
    local contentContainer = createInstance("ScrollingFrame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -170, 1, -42),
        Position = UDim2.new(0, 170, 0, 37),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = config.ScrollBarThickness,
        ScrollBarImageColor3 = getColor("Accent"),
    }, windowFrame)
    local contentLayout = createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
    }, contentContainer)
    applyPadding(contentContainer, {Left = UDim.new(0,12), Right = UDim.new(0,12), Top = UDim.new(0,8), Bottom = UDim.new(0,8)})
    
    local tabs = {}
    local currentTab = nil
    
    local function selectTab(tabName)
        if currentTab then
            currentTab.Button.BackgroundColor3 = getColor("TabInactive")
            currentTab.Content.Visible = false
        end
        currentTab = tabs[tabName]
        if currentTab then
            currentTab.Button.BackgroundColor3 = getColor("TabActive")
            currentTab.Content.Visible = true
        end
    end
    
    -- API вікна
    local windowApi = {
        _tabs = tabs,
        _windowFrame = windowFrame,
        
        AddTab = function(name)
            local tabButton = createInstance("TextButton", {
                Text = name,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = getColor("TabInactive"),
                TextColor3 = getColor("Text"),
                Font = config.Font,
                TextSize = 14,
                AutoButtonColor = false,
                LayoutOrder = #tabs + 1,
            }, tabList)
            applyCorner(tabButton, config.Rounding)
            
            local tabContent = createInstance("ScrollingFrame", {
                Name = name.."_Content",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = config.ScrollBarThickness,
                Visible = false,
            }, contentContainer)
            local tabContentLayout = createInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 12),
            }, tabContent)
            applyPadding(tabContent, {Left = UDim.new(0,0), Right = UDim.new(0,0), Top = UDim.new(0,0), Bottom = UDim.new(0,0)})
            
            tabs[name] = {
                Button = tabButton,
                Content = tabContent,
                Sections = {}
            }
            
            tabButton.MouseButton1Click:Connect(function()
                selectTab(name)
            end)
            
            if #tabs == 1 then selectTab(name) end
            
            -- API секцій
            local tabApi = {
                AddSection = function(sectionTitle)
                    local sectionFrame = createInstance("Frame", {
                        Size = UDim2.new(1, 0, 0, 0),
                        BackgroundColor3 = getColor("Section"),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y,
                    }, tabContent)
                    applyCorner(sectionFrame, config.Rounding)
                    applyPadding(sectionFrame, {Left = UDim.new(0,12), Right = UDim.new(0,12), Top = UDim.new(0,12), Bottom = UDim.new(0,12)})
                    
                    local titleText = createInstance("TextLabel", {
                        Text = sectionTitle,
                        Size = UDim2.new(1, 0, 0, 24),
                        BackgroundTransparency = 1,
                        TextColor3 = getColor("Text"),
                        Font = config.FontBold,
                        TextSize = 16,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }, sectionFrame)
                    
                    local sectionContent = createInstance("Frame", {
                        Size = UDim2.new(1, 0, 0, 0),
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                    }, sectionFrame)
                    local sectionLayout = createInstance("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 10),
                    }, sectionContent)
                    
                    local sectionApi = {}
                    
                    -- Додати кнопку
                    function sectionApi:AddButton(text, callback, danger)
                        local btn = createInstance("TextButton", {
                            Text = text,
                            Size = UDim2.new(1, 0, 0, 34),
                            BackgroundColor3 = danger and getColor("Danger") or getColor("Button"),
                            TextColor3 = getColor("Text"),
                            Font = config.Font,
                            TextSize = 14,
                            AutoButtonColor = false,
                        }, sectionContent)
                        applyCorner(btn, config.Rounding)
                        btn.MouseButton1Click:Connect(callback)
                        btn.MouseEnter:Connect(function()
                            TweenService:Create(btn, TweenInfo.new(config.AnimationSpeed), {BackgroundColor3 = danger and getColor("DangerHover") or getColor("ButtonHover")}):Play()
                        end)
                        btn.MouseLeave:Connect(function()
                            TweenService:Create(btn, TweenInfo.new(config.AnimationSpeed), {BackgroundColor3 = danger and getColor("Danger") or getColor("Button")}):Play()
                        end)
                        return btn
                    end
                    
                    -- Додати перемикач
                    function sectionApi:AddToggle(name, defaultValue, callback)
                        local settingKey = title.."_"..name.."_Toggle"
                        local savedValue = savedSettings[settingKey]
                        if savedValue ~= nil then defaultValue = savedValue end
                        
                        local toggleFrame = createInstance("Frame", {
                            Size = UDim2.new(1, 0, 0, 36),
                            BackgroundTransparency = 1,
                        }, sectionContent)
                        local label = createInstance("TextLabel", {
                            Text = name,
                            Size = UDim2.new(1, -60, 1, 0),
                            BackgroundTransparency = 1,
                            TextColor3 = getColor("Text"),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Font = config.Font,
                            TextSize = 14,
                        }, toggleFrame)
                        local toggleBtn = createInstance("TextButton", {
                            Size = UDim2.new(0, 44, 0, 22),
                            Position = UDim2.new(1, -48, 0.5, -11),
                            BackgroundColor3 = defaultValue and getColor("ToggleOn") or getColor("ToggleOff"),
                            Text = "",
                            AutoButtonColor = false,
                        }, toggleFrame)
                        applyCorner(toggleBtn, UDim.new(1,0))
                        local indicator = createInstance("Frame", {
                            Size = UDim2.new(0, 18, 0, 18),
                            Position = UDim2.new(defaultValue and 1 or 0, defaultValue and -20 or 3, 0.5, -9),
                            BackgroundColor3 = Color3.fromRGB(255,255,255),
                            BorderSizePixel = 0,
                        }, toggleBtn)
                        applyCorner(indicator, UDim.new(1,0))
                        
                        local function setToggle(state)
                            defaultValue = state
                            local targetColor = state and getColor("ToggleOn") or getColor("ToggleOff")
                            TweenService:Create(toggleBtn, TweenInfo.new(config.AnimationSpeed), {BackgroundColor3 = targetColor}):Play()
                            TweenService:Create(indicator, TweenInfo.new(config.AnimationSpeed), {Position = UDim2.new(state and 1 or 0, state and -20 or 3, 0.5, -9)}):Play()
                            savedSettings[settingKey] = state
                            saveSettings()
                            if callback then callback(state) end
                        end
                        
                        toggleBtn.MouseButton1Click:Connect(function() setToggle(not defaultValue) end)
                        setToggle(defaultValue)
                        return { Set = setToggle, Get = function() return defaultValue end }
                    end
                    
                    -- Додати повзунок
                    function sectionApi:AddSlider(name, min, max, default, callback, decimals)
                        decimals = decimals or 0
                        local settingKey = title.."_"..name.."_Slider"
                        local savedValue = savedSettings[settingKey]
                        if savedValue ~= nil then default = savedValue end
                        
                        local sliderFrame = createInstance("Frame", {
                            Size = UDim2.new(1, 0, 0, 56),
                            BackgroundTransparency = 1,
                        }, sectionContent)
                        local label = createInstance("TextLabel", {
                            Text = name,
                            Size = UDim2.new(1, -80, 0, 22),
                            BackgroundTransparency = 1,
                            TextColor3 = getColor("Text"),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Font = config.Font,
                            TextSize = 14,
                        }, sliderFrame)
                        local valueLabel = createInstance("TextLabel", {
                            Text = tostring(default),
                            Size = UDim2.new(0, 60, 0, 22),
                            Position = UDim2.new(1, -65, 0, 0),
                            BackgroundTransparency = 1,
                            TextColor3 = getColor("Text"),
                            Font = config.Font,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Right,
                        }, sliderFrame)
                        local sliderBg = createInstance("Frame", {
                            Size = UDim2.new(1, 0, 0, 10),
                            Position = UDim2.new(0, 0, 0, 30),
                            BackgroundColor3 = getColor("SliderBackground"),
                            BorderSizePixel = 0,
                        }, sliderFrame)
                        applyCorner(sliderBg, UDim.new(1,0))
                        local fill = createInstance("Frame", {
                            Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
                            BackgroundColor3 = getColor("SliderFill"),
                            BorderSizePixel = 0,
                        }, sliderBg)
                        applyCorner(fill, UDim.new(1,0))
                        
                        local function updateSlider(input)
                            local relative = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
                            local val = math.clamp(min + (max-min) * relative, min, max)
                            if decimals == 0 then val = math.floor(val) else val = tonumber(string.format("%."..decimals.."f", val)) end
                            valueLabel.Text = tostring(val)
                            fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
                            savedSettings[settingKey] = val
                            saveSettings()
                            if callback then callback(val) end
                            return val
                        end
                        
                        local draggingSlider = false
                        sliderBg.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                draggingSlider = true
                                updateSlider(input)
                            end
                        end)
                        UserInputService.InputChanged:Connect(function(input)
                            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                                updateSlider(input)
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                draggingSlider = false
                            end
                        end)
                        updateSlider({Position = sliderBg.AbsolutePosition + Vector2.new((default-min)/(max-min) * sliderBg.AbsoluteSize.X, 0)})
                        
                        return { Set = function(v) updateSlider({Position = sliderBg.AbsolutePosition + Vector2.new((v-min)/(max-min) * sliderBg.AbsoluteSize.X, 0)}) end, Get = function() return tonumber(valueLabel.Text) end }
                    end
                    
                    -- Додати текстове поле
                    function sectionApi:AddInput(name, placeholder, default, callback, numeric)
                        local settingKey = title.."_"..name.."_Input"
                        local savedValue = savedSettings[settingKey]
                        if savedValue ~= nil then default = savedValue end
                        
                        local inputFrame = createInstance("Frame", {
                            Size = UDim2.new(1, 0, 0, 52),
                            BackgroundTransparency = 1,
                        }, sectionContent)
                        local label = createInstance("TextLabel", {
                            Text = name,
                            Size = UDim2.new(1, 0, 0, 22),
                            BackgroundTransparency = 1,
                            TextColor3 = getColor("Text"),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Font = config.Font,
                            TextSize = 14,
                        }, inputFrame)
                        local box = createInstance("TextBox", {
                            Text = tostring(default),
                            PlaceholderText = placeholder,
                            Size = UDim2.new(1, 0, 0, 32),
                            Position = UDim2.new(0, 0, 0, 24),
                            BackgroundColor3 = getColor("InputBackground"),
                            TextColor3 = getColor("Text"),
                            Font = config.Font,
                            TextSize = 14,
                            ClearTextOnFocus = false,
                        }, inputFrame)
                        applyCorner(box, config.Rounding)
                        
                        box.FocusLost:Connect(function(enterPressed)
                            local val = box.Text
                            if numeric then
                                val = tonumber(val) or default
                                box.Text = tostring(val)
                            end
                            savedSettings[settingKey] = val
                            saveSettings()
                            if callback then callback(val) end
                        end)
                        return { Set = function(t) box.Text = tostring(t); callback(t) end, Get = function() return numeric and tonumber(box.Text) or box.Text end }
                    end
                    
                    -- Додати випадаючий список
                    function sectionApi:AddDropdown(name, options, default, callback)
                        local settingKey = title.."_"..name.."_Dropdown"
                        local savedValue = savedSettings[settingKey]
                        if savedValue ~= nil then default = savedValue end
                        
                        local dropdownFrame = createInstance("Frame", {
                            Size = UDim2.new(1, 0, 0, 40),
                            BackgroundTransparency = 1,
                        }, sectionContent)
                        local label = createInstance("TextLabel", {
                            Text = name,
                            Size = UDim2.new(0.5, -10, 1, 0),
                            BackgroundTransparency = 1,
                            TextColor3 = getColor("Text"),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Font = config.Font,
                            TextSize = 14,
                        }, dropdownFrame)
                        local dropdownBtn = createInstance("TextButton", {
                            Text = default,
                            Size = UDim2.new(0.5, 0, 0, 32),
                            Position = UDim2.new(0.5, 10, 0.5, -16),
                            BackgroundColor3 = getColor("DropdownBackground"),
                            TextColor3 = getColor("Text"),
                            Font = config.Font,
                            TextSize = 14,
                            AutoButtonColor = false,
                        }, dropdownFrame)
                        applyCorner(dropdownBtn, config.Rounding)
                        
                        local dropdownList = nil
                        local isOpen = false
                        
                        local function closeDropdown()
                            if dropdownList then dropdownList:Destroy() dropdownList = nil end
                            isOpen = false
                        end
                        
                        local function openDropdown()
                            closeDropdown()
                            dropdownList = createInstance("ScrollingFrame", {
                                Size = UDim2.new(0.5, 0, 0, 120),
                                Position = UDim2.new(0.5, 10, 0, 32),
                                BackgroundColor3 = getColor("DropdownBackground"),
                                BorderSizePixel = 0,
                                AutomaticSize = Enum.AutomaticSize.Y,
                                ScrollBarThickness = config.ScrollBarThickness,
                            }, dropdownFrame)
                            applyCorner(dropdownList, config.Rounding)
                            local listLayout = createInstance("UIListLayout", {
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = UDim.new(0, 2),
                            }, dropdownList)
                            for _, opt in ipairs(options) do
                                local optBtn = createInstance("TextButton", {
                                    Text = opt,
                                    Size = UDim2.new(1, 0, 0, 28),
                                    BackgroundTransparency = 1,
                                    TextColor3 = getColor("Text"),
                                    Font = config.Font,
                                    TextSize = 14,
                                    AutoButtonColor = false,
                                }, dropdownList)
                                optBtn.MouseEnter:Connect(function() optBtn.BackgroundColor3 = getColor("DropdownItemHover") end)
                                optBtn.MouseLeave:Connect(function() optBtn.BackgroundTransparency = 1 end)
                                optBtn.MouseButton1Click:Connect(function()
                                    dropdownBtn.Text = opt
                                    savedSettings[settingKey] = opt
                                    saveSettings()
                                    if callback then callback(opt) end
                                    closeDropdown()
                                end)
                            end
                            isOpen = true
                        end
                        
                        dropdownBtn.MouseButton1Click:Connect(function()
                            if isOpen then closeDropdown() else openDropdown() end
                        end)
                        
                        return { Set = function(opt) dropdownBtn.Text = opt; callback(opt) end, Get = function() return dropdownBtn.Text end }
                    end
                    
                    -- Додати колірний пікер
                    function sectionApi:AddColorPicker(name, defaultColor, callback)
                        local settingKey = title.."_"..name.."_Color"
                        local savedValue = savedSettings[settingKey]
                        if savedValue then defaultColor = Color3.fromHex(savedValue) end
                        
                        local pickerFrame = createInstance("Frame", {
                            Size = UDim2.new(1, 0, 0, 40),
                            BackgroundTransparency = 1,
                        }, sectionContent)
                        local label = createInstance("TextLabel", {
                            Text = name,
                            Size = UDim2.new(0.7, -10, 1, 0),
                            BackgroundTransparency = 1,
                            TextColor3 = getColor("Text"),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Font = config.Font,
                            TextSize = 14,
                        }, pickerFrame)
                        local colorBtn = createInstance("TextButton", {
                            Text = "",
                            Size = UDim2.new(0, 32, 0, 32),
                            Position = UDim2.new(1, -36, 0.5, -16),
                            BackgroundColor3 = defaultColor,
                            AutoButtonColor = false,
                        }, pickerFrame)
                        applyCorner(colorBtn, config.Rounding)
                        
                        local pickerModal = nil
                        colorBtn.MouseButton1Click:Connect(function()
                            if pickerModal then pickerModal:Destroy() pickerModal = nil return end
                            pickerModal = createInstance("Frame", {
                                Size = UDim2.new(0, 220, 0, 220),
                                Position = UDim2.new(0.5, -110, 0.5, -110),
                                BackgroundColor3 = getColor("ColorPickerBackground"),
                                BorderSizePixel = 0,
                                ZIndex = 10,
                            }, mainGui)
                            applyCorner(pickerModal, config.Rounding)
                            -- Спрощений колірний пікер (можна розширити)
                            local hueSlider = createInstance("Frame", {
                                Size = UDim2.new(0.8, 0, 0, 16),
                                Position = UDim2.new(0.1, 0, 0.7, 0),
                                BackgroundColor3 = Color3.fromRGB(255,0,0),
                            }, pickerModal)
                            applyCorner(hueSlider, UDim.new(1,0))
                            local saturationPicker = createInstance("Frame", {
                                Size = UDim2.new(0.8, 0, 0.5, 0),
                                Position = UDim2.new(0.1, 0, 0.1, 0),
                                BackgroundColor3 = defaultColor,
                            }, pickerModal)
                            applyCorner(saturationPicker, config.Rounding)
                            -- Спрощено: просто кнопка вибору
                            local selectBtn = createInstance("TextButton", {
                                Text = "Вибрати",
                                Size = UDim2.new(0.6, 0, 0, 30),
                                Position = UDim2.new(0.2, 0, 0.85, 0),
                                BackgroundColor3 = getColor("Button"),
                                TextColor3 = getColor("Text"),
                            }, pickerModal)
                            selectBtn.MouseButton1Click:Connect(function()
                                local newColor = saturationPicker.BackgroundColor3
                                colorBtn.BackgroundColor3 = newColor
                                savedSettings[settingKey] = newColor:ToHex()
                                saveSettings()
                                if callback then callback(newColor) end
                                pickerModal:Destroy()
                                pickerModal = nil
                            end)
                        end)
                        
                        return { Set = function(c) colorBtn.BackgroundColor3 = c; callback(c) end, Get = function() return colorBtn.BackgroundColor3 end }
                    end
                    
                    -- Додати призначення клавіш
                    function sectionApi:AddKeybind(name, defaultKey, callback)
                        local settingKey = title.."_"..name.."_Keybind"
                        local savedValue = savedSettings[settingKey]
                        if savedValue then defaultKey = savedValue end
                        
                        local keyFrame = createInstance("Frame", {
                            Size = UDim2.new(1, 0, 0, 40),
                            BackgroundTransparency = 1,
                        }, sectionContent)
                        local label = createInstance("TextLabel", {
                            Text = name,
                            Size = UDim2.new(0.7, -10, 1, 0),
                            BackgroundTransparency = 1,
                            TextColor3 = getColor("Text"),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Font = config.Font,
                            TextSize = 14,
                        }, keyFrame)
                        local keyBtn = createInstance("TextButton", {
                            Text = defaultKey,
                            Size = UDim2.new(0, 100, 0, 32),
                            Position = UDim2.new(1, -110, 0.5, -16),
                            BackgroundColor3 = getColor("KeybindBackground"),
                            TextColor3 = getColor("Text"),
                            Font = config.Font,
                            TextSize = 14,
                        }, keyFrame)
                        applyCorner(keyBtn, config.Rounding)
                        
                        local listening = false
                        keyBtn.MouseButton1Click:Connect(function()
                            if listening then return end
                            listening = true
                            keyBtn.Text = "..."
                            local connection
                            connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                                if gameProcessed then return end
                                if input.UserInputType == Enum.UserInputType.Keyboard then
                                    local key = input.KeyCode.Name
                                    keyBtn.Text = key
                                    savedSettings[settingKey] = key
                                    saveSettings()
                                    SoraUI:RegisterKeybind(name.."_custom", input.KeyCode, function() callback() end)
                                    listening = false
                                    connection:Disconnect()
                                end
                            end)
                            task.wait(5)
                            if listening then
                                listening = false
                                keyBtn.Text = defaultKey
                                connection:Disconnect()
                            end
                        end)
                        SoraUI:RegisterKeybind(name.."_custom", Enum.KeyCode[defaultKey], callback)
                        return { Set = function(k) keyBtn.Text = k; SoraUI:RegisterKeybind(name.."_custom", Enum.KeyCode[k], callback) end }
                    end
                    
                    -- Додати сепаратор
                    function sectionApi:AddSeparator()
                        local sep = createInstance("Frame", {
                            Size = UDim2.new(1, 0, 0, 2),
                            BackgroundColor3 = getColor("Separator"),
                            BorderSizePixel = 0,
                        }, sectionContent)
                        return sep
                    end
                    
                    -- Додати простий текст
                    function sectionApi:AddLabel(text, fontSize)
                        local label = createInstance("TextLabel", {
                            Text = text,
                            Size = UDim2.new(1, 0, 0, 24),
                            BackgroundTransparency = 1,
                            TextColor3 = getColor("TextSecondary"),
                            Font = config.Font,
                            TextSize = fontSize or 12,
                            TextWrapped = true,
                        }, sectionContent)
                        return label
                    end
                    
                    -- Додати параграф
                    function sectionApi:AddParagraph(text)
                        local para = createInstance("TextLabel", {
                            Text = text,
                            Size = UDim2.new(1, 0, 0, 0),
                            BackgroundTransparency = 1,
                            TextColor3 = getColor("TextSecondary"),
                            Font = config.Font,
                            TextSize = 12,
                            TextWrapped = true,
                            AutomaticSize = Enum.AutomaticSize.Y,
                        }, sectionContent)
                        return para
                    end
                    
                    return sectionApi
                end
            }
            return tabApi
        end,
        
        SetTheme = SoraUI.SetTheme,
        Notify = SoraUI.Notify,
        Destroy = function() 
            if mainGui then mainGui:Destroy() end
            mainGui = nil
        end,
        GetWindow = function() return windowFrame end,
        Hide = function() windowFrame.Visible = false end,
        Show = function() windowFrame.Visible = true end,
        Toggle = function() windowFrame.Visible = not windowFrame.Visible end,
    }
    
    loadSettings()
    applyThemeToDescendants(mainGui)
    return windowApi
end

-- ========================
-- ДОДАТКОВІ УТИЛІТИ
-- ========================
function SoraUI:ShowNotification(title, text, duration, type)
    self:Notify(title, text, duration, type)
end

function SoraUI:GetConfig()
    return config
end

function SoraUI:SetConfig(newConfig)
    for k, v in pairs(newConfig) do
        config[k] = v
    end
    if newConfig.Theme then
        self:SetTheme(newConfig.Theme)
    end
end

return SoraUI
