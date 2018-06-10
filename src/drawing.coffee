import DownListener from './down_listener.coffee'
import DrawingUtils from './drawing_utils.coffee'
import DrawingPathTool from './drawing_path_tool.coffee'
import DrawingTransform from './drawing_transform.coffee'
class Drawing
  constructor: (@svg, @options = {})->
    @_init()
    @options.color ||= '#FF0000'
    @options.tool ||= 'path'
  _init: ->
    @_down = new DownListener(@svg, down: => @down(arguments...))
    DrawingUtils.style(@svg, 'cursor', 'crosshair')
  down: (e)->
    # e.preventDefault()
    # e.stopPropagation()
    return if @_tool
    @select(null) if @selected?
    switch @options.tool
      when 'arrow'
        @_drawing_object(DrawingArrow, e)
      when 'double-arrow'
        @_drawing_object(DrawingDoubleArrow, e)
      when 'line'
        @_drawing_object(DrawingLine, e)
      when 'circle'
        @_drawing_object(DrawingCircle, e)
      when 'rect'
        @_drawing_object(DrawingRect, e)
      else
        @_tool = new DrawingPathTool(
          @svg,
          {
            color: @options.color
            size: @options.size
            end: (element)=>
              @_tool = null
              @_new_callback(element)
            cancel: =>
              @_tool = null
              @select(e.target)
          }
        )
  _drawing_object: (object_class, e)->
    @_tool = new DrawingObjectTool(
      @svg,
      {
        color: @options.color
        size: @options.size
        prompt_text: @options.prompt_text
        object_class: object_class
        end:(element) =>
          @_tool = null
          @_new_callback(element)
        cancel: =>
          @_tool = null
          @select(e.target)
      }
    )
  select: (element)->
    unless element?
      @_transform.destroy() if @_transform?
      @selected = null
      @_select_callback()
      return false
    return false if element == @svg
    return @select(element.parentNode) if element.parentNode != @svg
    if @selected != element
      @_transform.destroy() if @_transform?
      @selected = element
      @_select_callback()
      type = element.getAttribute('data-sharinpix-type')
      switch type
        when 'text' then @_transform = @transform(@selected)
        when 'sticker' then @_transform = @transform(@selected)
        when 'path' then @_transform = @transform(@selected)
        when 'rect' then @_transform = @transform(@selected)
        when 'arrow' then @_transform = @transform(@selected)
        when 'double-arrow' then @_transform = @transform(@selected)
        when 'line' then @_transform = @transform(@selected)
        when 'circle' then @_transform = @transform(@selected)
        else
          @_transform = new DrawingSelect(@selected)
      return true
    else
      @select(null)
  _select_callback: ->
    @options.selected(@selected) if @options.selected?
  _new_callback: (element)->
    @options.new(element) if @options.new?
  transform: (element)->
    new DrawingTransform(element, {
      click: =>
        if element.children[0].nodeName == 'text'
          if @options.prompt_text
            text_element = element.children[0]
            if text_element.children.length > 0
              parts = []
              for child in text_element.children
                parts.push(child.innerText || child.textContent)
              text = parts.join("\n")
            else
              text = text_element.innerText || text_element.textContent
            @options.prompt_text(text, (input)=>
              DrawingUtils.edit_text(element.children[0], input) if input != ''
              @select(null)
              @select(element)
            )
      end: ->
      cancel: ->
    })
  setSize: (size)->
    @options.size = size
  setTool: (tool)->
    @options.tool = tool
  setColor: (color)->
    @options.color = color
    return unless @selected?
    element = @selected.firstChild
    return unless element?
    DrawingUtils.style(@selected, 'fill', color)
    DrawingUtils.style(@selected, 'stroke', color)
    return
  delete: ->
    @selectLast() unless @selected?
    return unless @selected?
    element = @selected
    @select(null)
    element.parentNode.removeChild(element)
    @selectLast()
  selectLast: ->
    @select(@svg.lastChild) if @svg.lastChild?
  rotation_matrix: ->
    referentiel = new Referentiel(@svg)
    matrix =  referentiel.matrix()
    angle = -Math.atan2(-matrix[0][1], matrix[1][1])
    [
      [Math.cos(angle),-Math.sin(angle), 0],
      [Math.sin(angle),Math.cos(angle), 0],
      [0,0,1]
    ]
  addText: (input)->
    size = Math.round(DrawingUtils.size(@svg) * 0.05)
    referentiel = new Referentiel(@svg)
    center = referentiel.global_to_local([window.innerWidth/2, window.innerHeight/2])
    group = DrawingUtils.create_element(@svg, 'g')
    group.setAttribute('data-sharinpix-type', 'text')
    text = DrawingUtils.create_element(
      group,
      'text',
      {
        fill: @options.color,
        'font-size': size,
        'font-family': 'sans-serif'
      }
    )
    DrawingUtils.edit_text(text, input)
    DrawingUtils.apply_matrix(
      group,
      referentiel._multiply(
        [
          [1,0, center[0]],
          [0,1, center[1]],
          [0,0,1]
        ],
        @rotation_matrix()
      )
    )
    @_new_callback(group)
    @select(text)
  export: (options, callback)->
    selected = @selected
    @destroy()
    node = @svg.cloneNode(true)
    node.setAttribute('width', options.width) if options.width
    node.setAttribute('height', options.height) if options.height
    svg = node.outerHTML
    @svg.parentNode.parentNode.appendChild(node)
    node.parentNode.removeChild(node)
    callback(svg)
    @_init()
    @select(selected) if selected
  addImage: (dataUrl, options)->
    dataImg = new window.Image
    dataImg.src = image
    width = options.width || 100
    height = options.height || 100
    group = DrawingUtils.create_element(@svg, 'g')
    group.setAttribute('data-sharinpix-type', 'sticker')
    group.setAttribute('data-sharinpix-sticker-id', options.id) if options.id
    image = DrawingUtils.create_element(
      group,
      'image',
      {
        x: '0'
        y: '0'
        width: width
        height: height
      }
    )
    image.setAttributeNS("http://www.w3.org/1999/xlink", 'xlink:href', dataUrl)
    referentiel = new Referentiel(@svg)
    center = referentiel.global_to_local([window.innerWidth/2, window.innerHeight/2])
    scale = (DrawingUtils.size(@svg) / 8) / width
    DrawingUtils.apply_matrix(
      group,
      referentiel._multiply(
        [
          [scale, 0, center[0]],
          [0, scale, center[1]],
          [0, 0, 1]

        ],
        @rotation_matrix(),
        [
          [1, 0, - width/2],
          [0, 1, - height/2],
          [0, 0, 1]

        ]
      )
    )
    @_new_callback(group)
    @select(group)
  destroy: ->
    @select(null) if @selected
    DrawingUtils.style(@svg, 'cursor', 'auto')
    @_transform.destroy() if @_transform
    @_down.destroy()
export default Drawing
