local noClipEnabled = false

local freecamVeh = 0
if Config.NoClipType == 1 then
    function toggleFreecam(enabled, isInVis)
        noClipEnabled = enabled
        local ped = PlayerPedId()
        if not isInVis then
            SetEntityVisible(ped, not enabled)
        end
        SetPlayerInvincible(ped, enabled)
        FreezeEntityPosition(ped, enabled)

        if enabled then
            freecamVeh = GetVehiclePedIsIn(ped, false)
            if freecamVeh > 0 then
                NetworkSetEntityInvisibleToNetwork(freecamVeh, true)
                SetEntityCollision(freecamVeh, false, false)
            end
        end

        local function enableNoClip()
            lastTpCoords = GetEntityCoords(ped)

            SetFreecamActive(true)
            StartFreecamThread()

            Citizen.CreateThread(function()
                while IsFreecamActive() do
                    SetEntityLocallyInvisible(ped)
                    if freecamVeh > 0 then
                        if DoesEntityExist(freecamVeh) then
                            SetEntityLocallyInvisible(freecamVeh)
                        else
                            freecamVeh = 0
                        end
                    end
                    Wait(0)
                end

                if not DoesEntityExist(freecamVeh) then
                    freecamVeh = 0
                end
                if freecamVeh > 0 then
                    local coords = GetEntityCoords(ped)
                    NetworkSetEntityInvisibleToNetwork(freecamVeh, false)
                    SetEntityCollision(freecamVeh, true, true)
                    SetEntityCoords(freecamVeh, coords[1], coords[2], coords[3])
                    SetPedIntoVehicle(ped, freecamVeh, -1)
                    freecamVeh = 0
                end
            end)
        end

        local function disableNoClip()
            SetFreecamActive(false)
            SetGameplayCamRelativeHeading(0)
        end

        if not IsFreecamActive() and enabled then
            enableNoClip()
        end

        if IsFreecamActive() and not enabled then
            disableNoClip()
        end
    end
end

if Config.NoClipType == 4 then
local noclipEnabled = false
local ent
local invisible = nil
local noclipCam = nil
local speed = 1.0
local maxSpeed = 32.0
local minY, maxY = -150.0, 160.0
local inputRotEnabled = false
local disableControls = { 32, 33, 34, 35, 36, 12, 13, 14, 15, 16, 17 }
local cache = {}

