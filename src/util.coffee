QuandlismContext_.utility = () ->
  
  context = @
  
  utility = () -> return


  # Truncate a word to a max 
  utility.truncate = (word, chars) =>
    if word.length > chars then "#{word.substring(0, chars)}..." else word
    
  # Create lines objects
  #
  # data - Raw data 
  #
  # Returns an array of quandlism lines
  utility.createLines = (data) =>
    keys = data.columns[1..]
    lineData = _.map keys, (key, i) =>
      _.map data.data, (d) ->
        {
          date: d[0]
          num: +d[(i+1)]
        }
        
    if not context.lines().length
      defaultColumn = utility.defaultColumn data.code
      lines = _.map keys, (key, i) =>
        context.line {name: key, values: lineData[i]}
      # Only draw the first line
      for line, i in lines
        line.visible false if i isnt defaultColumn
    else
      lines = context.lines()
      for line, i in lines
        line.values lineData[i].reverse()
      
    lines

  # Get the default column to show when the dataset is drawn
  # 
  # code - The dataset code
  #
  # Returns 0 if code is not present, or if dataset is not a futures dataset. Returns 4 otherwis
  utility.defaultColumn = (code) ->
    return 0 unless code?
    if code.match /^FUTURE_/ then return 3 else return 0
    
  # Calculates the minimum and maxium values for all of the lines in the lines array
  # between the index values start, and end
  #
  # lines - An array of quandlism.line objects
  # start - The array index to start 
  # end   - The array index to end
  #
  # Returns an array with two values
  utility.getExtent = (lines, start, end) =>
    exes = (line.extent start, end for line in lines)
    [d3.min(exes, (m) -> m[0]), d3.max(exes, (m) -> m[1])]
 
 
  # Returns the name of the month
  utility.getMonthName = (monthDigit) =>
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    months[monthDigit]
    
  # Return a color
  #
  # i - The index of a line
  # 
  # Returns a string hex code
  utility.getColor = (i) =>
    context.colorList()[i]
    
  # Formats a number with commas
  #
  # num - The number to format
  #
  # Returns a string formatted numbers
  utility.formatNumberAsString = (num) =>
    num.toString().replace /\B(?=(\d{3})+(?!\d))/g, ","

  # Get the RGB value of the pixel at position m in canvas space
  #
  # m     - The mouse position relative to the canvas
  # ctx   - The canvas drawing context
  #
  # Returns a string represneting a hex color code
  utility.getPixelRGB = (m, ctx) =>
    px = ctx.getImageData(m[0], m[1], 1, 1).data
    rgb = d3.rgb px[0], px[1], px[2]
    rgb.toString()
  
      
  # Returns the label and divisor
  #
  # extent - The largest avlue of the graph, rounded, with zero decimal places
  #
  # Returns an object with label and divisor
  utility.getUnitAndDivisor = (extent) =>
    len = extent.toString().length
    if len <= 3
      {label: '', divisor: 1}
    else if len <= 6
      {label: 'K', divisor: 1000}
    else if len <= 9
      {label: 'M', divisor: 1000000}
    else 
      {label: 'B', divisor: 1000000000}
      
  # Returns a string that can be parsed in the same format as the dates in the active graph.
  # The number of - present indicate one of two date formats available.
  # date - An example date
  #  
  # Returns a string representing the date format
  utility.dateFormat = (date) ->
    hyphenCount = date.split('-').length - 1
    switch hyphenCount
      when -1 then dateString = '%Y'
      when 2  then dateString = '%Y-%m-%d'
      else throw("Unknown date format: #{hyphenCount} #{date}")
    dateString

  # Parses the input date into a readable format for D3
  # String format is a function of the datasets frequency parameter
  #   
  # date - A date to be parsed
  #   
  # Return a time formatter
  utility.parseDate = (date) ->
    dateString = @.dateFormat date
    d3.time.format(dateString).parse;
    
  utility