jasmine        = require('jasmine-node')
Browser        = require('zombie')
encoding_queue = require('kue').createQueue()
host           = 'http://localhost:4000'
test_preset_name = 'test_preset'
video_file     = "#{__dirname}/assets/video.avi"

describe "Electric Avenue Application", ->
  beforeEach( ->
    # Clear the queue
    encoding_queue.client.flushall()
  )

  describe "GET /", ->
    it "loads a page", ->
      whenPageHasLoaded("/", (browser) ->
        expect(browser.success).toBeTruthy()
        jasmine.asyncSpecDone()
      )

    it "has correct title", ->
      whenPageHasLoaded("/", (browser) ->
        expect(browser.text('a#title')).toEqual('Electric Avenue')
        jasmine.asyncSpecDone()
      )

    it "has somewhere to upload files", ->
      whenPageHasLoaded("/", (browser) ->
        browser.wait(2000, ->
          expect(browser.text('#filetarget .placeholder p')).toMatch(/Drag-and-drop your video file/)
          jasmine.asyncSpecDone()
        )
      )

    it "displays 'no encodings' message in the queue table", ->
      whenPageHasLoaded("/", (browser) ->
        browser.wait(2000, ->
          expect(browser.text('table#encodings tbody tr')).toMatch(/No encodings/)
          jasmine.asyncSpecDone()
        )
      )

    it "uploads a file", ->
      whenPageHasLoaded('/', (browser) ->
        browser.attach('file', video_file, ->
          browser.wait(1000, ->
            browser.fire('change', browser.query('input[name=file]'), ->
              expect(browser.text('#uploader table tr')).toMatch(/video\.avi/)
              jasmine.asyncSpecDone()
            )
          )
        )
      )


    it "displays the queue status", ->

    it "has a download link for the file", ->

    it "deletes the file", ->


  describe "GET /presets", ->
    it "loads a page", ->
      whenPageHasLoaded("/presets", (browser) ->
        expect(browser.success).toBeTruthy()
        jasmine.asyncSpecDone()
      )

    it "lists presets", ->
      whenPageHasLoaded("/presets", (browser) ->
        expect(browser.queryAll('table#presets tbody tr').length).toBeGreaterThan(0)
        jasmine.asyncSpecDone()
      )

    it "has a form to make a new preset", ->
      whenPageHasLoaded("/presets", (browser) ->
        expect(browser.query('form[action=/presets]')).toBeDefined()
        jasmine.asyncSpecDone()
      )


    it "has a button to delete each preset", ->
      whenPageHasLoaded('/presets', (browser) ->
        jasmine.asyncSpecDone()
        for row in browser.queryAll('table#presets tbody tr')
          do (row) ->
            expect(browser.query('form[action^="/presets/"] input[type=submit].btn')).toBeDefined()
      )

  describe "POST /presets", ->
    it "submits the form on the index page and creates a preset", ->
      whenPageHasLoaded('/presets', (browser) ->
        browser
        .fill('name', test_preset_name)
        .fill('contents', testPresetContent())
        .pressButton('Save Preset', ->
          jasmine.asyncSpecDone()
          expect(browser.success).toBeTruthy()
          expect(browser.location.pathname).toEqual("/presets")
          expect(browser.html('table#presets tbody tr')).toMatch(new RegExp(test_preset_name))
        )
      )

    it "does not accept a preset without a name", ->
      whenPageHasLoaded('/presets', (browser) ->
        browser
        .fill('name', null)
        .fill('contents', testPresetContent())
        .pressButton('Save Preset', ->
          expect(browser.statusCode).toEqual(406)
          jasmine.asyncSpecDone()
        )
      )

    it "does not acccept a preset without file contents", ->
      whenPageHasLoaded('/presets', (browser) ->
        browser
        .fill('name', 'Test Preset 2')
        .fill('contents', null)
        .pressButton('Save Preset', ->
          expect(browser.statusCode).toEqual(406)
          jasmine.asyncSpecDone()
        )
      )

  describe "DELETE /preset/:preset", ->
    it "deletes the preset", ->
      whenPageHasLoaded('/presets', (browser) ->
        browser.pressButton("input##{test_preset_name}_delete", ->
          expect(browser.location.pathname).toEqual("/presets")
          expect(browser.html("table#presets tbody tr")).toNotMatch(new RegExp(test_preset_name))
          jasmine.asyncSpecDone()
        )
      )


  testPresetContent = ->
    preset = "exports.load = function(ffmpeg) {
      ffmpeg
        .toFormat('avi')
        .withVideoBitrate('1024k')
        .withVideoCodec('mpeg4')
        .withSize('720x?')
        .withAudioBitrate('128k')
        .withAudioChannels(2)
        .withAudioCodec('libmp3lame')
        .addOptions([ '-vtag DIVX' ]);
      return ffmpeg;
      };"
    preset

  whenPageHasLoaded = (path, callback) ->
    Browser.visit(host + path, {waitFor: 1500, site: host}, (error, browser) ->
      throw error if error
      callback(browser)
    )
    jasmine.asyncSpecWait()
