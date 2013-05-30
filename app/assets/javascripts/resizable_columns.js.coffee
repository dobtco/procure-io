$ = jQuery

$.fn.extend
  resizableColumns: (method) ->
    makeResizable = ($table) ->
      tableId = $table.data('resizable-columns-id')

      resetHandles = ->
        $(".rc-draghandle").css
          left: ''
          height: ''

      setSizes = (difference, pos) ->
        currentWidth = $table.find("tr:first th").eq(pos).width()
        columnId = tableId + "-" + $table.find("tr:first th").eq(pos).data('resizable-column-id')
        newWidth = currentWidth + difference

        $table.find("tr").each ->
          $(@).find("th").eq(pos).css
            width: newWidth

        store.set(columnId, newWidth)

        resetHandles()

      i = 0
      $table.find("tr:first th").each ->
        index = i

        columnId = tableId + "-" + $(@).data('resizable-column-id')

        $(@).css
          position: "relative"
          width: store.get(columnId)

        $dragHandle = $("<div class='rc-draghandle'></div>")

        $(@).append $dragHandle

        initialPos = undefined

        $dragHandle.draggable
          axis: "x"
          start: ->
            initialPos = $(@).offset().left
            $(@).addClass('dragging')
            $(@).height($table.height())
          stop: (e, ui) ->
            $(@).removeClass('dragging')
            difference = $(@).offset().left - initialPos
            setSizes(difference, index)

        i = i + 1

    $(@).each ->
      if method == 'destroy'
        $(@).find(".rc-draghandle").remove()
        $(@).find("th").css
          position: ''
          width: ''

      else
        makeResizable $(@)