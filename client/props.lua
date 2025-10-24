--------------------------------------------
-- 📦 JLABS WAREHOUSE - Props (Fixed)
--------------------------------------------
GlobalProps = GlobalProps or {}
local confirmed = false
local heading = 0.0
local movingPropId = nil
local currentWarehouse = nil
local warehouseInteractionActive = false
--------------------------------------------------------
-- 📦 Warehouse Status
--------------------------------------------------------
RegisterNetEvent('jlabs-warehouse:client:setCurrentWarehouse', function(name)
    currentWarehouse = name

    if name and not warehouseInteractionActive then
        warehouseInteractionActive = true
        CreateThread(function()
            local uiActive = false
            while currentWarehouse do
                Wait(0)
                local ped = PlayerPedId()
                local pcoords = GetEntityCoords(ped)
                local closestId, closestEnt, closestDist = nil, nil, 1.8

                for propId, netId in pairs(GlobalProps) do
                    if netId and netId ~= 0 then
                        local ent = NetworkGetEntityFromNetworkId(netId)
                        if ent and DoesEntityExist(ent) then
                            local dist = #(pcoords - GetEntityCoords(ent))
                            if dist < closestDist then
                                closestId, closestEnt, closestDist = propId, ent, dist
                            end
                        end
                    end
                end

                if closestEnt then
                    if not uiActive then
                        uiActive = true
                        lib.showTextUI('[K] Pickup', {
                            position = 'left-center',
                            style = { background = '#ef1f43', color = 'white', borderRadius = 5 }
                        })
                    end

                    if IsControlJustPressed(0, 311) then -- K key
                        TriggerServerEvent('jlabs-warehouse:server:removeProp', closestId)
                        Wait(300)
                    end
                elseif uiActive then
                    uiActive = false
                    lib.hideTextUI()
                end
            end
            -- when leaving warehouse
            lib.hideTextUI()
            warehouseInteractionActive = false
        end)
    end
end)


RegisterNetEvent('jlabs-warehouse:client:clearCurrentWarehouse', function()
    currentWarehouse = nil
end)

--------------------------------------------------------
-- 🧱 Model & Math Helpers
--------------------------------------------------------
local function LoadModel(model)
    if type(model) == "string" then model = GetHashKey(model) end
    if not IsModelValid(model) then
        lib.notify({ title = 'Warehouse', description = 'Invalid model!', type = 'error' })
        return false
    end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(10) end
    return HasModelLoaded(model)
end

local function RotationToDirection(rotation)
    local radX, radZ = math.rad(rotation.x), math.rad(rotation.z)
    return vector3(-math.sin(radZ) * math.abs(math.cos(radX)),
                   math.cos(radZ) * math.abs(math.cos(radX)),
                   math.sin(radX))
end

local function RayCastCamera(dist)
    local camRot, camCoord = GetGameplayCamRot(), GetGameplayCamCoord()
    local dir = RotationToDirection(camRot)
    local dest = camCoord + dir * dist
    local handle = StartShapeTestRay(camCoord.x, camCoord.y, camCoord.z, dest.x, dest.y, dest.z, -1, PlayerPedId(), 0)
    local _, hit, endCoords, _, entity = GetShapeTestResult(handle)
    return hit, endCoords, entity
end

--------------------------------------------------------
-- 🧹 Entity Utilities
--------------------------------------------------------
local function GetEntityByPropId(propId)
    local netId = GlobalProps[propId]
    if not netId or netId == 0 then return nil end
    local ent = NetworkGetEntityFromNetworkId(netId)
    if ent and DoesEntityExist(ent) then return ent end
    return nil
end

local function SafeDeleteEntity(ent)
    if not ent or not DoesEntityExist(ent) then return end
    NetworkRequestControlOfEntity(ent)
    local timeout = GetGameTimer() + 2000
    while not NetworkHasControlOfEntity(ent) and GetGameTimer() < timeout do
        Wait(10)
        NetworkRequestControlOfEntity(ent)
    end
    SetEntityAsMissionEntity(ent, false, true)
    FreezeEntityPosition(ent, false)
    DeleteEntity(ent)
end

local function SafeDeleteByPropId(propId)
    local ent = GetEntityByPropId(propId)
    if ent then SafeDeleteEntity(ent) end
    GlobalProps[propId] = nil
end

--------------------------------------------------------
-- 🎯 Target Setup
--------------------------------------------------------
local function AddWarehousePropTarget(propId, obj, cfg)
    if not DoesEntityExist(obj) then return end
    exports.ox_target:removeEntity(obj)
    if cfg.type == 'stash' then
        exports.ox_target:addLocalEntity(obj, {{
            label = ('Open %s'):format(cfg.label),
            icon = 'fa-solid fa-box-archive',
            distance = 2.0,
            onSelect = function()
                TriggerServerEvent('jlabs-warehouse:server:openStash', propId, cfg.label, cfg.slots, cfg.weight)
            end
        }})
    elseif cfg.type == 'clothing' then
        exports.ox_target:addLocalEntity(obj, {{
            label = ('Use %s'):format(cfg.label),
            icon = 'fa-solid fa-shirt',
            distance = 2.0,
            onSelect = function()
                TriggerEvent('illenium-appearance:openWardrobe')
            end
        }})
    end
end

