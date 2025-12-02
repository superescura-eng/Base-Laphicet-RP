local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local QBCore = {}
QBCore.PlayerData = {}
QBCore.Functions = {}
QBCore.Shared = {}
QBCore.Client = {}
QBCore.Server = {}
QBCore.Config = {}

-- Basic QBCore Functions mapping to vRP
function QBCore.Functions.GetPlayerData()
    return QBCore.PlayerData
end

function QBCore.Functions.GetPlate(vehicle)
    if vehicle == 0 then return nil end
    return GetVehicleNumberPlateText(vehicle)
end

function QBCore.Functions.TriggerCallback(name, cb, ...)
    vRP.TriggerServerCallback(name, cb, ...)
end

function QBCore.Functions.Notify(text, type, length)
    TriggerEvent("Notify", type, text, length)
end

-- Export GetCoreObject
exports('GetCoreObject', function()
    return QBCore
end)

-- Initialize PlayerData
CreateThread(function()
    while not vRP do Wait(100) end
    -- Map vRP data to QBCore.PlayerData here if needed
end)
