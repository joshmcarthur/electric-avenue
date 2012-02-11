class Preset
  path = require('path')
  fs   = require('fs')
  preset_dir = path.join(__dirname, '..', 'node_modules', 'fluent-ffmpeg', 'lib', 'presets')

  constructor: ->
    this.readPresets()

  all: ->
    @presets

  find: (filename) ->
    @presets[filename]

  create: (filename, contents) ->
    fs.writeFile(path.join(preset_dir, filename), contents, 'utf-8', =>
      this.readPresets()
    )

  update: (filename, contents) ->
    this.create(filename, contents)

  delete: (filename) ->
    fs.unlink(path.join(preset_dir, filename), =>
      this.readPresets()
    )


  readPresets: ->
    @presets = []
    fs.readdir(preset_dir, (err, files) =>
      for filename in files
        do (filename) =>
          fs.readFile path.join(preset_dir, filename), (error, contents) =>
            throw error if error
            @presets.push({
              name: path.basename(filename, '.js')
              filename: filename
              contents: contents.toString()
            })
    )


module.exports = exports = new Preset()
