-- Mike's Hub | Arsenal Script
-- Combat, Visuals, Movement, Misc, Rage tabs + AC Bypass



local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local UserInputService = game:GetService("UserInputService")

local RunService = game:GetService("RunService")

local Lighting = game:GetService("Lighting")

local Workspace = game:GetService("Workspace")



local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Mouse = LocalPlayer:GetMouse()

local Camera = Workspace.CurrentCamera



pcall(function()

    RunService:UnbindFromRenderStep("MikesHubLoop")

end)



local oldGui = PlayerGui:FindFirstChild("MikesHub")

if oldGui then

    oldGui:Destroy()

end



local C = {

    bg1 = Color3.fromRGB(7, 7, 9),

    bg2 = Color3.fromRGB(11, 11, 14),

    bg3 = Color3.fromRGB(17, 17, 21),

    bg4 = Color3.fromRGB(23, 23, 28),

    white = Color3.fromRGB(255, 255, 255),

    g1 = Color3.fromRGB(185, 185, 192),

    g2 = Color3.fromRGB(88, 88, 98),

    g3 = Color3.fromRGB(50, 50, 58),

    g4 = Color3.fromRGB(27, 27, 33),

    blue = Color3.fromRGB(130, 185, 235),

    red = Color3.fromRGB(110, 28, 28),

    green = Color3.fromRGB(70, 200, 110),

    yellow = Color3.fromRGB(255, 210, 90),

}



local TF = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local TM = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)



local function tw(obj, props, info)

    TweenService:Create(obj, info or TF, props):Play()

end



local function rnd(obj, radius)

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0, radius or 6)

    corner.Parent = obj

end



local function keyboardBind(keyCode)

    return { Type = "Keyboard", KeyCode = keyCode }

end



local function mouseBind(userInputType)

    return { Type = "Mouse", UserInputType = userInputType }

end



local function isMouseButtonInput(input)

    if not input or not input.UserInputType then return false end

    return string.sub(input.UserInputType.Name, 1, 11) == "MouseButton"

end



local function inputToBind(input)

    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then

        return keyboardBind(input.KeyCode)

    end

    if isMouseButtonInput(input) then

        return mouseBind(input.UserInputType)

    end

    return nil

end



local function bindName(bind)

    if not bind then return "NONE" end

    if bind.Type == "Keyboard" and bind.KeyCode then return bind.KeyCode.Name end

    if bind.Type == "Mouse" and bind.UserInputType then return bind.UserInputType.Name end

    return "NONE"

end



local function bindMatchesInput(bind, input)

    if not bind or not input then return false end

    if bind.Type == "Keyboard" then

        return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == bind.KeyCode

    end

    if bind.Type == "Mouse" then

        return input.UserInputType == bind.UserInputType

    end

    return false

end





local TABS = {

    {

        name = "Combat",

        features = {

            { id = "aimbot", name = "Aimbot", desc = "Locks camera onto the nearest live player" },

            { id = "target_lock", name = "Target Lock", desc = "Keeps the same target locked" },

            { id = "wall_check", name = "Wall Check", desc = "Only targets visible players" },

            { id = "dead_check", name = "Dead Check", desc = "Stops aiming at dead bodies" },

        }

    },

    {

        name = "Visuals",

        features = {

            { id = "player_esp", name = "Player ESP", desc = "Highlights players through walls" },

            { id = "box_esp", name = "Box ESP", desc = "Shows a box marker over players" },

            { id = "name_esp", name = "Name Tags", desc = "Displays player names" },

            { id = "health_esp", name = "Health Bars", desc = "Shows player health" },

            { id = "dist_esp", name = "Distance ESP", desc = "Shows distance to players" },

            { id = "tool_esp", name = "Tool ESP", desc = "Highlights dropped tools" },

            { id = "crosshair", name = "Custom Crosshair", desc = "Shows a center crosshair" },

            { id = "fullbright", name = "Fullbright", desc = "Brightens the map" },

            { id = "no_fog", name = "Remove Fog", desc = "Clears map fog" },

            { id = "no_blur", name = "Remove Blur", desc = "Turns off blur effects" },

        }

    },

    {

        name = "Movement",

        features = {

            { id = "walkspeed", name = "Walkspeed Changer", desc = "Changes your walking speed" },

            { id = "jump_boost", name = "Jump Booster", desc = "Changes your jump height" },

            { id = "inf_jump", name = "Infinite Jump", desc = "Jump while in the air" },

            { id = "bhop", name = "Bunny Hop", desc = "Auto jumps while moving" },

            { id = "anti_void", name = "Anti-Void", desc = "Teleports back if you fall too low" },

            { id = "low_grav", name = "Low Gravity", desc = "Lowers workspace gravity" },

            { id = "click_tp", name = "Click Teleport", desc = "Teleport to your mouse click" },

        }

    },

    {

        name = "Misc",

        features = {

            { id = "ui_toggle", name = "UI Toggle", desc = "Shows or hides Mike's Hub" },

            { id = "fps_boost", name = "FPS Boost", desc = "Simplifies local visual effects" },

            { id = "hide_guis", name = "Hide Other GUIs", desc = "Hides other PlayerGui screens" },

        }

    },

    {

        name = "Rage (High Risk)",

        features = {

            { id = "rage_no_recoil", name = "No Recoil", desc = "Eliminates weapon kick completely" },

            { id = "rage_no_spread", name = "No Spread", desc = "Bullets go exactly where crosshair points" },

            { id = "rage_rapid_fire", name = "Rapid Fire", desc = "Override weapon fire rate (semi-auto becomes full-auto)" },

            { id = "rage_infinite_ammo", name = "Infinite Ammo", desc = "Never reload, never run out" },

            { id = "rage_auto_shoot", name = "Auto Shoot", desc = "Automatically fires when enemy is in crosshair" },

        }

    },

}



local Enabled = {}

local Pages = {}

local TabButtons = {}

local ToggleVisuals = {}

local KeybindButtons = {}

local ModeButtons = {}

local ActiveTab = 1

local WaitingForKeybind = nil



local CombatModes = {

    aimbot = "Toggle",

}





for _, tab in ipairs(TABS) do

    for _, feature in ipairs(tab.features) do

        Enabled[feature.id] = false

    end

end





local RageFOV = 280

local RageTargetPart = "Head"

local RageTargetPartOptions = {

    "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso",

    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",

    "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg",

    "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"

}



local FeatureKeybinds = {

    aimbot = nil,

    target_lock = nil,

    wall_check = nil,

    dead_check = nil,

    player_esp = nil,

    box_esp = nil,

    name_esp = nil,

    health_esp = nil,

    dist_esp = nil,

    tool_esp = nil,

    crosshair = nil,

    fullbright = nil,

    no_fog = nil,

    no_blur = nil,

    walkspeed = nil,

    jump_boost = nil,

    inf_jump = nil,

    bhop = nil,

    anti_void = nil,

    low_grav = nil,

    click_tp = nil,

    ui_toggle = keyboardBind(Enum.KeyCode.Insert),


    rage_no_recoil = nil,

    rage_no_spread = nil,

    rage_rapid_fire = nil,

    rage_infinite_ammo = nil,

    rage_auto_shoot = nil,

}



local AimPartName = "Head"

local AimPartOptions = {

    "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso",

    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",

    "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg",

    "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot",

    "Left Arm", "Right Arm", "Left Leg", "Right Leg",

}



local AimbotTarget = nil

local AimbotFOV = 280

local AimbotSmoothness = 10



local WalkspeedValue = 16

local JumpValue = 50

local DefaultWalkSpeed = 16

local DefaultJumpPower = 50

