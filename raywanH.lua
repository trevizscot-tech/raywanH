--// Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Variáveis
local ESPAtivado = false
local AimbotAtivado = false
local CampoDeVisao = 200
local ParteAlvo = "Head"

local alvoAtual = nil
local tocando = false
local suavizacao = 0.15
local espGuis = {}

--// GUI Principal
local Gui = Instance.new("ScreenGui")
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
Gui.Name = "ESP_Aimbot_GUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true

--// Mensagem
local welcome = Instance.new("TextLabel")
welcome.Parent = Gui
welcome.Size = UDim2.new(0,300,0,60)
welcome.Position = UDim2.new(0.5,-150,0.2,0)

welcome.BackgroundColor3 = Color3.fromRGB(15,15,15)
welcome.TextColor3 = Color3.fromRGB(0,255,150)
welcome.TextScaled = true
welcome.Font = Enum.Font.GothamBold
welcome.Text = "Bem vindo a RayScript"
welcome.BorderSizePixel = 0

Instance.new("UICorner",welcome).CornerRadius = UDim.new(0,10)
Instance.new("UIStroke",welcome).Transparency = 0.4

task.delay(3,function()
	welcome:Destroy()
end)

--// Criar Botão
local function criarBotao(parent,texto,pos)

	local b = Instance.new("TextButton")
	b.Parent = parent
	b.Size = UDim2.new(1,-20,0,38)
	b.Position = pos

	b.Text = texto
	b.BackgroundColor3 = Color3.fromRGB(35,35,35)
	b.TextColor3 = Color3.fromRGB(255,255,255)

	b.TextScaled = true
	b.Font = Enum.Font.GothamBold
	b.BorderSizePixel = 0

	local corner = Instance.new("UICorner",b)
	corner.CornerRadius = UDim.new(0,8)

	local stroke = Instance.new("UIStroke",b)
	stroke.Color = Color3.fromRGB(0,170,255)
	stroke.Transparency = 0.4
	stroke.Thickness = 1.2

	return b
end

--// Frame menu
local frame = Instance.new("Frame")
frame.Parent = Gui
frame.Size = UDim2.new(0,200,0,310)
frame.Position = UDim2.new(0,10,1,-360)

frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BorderSizePixel = 0
frame.Visible = false

Instance.new("UICorner",frame).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke",frame)
stroke.Color = Color3.fromRGB(0,170,255)
stroke.Transparency = 0.4
stroke.Thickness = 1.5

local titulo = Instance.new("TextLabel")
titulo.Parent = frame
titulo.Size = UDim2.new(1,0,0,35)

titulo.BackgroundTransparency = 1
titulo.Text = "RayScript"

titulo.TextColor3 = Color3.fromRGB(0,200,255)
titulo.Font = Enum.Font.GothamBold
titulo.TextScaled = true

--// Botão flutuante
local botMenu = Instance.new("ImageButton")
botMenu.Parent = Gui

botMenu.Size = UDim2.new(0,50,0,50)
botMenu.Position = UDim2.new(0,10,1,-60)

botMenu.BackgroundColor3 = Color3.fromRGB(20,20,20)
botMenu.BorderSizePixel = 0
botMenu.Image = "rbxassetid://7072718362"

Instance.new("UICorner",botMenu).CornerRadius = UDim.new(1,0)

local strokeMenu = Instance.new("UIStroke",botMenu)
strokeMenu.Color = Color3.fromRGB(0,170,255)
strokeMenu.Transparency = 0.4

--// Abrir e fechar menu
botMenu.MouseButton1Click:Connect(function()

	if frame.Visible then

		frame:TweenSize(
			UDim2.new(0,0,0,0),
			Enum.EasingDirection.In,
			Enum.EasingStyle.Back,
			0.25,
			true
		)

		task.wait(0.25)
		frame.Visible = false

	else

		frame.Visible = true
		frame.Size = UDim2.new(0,0,0,0)

		frame:TweenSize(
			UDim2.new(0,200,0,310),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Back,
			0.3,
			true
		)

	end

end)

--// Arrastar botão
local dragging
local dragInput
local dragStart
local startPos

local function update(input)

	local delta = input.Position - dragStart

	botMenu.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)

end

botMenu.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = botMenu.Position

		input.Changed:Connect(function()

			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end

		end)
	end
end)

botMenu.InputChanged:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end

end)

UserInputService.InputChanged:Connect(function(input)

	if input == dragInput and dragging then
		update(input)
	end

end)

--// Botões
local botESP = criarBotao(frame,"ESP: OFF",UDim2.new(0,10,0,10))
local botAim = criarBotao(frame,"AIMBOT: OFF",UDim2.new(0,10,0,60))
local botFOVMais = criarBotao(frame,"AUMENTAR FOV",UDim2.new(0,10,0,110))
local botFOVMenos = criarBotao(frame,"DIMINUIR FOV",UDim2.new(0,10,0,160))
local botSuaveMais = criarBotao(frame,"SUAVE+: "..suavizacao,UDim2.new(0,10,0,210))
local botSuaveMenos = criarBotao(frame,"SUAVE-: "..suavizacao,UDim2.new(0,10,0,260))

--// FOV Circle
local fovCircle = Instance.new("Frame")
fovCircle.Parent = Gui
fovCircle.Size = UDim2.new(0,CampoDeVisao*2,0,CampoDeVisao*2)
fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
fovCircle.Position = UDim2.new(0.5,0,0.5,0)
fovCircle.BackgroundTransparency = 1

