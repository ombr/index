import Referentiel from 'referentiel'
class MoveListener
  constructor: (@element, @options)->
    @destroyed = false
    @_referentiel = new Referentiel(@element)
    @_move = (e)=>
      return if @destroyed
      e.preventDefault()
      e.stopPropagation()
      @shift = e.shiftKey
      @_touches = []
      if e.touches?
        for i in [0...e.touches.length]
          touch = e.touches[i]
          @_touches.push([touch.pageX, touch.pageY])
      else
        @_touches.push([e.pageX, e.pageY])
    @element.addEventListener 'touchmove', @_move
    @element.addEventListener 'mousemove', @_move
    @loop_callback = =>
      @tick()
    requestAnimationFrame @loop_callback
  tick: ->
    return if @destroyed
    touches = []
    if @_touches?
      for touch in @_touches
        touches.push(@_referentiel.global_to_local(touch))
    if @first_touches? && @shift
      console.log 'Add', @first_touches
      touches.push([@first_touches[0][0] - 30, @first_touches[0][1] - 30])
    if touches.length > 0 and not @first_touches?
      @first_touches = touches
    if touches.length > 0
      console.log 'move', touches[0]...
      @options.move(touches)
    requestAnimationFrame @loop_callback
  destroy: ->
    return if @destroyed
    @destroyed = true
    @element.removeEventListener 'touchmove', @_move
    @element.removeEventListener 'mousemove', @_move
export default MoveListener