function toggleNoclipMurai()
    CreateThread(function()
        local inVehicle = false

        if cache.vehicle then
            inVehicle = true
            ent = cache.vehicle
        else
            ent = cache.ped
        end

        local pos = GetEntityCoords(ent)
        local rot = GetEntityRotation(ent)
        noclipCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, rot.z, 75.0, true, 2)
        AttachCamToEntity(noclipCam, ent, 0.0, 0.0, 0.0, true)
        RenderScriptCams(true, false, 3000, true, false)
        FreezeEntityPosition(ent, true)
        SetEntityCollision(ent, false, false)
        SetEntityAlpha(ent, 0, false)
        SetPedCanRagdoll(cache.ped, false)
        SetEntityVisible(ent, false, false)

        if not inVehicle then
            ClearPedTasksImmediately(cache.ped)
        end

        if inVehicle then
            FreezeEntityPosition(cache.ped, true)
            SetEntityCollision(cache.ped, false, false)
            SetEntityAlpha(cache.ped, 0, false)
            SetEntityVisible(cache.ped, false, false)
        end

        while noclipEnabled do
            Wait(0)
            local _, fv = GetCamMatrix(noclipCam)
            if IsDisabledControlPressed(2, 17) then
                speed = math.min(speed + 0.1, maxSpeed)
            elseif IsDisabledControlPressed(2, 16) then
                speed = math.max(0.1, speed - 0.1)
            end

            local multiplier = 1.0
            if IsDisabledControlPressed(2, 209) then
                multiplier = 2.0
            elseif IsDisabledControlPressed(2, 19) then
                multiplier = 4.0
            elseif IsDisabledControlPressed(2, 36) then
                multiplier = 0.25
            end

            if IsDisabledControlPressed(2, 32) then
                local setPos = GetEntityCoords(ent) + fv * (speed * multiplier)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 33) then
                local setPos = GetEntityCoords(ent) - fv * (speed * multiplier)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            end

            if IsDisabledControlPressed(2, 34) then
                local setPos = GetOffsetFromEntityInWorldCoords(ent, -speed * multiplier, 0.0, 0.0)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 35) then
                local setPos = GetOffsetFromEntityInWorldCoords(ent, speed * multiplier, 0.0, 0.0)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            end

            if IsDisabledControlPressed(2, 22) then
                local setPos = GetOffsetFromEntityInWorldCoords(ent, 0.0, 0.0, multiplier * speed / 2)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 52) then
                local setPos = GetOffsetFromEntityInWorldCoords(ent, 0.0, 0.0, multiplier * -speed / 2) -- Q
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            end

            local camRot = GetCamRot(noclipCam, 2)
            SetEntityHeading(ent, (360 + camRot.z) % 360)
            SetEntityVisible(ent, false, false)

            if inVehicle then
                SetEntityVisible(cache.ped, false, false)
            end

            for i = 1, #disableControls do
                DisableControlAction(2, disableControls[i], true)
            end

            DisablePlayerFiring(cache.playerId, true)
        end

        DestroyCam(noclipCam, false)
        noclipCam = nil
        RenderScriptCams(false, false, 3000, true, false)
        FreezeEntityPosition(ent, false)
        SetEntityCollision(ent, true, true)
        ResetEntityAlpha(ent)
        SetPedCanRagdoll(cache.ped, true)
        SetEntityVisible(ent, not invisible, false)
        ClearPedTasksImmediately(cache.ped)
        if inVehicle then
            FreezeEntityPosition(cache.ped, false)
            SetEntityCollision(cache.ped, true, true)
            ResetEntityAlpha(cache.ped)
            SetEntityVisible(cache.ped, true, false)
            SetPedIntoVehicle(cache.ped, ent, -1)
        end
    end)
end
function checkInputRotation()
    CreateThread(function()
        while inputRotEnabled do
            while not noclipCam or IsPauseMenuActive() do Wait(0) end
            local axisX = GetDisabledControlNormal(0, 1)
            local axisY = GetDisabledControlNormal(0, 2)
            local sensitivity = GetProfileSetting(14) * 2

            if GetProfileSetting(15) == 0 then -- Invert controls
                sensitivity = -sensitivity
            end

            if math.abs(axisX) > 0 or math.abs(axisY) > 0 then
                local rotation = GetCamRot(noclipCam, 2)
                local rotz = rotation.z + (axisX * sensitivity)
                local yValue = axisY * sensitivity
                local rotx = rotation.x
                if rotx + yValue > minY and rotx + yValue < maxY then
                    rotx = rotation.x + yValue
                end

                SetCamRot(noclipCam, rotx, rotation.y, rotz, 2)
            end
            Wait(0)
        end
    end)
end

function toggleNoClipMode(forceMode)
    if forceMode ~= nil then
        noclipEnabled = forceMode
        inputRotEnabled = noclipEnabled
    else
        noclipEnabled = not noclipEnabled
        inputRotEnabled = noclipEnabled
    end

    if noclipEnabled and inputRotEnabled then
        toggleNoclipMurai()
        checkInputRotation()
    end
end
end

