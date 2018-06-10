class DownListener
  constructor: (@element, @options)->
    @_listener = (e)=> @down(e)
    @destroyed = false
    @element.addEventListener 'touchstart', @_listener
    @element.addEventListener 'mousedown', @_listener
  down: (e)->
    return if @destroyed
    @options.down(e)
  destroy: ->
    return if @destroyed
    @destroyed = true
    @element.removeEventListener 'mousedown', @_listener
    @element.removeEventListener 'touchstart', @_listener
export default DownListener
