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
        @setState
            data: @state.data + d
            alert: @state.alert || (d.match('ERROR') && !@state.open)

    # Actions
    # --------------------------------------------------------------------------

    toggleOpen: ->
        @setState
            open: !@state.open
            alert: false

    clear: (e) ->
        e.stopPropagation()
        @setState data: ''

    # Rendering
    # --------------------------------------------------------------------------

    render: ->
        log_count_class = _.compact([
            'log_count'
            'alert' if @state.alert
            'open' if @state.open
        ]).join(' ')

        count = @getCount()
        showing = @state.open && count > 0

        D.div(className: 'logs',
            D.div(className: log_count_class, count),
            ActionsView(actions: clear: @clear) if showing,
            D.pre(dangerouslySetInnerHTML: __html: @renderLogs()) if showing
        )

    renderLogs: ->
        colorErrors = (line) ->
            if line.match 'ERROR'
                "<span class='error'>#{ line }</span>"
            else
                line
        @state.data.split('\n').map(colorErrors).join('\n')