local DefaultGravity = Workspace.Gravity

local LastSafeCFrame = nil



local DeadCharacters = setmetatable({}, { __mode = "k" })

local ESPObjects = {}

local ToolESPObjects = {}



local DefaultLighting = {

    Brightness = Lighting.Brightness,

    ClockTime = Lighting.ClockTime,

    FogEnd = Lighting.FogEnd,

    FogStart = Lighting.FogStart,

    GlobalShadows = Lighting.GlobalShadows,

    Ambient = Lighting.Ambient,

    OutdoorAmbient = Lighting.OutdoorAmbient,

}



local Gui = Instance.new("ScreenGui")

Gui.Name = "MikesHub"

Gui.ResetOnSpawn = false

Gui.IgnoreGuiInset = true

Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Gui.DisplayOrder = 999999

Gui.Parent = PlayerGui



local FOVCircle = Instance.new("Frame")

FOVCircle.Name = "AimbotFOVCircle"

FOVCircle.BackgroundTransparency = 1

FOVCircle.BorderSizePixel = 0

FOVCircle.Visible = false

FOVCircle.ZIndex = 999998

FOVCircle.Parent = Gui



local FOVCorner = Instance.new("UICorner")

FOVCorner.CornerRadius = UDim.new(1, 0)

FOVCorner.Parent = FOVCircle



local FOVStroke = Instance.new("UIStroke")

FOVStroke.Thickness = 2

FOVStroke.Color = C.blue

FOVStroke.Transparency = 0.1

FOVStroke.Parent = FOVCircle



local Win = Instance.new("Frame")

Win.Name = "Window"

Win.Size = UDim2.new(0, 740, 0, 460)

Win.Position = UDim2.new(0.5, -370, 0.5, -230)

Win.BackgroundColor3 = C.bg1

Win.BorderSizePixel = 0

Win.Parent = Gui

rnd(Win, 9)



local WinStroke = Instance.new("UIStroke")

WinStroke.Color = C.g4

WinStroke.Thickness = 1

WinStroke.Parent = Win



local GlowLine = Instance.new("Frame")

GlowLine.Size = UDim2.new(0.55, 0, 0, 1)

GlowLine.Position = UDim2.new(0.225, 0, 0, 0)

GlowLine.BackgroundColor3 = C.blue

GlowLine.BackgroundTransparency = 0.4

GlowLine.BorderSizePixel = 0

GlowLine.ZIndex = 12

GlowLine.Parent = Win

rnd(GlowLine, 1)



local TopBar = Instance.new("Frame")

TopBar.Size = UDim2.new(1, 0, 0, 42)

TopBar.BackgroundColor3 = C.bg2

TopBar.BorderSizePixel = 0

TopBar.ZIndex = 5

TopBar.Parent = Win

rnd(TopBar, 9)



local TopFill = Instance.new("Frame")

TopFill.Size = UDim2.new(1, 0, 0, 9)

TopFill.Position = UDim2.new(0, 0, 1, -9)

TopFill.BackgroundColor3 = C.bg2

TopFill.BorderSizePixel = 0

TopFill.ZIndex = 5

TopFill.Parent = TopBar



local TopLine = Instance.new("Frame")

TopLine.Size = UDim2.new(1, 0, 0, 1)

TopLine.Position = UDim2.new(0, 0, 1, -1)

TopLine.BackgroundColor3 = C.g4

TopLine.BorderSizePixel = 0

TopLine.ZIndex = 6

TopLine.Parent = TopBar



local Mark = Instance.new("Frame")

Mark.Size = UDim2.new(0, 24, 0, 24)

Mark.Position = UDim2.new(0, 14, 0.5, -12)

Mark.BackgroundColor3 = C.blue

Mark.BackgroundTransparency = 0.25

Mark.BorderSizePixel = 0

Mark.ZIndex = 7

Mark.Parent = TopBar

rnd(Mark, 6)



local MarkLabel = Instance.new("TextLabel")

MarkLabel.Size = UDim2.new(1, 0, 1, 0)

MarkLabel.BackgroundTransparency = 1

MarkLabel.Text = "M"

MarkLabel.TextColor3 = C.white

MarkLabel.Font = Enum.Font.GothamBlack

MarkLabel.TextSize = 12

MarkLabel.ZIndex = 8

MarkLabel.Parent = Mark



local TitleLabel = Instance.new("TextLabel")

TitleLabel.Size = UDim2.new(0, 150, 1, 0)

TitleLabel.Position = UDim2.new(0, 44, 0, 0)

TitleLabel.BackgroundTransparency = 1

TitleLabel.Text = "Mike's Hub"

TitleLabel.TextColor3 = C.white

TitleLabel.Font = Enum.Font.GothamBold

TitleLabel.TextSize = 13

TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

TitleLabel.ZIndex = 6

TitleLabel.Parent = TopBar



local CountLabel = Instance.new("TextLabel")

CountLabel.Size = UDim2.new(0, 100, 1, 0)

CountLabel.Position = UDim2.new(0.5, -50, 0, 0)

CountLabel.BackgroundTransparency = 1

CountLabel.Text = "0 ACTIVE"

CountLabel.TextColor3 = C.g3

CountLabel.Font = Enum.Font.GothamSemibold

CountLabel.TextSize = 10

CountLabel.ZIndex = 6

CountLabel.Parent = TopBar



local MinButton = Instance.new("TextButton")

MinButton.Size = UDim2.new(0, 26, 0, 26)

MinButton.Position = UDim2.new(1, -62, 0.5, -13)

MinButton.BackgroundColor3 = C.g4

MinButton.Text = "-"

MinButton.TextColor3 = C.g2

MinButton.Font = Enum.Font.GothamBold

MinButton.TextSize = 14

MinButton.BorderSizePixel = 0

MinButton.ZIndex = 7

MinButton.Parent = TopBar

rnd(MinButton, 5)



local CloseButton = Instance.new("TextButton")

CloseButton.Size = UDim2.new(0, 26, 0, 26)

CloseButton.Position = UDim2.new(1, -32, 0.5, -13)

CloseButton.BackgroundColor3 = C.g4

CloseButton.Text = "X"

CloseButton.TextColor3 = C.g2

CloseButton.Font = Enum.Font.GothamBold

CloseButton.TextSize = 16

CloseButton.BorderSizePixel = 0

CloseButton.ZIndex = 7

CloseButton.Parent = TopBar

rnd(CloseButton, 5)



MinButton.MouseEnter:Connect(function()

    tw(MinButton, { BackgroundColor3 = C.bg4, TextColor3 = C.g1 })

end)

MinButton.MouseLeave:Connect(function()

    tw(MinButton, { BackgroundColor3 = C.g4, TextColor3 = C.g2 })

end)

CloseButton.MouseEnter:Connect(function()

    tw(CloseButton, { BackgroundColor3 = C.red, TextColor3 = C.white })

end)

CloseButton.MouseLeave:Connect(function()

    tw(CloseButton, { BackgroundColor3 = C.g4, TextColor3 = C.g2 })

end)

CloseButton.MouseButton1Click:Connect(function()

    Win.Visible = false

end)



local minimized = false

MinButton.MouseButton1Click:Connect(function()

    minimized = not minimized

    tw(Win, { Size = minimized and UDim2.new(0, 740, 0, 42) or UDim2.new(0, 740, 0, 460) }, TM)

end)



do

    local dragging = false

    local offset = Vector2.new()

    TopBar.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true

            offset = Vector2.new(input.Position.X - Win.AbsolutePosition.X, input.Position.Y - Win.AbsolutePosition.Y)

        end

    end)

    UserInputService.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = false

        end

    end)

    UserInputService.InputChanged:Connect(function(input)

        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

            Win.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)

        end

    end)

