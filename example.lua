local Decimals = 4
local Clock = os.clock()
local ValueText = "Value Is Now :"

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/hapyclub/lua/refs/heads/main/ui.lua"))({
    cheatname = "Aimbot UI", -- watermark text
    gamename = "Roblox", -- watermark text
})

library:init()

local Window1 = library.NewWindow({
    title = "Cheat | Made By KIKO | Comunity Team Happy", -- Mainwindow Text
    size = UDim2.new(0, 510, 0.6, 6)
})

local Tab1 = Window1:AddTab("  Aimbot  ")
local Tab2 = Window1:AddTab("  ESP  ")
local SettingsTab = library:CreateSettingsTab(Window1)

-- Aimbot configuration variables
local AimKey = Enum.UserInputType.MouseButton2
local ToggleKey = Enum.KeyCode.Q
local TargetPart = "HumanoidRootPart"
local RandomPartEnabled = false -- Add this new variable
local Enabled = false
local Aiming = false
local Target = nil
local FOVCircle = nil
local connection = nil
local FriendCheck = false
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Aimbot functions
local function CreateFOVCircle()
    if FOVCircle then 
        FOVCircle:Destroy() 
        FOVCircle = nil
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AimbotFOV"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Frame = Instance.new("Frame")
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.Parent = ScreenGui
    
    FOVCircle = Instance.new("ImageLabel")
    FOVCircle.Name = "FOVCircle"
    FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    FOVCircle.BackgroundTransparency = 1
    FOVCircle.Image = "rbxassetid://3570695787"
    FOVCircle.ImageColor3 = library.flags.FOVColor
    FOVCircle.ImageTransparency = library.flags.FOVTransparency
    FOVCircle.ScaleType = Enum.ScaleType.Slice
    FOVCircle.SliceCenter = Rect.new(100, 100, 100, 100)
    FOVCircle.Parent = Frame
    
    -- Calculate FOV size
    local viewportSize = Camera.ViewportSize
    local minDimension = math.min(viewportSize.X, viewportSize.Y)
    local fovRadius = math.tan(math.rad(library.flags.FOV/2)) * minDimension
    FOVCircle.Size = UDim2.new(0, fovRadius*2, 0, fovRadius*2)
    
    return ScreenGui
end
local function IsFriend(player)
    if not FriendCheck then return false end
    return LocalPlayer:IsFriendsWith(player.UserId)
end
local function FindClosestPlayer()
    local closestPlayer = nil
    local closestAngle = math.huge
    local cameraPos = Camera.CFrame.Position
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Determine which part to aim at
            local partToAim
            if RandomPartEnabled then
                -- Randomly select between Head and HumanoidRootPart
                partToAim = math.random() > 0.5 and "Head" or "HumanoidRootPart"
            else
                partToAim = TargetPart
            end
            
            if not player.Character:FindFirstChild(partToAim) then continue end
            
            if library.flags.TeamCheck and player.Team == LocalPlayer.Team then continue end
            if FriendCheck and IsFriend(player) then continue end -- Friend check
            
            local targetPos = player.Character[partToAim].Position
            if (targetPos - cameraPos).Magnitude > library.flags.MaxDistance then continue end
            
            if library.flags.VisibilityCheck then
                local ray = Ray.new(cameraPos, (targetPos - cameraPos).Unit * library.flags.MaxDistance)
                local part, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, player.Character})
                if part and not part:IsDescendantOf(player.Character) then continue end
            end
            
            local screenPoint = Camera:WorldToViewportPoint(targetPos)
            if screenPoint.Z > 0 then
                local angle = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                
                if FOVCircle and angle <= (FOVCircle.AbsoluteSize.X/2) then
                    if angle < closestAngle then
                        closestAngle = angle
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function AimAtTarget()
    if not Target or not Target.Character then
        Target = nil
        return
    end
    
    -- Determine which part to aim at
    local partToAim
    if RandomPartEnabled then
        -- Randomly select between Head and HumanoidRootPart
        partToAim = math.random() > 0.5 and "Head" or "HumanoidRootPart"
    else
        partToAim = TargetPart
    end
    
    if not Target.Character:FindFirstChild(partToAim) then
        Target = nil
        return
    end
    
    local targetPos = Target.Character[partToAim].Position
    local cameraPos = Camera.CFrame.Position
    local direction = (targetPos - cameraPos).Unit
    
    Camera.CFrame = CFrame.new(cameraPos, cameraPos + (Camera.CFrame.LookVector:Lerp(direction, library.flags.Smoothness)))
