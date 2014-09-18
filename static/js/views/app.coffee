D = React.DOM

console.log "Starting app..."

window.AppView = React.createClass

    getInitialState: ->
        tab: @props.tabs[0]

    render: ->
        D.div(null,
            D.div(id: 'tabs', @renderTabs())
            D.div(className: 'box', @renderTabContent())
        )

    renderTabs: ->
        # TODO: Clean this up
        tab_names = _.pluck @props.tabs, 'tabName'
        selected_tab_name = @state.tab.tabName
        selectTab = (t) =>
            @setState tab: _.findWhere @props.tabs, tabName: t
        
        tabs = [LogoView(key: 'logo')].concat tab_names.map (t) ->
            tabClass = 'tab'
            tabClass += ' selected' if t == selected_tab_name
            _selectTab = -> selectTab t
            D.span(key: t, className: tabClass, onClick: _selectTab, t)

    renderTabContent: ->
        @state.tab()

LogoView = React.createClass
    render: ->
        D.img(className: 'logo', src: "/images/somata-logo.svg")

