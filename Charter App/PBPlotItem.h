//
//  PlotItem.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CorePlot/CorePlot.h>
#import "PBChartDataSource.h"

//typedef CPTLayerHostingView CPTGraphHostingView;

typedef NSRect CGNSRect;


@class CPTGraph;
@class CPTTheme;

@interface PBPlotItem : NSObject
{
  CPTGraphHostingView  *defaultLayerHostingView;
  
  NSMutableArray      *graphs;
  NSString            *title;
  PBChartDataSource   *chartDataSource;
  NSArrayController   *chartSeries;
}

@property (nonatomic, retain) CPTGraphHostingView *defaultLayerHostingView;
@property (nonatomic, retain) NSMutableArray *graphs;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) id chartDataSource;
@property (nonatomic, retain) id chartSeries;

+ (void)registerPlotItem:(id)item;

- (void)renderInView:(NSView *)hostingView withTheme:(CPTTheme *)theme;
- (void)setFrameSize:(NSSize)size;


- (void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme;

- (void)setTitleDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds;
- (void)setPaddingDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds;

- (void)reloadData;
- (void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme;

- (void)addGraph:(CPTGraph *)graph;
- (void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)layerHostingView;
- (void)killGraph;

- (NSComparisonResult)titleCompare:(PBPlotItem *)other;
- (CPTColor *)cptColorFromNSColor:( NSColor *)color;
@end
