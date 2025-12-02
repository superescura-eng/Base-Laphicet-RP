fx_version 'cerulean'
game 'gta5'

description 'QBCore Bridge for vRP'
version '1.0.0'

dependencies {
    'vrp'
}

shared_scripts {
    'shared/locale.lua'
}

server_scripts {
    '@vrp/lib/utils.lua',
    'server/bridge.lua'
}

client_scripts {
    '@vrp/lib/utils.lua',
    'client/bridge.lua'
}

exports {
    'GetCoreObject'
}
