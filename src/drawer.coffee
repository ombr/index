import DrawerListener from './drawer_listener.coffee'

class Drawer
  constructor: (@_config)->
    @listener = new Listener(@_config.elem, this)
    @element = @_config.elem

  destroy: ->
    return if @destroyed
    @destroyed = true
    @listener.destroy()
    @element.remove()
  tick: (e)->
    return if @destroyed
    if @drag
      translation = Geomtery.translation(@touches, @last_touches)
      @scale += Geomtery.scale(@touches, @last_touches)
      @translation = [
        @translation[0] - (translation[0]/@scale),
        @translation[1] - (translation[1]/@scale)
      ]
      @update_position()
      @viewer_background.style.opacity =
        Math.max(0, 1-(Math.abs(@translation[1]/100.0)))
    @last_touches = @touches
    requestAnimationFrame @loop_callback
  update_position: ()->
    translatex = -100.0*@index + (@translation[0])
    @viewer_content.style.transform =
      "scale(#{@scale}) translate(#{translatex}%, #{@translation[1]}%)"
  down: (@touches)->
    if @touches.length == 1
      @last_touches = @touches
      @drawing = true
  move: (@touches)->
  up: (@touches)->
    return unless @drawing
    @drag = false
    if @scale < 0.1 # Destroy via scale
      return @destroy()
    if @scale <= 1.1 # Mode transition classiques
      if Math.abs(@translation[1]) > 60
        return @destroy()

      if Math.abs(@translation[0]) > 20
        if @translation[0] < 0
          return @set_index(@index+1)
        else
          return @set_index(@index-1)
      return @set_index(@index)
    if @scale > 1.1
      ref = 50.0 * (1 - (1.0 / @scale))
      if @translation[1] >= ref
        @translation[1] = ref
      if @translation[0] >= ref
        @translation[0] = ref
      if @translation[0] <= -ref
        @translation[0] = -ref
      if @translation[1] <= -ref
        @translation[1] = -ref
      @element.classList.add('viewer-annimate')
      @update_position()
    @viewer_background.style.opacity = 1
  set_index: (index)->
    @scale = 1
    @translation = [0, 0]
    @element.classList.add('viewer-annimate')
    diff = index - @index
    changes = []
    if diff != 0
      switch diff
        when 1
          changes.push
            elem: @items[0]
            index: @index + 2
        when -1
          changes.push
            elem: @items[2]
            index: @index - 2
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
      change.elem.style.transform = "translate(#{change.index*100}%)"
    @index = index
    @_rotate_items(diff)
    positions = []
    for i, item of @items
      positions.push(
        elem: item,
        index: @index + @items.indexOf(item) - 1
      )
    if Object.keys(changes).length > 0 && @_config.callback?
      @_config.callback(changes, positions)
    @drag = false
    @viewer_content.style.transform = "translate(#{-@index*100}%, 0)"
    true
  _rotate_items: (index)->
    return if index == 0
    @items[1].style.zIndex = 0
    if index > 0
      @items.push(@items.shift())
      @_rotate_items(index - 1)
    else
      @items.unshift(@items.pop())
      @_rotate_items(index + 1)
    @items[1].style.zIndex = 1
  next: ->
    @set_index(@index + 1)
  previous: ->
    @set_index(@index - 1)

export default Drawer