end



local TabBar = Instance.new("Frame")

TabBar.Size = UDim2.new(1, 0, 0, 36)

TabBar.Position = UDim2.new(0, 0, 0, 42)

TabBar.BackgroundColor3 = C.bg2

TabBar.BorderSizePixel = 0

TabBar.ZIndex = 5

TabBar.Parent = Win



local TabLine = Instance.new("Frame")

TabLine.Size = UDim2.new(1, 0, 0, 1)

TabLine.Position = UDim2.new(0, 0, 1, -1)

TabLine.BackgroundColor3 = C.g4

TabLine.BorderSizePixel = 0

TabLine.ZIndex = 6

TabLine.Parent = TabBar



local TAB_W = 740 / #TABS

local Indicator = Instance.new("Frame")

Indicator.Size = UDim2.new(0, TAB_W - 32, 0, 2)

Indicator.Position = UDim2.new(0, 16, 1, -2)

Indicator.BackgroundColor3 = C.blue

Indicator.BorderSizePixel = 0

Indicator.ZIndex = 7

Indicator.Parent = TabBar

rnd(Indicator, 1)



local Content = Instance.new("Frame")

Content.Size = UDim2.new(1, 0, 1, -78)

Content.Position = UDim2.new(0, 0, 0, 78)

Content.BackgroundColor3 = C.bg1

Content.BorderSizePixel = 0

Content.ClipsDescendants = true

Content.Parent = Win



local Crosshair = Instance.new("Frame")

Crosshair.Name = "CustomCrosshair"

Crosshair.Size = UDim2.fromOffset(8, 8)

Crosshair.Position = UDim2.new(0.5, -4, 0.5, -4)

Crosshair.BackgroundTransparency = 1

Crosshair.Visible = false

Crosshair.Parent = Gui



local CrosshairH = Instance.new("Frame")

CrosshairH.Size = UDim2.fromOffset(18, 2)

CrosshairH.Position = UDim2.fromOffset(-5, 3)

CrosshairH.BackgroundColor3 = C.blue

CrosshairH.BorderSizePixel = 0

CrosshairH.Parent = Crosshair



local CrosshairV = Instance.new("Frame")

CrosshairV.Size = UDim2.fromOffset(2, 18)

CrosshairV.Position = UDim2.fromOffset(3, -5)

CrosshairV.BackgroundColor3 = C.blue

CrosshairV.BorderSizePixel = 0

CrosshairV.Parent = Crosshair



-- Rage FOV Circle (red)

local RageFOVCircle = Instance.new("Frame")

RageFOVCircle.Name = "RageFOVCircle"

RageFOVCircle.BackgroundTransparency = 1

RageFOVCircle.BorderSizePixel = 0

RageFOVCircle.Visible = false

RageFOVCircle.ZIndex = 999998

RageFOVCircle.Parent = Gui



local RageFOVCorner = Instance.new("UICorner")

RageFOVCorner.CornerRadius = UDim.new(1, 0)

RageFOVCorner.Parent = RageFOVCircle



local RageFOVStroke = Instance.new("UIStroke")

RageFOVStroke.Thickness = 2

RageFOVStroke.Color = C.red

RageFOVStroke.Transparency = 0.3

RageFOVStroke.Parent = RageFOVCircle



local function isMouseOverWindow()

    local mouseLocation = UserInputService:GetMouseLocation()

    local pos = Win.AbsolutePosition

    local size = Win.AbsoluteSize

    return Win.Visible and mouseLocation.X >= pos.X and mouseLocation.X <= pos.X + size.X and mouseLocation.Y >= pos.Y and mouseLocation.Y <= pos.Y + size.Y

end



local function refreshCount()

    local active = 0

    for id, value in pairs(Enabled) do

        if value and id ~= "ui_toggle" and not id:find("rage_") then

            active = active + 1

        end

    end

    CountLabel.Text = active .. " ACTIVE"

    tw(CountLabel, { TextColor3 = active > 0 and C.g1 or C.g3 })

end



local function updateKeybindButton(id)

    local button = KeybindButtons[id]

    if button then

        button.Text = "KEY: " .. bindName(FeatureKeybinds[id])

        button.BackgroundColor3 = C.g4

        button.TextColor3 = C.g1

    end

end



local function updateModeButton(id)

    local button = ModeButtons[id]

    if button then

        button.Text = string.upper(CombatModes[id] or "Toggle")

        button.BackgroundColor3 = CombatModes[id] == "Hold" and C.blue or C.g4

        button.TextColor3 = CombatModes[id] == "Hold" and C.white or C.g1

    end

end



local function updateAllKeybindButtons()

    for id in pairs(KeybindButtons) do

        updateKeybindButton(id)

    end

    for id in pairs(ModeButtons) do

        updateModeButton(id)

    end

end



local function setToggleVisual(id, on)

    local data = ToggleVisuals[id]

    if not data then return end

    if on then

        tw(data.Track, { BackgroundColor3 = C.blue })

        tw(data.Thumb, { BackgroundColor3 = C.bg1, Position = UDim2.new(1, -16, 0.5, -6) })

        tw(data.Accent, { BackgroundTransparency = 0 })

        tw(data.NameLabel, { TextColor3 = C.white })

    else

        tw(data.Track, { BackgroundColor3 = C.g4 })

        tw(data.Thumb, { BackgroundColor3 = C.g3, Position = UDim2.new(0, 3, 0.5, -6) })

        tw(data.Accent, { BackgroundTransparency = 1 })

        tw(data.NameLabel, { TextColor3 = C.g1 })

    end

end



local function setEnabled(id, value)

    Enabled[id] = value

    setToggleVisual(id, value)

    refreshCount()

    if id == "aimbot" and not value then

        AimbotTarget = nil

    end

    if id == "dead_check" then

        AimbotTarget = nil

    end

end



local function getLocalHumanoid()

    local character = LocalPlayer.Character

    if not character then return nil end

    return character:FindFirstChildOfClass("Humanoid")

end



local function markDead(character)

    if not character then return end

    DeadCharacters[character] = true

    if AimbotTarget and AimbotTarget:IsDescendantOf(character) then

        AimbotTarget = nil

    end

end



local function watchCharacter(player, character)

    if not character then return end

    DeadCharacters[character] = nil

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid then

        humanoid = character:WaitForChild("Humanoid", 5)

    end

    if not humanoid then return end

    if humanoid.Health <= 0 then

        markDead(character)

    end

    humanoid.Died:Connect(function()

        markDead(character)

    end)

    humanoid.HealthChanged:Connect(function(health)

        if health <= 0 then

            markDead(character)

        end

    end)

    humanoid.StateChanged:Connect(function(_, newState)

        if newState == Enum.HumanoidStateType.Dead then

            markDead(character)

        end

    end)

end



local function watchPlayer(player)

    if player.Character then

        watchCharacter(player, player.Character)

    end

    player.CharacterAdded:Connect(function(character)

        task.wait(0.1)

        watchCharacter(player, character)

    end)

    player.CharacterRemoving:Connect(function(character)

        markDead(character)

    end)

end



for _, player in ipairs(Players:GetPlayers()) do

    watchPlayer(player)

end

Players.PlayerAdded:Connect(watchPlayer)



local function isDeadMarked(character, humanoid)

    if DeadCharacters[character] then return true end

    if character:GetAttribute("Dead") == true or character:GetAttribute("IsDead") == true or character:GetAttribute("Eliminated") == true then

        return true

    end

    if humanoid:GetAttribute("Dead") == true or humanoid:GetAttribute("IsDead") == true or humanoid:GetAttribute("Eliminated") == true then

        return true

    end

    return false

