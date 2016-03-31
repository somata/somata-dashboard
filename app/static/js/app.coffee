_ = require 'underscore'
React = require 'react'
ReactDOM = require 'react-dom'
somata = require './somata-stream'
d3 = require 'd3'
bus = require 'kefir-bus'
Kefir = require 'kefir'
moment = require 'moment'

Store = {}

Dispatcher =
    key$: bus()
    refresh$: bus()

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

colors = d3.scale.category20()

ServiceGraph = React.createClass
    getInitialState: ->
        show_details: false
        key: 'memory'

    componentDidMount: ->
        Dispatcher.key$.onValue @setKey

    componentWillUnmount: ->
        Dispatcher.key$.offValue @setKey

    setKey: (key) ->
        @setState {key}

    render: ->
        x = d3.time.scale()
            .range([0, 100])
        y = d3.scale.linear()
            .range([100, 0])

        x.domain(status_extents)

        getKey = get_keys[@state.key]

        all_statuses = _.flatten(@props.instance_statuses.map ({statuses}) -> statuses)
        y.domain(d3.extent all_statuses, getKey)

        line = d3.svg.line()
            .x (d) -> x d.time
            .y (d) -> y getKey(d)

        <div ref='graph' className='graph'>
            <svg viewBox="0 0 100 100" preserveAspectRatio="none">
                {@props.instance_statuses.map ({instance_id, statuses}) =>
                    line_class = 'line'
                    if !@props.instance_health[instance_id]
                        line_class += ' unhealthy'
                    <path className=line_class d=line(statuses) key=instance_id />
                }
            </svg>
        </div>

Keys = React.createClass
    getInitialState: ->
        key: Object.keys(get_keys)[0]

    didChoose: (key) -> =>
        @setState {key}
        Dispatcher.key$.emit key

    render: ->
        <div className='keys'>
            {Object.keys(get_keys).map (key) =>
                <a onClick=@didChoose(key) className={if key==@state.key then 'active'} key=key>{key}</a>}
        </div>

AllServiceStatuses = React.createClass
    getInitialState: ->
        loading: true
        all_statuses: []

    componentDidMount: ->
        @findServices()

    findServices: ->
        somata.remote('registry', 'findServices')
            .onValue @foundServices
            .onValue @findAllStatuses

    foundServices: (services) ->
        instances = _.flatten(_.values(services))
        instances = _.flatten instances.map (instance_) -> _.values(instance_)
        instances = instances.filter (instance_) -> instance_?
        instance_health = _.object instances.map (instance) -> [instance.id, true]
        @setState {instance_health}

    findAllStatuses: ->
        somata.remote('somata:dashboard:data', 'getAllStatuses').onValue @foundAllStatuses

    foundAllStatuses: (all_statuses) ->
        _.flatten(all_statuses.map ({statuses}) -> statuses).map expandStatusExtents
        @setState {all_statuses}

    render: ->
        <div className='boxes'>
            {_.pairs(_.groupBy(@state.all_statuses, ({instance_id}) -> instance_id.split('~')[0])).map ([service_name, instance_statuses]) =>
                <div key=service_name className='box'>
                    <div className='name'>{service_name}</div>
                    <div className='instance'>
                        <ServiceGraph service_name=service_name instance_health=@state.instance_health instance_statuses=instance_statuses />
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
        <p className='detail' key=key>
            <input value=@state[key] onChange=@onChange(key) placeholder=key />
        </p>

Logo = React.createClass
    refresh: ->
        Dispatcher.refresh$.emit true

    render: ->
        <a className='logo' onClick=@refresh>
            <svg version="1.1" viewBox="0 0 800 800">
                <g style={fillRule: 'evenodd', fill: 'none'}>
                    <g className='main'>
                        <path d="M400 800C621 800 800 621 800 400 800 179 621 0 400 0 179 0 0 179 0 400 0 621 179 800 400 800ZM400 722C578 722 722 578 722 400 722 222 578 78 400 78 222 78 78 222 78 400 78 578 222 722 400 722Z"/>
                        <circle cx="262" cy="481" r="83"/>
                        <path d="M386 406C385 404 385 403 385 401L385 322C346 315 317 281 317 241 317 195 354 158 400 158 445 158 482 195 482 241 482 279 456 311 421 320L421 387 481 422C496 407 516 398 539 398 584 398 621 435 621 481 621 526 584 563 539 563 493 563 456 526 456 481 456 470 458 461 461 452L391 411C388 410 387 408 386 406Z"/>
                    </g>
                </g>
            </svg>
        </a>

App = React.createClass
    getInitialState: -> {}

    render: ->
        <div id="main">
            <div className="header">
                <Logo />
                <Keys />
            </div>
            <AllServiceStatuses />
        </div>

somata.authenticate (err, user) ->
    Store.user = user
    ReactDOM.render <App />, document.getElementById('app')

