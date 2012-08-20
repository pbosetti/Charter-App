//
//  SimpleScatterPlot.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PBScatterPlot.h"

@implementation PBScatterPlot
@synthesize graph, plotSpace;

+ (void)load
{
  [super registerPlotItem:self];
}

- (id)init
{
	if ((self = [super init])) {
    title = @"Simple Scatter Plot";
    symbols = [NSArray arrayWithObjects:@"crossPlotSymbol",@"ellipsePlotSymbol",@"rectanglePlotSymbol",
               @"trianglePlotSymbol",@"plusPlotSymbol",@"starPlotSymbol",@"diamondPlotSymbol",nil];
      //plotList = [[NSMutableArray alloc] init];
  }
  
  return self;
}

- (void)killGraph
{
  if ([graphs count]) {
      //CPGraph *graph = [graphs objectAtIndex:0];
    
    if (symbolTextAnnotation) {
      [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
      //[symbolTextAnnotation release];
      symbolTextAnnotation = nil;
    }
  }
  
  [super killGraph];
}

//- (void)dealloc
//{
//  [symbolTextAnnotation release];
//  [plotData release];
//  [super dealloc];
//}

#pragma mark -
#pragma mark Chart rendering and set-up

- (void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
  CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
  
  graph = [[CPTXYGraph alloc] initWithFrame:[layerHostingView bounds]]; //autorelease];
  [self addGraph:graph toHostingView:layerHostingView];
  [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:@"None"]];
  
  //[self setTitleDefaultsForGraph:graph withBounds:bounds];
  [self setPaddingDefaultsForGraph:graph withBounds:bounds];
  
  // Setup scatter plot space
  plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
  plotSpace.allowsUserInteraction = YES;
  plotSpace.delegate = self;
  
  // setup grids
  [self setupGrid];
  
  CPTPlotRange *defaultRange = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromDouble(-1.0) 
                                                              length:CPTDecimalFromDouble(11.0)];
  plotSpace.xRange = defaultRange;
  plotSpace.yRange = defaultRange;
  [defaultRange autorelease];
  [self setupAxesLabels];
}

- (void)setupAxesLabels
{
  [self setAxisTitle:[axesLabels objectAtIndex:0] atOffset:1.0f forCoordinate:CPTCoordinateX];  
  [self setAxisTitle:[axesLabels objectAtIndex:1] atOffset:1.0f forCoordinate:CPTCoordinateY];
}

- (void)setupGrid
{
  // Grid line styles
  CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
  majorGridLineStyle.lineWidth = 0.75;
  majorGridLineStyle.lineColor = [self cptColorFromNSColor:[NSUnarchiver unarchiveObjectWithData:[DEFAULTS objectForKey:@"majorGridColor"]]]; //[[CPTColor colorWithGenericGray:0.1] colorWithAlphaComponent:0.75];
  
  CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
  minorGridLineStyle.lineWidth = 0.75;
  minorGridLineStyle.lineColor = [self cptColorFromNSColor:[NSUnarchiver unarchiveObjectWithData:[DEFAULTS objectForKey:@"minorGridColor"]]]; //[[CPTColor colorWithGenericGray:0.3] colorWithAlphaComponent:0.33];    
  
  // Axes
  // Label x axis with a fixed interval policy
  CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
  CPTXYAxis *x = axisSet.xAxis;
  //x.majorIntervalLength = CPTDecimalFromString(@"1.0");
  x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0.0");
  x.minorTicksPerInterval = [DEFAULTS integerForKey:@"numberOfMinorTicks"];
  x.majorGridLineStyle = majorGridLineStyle;
  x.minorGridLineStyle = minorGridLineStyle;
  x.labelOffset = 10.0;
  x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
  x.preferredNumberOfMajorTicks = [DEFAULTS integerForKey:@"numberOfMajorTicks"];
  
  // Label y with an automatic label policy. 
  CPTXYAxis *y = axisSet.yAxis;
  //y.majorIntervalLength = CPTDecimalFromString(@"1.0");
  y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0.0");
  y.minorTicksPerInterval = [DEFAULTS integerForKey:@"numberOfMinorTicks"];
  y.majorGridLineStyle = majorGridLineStyle;
  y.minorGridLineStyle = minorGridLineStyle;
  y.labelOffset = 10.0;
  y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
  y.preferredNumberOfMajorTicks = [DEFAULTS integerForKey:@"numberOfMajorTicks"];
  
  
  // Rotate the labels by 45 degrees, just to show it can be done.
  //labelRotation = M_PI * 0.25;
  
  // Set axes
  //graph.axisSet.axes = [NSArray arrayWithObjects:x, y, y2, nil];
  graph.axisSet.axes = [NSArray arrayWithObjects:x, y, nil];
}

- (void)createCharts
{
  for (CPTPlot *plot in [graph allPlots]) {
    [graph removePlot:plot];
  }
  for (PBChartSeries *serie in (NSArray *)[chartSeries content]) {
      // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init]; //autorelease];
    dataSourceLinePlot.identifier = [serie id];

      // Set plot delegate, to know when symbols have been touched
      // We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self; 
    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0f;
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    [self setPropertiesForChart:serie];
  }
}

- (void)setupCharts
{
  for (PBChartSeries *serie in (NSArray *)[chartSeries content]) {
    [self setPropertiesForChart:serie];
  }
}

