# Connect to the Socket.io server

socket = io.connect()

# Call a remote service's method

window.remote = (service, method, args..., cb) ->
    socket.emit 'remote', service, method, args..., cb

# Subscribe to a service's events

subscriptions = {}
window.subscribe = (service, type, cb) ->
    subscriptions[service] ||= {}
    subscriptions[service][type] ||= []
    subscriptions[service][type].push cb
    socket.emit 'subscribe', service, type
    subscription = {
        service
        type
        unsubscribe: ->
            socket.emit 'unsubscribe', service, type
            subscriptions[service][type] =
                _.without subscriptions[service][type], cb
            console.log "Unsubscribed from #{ service }/#{ type }"
    }

# Handle published events

socket.on 'event', (service, type, event) ->
    if cbs = subscriptions[service][type]
        cbs.map (cb) ->
            try
                cb event
            catch e
                console.error '[Error handling event] ' + e

# Resubscribe when reconnecting

first_connect = true
socket.on 'hello', ->
    console.log '[socket:hello] Connecting...'

    # Prevent re-connecting on initial load
    if first_connect
        first_connect = false
        return

    # Re-connect known subscriptions
    for service, types of subscriptions
        for type, fns of types
            socket.emit 'subscribe', service, type

# Creating event streams

window.eventStream = (service, event) ->
    Bacon.fromBinder((sink) ->
        subscribe service, event, (value) ->
            sink value
    ).endOnError((e) -> console.log '[ERROR]', e)

