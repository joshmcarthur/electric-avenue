libraries = "../../lib"

Preset = require("#{libraries}/preset")

exports.index = (req, resp) ->
  @presets = Preset.all()
  switch req.format
    when 'json'
      resp.send(@presets)
    else
      resp.render 'presets/index', {presets: @presets}

exports.create = (req, resp) ->
  preset_name = req.param('name').replace(/\.js/, '').concat('.js')
  contents = req.param('contents')
  return resp.send("Missing params", 406) unless preset_name and contents
  Preset.create(preset_name, contents)
  resp.redirect('/presets')

exports.update = (req, resp) ->
  preset_name = req.params.name.replace(/\.js/, '').concat('.js')
  contents = req.params.contents

  return resp.send("Missing params", 406) unless contents

  Preset.update(preset_name, contents)
  resp.redirect('/presets')

exports.destroy = (req, resp) ->
  preset_name = req.params.preset.replace(/\.js/, '').concat('.js')
  Preset.delete(preset_name)
  resp.redirect('/presets')

