-- Sprscript v2.2 | Menú Mediano Centrado + FOV + Silent Aim Cabeza/Pecho + Inventario (Blockspin)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Estado del script
local AimbotEnabled = false
local FovEnabled = true
local MenuOpen = true
local InvOpen = false
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

-- Botón "Inventario" (Blockspin)
local InvButton = Instance.new("TextButton")
InvButton.Name = "InvButton"
InvButton.Size = UDim2.new(0, 236, 0, 38)
InvButton.Position = UDim2.new(0, 12, 0, 98)
InvButton.BackgroundColor3 = Color3.fromRGB(44, 52, 74)
InvButton.Text = "Inventario (Blockspin)"
InvButton.TextColor3 = Color3.fromRGB(165, 205, 255)
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
InfoLabel.Text = "Silent Aim: Cabeza / Pecho"
InfoLabel.TextColor3 = Color3.fromRGB(185, 185, 200)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.ZIndex = 6
InfoLabel.Parent = MenuFrame

-- Ventana de Inventario (Blockspin)
local InvFrame = Instance.new("Frame")
InvFrame.Name = "InvFrame"
InvFrame.Size = UDim2.new(0, 250, 0, 210)
InvFrame.Position = UDim2.new(0, 270, 0, 0)
InvFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
InvFrame.BorderSizePixel = 0
InvFrame.Visible = InvOpen
InvFrame.ZIndex = 7
InvFrame.Parent = TopBar

local InvFrameCorner = Instance.new("UICorner")
InvFrameCorner.CornerRadius = UDim.new(0, 10)
InvFrameCorner.Parent = InvFrame

local InvFrameStroke = Instance.new("UIStroke")
InvFrameStroke.Color = Color3.fromRGB(90, 110, 150)
InvFrameStroke.Thickness = 1.4
InvFrameStroke.Parent = InvFrame

local InvTitle = Instance.new("TextLabel")
InvTitle.Name = "InvTitle"
InvTitle.Size = UDim2.new(0, 190, 0, 30)
InvTitle.Position = UDim2.new(0, 10, 0, 6)
InvTitle.BackgroundTransparency = 1
InvTitle.Text = "Inventario Blockspin"
InvTitle.TextXAlignment = Enum.TextXAlignment.Left
InvTitle.TextColor3 = Color3.fromRGB(245, 245, 255)
InvTitle.TextSize = 14
InvTitle.Font = Enum.Font.GothamBold
InvTitle.ZIndex = 8
InvTitle.Parent = InvFrame

local CloseInvBtn = Instance.new("TextButton")
CloseInvBtn.Name = "CloseInvBtn"
CloseInvBtn.Size = UDim2.new(0, 32, 0, 28)
CloseInvBtn.Position = UDim2.new(0, 208, 0, 7)
CloseInvBtn.BackgroundColor3 = Color3.fromRGB(65, 35, 38)
CloseInvBtn.Text = "X"
CloseInvBtn.TextColor3 = Color3.fromRGB(255, 130, 130)
CloseInvBtn.TextSize = 13
CloseInvBtn.Font = Enum.Font.GothamBold
CloseInvBtn.ZIndex = 8
CloseInvBtn.Parent = InvFrame

local CloseInvCorner = Instance.new("UICorner")
CloseInvCorner.CornerRadius = UDim.new(0, 6)
CloseInvCorner.Parent = CloseInvBtn

local InvScroll = Instance.new("ScrollingFrame")
InvScroll.Name = "InvScroll"
InvScroll.Size = UDim2.new(0, 230, 0, 162)
InvScroll.Position = UDim2.new(0, 10, 0, 40)
InvScroll.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
InvScroll.BorderSizePixel = 0
InvScroll.ScrollBarThickness = 4
InvScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
InvScroll.ZIndex = 8
InvScroll.Parent = InvFrame

local InvScrollCorner = Instance.new("UICorner")
InvScrollCorner.CornerRadius = UDim.new(0, 8)
InvScrollCorner.Parent = InvScroll

