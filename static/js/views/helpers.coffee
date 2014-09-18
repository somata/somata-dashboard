window.D = React.DOM

window.ActionsView = React.createClass

    doAction: ->
        alert('action')

    render: ->
        D.div(className: 'actions',
            _.map(@props.actions, @renderAction)
        )

    renderAction: (action, action_name) ->
        D.a(key: action_name, onClick: action, action_name)

window.FieldsMixin =

    # Actions
    # --------------------------------------------------------------------------

    updateField: (named) ->
        (e) =>
            state_update = {}
            state_update[named] = e.target.value
            @setState state_update, ->
                @validate() if @validate?

    # Rendering
    # --------------------------------------------------------------------------

    renderField: (named) ->
        D.input
            ref: named
            value: @state[named]
            onChange: @updateField(named)
            placeholder: named

