class JobMonitor
  constructor: (@collection, @template) ->

  connect: (host = "localhost") ->
    @socket = io.connect(host)
    this.load()

    setInterval(this.load, 1000)

    @socket.on('encodings_response', (data) =>
      this.clearCollection()
      if (data.length > 0)
        this.addToCollection(encoding) for encoding in data
      else
        this.collectionIsEmpty()

    )

    # Bind a custom event to the body element - we can then trigger this event
    # elsewhere in our code
    $('body').bind('encoding-added', =>
      this.load()
    )

    $('body').bind('encoding-removed', =>
      this.load()
    )

    null

  load: =>
    @socket.emit('encodings_request')

  collectionIsEmpty: ->
    @collection.append(
      $('<tr></tr>').addClass('empty').append(
        $('<td></td>', {colspan: 6}).text("No encodings queued...")
      )
    )


  clearCollection: ->
    @collection.find('tbody tr').remove()

  addToCollection: (encoding) ->
    row = $('<tr></tr>').append(
      $('<td></td>').html(encoding.data.title)
      $('<td></td>').text(encoding.data.created_at)
      $('<td></td>').text(Helpers.bytesToSize(encoding.data.filesize))
      $('<td></td>').html(
        if encoding.state == "active"
          $('<div></div>', {class: 'progress progress-striped'}).append(
            $('<div></div>', {class: 'bar', style: "width: #{parseInt(encoding.progress)}%"})
          )
        else
          Helpers.stateMessage(encoding.state)
      )
      $('<td></td>').append(
        $('<a></a>')
        .data('encoding-settings', "Encoding options:")
        .text('...')
        .attr('href', '#')
        .addClass('settings-popover')
        .hover( ->
          $(this).popover()
        )
        .click((event) ->
          console.log("hit")
          event.stopPropagation()
          event.preventDefault()

          $(this).popover('show')

          return false
        )
      )
      $('<td></td>').append(
        $('<a></a>')
        .data('job-id', encoding.id)
        .text(Helpers.removeLinkText(encoding.state))
        .attr('href', '#')
        .click((event) ->
          event.stopPropagation()
          event.preventDefault()

          $.ajax(
            url: "/file/#{$(this).data('job-id')}"
            type: 'delete',
            success: =>
              $('body').trigger('encoding-removed')
              $(this).parent().parent().remove()

          )
        )
      )
    )
    row.prependTo(@collection.find('tbody'))




window.JobMonitor = JobMonitor
