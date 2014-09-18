window.ServicesView = React.createClass

    getInitialState: ->
        services: []

    componentWillMount: ->

        Dispatcher.getServices (err, services) =>
            console.log('[ERROR]', err) if err
            services.map(@addService)

        @subscriptions = [
            Dispatcher.onStartService @addService
            Dispatcher.onStopService @removeService
        ]

    componentWillUnmount: ->
        @subscriptions.map (s) -> s.unsubscribe()

    # State updates
    # --------------------------------------------------------------------------

    addService: (service) ->
        @setState
            services: @state.services.concat [service]

    removeService: (service) ->
        matching = _.where @state.services, service
        @setState
            services: _.difference @state.services, matching

    # Actions
    # --------------------------------------------------------------------------

    startService: (e) ->
        e.preventDefault()
        new_service = @refs.new_service.state
        @refs.new_service.resetInputs()
        Dispatcher.startService(new_service)

    # Rendering
    # --------------------------------------------------------------------------

    render: ->
        service_views = @state.services.map(@renderService)
        new_service_view = NewServiceView
            ref: 'new_service'
            onSubmit: @startService
        D.div(null, new_service_view, service_views)

    renderService: (service) ->
        ServiceView
            key: service.name
            service: service

ServicesView.tabName = 'Services'

