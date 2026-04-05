-- ================================================
-- SoraUI - UI modern to Roblox
-- ================================================

local SoraUI = {}
SoraUI.__index = SoraUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- ======================THEMES ======================
local Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 18, 24),
        Secondary = Color3.fromRGB(28, 28, 38),
        Accent = Color3.fromRGB(130, 90, 255),
        Accent2 = Color3.fromRGB(80, 200, 255),
        Text = Color3.fromRGB(245, 245, 255),
        Stroke = Color3.fromRGB(65, 65, 90)
    },
    Neon = {
        Background = Color3.fromRGB(12, 12, 20),
        Secondary = Color3.fromRGB(22, 22, 32),
        Accent = Color3.fromRGB(255, 60, 180),
        Accent2 = Color3.fromRGB(60, 255, 200),
        Text = Color3.fromRGB(255, 255, 255),
        Stroke = Color3.fromRGB(120, 50, 160)
    },
    Ocean = {
        Background = Color3.fromRGB(10, 20, 40),
        Secondary = Color3.fromRGB(20, 35, 65),
        Accent = Color3.fromRGB(0, 180, 255),
        Accent2 = Color3.fromRGB(100, 220, 255),
        Text = Color3.fromRGB(220, 240, 255),
        Stroke = Color3.fromRGB(50, 110, 190)
    },
    Light = {
        Background = Color3.fromRGB(248, 248, 252),
        Secondary = Color3.fromRGB(235, 235, 240),
        Accent = Color3.fromRGB(110, 70, 250),
        Accent2 = Color3.fromRGB(150, 110, 255),
        Text = Color3.fromRGB(25, 25, 35),
        Stroke = Color3.fromRGB(190, 190, 210)
    }
}

local CurrentTheme = Themes.Dark
local ConfigPath = "SoraUI_Config.json"

-- ====================== 
Helped Functions
======================
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function Tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function AddCorner(parent, radius)
    Create("UICorner", {CornerRadius = UDim.new(0, radius or 16), Parent = parent})
end

local function AddStroke(parent, color, thickness)
    Create("UIStroke", {Color = color or CurrentTheme.Stroke, Thickness = thickness or 1.8, Parent = parent})
end

local function AddShadow(parent)
    local shadow = Create("ImageLabel", {
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.65,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20,20,280,280),
        ZIndex = parent.ZIndex - 2,
        Parent = parent.Parent
    })
    return shadow
end

local function Drag(frame)
    local dragging = false
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function() dragging = false end)
end

local function SaveConfig(config)
    if isfile then
        writefile(ConfigPath, HttpService:JSONEncode(config))
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigPath) then
        return HttpService:JSONDecode(readfile(ConfigPath))
    end
    return {}
end

