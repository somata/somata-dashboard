_ = require 'underscore'
React = require 'react'
ReactDOM = require 'react-dom'
somata = require './somata-stream'

Store = {}

# App views
# ------------------------------------------------------------------------------

service_keys = ['host', 'port', 'client_id']

ServiceInstance = React.createClass
    render: ->
        <div className='instance'>
            <h4 classNae='id'>{@props.id}</h4>
            {service_keys.map (key) =>
                <p className='detail'><strong>{key}:</strong> {@props.instance[key]}</p>}
        </div>

Service = React.createClass
    render: ->
        <div className='service'>
            <h3 className='name'>{@props.name}</h3>
            {@props.instances.map (instance) ->
                <ServiceInstance id=instance.id instance=instance />}
            {if @props.instances.length == 0
                <p className='empty'>No healthy instances.</p>}
        </div>

RegisteredServices = React.createClass
    getInitialState: ->
        services: []
        loading: true
        show_new: false

    componentDidMount: ->
        somata.remote('registry', 'findServices').onValue @foundServices
    
    foundServices: (services) ->
        services = _.pairs(services).map ([name, instances]) -> {name, instances: _.values(instances)}
        services = _.sortBy services, 'name'
        healthy_services = services.filter (s) -> s.instances.length > 0
        unhealthy_services = services.filter (s) -> s.instances.length == 0
        @setState {healthy_services, unhealthy_services, loading: false}

    render: ->
        <div>
            {if @state.show_new
                <div className='services'>
                    <NewInstance />
                </div>
            }
            {if @state.loading
                <p className='loading'>Loading...</p>
            else
                <div>
                    <div className='services'>
                        {@state.healthy_services.map (service) ->
                            <Service name=service.name instances=service.instances />}
                    </div>
                    <div className='services'>
                        {@state.unhealthy_services.map (service) ->
                            <Service name=service.name instances=service.instances />}
                    </div>
                </div>
            }
        </div>

NewInstance = React.createClass
    getInitialState: -> {}

    onSubmit: (e) ->
        e.preventDefault()
        #somata.remote('registry', 'registerService', 'info')

    onChange: (key) -> (e) =>
        state_change = {}
        state_change[key] = e.target.value
        @setState state_change

    render: ->
        <form onSubmit=@onSubmit className='new service'>
            {@renderInput 'name'}
            <div className='instance'>
                {@renderInput 'id'}
                {service_keys.map @renderInput}
                <button>Register</button>
            </div>
        </form>

    renderInput: (key) ->
        <p className='detail'>
            <input value=@state[key] onChange=@onChange(key) placeholder=key />
        </p>

App = React.createClass
    getInitialState: -> {}

    render: ->
        <div id="main">
            <h1>Services</h1>
            <RegisteredServices />
        </div>

somata.authenticate (err, user) ->
    Store.user = user
    ReactDOM.render <App />, document.getElementById('app')

