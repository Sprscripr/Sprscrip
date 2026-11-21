-- Sprscript v2.3 | Menú Mediano Centrado + FOV + Silent Aim + ESP Inventario debajo de cada jugador
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Estado del script
local AimbotEnabled = false
local FovEnabled = true
local InvEspEnabled = false
local MenuOpen = true
local FovRadius = 140
local CurrentTarget = nil
local shotToggle = false

-- Limpiar UI anterior si se re-ejecuta
pcall(function()
	if gethui and gethui():FindFirstChild("SprscriptGui") then
		gethui().SprscriptGui:Destroy()
	elseif LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("SprscriptGui") then
		LocalPlayer.PlayerGui.SprscriptGui:Destroy()
	end
end)

-- Crear ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SprscriptGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
	if gethui then
		ScreenGui.Parent = gethui()
	else
		ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end)
if not ScreenGui.Parent then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Carpeta para los BillboardGuis de inventario debajo de los jugadores
local EspFolder = Instance.new("Folder")
EspFolder.Name = "SprscriptInvEsp"
EspFolder.Parent = ScreenGui

-- Círculo de FOV centrado en la pantalla
local FovCircle = Instance.new("Frame")
FovCircle.Name = "FovCircle"
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.Size = UDim2.new(0, FovRadius * 2, 0, FovRadius * 2)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = FovEnabled
FovCircle.ZIndex = 1
FovCircle.Parent = ScreenGui

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0)
FovCorner.Parent = FovCircle

local FovStroke = Instance.new("UIStroke")
FovStroke.Color = Color3.fromRGB(255, 70, 70)
FovStroke.Thickness = 1.6
FovStroke.Transparency = 0.25
FovStroke.Parent = FovCircle

-- Barra principal centrada: [ + | Sprscript ]
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 260, 0, 42)
TopBar.Position = UDim2.new(0.5, -130, 0.5, -130)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.ZIndex = 5
TopBar.Parent = ScreenGui

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local TopStroke = Instance.new("UIStroke")
TopStroke.Color = Color3.fromRGB(80, 80, 96)
TopStroke.Thickness = 1.4
TopStroke.Parent = TopBar

-- Botón "+" (Arrastrable por la pantalla)
local DragButton = Instance.new("TextButton")
DragButton.Name = "DragButton"
DragButton.Size = UDim2.new(0, 46, 0, 42)
DragButton.Position = UDim2.new(0, 0, 0, 0)
DragButton.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
DragButton.Text = "+"
DragButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DragButton.TextSize = 24
DragButton.Font = Enum.Font.GothamBold
DragButton.AutoButtonColor = true
DragButton.ZIndex = 6
DragButton.Parent = TopBar

local DragCorner = Instance.new("UICorner")
DragCorner.CornerRadius = UDim.new(0, 8)
DragCorner.Parent = DragButton

-- Separador vertical "|"
local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Size = UDim2.new(0, 2, 0, 24)
Divider.Position = UDim2.new(0, 48, 0, 9)
Divider.BackgroundColor3 = Color3.fromRGB(95, 95, 115)
Divider.BorderSizePixel = 0
Divider.ZIndex = 6
Divider.Parent = TopBar

-- Botón "Sprscript" (Abre/Cierra el menú)
local TitleButton = Instance.new("TextButton")
TitleButton.Name = "TitleButton"
TitleButton.Size = UDim2.new(0, 208, 0, 42)
TitleButton.Position = UDim2.new(0, 52, 0, 0)
TitleButton.BackgroundTransparency = 1
TitleButton.Text = "Sprscript"
TitleButton.TextColor3 = Color3.fromRGB(245, 245, 250)
TitleButton.TextSize = 16
TitleButton.Font = Enum.Font.GothamBold
TitleButton.AutoButtonColor = true
TitleButton.ZIndex = 6
TitleButton.Parent = TopBar

-- Menú mediano desplegable debajo de la barra
local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MenuFrame"
MenuFrame.Size = UDim2.new(0, 260, 0, 188)
MenuFrame.Position = UDim2.new(0, 0, 0, 48)
MenuFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = MenuOpen
MenuFrame.ZIndex = 5
MenuFrame.Parent = TopBar

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = MenuFrame

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = Color3.fromRGB(80, 80, 96)
MenuStroke.Thickness = 1.4
MenuStroke.Parent = MenuFrame

