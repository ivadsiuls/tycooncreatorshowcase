local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local SellPart = {}
SellPart.__index = SellPart

local function onTouched(otherPart, _serviceBag: ServiceBag.ServiceBag)
	if not CollectionService:HasTag(otherPart, "CashPart") then
		return
	end

	local CashService = _serviceBag:GetService(require("CashService"))

	local player = Players:GetPlayerByUserId(otherPart:GetAttribute("Owner"))

	otherPart:Destroy()

	if not player then
		return
	end

	CashService:AddCash(player, otherPart:GetAttribute("CashValue"))
end

function SellPart.new(part, _serviceBag: ServiceBag.ServiceBag)
	local maid = Maid.new()

	part.Touched:Connect(function(otherPart)
		onTouched(otherPart, _serviceBag)
	end)

	return setmetatable({
		_maid = maid,
	}, SellPart)
end

function SellPart:Destroy()
	self._maid:Destroy()
	setmetatable(self, nil)
end

local binder = Binder.new("SellPart", SellPart)

return binder
