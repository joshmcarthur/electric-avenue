kue         = require('kue')
ffmpeg      = require('fluent-ffmpeg')
fs          = require('fs')
path        = require('path')
jobs        = kue.createQueue()
tmpdir      = path.join(__dirname, '/tmp')
helpers     = require('./lib/helpers')


jobs.process('encoding', (encoding, done) ->
  # Move file to tmp directory
  # Encode
  # Delete temp files and original
  # Set new attributes on encoding
  # Callback
  old_path = encoding.data.path
  new_path = path.join(tmpdir, 'encoding', path.basename(old_path))
  encoded_path = path.join(tmpdir, 'complete', path.basename(old_path))
  fs.rename(old_path, new_path, (err) =>
    # Update the encoding before we start encoding. This ensures that
    # we can still remove the file, and the encoder will just fail - this is ok.
    encoding.data.path = new_path
    encoding.save()

    new ffmpeg(new_path)
    .usingPreset('divx')
    .onProgress( (progress) =>
      encoding.progress(
        helpers.Helpers.friendlyTimeToSecs(progress.time)
        helpers.Helpers.friendlyTimeToSecs(progress.total)
      )
    )
    .saveToFile(encoded_path, (return_code, error) ->
      fs.unlink(new_path, (err) ->
        throw err if err
        fs.stat(encoded_path, (err, stats) ->
          throw err if err
          encoding.data.filesize = stats.size
          encoding.data.path = encoded_path
          encoding.data.link = "/file/#{encoding.id}"
          encoding.save()
          done()
        )
      )
    )
  )
)
