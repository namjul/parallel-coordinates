Spine = require('spine')
Point = require('models/point')
Axis = require('controllers/axis')
Helper = require('lib/helper')

class ParallelCoordinates extends Spine.Controller

  events:
    'mousedown .selection': 'activate'
    'mousemove .selection': 'mousemove'
    'mouseup .selection': 'deactivate'

  elements: 
    ".axis": "axis"
    "canvas.coordinates": "coordinates"
    "canvas.selection": "selection"

  constructor: ->
    super

    # Bug: jquery ui stops dragging of no bind for trigger is there, i need it anyway :)
    Point.bind('change:filter', @update)

    #defaults
    @gutter = @gutter || x: 20, y:50

    @active = false

    @render()
   
  className: "parallelCoordinates"

  render: ->
    @html require('views/canvas')(@)
    @ctx = @coordinates[0].getContext('2d')
    @ctxSel = @selection[0].getContext('2d')
    @space = (@width-@gutter.x * 2)/(@columns.length-1);

    #calulate ranges
    @range = {}
    data = Point.select -> true
    for col in @columns
      min = _(data).chain().pluck(col).min().value()
      max = _(data).chain().pluck(col).max().value()
      @range[col] = 
        min: min
        max: max
        size: max-min

    @drawColumns()
    @update()

  drawColumns: ->
    @axis.remove()
    @axes = {}

    for col,i in @columns
    	axis = @axes[col] = new Axis('name': col, 'range': @range[col], 'gutter': @gutter, 'height': @height, 'x': @gutter.x + @space*i)
    	axis.el.css('left', @gutter.x + (@space*i)-20 + 'px')
    	axis.bind('selected', @switchColumns)
    	@append axis

  update: =>
    line_stroke = @lineStroke || "hsla(0,00%,20%,50%)";
    dataFiltered = Point.filtered()
    data = Point.all()
    @ctx.clearRect(0, 0, @width, @height);

    #draw dots
    for col in @columns
    	@axes[col].ctx.clearRect(0,0,40,@height)
    	@axes[col].ctx.fillStyle = 'rgba(50,50,50,0.2)'
    for point in data
    	for col in @columns
    		y = @hPositionWithoutGutter @height, point, col
    		@axes[col].ctx.fillRect(19,y,2,2)

    ##draw lines
    if line_stroke
      @ctx.strokeStyle = "hsl(23,39%,50%)"
      @ctx.lineWidth = 0.5
    for point in dataFiltered
    	@ctx.beginPath()
    	for col, j in @columns
    		x = @space*j + @gutter.x
    		y = @hPosition @height, point, col
    		if j == 0 then @ctx.moveTo(x,y)    		
    		else @ctx.lineTo(x,y)
    	@ctx.stroke()

    return null

  hPosition: (height, point, col) ->
    if @range[col].size == 0 then @gutter.y + (height-(2*@gutter.y))/2
    else @gutter.y + (height-(2*@gutter.y)) * ((@range[col].max - point[col]) / @range[col].size)

  hPositionWithoutGutter: (height, point, col) ->
    if @range[col].size == 0 then height/2
    else height * ((@range[col].max - point[col]) / @range[col].size)

  switchColumns: (column) =>
    @colsToSwitch = @colsToSwitch || []
    if @colsToSwitch.indexOf(column) != -1 
    	@colsToSwitch.splice(0,1)
    	return
    @colsToSwitch.push(column)
    if @colsToSwitch.length >= 2
    	idx1 = @columns.indexOf(@colsToSwitch[0])
    	idx2 = @columns.indexOf(@colsToSwitch[1])
    	temp = @columns[idx1]
    	@columns[idx1] = @columns[idx2]
    	@columns[idx2] = temp
    	@axis.find('.axis-wrapper').fadeOut(200, -> $(@).removeClass('selected'); $(@).show())
    	@drawColumns()
    	@update()
    	Spine.trigger 'columns:update', @columns
    	@colsToSwitch = []
    	for col, i of @axes
    		@axes[col].updateFilter()

    #@Log doesnt work here
    #conjsole.log(@colsToSwitch)

  activate: (e) ->
    @active = true
    @startDrag = Helper.getPos(@selection, e)
    @selection.addClass('active')

  mousemove: (e) ->
    if @active
    	pos = Helper.getPos(@selection, e)
    	start = @startDrag
    	@ctxSel.clearRect(0, 0, @width, @height)
    	@ctxSel.fillStyle = "rgba(229,205,92,0.2)"
    	@ctxSel.fillRect(start.x, start.y, pos.x-start.x, pos.y-start.y)

    	for axis of @axes
    		max = {}
    		min = {}
    		if pos.x > start.x
          min.x = start.x
          max.x = pos.x
        else
          min.x = pos.x
          max.x = start.x
          
        if pos.y > start.y
          min.y = start.y
          max.y = pos.y
        else
          min.y = pos.y
          max.y = start.y

        if (@axes[axis].x > min.x) and (@axes[axis].x < max.x) 
          range = Helper.getColumnRange(min.y - @gutter.y, max.y - @gutter.y, @height, @gutter, axis, @axes[axis].range)
          @axes[axis].addFilter(range)
         
  
  deactivate: (e) ->
    @active = false 
    @startDrag = null
    @ctxSel.clearRect(0, 0, @width, @height)
    @selection.removeClass('active')


    
module.exports = ParallelCoordinates