end



local function isLivePlayerCharacter(player)

    if not player then return false end

    local character = player.Character

    if not character or not character.Parent then return false end

    if player == LocalPlayer then return false end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid then return false end

    if Enabled.dead_check then

        if isDeadMarked(character, humanoid) then return false end

        if humanoid.Health <= 0 then return false end

        if humanoid:GetState() == Enum.HumanoidStateType.Dead then return false end

    end

    return true

end



local function captureDefaults()

    local humanoid = getLocalHumanoid()

    if humanoid then

        if humanoid.WalkSpeed > 0 then

            DefaultWalkSpeed = humanoid.WalkSpeed

            WalkspeedValue = math.clamp(math.floor(humanoid.WalkSpeed), 1, 100)

        end

        if humanoid.JumpPower > 0 then

            DefaultJumpPower = humanoid.JumpPower

            JumpValue = math.clamp(math.floor(humanoid.JumpPower / 2), 1, 100)

        end

    end

    if DefaultWalkSpeed <= 0 then DefaultWalkSpeed = 16 end

    if DefaultJumpPower <= 0 then DefaultJumpPower = 50 end

end

captureDefaults()



local function applyMovement()

    local humanoid = getLocalHumanoid()

    if humanoid then

        if Enabled.walkspeed then

            humanoid.WalkSpeed = math.clamp(WalkspeedValue, 1, 100)

        else

            if DefaultWalkSpeed > 0 then

                humanoid.WalkSpeed = DefaultWalkSpeed

            end

        end

        pcall(function()

            humanoid.UseJumpPower = true

        end)

        if Enabled.jump_boost then

            humanoid.JumpPower = math.clamp(JumpValue, 1, 100) * 2

        else

            if DefaultJumpPower > 0 then

                humanoid.JumpPower = DefaultJumpPower

            end

        end

    end

    if Enabled.low_grav then

        Workspace.Gravity = 65

    else

        Workspace.Gravity = DefaultGravity

    end

end



local function applyLighting()

    if Enabled.fullbright then

        Lighting.Brightness = 3

        Lighting.ClockTime = 14

        Lighting.GlobalShadows = false

        Lighting.Ambient = Color3.fromRGB(255, 255, 255)

        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)

    else

        Lighting.Brightness = DefaultLighting.Brightness

        Lighting.ClockTime = DefaultLighting.ClockTime

        Lighting.GlobalShadows = DefaultLighting.GlobalShadows

        Lighting.Ambient = DefaultLighting.Ambient

        Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient

    end

    if Enabled.no_fog then

        Lighting.FogEnd = 100000

        Lighting.FogStart = 0

    else

        Lighting.FogEnd = DefaultLighting.FogEnd

        Lighting.FogStart = DefaultLighting.FogStart

    end

end



local function applyBlur()

    for _, object in ipairs(Lighting:GetChildren()) do

        if object:IsA("BlurEffect") then

            object.Enabled = not Enabled.no_blur

        end

    end

end



local _hideGuisWasOn = false

local function applyHideGuis()

    if Enabled.hide_guis then

        for _, screenGui in ipairs(PlayerGui:GetChildren()) do

            if screenGui:IsA("ScreenGui") and screenGui ~= Gui then

                screenGui.Enabled = false

            end

        end

        _hideGuisWasOn = true

    elseif _hideGuisWasOn then

        for _, screenGui in ipairs(PlayerGui:GetChildren()) do

            if screenGui:IsA("ScreenGui") and screenGui ~= Gui then

                screenGui.Enabled = true

            end

        end

        _hideGuisWasOn = false

    end

end



local function fpsBoost()

    if not Enabled.fps_boost then return end

    for _, object in ipairs(Workspace:GetDescendants()) do

        if object:IsA("BasePart") then

            object.Material = Enum.Material.SmoothPlastic

            object.Reflectance = 0

        elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then

            object.Enabled = false

        end

    end

end



local function getAimPart(character)

    if not character then return nil end

    local selectedPart = character:FindFirstChild(AimPartName)

    if selectedPart and selectedPart:IsA("BasePart") then

        return selectedPart

    end

    local fallbackParts = { "HumanoidRootPart", "Head", "UpperTorso", "LowerTorso", "Torso" }

    for _, partName in ipairs(fallbackParts) do

        local part = character:FindFirstChild(partName)

        if part and part:IsA("BasePart") then

            return part

        end

    end

    return nil

end



local function canSeeTarget(part)

    if not Enabled.wall_check then return true end

    if not part or not Camera then return false end

    local origin = Camera.CFrame.Position

    local direction = part.Position - origin

    local params = RaycastParams.new()

    params.FilterType = Enum.RaycastFilterType.Exclude

    params.IgnoreWater = true

    local ignoreList = {}

    if LocalPlayer.Character then

        table.insert(ignoreList, LocalPlayer.Character)

    end

    params.FilterDescendantsInstances = ignoreList

    local result = Workspace:Raycast(origin, direction, params)

    if not result then return true end

    return result.Instance and result.Instance:IsDescendantOf(part.Parent)

end



local function canTargetPlayer(player)

    if not isLivePlayerCharacter(player) then return false end

    local character = player.Character

    local part = getAimPart(character)

    if not part then return false end

    local screenPosition, onScreen = Camera:WorldToViewportPoint(part.Position)

    if not onScreen or screenPosition.Z <= 0 then return false end

    if not canSeeTarget(part) then return false end

    local mouseLocation = UserInputService:GetMouseLocation()

    local mousePosition = Vector2.new(mouseLocation.X, mouseLocation.Y)

    local targetPosition = Vector2.new(screenPosition.X, screenPosition.Y)

    return (targetPosition - mousePosition).Magnitude <= AimbotFOV

end



local function getClosestTarget()

    local closestPart = nil

    local closestDistance = math.huge

    local mouseLocation = UserInputService:GetMouseLocation()

    local mousePosition = Vector2.new(mouseLocation.X, mouseLocation.Y)

    for _, player in ipairs(Players:GetPlayers()) do

        if canTargetPlayer(player) then

            local part = getAimPart(player.Character)

            if part then

                local screenPosition = Camera:WorldToViewportPoint(part.Position)

                local targetPosition = Vector2.new(screenPosition.X, screenPosition.Y)

                local distance = (targetPosition - mousePosition).Magnitude

                if distance < closestDistance then

                    closestDistance = distance

                    closestPart = part

                end

            end

        end

    end

    return closestPart

end



local function getAimAlpha()

    local smoothness = math.clamp(AimbotSmoothness, 1, 100)

    local alpha = 3 / smoothness

    return math.clamp(alpha, 0.02, 1)

end



local function updateFOVCircle()

    local mouseLocation = UserInputService:GetMouseLocation()

    FOVCircle.Visible = Enabled.aimbot == true

    FOVCircle.Size = UDim2.fromOffset(AimbotFOV * 2, AimbotFOV * 2)

    FOVCircle.Position = UDim2.fromOffset(mouseLocation.X - AimbotFOV, mouseLocation.Y - AimbotFOV)

end



local function updateRageFOVCircle()

    local mouseLocation = UserInputService:GetMouseLocation()

    RageFOVCircle.Visible = false

    RageFOVCircle.Size = UDim2.fromOffset(RageFOV * 2, RageFOV * 2)

    RageFOVCircle.Position = UDim2.fromOffset(mouseLocation.X - RageFOV, mouseLocation.Y - RageFOV)

end



