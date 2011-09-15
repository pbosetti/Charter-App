#
#  PBChartSeries,rb.rb
#  Testing
#
#  Created by Paolo Bosetti on 8/6/11.
#  Copyright 2011 Dipartimento di Ingegneria Meccanica e Strutturale. All rights reserved.
#
framework "Cocoa"


class PBChartSeries
  attr_accessor :name, :color, :thickness, :symbol, :symbolSize, :enabled
  attr_accessor :data
  
  def PBChartSeries.resetCounter(n=0)
    @@count = n
  end
  
  @@count = 0
  COLOR_SET = 6
  
  def isEnabled
    @enabled ? 1 : 0
  end
  
  def initialize(name=nil)
    @name = (name || "Series #{@@count += 1}")
    @id = @@count
    @thickness = 1.0
    @symbol = "No Symbol"
    @symbolSize = 10.0
    @color = colorCycle(@@count)
    @enabled = true
  end
  
  def id
    @id.to_s
  end
  
  def colorCycle(i)
    i = (i % COLOR_SET) - 1
    hue = 1.0 / COLOR_SET * i
    NSColor.colorWithCalibratedHue hue, saturation:1.0, brightness:(i == 0 ? 0.66 : 0.66), alpha:1.0
  end

end