Spine = require('spine')
Point = require('models/point')
Helper = require('lib/helper')

class Axis extends Spine.Controller

  events:
    'mousedown .axis-data': 'activate'
    'mousemove .axis-data': 'mousemove'
    'mouseup .axis-data': 'deactivate'
    'mouseleave .axis-data': 'deactivate'
    'dblclick .axis-filter': 'removeFilter'
    'click .axis-data': 'select'

  elements: 
    '.axis-wrapper': 'axis'
    '.axis-data': 'data'
    '.axis-filter': 'filter'

  constructor: ->
    super

    #no activity at the beginning
    @active = false
    @render()

    self = @

    @filter.draggable(
      containment: @axis
      axis: 'y'
      drag: (e, ui) ->
        range = Helper.getColumnRange($(ui).get(0).position.top, $(ui).get(0).position.top + $(@).height(), self.height, self.gutter, self.name, self.range)
        self.addFilter(range)
      stop: (e, ui) ->
        range = Helper.getColumnRange($(ui).get(0).position.top, $(ui).get(0).position.top + $(@).height(), self.height, self.gutter, self.name, self.range)
        self.addFilter(range)
    )

  className: "axis"

  render: ->
    @html require('views/axis')(@)
    @axis.css('top': @gutter.y + 'px', 'height': @height-2*@gutter.y + 'px' )
    @ctx = @data[0].getContext('2d')

  activate: (e) ->
    @active = true
    @startDrag = Helper.getPos(@axis, e)

  mousemove: (e) -> 
    if @active 
    	pos = Helper.getPos(@axis, e).y
    	start = @startDrag.y
    	if pos > start
        top = start
        bottom = pos
      else
        top = pos
        bottom = start
      range = Helper.getColumnRange(top, bottom, @height, @gutter, @name, @range)
    	@addFilter(range)

  deactivate: ->
    @active = false 
    @startDrag = false

  addFilter: (range) ->
    if range.top >= 0 and (range.top + range.height) < @data.height()
      @filter.css('height': range.height, 'top': range.top).addClass('active')
      Point.addFilter(range)

  removeFilter: ->
    @filter.css('height': '0', 'top': '0').removeClass('active')
    Point.removeFilter(@name)

  updateFilter: ->
    filter = Point.getFilter(@name)
    if filter
      @filter.css('height': filter.height, 'top': filter.top).addClass('active')

  select: ->
    if @axis.hasClass('selected') then @axis.removeClass('selected')
    else @axis.addClass('selected')
    @trigger 'selected', @name

  getColumnRange: (top, bottom) ->
    height = bottom - top
    step = (@range.max - @range.min) / (@height - @gutter.y * 2)
    column: @name
    max: @range.max - (top * step)
    min: @range.max - (bottom * step)
    top: top
    bottom: bottom
    height: height
    
module.exports = Axis
