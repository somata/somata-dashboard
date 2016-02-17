somata = require 'somata'
async = require 'async'
moment = require 'moment'
redis = require('redis').createClient()

keyToId = (k) -> k.split('status:')[1]
idToKey = (i) -> 'status:' + i

getAllStatusKeys = (cb) ->
    redis.keys "status:*", cb

getStatuses = (instance_id, cb) ->
    t0 = moment().subtract(1, 'day').toDate().getTime()
    redis.zrangebyscore idToKey(instance_id), t0, '+inf', (err, status_jsons) ->
        cb err, status_jsons?.map (s) -> JSON.parse(s)

getAllStatuses = (cb) ->
    getAllStatusKeys (err, status_keys) ->
        async.map status_keys.map(keyToId), getStatuses, cb

new somata.Service 'somata:dashboard:data', {
    getStatuses
    getAllStatuses
}