-- Botón "Aimbot"
local AimbotButton = Instance.new("TextButton")
AimbotButton.Name = "AimbotButton"
AimbotButton.Size = UDim2.new(0, 236, 0, 38)
AimbotButton.Position = UDim2.new(0, 12, 0, 12)
AimbotButton.BackgroundColor3 = Color3.fromRGB(45, 45, 56)
AimbotButton.Text = "Aimbot: OFF"
AimbotButton.TextColor3 = Color3.fromRGB(240, 95, 95)
AimbotButton.TextSize = 14
AimbotButton.Font = Enum.Font.GothamBold
AimbotButton.ZIndex = 6
AimbotButton.Parent = MenuFrame

local AimbotCorner = Instance.new("UICorner")
AimbotCorner.CornerRadius = UDim.new(0, 8)
AimbotCorner.Parent = AimbotButton

-- Botón "FOV"
local FovButton = Instance.new("TextButton")
FovButton.Name = "FovButton"
FovButton.Size = UDim2.new(0, 236, 0, 36)
FovButton.Position = UDim2.new(0, 12, 0, 56)
FovButton.BackgroundColor3 = Color3.fromRGB(38, 58, 46)
FovButton.Text = "FOV Circle: ON"
FovButton.TextColor3 = Color3.fromRGB(100, 245, 135)
FovButton.TextSize = 14
FovButton.Font = Enum.Font.GothamBold
FovButton.ZIndex = 6
FovButton.Parent = MenuFrame

local FovBtnCorner = Instance.new("UICorner")
FovBtnCorner.CornerRadius = UDim.new(0, 8)
FovBtnCorner.Parent = FovButton

-- Botón "Inventario Jugadores" (Debajo de cada jugador con ícono/imagen)
local InvButton = Instance.new("TextButton")
InvButton.Name = "InvButton"
InvButton.Size = UDim2.new(0, 236, 0, 38)
InvButton.Position = UDim2.new(0, 12, 0, 98)
InvButton.BackgroundColor3 = Color3.fromRGB(45, 45, 56)
InvButton.Text = "Ver Inventario ESP: OFF"
InvButton.TextColor3 = Color3.fromRGB(240, 95, 95)
InvButton.TextSize = 14
InvButton.Font = Enum.Font.GothamBold
InvButton.ZIndex = 6
InvButton.Parent = MenuFrame

local InvBtnCorner = Instance.new("UICorner")
InvBtnCorner.CornerRadius = UDim.new(0, 8)
InvBtnCorner.Parent = InvButton

-- Etiqueta informativa
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "InfoLabel"
InfoLabel.Size = UDim2.new(0, 236, 0, 24)
InfoLabel.Position = UDim2.new(0, 12, 0, 146)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Silent Aim + ESP Ítems en pies"
InfoLabel.TextColor3 = Color3.fromRGB(185, 185, 200)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.ZIndex = 6
InfoLabel.Parent = MenuFrame

-- Sistema de arrastre desde "+" (táctil y mouse)
do
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	local function update(input)
		local delta = input.Position - dragStart
		TopBar.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	DragButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = TopBar.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	DragButton.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

-- Abrir/cerrar menú al tocar "Sprscript"
TitleButton.MouseButton1Click:Connect(function()
	MenuOpen = not MenuOpen
	MenuFrame.Visible = MenuOpen
end)

-- Obtener herramientas (equipada + mochila) de cualquier jugador
local function getPlayerTools(player)
	local list = {}
	local seen = {}

	local function add(tool, equipped)
		if tool and tool:IsA("Tool") and not seen[tool] then
			seen[tool] = true
			table.insert(list, {
				Name = tool.Name,
				TextureId = tool.TextureId,
				Equipped = equipped
			})
		end
	end

	if player.Character then
		for _, child in ipairs(player.Character:GetChildren()) do
			add(child, true)
		end
	end

	local bp = player:FindFirstChildOfClass("Backpack")
	if bp then
		for _, child in ipairs(bp:GetChildren()) do
			add(child, false)
		end
	end

	return list
end

-- Limpiar ESP de inventario
local PlayerBillboards = {}

local function clearAllInvEsp()
	for player, gui in pairs(PlayerBillboards) do
		if gui then
			gui:Destroy()
		end
		PlayerBillboards[player] = nil
	end
end

