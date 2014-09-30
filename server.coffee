somata_socketio = require 'somata-socketio'

config =
    port: process.env.SOMATA_DASHBOARD_PORT || 10000
    medulla_prefix: process.env.MEDULLA_PREFIX || ''

app = somata_socketio.setup_app config

app.get '/', (req, res) ->
    res.locals.config = config
    res.render 'base'

app.start()

