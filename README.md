# 📦 JLABS Warehouse System

A fully synced and interactive **warehouse prop placement system** for **FiveM (ESX + ox_lib + ox_inventory)**.  
Players can place, move, and delete furniture or storage props inside their warehouses — complete with **inventory stash**, **clothing integration**, and **persistent saving**.

---

## 🎥 YouTube Showcase

▶ **Watch the showcase here:**  
[![JLABS Warehouse Showcase](https://img.youtube.com/vi/F0n8XMMSzL8/hqdefault.jpg)](https://www.youtube.com/watch?v=F0n8XMMSzL8)

---

## 🚀 Features

- 🌍 Network Synced Props  
- 🧱 Place, Move, and Delete system  
- 💾 Persistent database saving  
- 📦 ox_inventory stash & clothing integration  
- 🎯 ox_target support  
- ⚙️ Optimized and network-safe  
- 🧩 Easy configuration and customization  

---

## 🧱 Requirements

| Dependency | Description | Link |
|-------------|--------------|------|
| **ox_lib** | Core UI, notifications | [ox_lib](https://github.com/overextended/ox_lib) |
| **ox_target** | Target interaction system | [ox_target](https://github.com/overextended/ox_target) |
| **ox_inventory** | Inventory & stash system | [ox_inventory](https://github.com/overextended/ox_inventory) |
| **oxmysql** | Database wrapper | [oxmysql](https://github.com/overextended/oxmysql) |
| **qb-interior** | Interior shell system | [qb-interior](https://github.com/qbcore-framework/qb-interior) |

---

## ⚙️ Installation

1. Clone the resource:
   ```bash
   git clone https://github.com/YOURUSERNAME/jlabs-warehouse.git
2. SQL Will be automaticall generate by the server

## ox_inventory/data/items.lua

['furniture_wardrobe'] = {
	label = 'Wardrobe',
	weight = 15000,
	stack = false,
	close = true,
	description = 'A wardrobe for storing clothing.',
	client = {
		export = 'jlabs-warehouse.placeProp'
	}
},
['furniture_shelve'] = {
	label = 'Storage Shelve',
	weight = 20000,
	stack = false,
	close = true,
	description = 'A large shelve for storing items.',
	client = {
		export = 'jlabs-warehouse.placeProp'
	}
},
['furniture_table'] = {
	label = 'Wooden Table',
	weight = 15000,
	stack = false,
	close = true,
	description = 'A sturdy wooden table.',
	client = {
		export = 'jlabs-warehouse.placeProp'
	}
},
['furniture_chair'] = {
	label = 'Chair',
	weight = 8000,
	stack = false,
	close = true,
	description = 'A simple chair.',
	client = {
		export = 'jlabs-warehouse.placeProp'
	}
},
['warehouse_stash'] = {
	label = 'Storage Box',
	weight = 10000,
	stack = false,
	close = true,
	description = 'A small storage box for your warehouse.',
	client = {
		export = 'jlabs-warehouse.placeProp'
	}
},
['workbench_item'] = {
	label = 'Workbench',
	weight = 25000,
	stack = false,
	close = true,
	description = 'Workbench used for nothing hahaha.',
	client = {
		export = 'jlabs-warehouse.placeProp'
	}
},