end

local function ToggleAimbot()
    Enabled = not Enabled
    
    if Enabled then
        if library.flags.ShowFOV then
            CreateFOVCircle()
        end
    else
        Aiming = false
        Target = nil
        if FOVCircle then
            FOVCircle:Destroy()
            FOVCircle = nil
        end
    end
end

-- UI Elements
local Section1 = Tab1:AddSection("Aimbot Settings", 1)

Section1:AddToggle({
    text = "Enable Aimbot",
    state = false,
    risky = true,
    tooltip = "Toggle the aimbot on/off",
    flag = "AimbotEnabled",
    callback = function(v)
        ToggleAimbot()
    end
}):AddBind({
    enabled = true,
    text = "Toggle Key",
    tooltip = "Key to toggle aimbot",
    mode = "toggle",
    bind = "Q",
    flag = "AimbotToggleKey",
    callback = function(v)
        ToggleKey = v
    end
})
Section1:AddToggle({
    text = "Friend Check",
    state = true,
    flag = "FriendCheck",
    callback = function(v)
        FriendCheck = v
    end
})
Section1:AddToggle({
    text = "Show FOV Circle",
    state = true,
    flag = "ShowFOV",
    callback = function(v)
        if Enabled then
            if v then
                CreateFOVCircle()
            else
                if FOVCircle then
                    FOVCircle:Destroy()
                    FOVCircle = nil
                end
            end
        end
    end
})

Section1:AddToggle({
    text = "Team Check",
    state = false,
    flag = "TeamCheck",
    callback = function(v)
        -- Team check is handled in FindClosestPlayer
    end
})

Section1:AddToggle({
    text = "Visibility Check",
    state = false,
    flag = "VisibilityCheck",
    callback = function(v)
        -- Visibility check is handled in FindClosestPlayer
    end
})

Section1:AddSlider({
    text = "FOV Size",
    tooltip = "Field of View size",
    flag = "FOV",
    suffix = "°",
    min = 1,
    max = 360,
    increment = 1,
    value = 5,
    callback = function(v)
        if FOVCircle then
            local viewportSize = Camera.ViewportSize
            local minDimension = math.min(viewportSize.X, viewportSize.Y)
            local fovRadius = math.tan(math.rad(v/2)) * minDimension
            FOVCircle.Size = UDim2.new(0, fovRadius*2, 0, fovRadius*2)
        end
    end
})

Section1:AddSlider({
    text = "Smoothness",
    tooltip = "Aim smoothness",
    flag = "Smoothness",
    suffix = "",
    min = 0,
    max = 1,
    increment = 0.01,
    value = 0.8,
    callback = function(v)
        -- Smoothness is handled in AimAtTarget
    end
})

Section1:AddSlider({
    text = "Max Distance",
    tooltip = "Maximum target distance",
    flag = "MaxDistance",
    suffix = " studs",
    min = 10,
    max = 5000,
    increment = 10,
    value = 1000,
    callback = function(v)
        -- Max distance is handled in FindClosestPlayer
    end
})

Section1:AddList({
    text = "Target Part", 
    tooltip = "Select which part to aim at",
    selected = "HumanoidRootPart",
    values = {"Head", "HumanoidRootPart", "UpperTorso", "Random"},
    callback = function(v)
        if v == "Random" then
            RandomPartEnabled = true
        else
            RandomPartEnabled = false
            TargetPart = v
        end
    end
})

Section1:AddColor({
    text = "FOV Color",
    color = Color3.fromRGB(255, 50, 50),
    flag = "FOVColor",
    trans = 0,
    callback = function(v)
        if FOVCircle then
            FOVCircle.ImageColor3 = v
        end
    end
})

Section1:AddSlider({
    text = "FOV Transparency",
    tooltip = "FOV circle transparency",
    flag = "FOVTransparency",
    suffix = "",
    min = 0,
    max = 1,
    increment = 0.01,
    value = 0.95,
    callback = function(v)
        if FOVCircle then
            FOVCircle.ImageTransparency = v
        end
    end
})
local MovementSection = Tab1:AddSection("Movement", 1)

