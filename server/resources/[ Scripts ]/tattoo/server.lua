local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","tattoo")
vRPloja = Tunnel.getInterface("tattoo")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
cx = {}
Tunnel.bindInterface("tattoo",cx)
src = Tunnel.getInterface("tattoo")

-----------------------------------------------------------------------------------------------------------------------------------------
-- Functions
-----------------------------------------------------------------------------------------------------------------------------------------
function cx.getTattooShops()
    return tattooShop
end

function cx.getTattoo()
    local source = source
    local user_id = vRP.getUserId(source)
    local custom = {}
    local data = vRP.getUData(user_id,"vRP:tattoos")
     if data ~= '' then
        custom = json.decode(data)  
        src.setTattoos(source,custom)
        Wait(100)
        src.applyTatto(source)
     else         
        src.setTattoos(source,custom)
        Wait(100)
        src.applyTatto(source)
     end
end

function cx.payment(price, totalPrice, newTatto)
    local source = source 
    local user_id = vRP.getUserId(source)
    if parseInt(price) == parseInt(totalPrice) then
        if vRP.paymentBank(user_id,parseInt(totalPrice)) or totalPrice == 0 then
            TriggerClientEvent("Notify",source,"Sucesso","Você pagou <b>$"..totalPrice.." Reais</b> em suas tatuagens.",5000)
            vRP.setUData(user_id,"vRP:tattoos",json.encode(newTatto))
            src.payment(source, true)
        else 
            TriggerClientEvent("Notify",source,"Negado","Você não tem dinheiro suficiente",5000)
            src.payment(source, false)
        end 
    else 
        TriggerClientEvent("Notify",source,"Negado","Ocorreu um erro na sua compra! Tente novamente!",5000)
        src.payment(source, false)
        
    end
end

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
    local source = source
    local custom = {}
    local data = vRP.getUData(user_id,"vRP:tattoos")

    if data ~= '' then
        custom = json.decode(data)
        src.setTattoos(source,custom)
        Wait(100)
        src.applyTatto(source)
    else 
        src.setTattoos(source,custom)
        Wait(100)
        src.applyTatto(source)
    end 
end)