local function updateAimbot()

    if not Enabled.aimbot then

        AimbotTarget = nil

        return

    end

    if AimbotTarget then

        local targetCharacter = AimbotTarget:FindFirstAncestorOfClass("Model")

        local targetPlayer = targetCharacter and Players:GetPlayerFromCharacter(targetCharacter)

        if not targetPlayer or not canTargetPlayer(targetPlayer) then

            AimbotTarget = nil

        end

    end

    if Enabled.target_lock then

        if not AimbotTarget then

            AimbotTarget = getClosestTarget()

        end

    else

        AimbotTarget = getClosestTarget()

    end

    if AimbotTarget and Camera then

        local targetCharacter = AimbotTarget:FindFirstAncestorOfClass("Model")

        local targetPlayer = targetCharacter and Players:GetPlayerFromCharacter(targetCharacter)

        if targetPlayer and canTargetPlayer(targetPlayer) then

            local cameraPosition = Camera.CFrame.Position

            local targetCFrame = CFrame.lookAt(cameraPosition, AimbotTarget.Position)

            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, getAimAlpha())

        else

            AimbotTarget = nil

        end

    end

end



local function removeESP(player)

    local esp = ESPObjects[player]

    if esp then

        if esp.Highlight then esp.Highlight:Destroy() end

        if esp.Billboard then esp.Billboard:Destroy() end

        ESPObjects[player] = nil

    end

end



local function updateESPForPlayer(player)

    if player == LocalPlayer then return end

    if not isLivePlayerCharacter(player) then

        removeESP(player)

        return

    end

    local character = player.Character

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    local root = character:FindFirstChild("HumanoidRootPart")

    local head = character:FindFirstChild("Head")

    if not humanoid or not root then

        removeESP(player)

        return

    end

    local esp = ESPObjects[player]

    if not esp then

        local highlight = Instance.new("Highlight")

        highlight.Name = "MikesHubPlayerESP"

        highlight.Adornee = character

        highlight.FillColor = C.blue

        highlight.OutlineColor = C.white

        highlight.FillTransparency = 0.65

        highlight.OutlineTransparency = 0

        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

        highlight.Parent = character

        local billboard = Instance.new("BillboardGui")

        billboard.Name = "MikesHubInfo"

        billboard.Adornee = head or root

        billboard.Size = UDim2.fromOffset(190, 70)

        billboard.StudsOffset = Vector3.new(0, 3.25, 0)

        billboard.AlwaysOnTop = true

        billboard.MaxDistance = 10000

        billboard.Parent = Gui

        local info = Instance.new("TextLabel")

        info.Name = "Info"

        info.Size = UDim2.new(1, 0, 0, 45)

        info.BackgroundTransparency = 1

        info.TextColor3 = C.white

        info.TextStrokeTransparency = 0.25

        info.TextSize = 12

        info.Font = Enum.Font.GothamBold

        info.Parent = billboard

        local healthBack = Instance.new("Frame")

        healthBack.Name = "HealthBack"

        healthBack.Size = UDim2.fromOffset(100, 5)

        healthBack.Position = UDim2.new(0.5, -50, 0, 45)

        healthBack.BackgroundColor3 = C.g4

        healthBack.BorderSizePixel = 0

        healthBack.Parent = billboard

        rnd(healthBack, 3)

        local healthFill = Instance.new("Frame")

        healthFill.Name = "HealthFill"

        healthFill.Size = UDim2.new(1, 0, 1, 0)

        healthFill.BackgroundColor3 = C.green

        healthFill.BorderSizePixel = 0

        healthFill.Parent = healthBack

        rnd(healthFill, 3)

        esp = { Highlight = highlight, Billboard = billboard, Info = info, HealthBack = healthBack, HealthFill = healthFill }

        ESPObjects[player] = esp

    end

    esp.Highlight.Adornee = character

    esp.Highlight.Enabled = Enabled.player_esp or Enabled.box_esp

    esp.Billboard.Adornee = head or root

    esp.Billboard.Enabled = Enabled.name_esp or Enabled.health_esp or Enabled.dist_esp or Enabled.box_esp

    local distance = 0

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

        distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)

    end

    local textParts = {}

    if Enabled.name_esp then table.insert(textParts, player.Name) end

    if Enabled.dist_esp then table.insert(textParts, tostring(distance) .. " studs") end

    if Enabled.box_esp then table.insert(textParts, "[ BOX ]") end

    esp.Info.Text = table.concat(textParts, "\n")

    local healthPercent = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)

    esp.HealthBack.Visible = Enabled.health_esp

    esp.HealthFill.Size = UDim2.new(healthPercent, 0, 1, 0)

end



local function updateESP()

    if not (Enabled.player_esp or Enabled.box_esp or Enabled.name_esp or Enabled.health_esp or Enabled.dist_esp) then

        for player in pairs(ESPObjects) do

            removeESP(player)

        end

        return

    end

    for _, player in ipairs(Players:GetPlayers()) do

        updateESPForPlayer(player)

    end

end



local function clearToolESP()

    for tool, highlight in pairs(ToolESPObjects) do

        if highlight then highlight:Destroy() end

        ToolESPObjects[tool] = nil

    end

end



local function updateToolESP()

    if not Enabled.tool_esp then

        clearToolESP()

        return

    end

    for _, object in ipairs(Workspace:GetDescendants()) do

        if object:IsA("Tool") and not ToolESPObjects[object] then

            local handle = object:FindFirstChildWhichIsA("BasePart")

            if handle then

                local highlight = Instance.new("Highlight")

                highlight.Name = "MikesHubToolESP"

                highlight.Adornee = object

                highlight.FillColor = C.yellow

                highlight.OutlineColor = C.white

                highlight.FillTransparency = 0.55

                highlight.OutlineTransparency = 0

                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                highlight.Parent = object

                ToolESPObjects[object] = highlight

            end

        end

    end

    for tool, highlight in pairs(ToolESPObjects) do

        if not tool.Parent then

            highlight:Destroy()

            ToolESPObjects[tool] = nil

        end

    end

end



local function antiVoid()

    local character = LocalPlayer.Character

    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then return end

    if root.Position.Y > 5 then

        LastSafeCFrame = root.CFrame

    end

    if Enabled.anti_void and root.Position.Y < -50 then

        root.CFrame = LastSafeCFrame or CFrame.new(0, 50, 0)

    end

end



local function bunnyHop()

    if not Enabled.bhop then return end

    local humanoid = getLocalHumanoid()

    if humanoid and humanoid.MoveDirection.Magnitude > 0 and humanoid.FloorMaterial ~= Enum.Material.Air then

        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

    end

end



UserInputService.JumpRequest:Connect(function()

    if Enabled.inf_jump then

        local humanoid = getLocalHumanoid()

        if humanoid then

            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

        end

    end

end)



Mouse.Button1Down:Connect(function()

    if not Enabled.click_tp then return end

    local character = LocalPlayer.Character

    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root and Mouse.Hit then

        root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))

    end

end)



local function toggleFeature(id)

    if id == "ui_toggle" then

        Win.Visible = not Win.Visible

        return

    end

    setEnabled(id, not Enabled[id])

    if id == "fps_boost" and Enabled.fps_boost then

        fpsBoost()

    end

    if id == "hide_guis" then

        applyHideGuis()

    end

end



local function setHoldFeature(id, state)

    if id ~= "aimbot" then return end

    if Enabled[id] ~= state then

        setEnabled(id, state)

    end

end



local function toggleCombatMode(id)

    if id ~= "aimbot" then return end

    if CombatModes.aimbot == "Toggle" then

        CombatModes.aimbot = "Hold"

    else

        CombatModes.aimbot = "Toggle"

    end

    updateModeButton("aimbot")

end



