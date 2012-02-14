jasmine        = require('jasmine-node')
zombie         = require('zombie')
encoding_queue = require('kue').createQueue()
host           = 'http://localhost:4000'
browser        = new zombie.Browser(site: host)
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
        browser.wait(1000, ->
          expect(browser.text('#filetarget .placeholder p')).toEqual('Drag-and-drop your video file here to add to the encoding queue')
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
        for row in browser.queryAll('table#presets tbody tr')
          do (row) ->
            expect(browser.query('form[action^="/presets/"] input[type=submit].btn')).toBeDefined()
        jasmine.asyncSpecDone()
      )

  describe "POST /presets", ->
    it "submits the form on the index page and creates a preset", ->
      whenPageHasLoaded('/presets', (browser) ->
        browser.fill('name', test_preset_name, ->
          browser.fill('contents', testPresetContent(), ->
            browser.pressButton('form#new_preset input[type=submit]', ->
              expect(browser.success).toBeTruthy()
              expect(browser.location.pathname).toEqual("/presets")
              expect(browser.html('table#presets tbody tr')).toMatch(/test_preset/)
            )
          )
        )

        jasmine.asyncSpecDone()
      )


    it "does not accept a preset without a name", ->
      whenPageHasLoaded('/presets', (browser) ->
        jasmine.asyncSpecDone()
        browser.fill('contents', testPresetContent())
        browser.pressButton('form#new_preset input[type=submit]', ->
          expect(browser.statusCode).toEqual(406)
        )
      )

    it "does not acccept a preset without file contents", ->
      whenPageHasLoaded('/presets', (browser) ->
        jasmine.asyncSpecDone()
        browser.fill('#preset_name', 'Test Preset 2', ->
          browser.pressButton('Save Preset', ->
            expect(browser.statusCode).toEqual(406)
          )
        )
      )

  describe "DELETE /preset/:preset", ->
    it "deletes the preset", ->
      whenPageHasLoaded('/presets', (browser) ->
        jasmine.asyncSpecDone()
        browser.pressButton("input##{test_preset_name}_delete", ->
          expect(browser.location.pathname).toEqual("/presets")
          expect(browser.html("table#presets tbody tr")).toMatch(new RegExp(test_preset_name))
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
    browser.visit(host + path, (error, browser) ->
      callback(browser)
    )
    jasmine.asyncSpecWait()