if Config.NoClipType == 3 then
    IsNoClipping      = false
    PlayerPed         = nil
    NoClipEntity      = nil
    Camera            = nil
    NoClipAlpha       = nil
    PlayerIsInVehicle = false
    ResourceName      = GetCurrentResourceName()

    MinY, MaxY        = -89.0, 89.0

    --[[
        Configurable values are commented.
    ]]

    -- Perspective values
    local PedFirstPersonNoClip      = true       -- No Clip in first person when not in a vehicle
    local VehFirstPersonNoClip      = false      -- No Clip in first person when in a vehicle
    local ESCEnable                 = true      -- Access Map during NoClip

    -- Speed settings
    local Speed                     = 1         -- Default: 1
    local MaxSpeed                  = 16.0      -- Default: 16.0

    -- Key bindings
    local MOVE_FORWARDS             = 32        -- Default: W
    local MOVE_BACKWARDS            = 33        -- Default: S
    local MOVE_LEFT                 = 34        -- Default: A
    local MOVE_RIGHT                = 35        -- Default: D
    local MOVE_UP                   = 44        -- Default: Q
    local MOVE_DOWN                 = 46        -- Default: E

    local SPEED_DECREASE            = 14        -- Default: Mouse wheel down
    local SPEED_INCREASE            = 15        -- Default: Mouse wheel up
    local SPEED_RESET               = 348       -- Default: Mouse wheel click
    local SPEED_SLOW_MODIFIER       = 36        -- Default: Left Control
    local SPEED_FAST_MODIFIER       = 21        -- Default: Left Shift
    local SPEED_FASTER_MODIFIER     = 19        -- Default: Left Alt


    local DisabledControls = function()
        HudWeaponWheelIgnoreSelection()
        DisableAllControlActions(0)
        DisableAllControlActions(1)
        DisableAllControlActions(2)
        EnableControlAction(0, 220, true)
        EnableControlAction(0, 221, true)
        EnableControlAction(0, 245, true)
        if ESCEnable then
            EnableControlAction(0, 200, true)
        end
    end

    local IsControlAlwaysPressed = function(inputGroup, control)
        return IsControlPressed(inputGroup, control) or IsDisabledControlPressed(inputGroup, control)
    end

    local IsPedDrivingVehicle = function(ped, veh)
        return ped == GetPedInVehicleSeat(veh, -1)
    end

    local SetupCam = function()
        local entityRot = GetEntityRotation(NoClipEntity)
        Camera = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(NoClipEntity), vector3(0.0, 0.0, entityRot.z), 75.0)
        SetCamActive(Camera, true)
        RenderScriptCams(true, true, 1000, false, false)

        if PlayerIsInVehicle == 1 then
            AttachCamToEntity(Camera, NoClipEntity, 0.0, VehFirstPersonNoClip == true and 0.5 or -4.5, VehFirstPersonNoClip == true and 1.0 or 2.0, true)
        else
            AttachCamToEntity(Camera, NoClipEntity, 0.0, PedFirstPersonNoClip == true and 0.0 or -2.0, PedFirstPersonNoClip == true and 1.0 or 0.5, true)
        end

    end

    local DestroyCamera = function()
        SetGameplayCamRelativeHeading(0)
        RenderScriptCams(false, true, 1000, true, true)
        DetachEntity(NoClipEntity, true, true)
        SetCamActive(Camera, false)
        DestroyCam(Camera, true)
    end

    local GetGroundCoords = function(coords)
        local rayCast               = StartShapeTestRay(coords.x, coords.y, coords.z, coords.x, coords.y, -10000.0, 1, 0)
        local _, hit, hitCoords     = GetShapeTestResult(rayCast)
        return (hit == 1 and hitCoords) or coords
    end

    local CheckInputRotation = function()
        local rightAxisX = GetControlNormal(0, 220)
        local rightAxisY = GetControlNormal(0, 221)

        local rotation = GetCamRot(Camera, 2)

        local yValue = rightAxisY * -5
        local newX
        local newZ = rotation.z + (rightAxisX * -10)
        if (rotation.x + yValue > MinY) and (rotation.x + yValue < MaxY) then
            newX = rotation.x + yValue
        end
        if newX ~= nil and newZ ~= nil then
            SetCamRot(Camera, vector3(newX, rotation.y, newZ), 2)
        end
        
        SetEntityHeading(NoClipEntity, math.max(0, (rotation.z % 360)))
    end

    RunNoClipThread = function()
        Citizen.CreateThread(function()
            while IsNoClipping do
                Citizen.Wait(0)
                CheckInputRotation()
                DisabledControls()

                if IsControlAlwaysPressed(2, SPEED_DECREASE) then
                    Speed = Speed - 0.5
                    if Speed < 0.5 then
                        Speed = 0.5
                    end
                elseif IsControlAlwaysPressed(2, SPEED_INCREASE) then
                    Speed = Speed + 0.5
                    if Speed > MaxSpeed then
                        Speed = MaxSpeed
                    end
                elseif IsDisabledControlJustReleased(0, SPEED_RESET) then
                    Speed = 1
                end

                local multi = 1.0
                if IsControlAlwaysPressed(0, SPEED_FAST_MODIFIER) then
                    multi = 2
                elseif IsControlAlwaysPressed(0, SPEED_FASTER_MODIFIER) then
                    multi = 4
                elseif IsControlAlwaysPressed(0, SPEED_SLOW_MODIFIER) then
                    multi = 0.25
                end

                if IsControlAlwaysPressed(0, MOVE_FORWARDS) then
                    local pitch = GetCamRot(Camera, 0)

                    if pitch.x >= 0 then
                        SetEntityCoordsNoOffset(NoClipEntity, GetOffsetFromEntityInWorldCoords(NoClipEntity, 0.0, 0.5*(Speed * multi), (pitch.x*((Speed/2) * multi))/89))
                    else
                        SetEntityCoordsNoOffset(NoClipEntity, GetOffsetFromEntityInWorldCoords(NoClipEntity, 0.0, 0.5*(Speed * multi), -1*((math.abs(pitch.x)*((Speed/2) * multi))/89)))
                    end
                elseif IsControlAlwaysPressed(0, MOVE_BACKWARDS) then
                    local pitch = GetCamRot(Camera, 2)

                    if pitch.x >= 0 then
                        SetEntityCoordsNoOffset(NoClipEntity, GetOffsetFromEntityInWorldCoords(NoClipEntity, 0.0, -0.5*(Speed * multi), -1*(pitch.x*((Speed/2) * multi))/89))
                    else
                        SetEntityCoordsNoOffset(NoClipEntity, GetOffsetFromEntityInWorldCoords(NoClipEntity, 0.0, -0.5*(Speed * multi), ((math.abs(pitch.x)*((Speed/2) * multi))/89)))
                    end
                end

                if IsControlAlwaysPressed(0, MOVE_LEFT) then
                    SetEntityCoordsNoOffset(NoClipEntity, GetOffsetFromEntityInWorldCoords(NoClipEntity, -0.5*(Speed * multi), 0.0, 0.0))
                elseif IsControlAlwaysPressed(0, MOVE_RIGHT) then
                    SetEntityCoordsNoOffset(NoClipEntity, GetOffsetFromEntityInWorldCoords(NoClipEntity, 0.5*(Speed * multi), 0.0, 0.0))
                end

                if IsControlAlwaysPressed(0, MOVE_UP) then
                    SetEntityCoordsNoOffset(NoClipEntity, GetOffsetFromEntityInWorldCoords(NoClipEntity, 0.0, 0.0, 0.5*(Speed * multi)))
                elseif IsControlAlwaysPressed(0, MOVE_DOWN) then
                    SetEntityCoordsNoOffset(NoClipEntity, GetOffsetFromEntityInWorldCoords(NoClipEntity, 0.0, 0.0, -0.5*(Speed * multi)))
                end

                local coords = GetEntityCoords(NoClipEntity)
    
                RequestCollisionAtCoord(coords.x, coords.y, coords.z)

                FreezeEntityPosition(NoClipEntity, true)
                SetEntityCollision(NoClipEntity, false, false)
                SetEntityVisible(NoClipEntity, false, false)
                SetEntityInvincible(NoClipEntity, true)
                SetLocalPlayerVisibleLocally(true)
                SetEntityAlpha(NoClipEntity, NoClipAlpha, false)
                if PlayerIsInVehicle == 1 then
                    SetEntityAlpha(PlayerPed, NoClipAlpha, false)
                end
                SetEveryoneIgnorePlayer(PlayerPed, true)
                SetPoliceIgnorePlayer(PlayerPed, true)
            end
            StopNoClip()
        end)
    end

    StopNoClip = function()
        FreezeEntityPosition(NoClipEntity, false)
        SetEntityCollision(NoClipEntity, true, true)
        SetEntityVisible(NoClipEntity, true, false)
        SetLocalPlayerVisibleLocally(true)
        ResetEntityAlpha(NoClipEntity)
        ResetEntityAlpha(PlayerPed)
        SetEveryoneIgnorePlayer(PlayerPed, false)
        SetPoliceIgnorePlayer(PlayerPed, false)
        ResetEntityAlpha(NoClipEntity)
        SetPoliceIgnorePlayer(PlayerPed, true)

        if GetVehiclePedIsIn(PlayerPed, false) ~= 0 then
            while (not IsVehicleOnAllWheels(NoClipEntity)) and not IsNoClipping do
                Wait(0)
            end
            while not IsNoClipping do
                Wait(0)
                if IsVehicleOnAllWheels(NoClipEntity) then
                    return SetEntityInvincible(NoClipEntity, false)
                end
            end
        else
            if (IsPedFalling(NoClipEntity) and math.abs(1 - GetEntityHeightAboveGround(NoClipEntity)) > 1.00) then
                while (IsPedStopped(NoClipEntity) or not IsPedFalling(NoClipEntity)) and not IsNoClipping do
                    Wait(0)
                end
            end
            while not IsNoClipping do
                Wait(0)
                if (not IsPedFalling(NoClipEntity)) and (not IsPedRagdoll(NoClipEntity)) then
                    return SetEntityInvincible(NoClipEntity, false)
                end
            end
        end
    end

    ToggleNoClip = function(state)
        IsNoClipping = state or not IsNoClipping
        PlayerPed    = PlayerPedId()
        PlayerIsInVehicle = IsPedInAnyVehicle(PlayerPed, false)
        if PlayerIsInVehicle ~= 0 and IsPedDrivingVehicle(PlayerPed, GetVehiclePedIsIn(PlayerPed, false)) then
            NoClipEntity = GetVehiclePedIsIn(PlayerPed, false)
            SetVehicleEngineOn(NoClipEntity, not IsNoClipping, true, IsNoClipping)
            NoClipAlpha = VehFirstPersonNoClip == true and 0 or 51
        else
            NoClipEntity = PlayerPed
            NoClipAlpha = VehFirstPersonNoClip == true and 0 or 51
        end

        if IsNoClipping then
            FreezeEntityPosition(PlayerPed)
            SetupCam()
            PlaySoundFromEntity(-1, "SELECT", PlayerPed, "HUD_LIQUOR_STORE_SOUNDSET", 0, 0)

            if not PlayerIsInVehicle then
                ClearPedTasksImmediately(PlayerPed)
                if PedFirstPersonNoClip then
                    Citizen.Wait(1000) -- Wait for the cinematic effect of the camera transitioning into first person 
                end
            else
                if VehFirstPersonNoClip then
                    Citizen.Wait(1000) -- Wait for the cinematic effect of the camera transitioning into first person 
                end
            end

        else
            local groundCoords      = GetGroundCoords(GetEntityCoords(NoClipEntity))
            SetEntityCoords(NoClipEntity, groundCoords.x, groundCoords.y, groundCoords.z)
            Citizen.Wait(50)
            DestroyCamera()
            PlaySoundFromEntity(-1, "CANCEL", PlayerPed, "HUD_LIQUOR_STORE_SOUNDSET", 0, 0)
        end
        
        SetUserRadioControlEnabled(not IsNoClipping)
    
        if IsNoClipping then
            RunNoClipThread()
        end
    end

    RegisterNetEvent('mri-Qadmin:client:ToggleNoClip', function()
        ToggleNoClip(not IsNoClipping)
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName == ResourceName then
            FreezeEntityPosition(NoClipEntity, false)
            FreezeEntityPosition(PlayerPed, false)
            SetEntityCollision(NoClipEntity, true, true)
            SetEntityVisible(NoClipEntity, true, false)
            SetLocalPlayerVisibleLocally(true)
            ResetEntityAlpha(NoClipEntity)
            ResetEntityAlpha(PlayerPed)
            SetEveryoneIgnorePlayer(PlayerPed, false)
            SetPoliceIgnorePlayer(PlayerPed, false)
            ResetEntityAlpha(NoClipEntity)
            SetPoliceIgnorePlayer(PlayerPed, true)
            SetEntityInvincible(NoClipEntity, false)
        end
    end)
end