local function startKeybindChange(id)

    WaitingForKeybind = id

    local button = KeybindButtons[id]

    if button then

        button.Text = "PRESS KEY/MOUSE"

        button.BackgroundColor3 = C.blue

        button.TextColor3 = C.white

    end

end



local function buildRow(page, feature, yPos, tabName)

    local hasModeButton = feature.id == "aimbot"

    local Row = Instance.new("Frame")

    Row.Size = UDim2.new(1, -20, 0, 44)

    Row.Position = UDim2.new(0, 10, 0, yPos)

    Row.BackgroundColor3 = C.bg3

    Row.BorderSizePixel = 0

    Row.Parent = page

    rnd(Row, 7)

    local RowStroke = Instance.new("UIStroke")

    RowStroke.Color = C.g4

    RowStroke.Thickness = 1

    RowStroke.Parent = Row

    local Accent = Instance.new("Frame")

    Accent.Size = UDim2.new(0, 2, 0, 22)

    Accent.Position = UDim2.new(0, 0, 0.5, -11)

    Accent.BackgroundColor3 = C.blue

    Accent.BackgroundTransparency = 1

    Accent.BorderSizePixel = 0

    Accent.Parent = Row

    rnd(Accent, 1)

    local NameLabel = Instance.new("TextLabel")

    NameLabel.Size = hasModeButton and UDim2.new(1, -280, 0, 17) or UDim2.new(1, -190, 0, 17)

    NameLabel.Position = UDim2.new(0, 16, 0, 8)

    NameLabel.BackgroundTransparency = 1

    NameLabel.Text = feature.name

    NameLabel.TextColor3 = C.g1

    NameLabel.Font = Enum.Font.GothamSemibold

    NameLabel.TextSize = 12

    NameLabel.TextXAlignment = Enum.TextXAlignment.Left

    NameLabel.Parent = Row

    local DescLabel = Instance.new("TextLabel")

    DescLabel.Size = hasModeButton and UDim2.new(1, -280, 0, 14) or UDim2.new(1, -190, 0, 14)

    DescLabel.Position = UDim2.new(0, 16, 0, 26)

    DescLabel.BackgroundTransparency = 1

    DescLabel.Text = feature.desc

    DescLabel.TextColor3 = C.g3

    DescLabel.Font = Enum.Font.Gotham

    DescLabel.TextSize = 10

    DescLabel.TextXAlignment = Enum.TextXAlignment.Left

    DescLabel.Parent = Row

    if hasModeButton then

        local ModeButton = Instance.new("TextButton")

        ModeButton.Size = UDim2.new(0, 82, 0, 22)

        ModeButton.Position = UDim2.new(1, -235, 0.5, -11)

        ModeButton.BackgroundColor3 = C.g4

        ModeButton.Text = string.upper(CombatModes.aimbot)

        ModeButton.TextColor3 = C.g1

        ModeButton.Font = Enum.Font.GothamSemibold

        ModeButton.TextSize = 9

        ModeButton.BorderSizePixel = 0

        ModeButton.Parent = Row

        rnd(ModeButton, 6)

        ModeButtons[feature.id] = ModeButton

        ModeButton.MouseButton1Click:Connect(function()

            toggleCombatMode(feature.id)

        end)

    end

    local KeyButton = Instance.new("TextButton")

    KeyButton.Size = UDim2.new(0, 82, 0, 22)

    KeyButton.Position = UDim2.new(1, -145, 0.5, -11)

    KeyButton.BackgroundColor3 = C.g4

    KeyButton.Text = "KEY: " .. bindName(FeatureKeybinds[feature.id])

    KeyButton.TextColor3 = C.g1

    KeyButton.Font = Enum.Font.GothamSemibold

    KeyButton.TextSize = 9

    KeyButton.BorderSizePixel = 0

    KeyButton.Parent = Row

    rnd(KeyButton, 6)

    KeybindButtons[feature.id] = KeyButton

    KeyButton.MouseButton1Click:Connect(function()

        startKeybindChange(feature.id)

    end)

    local Track = Instance.new("Frame")

    Track.Size = UDim2.new(0, 36, 0, 19)

    Track.Position = UDim2.new(1, -50, 0.5, -9)

    Track.BackgroundColor3 = C.g4

    Track.BorderSizePixel = 0

    Track.Parent = Row

    rnd(Track, 10)

    local Thumb = Instance.new("Frame")

    Thumb.Size = UDim2.new(0, 13, 0, 13)

    Thumb.Position = UDim2.new(0, 3, 0.5, -6)

    Thumb.BackgroundColor3 = C.g3

    Thumb.BorderSizePixel = 0

    Thumb.Parent = Track

    rnd(Thumb, 7)

    local ClickButton = Instance.new("TextButton")

    ClickButton.Size = hasModeButton and UDim2.new(1, -245, 1, 0) or UDim2.new(1, -155, 1, 0)

    ClickButton.BackgroundTransparency = 1

    ClickButton.Text = ""

    ClickButton.ZIndex = 10

    ClickButton.Parent = Row

    ToggleVisuals[feature.id] = { Track = Track, Thumb = Thumb, Accent = Accent, NameLabel = NameLabel }

    ClickButton.MouseEnter:Connect(function()

        tw(Row, { BackgroundColor3 = C.bg4 })

    end)

    ClickButton.MouseLeave:Connect(function()

        tw(Row, { BackgroundColor3 = C.bg3 })

    end)

    ClickButton.MouseButton1Click:Connect(function()

        toggleFeature(feature.id)

    end)

end



local function buildSlider(page, label, y, min, max, default, callback)

    local Holder = Instance.new("Frame")

    Holder.Size = UDim2.new(1, -20, 0, 50)

    Holder.Position = UDim2.new(0, 10, 0, y)

    Holder.BackgroundColor3 = C.bg3

    Holder.BorderSizePixel = 0

    Holder.Parent = page

    rnd(Holder, 7)

    local HolderStroke = Instance.new("UIStroke")

    HolderStroke.Color = C.g4

    HolderStroke.Thickness = 1

    HolderStroke.Parent = Holder

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(1, -20, 0, 18)

    Label.Position = UDim2.new(0, 10, 0, 6)

    Label.BackgroundTransparency = 1

    Label.Text = label .. ": " .. tostring(default)

    Label.TextColor3 = C.g1

    Label.Font = Enum.Font.GothamSemibold

    Label.TextSize = 12

    Label.TextXAlignment = Enum.TextXAlignment.Left

    Label.Parent = Holder

    local Bar = Instance.new("Frame")

    Bar.Size = UDim2.new(1, -20, 0, 8)

    Bar.Position = UDim2.new(0, 10, 0, 32)

    Bar.BackgroundColor3 = C.g4

    Bar.BorderSizePixel = 0

    Bar.Parent = Holder

    rnd(Bar, 8)

    local Fill = Instance.new("Frame")

    Fill.Size = UDim2.fromScale((default - min) / (max - min), 1)

    Fill.BackgroundColor3 = C.blue

    Fill.BorderSizePixel = 0

    Fill.Parent = Bar

    rnd(Fill, 8)

    local dragging = false

    local function setValue(x)

        local percent = math.clamp((x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

        local value = math.floor(min + ((max - min) * percent))

        Fill.Size = UDim2.fromScale(percent, 1)

        Label.Text = label .. ": " .. tostring(value)

        callback(value)

    end

    Bar.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true

            setValue(input.Position.X)

        end

    end)

    UserInputService.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = false

        end

    end)

    UserInputService.InputChanged:Connect(function(input)

        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

            setValue(input.Position.X)

        end

    end)

end



