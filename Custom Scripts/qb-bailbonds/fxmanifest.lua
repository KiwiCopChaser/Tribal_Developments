-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

author 'Wildman_Developments'
description 'Comprehensive Bail Bond System for QBCore'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

lua54 'yes'