local wsToggle = MovementSection:AddToggle({
    text = "Enable WalkSpeed",
    state = false,
    risky = false,
    tooltip = "Enables custom walking speed",
    flag = "WalkSpeed_Toggle",
    callback = function(v)
        if v then
            -- Apply the walk speed when toggled on
            local speed = library.flags.WalkSpeed_Value or 16
            game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = speed
        else
            -- Reset to default when toggled off
            game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 16
        end
    end
})

MovementSection:AddSlider({
    enabled = true,
    text = "Walk Speed",
    tooltip = "Sets your walking speed",
    flag = "WalkSpeed_Value",
    suffix = " studs/s",
    dragging = true,
    focused = false,
    min = 16,
    max = 200,
    increment = 1,
    risky = false,
    callback = function(v)
        if library.flags.WalkSpeed_Toggle then
            local character = game:GetService("Players").LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = v
                end
            end
        end
    end
})

-- Input handling
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == ToggleKey then
        ToggleAimbot()
    elseif Enabled and input.UserInputType == AimKey then
        Aiming = true
        Target = FindClosestPlayer()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimKey then
        Aiming = false
        Target = nil
    end
end)

-- Viewport changes
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if FOVCircle and library.flags.ShowFOV then
        local viewportSize = Camera.ViewportSize
        local minDimension = math.min(viewportSize.X, viewportSize.Y)
        local fovRadius = math.tan(math.rad(library.flags.FOV/2)) * minDimension
        FOVCircle.Size = UDim2.new(0, fovRadius*2, 0, fovRadius*2)
    end
end)

-- Main loop
connection = RunService.RenderStepped:Connect(function()
    if Enabled and Aiming then
        if Target then
            AimAtTarget()
        else
            Target = FindClosestPlayer()
        end
    end
end)

-- Cleanup
game.Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        if connection then connection:Disconnect() end
        if FOVCircle then FOVCircle:Destroy() end
    end