local function buildDropdown(page, label, y, options, default, callback)

    local Holder = Instance.new("Frame")

    Holder.Size = UDim2.new(1, -20, 0, 50)

    Holder.Position = UDim2.new(0, 10, 0, y)

    Holder.BackgroundColor3 = C.bg3

    Holder.BorderSizePixel = 0

    Holder.ZIndex = 20

    Holder.Parent = page

    rnd(Holder, 7)

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(0.45, 0, 1, 0)

    Label.Position = UDim2.new(0, 10, 0, 0)

    Label.BackgroundTransparency = 1

    Label.Text = label

    Label.TextColor3 = C.g1

    Label.Font = Enum.Font.GothamSemibold

    Label.TextSize = 12

    Label.TextXAlignment = Enum.TextXAlignment.Left

    Label.ZIndex = 21

    Label.Parent = Holder

    local DropButton = Instance.new("TextButton")

    DropButton.Size = UDim2.new(0, 210, 0, 30)

    DropButton.Position = UDim2.new(1, -220, 0.5, -15)

    DropButton.BackgroundColor3 = C.g4

    DropButton.Text = default .. " v"

    DropButton.TextColor3 = C.white

    DropButton.Font = Enum.Font.GothamSemibold

    DropButton.TextSize = 11

    DropButton.BorderSizePixel = 0

    DropButton.ZIndex = 21

    DropButton.Parent = Holder

    rnd(DropButton, 6)

    local OptionsFrame = Instance.new("ScrollingFrame")

    OptionsFrame.Size = UDim2.new(1, -20, 0, 150)

    OptionsFrame.Position = UDim2.new(0, 10, 0, y + 52)

    OptionsFrame.BackgroundColor3 = C.bg2

    OptionsFrame.BorderSizePixel = 0

    OptionsFrame.Visible = false

    OptionsFrame.ScrollBarThickness = 3

    OptionsFrame.ScrollBarImageColor3 = C.g4

    OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 28)

    OptionsFrame.ZIndex = 50

    OptionsFrame.Parent = page

    rnd(OptionsFrame, 7)

    for index, optionName in ipairs(options) do

        local Option = Instance.new("TextButton")

        Option.Size = UDim2.new(1, -6, 0, 26)

        Option.Position = UDim2.new(0, 3, 0, (index - 1) * 28)

        Option.BackgroundColor3 = C.bg3

        Option.Text = optionName

        Option.TextColor3 = C.g1

        Option.Font = Enum.Font.Gotham

        Option.TextSize = 11

        Option.BorderSizePixel = 0

        Option.ZIndex = 51

        Option.Parent = OptionsFrame

        rnd(Option, 5)

        Option.MouseButton1Click:Connect(function()

            DropButton.Text = optionName .. " v"

            OptionsFrame.Visible = false

            callback(optionName)

        end)

    end

    DropButton.MouseButton1Click:Connect(function()

        OptionsFrame.Visible = not OptionsFrame.Visible

    end)

end



local function switchTab(index)

    ActiveTab = index

    for i, page in ipairs(Pages) do

        page.Visible = i == index

    end

    for i, button in ipairs(TabButtons) do

        tw(button, { TextColor3 = i == index and C.white or C.g2 })

    end

    tw(Indicator, { Position = UDim2.new(0, (index - 1) * TAB_W + 16, 1, -2) }, TM)

end



for i, tab in ipairs(TABS) do

    local TabButton = Instance.new("TextButton")

    TabButton.Size = UDim2.new(0, TAB_W, 1, -1)

    TabButton.Position = UDim2.new(0, (i - 1) * TAB_W, 0, 0)

    TabButton.BackgroundTransparency = 1

    TabButton.Text = tab.name:upper()

    TabButton.TextColor3 = i == 1 and C.white or C.g2

    TabButton.Font = Enum.Font.GothamSemibold

    TabButton.TextSize = 11

    TabButton.BorderSizePixel = 0

    TabButton.ZIndex = 6

    TabButton.Parent = TabBar

    TabButtons[i] = TabButton

    TabButton.MouseButton1Click:Connect(function()

        switchTab(i)

    end)

    local Page = Instance.new("ScrollingFrame")

    Page.Size = UDim2.new(1, 0, 1, 0)

    Page.BackgroundTransparency = 1

    Page.BorderSizePixel = 0

    Page.ScrollBarThickness = 3

    Page.ScrollBarImageColor3 = C.g4

    Page.CanvasSize = UDim2.new(0, 0, 0, 400) -- overwritten per-tab below

    Page.Visible = i == 1

    Page.Parent = Content

    Pages[i] = Page

    if tab.name == "Combat" then


        -- Aimbot row + its settings immediately below
        local y = 10
        buildRow(Page, tab.features[1], y, tab.name)          -- Aimbot
        y = y + 58
        buildSlider(Page, "Aimbot FOV", y, 50, 600, AimbotFOV, function(value)
            AimbotFOV = value
        end)
        y = y + 58
        buildSlider(Page, "Aim Smoothness", y, 1, 100, AimbotSmoothness, function(value)
            AimbotSmoothness = value
        end)
        y = y + 58
        buildDropdown(Page, "Aimbot Body Part", y, AimPartOptions, AimPartName, function(value)
            AimPartName = value
            AimbotTarget = nil
        end)
        y = y + 58
        -- Remaining Combat features below aimbot block
        for j = 2, #tab.features do
            buildRow(Page, tab.features[j], y, tab.name)
            y = y + 50
        end
        Page.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    elseif tab.name == "Movement" then

        -- Walkspeed row + slider immediately below
        local y = 10
        buildRow(Page, tab.features[1], y, tab.name)          -- Walkspeed Changer
        y = y + 58
        buildSlider(Page, "Walkspeed", y, 1, 100, WalkspeedValue, function(value)
            WalkspeedValue = value
            applyMovement()
        end)
        y = y + 58
        -- Jump Booster row + slider immediately below
        buildRow(Page, tab.features[2], y, tab.name)          -- Jump Booster
        y = y + 58
        buildSlider(Page, "Jump Height", y, 1, 100, JumpValue, function(value)
            JumpValue = value
            applyMovement()
        end)
        y = y + 58
        -- Remaining movement features below both blocks
        for j = 3, #tab.features do
            buildRow(Page, tab.features[j], y, tab.name)
            y = y + 50
        end
        Page.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    elseif tab.name == "Rage (High Risk)" then

        local y = 10
        for j = 1, #tab.features do
            buildRow(Page, tab.features[j], y, tab.name)
            y = y + 50
        end
        Page.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    else

        -- Visuals, Misc: simple row loop
        for j, feature in ipairs(tab.features) do
            buildRow(Page, feature, 10 + (j - 1) * 50, tab.name)
        end
        Page.CanvasSize = UDim2.new(0, 0, 0, 20 + #tab.features * 50)

    end

end



Players.PlayerRemoving:Connect(function(player)

    removeESP(player)

end)



LocalPlayer.CharacterAdded:Connect(function(character)

    task.wait(1.5)

    captureDefaults()

    applyMovement()

    AimbotTarget = nil

    watchCharacter(LocalPlayer, character)

end)



UserInputService.InputBegan:Connect(function(input, gameProcessed)

    if WaitingForKeybind then

        if input.UserInputType == Enum.UserInputType.Keyboard then

            if input.KeyCode == Enum.KeyCode.Escape then

                FeatureKeybinds[WaitingForKeybind] = nil

                local oldId = WaitingForKeybind

                WaitingForKeybind = nil

                updateKeybindButton(oldId)

                return

            end

            if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then

                FeatureKeybinds[WaitingForKeybind] = nil

                local oldId = WaitingForKeybind

                WaitingForKeybind = nil

                updateKeybindButton(oldId)

                return

            end

        end

        local newBind = inputToBind(input)

        if newBind then

            FeatureKeybinds[WaitingForKeybind] = newBind

            local oldId = WaitingForKeybind

            WaitingForKeybind = nil

            updateKeybindButton(oldId)

            return

        end

        return

    end

    if gameProcessed then return end

    if isMouseButtonInput(input) and isMouseOverWindow() then return end

    if bindMatchesInput(FeatureKeybinds.ui_toggle, input) then

        toggleFeature("ui_toggle")

        return

    end

    for id, bind in pairs(FeatureKeybinds) do

        if id ~= "ui_toggle" and bindMatchesInput(bind, input) then

            if id == "aimbot" and CombatModes.aimbot == "Hold" then

                setHoldFeature("aimbot", true)

            else

                toggleFeature(id)

            end

            return

        end

    end

end)



UserInputService.InputEnded:Connect(function(input)

    if CombatModes.aimbot == "Hold" and bindMatchesInput(FeatureKeybinds.aimbot, input) then

        setHoldFeature("aimbot", false)

    end

end)



local function GetCurrentWeapon()

    local char = LocalPlayer.Character

    if char then

        local tool = char:FindFirstChildWhichIsA("Tool")

        if tool and tool:FindFirstChild("Values") then

            return tool

        end

    end

    return nil

end



local function GetRageTargetPart(character)

    if not character then return nil end

    local selected = character:FindFirstChild(RageTargetPart)

    if selected and selected:IsA("BasePart") then

        return selected

    end

    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")

end



local function GetNearestEnemyForRage()

    local closest = nil

    local closestDist = RageFOV

    local char = LocalPlayer.Character

    if not char then return nil end

    local origin = char:FindFirstChild("HumanoidRootPart")

    if not origin then return nil end

    for _, player in pairs(Players:GetPlayers()) do

        if isLivePlayerCharacter(player) then

            local targetPart = GetRageTargetPart(player.Character)

            if targetPart then

                local targetPos = targetPart.Position

                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPos)

                if onScreen then

                    local dx = screenPoint.X - Mouse.X

                    local dy = screenPoint.Y - Mouse.Y

                    local dist = math.sqrt(dx^2 + dy^2)

                    if dist < closestDist and (targetPos - origin.Position).Magnitude <= 500 then

                        if Enabled.wall_check then

                            local params = RaycastParams.new()

                            params.FilterType = Enum.RaycastFilterType.Exclude

                            params.IgnoreWater = true

                            params.FilterDescendantsInstances = {LocalPlayer.Character}

                            local result = workspace:Raycast(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * 1000, params)

                            if result and result.Instance:IsDescendantOf(player.Character) then

                                closestDist = dist

                                closest = player

                            end

                        else

                            closestDist = dist

                            closest = player

                        end

                    end

                end

            end

        end

    end

    return closest

