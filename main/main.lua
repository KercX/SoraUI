-- ================================================
SORA UI
-- ================================================

print("SoraUI loading...")

-- ====================== LOCAL SCREEN GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SoraUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local SoraUI = {}
SoraUI.__index = SoraUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ====================== ТЕМИ ======================
local Themes = {
    Dark = {Bg = Color3.fromRGB(18,18,24), Sec = Color3.fromRGB(28,28,38), Accent = Color3.fromRGB(130,90,255), Text = Color3.fromRGB(245,245,255)},
    Neon = {Bg = Color3.fromRGB(12,12,20), Sec = Color3.fromRGB(22,22,32), Accent = Color3.fromRGB(0,200,255), Text = Color3.fromRGB(255,255,255)},
    Ocean = {Bg = Color3.fromRGB(10,20,40), Sec = Color3.fromRGB(20,35,65), Accent = Color3.fromRGB(0,170,255), Text = Color3.fromRGB(220,240,255)},
    Light = {Bg = Color3.fromRGB(245,245,250), Sec = Color3.fromRGB(230,230,235), Accent = Color3.fromRGB(100,70,250), Text = Color3.fromRGB(30,30,40)}
}

local CurrentTheme = Themes.Neon

local function Create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k] = v end
    return obj
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function AddCorner(parent, r)
    Create("UICorner", {CornerRadius = UDim.new(0, r or 16), Parent = parent})
end

local function AddStroke(parent)
    Create("UIStroke", {Color = CurrentTheme.Accent, Thickness = 1.6, Parent = parent})
end

local function Drag(frame)
    local dragging = false
    local dragStart, startPos
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function() dragging = false end)
end