end)
local Section1 = Tab1:AddSection("Local", 2)
Section1:AddButton({
    enabled = true,
    text = "Freecam",
    tooltip = "Key Enable F5",
    confirm = true,
    risky = false,
    callback = function()
        
    function sandbox(var,func)
        local env = getfenv(func)
        local newenv = setmetatable({},{
        __index = function(self,k)
        if k=="script" then
        return var
        else
        return env[k]
        end
        end,
        })
        setfenv(func,newenv)
        return func
        end
        cors = {}
        mas = Instance.new("Model",game:GetService("Lighting"))
        LocalScript0 = Instance.new("LocalScript")
        LocalScript0.Name = "FreeCamera"
        LocalScript0.Parent = mas
        table.insert(cors,sandbox(LocalScript0,function()
        -----------------------------------------------------------------------
        -- Freecam
        -- Cinematic free camera for spectating and video production.
        ------------------------------------------------------------------------
         
        local pi    = math.pi
        local abs   = math.abs
        local clamp = math.clamp
        local exp   = math.exp
        local rad   = math.rad
        local sign  = math.sign
        local sqrt  = math.sqrt
        local tan   = math.tan
         
        local ContextActionService = game:GetService("ContextActionService")
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local StarterGui = game:GetService("StarterGui")
        local UserInputService = game:GetService("UserInputService")
         
        local LocalPlayer = Players.LocalPlayer
        if not LocalPlayer then
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        LocalPlayer = Players.LocalPlayer
        end
         
        local Camera = workspace.CurrentCamera
        workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        local newCamera = workspace.CurrentCamera
        if newCamera then
        Camera = newCamera
        end
        end)
         
        ------------------------------------------------------------------------
         
        local TOGGLE_INPUT_PRIORITY = Enum.ContextActionPriority.Low.Value
        local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
        local FREECAM_MACRO_KB = {Enum.KeyCode.F5}
         
        local NAV_GAIN = Vector3.new(1, 1, 1)*64
        local PAN_GAIN = Vector2.new(0.75, 1)*8
        local FOV_GAIN = 300
         
        local PITCH_LIMIT = rad(90)
         
        local VEL_STIFFNESS = 1.5
        local PAN_STIFFNESS = 1.0
        local FOV_STIFFNESS = 4.0
         
        ------------------------------------------------------------------------
         
        local Spring = {} do
        Spring.__index = Spring
         
        function Spring.new(freq, pos)
        local self = setmetatable({}, Spring)
        self.f = freq
        self.p = pos
        self.v = pos*0
        return self
        end
         
        function Spring:Update(dt, goal)
        local f = self.f*2*pi
        local p0 = self.p
        local v0 = self.v
         
        local offset = goal - p0
        local decay = exp(-f*dt)
         
        local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
        local v1 = (f*dt*(offset*f - v0) + v0)*decay
         
        self.p = p1
        self.v = v1
         
        return p1
        end
         
        function Spring:Reset(pos)
        self.p = pos
        self.v = pos*0
        end
        end
         
        ------------------------------------------------------------------------
         
        local cameraPos = Vector3.new()
        local cameraRot = Vector2.new()
        local cameraFov = 0
         
        local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
        local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
        local fovSpring = Spring.new(FOV_STIFFNESS, 0)
         
        ------------------------------------------------------------------------
         
        local Input = {} do
        local thumbstickCurve do
        local K_CURVATURE = 2.0
        local K_DEADZONE = 0.15
         
        local function fCurve(x)
        return (exp(K_CURVATURE*x) - 1)/(exp(K_CURVATURE) - 1)
        end
         
        local function fDeadzone(x)
        return fCurve((x - K_DEADZONE)/(1 - K_DEADZONE))
        end
         
        function thumbstickCurve(x)
        return sign(x)*clamp(fDeadzone(abs(x)), 0, 1)
        end
        end
         
        local gamepad = {
        ButtonX = 0,
        ButtonY = 0,
        DPadDown = 0,
        DPadUp = 0,
        ButtonL2 = 0,
        ButtonR2 = 0,
        Thumbstick1 = Vector2.new(),
        Thumbstick2 = Vector2.new(),
        }
         
        local keyboard = {
        W = 0,
        A = 0,
        S = 0,
        D = 0,
        E = 0,
        Q = 0,
        U = 0,
        H = 0,
        J = 0,
        K = 0,
        I = 0,
        Y = 0,
        Up = 0,
        Down = 0,
        LeftShift = 0,
        RightShift = 0,
        }
         
        local mouse = {
        Delta = Vector2.new(),
        MouseWheel = 0,
        }
         
        local NAV_GAMEPAD_SPEED  = Vector3.new(1, 1, 1)
        local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
        local PAN_MOUSE_SPEED    = Vector2.new(1, 1)*(pi/64)
        local PAN_GAMEPAD_SPEED  = Vector2.new(1, 1)*(pi/8)
        local FOV_WHEEL_SPEED    = 1.0
        local FOV_GAMEPAD_SPEED  = 0.25
        local NAV_ADJ_SPEED      = 0.75
        local NAV_SHIFT_MUL      = 0.25
         
        local navSpeed = 1
         
        function Input.Vel(dt)
        navSpeed = clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)
         
        local kGamepad = Vector3.new(
        thumbstickCurve(gamepad.Thumbstick1.x),
        thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),
        thumbstickCurve(-gamepad.Thumbstick1.y)
        )*NAV_GAMEPAD_SPEED
         
        local kKeyboard = Vector3.new(
        keyboard.D - keyboard.A + keyboard.K - keyboard.H,
        keyboard.E - keyboard.Q + keyboard.I - keyboard.Y,
        keyboard.S - keyboard.W + keyboard.J - keyboard.U
        )*NAV_KEYBOARD_SPEED
         
        local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
         
        return (kGamepad + kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
        end
         
        function Input.Pan(dt)
        local kGamepad = Vector2.new(
        thumbstickCurve(gamepad.Thumbstick2.y),
        thumbstickCurve(-gamepad.Thumbstick2.x)
        )*PAN_GAMEPAD_SPEED
        local kMouse = mouse.Delta*PAN_MOUSE_SPEED
        mouse.Delta = Vector2.new()
        return kGamepad + kMouse
        end
         
        function Input.Fov(dt)
        local kGamepad = (gamepad.ButtonX - gamepad.ButtonY)*FOV_GAMEPAD_SPEED
        local kMouse = mouse.MouseWheel*FOV_WHEEL_SPEED
        mouse.MouseWheel = 0
        return kGamepad + kMouse
        end
         
        do
        local function Keypress(action, state, input)
        keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
        return Enum.ContextActionResult.Sink
        end
         
        local function GpButton(action, state, input)
        gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
        return Enum.ContextActionResult.Sink
        end
         
        local function MousePan(action, state, input)
        local delta = input.Delta
        mouse.Delta = Vector2.new(-delta.y, -delta.x)
        return Enum.ContextActionResult.Sink
        end
         
        local function Thumb(action, state, input)
        gamepad[input.KeyCode.Name] = input.Position
        return Enum.ContextActionResult.Sink
        end
         
        local function Trigger(action, state, input)
        gamepad[input.KeyCode.Name] = input.Position.z
        return Enum.ContextActionResult.Sink
        end
         
        local function MouseWheel(action, state, input)
        mouse[input.UserInputType.Name] = -input.Position.z
        return Enum.ContextActionResult.Sink
        end
         
        local function Zero(t)
        for k, v in pairs(t) do
        t[k] = v*0
        end
        end
         
        function Input.StartCapture()
        ContextActionService:BindActionAtPriority("FreecamKeyboard", Keypress, false, INPUT_PRIORITY,
        Enum.KeyCode.W, Enum.KeyCode.U,
        Enum.KeyCode.A, Enum.KeyCode.H,
        Enum.KeyCode.S, Enum.KeyCode.J,
        Enum.KeyCode.D, Enum.KeyCode.K,
        Enum.KeyCode.E, Enum.KeyCode.I,
        Enum.KeyCode.Q, Enum.KeyCode.Y,
        Enum.KeyCode.Up, Enum.KeyCode.Down
        )
        ContextActionService:BindActionAtPriority("FreecamMousePan",          MousePan,   false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
        ContextActionService:BindActionAtPriority("FreecamMouseWheel",        MouseWheel, false, INPUT_PRIORITY, Enum.UserInputType.MouseWheel)
        ContextActionService:BindActionAtPriority("FreecamGamepadButton",     GpButton,   false, INPUT_PRIORITY, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
        ContextActionService:BindActionAtPriority("FreecamGamepadTrigger",    Trigger,    false, INPUT_PRIORITY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
        ContextActionService:BindActionAtPriority("FreecamGamepadThumbstick", Thumb,      false, INPUT_PRIORITY, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
        end
         
        function Input.StopCapture()
        navSpeed = 1
        Zero(gamepad)
        Zero(keyboard)
        Zero(mouse)
        ContextActionService:UnbindAction("FreecamKeyboard")
        ContextActionService:UnbindAction("FreecamMousePan")
        ContextActionService:UnbindAction("FreecamMouseWheel")
        ContextActionService:UnbindAction("FreecamGamepadButton")
        ContextActionService:UnbindAction("FreecamGamepadTrigger")
        ContextActionService:UnbindAction("FreecamGamepadThumbstick")
        end
        end
        end
         
        local function GetFocusDistance(cameraFrame)
        local znear = 0.1
        local viewport = Camera.ViewportSize
        local projy = 2*tan(cameraFov/2)
        local projx = viewport.x/viewport.y*projy
        local fx = cameraFrame.rightVector
        local fy = cameraFrame.upVector
        local fz = cameraFrame.lookVector
         
        local minVect = Vector3.new()
        local minDist = 512
         
        for x = 0, 1, 0.5 do
        for y = 0, 1, 0.5 do
        local cx = (x - 0.5)*projx
        local cy = (y - 0.5)*projy
        local offset = fx*cx - fy*cy + fz
        local origin = cameraFrame.p + offset*znear
        local part, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
        local dist = (hit - origin).magnitude
        if minDist > dist then
        minDist = dist
        minVect = offset.unit
        end
        end
        end
         
        return fz:Dot(minVect)*minDist
        end
         
        ------------------------------------------------------------------------
         
        local function StepFreecam(dt)
        local vel = velSpring:Update(dt, Input.Vel(dt))
        local pan = panSpring:Update(dt, Input.Pan(dt))
        local fov = fovSpring:Update(dt, Input.Fov(dt))
         
        local zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))
         
        cameraFov = clamp(cameraFov + fov*FOV_GAIN*(dt/zoomFactor), 1, 120)
        cameraRot = cameraRot + pan*PAN_GAIN*(dt/zoomFactor)
        cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y%(2*pi))
         
        local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*NAV_GAIN*dt)
        cameraPos = cameraCFrame.p
         
        Camera.CFrame = cameraCFrame
        Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
        Camera.FieldOfView = cameraFov
        end
         
        ------------------------------------------------------------------------
         
        local PlayerState = {} do
        local mouseIconEnabled
        local cameraSubject
        local cameraType
        local cameraFocus
        local cameraCFrame
        local cameraFieldOfView
        local screenGuis = {}
        local coreGuis = {
        Backpack = true,
        Chat = true,
        Health = true,
        PlayerList = true,
        }
        local setCores = {
        BadgesNotificationsActive = true,
        PointsNotificationsActive = true,
        }
         
        -- Save state and set up for freecam
        function PlayerState.Push()
        for name in pairs(coreGuis) do
        coreGuis[name] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[name])
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], false)
        end
        for name in pairs(setCores) do
        setCores[name] = StarterGui:GetCore(name)
        StarterGui:SetCore(name, false)
        end
        local playergui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playergui then
        for _, gui in pairs(playergui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
        screenGuis[#screenGuis + 1] = gui
        gui.Enabled = false
        end
        end
        end
         
        cameraFieldOfView = Camera.FieldOfView
        Camera.FieldOfView = 70
         
        cameraType = Camera.CameraType
        Camera.CameraType = Enum.CameraType.Custom
         
        cameraSubject = Camera.CameraSubject
        Camera.CameraSubject = nil
         
        cameraCFrame = Camera.CFrame
        cameraFocus = Camera.Focus
         
        mouseIconEnabled = UserInputService.MouseIconEnabled
        UserInputService.MouseIconEnabled = false
         
        mouseBehavior = UserInputService.MouseBehavior
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
         
        -- Restore state
        function PlayerState.Pop()
        for name, isEnabled in pairs(coreGuis) do
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], isEnabled)
        end
        for name, isEnabled in pairs(setCores) do
        StarterGui:SetCore(name, isEnabled)
        end
        for _, gui in pairs(screenGuis) do
        if gui.Parent then
        gui.Enabled = true
        end
        end
         
        Camera.FieldOfView = cameraFieldOfView
        cameraFieldOfView = nil
         
        Camera.CameraType = cameraType
        cameraType = nil
         
        Camera.CameraSubject = cameraSubject
        cameraSubject = nil
         
        Camera.CFrame = cameraCFrame
        cameraCFrame = nil
         
        Camera.Focus = cameraFocus
        cameraFocus = nil
         
        UserInputService.MouseIconEnabled = mouseIconEnabled
        mouseIconEnabled = nil
         
        UserInputService.MouseBehavior = mouseBehavior
        mouseBehavior = nil
        end
        end
         
        local function StartFreecam()
        local cameraCFrame = Camera.CFrame
        cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())
        cameraPos = cameraCFrame.p
        cameraFov = Camera.FieldOfView
         
        velSpring:Reset(Vector3.new())
        panSpring:Reset(Vector2.new())
        fovSpring:Reset(0)
         
        PlayerState.Push()
        RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
        Input.StartCapture()
        end
         
        local function StopFreecam()
        Input.StopCapture()
        RunService:UnbindFromRenderStep("Freecam")
        PlayerState.Pop()
        end
         
        ------------------------------------------------------------------------
         
        do
        local enabled = false
         
        local function ToggleFreecam()
        if enabled then
        StopFreecam()
        else
        StartFreecam()
        end
        enabled = not enabled
        end
         
        local function CheckMacro(macro)
        for i = 1, #macro - 1 do
        if not UserInputService:IsKeyDown(macro[i]) then
        return
        end
        end
        ToggleFreecam()
        end
         
        local function HandleActivationInput(action, state, input)
        if state == Enum.UserInputState.Begin then
        if input.KeyCode == FREECAM_MACRO_KB[#FREECAM_MACRO_KB] then
        CheckMacro(FREECAM_MACRO_KB)
        end
        end
        return Enum.ContextActionResult.Pass
        end
         
        ContextActionService:BindActionAtPriority("FreecamToggle", HandleActivationInput, false, TOGGLE_INPUT_PRIORITY, FREECAM_MACRO_KB[#FREECAM_MACRO_KB])
        end
        end))
        for i,v in pairs(mas:GetChildren()) do
        v.Parent = game:GetService("Players").LocalPlayer.PlayerGui
        pcall(function() v:MakeJoints() end)
        end
        mas:Destroy()
        for i,v in pairs(cors) do
        spawn(function()
        pcall(v)
        end)
        end

    end
})
local Section1 = Tab2:AddSection("Visual Settings", 1)
local ESP = {
    Enabled = false,
    Boxes = true,
    Names = true,
    Health = true,
    Distance = true,
    TeamColor = true,
    RainbowColor = false, -- New Rainbow toggle
    BoxColor = Color3.fromRGB(255, 255, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    MaxDistance = 1000,
    TextSize = 14,
    Font = "GothamMedium"
}

local ESPObjects = {}
local RainbowCounter = 0

-- Rainbow color function
local function GetRainbowColor(hue)
    return Color3.fromHSV(hue, 1, 1)
end

-- Clean ESP Functions
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Create minimalist highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_ESP"
    highlight.Adornee = character
    highlight.Parent = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0
    
    -- Create compact info display
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name .. "_Info"
    billboard.Adornee = rootPart
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    
    -- Single combined text label for better performance
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "ESPInfo"
    infoLabel.Size = UDim2.new(1, 0, 1, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = ESP.TextColor
    infoLabel.TextSize = ESP.TextSize
    infoLabel.Font = Enum.Font[ESP.Font]
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.Parent = billboard
    
    ESPObjects[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Character = character,
        Humanoid = humanoid,
        InfoLabel = infoLabel
    }
    
    -- Health update connection
    humanoid.HealthChanged:Connect(function()
        if ESPObjects[player] then
            UpdatePlayerESP(player)
        end
    end)
    
    -- Cleanup connection
    character:GetPropertyChangedSignal("Parent"):Connect(function()
        if not character.Parent and ESPObjects[player] then
            ESPObjects[player].Highlight:Destroy()
            ESPObjects[player].Billboard:Destroy()
            ESPObjects[player] = nil
        end
    end)
end

local function UpdatePlayerESP(player)
    local data = ESPObjects[player]
    if not data or not data.Character or not data.Character.Parent then return end
    
    -- Skip if friend check is enabled and player is a friend
    if FriendCheck and IsFriend(player) then
        data.Highlight.Enabled = false
        data.Billboard.Enabled = false
        return
    end
    
    local localPlayer = game:GetService("Players").LocalPlayer
    local localCharacter = localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    local rootPart = data.Character:FindFirstChild("HumanoidRootPart")
    
    if rootPart and localRoot then
        -- Calculate distance
        local distance = (rootPart.Position - localRoot.Position).Magnitude
        local shouldShow = distance <= ESP.MaxDistance
        
        -- Update visibility
        data.Highlight.Enabled = shouldShow and ESP.Enabled
        data.Billboard.Enabled = shouldShow and ESP.Enabled
        
        -- Set colors
        if ESP.RainbowColor then
            -- Rainbow effect
            local hue = (tick() * 0.5 % 1)
            data.Highlight.FillColor = GetRainbowColor(hue)
            data.Highlight.OutlineColor = GetRainbowColor(hue)
        elseif ESP.TeamColor and player.Team then
            -- Team color
            data.Highlight.FillColor = player.Team.TeamColor.Color
            data.Highlight.OutlineColor = player.Team.TeamColor.Color
        else
            -- Custom color
            data.Highlight.FillColor = ESP.BoxColor
            data.Highlight.OutlineColor = ESP.BoxColor
        end
        
        -- Update text (single combined label for better performance)
        local infoText = ""
        if ESP.Names then infoText = player.Name end
        if ESP.Health then infoText = infoText .. (infoText ~= "" and "\n" or "") .. "♥ " .. math.floor(data.Humanoid.Health) end
        if ESP.Distance then infoText = infoText .. (infoText ~= "" and "\n" or "") .. "📏 " .. math.floor(distance) .. "m" end
        
        data.InfoLabel.Text = infoText
        data.InfoLabel.TextColor3 = ESP.TextColor
        
        -- Update highlight transparency
        data.Highlight.FillTransparency = ESP.Boxes and 0.8 or 1
        data.Highlight.OutlineTransparency = ESP.Boxes and 0 or 1
    end
end

local function UpdateESP()
    RainbowCounter = RainbowCounter + 0.01 -- Increment rainbow counter
    
    for player, _ in pairs(ESPObjects) do
        UpdatePlayerESP(player)
    end
end

local function ToggleESP(state)
    ESP.Enabled = state
    
    if state then
        -- Initialize for existing players
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer then
                if player.Character then
                    CreateESP(player)
                end
                player.CharacterAdded:Connect(function()
                    CreateESP(player)
                end)
            end
        end
        
        -- Setup for new players
        game:GetService("Players").PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                CreateESP(player)
            end)
        end)
        
        -- Start update loop
        game:GetService("RunService").RenderStepped:Connect(UpdateESP)
    else
        -- Cleanup
        for player, data in pairs(ESPObjects) do
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
        end
        ESPObjects = {}
    end
