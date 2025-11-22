--====================================================
--  SUEPHUB UI LIBRARY (BY CHATGPT)
--====================================================

local SuepHub = {}

-- buat window utama
function SuepHub:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 500, 0, 360)
    Main.Position = UDim2.new(0.5, -250, 0.5, -180)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local Top = Instance.new("TextLabel")
    Top.Size = UDim2.new(1, 0, 0, 40)
    Top.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Top.TextColor3 = Color3.fromRGB(255, 255, 255)
    Top.Font = Enum.Font.GothamBold
    Top.TextSize = 20
    Top.Text = title
    Top.Parent = Main

    local TabHolder = Instance.new("Frame")
    TabHolder.Size = UDim2.new(0, 150, 1, -40)
    TabHolder.Position = UDim2.new(0, 0, 0, 40)
    TabHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabHolder.Parent = Main

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabHolder
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -150, 1, -40)
    ContentHolder.Position = UDim2.new(0, 150, 0, 40)
    ContentHolder.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    ContentHolder.Parent = Main

    local Window = {
        Main = Main,
        TabHolder = TabHolder,
        Content = ContentHolder
    }

    setmetatable(Window, {__index = SuepHub})
    return Window
end

-- buat tab
function SuepHub:CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -10, 0, 35)
    TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Text = name
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 14
    TabButton.Parent = self.TabHolder

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 6
    Page.Visible = false
    Page.Parent = self.Content

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = Page
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 6)

    TabButton.MouseButton1Click:Connect(function()
        for _,v in pairs(self.Content:GetChildren()) do
            if v:IsA("ScrollingFrame") then
                v.Visible = false
            end
        end
        Page.Visible = true
    end)

    local Tab = {Page = Page}
    setmetatable(Tab, {__index = SuepHub})
    return Tab
end

-- buat section
function SuepHub:CreateSection(name)
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, -10, 0, 25)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextSize = 16
    SectionTitle.Text = name
    SectionTitle.Parent = self.Page

    local Section = {Parent = self.Page}
    setmetatable(Section, {__index = SuepHub})
    return Section
end

-- buat button
function SuepHub:CreateButton(name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = name
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.Parent = self.Parent

    Btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

-- buat toggle
function SuepHub:CreateToggle(name, default, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = name .. ": " .. (default and "ON" or "OFF")
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.Parent = self.Parent

    local state = default or false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = name .. ": " .. (state and "ON" or "OFF")
        pcall(callback, state)
    end)
end

-- buat slider sederhana
function SuepHub:CreateSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Frame.Parent = self.Parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Text = name .. ": " .. default
    Label.Parent = Frame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 20)
    Btn.Position = UDim2.new(0, 5, 0, 25)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.Text = "Change"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.Parent = Frame

    Btn.MouseButton1Click:Connect(function()
        local value = math.random(min, max)
        Label.Text = name .. ": " .. value
        pcall(callback, value)
    end)
end

return SuepHub
