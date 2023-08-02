fx_version 'cerulean'

games { 'gta5' }

author 'Javi'

description 'Conce by Javi'

ui_page 'ui/index.html'

files {
    'ui/**/**/*.*'
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua',
}

shared_scripts {
    'shared/*.lua'
}

exports 'appendBankDialog'

dependencies {
    'es_extended'
}