end
Section1:AddToggle({
    text = "Enable ESP",
    state = false,
    flag = "ESP_Enabled",
    callback = ToggleESP
})
Section1:AddToggle({
    text = "Friend Check",
    state = false,
    flag = "ESP_FriendCheck",
    callback = function(v)
        FriendCheck = v
    end
})
Section1:AddToggle({
    text = "Show Boxes",
    state = true,
    flag = "ESP_Boxes",
    callback = function(v) ESP.Boxes = v end
})

Section1:AddToggle({
    text = "Team Colors",
    state = true,
    flag = "ESP_TeamColor",
    callback = function(v) 
        ESP.TeamColor = v 
        if v then ESP.RainbowColor = false end
    end
})

-- New Rainbow toggle
Section1:AddToggle({
    text = "Rainbow Color",
    state = false,
    flag = "ESP_Rainbow",
    callback = function(v) 
        ESP.RainbowColor = v 
        if v then ESP.TeamColor = false end
    end
})

local Section2 = Tab2:AddSection("Information", 2)

Section2:AddToggle({
    text = "Show Names",
    state = true,
    flag = "ESP_Names",
    callback = function(v) ESP.Names = v end
})

Section2:AddToggle({
    text = "Show Health",
    state = true,
    flag = "ESP_Health",
    callback = function(v) ESP.Health = v end
})

