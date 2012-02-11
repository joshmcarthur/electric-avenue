#= require helpers
#= require file_loader
#= require job_monitor
#= require bootstrap.min.js
#= require jquery.tmpl.min.js
#= require bootstrap-tooltip.js
#= require bootstrap-popover.js
#= require bootstrap-button.js

jQuery.event.props.push('dataTransfer')
$ ->
  resetUpload()
  bindPopover()
  bindFileUpload()
  new JobMonitor($('table#encodings'), $('#templates #encoding_table_row tr')).connect()

resetUpload = ->
  window.file_loader = null
  $('#filetarget').html(getTemplate('new_upload'))
  $('#filetarget')
  .bind 'dragover', (event) ->
    $(this).addClass('ready-to-drop')
    event.preventDefault()
    return false
  .bind 'dragleave', ->
    $(this).removeClass('ready-to-drop')
    event.preventDefault()
    return false
  .bind 'drop', uploadFiles

  $('#files').hide()
  $('form#uploader input').attr('disabled', false)
  $('form#uploader input.primary').button('reset')


getTemplate = (template_name) ->
  $("#templates ##{template_name}").html()

uploadFiles = (event) ->
  event.preventDefault()
  event.stopPropagation()
  $(this).removeClass('ready-to-drop')
  window.file_loader = new FileLoader(
    files: event.dataTransfer.files
    fileListElement: $('#files')
    element: $(this).find('.placeholder')
    method: 'POST'
    url: 'http://localhost:4000/file'
    callback: uploadSuccess
  )

uploadSuccess = (encoding) ->
  resetUpload()

bindPopover = ->
  $('a.settings-popover').popover(
    placement: 'bottom'
    title: 'Encoding Settings'
  )

bindFileUpload = ->
  $('form#uploader')
  .bind('reset', (event) ->
    event.stopPropagation()

    $(this).find('tr').remove()
    $(this).closest('div#files').hide()
    window.file_loader.removeFiles()
  )
  .bind('submit', (event) ->
    event.stopPropagation()
    event.preventDefault()

    $(this).find('input.primary').button('loading')
    $(this).find('input').attr('disabled', true)

    window.file_loader.startUpload()
  )