- (void)setPropertiesForChart:(PBChartSeries *)serie
{
  CPTScatterPlot *dataSourceLinePlot = (CPTScatterPlot *)[graph plotWithIdentifier:serie.id];
  dataSourceLinePlot.identifier = serie.id;
  CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy]; //autorelease];
  lineStyle.lineWidth = ([serie.isEnabled boolValue] ? [serie.thickness floatValue] : 0.0f);
  lineStyle.lineColor = [self cptColorFromNSColor:serie.color];
  dataSourceLinePlot.dataLineStyle = lineStyle;
  
  // Add plot symbols
  CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
  [lineStyle release];
  symbolLineStyle.lineColor = [CPTColor blackColor];
  CPTPlotSymbol *plotSymbol = [CPTPlotSymbol performSelector:NSSelectorFromString([symbols objectAtIndex:[serie.symbol integerValue]])];
  plotSymbol.fill = [CPTFill fillWithColor:[self cptColorFromNSColor:serie.color]];
  plotSymbol.lineStyle = symbolLineStyle;
  float symbolSize = ([serie.isEnabled boolValue] ? [serie.symbolSize floatValue] : 0.0f);
  plotSymbol.size = CGSizeMake(symbolSize, symbolSize);
  dataSourceLinePlot.plotSymbol = plotSymbol;
}

- (void)rescaleAll
{
  if (symbolTextAnnotation) {
    [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
      //[symbolTextAnnotation release];
    symbolTextAnnotation = nil;
  }
  // Update axes labels
  [self setAxisTitle:[axesLabels objectAtIndex:0] atOffset:1.0f forCoordinate:CPTCoordinateX];  
  [self setAxisTitle:[axesLabels objectAtIndex:1] atOffset:1.0f forCoordinate:CPTCoordinateY];
  
  // Auto scale the plot space to fit the plot data
  // Extend the y range by 10% for neatness
  [plotSpace scaleToFitPlots:[graph allPlots]];
  CPTMutablePlotRange *xRange = [CPTMutablePlotRange plotRangeWithLocation:plotSpace.xRange.minLimit
                                                                    length:plotSpace.xRange.length];
  CPTMutablePlotRange *yRange = [CPTMutablePlotRange plotRangeWithLocation:plotSpace.yRange.minLimit
                                                                    length:plotSpace.yRange.length];
  //xRange.length *= [DEFAULTS doubleForKey:@"zoomExpansion"];
  
  [xRange expandRangeByFactor:CPTDecimalFromDouble([DEFAULTS doubleForKey:@"zoomExpansion"])];
  [yRange expandRangeByFactor:CPTDecimalFromDouble([DEFAULTS doubleForKey:@"zoomExpansion"])];
  [self rescaleToXRange:xRange yRange:yRange];
}

- (void)rescaleToXRange:(CPTPlotRange *)xRange yRange:(CPTPlotRange *)yRange
{
  plotSpace.yRange = yRange;
  plotSpace.xRange = xRange;
  /*
  CGFloat length = xRange.lengthDouble;
  xShift = length;// - 3.0;
  length = yRange.lengthDouble;
  yShift = length;// - 2.0;
   */
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
  return [[chartDataSource data] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
  return [chartDataSource numberForPlot:plot 
                                 field:[NSNumber numberWithUnsignedLong:fieldEnum] 
                           recordIndex:[NSNumber numberWithUnsignedLong:index]];
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
  float offset;
  /*
  // Impose a limit on how far user can scroll in x
  if (coordinate == CPTCoordinateX) {
    //    CPTPlotRange *maxRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(6.0f)];
    CPTPlotRange *changedRange = [newRange copy]; // autorelease];
    //    [changedRange shiftEndToFitInRange:maxRange];
    //    [changedRange shiftLocationToFitInRange:maxRange];
    newRange = changedRange;
    
    offset = ([newRange maxLimitDouble] - [newRange lengthDouble] / 10.0f);
  }
  */
  offset = ([newRange maxLimitDouble] - [newRange lengthDouble] / 10.0f);
  [self setAxisTitle:[axesLabels objectAtIndex:coordinate] atOffset:offset forCoordinate:coordinate];
  return newRange;
}


- (void)setAxisTitle:(NSString *)axisTitle atOffset:(float)offset forCoordinate:(CPTCoordinate)coordinate
{
    //CPGraph *graph = [graphs objectAtIndex:0];
  CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
  CPTXYAxis *axis;
  if (coordinate == CPTCoordinateX) {
    axis = axisSet.xAxis;
  }
  else {
    axis = axisSet.yAxis;
  }
  axis.title = axisTitle;
  axis.titleOffset = -20.0;
  axis.titleLocation = CPTDecimalFromFloat(offset);
}

#pragma mark -
#pragma mark CPScatterPlot delegate method
/*
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
  graph = [graphs objectAtIndex:0];
  
  if (symbolTextAnnotation) {
    [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
    //[symbolTextAnnotation release];
    symbolTextAnnotation = nil;
  }
  
  // Setup a style for the annotation
  CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
  hitAnnotationTextStyle.color = [CPTColor blackColor];
  hitAnnotationTextStyle.fontSize = 16.0f;
  hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
  
  // Determine point of symbol in plot coordinates
  NSNumber *x = [[plotData objectAtIndex:index] valueForKey:@"x"];
  NSNumber *y = [[plotData objectAtIndex:index] valueForKey:@"y"];
  NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
  
  // Add annotation
  // First make a string for the y value
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init]; // autorelease];
  [formatter setMaximumFractionDigits:2];
  NSString *yString = [formatter stringFromNumber:y];
  
  [formatter release];
  // Now add the annotation to the plot area
  CPTTextLayer *textLayer = [[[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle] autorelease];
  symbolTextAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
  symbolTextAnnotation.contentLayer = textLayer;
  symbolTextAnnotation.displacement = CGPointMake(0.0f, 20.0f);
  [graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];    
}
*/
@end
