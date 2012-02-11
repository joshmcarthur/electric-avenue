express   = require 'express'
socketio  = require 'socket.io'
fs        = require 'fs'
Preset    = require './lib/preset'
stylus    = require 'stylus'
assets    = require 'connect-assets'
kue       = require 'kue'
Job       = require 'kue/lib/queue/job'
encoding  = require './lib/encoding'
query = require './lib/kue_query'
jobs      = kue.createQueue()
kue_query = new query.KueQuery(jobs)

app = express.createServer()
io = socketio.listen(app)
app.use assets()
app.use express.bodyParser(
  keepExtensions: true
  uploadDir: "#{__dirname}/tmp/queued"
)

app.set 'view engine', 'jade'


app.get '/', (req, resp) -> resp.render 'index'

app.get '/presets', (req, resp) ->
  pres = []
  pres.push(preset) for preset in Preset.all()
  resp.send(pres)


app.get '/file/:id', (req, resp) ->
  # Serve the file back as a 'download'
  console.log(req.params.id.split('.')[0])
  Job.get(req.params.id.split('.')[0], (error, job) ->
    return resp.send('File not found', 404) unless job
    resp.download(job.data.path, job.data.title)
  )

app.post '/file', (req, resp) ->
  # Save file to the filesystem, returning path
  # Parse options to JSON
  # Enqueue the encoding job
  # Return a JSON hash of the job id, the filename, and the encoding
  # options
  files = req.files.files
  files = [files] unless files instanceof Array
  results = []
  results.push(
    new encoding.Encoding(file, req.params['options']).enqueue_onto(jobs)
  ) for file in files

  resp.send(results)

app.del '/file/:id', (req, resp) ->
  Job.get(req.params.id, (err, job) ->
    fs.unlink(job.data.path, (err) ->
      Job.remove(job.id, ->
        resp.send({success: true})
      )
    )
  )

io.sockets.on('connection', (socket) =>
  socket.on('encodings_request', =>
    kue_query.all((all_jobs) =>
      if all_jobs == null or all_jobs.length == 0
        socket.emit('encodings_response', [])
      else
        socket.emit('encodings_response', all_jobs)
    )
  )
)

kue.app.listen(4001)
app.listen process.env.VMC_APP_PORT or 4000, -> console.log 'Listening...'
