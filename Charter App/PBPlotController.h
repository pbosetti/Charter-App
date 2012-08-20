//
//  PlotGalleryController.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/5/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <CorePlot/CorePlot.h>

#import "PBChartDataSource.h"

#import "PBPlotView.h"
#import "PBPlotItem.h"
#import "PBScatterPlot.h"

@interface PBPlotController : NSObject <PlotViewDelegate>
{
  IBOutlet NSScrollView       *scrollView;
  IBOutlet NSPopUpButton      *themePopUpButton;
  
  IBOutlet PBPlotView         *hostingView;
  CPTGraphHostingView          *defaultLayerHostingView;
  NSString                    *currentThemeName;
  NSToolbarItem               *test;
  
  id                          plotItem;
  IBOutlet NSButton *autoscale;
  IBOutlet id                 chartDataSource;
  IBOutlet id                 chartSeries;
  IBOutlet NSForm *chartRanges;
}

@property (nonatomic, retain) PBPlotItem *plotItem;
@property (nonatomic, copy) NSString *currentThemeName;
@property (assign) IBOutlet id chartDataSource;
@property (assign) IBOutlet id chartSeries;
@property (assign) IBOutlet NSButton *autoscale;
@property (assign) IBOutlet NSForm *chartRanges;

- (IBAction)themeSelectionDidChange:(id)sender;
- (IBAction)test:(id)sender;
- (IBAction)rescaleAll:(id)sender;
- (IBAction)updateCharts:(id)sender;
- (IBAction)setupGrid:(id)sender;
- (IBAction)exportToPNG:(id)sender;
- (IBAction)exportToPDF:(id)sender;

- (CPTTheme *)currentTheme;
- (void)reloadData;
- (void)createCharts;
- (void)setupAxesLabels:(NSMutableArray *)labels;
@end
