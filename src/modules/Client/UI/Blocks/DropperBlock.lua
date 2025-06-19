local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local AccelTween = require("AccelTween")
local Blend = require("Blend")
local Maid = require("Maid")
local RxAttributeUtils = require("RxAttributeUtils")
local ServiceBag = require("ServiceBag")

local DropperBlock = {}
DropperBlock.__index = DropperBlock

function DropperBlock.new(buildFrame, _serviceBag: ServiceBag.ServiceBag, viewportCamera: Camera)
	local maid = Maid.new()

	local self = setmetatable({}, DropperBlock)

	self._maid = maid
	self._serviceBag = _serviceBag

	self.BuildServiceClient = self._serviceBag:GetService(require("BuildServiceClient"))

	self.buildFrame = buildFrame

	self.viewportCamera = viewportCamera

	self:Init()

	return self
end

function DropperBlock:_onActivated()
	if self.BuildServiceClient:StartPlacementMode("Dropper") == true then
		self.closeButton.Visible = true
	end
end

function DropperBlock:Init()
	local render = Blend.New "ImageButton" {
		Name = "DropperBlockButton",

		BackgroundTransparency = 1,

		Size = UDim2.fromScale(1, 1),

		Parent = self.buildFrame,

		Blend.New "UIAspectRatioConstraint" {},

		Blend.New "ViewportFrame" {
			Name = "Viewport",

			Size = UDim2.fromScale(1, 1),

			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),

			CurrentCamera = self.viewportCamera,
		},

		Blend.New "ImageLabel" {
			AnchorPoint = Vector2.new(0.5, 0.5),

			Position = UDim2.fromScale(0.95, 0.05),

			Size = UDim2.fromScale(0.4, 0.4),

			BackgroundTransparency = 1,

			Name = "InputIcon",

			Blend.New "UIAspectRatioConstraint" {},
		},

		[Blend.OnEvent "Activated"] = function()
			self:_onActivated()
		end,
	}

	render:Subscribe(function(button)
		self.mainButton = button
		self.viewport = button:FindFirstChildWhichIsA("ViewportFrame")

		local blockModel = ReplicatedStorage.Assets.Blocks:FindFirstChild("Dropper")

		local viewportBlock = blockModel:Clone()
		viewportBlock:PivotTo(CFrame.new(Vector3.new(0, 9, -20)) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)))

		viewportBlock:SetAttribute("SpinVelocity", 25)

		viewportBlock.Parent = self.viewport

		local tween = AccelTween.new()
		tween.t = 360

		local velocity

		self._maid:GiveTask(
			Blend.Spring(RxAttributeUtils.observeAttribute(viewportBlock, "SpinVelocity", 25)):Subscribe(function(value)
				velocity = value
			end)
		)

		self._maid:GiveTask(RunService.PreRender:Connect(function()
			if self.BuildServiceClient:GetPlacingBlockName() == "Dropper" then
				tween.v = 0
				return
			end

			viewportBlock:PivotTo(
				CFrame.new(Vector3.new(0, 9, -20)) * CFrame.Angles(math.rad(0), math.rad(tween.p), math.rad(0))
			)
			tween.v = -velocity
		end))
	end)

	local closeButton = Blend.New "ImageButton" {
		Name = "CloseButton",

		Image = "rbxassetid://1249929622",

		BackgroundTransparency = 1,

		Size = UDim2.fromScale(1, 1),

		Visible = false,

		Parent = self.mainButton,

		[Blend.OnEvent "Activated"] = function()
			self.BuildServiceClient:StopPlacementMode()
		end,
	}

	closeButton:Subscribe(function(button)
		self.closeButton = button

		self._maid:GiveTask(self.BuildServiceClient:GetPlacementStoppedSignal():Connect(function()
			self.closeButton.Visible = false
		end))
	end)
end

return DropperBlock
