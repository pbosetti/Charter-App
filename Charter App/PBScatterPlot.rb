#
#  PBScatterPlot.rb
#  Charter
#
#  Created by Paolo Bosetti on 9/9/11.
#  Copyright 2011 Dipartimento di Ingegneria Meccanica e Strutturale. All rights reserved.
#

class PBScatterPlot < PBPlotItem
  
  def PBScatterPlot.load
    super self
  end

  def init
    title = "Simple Scatter Plot"
    return self
  end

  def killGraph
    if graphs.count then
      graph = graphs.objectAtIndex 0
    
      if symbolTextAnnotation then
        graph.plotAreaFrame.plotArea removeAnnotation symbolTextAnnotation
        symbolTextAnnotation.release
        symbolTextAnnotation = nil;
      end
    end
    super
  end

  def generateData
    if plotData == nil then
      contentArray = []
      10.times do |i|
        x = 1.0 + i * 0.05
        y = 1.2 * rand + 0.5
        contentArray << {"x" => x, "y" => y}
      end
      plotData = contentArray
    end
  end

  def renderInLayer(layerHostingView, withTheme:theme)
    bounds = NSRectToCGRect(layerHostingView.bounds)
  
    graph = CPXYGraph.alloc.initWithFrame(layerHostingView.bounds).autorelease
    self.addGraph(graph, toHostingView:layerHostingView)
    self.applyTheme(theme, toGraph:graph, withDefault:CPTheme.themeNamed("None"))
  
    self.setTitleDefaultsForGraph(graph, withBounds:bounds)
    self.setPaddingDefaultsForGraph(graph, withBounds:bounds)
    graph.paddingLeft   = 5.0
    graph.paddingTop    = 5.0
    graph.paddingRight  = 5.0
    graph.paddingBottom = 5.0  
  
    # Setup scatter plot space
    plotSpace = graph.defaultPlotSpace
    plotSpace.allowsUserInteraction = true
    plotSpace.delegate = self
  
    # Grid line styles
    majorGridLineStyle = CPMutableLineStyle.lineStyle
    majorGridLineStyle.lineWidth = 0.75
    majorGridLineStyle.lineColor = CPColor.colorWithGenericGray(0.2, colorWithAlphaComponent:0.75)
  
    minorGridLineStyle = CPMutableLineStyle.lineStyle
    minorGridLineStyle.lineWidth = 0.25
    minorGridLineStyle.lineColor = CPColor.whiteColor.colorWithAlphaComponent(0.1)    
  
    redLineStyle = CPMutableLineStyle.lineStyle
    redLineStyle.lineWidth = 10.0
    redLineStyle.lineColor = CPColor.redColor.colorWithAlphaComponent(0.5)
  
    # Axes
    # Label x axis with a fixed interval policy
    axisSet = graph.axisSet
    x = axisSet.xAxis
    x.majorIntervalLength = 0.5
    x.orthogonalCoordinateDecimal = 1.0
    x.minorTicksPerInterval = 2
    x.majorGridLineStyle = majorGridLineStyle
    x.minorGridLineStyle = minorGridLineStyle
  
    x.title = "X Axis"
    x.titleOffset = 30.0
    x.titleLocation = 1.25
  
    # Label y with an automatic label policy. 
    y = axisSet.yAxis
    y.labelingPolicy = CPAxisLabelingPolicyAutomatic
    y.orthogonalCoordinateDecimal = 1.0
    y.minorTicksPerInterval = 2
    y.preferredNumberOfMajorTicks = 8
    y.majorGridLineStyle = majorGridLineStyle
    y.minorGridLineStyle = minorGridLineStyle
    y.labelOffset = 10.0
  
    y.title = "Y Axis"
    y.titleOffset = 30.0
    y.titleLocation = 1.0
  
    # Rotate the labels by 45 degrees, just to show it can be done.
    labelRotation = M_PI * 0.25;
  
    # Set axes
    #graph.axisSet.axes = [NSArray arrayWithObjects:x, y, y2, nil];
    graph.axisSet.axes = [x, y]
  
    # Create a plot that uses the data source method
    dataSourceLinePlot = CPScatterPlot.alloc.init.autorelease
    dataSourceLinePlot.identifier = "Data Source Plot"
  
    lineStyle = dataSourceLinePlot.dataLineStyle.mutableCopy.autorelease
    lineStyle.lineWidth = 3.0
    lineStyle.lineColor = CPColor.greenColor
    dataSourceLinePlot.dataLineStyle = lineStyle
  
    dataSourceLinePlot.dataSource = self
    graph.addPlot dataSourceLinePlot
  
    self.generateData
  
    # Auto scale the plot space to fit the plot data
    # Extend the y range by 10% for neatness
    plotSpace.scaleToFitPlots [dataSourceLinePlot]
    xRange = plotSpace.xRange
    yRange = plotSpace.yRange
    xRange.expandRangeByFactor(1.3)
    yRange.expandRangeByFactor(1.3)
    plotSpace.yRange = yRange
  
    # Restrict y range to a global range
    globalYRange = CPPlotRange.plotRangeWithLocation(0.0, length:2.0)
    plotSpace.globalYRange = globalYRange
  
    # set the x and y shift to match the new ranges
    length = xRange.lengthDouble
    xShift = length - 3.0
    length = yRange.lengthDouble
    yShift = length - 2.0
  
    # Add plot symbols
    symbolLineStyle = CPMutableLineStyle.lineStyle
    symbolLineStyle.lineColor = CPColor.blackColor
    plotSymbol = CPPlotSymbol.ellipsePlotSymbol
    plotSymbol.fill = CPFill.fillWithColor(CPColor.blueColor)
    plotSymbol.lineStyle = symbolLineStyle
    plotSymbol.size = CGSizeMake(10.0, 10.0)
    dataSourceLinePlot.plotSymbol = plotSymbol
  
    # Set plot delegate, to know when symbols have been touched
    # We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self
    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0
  end

  def dealloc
    symbolTextAnnotation.release
    plotData.release
    super
  end

