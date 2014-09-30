somata = require 'somata/src'
path = require 'path'
forever = require 'forever-monitor'
_ = require 'underscore'
util = require 'util'

medulla_id = _.compact([process.env.MEDULLA_PREFIX, 'medulla']).join(':')

class ServiceProcess
    constructor: ({@name, @dir, @command}) ->
        if !@dir
            @dir = process.env.MEDULLA_ROOT || '~/Projects/gofish'
        if !@command
            ext = process.env.MEDULLA_EXT || ''
            @command = "coffee services/#{ @name }#{ ext }"
        @dir = @dir.replace('~', process.env.HOME)

    runForever: ->
        @_forever = forever.start null,
            cwd: @dir
            command: @command

        stdout_event = "service:#{ @name }:stdout"
        @_forever.on 'stdout', (stdout) ->
            medulla.publish stdout_event, stdout.toString()
        @_forever.on 'stderr', (stdout) ->
            medulla.publish stdout_event, stdout.toString()

    toJson: ->
        {@name, @dir, @command}

running_services = {}

startService = (_service, cb) ->
    new_service = new ServiceProcess(_service)
    new_service.runForever()
    running_services[new_service.name] = new_service
    medulla.publish 'startService', new_service.toJson()
    cb null, {success: true}

restartService = (service, cb) ->
    running_services[service.name]._forever.restart()
    cb null, {success: true}

stopService = (service, cb) ->
    running_services[service.name]._forever.stop()
    delete running_services[service.name]
    medulla.publish 'stopService', service
    cb null, {success: true}

listServices = (cb) ->
    cb null, _.values(running_services).map((s) -> s.toJson())

medulla = new somata.Service medulla_id, {
    listServices
    startService
    restartService
    stopService
}

