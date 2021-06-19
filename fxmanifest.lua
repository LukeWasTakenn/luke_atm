fx_version 'cerulean'

game 'gta5'

author 'Luke - https://github.com/LukeWasTakenn'
description 'ATM script for ESX framework'
version '1.2.0'

ui_page 'html/ui.html'

client_scripts {
    'config.lua',
    'client/client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server/version_check.lua',
    'server/server.lua'
}

files {
    'html/ui.html',
    'html/js/app.js',
    'html/css/style.css',
    'html/webfonts/fa-brands-400.eot',
    'html/webfonts/fa-brands-400.svg',
    'html/webfonts/fa-brands-400.ttf',
    'html/webfonts/fa-brands-400.woff',
    'html/webfonts/fa-brands-400.woff2',
    'html/webfonts/fa-regular-400.eot',
    'html/webfonts/fa-regular-400.svg',
    'html/webfonts/fa-regular-400.ttf',
    'html/webfonts/fa-regular-400.woff',
    'html/webfonts/fa-regular-400.woff2',
    'html/webfonts/fa-solid-900.eot',
    'html/webfonts/fa-solid-900.svg',
    'html/webfonts/fa-solid-900.ttf',
    'html/webfonts/fa-solid-900.woff',
    'html/webfonts/fa-solid-900.woff2',
    'html/css/all.min.css',
    'html/css/bootstrap.min.css',
    'html/js/bootstrap.min.js',
    'html/js/popper.js',
}