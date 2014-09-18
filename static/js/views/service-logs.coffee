window.ServiceLogsView = React.createClass
    
    getInitialState: ->
        open: false
        count: 0
        data: ''

    getCount: ->
        _.compact(@state.data.split('\n')).length

    componentWillMount: ->
        @subscriptions = [
            Dispatcher.onServiceLogs @props.service, @addData
        ]

    componentWillUnmount: ->
        @subscriptions.map (s) -> s.unsubscribe()

    # State updates
    # --------------------------------------------------------------------------

    addData: (d) ->
        console.log "Trying to add data: " + d
        console.log @state
        @setState
            data: @state.data + d
            fresh: !@state.open

    # Actions
    # --------------------------------------------------------------------------

    toggleOpen: ->
        @setState
            open: !@state.open
            fresh: false

    clear: ->
        @setState data: ''

    # Rendering
    # --------------------------------------------------------------------------

    render: ->
        log_count_class = _.compact([
            'log_count'
            'fresh' if @state.fresh
            'open' if @state.open
        ]).join(' ')

        count = @getCount()
        showing = @state.open && count > 0

        D.div(className: 'logs',
            D.div(className: log_count_class, count),
            ActionsView(actions: clear: @clear) if showing,
            D.pre({}, @state.data) if showing
        )

