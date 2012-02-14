class FileLoader
  constructor: (@options) ->
    # Build container element
    # Add progress bar
    # Add filename textbox
    # Fire off upload
    this.addFile(file) for file in @options.files
    if window.XMLHttpRequestUpload
      @container = this.build_progress()
    else
      @container = this.build_spinner()

    @element   = options.element
    this.addToFileList(@options.fileListElement, file) for file in @files

  build_form: ->
    $("<form></form>", {action: @options.url, method: @options.method})
      .css('display': 'none')
      .append("<input></input>", {type: 'file', name: 'file', id: 'file'})

  addToFileList: (list_el, file) ->
    list_el.find('table tbody').append(
      $('<tr></tr>')
      .addClass('file')
      .data({file: file})
      .append(
        $('<td></td>').text("#{file.name} (#{Helpers.bytesToSize(file.size)})")
      )
    )
    list_el.show() if list_el.is(":hidden")

  build_spinner: ->
    spinner = $("<div></div>").addClass('spinner').spin({
      lines: 12,
      length: 7,
      width: 4,
      radius: 10,
      color: '#000',
      speed: 0.9,
      trail: 60,
      shadow: false,
      hwaccel: false
    })

    $("<div></div>", {id: 'fileupload'})
      .append(spinner)
      .append(
        $("<p></p>").text("Uploading files. Please wait, this will take some time.")
      )

  build_progress: ->
    $("<div></div>", {id: 'fileupload'})
      .append(
        $("<div></div>", {class: 'progress progress-info progress-striped active'}).append(
          $("<div></div>", {class: 'bar', style: 'width: 1%'})
        )
      )
      .append(
        $("<div></div>", {class: 'row'}).append(
          $("<div></div>", {class: 'span6'}).append(
            $("<h3></h3>", {class: 'filename'})
          )
        ).append(
          $("<div></div>", {class: 'span6'}).append(
            $("<h3></h3>", {class: 'filesize'})
          )
        )
      )
      .append(
        this.build_form()
      )

  removeFiles: ->
    @files = []

  removeFile: (file) ->
    @files = @files.filterOutValue(file)

  addFile: (file) ->
    @files ||= []
    @files.push(file) if (@files.indexOf(file) < 0)

    file

  startUpload: ->
    @element.replaceWith(@container)
    this.uploadFiles()

  uploadFiles: ->
    @request = new XMLHttpRequest()
    @request.onreadystatechange = this.completeLoad
    upload  = @request.upload

    if upload
      upload.onprogress = this.updateProgressBar

    data = new FormData()
    data.append(
      "files",
      file
    ) for file in @files
    data.append(
      "encoding_options[preset]",
      $('form#uploader select#encoding_preset').val()
    )

    @request.open(@options.method, @options.url, true)

    @request.send(data)

  completeLoad: (event) =>
    if (@request.readyState == 4 and @request.status == 200)
      encoding_job = JSON.parse(@request.responseText)
      $('body').trigger('encoding-added')
      @options.callback(encoding_job)

  updateProgressBar: (event) =>
    progress = Math.round((event.loaded * 100) / event.total)
    current = Helpers.bytesToSize(event.loaded)
    total   = Helpers.bytesToSize(event.total)
    @container.find('.filesize').text("#{current} / #{total}")
    @container.find('div.progress div.bar').css('width', "#{progress}%")


window.FileLoader = FileLoader
