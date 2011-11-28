


describe 'Filter', ->
  Filter = null
  
  beforeEach ->
    class Filter extends Spine.Model
      @configure 'Filter'
  
  it 'can noop', ->

    filter= new Filter(first_name: "Alex", last_name: "MacCaw")
    assertEqual( filter.fullName(), "Alex MacCaw" ) 
