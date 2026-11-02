fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NoxenScripts'
name 'noxen_lib'
description 'Framework bridge and tooling for Noxen scripts (ESX, QBCore, Qbox)'
version '2.0.0'

ui_page 'ui/ui.html'

shared_scripts {
    'imports.lua',
    'config.lua',
    'shared/core.lua',
    'shared/mappers.lua',
}

server_scripts {
    'server/callbacks.lua',
    'server/frameworks/*.lua',
    'server/inventories/*.lua',
    'server/main.lua',
    'internal/index.lua',
}

client_scripts {
    'client/callbacks.lua',
    'client/frameworks/*.lua',
    'client/targets/*.lua',
    'client/main.lua',
    'internal/index.lua',
}

files {
    'internal/**',
    'system/**',
    'enums/**',
    'lib/**',
    'ui/**',
}
