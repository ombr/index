class Listener
  constructor: (@element, @viewer)->
    @sizes = [ @element.clientWidth * 1.0, @element.clientHeight * 1.0 ]
    @on_down = (e)=>
      @send('down', e)
    @on_up = (e)=>
      @send('up', e) unless @event_in_scope(e)
    @on_move = (e)=>
      @send('move', e)
    @add_listener 'touchstart mousedown', @on_down
    @add_listener 'touchmove mousemove', @on_move
    @add_listener 'touchend mouseup mouseout touchcancel', @on_up
  destroy: ->
    @remove_listener 'touchstart mousedown', @on_down
    @remove_listener 'touchmove mousemove', @on_move
    @remove_listener 'touchend mouseup mouseout touchcancel', @on_up
  add_listener: (events, callback)->
    for event in events.split(' ')
      @element.addEventListener event, callback
  remove_listener: (events, callback)->
    for event in events.split(' ')
      @element.addEventListener event, callback
  event_in_scope: (event)->
    e = event.relatedTarget
    return false if event.relatedTarget == null
    while e
      return true if e == @element
      e = e.parentElement
    false
  send: (type, event)->
    event.preventDefault()
    event.stopPropagation()
    touches = @extract_touches(event)
    @viewer[type](touches)
  extract_touches: (e)->
    touches = []
    if e.touches?
      return @_touch_cache if e.touches.length == 0
      touches = []
      for i in [0...e.touches.length]
        touch = e.touches[i]
        touches.push([touch.pageX, touch.pageY])
    else
      touches.push([e.pageX, e.pageY])
    for touch, i in touches
      touches[i] = [touch[0] / @sizes[0] * 100.0, touch[1] / @sizes[1] * 100.0]
    touches.push([45, 45]) if e.shiftKey
    touches
    @_touch_cache = touches
    @_touch_cache
export default Listener
