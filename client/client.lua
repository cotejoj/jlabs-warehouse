local isNearWarehouse = false
local ownedWarehouses = {}

-- 🗺️ Distance-based warehouse blips
CreateThread(function()
    local activeBlips = {}
    local showRange = 300.0 -- distance in meters to show blip

    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for name, warehouse in pairs(Config.Warehouses) do
            local dist = #(coords - vector3(warehouse.coords.x, warehouse.coords.y, warehouse.coords.z))

            -- create blip when close
            if dist < showRange and not activeBlips[name] then
                local blip = AddBlipForCoord(warehouse.coords.x, warehouse.coords.y, warehouse.coords.z)
                SetBlipSprite(blip, Config.Default.blip.sprite)
                SetBlipDisplay(blip, Config.Default.blip.display)
                SetBlipScale(blip, Config.Default.blip.scale)
                SetBlipColour(blip, Config.Default.blip.color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(Config.Default.blip.name)
                EndTextCommandSetBlipName(blip)
                activeBlips[name] = blip

            -- remove blip when far
            elseif dist >= showRange and activeBlips[name] then
                RemoveBlip(activeBlips[name])
                activeBlips[name] = nil
            end
        end

        Wait(2000) -- check every 2 seconds
    end
end)


-- 🧾 Load player’s owned warehouses from server
RegisterNetEvent('jlabs-warehouse:client:setOwned', function(owned)
    ownedWarehouses = owned or {}
end)

-- 🎯 Warehouse interaction
CreateThread(function()
    local textShown = false
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local sleep = 500
        local closestWarehouse , closestData = nil , nil
        for name, data in pairs(Config.Warehouses) do
            local dist = #(pos - vector3(data.coords.x, data.coords.y, data.coords.z))
            if dist < 3.0 then
                closestWarehouse = name
                closestData = data
            end
        end
        if closestWarehouse then
            sleep = 1
            if IsControlJustReleased(0, 38) then -- E key
                OpenWarehouseMenu(closestWarehouse, closestData)
            end
        end

        if closestWarehouse and not textShown then
            textShown = true
            lib.showTextUI('[E] Interact Warehouse ', {
                position = "left-center",
                style = {
                    borderRadius = 5,
                    background = '#ef1f43',
                    color = 'white'
                }
            })
        elseif not closestWarehouse and textShown then
            textShown = false
            lib.hideTextUI()
        end

        Wait(sleep)
    end
end)

function OpenWarehouseMenu(name, data)
    -- Ask the server who owns this warehouse
    local ownershipStatus = lib.callback.await('jlabs-warehouse:server:getOwnershipStatus', false, name)

    -- ownershipStatus can be:
    -- "ownedByYou", "ownedBySomeone", or "unowned"
    print(('[DEBUG] Warehouse %s status: %s'):format(name, ownershipStatus))

    local options = {}

    if ownershipStatus == "unowned" then
        -- Show purchase option only
        options[#options+1] = {
            title = 'Purchase Warehouse',
            description = ('Buy for $%s'):format(data.price),
            icon = 'warehouse',
            onSelect = function()
                TriggerServerEvent('jlabs-warehouse:server:buyWarehouse', name)
            end
        }

    elseif ownershipStatus == "ownedByYou" then
        -- Owner options
        options[#options+1] = {
            title = 'Enter Warehouse',
            description = 'Go inside your warehouse',
            icon = 'door-open',
            onSelect = function()
                TriggerEvent('jlabs-warehouse:client:enterWarehouse', name)
            end
        }

        options[#options+1] = {
            title = 'Invite Nearby Players',
            description = 'Allow nearby players to enter your warehouse',
            icon = 'users',
            onSelect = function()
                TriggerServerEvent('jlabs-warehouse:server:inviteNearby', name)
            end
        }

        options[#options+1] = {
            title = 'Sell Warehouse',
            description = ('Sell for $%s'):format(math.floor(data.price * 0.7)),
            icon = 'dollar-sign',
            onSelect = function()
                TriggerServerEvent('jlabs-warehouse:server:sellWarehouse', name)
            end
        }
    else
        -- Owned by someone else — do not show any menu
        lib.notify({
            type = 'error',
            description = 'This warehouse is already owned by someone else.'
        })
        return
    end

    -- Register and show the context menu
    lib.registerContext({
        id = 'warehouse_menu_' .. name,
        title = 'Warehouse - ' .. name,
        options = options
    })
    lib.showContext('warehouse_menu_' .. name)
end



RegisterNetEvent('jlabs-warehouse:client:receiveInvite', function(warehouseName, inviterId)
    local inviterPed = GetPlayerPed(GetPlayerFromServerId(inviterId))
    local name = GetPlayerName(inviterId)

    lib.registerContext({
        id = 'warehouse_invite_' .. warehouseName .. '_' .. inviterId,
        title = 'Warehouse Invite',
        options = {
            {
                title = 'Accept Invite',
                icon = 'door-open',
                onSelect = function()
                    TriggerEvent('jlabs-warehouse:client:enterWarehouse', warehouseName, inviterId)
                end
            },
            {
                title = 'Decline',
                icon = 'times',
                onSelect = function() end
            }
        }
    })

    lib.showContext('warehouse_invite_' .. warehouseName .. '_' .. inviterId)
end)

-- Enter warehouse with optional inviterId for shared routing bucket
RegisterNetEvent('jlabs-warehouse:client:enterWarehouse', function(warehouseName, inviterId)
    local warehouse = Config.Warehouses[warehouseName]
    if not warehouse then return end
    TriggerEvent("InteractSound_CL:PlayOnOne", "DoorOpen", 0.5)
    -- Use the warehouse coordinates from config and apply offset
    local spawnPos = vector4(
        warehouse.coords.x,
        warehouse.coords.y,
        warehouse.coords.z - (warehouse.offset or 0.0), -- subtract offset to place inside shell
        warehouse.coords.w
    )

    -- Spawn the warehouse shell
    local shell = exports['qb-interior']:CreateWarehouse1(spawnPos)

    -- Move player inside
    SetEntityCoords(PlayerPedId(), vector3(spawnPos.x, spawnPos.y, spawnPos.z))
    SetEntityHeading(PlayerPedId(), spawnPos.w)

    -- Calculate exit point relative to shell interior
    local exitOffset = shell[2].exit -- adjust X/Y/Z offset to match your door position
    local exitPoint = vector3(spawnPos.x + exitOffset.x, spawnPos.y + exitOffset.y, spawnPos.z + exitOffset.z)

    TriggerEvent('jlabs-warehouse:client:setCurrentWarehouse', warehouseName)
    TriggerServerEvent('jlabs-warehouse:server:loadWarehouseProps', warehouseName)
    local insideWarehouse = true
    CreateThread(function()
        local textShown = false
        while insideWarehouse do

            local pedCoords = GetEntityCoords(PlayerPedId())
            if #(pedCoords - exitPoint) < 1.0 then
                if not textShown then
                    textShown = true
                    lib.showTextUI('[E] Exit Warehouse', {
                        position = "left-center",
                        style = {
                            borderRadius = 5,
                            background = '#ef1f43',
                            color = 'white'
                        }
                    })
                end
                if IsControlJustReleased(0, 38) then -- E key
                        exports['qb-interior']:DespawnInterior(shell[1], function()
                            SetEntityCoords(PlayerPedId(), vector3(warehouse.coords.x, warehouse.coords.y, warehouse.coords.z))
                            TriggerEvent("InteractSound_CL:PlayOnOne", "DoorClose", 0.5)
                            textShown = false
                            lib.hideTextUI()
                            insideWarehouse = false
                            TriggerEvent('jlabs-warehouse:client:setCurrentWarehouse', nil)
                        end)
                    break
                end
            elseif #(pedCoords - exitPoint) > 1.0 and textShown then
                textShown = false
                lib.hideTextUI()
            end
            Wait(0)
        end
    end)
end)


-- 🧾 Draw 3D text helper
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
