//
//  PlotGalleryController.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/5/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PBPlotController.h"

const float CP_SPLIT_VIEW_MIN_LHS_WIDTH = 150.0f;

#define kThemeTableViewControllerNoTheme        @"None"
#define kThemeTableViewControllerDefaultTheme   @"Default"

@implementation PBPlotController

@synthesize currentThemeName;
@synthesize chartDataSource;
@synthesize chartSeries;


- (id)init
{
  if ((self = [super init])) {
    
  }
  
  return self;
}

- (void)setupThemes
{
  [themePopUpButton removeAllItems];
  [themePopUpButton addItemWithTitle:kThemeTableViewControllerDefaultTheme];
  [themePopUpButton addItemWithTitle:kThemeTableViewControllerNoTheme];
  
  for (Class c in [CPTTheme themeClasses]) {
    [themePopUpButton addItemWithTitle:[c defaultName]];
  }
  
//  [themePopUpButton selectItemWithTitle:kThemeTableViewControllerDefaultTheme];
  [themePopUpButton selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"selectedTheme"]];
  self.currentThemeName = [themePopUpButton titleOfSelectedItem];
}

- (void)awakeFromNib
{
  [hostingView setDelegate:self];  
  [self setupThemes];
  plotItem = [[PBScatterPlot alloc] init];
  [plotItem setChartDataSource:chartDataSource];
  [plotItem setChartSeries:chartSeries];
  [plotItem renderInView:hostingView withTheme:[self currentTheme]];
}

- (void)dealloc
{
  [self setPlotItem:nil];
  
  [hostingView setDelegate:nil];
  
  [super dealloc];
}

- (void)setFrameSize:(NSSize)newSize
{
  if ([plotItem respondsToSelector:@selector(setFrameSize:)]) {
    [plotItem setFrameSize:newSize];
  }
}

#pragma mark -
#pragma mark Theme Selection

- (CPTTheme *)currentTheme
{
  CPTTheme *theme;
  
  if (currentThemeName == kThemeTableViewControllerNoTheme) {
    theme = (id)[NSNull null];
  }
  else if (currentThemeName == kThemeTableViewControllerDefaultTheme) {
    theme = nil;
  }
  else {
    theme = [CPTTheme themeNamed:currentThemeName];
  }
  
  return theme;
}

- (IBAction)themeSelectionDidChange:(id)sender
{
  self.currentThemeName = [sender titleOfSelectedItem];
	[plotItem renderInView:hostingView withTheme:[self currentTheme]];
}

- (IBAction)test:(id)sender {
  NSLog(@"chartDataSource is %@", [chartDataSource inspect]);
  [self reloadData];
}

- (void)createCharts
{
  [plotItem createCharts];
}

- (void)reloadData
{
  [plotItem reloadData];
}

- (IBAction)updateCharts:(id)sender
{
  [plotItem setupCharts];
}

- (IBAction)rescaleAll:(id)sender {
  [plotItem rescaleAll];
}

- (IBAction)setupGrid:(id)sender
{
  [plotItem setupGrid];
}

-(IBAction)exportToPNG:(id)sender
{
	NSSavePanel *pngSavingDialog = [NSSavePanel savePanel];
	[pngSavingDialog setAllowedFileTypes:[NSArray arrayWithObject:@"png"]];
	
	if ( [pngSavingDialog runModal] == NSOKButton ) {
		NSImage *image = [((PBScatterPlot *)plotItem).graph imageOfLayer];
    NSData *tiffData = [image TIFFRepresentation];
    NSBitmapImageRep *tiffRep = [NSBitmapImageRep imageRepWithData:tiffData];
    NSData *pngData = [tiffRep representationUsingType:NSPNGFileType properties:nil];
		[pngData writeToURL:[pngSavingDialog URL] atomically:NO];
	}		
}

-(IBAction)exportToPDF:(id)sender
{
	NSSavePanel *pdfSavingDialog = [NSSavePanel savePanel];
	[pdfSavingDialog setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
	
	if ( [pdfSavingDialog runModal] == NSOKButton ) {
		NSData *dataForPDF = [((PBScatterPlot *)plotItem).graph dataForPDFRepresentationOfLayer];
		[dataForPDF writeToURL:[pdfSavingDialog URL] atomically:NO];
  }		
}

#pragma mark -
#pragma mark PlotItem Property

- (PBPlotItem *)plotItem
{
  return plotItem;
}

- (void)setPlotItem:(PBPlotItem *)item
{
  if (plotItem != item) {
    [plotItem killGraph];
    //[plotItem release];
    
    plotItem = [item retain];
    
    [plotItem renderInView:hostingView withTheme:[self currentTheme]];
  }
}

@end
