import Viewer from './viewer.coffee'
import Drawing from './drawing.coffee'
# import Drawer from './viewer.coffee'
import $ from '../node_modules/jquery/dist/jquery'
window.$ = $

import css from './index.sass'

$ ->
  i = 0
  window.draw = ->
    $('svg').on 'mousedown mousemove mouseup', (e)->
      console.log e.offsetX, e.offsetY, e.clientX, e.clientY
      if e.shiftKey
        e.preventDefault()
        e.stopPropagation()
        return false
      return true
  window.v = new Viewer(
    elem: document.getElementsByClassName('viewer')[0]
    change: (changes, positions)->
      console.log arguments...
      for change in changes
        $('p', change.elem).html(change.index)
        $img = $('img', change.elem)
      $('svg').remove()
      for position in positions
        console.log window.v.index, position.index
        if window.v.index == position.index
          $svg = $('<svg xmlns="http://www.w3.org/2000/svg" \
            xmlns:xlink="http://www.w3.org/1999/xlink" \
            version="1.1" \
            xml:space="preserve"></svg>')
          $svg.addClass('drawing')
          console.log $svg
          $div = $('<div style="position: absolute; top: 50px; bottom: 50px; left: 50px; right: 50px;"></div>')
          $div.append($svg)
          $(position.elem).append($div)
          drawing = new Drawing($svg[0])
        # console.log $img.attr('src') + Math.round(Math.random()*9)
        # $img.attr('src', $img.attr('src') + Math.round(Math.random()*9))
    destroyed: (e)->
      $(e).remove()
  )
  # v.down([[50,50]])
  # setTimeout( ->
  #   v.move([[45,45]])
  #   setTimeout( ->
  #     v.up([[45, 45]])
  #   , 1000)
  # , 1000)
# # $('body').on 'mousemove', ->
#   console.log 'MOUSE MOVE BODY !'
# setTimeout(->
#   v.set_index(30)
# , 1000)
# v.$items = [0, 1, 2]
# v._rotate_items(1)
# console.log v.$items