local strokeFOV = Instance.new("UIStroke")
strokeFOV.Parent = fovCircle
strokeFOV.Thickness = 2
strokeFOV.Color = Color3.new(1,1,1)
strokeFOV.Transparency = 0.4

local corner = Instance.new("UICorner")
corner.Parent = fovCircle
corner.CornerRadius = UDim.new(1,0)

--// BOTÕES

botESP.MouseButton1Click:Connect(function()

	ESPAtivado = not ESPAtivado
	botESP.Text = ESPAtivado and "ESP: ON" or "ESP: OFF"

	if not ESPAtivado then

		for p,gui in pairs(espGuis) do

			if gui.boxGui then gui.boxGui:Destroy() end
			if gui.nameGui then gui.nameGui:Destroy() end

		end

		espGuis = {}

	end

end)

botAim.MouseButton1Click:Connect(function()

	AimbotAtivado = not AimbotAtivado
	botAim.Text = AimbotAtivado and "AIMBOT: ON" or "AIMBOT: OFF"

end)

botFOVMais.MouseButton1Click:Connect(function()
	CampoDeVisao = math.min(CampoDeVisao + 25,500)
end)

botFOVMenos.MouseButton1Click:Connect(function()
	CampoDeVisao = math.max(CampoDeVisao - 25,25)
end)

botSuaveMais.MouseButton1Click:Connect(function()

	suavizacao = math.min(suavizacao + 0.05,1)

	botSuaveMais.Text = "SUAVE+: "..string.format("%.2f",suavizacao)
	botSuaveMenos.Text = "SUAVE-: "..string.format("%.2f",suavizacao)

end)

botSuaveMenos.MouseButton1Click:Connect(function()

	suavizacao = math.max(suavizacao - 0.05,0.01)

	botSuaveMais.Text = "SUAVE+: "..string.format("%.2f",suavizacao)
	botSuaveMenos.Text = "SUAVE-: "..string.format("%.2f",suavizacao)

end)

--// ESP
function criarESPnoPlayer(p)

	if p == LocalPlayer then return end
	if p.Team == LocalPlayer.Team then return end
	if espGuis[p] then return end
	if not p.Character then return end
	if not p.Character:FindFirstChild("HumanoidRootPart") then return end

	local hrp = p.Character.HumanoidRootPart
	local head = p.Character:FindFirstChild("Head")

	if not head then return end

	local boxGui = Instance.new("BillboardGui")
	boxGui.Parent = hrp
	boxGui.Size = UDim2.new(4,0,5,0)
	boxGui.AlwaysOnTop = true

	local box = Instance.new("Frame")
	box.Parent = boxGui
	box.Size = UDim2.new(1,0,1,0)
	box.BackgroundColor3 = Color3.new(1,0,0)
	box.BackgroundTransparency = 0.8
	box.BorderSizePixel = 2
	box.BorderColor3 = Color3.new(1,1,1)

	local nameGui = Instance.new("BillboardGui")
	nameGui.Parent = head
	nameGui.Size = UDim2.new(0,70,0,25)
	nameGui.StudsOffset = Vector3.new(0,2,0)
	nameGui.AlwaysOnTop = true

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Parent = nameGui
	nameLabel.Size = UDim2.new(1,0,1,0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.new(1,1,1)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = p.Name

	espGuis[p] = {boxGui = boxGui,nameGui = nameGui,nameLabel = nameLabel}

end

--// Encontrar alvo
function encontrarAlvo()

	local alvo = nil
	local menor = CampoDeVisao

	for _,p in ipairs(Players:GetPlayers()) do

		if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild(ParteAlvo) then

			local parte = p.Character[ParteAlvo]

			local pos,vis = Camera:WorldToViewportPoint(parte.Position)

			local dist = (Vector2.new(pos.X,pos.Y) - Camera.ViewportSize/2).Magnitude

			if vis and dist < menor then
				menor = dist
				alvo = parte
			end

		end

	end

	return alvo
end

--// Input
UserInputService.InputBegan:Connect(function(input)

	if AimbotAtivado and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
		tocando = true
	end

end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		tocando = false
		alvoAtual = nil
	end

end)

--// Loop
RunService.RenderStepped:Connect(function()

	fovCircle.Size = UDim2.new(0,CampoDeVisao*2,0,CampoDeVisao*2)

	if ESPAtivado then

		for _,p in ipairs(Players:GetPlayers()) do
			criarESPnoPlayer(p)
		end

		for p,gui in pairs(espGuis) do

			if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") or p.Team == LocalPlayer.Team then

				gui.boxGui:Destroy()
				gui.nameGui:Destroy()
				espGuis[p] = nil

			else

				local dist = math.floor((p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude)
				gui.nameLabel.Text = p.Name.." ("..dist.."m)"

			end

		end

	end

	if AimbotAtivado and tocando then

		alvoAtual = encontrarAlvo()

		if alvoAtual then

			Camera.CFrame = Camera.CFrame:Lerp(
				CFrame.new(Camera.CFrame.Position,alvoAtual.Position),
				suavizacao
			)

		end

	end

end)

--// Atualizar ESP novos jogadores
Players.PlayerAdded:Connect(function(p)

	p.CharacterAdded:Connect(function()

		task.wait(1)

		if ESPAtivado then
			criarESPnoPlayer(p)
		end

	end)

end)
