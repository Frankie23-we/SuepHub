--====================================================
--  SUEPHUB UI LIBRARY
--  Dibuat khusus untuk kamu oleh ChatGPT
--====================================================

local SuepHub = {}

-- MakeWindow
function SuepHub:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 480, 0, 350)
    Main.Position = UDim2.new(0.5, -240, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Main.Active = true
    Main.Draggable = true

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Title.Text = title or "SuepHub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.Parent = Main

    local Window = {Main = Main}
    setmetatable(Window, {__index = SuepHub})

    return Window
end

-- CreateTab
function SuepHub:CreateTab(name, icon)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 120, 0, 32)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = name or "Tab"
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = self.Main

    local PageFrame = Instance.new("Frame")
    PageFrame.Size = UDim2.new(1, -130, 1, -50)
    PageFrame.Position = UDim2.new(0, 130, 0, 50)
    PageFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    PageFrame.Visible = false
    PageFrame.Parent = self.Main

    Button.MouseButton1Click:Connect(function()
        for _,v in pairs(self.Main:GetChildren()) do
            if v:IsA("Frame") and v ~= PageFrame and v.Name ~= "" then
                v.Visible = false
            end
        end
        PageFrame.Visible = true
    end)

    local Tab = {Page = PageFrame}
    setmetatable(Tab, {__index = SuepHub})
    return Tab
end

-- CreateSection
function SuepHub:CreateSection(name)
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, -10, 0, 25)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextSize = 14
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Text = "  " .. (name or "Section")
    SectionLabel.Parent = self.Page

    local Section = {Parent = self.Page}
    setmetatable(Section, {__index = SuepHub})
    return Section
end

-- CreateToggle
function SuepHub:CreateToggle(name, default, callback)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, -10, 0, 28)
    ToggleButton.Position = UDim2.new(0, 5, 0, 30)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Text = name .. ": " .. (default and "ON" or "OFF")
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.TextSize = 14
    ToggleButton.Parent = self.Parent

    local state = default or false

    ToggleButton.MouseButton1Click:Connect(function()
        state = not state
        ToggleButton.Text = name .. ": " .. (state and "ON" or "OFF")
        pcall(callback, state)
    end)
end

-- CreateButton
function SuepHub:CreateButton(name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 28)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = name
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.Parent = self.Parent

    Btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

-- CreateSlider
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

    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(1, -10, 0, 20)
    Slider.Position = UDim2.new(0, 5, 0, 25)
    Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Slider.Text = ""
    Slider.Parent = Frame

    local value = default

    Slider.MouseButton1Click:Connect(function()
        value = math.random(min, max) -- (sederhana, bisa diupgrade)
        Label.Text = name .. ": " .. value
        pcall(callback, value)
    end)
end

return SuepHub
