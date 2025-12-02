local Tunnel = module("vrp","lib/Tunnel");
local Proxy = module("vrp","lib/Proxy");
vRP = Proxy.getInterface("vRP");
--------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
--------------------------------------------------------------------------------------------------------------------------------
Client = {};
Tunnel.bindInterface(GetCurrentResourceName(), Client);
vSERVER = Tunnel.getInterface(GetCurrentResourceName());
--------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
--------------------------------------------------------------------------------------------------------------------------------
local blips = {};
local coords = nil;
local crate = nil;
local parachute = nil;
local pickingAirDrop = false;
local particleId = 0;
local x,y,z = nil;
local evento = nil;
local dropNoChao = false;
local delay = 0;
local time = Index.Main.time[1];
local minute = false;
local string = tostring(Index.Main.minutos[1]);
local delayToRobbery = Index.Main.delayToRobbery[1];
local seconds;
local start = false;
local tpdrop = false;
local tempo = false;

--------------------------------------------------------------------------------------------------------------------------------
-- REQUESTPARTICLE
--------------------------------------------------------------------------------------------------------------------------------
local function requestParticle(dict)
    RequestNamedPtfxAsset(dict);
    while not HasNamedPtfxAssetLoaded(dict) do
        RequestNamedPtfxAsset(dict);
        Citizen.Wait(50);
    end
    UseParticleFxAssetNextCall(dict);
end
--------------------------------------------------------------------------------------------------------------------------------
-- DRAWPARTICLE
--------------------------------------------------------------------------------------------------------------------------------
local function drawParticle(x, y, z, particleDict, particleName)
    requestParticle(particleDict);
    particleId = StartParticleFxLoopedAtCoord(particleName, x, y, z, 0.0, 0.0, 0.0, 2.0, false, false, false, false);
end
--------------------------------------------------------------------------------------------------------------------------------
-- DRAWTEXT
--------------------------------------------------------------------------------------------------------------------------------
local function drawText(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z);
	SetTextFont(6);
	SetTextScale(0.35,0.35);
	SetTextColour(255,255,255,150);
	SetTextEntry("STRING");
	SetTextCentre(1);
	AddTextComponentString(text);
	DrawText(_x,_y);
	local factor = (string.len(text))/400;
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,80);
end
--------------------------------------------------------------------------------------------------------------------------------
-- DRAWSCREEN
--------------------------------------------------------------------------------------------------------------------------------
local function drawScreen(text,font,x,y,scale)
	SetTextFont(font);
	SetTextScale(scale,scale);
	SetTextColour(255,255,255,150);
	SetTextOutline();
	SetTextCentre(1);
	SetTextEntry("STRING");
	AddTextComponentString(text);
	DrawText(x,y);
end
--------------------------------------------------------------------------------------------------------------------------------
-- CREATEAIRSUPPLYBLIP
--------------------------------------------------------------------------------------------------------------------------------
local function createAirSupplyBlip(index, delete, x, y, z, sprite, colour, scale, text)
    if not delete then
        blips[index] = AddBlipForCoord(x, y, z);
        SetBlipSprite(blips[index],sprite);
        SetBlipColour(blips[index],colour);
        SetBlipScale(blips[index],scale);
        SetBlipAsShortRange(blips[index],true);

        BeginTextCommandSetBlipName("STRING");
        AddTextComponentString(text);
        EndTextCommandSetBlipName(blips[index]);
    else
        if DoesBlipExist(blips[index]) then
            RemoveBlip(blips[index]);
        end
        blips[index] = nil;
    end
end
--------------------------------------------------------------------------------------------------------------------------------
-- PICKUPAIRDROP
--------------------------------------------------------------------------------------------------------------------------------
local function pickupAirDrop()
    local ped = PlayerPedId();
    local count = 0;

    pickingAirDrop = true;

    FreezeEntityPosition(ped, true);

    local function cancel()
        pickingAirDrop = false;
        FreezeEntityPosition(ped, false);
        ClearPedTasks(ped);
    end

    while count <= delayToRobbery do

        count = count + 1;
        if not IsEntityPlayingAnim(ped, "amb@medic@standing@tendtodead@idle_a", "idle_a", 3) then
            ClearPedTasksImmediately(ped); 
            vRP.playAnim(false, {"amb@medic@standing@tendtodead@idle_a", "idle_a"}, true)
            Wait(500);
        end
        if GetEntityHealth(ped) <= 101 or IsControlJustPressed(0, 168) then
            cancel();
            return false;
        end

        drawText(x,y,z, 'AGUARDE ~b~'..math.ceil((delayToRobbery-count)/100)..' ~w~SEGUNDOS, LOOTEANDO... (~b~F7~w~ PARA CANCELAR)')

        Citizen.Wait(4);
    end

    cancel();
    return true;