Section2:AddToggle({
    text = "Show Distance",
    state = true,
    flag = "ESP_Distance",
    callback = function(v) ESP.Distance = v end
})

Section2:AddSlider({
    text = "Max Distance",
    suffix = "m",
    min = 0,
    max = 5000,
    increment = 50,
    value = 1000,
    flag = "ESP_MaxDistance",
    callback = function(v) ESP.MaxDistance = v end
})

local Section3 = Tab2:AddSection("Appearance", 3)

Section3:AddColor({
    text = "Box Color",
    color = Color3.fromRGB(255, 255, 255),
    flag = "ESP_BoxColor",
    callback = function(v) 
        ESP.BoxColor = v 
        if v ~= Color3.fromRGB(255, 255, 255) then 
            ESP.RainbowColor = false 
        end
    end
})

Section3:AddColor({
    text = "Text Color",
    color = Color3.fromRGB(255, 255, 255),
    flag = "ESP_TextColor",
    callback = function(v) ESP.TextColor = v end
})

Section3:AddSlider({
    text = "Text Size",
    min = 8,
    max = 24,
    increment = 1,
    value = 14,
    flag = "ESP_TextSize",
    callback = function(v) 
        ESP.TextSize = v
        for _, data in pairs(ESPObjects) do
            if data.InfoLabel then
                data.InfoLabel.TextSize = v
            end
        end
    end
})

Section3:AddList({
    text = "Font Style",
    values = {"GothamMedium", "GothamBold", "SourceSans", "Ubuntu"},
    value = "GothamMedium",
    callback = function(v)
        ESP.Font = v
        for _, data in pairs(ESPObjects) do
            if data.InfoLabel then
                data.InfoLabel.Font = Enum.Font[v]
            end
        end
    end
})
local Time = (string.format("%."..tostring(Decimals).."f", os.clock() - Clock))
library:SendNotification(("Aimbot UI Loaded In "..tostring(Time).." seconds"), 6)