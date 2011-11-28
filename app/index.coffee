require('lib/setup')

ParallelCoordinates = require('controllers/parallelCoordinates')
Lists = require('controllers/lists')
Spine = require('spine')
CsvJson = require('lib/csvjson')
Point = require('models/point')

class App extends Spine.Controller

  constructor: ->
    super
    if !(window.File and window.FileReader and window.FileList and window.Blob)
      alert 'The File APIs are not fully supported in this browser.'

    @html require('views/upload')

    dropZone = document.getElementById('drop_zone');
    dropZone.addEventListener('dragover', @handleDragOver, false);
    dropZone.addEventListener('drop', @handleFileSelect, false);

  handleDragOver: (e) ->
    e.stopPropagation();
    e.preventDefault();
    e.dataTransfer.dropEffect = 'copy';

  handleFileSelect: (e) =>
    e.stopPropagation();
    e.preventDefault();

    file = e.dataTransfer.files[0];

    reader = new FileReader();

    reader.onload = (e) =>
      @initData(e.target.result)
      

    reader.readAsText(file);

  initData: (fileData) =>

    data = CsvJson.csv2json fileData,
      delim: ";" 
      textdelim: "\""


    attributes = data.headers.slice(0)
    attributes.unshift('Point')

    Point.configure.apply(Point, attributes)
    Point.refresh(data.rows)
    #@log(Point.records)


    pc = new ParallelCoordinates(width: @el.width(), height: 400, columns: data.headers)
    @html pc
    list = new Lists(columns: data.headers)
    @append list

module.exports = App
    
