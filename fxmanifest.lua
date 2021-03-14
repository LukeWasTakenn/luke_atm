fx_version 'cerulean'

game 'gta5'

author 'Luke'
description 'ATM script for ESX framework'
version '1.0.0'

ui_page 'html/ui.html'

client_scripts {
    'client/client.lua',
    'config.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/server.lua',
    'config.lua',
}

files {
    'html/ui.html',
    'html/app.js',
    'html/style.css',
    'html/img/*.png',
}