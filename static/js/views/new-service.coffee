window.NewServiceView = React.createClass
    mixins: [FieldsMixin]

    getInitialState: ->
        name: ''
        cwd: ''
        command: ''
        valid: false

    resetInputs: ->
        @setState @getInitialState()

    validate: ->
        @setState valid: @state.name.length > 0

    # Rendering
    # --------------------------------------------------------------------------

    render: ->
        D.form(onSubmit: @props.onSubmit,
            @renderField('name'),
            @renderField('cwd'),
            @renderField('command'),
            D.button(disabled: !@state.valid, "Start")
        )