-- ====================== CREATE WINDOW ======================
function SoraUI:CreateWindow(title)
    local self = setmetatable({}, SoraUI)

    local MainFrame = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 830, 0, 570),
        Position = UDim2.new(0.5, -415, 0.5, -285),
        BackgroundColor3 = CurrentTheme.Bg,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 20)
    AddStroke(MainFrame)

    -- Title Bar (як у WindUI / Rayfield)
    local TitleBar = Create("Frame", {Size = UDim2.new(1,0,0,70), BackgroundColor3 = CurrentTheme.Accent, Parent = MainFrame})
    AddCorner(TitleBar)

    local TitleLabel = Create("TextLabel", {  -- local TitleLabel
        Size = UDim2.new(1, -160, 1, 0),
        BackgroundTransparency = 1,
        Text = title or "SoraUI v6.0",
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0,52,0,52),
        Position = UDim2.new(1,-65,0,9),
        Text = "✕",
        TextColor3 = Color3.fromRGB(255,100,100),
        BackgroundTransparency = 1,
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })

    -- Tab Bar
    local TabBar = Create("Frame", {Size = UDim2.new(1,-30,0,65), Position = UDim2.new(0,15,0,80), BackgroundColor3 = CurrentTheme.Sec, Parent = MainFrame})
    AddCorner(TabBar, 14)

    local TabScroll = Create("ScrollingFrame", {
        Size = UDim2.new(1,-20,1,-10),
        Position = UDim2.new(0,10,0,5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        Parent = TabBar
    })
    Create("UIListLayout", {Padding = UDim.new(0,12), FillDirection = Enum.FillDirection.Horizontal, Parent = TabScroll})

    local ContentArea = Create("Frame", {Size = UDim2.new(1,-30,1,-165), Position = UDim2.new(0,15,0,155), BackgroundTransparency = 1, Parent = MainFrame})

    Drag(MainFrame)

    self.ScreenGui = ScreenGui
    self.MainFrame = MainFrame
    self.ContentArea = ContentArea
    self.Tabs = {}
    self.CurrentTab = nil

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.45)
        task.wait(0.5)
        ScreenGui:Destroy()
    end)

    -- ====================== CREATE TAB ======================
    function self:CreateTab(name)
        local TabBtn = Create("TextButton", {
            Size = UDim2.new(0,175,1,0),
            BackgroundColor3 = CurrentTheme.Sec,
            Text = name,
            TextColor3 = CurrentTheme.Text,
            Font = Enum.Font.GothamSemibold,
            TextScaled = true,
            Parent = TabScroll
        })
        AddCorner(TabBtn, 12)

        local TabPage = Create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 6,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentArea
        })
        Create("UIListLayout", {Padding = UDim.new(0,14), Parent = TabPage})

        table.insert(self.Tabs, {Btn = TabBtn, Page = TabPage})

        TabBtn.MouseButton1Click:Connect(function()
            if self.CurrentTab then
                self.CurrentTab.Page.Visible = false
                Tween(self.CurrentTab.Btn, {BackgroundColor3 = CurrentTheme.Sec}, 0.25)
            end
            TabPage.Visible = true
            Tween(TabBtn, {BackgroundColor3 = CurrentTheme.Accent}, 0.25)
            self.CurrentTab = {Btn = TabBtn, Page = TabPage}
        end)

        if #self.Tabs == 1 then
            TabPage.Visible = true
            TabBtn.BackgroundColor3 = CurrentTheme.Accent
            self.CurrentTab = {Btn = TabBtn, Page = TabPage}
        end

        local Tab = {}

        function Tab:CreateSection(title)
            Create("TextLabel", {Size = UDim2.new(1,-20,0,42), BackgroundTransparency = 1, Text = "◆ "..title, TextColor3 = CurrentTheme.Accent, Font = Enum.Font.GothamBold, TextScaled = true, Parent = TabPage})
        end

        function Tab:CreateButton(text, callback)
            local Btn = Create("TextButton", {Size = UDim2.new(1,-20,0,56), BackgroundColor3 = CurrentTheme.Sec, Text = text, TextColor3 = CurrentTheme.Text, Font = Enum.Font.GothamSemibold, TextScaled = true, Parent = TabPage})
            AddCorner(Btn, 14)
            AddStroke(Btn)
            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, {BackgroundColor3 = CurrentTheme.Accent}, 0.1)
                task.wait(0.15)
                Tween(Btn, {BackgroundColor3 = CurrentTheme.Sec}, 0.25)
                if callback then callback() end
            end)
        end

        function Tab:CreateToggle(text, default, callback)
            local state = default or false
            local Frame = Create("Frame", {Size = UDim2.new(1,-20,0,56), BackgroundColor3 = CurrentTheme.Sec, Parent = TabPage})
            AddCorner(Frame, 14)
            AddStroke(Frame)

            Create("TextLabel", {Size = UDim2.new(0.78,0,1,0), BackgroundTransparency = 1, Text = text, TextColor3 = CurrentTheme.Text, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamSemibold, TextScaled = true, Parent = Frame})

            local Tog = Create("Frame", {Size = UDim2.new(0,54,0,30), Position = UDim2.new(1,-72,0.5,-15), BackgroundColor3 = state and CurrentTheme.Accent or Color3.fromRGB(70,70,90), Parent = Frame})
            AddCorner(Tog, 999)

            Tog.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    Tween(Tog, {BackgroundColor3 = state and CurrentTheme.Accent or Color3.fromRGB(70,70,90)}, 0.35)
                    if callback then callback(state) end
                end
            end)
        end

        function Tab:CreateLabel(text)
            local TextLabel1 = Create("TextLabel", {  -- local TextLabel1
                Size = UDim2.new(1,-20,0,40),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = CurrentTheme.Text,
                TextScaled = true,
                Font = Enum.Font.Gotham,
                Parent = TabPage
            })
        end

        return Tab
    end

    -- Notification
    function self:Notify(msg, dur)
        dur = dur or 4
        local Notif = Create("Frame", {Size = UDim2.new(0,360,0,100), Position = UDim2.new(1,40,1,-150), BackgroundColor3 = CurrentTheme.Bg, Parent = ScreenGui})
        AddCorner(Notif, 16)
        AddStroke(Notif)

        Create("TextLabel", {Size = UDim2.new(1,-30,1,-20), Position = UDim2.new(0,15,0,10), BackgroundTransparency = 1, Text = msg, TextColor3 = CurrentTheme.Text, TextScaled = true, Font = Enum.Font.GothamSemibold, Parent = Notif})

        Tween(Notif, {Position = UDim2.new(1,-400,1,-150)}, 0.55)
        task.wait(dur)
        Tween(Notif, {Position = UDim2.new(1,40,1,-150)}, 0.55)
        task.wait(0.6)
        Notif:Destroy()
    end

    return self
end
