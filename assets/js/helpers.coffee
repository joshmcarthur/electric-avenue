class Helpers

Helpers::bytesToSize = (bytes) ->
  sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB']
  return 'n/a' if (bytes == 0)
  i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)))
  return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i]

Helpers::stateMessage = (state) ->
  mappings = {
    "inactive": "In queue...",
    "active": "Now encoding...",
    "complete": "Encoding finished.",
    "failed": "Encoding failed. Please remove and try again."
  }

  return mappings[state]

Helpers::removeLinkText = (state) ->
  if state == "active" then "" else "Remove"

Array::filterOutValue = (v) -> x for x in @ when x!=v

window.Helpers = new Helpers()
