describe 'Filtered', ->
  Filtered = null
  
  beforeEach ->
    class Filtered extends Spine.Model
      @configure 'Filtered'
  
  it 'can noop', ->
    