end



local _ammoConn = nil
local _lastAmmoWeapon = nil

task.spawn(function()

    RunService.Heartbeat:Connect(function()

        if not Enabled.rage_infinite_ammo then

            if _ammoConn then _ammoConn:Disconnect() _ammoConn = nil end

            _lastAmmoWeapon = nil

            return

        end

        local w = GetCurrentWeapon()

        if w ~= _lastAmmoWeapon then

            if _ammoConn then _ammoConn:Disconnect() _ammoConn = nil end

            _lastAmmoWeapon = w

            if w then

                local a = w:FindFirstChild("Ammo")

                if a and (a:IsA("IntValue") or a:IsA("NumberValue")) then

                    a.Value = 999

                    _ammoConn = a:GetPropertyChangedSignal("Value"):Connect(function()

                        if Enabled.rage_infinite_ammo and a.Value < 999 then a.Value = 999 end

                    end)

                end

            end

        end

    end)

end)



local oFR = nil
local oFR_weapon = nil

UserInputService.InputBegan:Connect(function(i, gp)

    if gp or not Enabled.rage_rapid_fire then return end

    if i.UserInputType == Enum.UserInputType.MouseButton1 then

        local w = GetCurrentWeapon()

        if w and w.Values and w.Values.FireRate then

            if w ~= oFR_weapon then

                oFR = w.Values.FireRate.Value

                oFR_weapon = w

            end

            w.Values.FireRate.Value = 3000

        end

    end

end)



UserInputService.InputEnded:Connect(function(i)

    if i.UserInputType == Enum.UserInputType.MouseButton1 and oFR then

        local w = GetCurrentWeapon()

        if w and w.Values and w.Values.FireRate then

            w.Values.FireRate.Value = oFR

        end

    end

end)










local _recoilOrig = {}
local _lastRW = nil



RunService:BindToRenderStep("MikesHubLoop", Enum.RenderPriority.Camera.Value + 1, function()

    Camera = workspace.CurrentCamera

    applyMovement()

    applyLighting()

    applyBlur()

    applyHideGuis()

    updateFOVCircle()

    updateRageFOVCircle()

    updateAimbot()

    updateESP()

    updateToolESP()

    bunnyHop()

    antiVoid()

    Crosshair.Visible = Enabled.crosshair == true

    local w = GetCurrentWeapon()

    if w ~= _lastRW then

        _recoilOrig = {}

        _lastRW = w

    end

    if w and w:FindFirstChild("Values") then

        local r = w.Values:FindFirstChild("Recoil")

        local s = w.Values:FindFirstChild("Spread")

        if r then

            if Enabled.rage_no_recoil then

                _recoilOrig.r = _recoilOrig.r or r.Value

                r.Value = 0

            elseif _recoilOrig.r then

                r.Value = _recoilOrig.r

                _recoilOrig.r = nil

            end

        end

        if s then

            if Enabled.rage_no_spread then

                _recoilOrig.s = _recoilOrig.s or s.Value

                s.Value = 0

            elseif _recoilOrig.s then

                s.Value = _recoilOrig.s

                _recoilOrig.s = nil

            end

        end

    end

end)



refreshCount()

updateAllKeybindButtons()



print("Mike's Hub loaded.")

local ARSENAL_SPEED_THRESHOLD = 21

RunService.Heartbeat:Connect(function()

    if not Enabled.walkspeed then return end

    local humanoid = getLocalHumanoid()

    if humanoid and humanoid.WalkSpeed > ARSENAL_SPEED_THRESHOLD then

        humanoid.WalkSpeed = ARSENAL_SPEED_THRESHOLD

    end

end)

local ACReportPatterns = {"Log", "Report", "Flag", "AntiCheat", "Anticheat", "AC", "Cheat", "Detect", "Kick", "Ban", "Notify", "Warn"}

local function IsACRemote(name)
    for _, pattern in ipairs(ACReportPatterns) do
        if name:find(pattern) then return true end
    end
    return false
end

local function HookACRemote(v)
    if not v or not v:IsA("RemoteEvent") then return end
    if not IsACRemote(v.Name) then return end
    pcall(function() v.FireServer = function() end end)
end

-- Batch sweep so it doesn't freeze on startup
task.spawn(function()
    local descendants = game:GetDescendants()
    for i, v in ipairs(descendants) do
        HookACRemote(v)
        if i % 100 == 0 then task.wait() end
    end
end)

game.DescendantAdded:Connect(function(v)
    HookACRemote(v)
end)

local function GetWeaponFireDelay()
    local w = GetCurrentWeapon()
    if w and w:FindFirstChild("Values") then
        local fr = w.Values:FindFirstChild("FireRate")
        if fr and fr.Value > 0 then
            return 60 / fr.Value
        end
    end
    return 0.1
end