-- ====================== CREATE WINDOW ======================
function SoraUI:CreateWindow(options)
    options = options or {}
    local self = setmetatable({}, SoraUI)

    -- local ScreenGui (як ти просив)
    local ScreenGui = Create("ScreenGui", {
        Name = "SoraUI_v6",
        ResetOnSpawn = false,
        Parent = (gethui and gethui()) or game:GetService("CoreGui")
    })

    -- Головне вікно
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 850, 0, 600),
        Position = UDim2.new(0.5, -425, 0.5, -300),
        BackgroundColor3 = CurrentTheme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 20)
    AddStroke(MainFrame)
    AddShadow(MainFrame)

    -- Title Bar
    local TitleBar = Create("Frame", {Size = UDim2.new(1, 0, 0, 72), BackgroundTransparency = 1, Parent = MainFrame})
    local TitleGradient = Create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = CurrentTheme.Accent, Parent = TitleBar})
    Create("UIGradient", {
        Color = ColorSequence.new(CurrentTheme.Accent, CurrentTheme.Accent2),
        Parent = TitleGradient
    })
    AddCorner(TitleGradient, 20)

    -- Багато local TextLabel (як ти просив)
    local TitleLabel = Create("TextLabel", {
        Size = UDim2.new(1, -200, 1, 0),
        BackgroundTransparency = 1,
        Text = options.Title or "SoraUI v6.0 — Великий Хаб",
        TextColor3 = CurrentTheme.Text,
        Font = Enum.Font.GothamBlack,
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    local VersionLabel = Create("TextLabel", {
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -190, 0, 0),
        BackgroundTransparency = 1,
        Text = "v6.0 Power",
        TextColor3 = CurrentTheme.Text,
        Font = Enum.Font.GothamSemibold,
        TextScaled = true,
        Parent = TitleBar
    })

    local AuthorLabel = Create("TextLabel", { -- local TextLabel
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -300, 0, 0),
        BackgroundTransparency = 1,
        Text = "by Sora",
        TextColor3 = CurrentTheme.Text,
        Font = Enum.Font.Gotham,
        TextScaled = true,
        Parent = TitleBar
    })

    -- Кнопки керування
    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 52, 0, 52),
        Position = UDim2.new(1, -68, 0, 10),
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 100, 100),
        BackgroundTransparency = 1,
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })

    local MinimizeBtn = Create("TextButton", {
        Size = UDim2.new(0, 52, 0, 52),
        Position = UDim2.new(1, -125, 0, 10),
        Text = "–",
        TextColor3 = CurrentTheme.Text,
        BackgroundTransparency = 1,
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })

    Drag(MainFrame)

    -- Tab Bar
    local TabBar = Create("Frame", {
        Size = UDim2.new(1, -30, 0, 68),
        Position = UDim2.new(0, 15, 0, 82),
        BackgroundColor3 = CurrentTheme.Secondary,
        Parent = MainFrame
    })
    AddCorner(TabBar, 16)

    local TabScroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -12),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        Parent = TabBar
    })
    Create("UIListLayout", {Padding = UDim.new(0, 12), FillDirection = Enum.FillDirection.Horizontal, Parent = TabScroll})

    local ContentArea = Create("Frame", {
        Size = UDim2.new(1, -30, 1, -175),
        Position = UDim2.new(0, 15, 0, 160),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    self.ScreenGui = ScreenGui
    self.MainFrame = MainFrame
    self.ContentArea = ContentArea
    self.Tabs = {}
    self.CurrentTab = nil
    self.Config = LoadConfig()

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.45)
        task.wait(0.5)
        ScreenGui:Destroy()
    end)

    -- ====================== CREATE TAB ======================
    function self:CreateTab(name)
        local TabButton = Create("TextButton", {
            Size = UDim2.new(0, 190, 1, 0),
            BackgroundColor3 = CurrentTheme.Secondary,
            Text = name,
            TextColor3 = CurrentTheme.Text,
            Font = Enum.Font.GothamSemibold,
            TextScaled = true,
            Parent = TabScroll
        })
        AddCorner(TabButton, 14)

        local TabPage = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 6,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentArea
        })
        Create("UIListLayout", {Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabPage})

        table.insert(self.Tabs, {Button = TabButton, Page = TabPage})

        TabButton.MouseButton1Click:Connect(function()
            if self.CurrentTab then
                self.CurrentTab.Page.Visible = false
                Tween(self.CurrentTab.Button, {BackgroundColor3 = CurrentTheme.Secondary}, 0.25)
            end
            TabPage.Visible = true
            Tween(TabButton, {BackgroundColor3 = CurrentTheme.Accent}, 0.25)
            self.CurrentTab = {Button = TabButton, Page = TabPage}
        end)

        if #self.Tabs == 1 then
            TabPage.Visible = true
            TabButton.BackgroundColor3 = CurrentTheme.Accent
            self.CurrentTab = {Button = TabButton, Page = TabPage}
        end

        local Tab = {Parent = self}

        function Tab:CreateSection(title)
            local SectionLabel = Create("TextLabel", {
                Size = UDim2.new(1, -20, 0, 45),
                BackgroundTransparency = 1,
                Text = "◆ " .. title,
                TextColor3 = CurrentTheme.Accent,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                Parent = TabPage
            })
        end

        function Tab:CreateButton(text, callback)
            local Btn = Create("TextButton", {
                Size = UDim2.new(1, -20, 0, 62),
                BackgroundColor3 = CurrentTheme.Secondary,
                Text = text,
                TextColor3 = CurrentTheme.Text,
                Font = Enum.Font.GothamSemibold,
                TextScaled = true,
                Parent = TabPage
            })
            AddCorner(Btn, 16)
            AddStroke(Btn)
            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, {BackgroundColor3 = CurrentTheme.Accent}, 0.1)
                task.wait(0.15)
                Tween(Btn, {BackgroundColor3 = CurrentTheme.Secondary}, 0.25)
                if callback then callback() end
            end)
        end

        function Tab:CreateToggle(text, default, callback, flag)
            local state = self.Parent.Config[flag] or default or false
            local Frame = Create("Frame", {Size = UDim2.new(1, -20, 0, 62), BackgroundColor3 = CurrentTheme.Secondary, Parent = TabPage})
            AddCorner(Frame, 16)
            AddStroke(Frame)

            local ToggleLabel = Create("TextLabel", {
                Size = UDim2.new(0.78, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.GothamSemibold,
                TextScaled = true,
                Parent = Frame
            })

            local ToggleFrame = Create("Frame", {
                Size = UDim2.new(0, 60, 0, 34),
                Position = UDim2.new(1, -80, 0.5, -17),
                BackgroundColor3 = state and CurrentTheme.Accent or Color3.fromRGB(75,75,90),
                Parent = Frame
            })
            AddCorner(ToggleFrame, 999)

            ToggleFrame.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    Tween(ToggleFrame, {BackgroundColor3 = state and CurrentTheme.Accent or Color3.fromRGB(75,75,90)}, 0.35)
                    if callback then callback(state) end
                    if flag then self.Parent.Config[flag] = state; SaveConfig(self.Parent.Config) end
                end
            end)
        end

        function Tab:CreateSlider(text, min, max, default, callback, flag)
            local value = self.Parent.Config[flag] or default or min
            local Frame = Create("Frame", {Size = UDim2.new(1, -20, 0, 90), BackgroundColor3 = CurrentTheme.Secondary, Parent = TabPage})
            AddCorner(Frame, 16)

            local SliderLabel = Create("TextLabel", { -- local TextLabel
                Size = UDim2.new(1, -30, 0, 32),
                BackgroundTransparency = 1,
                Text = text .. ": " .. value,
                TextColor3 = CurrentTheme.Text,
                Font = Enum.Font.GothamSemibold,
                Parent = Frame
            })

            local Bar = Create("Frame", {Size = UDim2.new(1, -50, 0, 14), Position = UDim2.new(0, 25, 0, 58), BackgroundColor3 = Color3.fromRGB(60,60,78), Parent = Frame})
            AddCorner(Bar, 999)

            local Fill = Create("Frame", {Size = UDim2.new((value - min) / (max - min), 0, 1, 0), BackgroundColor3 = CurrentTheme.Accent, Parent = Bar})
            AddCorner(Fill, 999)

            local dragging = false
            Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
            Bar.InputEnded:Connect(function() dragging = false end)

            RunService.RenderStepped:Connect(function()
                if dragging then
                    local rel = math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * rel)
                    Fill.Size = UDim2.new(rel, 0, 1, 0)
                    SliderLabel.Text = text .. ": " .. value
                    if callback then callback(value) end
                    if flag then self.Parent.Config[flag] = value; SaveConfig(self.Parent.Config) end
                end
            end)
        end

        function Tab:CreateDropdown(text, options, default, callback)
            local Btn = Create("TextButton", {
                Size = UDim2.new(1, -20, 0, 62),
                BackgroundColor3 = CurrentTheme.Secondary,
                Text = text .. " ▼ " .. (default or options[1] or ""),
                TextColor3 = CurrentTheme.Text,
                Font = Enum.Font.GothamSemibold,
                Parent = TabPage
            })
            AddCorner(Btn, 16)
            Btn.MouseButton1Click:Connect(function()
                self.Parent:Notify("Dropdown: " .. text .. " (" .. #options .. " опцій)", 3)
                if callback and options[1] then callback(options[1]) end
            end)
        end

        function Tab:CreateTextbox(text, placeholder, callback)
            local Frame = Create("Frame", {Size = UDim2.new(1, -20, 0, 62), BackgroundColor3 = CurrentTheme.Secondary, Parent = TabPage})
            AddCorner(Frame, 16)

            local TextboxLabel = Create("TextLabel", {
                Size = UDim2.new(0.4, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Frame
            })

            local Box = Create("TextBox", {
                Size = UDim2.new(0.55, 0, 0.8, 0),
                Position = UDim2.new(0.42, 0, 0.1, 0),
                PlaceholderText = placeholder or "Введіть...",
                BackgroundColor3 = Color3.fromRGB(40,40,55),
                TextColor3 = CurrentTheme.Text,
                Parent = Frame
            })
            AddCorner(Box, 12)

            Box.FocusLost:Connect(function(enter)
                if enter and callback then callback(Box.Text) end
            end)
        end

        function Tab:CreateLabel(text)
            local TextLabel1 = Create("TextLabel", { -- local TextLabel1
                Size = UDim2.new(1, -20, 0, 40),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = CurrentTheme.Text,
                TextScaled = true,
                Font = Enum.Font.Gotham,
                Parent = TabPage
            })
            return TextLabel1
        end

        function Tab:CreateParagraph(text)
            local ParagraphLabel = Create("TextLabel", {
                Size = UDim2.new(1, -30, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = CurrentTheme.Text,
                TextWrapped = true,
                TextSize = 17,
                Font = Enum.Font.Gotham,
                Parent = TabPage
            })
        end

        return Tab
    end

    -- ====================== NOTIFICATIONS ======================
    function self:Notify(message, duration)
        duration = duration or 4
        local Notif = Create("Frame", {
            Size = UDim2.new(0, 370, 0, 105),
            Position = UDim2.new(1, 50, 1, -170),
            BackgroundColor3 = CurrentTheme.Background,
            Parent = ScreenGui
        })
        AddCorner(Notif, 18)
        AddStroke(Notif)

        local NotifLabel = Create("TextLabel", { -- local TextLabel
            Size = UDim2.new(1, -30, 1, -20),
            Position = UDim2.new(0, 15, 0, 10),
            BackgroundTransparency = 1,
            Text = message,
            TextColor3 = CurrentTheme.Text,
            TextScaled = true,
            Font = Enum.Font.GothamSemibold,
            TextWrapped = true,
            Parent = Notif
        })

        Tween(Notif, {Position = UDim2.new(1, 
-420, 1, -170)}, 0.6)
        task.delay(duration, function()
            Tween(Notif, {Position = UDim2.new(1, 50, 1, -170)}, 0.6)
            task.wait(0.7)
            Notif:Destroy()
        end)
    end
——AAAAAAAAAAAAAA
—why :(   oh no
    self:Notify("SoraUI loading good(1500+)", 5)

    return self
end

return SoraUI
