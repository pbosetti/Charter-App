//
//  SimpleScatterPlot.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PBPlotItem.h"
#define DEFAULTS [NSUserDefaults standardUserDefaults]

@interface PBScatterPlot : PBPlotItem < CPTPlotSpaceDelegate,CPTPlotDataSource,CPTScatterPlotDelegate>
{
  CPTPlotSpaceAnnotation  *symbolTextAnnotation;
  
  CGFloat             xShift;
  CGFloat             yShift;
  
  CGFloat             labelRotation;
  
  CPTGraph            *graph;
  CPTXYPlotSpace      *plotSpace;
  
  NSArray*            plotData;
  NSArray            *symbols;
}

@property (nonatomic, assign) CPTGraph *graph;
@property (nonatomic, assign) CPTXYPlotSpace *plotSpace;

- (void)setAxisTitle:(NSString *)axisTitle atOffset:(float)offset forCoordinate:(CPTCoordinate)coordinate;
- (void)rescaleAll;
- (void)setupCharts;
- (void)createCharts;
- (void)setupGrid;
- (void)setPropertiesForChart:(PBChartSeries *)serie;
- (void)rescaleToXRange:(CPTPlotRange *)xRange yRange:(CPTPlotRange *)yRange;
@end