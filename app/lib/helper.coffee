Spine = require('spine')

class Helper 
  @getPos: (el, e) ->
    parentOffset = $(el).offset()
    x: e.pageX - parentOffset.left
    y: e.pageY - parentOffset.top

  @getColumnRange: (top, bottom, parentHeight, gutter, column, range) ->
    height = bottom - top
    step = (range.max - range.min) / (parentHeight - gutter.y * 2)
    column: column
    max: range.max - (top * step)
    min: range.max - (bottom * step)
    top: top
    bottom: bottom
    height: height
module.exports = Helper

