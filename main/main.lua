--// SoraUI FULL (Modern Roblox UI Library)

local SoraUI = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LP = Players.LocalPlayer

-- ICONS (custom names as requested)
local Icons = {
    star = "rbxassetid://10734952173",
    space = "rbxassetid://10734950309",
    player = "rbxassetid://10734943674",
    game = "rbxassetid://10734941499"
}

-- THEME
local Theme = {
    bg = Color3.fromRGB(18,18,18),
    sidebar = Color3.fromRGB(22,22,22),
    element = Color3.fromRGB(30,30,30),
    accent = Color3.fromRGB(0,200,255)
}

local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- DRAG SYSTEM
local function drag(frame, top)
    local dragging, offset

    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            offset = frame.Position - UDim2.new(0,i.Position.X,0,i.Position.Y)
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            frame.Position = UDim2.new(0,i.Position.X,0,i.Position.Y) + offset
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- NOTIFY
function SoraUI:Notify(title, text)
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "SoraNotify"

    local f = Instance.new("Frame", gui)
    f.Size = UDim2.new(0,250,0,60)
    f.Position = UDim2.new(1,-260,0,20)
    f.BackgroundColor3 = Theme.element

    Instance.new("UICorner", f)

    local t1 = Instance.new("TextLabel", f)
    t1.Text = title
    t1.Size = UDim2.new(1,0,0.5,0)
    t1.BackgroundTransparency = 1
    t1.TextColor3 = Color3.new(1,1,1)

    local t2 = Instance.new("TextLabel", f)
    t2.Text = text
    t2.Size = UDim2.new(1,0,0.5,0)
    t2.Position = UDim2.new(0,0,0.5,0)
    t2.BackgroundTransparency = 1
    t2.TextColor3 = Color3.fromRGB(180,180,180)

    tween(f,0.2,{Position = UDim2.new(1,-260,0,20)})

    task.wait(2.5)

    tween(f,0.2,{Position = UDim2.new(1,300,0,20)})
    task.wait(0.3)
    gui:Destroy()
end

-- WINDOW
function SoraUI:CreateWindow(title)

    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "SoraUI"

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0,620,0,380)
    main.Position = UDim2.new(0.5,-310,0.5,-190)
    main.BackgroundColor3 = Theme.bg

    Instance.new("UICorner", main)

    local top = Instance.new("Frame", main)
    top.Size = UDim2.new(1,0,0,40)
    top.BackgroundColor3 = Theme.sidebar

    Instance.new("UICorner", top)

    local titleLabel = Instance.new("TextLabel", top)
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1,0,1,0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.new(1,1,1)

    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0,160,1,-40)
    sidebar.Position = UDim2.new(0,0,0,40)
    sidebar.BackgroundColor3 = Theme.sidebar

    Instance.new("UICorner", sidebar)

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1,-160,1,-40)
    content.Position = UDim2.new(0,160,0,40)
    content.BackgroundTransparency = 1

    drag(main, top)

    local Window = {}

    -- TAB SYSTEM
    function Window:CreateTab(name, icon)

        local tabBtn = Instance.new("Frame", sidebar)
        tabBtn.Size = UDim2.new(1,-10,0,38)
        tabBtn.BackgroundColor3 = Theme.element

        Instance.new("UICorner", tabBtn)

        local img = Instance.new("ImageLabel", tabBtn)
        img.Size = UDim2.new(0,18,0,18)
        img.Position = UDim2.new(0,10,0.5,-9)
        img.BackgroundTransparency = 1
        img.Image = Icons[icon] or Icons.space

        local lbl = Instance.new("TextLabel", tabBtn)
        lbl.Text = name
        lbl.Position = UDim2.new(0,35,0,0)
        lbl.Size = UDim2.new(1,-35,1,0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", tabBtn)
        btn.Size = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text = ""

        local page = Instance.new("ScrollingFrame", content)
        page.Size = UDim2.new(1,0,1,0)
        page.Visible = false
        page.BackgroundTransparency = 1

        Instance.new("UIListLayout", page)

        btn.MouseButton1Click:Connect(function()

            for _,v in pairs(content:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end

            page.Visible = true
            tween(tabBtn,0.2,{BackgroundColor3 = Theme.accent})
        end)

        local Tab = {}

        -- BUTTON
        function Tab:Button(text, cb)
            local b = Instance.new("TextButton", page)
            b.Size = UDim2.new(1,-10,0,40)
            b.Text = text
            b.BackgroundColor3 = Theme.element
            b.TextColor3 = Color3.new(1,1,1)

            Instance.new("UICorner", b)

            b.MouseButton1Click:Connect(function()
                tween(b,0.1,{BackgroundColor3 = Theme.accent})
                task.wait(0.1)
                tween(b,0.1,{BackgroundColor3 = Theme.element})
                cb()
            end)
        end

        -- TOGGLE
        function Tab:Toggle(text, def, cb)
            local state = def

            local t = Instance.new("TextButton", page)
            t.Size = UDim2.new(1,-10,0,40)
            t.Text = text .. " : " .. tostring(state)
            t.BackgroundColor3 = Theme.element
            t.TextColor3 = Color3.new(1,1,1)

            Instance.new("UICorner", t)

            t.MouseButton1Click:Connect(function()
                state = not state
                t.Text = text .. " : " .. tostring(state)
                cb(state)
            end)
        end

        -- SLIDER
        function Tab:Slider(text, min, max, cb)
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1,-10,0,50)
            f.BackgroundColor3 = Theme.element

            Instance.new("UICorner", f)

            local bar = Instance.new("Frame", f)
            bar.Size = UDim2.new(1,-20,0,6)
            bar.Position = UDim2.new(0,10,0,30)
            bar.BackgroundColor3 = Color3.fromRGB(60,60,60)

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new(0,0,1,0)
            fill.BackgroundColor3 = Theme.accent

            local dragging = false

            bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)

            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)

            UserInputService.InputChanged:Connect(function(i)
                if dragging then
                    local p = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    fill.Size = UDim2.new(p,0,1,0)
                    cb(math.floor(min+(max-min)*p))
                end
            end)
        end

        return Tab
    end

    return Window
end

return SoraUI
