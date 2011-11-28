Spine = require('spine')
Point = require('models/point')
Async = require('lib/async')

class Lists extends Spine.Controller
  constructor: ->
    super
    Point.bind 'change:filter', @update
    Spine.bind 'columns:update', @render
    @render()

  className: 'table-wrapper'

  render: (columns) =>
    @columns = columns || @columns
    @el.html(require('views/list')(@))
    $('#template').html(require('views/listItem')(@))
    
    #List should start after the views are added to the DOM
    setTimeout(@startList, 100);

  startList: =>
    points = Point.all()
    self = @
    data = _.map points, (point) ->
      p = {}
      for col in self.columns
      	p[col.toLowerCase()] = point[col]
      	p['id'] = point['id']
      return p

    @dataList = new List('data-list', item: 'data-item', data)
    @update


  update: =>
    filteredIds = Point.filteredIds()
  
    @dataList.filter (point) ->
      if filteredIds.indexOf(point.id) != -1 then return true
      else return false
      

          
module.exports = Lists
