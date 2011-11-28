Spine = require('spine')

class Point extends Spine.Model
  @configure 'Point'

  @filter = {}

  @addFilter = (filter) ->
    @filter[filter.column] = filter
    @trigger 'change:filter'

  @removeFilter = (filter) ->
    delete @filter[filter]
    @trigger 'change:filter'

  @getFilter = (column) ->
    @filter[column]

  @filtered = ->
    return @all() unless @isEmpty(@filter) isnt true
    filtered = @select (point) =>
      return @check point
    return filtered

  @check = (point) ->
    for column, f of @filter
    	if point[f.column] > f.max or point[f.column] < f.min then return false
    return true

  @isEmpty = (filter) ->
    for f of filter
      if filter.hasOwnProperty f
        return false
    return true

  @filteredIds = ->
    _.map @filtered(), (point) ->
      point['id']


module.exports = Point 