end
--------------------------------------------------------------------------------------------------------------------------------
-- CHECKAREACLEAROFPLAYER
--------------------------------------------------------------------------------------------------------------------------------
local function checkAreaClearOfPlayer(radius)

    local ped = PlayerPedId();
    local pedCoords = GetEntityCoords(ped);

    for k, v in pairs(GetActivePlayers()) do
        local nped = GetPlayerPed(v);
        local npedCoords = GetEntityCoords(nped);
        if ped ~= nped then
            if Vdist2(pedCoords,npedCoords) <= radius then
                if GetEntityHealth(nped) > 101 then
                    return false;
                end
            end
        end
    end

    return true;
end
--------------------------------------------------------------------------------------------------------------------------------
-- FINISHEVENT
--------------------------------------------------------------------------------------------------------------------------------
function Client.finishEvent()

    if DoesEntityExist(crate) then
        DeleteEntity(crate);
    end

    if DoesEntityExist(dropNoChao) then
        DeleteEntity(dropNoChao);
    end

    if DoesEntityExist(parachute) then
        DeleteEntity(parachute);
    end

    DeleteObject(parachuteObj);
    DeleteObject(crateObj);

    coords = nil;
    crate = nil;
    parachute = nil;
    dropNoChao = false;
    minute = false;
    start = false;
    delay = 0;
    string = tostring(Index.Main.minutos[1]);
    seconds = '';

    createAirSupplyBlip('airSupplyArea', true);
    createAirSupplyBlip('airSupplyCenterFalling', true);
    createAirSupplyBlip('airSupplyCenterOnFloor', true);
    local ped = PlayerPedId();
    FreezeEntityPosition(ped, false);
end
--------------------------------------------------------------------------------------------------------------------------------
-- STARTEVENT
--------------------------------------------------------------------------------------------------------------------------------
function Client.startEvent(c,v,r, name)
    evento = 1;
    tpdrop = true;
    tempo = true;
    TriggerEvent('Notify', "amarelo","<b>ATENÇÃO</b> um suprimento está sendo encomendado, o <b>AIRDROP</b> está marcado no mapa.",15000);
    TriggerEvent('sounds:source', 'drop', 0.4);
    x, y, z = c,v,r;
    local crateObj = GetHashKey('prop_mil_crate_01');
    local parachuteObj = GetHashKey('p_parachute1_mp_dec');

    local sky = z + 250;
    local floor = z - 1.0;

    crate = CreateObject(crateObj, x, y, sky, false, true, false);
    SetEntityLodDist(crate, 450);
    SetEntityAsMissionEntity(crate,true,true);

    parachute = CreateObject(parachuteObj, x, y, sky, false, true, false);

    FreezeEntityPosition(crate, true);
    FreezeEntityPosition(parachute, true);

    AttachEntityToEntity(parachute, crate, 0, 0.0, 0.0, 3.4, 0.0, 0.0, 0.0, false, false, false, true, 2, true);

    blips['airSupplyArea'] = AddBlipForRadius(x, y, z, 115.0);
    SetBlipColour(blips['airSupplyArea'], 63);
    SetBlipAlpha(blips['airSupplyArea'], 38);

    createAirSupplyBlip('airSupplyCenterFalling', false, x, y, z, 94, 63, 0.9, '~b~Local: ~w~Caixa de Suprimentos STATUS: ~r~CAINDO');
    drawParticle(x, y, z-1.0, 'core', 'exp_grd_flare');

    while sky > floor do
        sky = sky - 0.1;
        SetEntityCoords(crate, x, y, sky);

        local ped = PlayerPedId();
        local pedCoords = GetEntityCoords(ped);
        local _, _, pedZ = table.unpack(pedCoords);

        if #(pedCoords - vector3( x, y, sky)) <= 1.7 then
            --SetEntityHealth(ped, 101)
            vRP.setHealth(101);
            TriggerEvent("Hud:sendStatus");
        end

        if sky - floor <= 1 then
            if parachute then
                DeleteEntity(parachute);
            end

            RemoveBlip(blips['airSupplyArea']);
            blips['airSupplyArea'] = AddBlipForRadius(x, y, z, 115.0);
            SetBlipColour(blips['airSupplyArea'], 63);
            SetBlipAlpha(blips['airSupplyArea'], 38);
            createAirSupplyBlip('airSupplyCenterFalling', true);
            createAirSupplyBlip('airSupplyCenterOnFloor', false, x, y, z, 478, 63, 0.9, '~b~Local: ~w~Caixa de Suprimentos STATUS: ~b~LOOT');
            StopParticleFxLooped(particleId, false);
            SetEntityCoords(crate,x,y,floor);
            PlaceObjectOnGroundProperly(crate);

            coords = c,v,r;
            dropNoChao = true;
            start = true;
            minute = true;
            delay = Index.Main.minutos[1];
            break;
        end
        Citizen.Wait(time);
    end
