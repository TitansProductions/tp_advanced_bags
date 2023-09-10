fx_version 'adamant'
game 'gta5'

author 'Nosmakos'
description 'Titans Productions Advanced Bags (ESX Legacy)'
version '1.0.0'

ui_page 'html/index.html'

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    '@es_extended/locale.lua',
	'locales/en.lua',
    'config.lua',
    'server/*.lua',
}


client_scripts {
    '@es_extended/locale.lua',
	'locales/en.lua',
    'config.lua',
    'client/*.lua',
}

files {
	'html/index.html',
	'html/js/script.js',
	'html/css/*.css',
	'html/font/Prototype.ttf',
    'html/img/background.jpg',
}

dependency 'es_extended'
