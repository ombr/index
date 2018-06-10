import css from './viewer.sass'
import Geometry from './geometry.coffee'
import DownListener from './down_listener.coffee'
import MoveListener from './move_listener.coffee'
import UpListener from './up_listener.coffee'
class Viewer
  constructor: (@_config)->
    @_down = new DownListener(@_config.elem,
      down: ()=> @down(arguments...)
    )
    @element = @_config.elem
    @drag = false
    @destroyed = false
    @locked = false

    @translation = [0, 0]
    @scale_center = [50, 50]
    @scale = 1.0
    @last_up = 0

    @viewer_content = @element.getElementsByClassName('viewer-content')[0]
    @viewer_background = @element.getElementsByClassName('viewer-background')[0]

    @index = null
    @visible = false

    @items = @element.getElementsByClassName('viewer-container')
    @items = [@items[0], @items[1], @items[2]]

    for item in @items
      item.style.display = ''
    @items[0].style.transform = 'translate(-100%) scale(1)'
    @items[2].style.transform = 'translate(100%) scale(1)'
  down: ->
    console.log 'Viewer Down !'
    return if @drag
    @drag = true
    @last_touches = []
    @_move = new MoveListener(
      @element,
      move: => @move(arguments...)
     )
    @_up = new UpListener(
      @element,
      up: (e)=> @up(arguments...)
    )
    @element.classList.remove('viewer-annimate')
    @element.classList.remove('viewer-annimate-origin')
    @drag = true
  up: (touches)->
    @_move.destroy()
    @_up.destroy()
    @drag = false
    @viewer_background.style.opacity = 1
    if Geometry.distance(@translation) < 10
      if Date.now() - @last_up  < 300
        @last_up = 0
        if @scale > 1
          @scale = 1.0
          @translation = [0, 0]
          @_config.show_controls() if @_config.show_controls?
        else
          @scale = 3.0
          @scale_center = @position_relative(touches[0])
          # Cancel previous toggle ?
          @_config.toggle_controls() if @_config.toggle_controls?
        @element.classList.add('viewer-annimate')
        @update_position()
        return
      else
        @_config.toggle_controls() if @_config.toggle_controls?
        @last_up = Date.now()
    if @scale < 0.1 # close
      return @hide()
    if @scale > 1
      # Change percent to relative size !!
      if @scale_center[0] > 100
        @scale_center[0] = 100
      if @scale_center[0] < 0
        @scale_center[0] = 0
      if @scale_center[1] > 100
        @scale_center[1] = 100
      if @scale_center[1] < 0
        @scale_center[1] = 0
      @element.classList.add('viewer-annimate')
      @element.classList.add('viewer-annimate-origin')
      @update_position()
    else
      # Mode transition classiques
      if Math.abs(@translation[1]) > 50
        return @hide()

      unless @single_image
        if Math.abs(@translation[0]) > 15
          if @translation[0] < 0
            return @set_index(@index+1, annimate: true)
          else
            return @set_index(@index-1, annimate: true)
      return @set_index(@index, annimate: true)
  move: (touches)->
    return if @destroyed
    if @last_touches.length > 0
      translation = @position_relative(
        Geometry.translation(touches, @last_touches)
      )
      @scale += Geometry.scale(touches, @last_touches)
      @scale = 5 if @scale > 5
      @scale = 0.5 if @scale < 0.5
      if @scale == 1
        @translation = [
          @translation[0] - translation[0],
          @translation[1] - translation[1]
        ]
      else
        @translation = [0, 0]
        @scale_center = [
          @scale_center[0] + translation[0]/@scale,
          @scale_center[1] + translation[1]/@scale
        ]
      @update_position()
      @viewer_background.style.opacity =
        Math.max(0, 1-(Math.abs(@translation[1]/100.0)))
    @last_touches = touches

  hide: ->
    @visible = false
    @element.style.display = 'none'
    @_config.hide() if @_config.hide?
  show: ->
    @visible = true
    @element.style.display = 'block'
    @_config.show() if @_config.show?
  destroy: ->
    return if @destroyed
    @destroyed = true
    @listener.destroy()
    @element.remove()
  update_position: ()->
    translatex = -100.0*@index + (@translation[0])
    @scale = 0.2 if @scale < 0.2
    @viewer_content.style.transformOrigin =
      "#{@scale_center[0]+100.0*@index}% #{@scale_center[1]}% 0"
    @viewer_content.style.transform =
      "translate(#{translatex}%, #{@translation[1]}%) scale(#{@scale})"
  position_relative: (touch)->
    unless @size
      rect = @element.getBoundingClientRect()
      @size = [rect.width, rect.height]
    [ touch[0] / @size[0] * 100.0, touch[1] / @size[1] * 100.0 ]
  set_index: (index, options = {})->
    @index = index + 1000 unless @index?
    @scale = 1
    @scale_center = [50, 50]
    @translation = [0, 0]
    if options.annimate? and options.annimate == true
      @element.classList.add('viewer-annimate')
    else
      @element.classList.remove('viewer-annimate')
    diff = index - @index
    changes = []
    if diff != 0
      switch diff
        when 1
          changes.push
            elem: @items[0]
            index: index + 1
          @items.push(@items.shift())
        when -1
          changes.push
            elem: @items[2]
            index: index - 1
          @items.unshift(@items.pop())
        # When 2 -2 ?
        else
          changes.push
            elem: @items[0]
            index: index - 1
          changes.push
            elem: @items[1]
            index: index
          changes.push
            elem: @items[2]
            index: index + 1
    for change in changes
      change.elem.style.zIndex = change.index == index ? 1 : 0
      change.elem.style.transform = "translate(#{change.index*100}%) scale(1)"
    @index = index
    positions = []
    for i, item of @items
      positions.push(
        elem: item,
        index: @index + @items.indexOf(item) - 1
      )
    if changes.length > 0 && @_config.change?
      @_config.change(changes, positions)
    @drag = false
    @viewer_content.style.transform = "translate(#{-@index*100}%, 0) scale(1)"
    true
  set_single_image: (@single_image)->
    if @single_image
      @items[0].style.opacity = 0
      @items[2].style.opacity = 0
    else
      @items[0].style.opacity = 1
      @items[2].style.opacity = 1
  next: ->
    @set_index(@index + 1, annimate: false)
  previous: ->
    @set_index(@index - 1, annimate: false)
export default Viewer
