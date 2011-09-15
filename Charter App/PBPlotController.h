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
  CPTLayerHostingView          *defaultLayerHostingView;
  NSString                    *currentThemeName;
  NSToolbarItem               *test;
  
  id                          plotItem;
  IBOutlet id                 chartDataSource;
  IBOutlet id                 chartSeries;
}

@property (nonatomic, retain) PBPlotItem *plotItem;
@property (nonatomic, copy) NSString *currentThemeName;
@property (assign) IBOutlet id chartDataSource;
@property (assign) IBOutlet id chartSeries;

- (IBAction)themeSelectionDidChange:(id)sender;
- (IBAction)test:(id)sender;
- (IBAction)rescaleAll:(id)sender;
- (IBAction)updateCharts:(id)sender;

- (CPTTheme *)currentTheme;
- (void)reloadData;
- (void)createCharts;
@end
