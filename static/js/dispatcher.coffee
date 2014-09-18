# Collect action methods into services
# TODO: Figure out a better system for more complex models (if necessary)
# TODO: Connectors for HTTP APIs

ServicesDispatcher =

    # Commands

    getServices: (cb) ->
        remote 'medulla', 'listServices', cb

    startService: (service) ->
        remote 'medulla', 'startService', service, ->
            console.log "Started #{ service.name }."

    stopService: (service) ->
        remote 'medulla', 'stopService', service, ->
            console.log "Stopped #{ service.name }."

    restartService: (service) ->
        remote 'medulla', 'restartService', service, ->
            console.log "Restarted #{ service.name }."

    # Subscriptions

    onStartService: (cb) ->
        subscribe 'medulla', 'startService', cb

    onStopService: (cb) ->
        subscribe 'medulla', 'stopService', cb

    onServiceLogs: (service, cb) ->
        subscribe 'medulla', "service:#{ service.name }:stdout", cb

ShellDispatcher =

    # Commands

    runCommand: (command_string, cb) ->
        [service_command, args...] = command_string.split(' ')
        [service, command] = service_command.split('.')
        remote service, command, args..., cb

window.Dispatcher = _.extend {}, ServicesDispatcher, ShellDispatcher

