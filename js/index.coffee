tools = require "kaiec-tools"
path = require "path"
consoleScrolling = true
Exif = new require('kaiec-exif').Exif
exif = new Exif("exiftool\\exiftool")
oevre = require('../js/oevre')
fs = require("fs")


_log = (text,before=0,after=0,pre=false) ->
  escape = require('escape-html')
  html = ""
  html += "<br/>" for x in [0...before]
  html += "<pre>" if pre
  html +=  escape(text)
  html += "</pre>" if pre
  html += "<br/>"
  html += "<br/>" for x in [0...after]
  $("#output").append(html)
  if consoleScrolling then $("#output").scrollTop(99999999999999)

tools.log.setWriter(_log)





_walkDirExtraction = (directory) ->
  _log("Looking for files in " + directory,after=1)
  walk    = require('walk')
  files   = []

  #  Walker options
  walker  = walk.walk(directory, { followLinks: false })
  walker.on('file', (root, stat, next) ->
    # Add this file to the list of files
    return next() if stat.name.indexOf(".jpg")==-1 and stat.name.indexOf(".JPG")==-1
    filename = stat.name.replace(".JPG","").replace(".jpg","")
    fdir = root.replace(directory,"")
    data = filename.split(",")
    imageData = oevre.extractData(data,fdir,fdir + "/" + stat.name)
    if !imageData.sane
      _log(imageData.errorMsg)
    else
      files.push(imageData)
      _writeXMP(root + "\\" + stat.name, imageData)
      _log("Updated: " + root + "\\" + stat.name)
    next()
  )
  walker.on('end', ->
    _log("Finished! " + files.length + " sane images.",1,2)

    # _log(JSON.stringify(files,null,2),0,0,true);
  )

_sortImages = (directory) ->
  _log("Looking for files in " + directory,after=1)
  walk    = require('walk')
  files   = []

  #  Walker options
  counter = 0
  walker  = walk.walk(directory, { followLinks: false })
  walker.on('file', (root, stat, next) ->
    # Add this file to the list of files
    return next() if stat.name.indexOf(".jpg")==-1 and stat.name.indexOf(".JPG")==-1
    file = root + "\\" + stat.name
    counterString = String('000'+counter).slice(-3)
    fileNew = root + "\\" + counterString + "00-" + stat.name
    _log("Renaming " + file)
    fs.renameSync(file, fileNew)
    counter++
    next()
  )
  walker.on('end', ->
    _log("Finished! ",1,2);

    # _log(JSON.stringify(files,null,2),0,0,true);
  )


_writeXMP = (file, imageData)->
  exif.setXMPTags("oevre",imageData,file)

_createPhotobook = (directory, photobook, target) ->
  Fotobook = require('kaiec-fotobook').Fotobook
  fb = new Fotobook(photobook, target)
  _log(fb.getStatistics(),0,0,true)
  _log("Looking for files in " + directory,after=1);
  walk    = require('walk')
  files   = []

  #  Walker options
  walker  = walk.walk(directory, { followLinks: false })
  walker.on('file', (root, stat, next) ->
    # Add this file to the list of files
    return next() if stat.name.indexOf(".jpg")==-1 and stat.name.indexOf(".JPG")==-1

    fb.insertImage(root + path.sep +  stat.name)

    next()
  )
  walker.on('end', ->
    fb.ready(-> _log("Finished. New book saved to " + target))
  )




#
# Main interface setup
#

$ ->
  try
    process.on("uncaughtException", (err) ->
      _log(err)
    )
    $(".section").each(->
      $(this).prepend('<div class="secTools"/><div class="secLabel">' + $(this).attr("title") + '</div><div class="clear"/>')
    )
    $("#workspace").append('<p>1. Input: Oevre/Sorted Images (NEVER YOUR ORIGINAL OEVRE!): <span id="oevreDir">'+ localStorage.oevreDir + '</span></p>')
    $("#workspace").append('<p>2. Input: Template: <span id="photobook">'+ localStorage.photobook + '</span></p>')
    $("#workspace").append('<p>------------------------------------------------------------------------------------------------------------------------------------------------</p>')
    $("#workspace").append('<p>Target: <span id="target">'+ localStorage.target + '</span></p>')
    $("#oevreDir").on("click",-> tools.chooseDirectory( (dir) ->
      localStorage.oevreDir = dir
      $("#oevreDir").html(dir)
    ))
    $("#photobook").on("click",-> tools.chooseFile( (file) ->
      localStorage.photobook = file
      $("#photobook").html(file)
    ))
    $("#target").on("click",-> tools.chooseFileSave( (file) ->
      localStorage.target = file
      $("#target").html(file)
    ))
    $("#toolbar").append('<button id="extractData">Filename -> Data</button>')
    $("#extractData").on("click",-> _walkDirExtraction(localStorage.oevreDir) if localStorage.oevreDir != undefined )
    $("#toolbar").append('<button id="sortImages">Sort Images</button>')
    $("#sortImages").on("click",-> _sortImages(localStorage.oevreDir) if localStorage.oevreDir != undefined )
    $("#toolbar").append('<button id="createPhotobook">Create Photobook</button>')
    $("#createPhotobook").on("click",-> _createPhotobook(localStorage.oevreDir, localStorage.photobook, localStorage.target))
    $("#console .secTools").append('<span id="toggleOutput">Hide</span> | <span id="clearOutput">Clear</span> | <span id="toggleScrolling">Scrolling Off</span>')
    $("#console").append('<pre id="output"></pre>')
    $("#clearOutput").on("click",-> $("#output").html(""))
    $("#toggleOutput").on("click",->
      if $("#output").is(":visible")
        $("#output").fadeOut()
        $("#toggleOutput").html("Show")
      else
        $("#output").fadeIn()
        $("#toggleOutput").html("Hide")
    )
    $("#toggleScrolling").on("click",->
      if consoleScrolling
        consoleScrolling = false
        $("#toggleScrolling").html("Scrolling On")
      else
        consoleScrolling = true
        $("#toggleScrolling").html("Scrolling Off")
    )
  catch error
    _log(error)

