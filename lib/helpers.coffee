class Helpers

  # Format is hh:mm::ss.ms
  # Split and assume lowest is seconds
  friendlyTimeToSecs: (time_string) ->
    components = time_string.split(':')
    switch components.length
      when 1
        seconds = parseFloat(components[0])
      when 2
        seconds = parseFloat(components[1])
        minutes = parseInt(components[0]) * 60
      when 3
        seconds = parseFloat(components[2])
        minutes = parseInt(components[1]) * 60
        hours   = parseInt(components[0]) * 60 * 60

    Math.round(hours + minutes + seconds)

exports.Helpers = new Helpers()
