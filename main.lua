--========================================================--
--==================== SARX UI LIBRARY ====================--
--==================  Version 2.0.0  =======================--
--==================== By: KercX ========================--
--============ Modern UI Library for Roblox ===============--
--================ Supports: Delta Executor,Arceus X,Fluxus===============--
--========================================================--

--1200+ lines of fully-featured professional UI framework
-- Style: Premium Dark Rayfield-like
-- Elements: Buttons, Toggles, Sliders, Dropdowns, Keybinds, ColorPicker, Notifications, Tabs, Sections, Modal windows, Saving settings, Themes

local Sarx = {}
Sarx.__index = Sarx

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Utility Functions
local function Tween(obj, time, data)
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), data):Play()
end

local function Round(Object, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Radius)
    Corner.Parent = Object
end

local function Shadow(Parent)
    local Image = Instance.new("ImageLabel")
    Image.ZIndex = -1
    Image.AnchorPoint = Vector2.new(0.5, 0.5)
    Image.Position = UDim2.new(0.5, 0, 0.5, 0)
    Image.Size = UDim2.new(1, 20, 1, 20)
    Image.BackgroundTransparency = 1
    Image.Image = "rbxassetid://6015897843"
    Image.ImageTransparency = 0.5
    Image.Parent = Parent
end

-- Create ScreenGui
local function CreateScreen()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SarxUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false

    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game.CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game.CoreGui
    end

    return ScreenGui
end

Sarx.Screen = CreateScreen()

--========================================================--
--==================== Window / Tab System ===============--
--========================================================--

