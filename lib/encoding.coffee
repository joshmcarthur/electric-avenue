class Encoding
  constructor: (@file, @options) ->
    @options = {} unless @options

  enqueue_onto: (queue) ->
    @job = queue.create('encoding', this.toJSON(false)).save()
    this.toJSON(false)

  toJSON: (return_string = false)->
    @json ||= {
      title: @file.name,
      mimetype: @file.type,
      filesize: @file.size,
      path: @file.path
      created_at: new Date().toString(),
      encoding_options: @options,
    }

    if return_string then return JSON.stringify(@json) else return @json

exports.Encoding = Encoding
