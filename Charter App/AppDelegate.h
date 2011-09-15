//
//  AppDelegate.h
//  Testing
//
//  Created by Paolo Bosetti on 8/4/11.
//  Copyright 2011 Dipartimento di Ingegneria Meccanica e Strutturale. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSButton *startButton;
  NSTextView *textGuideView;
  CPLayerHostingView *chartHostView;
  PBPlotController *plotController;
  NSTextFieldCell *updatePeriod;
  NSWindow *window;
  NSScrollView *sourceList;
  NSPopover *popover;
  NSPopover *recordPopover;
  NSButton *resetCounterButton;
  NSArrayController *seriesArrayController;
  NSTableView *seriesTableView;
  NSView *splitView;
  NSPanel *dataPanelHUD;
  NSView *mainView;
  NSScrollView *dataTableView;
  PBChartDataSource *chartDataSource;
  NSTableView *dataTable;
  NSToolbarItem *inspectDataStream;
  NSTextField *port;
  NSToolbarItem *startStopButton;
}

- (IBAction)editSeriesItem:(id)sender;
- (IBAction)toggleLeftPane:(id)sender;
- (IBAction)buttonClick:(id)sender;
- (IBAction)inspectDataStream:(id)sender;
- (IBAction)startListening:(id)sender;
- (IBAction)stopListening:(id)sender;
- (IBAction)editSettings:(id)sender;
- (IBAction)selectID:(id)sender;
- (IBAction)test:(id)sender;
- (IBAction)openTerminal:(id)sender;
- (IBAction)updateCharts:(id)sender;

@property (assign) IBOutlet NSToolbarItem *startStopButton;
@property (assign) IBOutlet NSTextField *port;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet PBChartDataSource *chartDataSource;
@property (assign) IBOutlet NSTableView *dataTable;
@property (assign) IBOutlet NSScrollView *dataTableView;
@property (assign) IBOutlet NSView *mainView;
@property (assign) IBOutlet NSScrollView *sourceList;
@property (assign) IBOutlet NSPopover *seriesPopover;
@property (assign) IBOutlet NSPopover *recordPopover;
@property (assign) IBOutlet NSButton *resetCounterButton;
@property (assign) IBOutlet NSArrayController *seriesArrayController;
@property (assign) IBOutlet NSTableView *seriesTableView;
@property (assign) IBOutlet NSView *splitView;
@property (assign) IBOutlet NSPanel *dataPanelHUD;
@property (assign) IBOutlet NSButton *startButton;
@property (assign) IBOutlet NSScrollView *textGuideView;
@property (assign) IBOutlet CPLayerHostingView *chartHostView;
@property (assign) IBOutlet PBPlotController *plotController;
@property (assign) IBOutlet NSTextFieldCell *updatePeriod;

@end