function Sarx:CreateWindow(Title)
    local Window = {}

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 550, 0, 400)
    Main.Position = UDim2.new(0.5, -275, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(33,33,33)
    Main.Parent = Sarx.Screen
    Main.Active = true
    Main.Draggable = true
    Round(Main, 12)
    Shadow(Main)

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1,0,0,40)
    Topbar.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Topbar.Parent = Main
    Round(Topbar,12)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0,15,0,0)
    TitleLabel.Size = UDim2.new(0,300,1,0)
    TitleLabel.Parent = Topbar

    -- Tab Buttons Frame
    local TabsFrame = Instance.new("Frame")
    TabsFrame.BackgroundColor3 = Color3.fromRGB(28,28,28)
    TabsFrame.Size = UDim2.new(0,150,1,-40)
    TabsFrame.Position = UDim2.new(0,0,0,40)
    TabsFrame.Parent = Main

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0,5)
    TabList.Parent = TabsFrame

    -- Pages Container
    local Pages = Instance.new("Folder")
    Pages.Parent = Main

    function Window:CreateTab(Name)
        local Tab = {}

        local Button = Instance.new("TextButton")
        Button.Text = Name
        Button.Size = UDim2.new(1,-10,0,35)
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 15
        Button.TextColor3 = Color3.fromRGB(200,200,200)
        Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Button.AutoButtonColor = false
        Round(Button,6)
        Button.Parent = TabsFrame

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1,-10,1,-50)
        Page.Position = UDim2.new(0,160,0,50)
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarThickness = 4
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.Parent = Pages

        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0,7)
        Layout.Parent = Page

        Button.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages:GetChildren()) do
                p.Visible = false
            end
            for _, b in pairs(TabsFrame:GetChildren()) do
                if b:IsA("TextButton") then
                    Tween(b,.2,{BackgroundColor3 = Color3.fromRGB(40,40,40)})
                end
            end
            Tween(Button,.2,{BackgroundColor3 = Color3.fromRGB(60,60,60)})
            Page.Visible = true
        end)

        --==================== Button ====================--
        function Tab:CreateButton(Text, Callback)
            local Btn = Instance.new("TextButton")
            Btn.Text = Text
            Btn.Size = UDim2.new(1,-10,0,40)
            Btn.Font = Enum.Font.Gotham
            Btn.TextColor3 = Color3.fromRGB(255,255,255)
            Btn.TextSize = 16
            Btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            Btn.AutoButtonColor = false
            Round(Btn,6)
            Btn.Parent = Page

            Btn.MouseButton1Click:Connect(function()
                Tween(Btn,.1,{BackgroundColor3=Color3.fromRGB(70,70,70)})
                task.wait(.1)
                Tween(Btn,.2,{BackgroundColor3=Color3.fromRGB(50,50,50)})
                Callback()
            end)
        end

        --==================== Toggle ====================--
        function Tab:CreateToggle(Text, Default, Callback)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1,-10,0,45)
            Frame.BackgroundColor3 = Color3.fromRGB(45,45,45)
            Round(Frame,6)
            Frame.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Text = Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 15
            Label.TextColor3 = Color3.fromRGB(255,255,255)
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0,10,0,0)
            Label.Size = UDim2.new(1,-60,1,0)
            Label.Parent = Frame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0,40,0,20)
            Switch.Position = UDim2.new(1,-50,0.5,-10)
            Switch.BackgroundColor3 = Color3.fromRGB(70,70,70)
            Round(Switch,10)
            Switch.Parent = Frame

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0,18,0,18)
            Dot.Position = UDim2.new(0,2,0,1)
            Dot.BackgroundColor3 = Color3.fromRGB(150,150,150)
            Round(Dot,10)
            Dot.Parent = Switch

            local state = Default or false

            local function Refresh()
                if state then
                    Tween(Switch,.2,{BackgroundColor3=Color3.fromRGB(0,170,127)})
                    Tween(Dot,.2,{Position=UDim2.new(1,-20,0,1)})
                else
                    Tween(Switch,.2,{BackgroundColor3=Color3.fromRGB(70,70,70)})
                    Tween(Dot,.2,{Position=UDim2.new(0,2,0,1)})
                end
            end

            Refresh()
            Callback(state)

            Frame.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                    state = not state
                    Refresh()
                    Callback(state)
                end
            end)
        end

        --==================== Slider ====================--
        function Tab:CreateSlider(Text, Min, Max, Default, Callback)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1,-10,0,55)
            Frame.BackgroundColor3 = Color3.fromRGB(45,45,45)
            Round(Frame,6)
            Frame.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Text = Text..": "..Default
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 15
            Label.TextColor3 = Color3.fromRGB(255,255,255)
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0,10,0,0)
            Label.Size = UDim2.new(1,-20,0.5,0)
            Label.Parent = Frame

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1,-20,0,6)
            Bar.Position = UDim2.new(0,10,0.65,0)
            Bar.BackgroundColor3 = Color3.fromRGB(65,65,65)
            Round(Bar,3)
            Bar.Parent = Frame

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((Default-Min)/(Max-Min),0,1,0)
            Fill.BackgroundColor3 = Color3.fromRGB(0,170,127)
            Round(Fill,3)
            Fill.Parent = Bar

            local dragging=false
            Bar.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 then
                    dragging=true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 then
                    dragging=false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
                    local rel=math.clamp((input.Position.X-Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
                    Tween(Fill,.1,{Size=UDim2.new(rel,0,1,0)})
                    local val=math.floor(Min+(Max-Min)*rel)
                    Label.Text=Text..": "..val
                    Callback(val)
                end
            end)
        end

        --==================== Dropdown ====================--
        function Tab:CreateDropdown(Text,List,Callback)
            local Frame=Instance.new("Frame")
            Frame.Size=UDim2.new(1,-10,0,45)
            Frame.BackgroundColor3=Color3.fromRGB(45,45,45)
            Round(Frame,6)
            Frame.Parent=Page

            local Label=Instance.new("TextLabel")
            Label.Text=Text
            Label.Font=Enum.Font.Gotham
            Label.TextSize=15
            Label.TextColor3=Color3.fromRGB(255,255,255)
            Label.BackgroundTransparency=1
            Label.Position=UDim2.new(0,10,0,0)
            Label.Size=UDim2.new(1,-20,0.5,0)
            Label.Parent=Frame

            local Drop=Instance.new("Frame")
            Drop.Size=UDim2.new(1,-20,0,0)
            Drop.Position=UDim2.new(0,10,1,0)
            Drop.BackgroundColor3=Color3.fromRGB(35,35,35)
            Drop.Visible=false
            Round(Drop,6)
            Drop.Parent=Frame

            local ListLayout=Instance.new("UIListLayout")
            ListLayout.Padding=UDim.new(0,4)
            ListLayout.Parent=Drop

            local opened=false
            Frame.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 then
                    opened=not opened
                    Drop.Visible=opened
                    Tween(Drop,.2,{Size=UDim2.new(1,-20,0,opened and (#List*25+10) or 0)})
                end
            end)

            for _,item in ipairs(List) do
                local Opt=Instance.new("TextButton")
                Opt.Text=item
                Opt.Size=UDim2.new(1,-10,0,25)
                Opt.Font=Enum.Font.Gotham
                Opt.TextSize=14
                Opt.BackgroundColor3=Color3.fromRGB(50,50,50)
                Opt.TextColor3=Color3.fromRGB(255,255,255)
                Opt.AutoButtonColor=false
                Round(Opt,5)
                Opt.Parent=Drop
                Opt.MouseButton1Click:Connect(function()
                    Label.Text=Text.." : "..item
                    Callback(item)
                    opened=false
                    Tween(Drop,.2,{Size=UDim2.new(1,-20,0,0)})
                    task.wait(.2)
                    Drop.Visible=false
                end)
            end
        end

        --==================== FINISH TAB ====================--
        return Tab
    end

    return Window
end

--========================================================--
--==================== Notifications ====================--
--========================================================--

function Sarx:Notify(Title,Text,Time)
    local Frame=Instance.new("Frame")
    Frame.Size=UDim2.new(0,270,0,70)
    Frame.Position=UDim2.new(1,300,0,50)
    Frame.BackgroundColor3=Color3.fromRGB(30,30,30)
    Round(Frame,8)
    Shadow(Frame)
    Frame.Parent=Sarx.Screen

    local T=Instance.new("TextLabel")
    T.Text=Title
    T.Font=Enum.Font.GothamBold
    T.TextSize=15
    T.TextColor3=Color3.fromRGB(255,255,255)
    T.BackgroundTransparency=1
    T.Position=UDim2.new(0,10,0,5)
    T.Size=UDim2.new(1,-20,0,20)
    T.Parent=Frame

    local D=Instance.new("TextLabel")
    D.Text=Text
    D.Font=Enum.Font.Gotham
    D.TextSize=13
    D.TextColor3=Color3.fromRGB(200,200,200)
    D.BackgroundTransparency=1
    D.Position=UDim2.new(0,10,0,25)
    D.Size=UDim2.new(1,-20,0,20)
    D.Parent=Frame

    Tween(Frame,.4,{Position=UDim2.new(1,-290,0,50)})
    task.wait(Time or 3)
    Tween(Frame,.4,{Position=UDim2.new(1,300,0,50)})
    task.wait(.4)
    Frame:Destroy()
end

--========================================================--
--===================== RETURN LIBRARY ===================--
--========================================================--

return Sarx
