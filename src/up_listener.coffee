import Referentiel from 'referentiel'
class UpListener
  constructor: (@element, @options)->
    @_listener = (e)=> @up(e)
    @destroyed = false
    @element.addEventListener 'touchend', @_listener
    @element.addEventListener 'touchcancel', @_listener
    @element.addEventListener 'mouseout', @_listener
    @element.addEventListener 'mouseup', @_listener
  up: (e)->
    return if @destroyed
    referentiel = new Referentiel(@element)
    touches = []
    if e.touches?
      for i in [0...e.touches.length]
        touch = e.touches[i]
        touches.push(referentiel.global_to_local([touch.pageX, touch.pageY]))
    else
      touches.push(referentiel.global_to_local([e.pageX, e.pageY]))
    @options.up(touches, e) unless @event_in_scope(e)
  destroy: ->
    return if @destroyed
    @destroyed = true
    @element.removeEventListener 'touchend', @_listener
    @element.removeEventListener 'touchcancel', @_listener
    @element.removeEventListener 'mouseout', @_listener
    @element.removeEventListener 'mouseup', @_listener
  event_in_scope: (event)->
    e = event.relatedTarget
    return false if event.relatedTarget == null
    while e
      return true if e == @element
      e = e.parentNode
    false
export default UpListener
