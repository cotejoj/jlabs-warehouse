local oxmysql = exports.oxmysql
local spawnedProps = {} -- track spawned entities
-- 🧱 Create table if missing
CreateThread(function()
    oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS jlabs_warehouses (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(64) NOT NULL,
            warehouse VARCHAR(64) NOT NULL,
            slots INT DEFAULT 50,
            weight INT DEFAULT 200000,
            UNIQUE (identifier, warehouse)
        );
    ]])

    oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS jlabs_warehouse_props (
        id INT AUTO_INCREMENT PRIMARY KEY,
        owner_identifier VARCHAR(64) NOT NULL,
        warehouse_name VARCHAR(64) NOT NULL,
        item_name VARCHAR(64) NOT NULL,
        model VARCHAR(128) NOT NULL,
        pos_x DOUBLE NOT NULL,
        pos_y DOUBLE NOT NULL,
        pos_z DOUBLE NOT NULL,
        rot_x DOUBLE DEFAULT 0,
        rot_y DOUBLE DEFAULT 0,
        rot_z DOUBLE DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    ]])
end)

-- 🧾 Load owned warehouses when player joins
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local identifier = xPlayer.identifier

    MySQL.query('SELECT * FROM jlabs_warehouses WHERE identifier = ?', { identifier }, function(result)
        local owned = {}
        for _, row in pairs(result) do
            owned[row.warehouse] = true
        end

        TriggerClientEvent('jlabs-warehouse:client:setOwned', playerId, owned)
    end)
end)

-- 💰 Buy warehouse
RegisterNetEvent('jlabs-warehouse:server:buyWarehouse', function(name)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier
    local warehouse = Config.Warehouses[name]
    if not warehouse then return end

    local result = MySQL.single.await('SELECT * FROM jlabs_warehouses WHERE identifier = ? AND warehouse = ?', { identifier, name })
    if result then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Warehouse', description = 'You already own this warehouse.', type = 'error' })
        return
    end

    if xPlayer.getAccount('bank').money >= warehouse.price then
        xPlayer.removeAccountMoney('bank', warehouse.price)

        MySQL.insert('INSERT INTO jlabs_warehouses (identifier, warehouse, slots, weight) VALUES (?, ?, ?, ?)', {
            identifier,
            name,
            warehouse.defaultSlots,
            warehouse.defaultWeight
        })

        TriggerClientEvent('ox_lib:notify', src, { title = 'Warehouse', description = 'You purchased the warehouse successfully!', type = 'success' })
        TriggerClientEvent('jlabs-warehouse:client:setOwned', src, { [name] = true })
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Warehouse', description = 'You do not have enough money.', type = 'error' })
    end
end)

-- 💸 Sell warehouse
RegisterNetEvent('jlabs-warehouse:server:sellWarehouse', function(name)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier
    local warehouse = Config.Warehouses[name]
    if not warehouse then return end

    local result = MySQL.single.await('SELECT * FROM jlabs_warehouses WHERE identifier = ? AND warehouse = ?', { identifier, name })
    if not result then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Warehouse', description = 'You do not own this warehouse.', type = 'error' })
        return
    end

    local sellPrice = math.floor(warehouse.price * 0.7)
    xPlayer.addAccountMoney('bank', sellPrice)

    MySQL.query('DELETE FROM jlabs_warehouses WHERE identifier = ? AND warehouse = ?', { identifier, name })
    TriggerClientEvent('ox_lib:notify', src, { title = 'Warehouse', description = 'Warehouse sold successfully.', type = 'success' })
    TriggerClientEvent('jlabs-warehouse:client:setOwned', src, {})
end)


lib.callback.register('jlabs-warehouse:server:getOwnershipStatus', function(source, name)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 'unknown' end

    -- Check who owns this warehouse
    local owner = exports.oxmysql:scalarSync(
        'SELECT identifier FROM jlabs_warehouses WHERE warehouse = ? LIMIT 1',
        { name }
    )

    if not owner then
        return "unowned"
    elseif owner == xPlayer.identifier then
        return "ownedByYou"
    else
        return "ownedBySomeone"
    end
end)


