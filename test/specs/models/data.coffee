describe 'Data', ->
  Data = null
  
  beforeEach ->
    class Data extends Spine.Model
      @configure 'Data'
  
  it 'can noop', ->
    