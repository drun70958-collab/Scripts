local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
local window = library:Window("Aimbot By Drun")
local AimbotEnabled = false
local TeamCheck = false
local DeathCheck = false
local WallCheck = false
local BlatantMode = false
local UseFOV = false
local fov = 100
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Cam = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 1
FOVring.Color = Color3.fromRGB(255, 255, 255)
FOVring.Filled = false
FOVring.Radius = fov
window:Toggle("Enable Aimbot", false, function(bool) AimbotEnabled = bool end)
window:Toggle("Use Fov", false, function(bool) UseFOV = bool FOVring.Visible = bool end)
window:Toggle("Blatant Mode", false, function(bool) BlatantMode = bool end)
window:Toggle("Team Check", false, function(bool) TeamCheck = bool end)
window:Toggle("Death Check", false, function(bool) DeathCheck = bool end)
window:Toggle("Wall Check", false, function(bool) WallCheck = bool end)
window:Slider("Fov Radius", 0, 800, 100, function(val) fov = val FOVring.Radius = val end)
local function isVisible(part)
    if not WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Cam}
    local res = workspace:Raycast(Cam.CFrame.Position, part.Position - Cam.CFrame.Position, params)
    return not res or res.Instance:IsDescendantOf(part.Parent)
end
local function getTarget()
    local closest, dist = nil, (UseFOV and fov or math.huge)
    local center = Cam.ViewportSize / 2
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if TeamCheck and p.TeamColor == LocalPlayer.TeamColor then continue end
            local char = p.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local head = char and char:FindFirstChild("Head")
            if head and hum then
                if DeathCheck and hum.Health <= 0 then continue end
                local pos, onScreen = Cam:WorldToViewportPoint(head.Position)
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < dist and isVisible(head) then
                    dist = mag
                    closest = head
                end
            end
        end
    end
    return closest
end
RunService:BindToRenderStep("AimbotUpdate", 201, function()
    FOVring.Position = Cam.ViewportSize / 2
    if AimbotEnabled then
        local target = getTarget()
        if target then
            local lookAt = CFrame.new(Cam.CFrame.Position, target.Position)
            if BlatantMode then
                Cam.CFrame = lookAt
            else
                Cam.CFrame = Cam.CFrame:Lerp(lookAt, 0.1)
            end
        end
    end
end)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Delete then
        RunService:UnbindFromRenderStep("AimbotUpdate")
        FOVring:Remove()
    end
end)
