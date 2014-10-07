somata = require 'somata/src'
path = require 'path'
pm2 = require 'pm2'
_ = require 'underscore'
util = require 'util'
tail = require 'tail'
pm2.connect()

{MEDULLA_EXT, MEDULLA_ROOT, MEDULLA_PREFIX} = process.env
medulla_id = _.compact([MEDULLA_PREFIX, 'medulla']).join(':')

tail_logs = (log_path, event_key) ->
    # Tail the stdout file
    stdout_tail = new tail.Tail log_path
    stdout_tail.on 'line', (stdout) ->
        medulla.publish event_key, stdout.toString() + '\n'

class ServiceProcess
    constructor: ({@name, @cwd, @command}) ->

        if !@cwd
            @cwd = MEDULLA_ROOT || process.cwd()
        else
            @cwd = @cwd.replace('~', process.env.HOME)

        if !@command
            ext = MEDULLA_EXT || ''
            @command = "services/#{ @name }#{ ext }"

    run: (cb) ->
        _pm2 = pm2.start @command,
            cwd: @cwd
            name: _.compact([MEDULLA_PREFIX, @name]).join(':')
        , (err, [_pm2]) =>
            @_pm2 = _pm2
            @id = @_pm2.pm_id
            @watchLogs()
            cb()

    watchLogs: ->
        stdout_event = "service:#{ @id }:stdout"
        tail_logs @_pm2.pm2_env.pm_out_log_path, stdout_event
        tail_logs @_pm2.pm2_env.pm_err_log_path, stdout_event

    restart: ->
        pm2.restart @_pm2.pm2_env.pm_id, ->

    stop: ->
        pm2.stop @_pm2.pm2_env.pm_id, ->

    toJson: ->
        {@name, @cwd, @command}

serviceProcessFromPM2 = (_pm2) ->
    [prefix, name] = _pm2.name.split(':')
    return null if prefix != MEDULLA_PREFIX

    cwd = _pm2.pm2_env.cwd
    command = _pm2.pm2_env.pm_exec_path.replace(cwd + '/', '')
    service_process = new ServiceProcess {name, cwd, command}
    service_process._pm2 = _pm2
    service_process.id = _pm2.pm_id
    service_process.watchLogs()

    return service_process

running_services = {}

startService = (_service, cb) ->
    new_service = new ServiceProcess(_service)
    new_service.run ->
        running_services[new_service.id] = new_service
        medulla.publish 'startService', new_service.toJson()
        cb null, {success: true}

restartService = (service, cb) ->
    console.log "Restarting: " + util.inspect service
    running_services[service.id].restart()
    cb null, {success: true}

stopService = (service, cb) ->
    running_services[service.id].stop()
    delete running_services[service.id]
    medulla.publish 'stopService', service
    cb null, {success: true}

listServices = (cb) ->
    pm2.list (err, ps) ->
        cb null, _.compact ps.map (_p) ->
            p = running_services[_p.pm_id]
            if !p?
                p = running_services[_p.pm_id] = serviceProcessFromPM2(_p)
            p

medulla = new somata.Service medulla_id, {
    listServices
    startService
    restartService
    stopService
}