-- Crear o actualizar BillboardGui debajo de cada jugador
local function updatePlayerInvEsp(player)
	if player == LocalPlayer then return end

	local char = player.Character
	local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if not InvEspEnabled or not char or not root or not hum or hum.Health <= 0 then
		if PlayerBillboards[player] then
			PlayerBillboards[player]:Destroy()
			PlayerBillboards[player] = nil
		end
		return
	end

	local tools = getPlayerTools(player)
	local bb = PlayerBillboards[player]

	if not bb or not bb.Parent then
		bb = Instance.new("BillboardGui")
		bb.Name = "InvBillboard_" .. player.Name
		bb.Size = UDim2.new(0, 220, 0, 56)
		-- Posicionado debajo del jugador (en sus pies)
		bb.StudsOffset = Vector3.new(0, -3.5, 0)
		bb.AlwaysOnTop = true
		bb.MaxDistance = 250
		bb.Parent = EspFolder

		local holder = Instance.new("Frame")
		holder.Name = "Holder"
		holder.Size = UDim2.new(1, 0, 1, 0)
		holder.BackgroundTransparency = 1
		holder.Parent = bb

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Padding = UDim.new(0, 4)
		layout.Parent = holder

		PlayerBillboards[player] = bb
	end

	bb.Adornee = root
	local holder = bb:FindFirstChild("Holder")
	if not holder then return end

	-- Limpiar slots previos
	for _, child in ipairs(holder:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	if #tools == 0 then
		local emptySlot = Instance.new("Frame")
		emptySlot.Size = UDim2.new(0, 90, 0, 22)
		emptySlot.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		emptySlot.BackgroundTransparency = 0.25
		emptySlot.Parent = holder

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 5)
		c.Parent = emptySlot

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = "Sin ítems"
		lbl.TextColor3 = Color3.fromRGB(185, 185, 195)
		lbl.TextSize = 11
		lbl.Font = Enum.Font.GothamMedium
		lbl.Parent = emptySlot
		return
	end

	-- Mostrar hasta 5 objetos con su imagen (TextureId) y nombre
	local maxSlots = math.min(#tools, 5)
	bb.Size = UDim2.new(0, math.max(120, maxSlots * 54), 0, 54)

	for i = 1, maxSlots do
		local t = tools[i]
		local slot = Instance.new("Frame")
		slot.Size = UDim2.new(0, 50, 0, 50)
		slot.BackgroundColor3 = t.Equipped and Color3.fromRGB(32, 62, 42) or Color3.fromRGB(22, 22, 28)
		slot.BackgroundTransparency = 0.15
		slot.Parent = holder

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = slot

		local stroke = Instance.new("UIStroke")
		stroke.Color = t.Equipped and Color3.fromRGB(95, 245, 135) or Color3.fromRGB(90, 95, 115)
		stroke.Thickness = t.Equipped and 1.6 or 1
		stroke.Parent = slot

		-- Imagen del objeto si el Tool tiene TextureId
		local hasIcon = (t.TextureId ~= nil and t.TextureId ~= "")
		if hasIcon then
			local icon = Instance.new("ImageLabel")
			icon.Size = UDim2.new(0, 30, 0, 30)
			icon.Position = UDim2.new(0.5, -15, 0, 3)
			icon.BackgroundTransparency = 1
			icon.Image = t.TextureId
			icon.ScaleType = Enum.ScaleType.Fit
			icon.Parent = slot
		end

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = hasIcon and UDim2.new(1, -4, 0, 14) or UDim2.new(1, -4, 1, -4)
		nameLbl.Position = hasIcon and UDim2.new(0, 2, 1, -15) or UDim2.new(0, 2, 0, 2)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = t.Name
		nameLbl.TextColor3 = t.Equipped and Color3.fromRGB(145, 255, 170) or Color3.fromRGB(240, 240, 248)
		nameLbl.TextSize = hasIcon and 9 or 10
		nameLbl.TextWrapped = not hasIcon
		nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.Parent = slot
	end
end

Players.PlayerRemoving:Connect(function(player)
	if PlayerBillboards[player] then
		PlayerBillboards[player]:Destroy()
		PlayerBillboards[player] = nil
	end
end)

-- Alternar ESP de Inventario debajo de cada jugador
InvButton.MouseButton1Click:Connect(function()
	InvEspEnabled = not InvEspEnabled
	if InvEspEnabled then
		InvButton.Text = "Ver Inventario ESP: ON"
		InvButton.TextColor3 = Color3.fromRGB(90, 245, 130)
		InvButton.BackgroundColor3 = Color3.fromRGB(32, 68, 44)
	else
		InvButton.Text = "Ver Inventario ESP: OFF"
		InvButton.TextColor3 = Color3.fromRGB(240, 95, 95)
		InvButton.BackgroundColor3 = Color3.fromRGB(45, 45, 56)
		clearAllInvEsp()
	end
end)

-- Resaltado rojo para el objetivo actual
local Highlight = Instance.new("Highlight")
Highlight.Name = "SprscriptTargetHighlight"
Highlight.FillColor = Color3.fromRGB(255, 35, 35)
Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
Highlight.FillTransparency = 0.35
Highlight.OutlineTransparency = 0
Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
Highlight.Enabled = false
Highlight.Parent = ScreenGui

local function clearTargetHighlight()
	CurrentTarget = nil
	Highlight.Adornee = nil
	Highlight.Enabled = false
end

-- Alternar Aimbot
AimbotButton.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
	if AimbotEnabled then
		AimbotButton.Text = "Aimbot: ON"
		AimbotButton.TextColor3 = Color3.fromRGB(90, 245, 130)
		AimbotButton.BackgroundColor3 = Color3.fromRGB(32, 68, 44)
	else
		AimbotButton.Text = "Aimbot: OFF"
		AimbotButton.TextColor3 = Color3.fromRGB(240, 95, 95)
		AimbotButton.BackgroundColor3 = Color3.fromRGB(45, 45, 56)
		clearTargetHighlight()
	end
end)