local InvListLayout = Instance.new("UIListLayout")
InvListLayout.Padding = UDim.new(0, 5)
InvListLayout.SortOrder = Enum.SortOrder.LayoutOrder
InvListLayout.Parent = InvScroll

-- Detectar tipo de arma/ítem (bate, glock, rifle, etc.)
local function classifyItem(name)
	local lower = string.lower(name)
	if string.find(lower, "bat") or string.find(lower, "bate") or string.find(lower, "club") or string.find(lower, "melee") or string.find(lower, "knife") or string.find(lower, "cuchillo") then
		return "[Cuerpo a cuerpo]"
	elseif string.find(lower, "glock") or string.find(lower, "pistol") or string.find(lower, "9mm") or string.find(lower, "deagle") or string.find(lower, "revolver") then
		return "[Pistola]"
	elseif string.find(lower, "ak") or string.find(lower, "ar") or string.find(lower, "rifle") or string.find(lower, "m4") or string.find(lower, "draco") or string.find(lower, "shotgun") or string.find(lower, "smg") or string.find(lower, "uzi") then
		return "[Arma]"
	end
	return "[Ítem]"
end

-- Refrescar lista de inventario
local function refreshInventory()
	for _, child in ipairs(InvScroll:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	local foundItems = {}
	local seen = {}

	local function addTool(tool, estado)
		if tool and tool:IsA("Tool") then
			local key = tool.Name .. "_" .. estado
			if not seen[key] then
				seen[key] = true
				table.insert(foundItems, {
					Name = tool.Name,
					Tipo = classifyItem(tool.Name),
					Estado = estado
				})
			end
		end
	end

	-- Armas equipadas en el personaje
	local char = LocalPlayer.Character
	if char then
		for _, item in ipairs(char:GetChildren()) do
			addTool(item, "Equipada")
		end
	end

	-- Armas en Backpack
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			addTool(item, "Mochila")
		end
	end

	if #foundItems == 0 then
		local emptyLbl = Instance.new("TextLabel")
		emptyLbl.Size = UDim2.new(1, -8, 0, 28)
		emptyLbl.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
		emptyLbl.Text = "No hay armas/ítems en Backpack"
		emptyLbl.TextColor3 = Color3.fromRGB(170, 170, 185)
		emptyLbl.TextSize = 12
		emptyLbl.Font = Enum.Font.GothamMedium
		emptyLbl.ZIndex = 9
		emptyLbl.Parent = InvScroll

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = emptyLbl
	else
		for i, entry in ipairs(foundItems) do
			local row = Instance.new("TextLabel")
			row.LayoutOrder = i
			row.Size = UDim2.new(1, -8, 0, 30)
			row.BackgroundColor3 = entry.Estado == "Equipada" and Color3.fromRGB(36, 56, 44) or Color3.fromRGB(30, 30, 38)
			row.Text = string.format(" %s %s (%s)", entry.Tipo, entry.Name, entry.Estado)
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.TextColor3 = entry.Estado == "Equipada" and Color3.fromRGB(130, 250, 160) or Color3.fromRGB(235, 235, 245)
			row.TextSize = 12
			row.Font = Enum.Font.GothamBold
			row.ZIndex = 9
			row.Parent = InvScroll

			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, 6)
			c.Parent = row
		end
	end

	task.wait()
	InvScroll.CanvasSize = UDim2.new(0, 0, 0, InvListLayout.AbsoluteContentSize.Y + 8)
end

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
	if not MenuOpen then
		InvOpen = false
		InvFrame.Visible = false
	end
end)

-- Abrir/cerrar inventario
InvButton.MouseButton1Click:Connect(function()
	InvOpen = not InvOpen
	InvFrame.Visible = InvOpen
	if InvOpen then
		refreshInventory()
	end
end)

CloseInvBtn.MouseButton1Click:Connect(function()
	InvOpen = false
	InvFrame.Visible = false
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