-- Invite nearby players to the warehouse
RegisterNetEvent('jlabs-warehouse:server:inviteNearby', function(warehouseName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    -- Get coords of player
    local playerPed = GetPlayerPed(src)
    local px, py, pz = table.unpack(GetEntityCoords(playerPed))

    -- Find nearby players within 5 meters
    local nearbyPlayers = {}
    for _, playerId in pairs(GetPlayers()) do
        if tonumber(playerId) ~= tonumber(src) then
            local ped = GetPlayerPed(playerId)
            local coords = GetEntityCoords(ped)
            local dist = #(vector3(px, py, pz) - coords)
            if dist <= 5.0 then
                table.insert(nearbyPlayers, playerId)
            end
        end
    end

    -- Send invite to nearby players
    for _, targetId in pairs(nearbyPlayers) do
        TriggerClientEvent('jlabs-warehouse:client:receiveInvite', targetId, warehouseName, src)
    end
end)


--------------------------------------------
-- 📦 JLABS WAREHOUSE - SERVER
--------------------------------------------

local function spawnProp(prop)
    local data = {
        id = prop.id,
        model = prop.model,
        pos = { x = prop.pos_x, y = prop.pos_y, z = prop.pos_z },
        rot = { x = prop.rot_x, y = prop.rot_y, z = prop.rot_z }
    }
    TriggerClientEvent('jlabs-warehouse:client:spawnProp', -1, data)
end

--------------------------------------------------------
-- 📦 Place Prop
--------------------------------------------------------
RegisterNetEvent('jlabs-warehouse:server:placeProp', function(warehouse, item, model, pos, rot)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local identifier = xPlayer.identifier or xPlayer.getIdentifier()
    local insertId = MySQL.insert.await([[
        INSERT INTO jlabs_warehouse_props 
        (owner_identifier, warehouse_name, item_name, model, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], { identifier, warehouse, item, model, pos.x, pos.y, pos.z, rot.x or 0, rot.y or 0, rot.z or 0 })

    if insertId then
        xPlayer.removeInventoryItem(item, 1)
        spawnProp({
            id = insertId, model = model,
            pos_x = pos.x, pos_y = pos.y, pos_z = pos.z,
            rot_x = rot.x, rot_y = rot.y, rot_z = rot.z
        })
        TriggerClientEvent('ox_lib:notify', src, { title = 'Warehouse', description = 'Prop placed successfully!', type = 'success' })
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Warehouse', description = 'Failed to save prop.', type = 'error' })
    end
end)

RegisterNetEvent('jlabs-warehouse:server:removeProp', function(propId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local identifier = xPlayer.identifier or xPlayer.getIdentifier()
    local row = MySQL.single.await('SELECT * FROM jlabs_warehouse_props WHERE id = ? AND owner_identifier = ?', { propId, identifier })

    if not row then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'Warehouse',
            description = 'Prop not found or not yours.',
            type = 'error'
        })
    end

    -- Remove prop from DB and all clients
    MySQL.query('DELETE FROM jlabs_warehouse_props WHERE id = ?', { propId })
    TriggerClientEvent('jlabs-warehouse:client:deleteProp', -1, propId)

    -- Refund item using ox_inventory
    local itemName = row.item_name
    if itemName and itemName ~= '' then
        exports.ox_inventory:AddItem(src, itemName, 1)
    end
end)
--------------------------------------------------------
-- 🔁 Update Prop (Move)
--------------------------------------------------------
RegisterNetEvent('jlabs-warehouse:server:updateProp', function(propId, pos, rot)
    MySQL.update('UPDATE jlabs_warehouse_props SET pos_x=?,pos_y=?,pos_z=?,rot_x=?,rot_y=?,rot_z=? WHERE id=?',
        { pos.x, pos.y, pos.z, rot.x or 0, rot.y or 0, rot.z or 0, propId })
    TriggerClientEvent('jlabs-warehouse:client:updateProp', -1, { id = propId, pos = pos, rot = rot })
end)

--------------------------------------------------------
-- 🏷️ Stash
--------------------------------------------------------
RegisterNetEvent('jlabs-warehouse:server:openStash', function(propId, label, slots, weight)
    local src = source
    local stashId = ('warehouse_stash_%s'):format(propId)
    if not exports.ox_inventory:GetInventory(stashId) then
        exports.ox_inventory:RegisterStash(stashId, label or 'Warehouse Storage', slots or 50, weight or 50000, false)
    end
    TriggerClientEvent('ox_inventory:openInventory', src, 'stash', { id = stashId })
end)

--------------------------------------------------------
-- 🧱 Restore Props (on join / restart)
--------------------------------------------------------
RegisterNetEvent('jlabs-warehouse:server:requestProps', function()
    local src = source
    local rows = MySQL.query.await('SELECT * FROM jlabs_warehouse_props')
    for _, prop in ipairs(rows or {}) do
        spawnProp(prop)
    end
end)

AddEventHandler('playerJoining', function(playerId)
    local rows = MySQL.query.await('SELECT * FROM jlabs_warehouse_props')
    for _, prop in ipairs(rows or {}) do
        spawnProp(prop)
    end
end)
