kue         = require('kue')
ffmpeg      = require('fluent-ffmpeg')
fs          = require('fs')
path        = require('path')
jobs        = kue.createQueue()
tmpdir      = path.join(__dirname, '/tmp')
helpers     = require('./lib/helpers')


jobs.process('encoding', (encoding, done) ->
  encoding.data.link = "http://google.com"
  encoding.data.title = "<a href='#{encoding.data.path}'>#{encoding.data.title}</a>"

  # Move file to tmp directory
  # Encode
  # Callback
  old_path = encoding.data.path
  new_path = path.join(tmpdir, path.basename(old_path))
  fs.rename(old_path, new_path, (err) =>
    new ffmpeg(new_path)
    .usingPreset('divx')
    .onProgress( (progress) =>
      encoding.progress(
        helpers.Helpers.friendlyTimeToSecs(progress.time)
        helpers.Helpers.friendlyTimeToSecs(progress.total)
      )
    )
    .saveToFile(old_path, (return_code, error) ->
      done()
    )
  )
)
