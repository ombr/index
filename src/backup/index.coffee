`import css from './index.sass';`
`import $ from '../node_modules/jquery/dist/jquery';`
window.$ = $
class Viewer
  constructor: (@_config)->
    @$viewer = $(@_config.elem)
    @drag = false
    @destroyed = false
    @on_down = (e)=>
      @down(e)
    @on_up = (e)=>
      @up(e)
    @on_move = (e)=>
      @move(e)
    @$viewer.on 'touchstart mousedown', @on_down
    @$viewer.on 'touchmove mousemove', @on_move
    @$viewer.on 'touchend mouseup mouseout touchcancel', @on_up

    @$viewer_content = @$('.viewer-content')
    @$viewer_background = @$('.viewer-background')
    @width = @$viewer_content.width()

    items = @$('.viewer-container')
    @$items = [$(items[0]), $(items[1]), $(items[2])]
    # console.log @$items
    @index = 0
    @$items[0].css('left', '-100%')
    @$items[2].css('left', '100%')
    @loop_callback = =>
      @loop()
    requestAnimationFrame @loop_callback
  destroy: ->
    @$viewer.off 'touchstart mousedown', @on_down
    @$viewer.off 'touchmove mousemove', @on_move
    @$viewer.off 'touchend mouseup mouseout touchcancel', @on_up
    @destroyed = true
    @_config.destroyed(@$viewer[0]) if @_config.destroyed?
  loop: (e)->
    return if @destroyed
    if @drag
      translation = @translation()
      @$viewer_background.css(
        'opacity', Math.max(0, 1-(Math.abs(translation[1]/100)))
      )
      translatex = 100*-@index + translation[0]/@width*100
      @$viewer_content
        .css(
          'transform',
          "translate(#{translatex}%, #{translation[1]}px)"
        )
    requestAnimationFrame @loop_callback
  distance: (p)->
    Math.sqrt(p[0]*p[0]+p[1]*p[1])
  translation: ->
    if @move_position?
      @position_diff(@move_position, @down_position)
    else
      [0, 0]
  down: (e)->
    e.preventDefault()
    @$viewer.removeClass('viewer-annimate')
    @drag = true
    @last_start = Date.now()
    @down_position = @position(e)
  $: (selector)->
    if selector?
      $(selector, @$viewer)
    else
      @$viewer
  set_index: (index)->
    diff = index - @index
    # console.log diff
    changes = {}
    switch diff
      when 1
        changes[@index+2] = @$items[0]
      when -1
        changes[@index-2] = @$items[2]
      else
        changes[index-1] = @$items[0]
        changes[index] = @$items[1]
        changes[index+1] = @$items[2]
    for i, $element of changes
      $element.css('left', "#{i*100}%")
      changes[i] = $element[0]
    @index = index
    @_rotate_items(diff)
    positions = []
    for i, item of @$items
      positions[item.index()] = i
    if Object.keys(changes).length > 0 && @_config.callback?
      @_config.callback(changes, positions)
    @drag = false
    @$viewer_content.css('transform', "translate(#{-@index*100}%, 0)")
  _rotate_items: (index)->
    return if index == 0
    if index > 0
      @$items.push(@$items.shift())
      @_rotate_items(index - 1)
    else
      @$items.unshift(@$items.pop())
      @_rotate_items(index + 1)
  up: (e)->
    e.preventDefault()
    return unless @drag
    @drag = false
    translation = @translation()
    if Math.abs(translation[1]) > 100
      return @destroy()
    @$viewer.addClass('viewer-annimate')
    if Math.abs(translation[0]) > 50
      changes = {}
      if translation[0] < 0
        @set_index(@index+1)
      else
        @set_index(@index-1)
    else
      @set_index(@index)
    @move_position = null
  move: (e)->
    e.preventDefault()
    e.stopPropagation()
    @move_position = @position(e)
  position: (e)->
    if e.touches?
      return @last_position if e.touches.length == 0
      touch = e.touches[0]
      x = touch.pageX
      y = touch.pageY
    else
      x = e.pageX
      y = e.pageY
    @last_position = [x, y]
    @last_position
  position_diff: (a,b)->
    [a[0] - b[0], a[1] - b[1]]
$ ->
  i = 0
  v = new Viewer(
    elem: '.viewer'
    callback: (changes, positions)->
      for index, element of changes
        $(element).html(index)
    destroyed: (e)->
      $(e).remove()
  )
  # $('body').on 'mousemove', ->
  #   console.log 'MOUSE MOVE BODY !'
  v.set_index(30)
  # v.$items = [0, 1, 2]
  # v._rotate_items(1)
  # console.log v.$items