-- Alternar Círculo FOV
FovButton.MouseButton1Click:Connect(function()
	FovEnabled = not FovEnabled
	FovCircle.Visible = FovEnabled
	if FovEnabled then
		FovButton.Text = "FOV Circle: ON"
		FovButton.TextColor3 = Color3.fromRGB(100, 245, 135)
		FovButton.BackgroundColor3 = Color3.fromRGB(38, 58, 46)
	else
		FovButton.Text = "FOV Circle: OFF"
		FovButton.TextColor3 = Color3.fromRGB(220, 140, 140)
		FovButton.BackgroundColor3 = Color3.fromRGB(50, 44, 48)
	end
end)

-- Obtener parte del pecho disponible del personaje
local function getChestPart(character)
	return character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
end

-- Buscar jugador más cercano dentro del FOV
local function getClosestTargetInFov()
	local closestData = nil
	local shortestDistance = math.huge
	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local head = character and character:FindFirstChild("Head")
			local chest = character and getChestPart(character)

			if humanoid and humanoid.Health > 0 and head and head:IsA("BasePart") and chest and chest:IsA("BasePart") then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen and screenPos.Z > 0 then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
					if (not FovEnabled or dist <= FovRadius) and dist < shortestDistance then
						shortestDistance = dist
						closestData = {
							Player = player,
							Character = character,
							Head = head,
							Chest = chest
						}
					end
				end
			end
		end
	end

	return closestData
end

-- Bucle de actualización del ESP de inventario (cada 0.25s para no bajar FPS)
task.spawn(function()
	while ScreenGui.Parent do
		if InvEspEnabled then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					pcall(updatePlayerInvEsp, player)
				end
			end
		end
		task.wait(0.25)
	end
end)

-- Actualizar objetivo en rojo cada frame sin mover la cámara
RunService.RenderStepped:Connect(function()
	FovCircle.Position = UDim2.new(0, Camera.ViewportSize.X / 2, 0, Camera.ViewportSize.Y / 2)
	FovCircle.Size = UDim2.new(0, FovRadius * 2, 0, FovRadius * 2)

	if not AimbotEnabled then
		clearTargetHighlight()
		return
	end

	local targetData = getClosestTargetInFov()
	if targetData then
		CurrentTarget = targetData
		Highlight.Adornee = targetData.Character
		Highlight.Enabled = true
	else
		clearTargetHighlight()
	end
end)

-- Elegir posición de impacto (alternando Cabeza y Pecho)
local function getNextAimPosition()
	if not CurrentTarget then return nil end
	shotToggle = not shotToggle
	if shotToggle then
		if CurrentTarget.Head and CurrentTarget.Head.Parent then
			return CurrentTarget.Head.Position
		end
	else
		if CurrentTarget.Chest and CurrentTarget.Chest.Parent then
			return CurrentTarget.Chest.Position
		end
	end
	return (CurrentTarget.Head and CurrentTarget.Head.Position) or (CurrentTarget.Chest and CurrentTarget.Chest.Position)
end

-- Silent Aim hook sin mover cámara
pcall(function()
	if not hookmetamethod or not getnamecallmethod then
		return
	end

	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local method = getnamecallmethod()
		local args = { ... }

		if AimbotEnabled and CurrentTarget and self == Workspace then
			local aimPos = getNextAimPosition()
			if aimPos then
				if method == "Raycast" and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
					local origin = args[1]
					args[2] = (aimPos - origin).Unit * args[2].Magnitude
					return oldNamecall(self, table.unpack(args))
				elseif method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
					local ray = args[1]
					if typeof(ray) == "Ray" then
						local newDirection = (aimPos - ray.Origin).Unit * ray.Direction.Magnitude
						args[1] = Ray.new(ray.Origin, newDirection)
						return oldNamecall(self, table.unpack(args))
					end
				end
			end
		end

		return oldNamecall(self, ...)
	end)
end)
