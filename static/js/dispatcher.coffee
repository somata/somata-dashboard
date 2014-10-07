# Collect action methods into services
# TODO: Figure out a better system for more complex models (if necessary)
# TODO: Connectors for HTTP APIs

ServicesDispatcher =

    # Commands

    getServices: (cb) ->
        remote medulla_id, 'listServices', cb

    startService: (service) ->
        remote medulla_id, 'startService', service, ->
            console.log "Started #{ service.name }."

    stopService: (service) ->
        remote medulla_id, 'stopService', service, ->
            console.log "Stopped #{ service.name }."

    restartService: (service) ->
        remote medulla_id, 'restartService', service, ->
            console.log "Restarted #{ service.name }."

    # Subscriptions

    onStartService: (cb) ->
        subscribe medulla_id, 'startService', cb

    onStopService: (cb) ->
        subscribe medulla_id, 'stopService', cb

    onServiceLogs: (service, cb) ->
        subscribe medulla_id, "service:#{ service.id }:stdout", cb

ShellDispatcher =

    # Commands

    runCommand: (command_string, cb) ->
        [service_command, args...] = command_string.split(' ')
        [service, command] = service_command.split('.')
        remote service, command, args..., cb

window.Dispatcher = _.extend {}, ServicesDispatcher, ShellDispatcher

