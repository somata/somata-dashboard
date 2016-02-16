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

status_extents = [-1, 0]
expandStatusExtents = (status) ->
    if status.time < status_extents[0] or status_extents[0] == -1
        status_extents[0] = status.time
    if status.time > status_extents[1]
        status_extents[1] = status.time

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
        statuses.map expandStatusExtents
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
        @y = d3.scale.linear()
            .range([@h, 0])

    renderGraph: ->
        console.log 'key is', @state.key
        getKey = get_keys[@state.key]
        @x.domain(status_extents)
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
            <div ref='graph' className='graph'></div>
        </div>

Keys = React.createClass
    getInitialState: ->
        key: Object.keys(get_keys)[0]

    didChoose: (key) -> =>
        @setState {key}
        key$.emit key

    render: ->
        <div className='keys'>
            {Object.keys(get_keys).map (key) =>
                <a onClick=@didChoose(key) className={if key==@state.key then 'active'}>{key}</a>}
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
                <div className='boxes'>
                    {@state.all_instances.map (instance) ->
                        <div className='box'>
                            <ServiceInstance id=instance.id instance=instance />
                        </div>}
                </div>

            else
                <div>
                    <div className='boxes'>
                        {@state.healthy_services.map (service) ->
                            <Service name=service.name instances=service.instances />}
                    </div>
                    <div className='boxes'>
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

Logo = React.createClass
    render: ->
        <div className='logo'>
        <svg version="1.1" viewBox="0 0 800 800">
            <g style={'fill-rule': 'evenodd', fill: 'none'}>
                <g className='main'>
                    <path d="M400 800C621 800 800 621 800 400 800 179 621 0 400 0 179 0 0 179 0 400 0 621 179 800 400 800ZM400 722C578 722 722 578 722 400 722 222 578 78 400 78 222 78 78 222 78 400 78 578 222 722 400 722Z"/>
                    <circle cx="262" cy="481" r="83"/>
                    <path d="M386 406C385 404 385 403 385 401L385 322C346 315 317 281 317 241 317 195 354 158 400 158 445 158 482 195 482 241 482 279 456 311 421 320L421 387 481 422C496 407 516 398 539 398 584 398 621 435 621 481 621 526 584 563 539 563 493 563 456 526 456 481 456 470 458 461 461 452L391 411C388 410 387 408 386 406Z"/>
                </g>
            </g>
        </svg>
        </div>

App = React.createClass
    getInitialState: -> {}

    render: ->
        <div id="main">
            <div className="header">
                <Logo />
                <Keys />
            </div>
            <RegisteredServices />
        </div>

somata.authenticate (err, user) ->
    Store.user = user
    ReactDOM.render <App />, document.getElementById('app')

