module.exports.extractData = (data,directory,origin) ->
  imageData = {}
  directory = directory.substr(1) if directory.indexOf("/")==0
  categories = directory.split("/")
  imageData.Category = categories
  imageData.sane = true
  imageData.File = origin.trim()
  if data.length==4
    imageData.Year = data[0].trim()
    imageData.Title = data[1].trim()
    imageData.Technique = data[2].trim()
    formatImageNr = data[3].split("-")
    imageData.Format = formatImageNr[0].trim()
    imageData.ImgNr = if formatImageNr[1] != undefined
      formatImageNr[1].trim()
    else
      undefined
    if imageData.Format.indexOf("x")==-1
      imageData.errorMsg ="Suspicious format: " + origin
      imageData.sane = false
    if imageData.Year==-1
      imageData.errorMsg ="Suspicious format: " + origin
      imageData.sane = false
  else if data.length>4
    imageData.errorMsg ="More than 4 elements: " + origin
    imageData.sane = false
  else
    imageData.errorMsg = "Extraction incomplete: " + origin
    imageData.sane = false
  return imageData