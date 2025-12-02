-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:SERVERMESSAGE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("chat:ServerMessage")
AddEventHandler("chat:ServerMessage",function(Message,Mode)
	local source = source
	local Passport = vRP.getUserId(source)
	if Passport then
		local Identity = vRP.getUserIdentity(Passport)
		local Messages = Message:gsub("[<>]","")
		TriggerClientEvent("chat:ClientMessage",source,Identity["name"].." "..Identity["name2"],Mode,Messages)

		local Players = vRPC.nearestPlayers(source,10)
		for Player,v in pairs(Players) do
			async(function()
				TriggerClientEvent("chat:ClientMessage",Player,Identity["name"].." "..Identity["name2"],Mode,Messages)
			end)
		end
	end
end)