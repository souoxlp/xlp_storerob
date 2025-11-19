fx_version 'cerulean'
game 'gta5'

author 'xlp1'
description 'Simple 24/7 Store Robbery Script'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'config.lua'
}

files {
    'locales/*.json'
}

client_script 'client.lua'
server_script 'server.lua'

lua54 'yes'