end
--------------------------------------------------------------------------------------------------------------------------------
-- MAINTHREAD
--------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        local ped = PlayerPedId();
        local pedCoords = GetEntityCoords(ped);
        local timeDistance = 2000;
        if evento ~= nil then
            timeDistance = 4;
            local dist = #(pedCoords - vector3(x,y,z));
            local alive = GetEntityHealth(ped) > 101;
            if not IsPedInAnyVehicle(ped) and alive and not pickingAirDrop and not create ~= nil and not dropNoChao == false then
                if dist <= 3.0 then
                    if delay > 0 then
                        drawText(x,y,z,'AGUARDE ~b~['..delay..']~w~ SEGUNDOS');
                    else
                        drawText(x,y,z,'~w~PRESSIONE ~b~[E]~w~ PARA ABRIR A CAIXA');
                    end
                    if dist <= 1.5 then
                        if IsControlJustPressed(0, 38) and delay == 0 then
                            if vSERVER.checkNearestPlayers() then
                                if pickupAirDrop() then
                                    if alive then
                                        local src = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped));
                                        vSERVER.finish(-1);
                                        vSERVER.getSupply(src);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        Wait(timeDistance);
    end
end)

CreateThread( function()
    while true do
        if dropNoChao then
            if delay > 0 then
                delay = delay - 1;
            elseif delay == 0 and start then
                --vSERVER.NotifyAll(-1, '[AIRSUPPLY] - A caixa de suprimentos foi aberta, roube-a antes que alguem chegue primeiro.');
                TriggerEvent('Notify', 'amarelo', 'A caixa de suprimentos pode ser aberta, roube-a antes que alguem chegue primeiro.',10000);
                start = false;
            end
            if dropNoChao and minute then
                if string == '60' then
                    seconds = '1';
                elseif string == '120' then
                    seconds = '2';
                elseif string == '180' then
                    seconds = '3';
                elseif string == '240' then
                    seconds = '4';
                elseif string == '300' then
                    seconds = '5';
                end
                TriggerEvent('Notify', 'amarelo', 'A caixa de suprimentos poderá ser aberta em <b>'..seconds.. '</b> minuto(s).',5000);
                minute = false;
            end

            --vSERVER.NotifyAll(-1, '[AIRSUPPLY] - A caixa de suprimentos poderá ser resgatada em <b>'..seconds.. '</b> minuto(s).');
            --[[ TriggerEvent('Notify', 'importante', '<b>[AIRSUPPLY]</b> - A caixa de suprimentos poderá ser aberta em <b>'..seconds.. '</b> minuto(s).');
            minute = false; ]]
        end
        Wait(1000);
    end
end)

--[[ RegisterCommand('tpdrop',function(source,rawCommand)
    if tpdrop then
        if tempo then
            tempo = false;
            SetEntityCoords(PlayerPedId(),x,y,z)
        else
            TriggerEvent("Notify","vermelho","Você não pode digitar este comando mais de 2x.",5000)
        end
    end
end) ]]