somata_socketio = require 'somata-socketio'

app = somata_socketio.setup_app
    port: 10000

app.get '/', (req, res) ->
    res.render 'base'

app.start()

