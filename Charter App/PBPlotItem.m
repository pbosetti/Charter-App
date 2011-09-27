//
//  PlotItem.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/4/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PBPlotItem.h"

@implementation PBPlotItem

@synthesize defaultLayerHostingView;
@synthesize graphs;
@synthesize title;
@synthesize chartDataSource;
@synthesize chartSeries;

+ (void)registerPlotItem:(id)item
{  
  Class itemClass = [item class];
	
  if (itemClass) {
    // There's no autorelease pool here yet...
    PBPlotItem *plotItem = [[itemClass alloc] init];
    if (plotItem) {
      //[plotItem release];
    }
  }
}

- (id)init
{
  if ((self = [super init])) {
    graphs = [[NSMutableArray alloc] init];
  }
  
  return self;
}

- (void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)layerHostingView
{
  [graphs addObject:graph];
  
  if (layerHostingView) {
    //layerHostingView.hostedLayer = graph;
    [self addGraph:graph toHostingView:nil];
  }
}

- (void)addGraph:(CPTGraph *)graph
{
  [self addGraph:graph toHostingView:nil];
}

- (void)killGraph
{
  // Remove the CPLayerHostingView
  if (defaultLayerHostingView) {
    [defaultLayerHostingView removeFromSuperview];
    
    //defaultLayerHostingView.hostedLayer = nil;
    //[defaultLayerHostingView release];
    defaultLayerHostingView = nil;
  }
    
  [graphs removeAllObjects];
}

- (void)dealloc
{
  [self killGraph];
  [super dealloc];
}

- (NSComparisonResult)titleCompare:(PBPlotItem *)other
{
  return [title caseInsensitiveCompare:other.title];
}

- (void)setTitleDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds
{
  graph.title = title;
  CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
  textStyle.color = [CPTColor grayColor];
  textStyle.fontName = @"Helvetica-Bold";
  textStyle.fontSize = round(bounds.size.height / 20.0f);
  graph.titleTextStyle = textStyle;
  graph.titleDisplacement = CGPointMake(0.0f, round(bounds.size.height / 18.0f)); // Ensure that title displacement falls on an integral pixel
  graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;    
}

- (void)setPaddingDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds
{
//  float boundsPadding = round(bounds.size.width / 20.0f); // Ensure that padding falls on an integral pixel
  float boundsPadding = 5.0f;
  graph.paddingLeft = boundsPadding;
  
  if (graph.titleDisplacement.y > 0.0) {
    graph.paddingTop = graph.titleDisplacement.y * 2;
  }
  else {
    graph.paddingTop = boundsPadding;
  }
  
  graph.paddingRight = boundsPadding;
  graph.paddingBottom = boundsPadding;    
}


- (void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme
{
  if (theme == nil) {
    [graph applyTheme:defaultTheme];
  }
  else if (![theme isKindOfClass:[NSNull class]])	{
    [graph applyTheme:theme];
  }
}

- (void)setFrameSize:(NSSize)size
{
}


- (void)renderInView:(NSView*)hostingView withTheme:(CPTTheme*)theme
{
  [self killGraph];
  //CGRect bounds = NSRectToCGRect([hostingView bounds]);
  defaultLayerHostingView = [[CPTGraphHostingView alloc] initWithFrame:[hostingView bounds]];
  
  [defaultLayerHostingView setAutoresizesSubviews:YES];
  [defaultLayerHostingView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  
  [hostingView addSubview:defaultLayerHostingView];
  [self renderInLayer:defaultLayerHostingView withTheme:theme];
}

- (void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
  NSLog(@"PlotItem:renderInLayer: Override me");
}

- (void)reloadData
{
  for (CPTGraph *g in graphs) {
    [g reloadData];
  }
}

- (CPTColor *)cptColorFromNSColor:( NSColor *)color
{
  return [CPTColor colorWithComponentRed:[color redComponent] 
                                   green:[color greenComponent] 
                                    blue:[color blueComponent]
                                   alpha:[color alphaComponent]];
}


@end
