fx_version 'cerulean'
game 'gta5'

author 'Jumar'
description 'Warehouse System for ESX'
version '1.1.0'

shared_scripts {
  '@ox_lib/init.lua',
  '@es_extended/imports.lua',
  'config.lua'
}
client_scripts {'client/*.lua'}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