--------------------------------------------------------
-- 🧱 Spawn & Delete Props
--------------------------------------------------------
RegisterNetEvent('jlabs-warehouse:client:spawnProp', function(data)
    if not LoadModel(data.model) then return end

    -- ✅ FIX: ensure true,true to make it networked
    local obj = CreateObject(data.model, data.pos.x, data.pos.y, data.pos.z, true, true, false)
    if not DoesEntityExist(obj) then
        print(('[JLABS] Failed to create object for prop ID %s'):format(data.id))
        return
    end

    SetEntityRotation(obj, data.rot.x, data.rot.y, data.rot.z, 2, true)
    FreezeEntityPosition(obj, true)
    SetEntityInvincible(obj, true)
    SetEntityAsMissionEntity(obj, true, true)

    local netId = NetworkGetNetworkIdFromEntity(obj)
    if netId and netId ~= 0 then
        GlobalProps[data.id] = netId
    else
        print('[JLABS] Invalid netId for object, skipping sync.')
    end

    for _, cfg in pairs(Config.PlaceableItems) do
        if GetHashKey(cfg.model) == GetEntityModel(obj) then
            AddWarehousePropTarget(data.id, obj, cfg)
            break
        end
    end
end)

RegisterNetEvent('jlabs-warehouse:client:deleteProp', function(propId)
    SafeDeleteByPropId(propId)
end)

RegisterNetEvent('jlabs-warehouse:client:updateProp', function(data)
    local ent = GetEntityByPropId(data.id)
    if not ent then return end
    NetworkRequestControlOfEntity(ent)
    FreezeEntityPosition(ent, false)
    SetEntityCoordsNoOffset(ent, data.pos.x, data.pos.y, data.pos.z, false, false, false)
    SetEntityRotation(ent, data.rot.x, data.rot.y, data.rot.z, 2, true)
    FreezeEntityPosition(ent, true)
end)

--------------------------------------------------------
-- 🏗️ Placement (Move or Place)
--------------------------------------------------------
local function beginPlacement(model, itemName, propId)
    confirmed, heading, movingPropId = false, 0.0, propId or nil

    if not currentWarehouse then
        return lib.notify({ title = 'Warehouse', description = 'You must be inside your warehouse.', type = 'error' })
    end
    if not LoadModel(model) then return end

    -- ✅ LOCAL ghost prop (non-networked, won’t spam errors)
    local cam = GetGameplayCamCoord()
    local obj = CreateObject(model, cam.x, cam.y, cam.z, false, false, false)
    if not DoesEntityExist(obj) then return end

    SetEntityAlpha(obj, 100, false)
    SetEntityCollision(obj, false, false)
    FreezeEntityPosition(obj, true)

    lib.showTextUI('[Mouse] Move | [←/→] Rotate | [E] Confirm | [G] Cancel', {
        position = 'left-center', style = { background = '#1f8bef', color = 'white', borderRadius = 5 }
    })

    CreateThread(function()
        while not confirmed do
            Wait(0)
            local hit, coords = RayCastCamera(1000.0)
            if hit and coords then
                SetEntityCoordsNoOffset(obj, coords.x, coords.y, coords.z + 0.05, false, false, false, true)
            end

            if IsControlPressed(0, 174) then heading += 1.0 end
            if IsControlPressed(0, 175) then heading -= 1.0 end
            SetEntityHeading(obj, heading)

            -- ✅ Confirm
            if IsControlJustPressed(0, 38) then
                confirmed = true
                lib.hideTextUI()

                local pos, rot = GetEntityCoords(obj), GetEntityRotation(obj)
                DeleteEntity(obj)

                if movingPropId then
                    TriggerServerEvent('jlabs-warehouse:server:updateProp', movingPropId, pos, rot)
                else
                    TriggerServerEvent('jlabs-warehouse:server:placeProp', currentWarehouse, itemName, model, pos, rot)
                end
                movingPropId = nil
                return
            end

            -- Cancel
            if IsControlJustPressed(0, 47) then
                DeleteEntity(obj)
                lib.hideTextUI()
                lib.notify({ title = 'Warehouse', description = 'Placement cancelled.', type = 'error' })
                return
            end
        end
    end)
end

--------------------------------------------------------
-- 🧪 Test Command
--------------------------------------------------------
RegisterCommand('placeprop', function(_, args)
    local item = args[1] or 'furniture_table'
    local cfg = Config.PlaceableItems[item]
    if not cfg then
        return lib.notify({ title = 'Warehouse', description = 'Invalid item.', type = 'error' })
    end
    if not currentWarehouse then
        return lib.notify({ title = 'Warehouse', description = 'You must be inside your warehouse.', type = 'error' })
    end
    beginPlacement(cfg.model, item)
end, false)

--------------------------------------------------------
-- 📦 Export for ox_inventory item use
--------------------------------------------------------
exports('placeProp', function(data, slot)
    local itemName = data?.name or slot?.name
    if not itemName then
        return lib.notify({ title = 'Warehouse', description = 'Invalid item.', type = 'error' })
    end

    local cfg = Config.PlaceableItems[itemName]
    if not cfg then
        return lib.notify({ title = 'Warehouse', description = 'This item cannot be placed.', type = 'error' })
    end

    if not currentWarehouse then
        return lib.notify({ title = 'Warehouse', description = 'You must be inside your warehouse.', type = 'error' })
    end

    beginPlacement(cfg.model, itemName)
end)
