jasmine    = require('jasmine-node')
zombie     = require('zombie')
host       = 'http://localhost:4000'
browser    = new zombie.Browser(site: host)
video_file = "#{__dirname}/assets/video.avi"

describe "Electric Avenue Application", ->

  describe "GET /", ->
    it "loads a page", ->
      whenPageHasLoaded("/", ->
        expect(browser.statusCode).toEqual(200)
      )

    it "has correct title", ->
      whenPageHasLoaded("/", ->
        expect(browser.html('h1#title')).toEqual('Electic Avenue')
      )

  describe "POST /file", ->
    console.log(video_file)
    browser.attach 'file', video_file, (error, browser) ->
      console.log(browser.html())
      jasmine.asyncSpecDone()

    jasmine.asyncSpecWait()


  whenPageHasLoaded = (path, callback) ->
    browser.visit(path, (error, browser) ->
      callback.call()
      jasmine.asyncSpecDone()
    )
    jasmine.asyncSpecWait()
