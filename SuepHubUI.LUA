    --========================================================
-- SuepHub UI Library (Lightweight Custom UI System)
--========================================================

local SuepHub = {}

-- Create a UI Window
function SuepHub:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.IgnoreGuiInset = true

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 560, 0, 350)
    Main.Position = UDim2.new(0.5, -280, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(160, 160, 160)
    Stroke.Thickness = 1
    Stroke.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 32)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(230, 230, 230)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = Main

    -- Tab side panel
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(0, 140, 1, -32)
    TabFrame.Position = UDim2.new(0, 0, 0, 32)
    TabFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    TabFrame.Parent = Main

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabFrame

    -- Content panel
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -150, 1, -40)
    ContentFrame.Position = UDim2.new(0, 150, 0, 40)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ContentFrame.Parent = Main

    local tabs = {}

    local function SwitchTab(name)
        for tabName, tab in pairs(tabs) do
            tab.Content.Visible = (tabName == name)
        end
    end

    local WindowAPI = {}

    -- Create Tab
    function WindowAPI:CreateTab(name, icon)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -10, 0, 32)
        Button.Text = name
        Button.Parent = TabFrame
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Button.TextColor3 = Color3.fromRGB(240, 240, 240)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14
        Button.BorderSizePixel = 0

        local Content = Instance.new("Frame")
        Content.Size = UDim2.new(1, 0, 1, 0)
        Content.BackgroundTransparency = 1
        Content.Visible = false
        Content.Parent = ContentFrame

        tabs[name] = {Button = Button, Content = Content}

        Button.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)

        local TabAPI = {}

        -- Create Section
        function TabAPI:CreateSection(secName)
            local Sec = Instance.new("Frame")
            Sec.Size = UDim2.new(1, -20, 0, 30)
            Sec.BackgroundTransparency = 1
            Sec.Parent = Content

            local SecTitle = Instance.new("TextLabel")
            SecTitle.Size = UDim2.new(1, 0, 0, 22)
            SecTitle.Text = secName
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.TextSize = 14
            SecTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
            SecTitle.BackgroundTransparency = 1
            SecTitle.Parent = Sec

            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 6)
            layout.Parent = Content

            local SectionAPI = {}

            -- Create Button
            function SectionAPI:CreateButton(btnName, callback)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -20, 0, 28)
                Btn.Text = btnName
                Btn.Parent = Content
                Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 14
                Btn.BorderSizePixel = 0

                Btn.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)
            end

            -- Create Toggle
            function SectionAPI:CreateToggle(tName, default, callback)
                local Toggle = Instance.new("TextButton")
                Toggle.Size = UDim2.new(1, -20, 0, 28)
                Toggle.Text = tName .. ": " .. (default and "ON" or "OFF")
                Toggle.Parent = Content
                Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
                Toggle.Font = Enum.Font.Gotham
                Toggle.TextSize = 14
                Toggle.BorderSizePixel = 0

                local state = default

                Toggle.MouseButton1Click:Connect(function()
                    state = not state
                    Toggle.Text = tName .. ": " .. (state and "ON" or "OFF")
                    pcall(callback, state)
                end)
            end

            -- Create Slider
            function SectionAPI:CreateSlider(name, min, max, default, callback)
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -20, 0, 40)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Content

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 18)
                Label.Text = name .. ": " .. tostring(default)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 14
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.BackgroundTransparency = 1
                Label.Parent = Frame

                local Slider = Instance.new("TextButton")
                Slider.Size = UDim2.new(1, 0, 0, 20)
                Slider.Position = UDim2.new(0, 0, 0, 20)
                Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Slider.Text = ""
                Slider.Parent = Frame

                local value = default

                Slider.MouseButton1Click:Connect(function()
                    value = math.clamp(value + 1, min, max)
                    Label.Text = name .. ": " .. value
                    pcall(callback, value)
                end)
            end

            return SectionAPI
        end

        return TabAPI
    end

    -- set default first tab active
    task.delay(0.1, function()
        for n,v in pairs(tabs) do
            SwitchTab(n)
            break
        end
    end)

    return WindowAPI
end

return SuepHub
