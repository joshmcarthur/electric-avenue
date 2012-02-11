class KueHelpers
  getJobs: (callback) ->
    options = {
      host: 'localhost',
      port: 4001,
      path: '/jobs/0..10/asc'
    }

    require('http').get(options, (response) ->
      json = ""
      response.on('chunk', (data) ->
        json += data
      )

      response.on('end', ->
        callback(JSON.parse(json))
      )
    )

exports.KueHelpers = new KueHelpers()

