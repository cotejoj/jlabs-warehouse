Config = {}

-- 🌍 Global Settings
Config.Default = {
    offset = 50.0,            -- how deep the interior spawns underground
    price = 2000000,            -- base price if none set
    defaultSlots = 50,        -- stash slots
    defaultWeight = 200000,   -- stash weight

    -- 🧭 Blip Settings (applied to all warehouses)
    blip = {
        sprite = 473,         -- warehouse icon
        color = 5,            -- blue
        scale = 0.8,
        display = 4,          -- map + minimap
        shortRange = true,
        name = "Warehouse Property"
    }
}

Config.Warehouses = {
    ['Warehouse1'] = { coords = vector4(1199.901, -1302.736, 35.217, 30.0), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },

    ['Warehouse2'] = { coords = vector4(1459.4525, -1930.7321, 71.8045, 253.3779), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse3'] = { coords = vector4(1017.7053, -2529.1602, 28.3020, 82.8969), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse4'] = { coords = vector4(900.6323, -1152.7695, 26.0593, 178.7255), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse5'] = { coords = vector4(-592.5543, -1765.0747, 23.1803, 238.0873), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse6'] = { coords = vector4(-1027.6757, -1575.4696, 5.2689, 313.7686), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse7'] = { coords = vector4(-1273.2997, -1371.6382, 4.3029, 30.2502), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse8'] = { coords = vector4(-1487.1868, -909.9212, 10.0236, 5.6542), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse9'] = { coords = vector4(-1453.2385, -387.2369, 38.1934, 39.6917), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse10'] = { coords = vector4(-439.5804, 295.2384, 83.3329, 85.5699), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse11'] = { coords = vector4(189.7598, 309.1843, 105.3897, 183.6003), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse12'] = { coords = vector4(201.4733, 2462.4741, 55.9056, 205.3252), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse13'] = { coords = vector4(194.8342, 3030.7815, 44.0159, 282.9376), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse14'] = { coords = vector4(387.6162, 3584.6985, 33.2922, 162.8000), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse15'] = { coords = vector4(905.9127, 3586.2437, 33.4613, 54.2460), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse16'] = { coords = vector4(983.8057, 2718.9314, 39.5034, 191.0727), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse17'] = { coords = vector4(1252.5656, 2742.8584, 39.0008, 157.9589), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse18'] = { coords = vector4(2359.3728, 2541.8643, 47.6960, 191.1928), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse19'] = { coords = vector4(1586.2449, 2906.9309, 57.9691, 123.5620), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse20'] = { coords = vector4(2168.2476, 3330.9402, 46.5156, 203.5830), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse21'] = { coords = vector4(2588.4995, 3167.6763, 51.3669, 129.3632), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse22'] = { coords = vector4(2179.1448, 3496.5430, 46.0147, 325.0700), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse23'] = { coords = vector4(1412.9893, 3663.8582, 34.4065, 97.9087), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse24'] = { coords = vector4(1738.1051, 3709.1431, 34.1378, 123.3696), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse25'] = { coords = vector4(1915.6858, 3909.2375, 33.4416, 231.6452), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse26'] = { coords = vector4(2728.6685, 4142.1548, 44.3033, 102.1104), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse27'] = { coords = vector4(2889.6833, 4391.2603, 50.4511, 111.0731), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse28'] = { coords = vector4(2589.4075, 4678.1094, 34.0768, 140.4789), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse29'] = { coords = vector4(1961.0566, 5185.1592, 47.9447, 92.0809), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse30'] = { coords = vector4(1930.0830, 4634.8853, 40.4715, 132.4965), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse31'] = { coords = vector4(416.2389, 6520.8828, 27.7246, 124.9997), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse32'] = { coords = vector4(148.9906, 6362.6294, 31.5292, 302.5078), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse33'] = { coords = vector4(-87.8004, 6494.7021, 32.1006, 47.2230), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse34'] = { coords = vector4(-55.0819, 6392.4565, 31.5824, 228.9653), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse35'] = { coords = vector4(-223.2419, 6243.0171, 31.4924, 230.0031), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse36'] = { coords = vector4(-358.7412, 6061.6611, 31.5001, 214.3032), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse37'] = { coords = vector4(-1128.4139, 2691.8799, 18.8004, 349.5582), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse38'] = { coords = vector4(-50.2376, 1911.2069, 195.7442, 273.8951), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse39'] = { coords = vector4(1211.3955, 1857.4116, 78.9631, 211.7560), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse40'] = { coords = vector4(822.4760, -119.2347, 80.4575, 254.9133), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse41'] = { coords = vector4(1099.4309, -345.9411, 67.1822, 35.4650), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse42'] = { coords = vector4(1238.4825, -401.7827, 68.9379, 67.3133), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse43'] = { coords = vector4(1082.6372, -787.4551, 58.3520, 2.9389), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse44'] = { coords = vector4(748.7184, -529.2608, 27.7774, 281.8248), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse45'] = { coords = vector4(677.9539, -913.0856, 23.4620, 185.0806), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse46'] = { coords = vector4(707.5550, -1142.2670, 23.4882, 273.8093), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse47'] = { coords = vector4(838.1953, -1396.0664, 26.3120, 7.2447), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse48'] = { coords = vector4(1122.8530, -1304.6119, 34.7164, 176.5788), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse49'] = { coords = vector4(992.2533, -1550.4934, 30.7548, 91.6726), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse50'] = { coords = vector4(486.0516, -1529.7993, 29.4640, 217.1628), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
    ['Warehouse51'] = { coords = vector4(178.9538, -1488.1873, 29.1416, 153.5895), offset = 50.0, price = 2000000, defaultSlots = 50, defaultWeight = 200000 },
}


-- placeable items and their models
Config.PlaceableItems = {
    ['furniture_wardrobe'] = { model = 'v_res_tre_wardrobe', label = 'Wardrobe', type = 'clothing' },
    ['furniture_shelve']   = {model = 'prop_shelves_02' , label = "Shelve" , type = 'stash', slots = 100, weight=1000000},
    ['furniture_table']     = { model = 'prop_table_03b_cs', label = 'Wooden Table', type = 'decor' },
    ['furniture_chair']     = { model = 'prop_chair_01a', label = 'Chair', type = 'decor' },
    ['warehouse_stash']     = { model = 'sm_prop_smug_crate_m_01a', label = 'Storage Box', type = 'stash', slots = 100, weight = 500000 },
    ['workbench_item']      = { model = 'prop_tool_bench02_ld', label = 'Workbench', type = 'crafting' },
}

