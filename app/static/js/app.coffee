_ = require 'underscore'
React = require 'react'
ReactDOM = require 'react-dom'
somata = require './somata-stream'
d3 = require 'd3'
bus = require 'kefir-bus'

key$ = bus()

Store = {}

# App views
# ------------------------------------------------------------------------------

service_keys = ['host', 'port', 'client_id']

get_keys =
    memory: (d) ->
        d.memory
    cpu: (d) ->
        d.cpu

ServiceInstance = React.createClass
    getInitialState: ->
        show_details: false
        key: 'memory'

    componentDidMount: ->
        somata.remote('somata:dashboard:data', 'getStatuses', @props.id).onValue @foundStatuses
        #@foundStatuses()
        key$.onValue (key) =>
            console.log 'key', key
            @setState {key}, @renderGraph

    foundStatuses: (statuses) ->
        console.log statuses[0]
        @setState {statuses}
        @setupGraph()
        @renderGraph()

    setupGraph: ->
        @w = @refs.graph.clientWidth
        @h = 100

        svg = d3.select(@refs.graph)
            .append('svg')
        svg
            .attr('width', @w)
            .attr('height', @h)
        @graph = svg.append('g')

        @x = d3.time.scale()
            .range([0, @w])
            .domain(d3.extent @state.statuses, (d) -> d.time)
        @y = d3.scale.linear()
            .range([@h, 0])

    renderGraph: ->
        console.log 'key is', @state.key
        getKey = get_keys[@state.key]
        @y.domain(d3.extent @state.statuses, getKey)

        line = d3.svg.line()
            .x (d) => @x d.time
            .y (d) => @y getKey(d)

        @graph.selectAll('path').remove()
        path = @graph.append('path')
            .datum(@state.statuses)
            .attr('class', 'line')
            .attr('d', line)

    toggleDetails: ->
        @setState show_details: !@state.show_details

    render: ->
        <div className='instance'>
            <div className='details'>
                <h4 className='id' onClick=@toggleDetails>{@props.id}</h4>
                {if @state.show_details then service_keys.map (key) =>
                    <p className='detail'><strong>{key}</strong> {@props.instance[key]}</p>}
            </div>
            <div ref='graph' className='graph' />
        </div>

Keys = React.createClass
    getInitialState: ->
        key: Object.keys(get_keys)[0]

    didChoose: (key) -> =>
        @setState {key}
        key$.emit key

    render: ->
        <div>
            {Object.keys(get_keys).map (key) =>
                <a onClick=@didChoose(key)>{key}</a>}
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
        flattened: true

    componentDidMount: ->
        somata.remote('registry', 'findServices').onValue @foundServices
    
    foundServices: (services) ->
        services = _.pairs(services).map ([name, instances]) -> {name, instances: _.values(instances)}
        services = _.sortBy services, 'name'
        healthy_services = services.filter (s) -> s.instances.length > 0
        unhealthy_services = services.filter (s) -> s.instances.length == 0
        all_instances = _.flatten services.map (s) -> s.instances
        @setState {all_instances, healthy_services, unhealthy_services, loading: false}

    render: ->
        <div>
            {if @state.show_new
                <div className='services'>
                    <NewInstance />
                </div>
            }

            {if @state.loading
                <p className='loading'>Loading...</p>

            else if @state.flattened
                <div className='instances'>
                    {@state.all_instances.map (instance) ->
                        <ServiceInstance id=instance.id instance=instance />}
                </div>

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
            <Keys />
            <RegisteredServices />
        </div>

somata.authenticate (err, user) ->
    Store.user = user
    ReactDOM.render <App />, document.getElementById('app')

