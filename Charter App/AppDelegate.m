//
//  AppDelegate.m
//  Testing
//
//  Created by Paolo Bosetti on 8/4/11.
//  Copyright 2011 Dipartimento di Ingegneria Meccanica e Strutturale. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize inspectDataStream;
@synthesize startStopButton;
@synthesize port;
@synthesize window;
@synthesize chartDataSource;
@synthesize dataTable;
@synthesize dataTableView;
@synthesize mainView;
@synthesize dataPanelHUD;
@synthesize sourceList;
@synthesize popover;
@synthesize recordPopover;
@synthesize resetCounterButton;
@synthesize seriesArrayController;
@synthesize seriesTableView;
@synthesize splitView;
@synthesize startButton;
@synthesize textGuideView;
@synthesize chartHostView;
@synthesize plotController;
@synthesize updatePeriod;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)click:(id)sender {
}

- (IBAction)toggleLeftPane:(id)sender {
}

- (IBAction)buttonClick:(id)sender {
}

- (IBAction)inspectDataStream:(id)sender {
}

- (IBAction)showDataTable:(id)sender {
}

- (IBAction)startListening:(id)sender {
}

- (IBAction)stopListening:(id)sender {
}

- (IBAction)editSettings:(id)sender {
}

- (IBAction)selectID:(id)sender {
}

- (IBAction)test:(id)sender {
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
  return YES;
}

- (IBAction)editSeriesItem:(id)sender {
}
- (IBAction)showDataTable:(id)sender {
  [[[NSTableView alloc] init] setNumb
  [[mainView animator] 
}
   
- (IBAction)showAboutBox:(id)sender
   {
     
   }

- (IBAction)updateCharts:(id)sender
   {
     
   }
@end
