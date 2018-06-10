import Viewer from './viewer.coffee'
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
    callback: (changes, positions)->
      for change in changes
        $('p', change.elem).html(change.index)
        $img = $('img', change.elem)
        # console.log $img.attr('src') + Math.round(Math.random()*9)
        $img.attr('src', $img.attr('src') + Math.round(Math.random()*9))
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

class DessinPath
  constructor: (@dessin)->
  start: (event)->
    [@lastX, @lastY] = @position(event)
    @listener = (e)=>
      e.preventDefault()
      e.stopPropagation()
      [@x, @y] = @position(event)
    @dessin.$element.on 'touchmove mousemove', @listener
  end: ->

class Dessin
  constructor: (@element)->
    @$element = $(@element)
    @$element.on 'mousedown touchstart', (e)->
      @tool = new @Tool(this)
      @tool.start((svg)->

      )

dessin = new Dessin
dessin.set_tool(Dessin.Path)
