local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local QBCore = {}
QBCore.Functions = {}
QBCore.Player = {}

-- Basic QBCore Functions mapping to vRP
function QBCore.Functions.GetPlayer(source)
    local user_id = vRP.getUserId(source)
    if not user_id then return nil end

    local self = {}
    self.PlayerData = {
        source = source,
        citizenid = tostring(user_id),
        license = "license:"..user_id,
        name = "Player "..user_id,
        money = {
            cash = vRP.getMoney(user_id),
            bank = vRP.getBankMoney(user_id)
        },
        job = {
            name = "unemployed",
            label = "Desempregado",
            payment = 10,
            grade = { level = 0, name = "Freelancer" }
        }
    }

    self.Functions = {}
    
    function self.Functions.AddMoney(type, amount)
        if type == "cash" then
            vRP.giveMoney(user_id, amount)
        elseif type == "bank" then
            vRP.giveBankMoney(user_id, amount)
        end
    end

    function self.Functions.RemoveMoney(type, amount)
        if type == "cash" then
            vRP.tryPayment(user_id, amount)
        elseif type == "bank" then
            vRP.tryFullPayment(user_id, amount) -- vRP doesn't have tryBankPayment usually, uses tryFullPayment
        end
    end

    function self.Functions.SetJob(job, grade)
        -- vRP groups implementation needed here
    end

    return self
end

-- QBCore Commands
QBCore.Commands = {}
function QBCore.Commands.Add(name, help, arguments, argsrequired, callback, permission)
    RegisterCommand(name, function(source, args)
        local src = source
        local user_id = vRP.getUserId(src)
        if permission then
            if vRP.hasPermission(user_id, permission) or permission == "user" then
                callback(src, args)
            else
                TriggerClientEvent('QBCore:Notify', src, "You don't have permission to use this command.", "error")
            end
        else
            callback(src, args)
        end
    end, false)
end

function QBCore.Commands.Refresh(source)
    -- No-op for now
end

-- QBCore Shared
QBCore.Shared = {
    StarterItems = {
        { item = "id_card", amount = 1 },
        { item = "driver_license", amount = 1 },
        { item = "phone", amount = 1 }
    }
}

-- QBCore Functions
function QBCore.Functions.GetIdentifier(source, idtype)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.find(id, idtype) then
            return id
        end
    end
    return nil
end

function QBCore.Functions.CreateCallback(name, cb)
    vRP.RegisterServerCallback(name, cb)
end

function QBCore.Functions.CreateUseableItem(item, cb)
    -- vRP item usage mapping
end

-- QBCore Player
function QBCore.Player.Login(source, citizenid, newData)
    return true
end

function QBCore.Player.Logout(source)
    -- vRP doesn't support logout to char select easily
end

function QBCore.Player.DeleteCharacter(source, citizenid)
    -- Not implemented
end

function QBCore.Player.ForceDeleteCharacter(citizenid)
    -- Not implemented
end

-- Export GetCoreObject
exports('GetCoreObject', function()
    return QBCore
end)
