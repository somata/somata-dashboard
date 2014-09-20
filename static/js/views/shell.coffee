ResultView = React.createClass
    componentDidMount: ->
        $(@getDOMNode()).JSONView(@props.data)

    render: ->
        D.div(className: 'result')

window.ShellView = React.createClass
    mixins: [FieldsMixin]

    getInitialState: ->
        command: ''
        results: []

    componentDidMount: ->
        @refs.command.getDOMNode().focus()

    runCommand: (e) ->
        e.preventDefault()
        Dispatcher.runCommand @state.command, @addResult

    addResult: (err, result_data) ->
        result =
            id: new Date().getTime()
            data: result_data
        @setState
            results: [result].concat @state.results

    # Rendering
    # --------------------------------------------------------------------------

    render: ->
        D.form(id: 'shell', onSubmit: @runCommand,
            @renderField('command')
            @state.results.map(@renderResult)
        )

    renderResult: (result) ->
        ResultView(key: result.id, data: result.data)

