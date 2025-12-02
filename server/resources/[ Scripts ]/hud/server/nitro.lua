nitro = {}

if Config.EnableNitro then

    RegisterUsableItem(Config.NitroItem, function(source)
        TriggerClientEvent('hud:SetupNitro', source)
    end)

    RegisterServerEvent('hud:InstallNitro')
    AddEventHandler('hud:InstallNitro', function(plate)
        local src = source
        if plate then
            nitro[plate] = 100
            TriggerClientEvent('hud:UpdateNitroData', -1, nitro)
        end
    end)
    
    RegisterServerEvent('hud:UpdateNitro')
    AddEventHandler('hud:UpdateNitro', function(plate, val)
        local src = source
        if plate then
            if nitro[plate] then
                nitro[plate] = val
                TriggerClientEvent('hud:UpdateNitroData', -1, nitro)
            end
        end
    end)
end
