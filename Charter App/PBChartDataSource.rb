#
#  PBChartDataSource.rb
#  Testing
#
#  Created by Paolo Bosetti on 8/11/11.
#  Copyright 2011 Dipartimento di Ingegneria Meccanica e Strutturale. All rights reserved.
#

class AlignmentError < RuntimeError
  
end

class PBChartDataSource
  TYPES = {s:0, m:1}
  attr_reader :data, :type, :numberOfSeries
  
  def initialize
    reset
  end
  
  def reset
    @data = NSMutableArray.new
    @type = :undefined # :s => single x col, :m => one x col per each y
    @numberOfSeries = 1
  end
  
  def chartType
    TYPES[type]
  end
  
  def addRecordFromString(aString)
    schemeChanged = false
    result = :OK
    tokens = aString.split
    type = tokens[0].downcase.to_sym
    result = :reload if @data.empty?
    if type != @type
      reset
      result = :reload
    end

    @type = type

    case type
    when :s
      @type = :s
      @data << tokens[1..-1].map {|e| e.to_f}
      @numberOfSeries = @data[0].count - 1
      schemeChanged = true if @numberOfSeries != tokens.size - 2
    when :m
      @type = :m
      record = NSMutableArray.new
      tokens[1..-1].each {|c| record << c.split(',').map {|e| e.to_f}}
      @data << record
      @numberOfSeries = @data[0].count
      schemeChanged = true if @numberOfSeries != tokens.size - 1
    else
      raise RuntimeError, "Unexpected data alignment: #{tokens[0]}"
    end
    if schemeChanged
      print "scheme changed "
      reset
      addRecordFromString(aString)
      result = :reload
    end
    #puts "data: #{@data}, type: #{@type}, result: #{result}"
    return result
  end
  
  # table view datasource/delegate
  
  def numberOfRowsInTableView(table)
    @data.size
  end
  
  def tableView(table, objectValueForTableColumn:column, row:row)
    case @type
    when :m
      @data[row].flatten[column.identifier.to_i]
    when :s
      @data[row][column.identifier.to_i]
    end
  end
  
  def tableView(table, setObjectValue:object, forTableColumn:column, row:row)
    @data[row][column.identifier.to_i] = object.to_f
  end
  
  def tableViewSelectionDidChange(notification)  
  end
  
  #pragma mark -
  #pragma mark Plot Data Source Methods
  
  def numberOfRecordsForPlot(plot)
    return @data.size
  end
  
  def numberForPlot(plot, field:fieldEnum, recordIndex:index)
    num = 0
    case @type
      when :m
      serie = plot.identifier.integerValue - 1
      num = fieldEnum == 0 ? @data[index][serie][0] : @data[index][serie][1]
      when :s
      serie = plot.identifier.integerValue
      num = fieldEnum == 0 ? @data[index][0] : @data[index][serie]
    end
    return num
  end

end