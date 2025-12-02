fx_version 'cerulean'
game 'gta5'

author '.mur4i'
description 'mri_Qbox Admin Panel'
version '1.0.1'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

ui_page 'html/index.html'

files {
	'html/**',
    'json/reports.json',
    'json/adminchat.json',
    'json/logs.json',
}

shared_scripts {
    -- '@ox_lib/init.lua',
	-- '@qbx_core/modules/lib.lua',
   -- '@qbx_core/modules/utils.lua',
    'locales/locale.lua',
    'locales/pt-br.lua', -- Can change to other languages available in locales folder
    'config.lua',
    'compat/qbcore.lua', -- If using ESX uncomment line below & comment this line
	--'compat/esx18.lua', -- If using ESX comment line above & uncomment this line
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/adminactions.lua',
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/freecam/utils.lua',
    'client/freecam/config.lua',
    'client/freecam/camera.lua',
    'client/freecam/main.lua',
    'client/noclip_new.lua',
    'client/DeveloperOptions.lua',
}

dependencies { 'oxmysql' }