#pragma mark -
#pragma mark Plot Data Source Methods

  def numberOfRecordsForPlot(plot)
    return plotData.count
  end

  def numberForPlot(plot, field:fieldEnum, recordIndex:index)
    num = plotData[index][fieldEnum == CPScatterPlotFieldX ? "x" : "y"]
    if fieldEnum == CPScatterPlotFieldY then
      num = num.to_f
    end
    return num
  end

#pragma mark -
#pragma mark Plot Space Delegate Methods

  def plotSpace(space, willChangePlotRangeTo:newRange, forCoordinate:coordinate)
    # Impose a limit on how far user can scroll in x
    if coordinate == CPCoordinateX then
      maxRange = CPPlotRange.plotRangeWithLocation(-1.0, length:6.0)
      changedRange = newRange.copy.autorelease
      changedRange.shiftEndToFitInRange maxRange
      changedRange.shiftLocationToFitInRange maxRange
      newRange = changedRange
    end
    return newRange;
  end

#pragma mark -
#pragma mark CPScatterPlot delegate method

  def scatterPlot(plot, plotSymbolWasSelectedAtRecordIndex:index)
    graph = graphs[0]
  
    if symbolTextAnnotation then
      graph.plotAreaFrame.plotArea.removeAnnotation symbolTextAnnotation
      symbolTextAnnotation.release
      symbolTextAnnotation = nil
    end
  
    # Setup a style for the annotation
    hitAnnotationTextStyle = CPMutableTextStyle.textStyle
    hitAnnotationTextStyle.color = CPColor.whiteColor
    hitAnnotationTextStyle.fontSize = 16.0
    hitAnnotationTextStyle.fontName = "Helvetica-Bold";
  
    # Determine point of symbol in plot coordinates
    x = plotData[index]["x"]
    y = plotData[index]["y"]
    anchorPoint = [x, y]
  
    # Add annotation
    # First make a string for the y value
    formatter = NSNumberFormatter.alloc.init.autorelease
    formatter.setMaximumFractionDigits 2
    yString = formatter.stringFromNumber y
  
    # Now add the annotation to the plot area
    textLayer = CPTextLayer.alloc.initWithText(yString, style:hitAnnotationTextStyle).autorelease
    symbolTextAnnotation = CPPlotSpaceAnnotation.alloc.initWithPlotSpace (graph.defaultPlotSpace.anchorPlotPoint(anchorPoint))
    symbolTextAnnotation.contentLayer = textLayer
    symbolTextAnnotation.displacement = CGPointMake(0.0, 20.0)
    graph.plotAreaFrame.plotArea.addAnnotation symbolTextAnnotation
  end

end
