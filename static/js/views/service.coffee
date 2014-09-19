window.ServiceView = React.createClass

    # State updates
    # --------------------------------------------------------------------------

    toggleLogs: ->
        @refs.logs.toggleOpen()

    # Actions
    # --------------------------------------------------------------------------

    stop: (e) ->
        e.stopPropagation()
        Dispatcher.stopService(@props.service)

    restart: (e) ->
        e.stopPropagation()
        Dispatcher.restartService(@props.service)

    clear: (e) ->
        e.stopPropagation()
        @refs.logs.clear()

    # Rendering
    # --------------------------------------------------------------------------

    render: ->
        D.div(className: 'service', onClick: @toggleLogs,
            ActionsView(actions: {
                stop: @stop
                restart: @restart
                clear: @clear
            }),
            D.span(className: 'name', @props.service.name),
            D.span(className: 'dir', @props.service.dir),
            D.span(className: 'command', @props.service.command)
            ServiceLogsView(service: @props.service, ref: 'logs')
        )

