somata = require 'somata'
async = require 'async'
_ = require 'underscore'
redis = require('redis').createClient()

POLL_TIME = 1000 * 60

client = new somata.Client

fetchInstanceStatus = (instance, cb) ->
    connection = new somata.Connection instance
    connection.sendMethod null, '_status', [], (err, status) ->
        cb err, {status, instance}
        connection.close()

saveInstanceStatus = (instance_status, cb) ->
    console.log '[saveInstanceStatus]', instance_status.instance.id
    time = new Date().getTime()
    status =
        time: time
        id: instance_status.instance.id
        uptime: instance_status.status.uptime
        memory: instance_status.status.memory
        cpu: instance_status.status.cpu

    status_key = "status:#{instance_status.instance.id}"
    console.log status_key
    redis.zadd status_key, time, JSON.stringify(status), (err, ok) ->
        cb null, status

fetchAndSaveInstanceStatus = (instance, cb) ->
    fetchInstanceStatus instance, (err, instance_status) ->
        console.log err if err
        saveInstanceStatus instance_status, cb

fetchAllServicesStatuses = ->
    client.remote 'registry', 'findServices', (err, services) ->
        all_instances = _.flatten(_.pairs(services)
            .map ([service_name, service_instances]) ->
                _.pairs(service_instances).map ([instance_id, instance]) ->
                    instance.name = service_name
                    instance
        )

        console.log 'fetched', all_instances.length
        for instance in all_instances
            console.log '* ' + instance.id

        async.map all_instances, fetchAndSaveInstanceStatus, (err, statuses) ->
            console.log err if err
            now = new Date
            statuses.map (status) ->
                console.log status.time, status.id, status.uptime, status.memory, status.cpu

fetchAllServicesStatuses()
setInterval fetchAllServicesStatuses, POLL_TIME

