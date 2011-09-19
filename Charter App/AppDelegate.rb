#
#  AppDelegate.rb
#  Testing
#
#  Created by Paolo Bosetti on 8/4/11.
#  Copyright 2011 Dipartimento di Ingegneria Meccanica e Strutturale. All rights reserved.
#
require 'socket'

BUNDLE = NSBundle.mainBundle
VERSION = BUNDLE.infoDictionary["CFBundleShortVersionString"]
BUILD = BUNDLE.infoDictionary["CFBundleVersion"]
PORT = 2000

class AppDelegate
  attr_accessor :window, :startButton, :sourceList, :resetCounterButton
  attr_accessor :splitView, :mainView, :dataTableView, :dataTable, :chartDataSource
  attr_accessor :seriesInfoPanel
  attr_accessor :hitCount, :port
  attr_accessor :seriesArray, :seriesArrayController, :seriesTableView
  attr_accessor :listening, :statusBarMessage, :startStopButton
  attr_accessor :chartHostView
  attr_accessor :plotController
  attr_accessor :userDefaultsController
  attr_writer :updatePeriod
  attr_reader :allowSavingData
  
  def initialize
    @listening = 0
    @listeningSocket = UDPSocket.open
    @defaults = NSUserDefaults.standardUserDefaults
    @defaults.registerDefaults(NSDictionary.dictionaryWithContentsOfFile(NSBundle.mainBundle.resourcePath + "/Charter_defaults.plist"))
  end
  
  def applicationDidFinishLaunching(a_notification)
    # Insert code here to initialize your application
    @seriesArray = []
    @hitCount = 0
    @splitViewPosition = 120.0
    #@chartDataSource.addRecordFromString "m 1,2 10,3 12,2 9,0 7,13"
    #@chartDataSource.addRecordFromString "s 1 10 12 9 7"
    self.setStatusBarMessage ""
    self.setPort 1
    @listeningThread = Thread.start {}
    @guideVisible = true
    self.setUpdatePeriod(@defaults.integerForKey("updatePeriod") || 10)
    @userDefaultsController.setInitialValues(NSDictionary.dictionaryWithContentsOfFile(NSBundle.mainBundle.resourcePath + "/Charter_defaults.plist"))
    if Time.now > Time.gm(2011,9,30)
      NSAlert.alertWithMessageText("Expired!", 
                                 defaultButton: "OK",
                                 alternateButton: nil,
                                 otherButton: nil,
                                 informativeTextWithFormat: "Testing period has expired, sorry").runModal
      exit
    end
  end
  
  def saveDataTable(sender)
    savingDialog = NSSavePanel.savePanel
    savingDialog.setAllowedFileTypes %w|txt dat|
    if savingDialog.runModal == NSOKButton then
      names = []
      @seriesArray.each {|s| names << s.name }
      @chartDataSource.saveDataOnFile(savingDialog.URL.path, withHeader:names)
    end
  end
  
  def allowSavingData
    chartDataSource.data.count > 0
  end
  
  def showAboutBox(sender)
    options = {
      "Copyright" => "© Paolo Bosetti, 2011",
      "ApplicationName" => "Charter - Free version"
    }
    NSApplication.sharedApplication.orderFrontStandardAboutPanelWithOptions(options)
  end
  
  def windowControllerDidLoadNib(aController)
    puts "Nib loaded"
  end
  
  def updatePeriod
    case @updatePeriod
    when 1
      "continuous"
    when 101
      "never"
    else
      @updatePeriod.to_i.to_s
    end
  end
  
  def updateCharts(sender)
    plotController.updateCharts(self)
  end
  
  def resetDataTable(args=nil)
    while (cols = @dataTable.tableColumns).count > 0
      cols.length.times {|i| @dataTable.removeTableColumn(cols[i])}
    end
    @seriesArrayController.setSelectedObjects @seriesArrayController.arrangedObjects
    @seriesArrayController.remove(self)
    PBChartSeries.resetCounter
    n = @chartDataSource.numberOfSeries
    case @chartDataSource.type
    when :s
      column = NSTableColumn.alloc.initWithIdentifier("0")
      column.headerCell.setStringValue "X"
      @dataTable.addTableColumn column
      n.times do |i| 
        @seriesArrayController.addObject(PBChartSeries.new)
        column = NSTableColumn.alloc.initWithIdentifier((i+1).to_s)
        column.headerCell.bind "value", toObject:@seriesArrayController.arrangedObjects[i], withKeyPath:"name", options:{NSContinuouslyUpdatesValueBindingOption:true}
        column.bind "textColor", toObject:@seriesArrayController.arrangedObjects[i], withKeyPath:"color", options:nil
        @dataTable.addTableColumn column
      end
    when :m
      n.times do |i|
        @seriesArrayController.addObject(PBChartSeries.new)
        columnX = NSTableColumn.alloc.initWithIdentifier((2*i).to_s)
        columnY = NSTableColumn.alloc.initWithIdentifier((2*i+1).to_s)
        columnX.headerCell.setStringValue "X #{i+1}"
        columnY.headerCell.bind "value", toObject:@seriesArrayController.arrangedObjects[i], withKeyPath:"name", options:{NSContinuouslyUpdatesValueBindingOption:true}
        columnX.bind "textColor", toObject:@seriesArrayController.arrangedObjects[i], withKeyPath:"color", options:nil
        columnY.bind "textColor", toObject:@seriesArrayController.arrangedObjects[i], withKeyPath:"color", options:nil
        @dataTable.addTableColumn columnX
        @dataTable.addTableColumn columnY
      end
    end
    @dataTable.reloadData
    @plotController.createCharts
  end
  
  def test(sender)
    if true
      p chartDataSource.data
    else
    NSAnimationContext.currentContext.setDuration 1.0
    if @guideVisible then
      textGuideView.animator.removeFromSuperview
      @guideVisible = false
    else
      mainView.animator.addSubview textGuideView
      @guideVisible = true
    end
      end
  end
  
  def buttonClick(sender)
    puts "ButtonClick"
    options = {
      "Copyright" => "Paolo Bosetti 2011"
    }
    NSApplication.sharedApplication.orderFrontStandardAboutPanelWithOptions(options)
  end

  def openTerminal(sender)
    NSWorkspace.sharedWorkspace.launchAppWithBundleIdentifier "com.apple.Terminal", options:NSWorkspaceLaunchDefault, additionalEventParamDescriptor:nil, launchIdentifier:nil
  end

  def editSettings(sender)
    width = splitView.subviews.objectAtIndex(0).frame.size.width
    NSAnimationContext.currentContext.setDuration 1.0
    if width == 0.0
      splitView.animator.setPosition @splitViewPosition, ofDividerAtIndex:0
      sender.setLabel "Hide legend"
    else
      @splitViewPosition = width
      splitView.animator.setPosition 0, ofDividerAtIndex:0
      sender.setLabel "Show legend"
    end
  end
  
  def inspectDataStream(sender)
    NSAnimationContext.currentContext.setDuration 1.0

    if sender.state == NSOnState
      mainView.animator.addSubview dataTableView
    else
      dataTableView.animator.removeFromSuperview
    end
  end
  
  def startListening(sender)
    if listening == 1 and not @listeningThread.alive? then
      startStopButton.setLabel "Running"
      setStatusBarMessage "Started listening on port #{@port.to_i}"
      setListening 1
      @listeningSocket = UDPSocket.open
      @listeningSocket.bind(nil, PORT + @port.to_i)
      @listeningThread = Thread.start(@listeningSocket) do |svr|
        running = true
        badMsg = 0
        counter = 0
        while running do
          raw = svr.recvfrom(2048)
          next if @defaults.integerForKey("networkOperations") == 1 and raw[1][2] != '127.0.0.1'
          raw = raw[0].chomp
          case raw
          when /CLOSE/i
            running = false
            self.performSelectorOnMainThread "setStatusBarMessage:", withObject:"Idle", waitUntilDone:false
          when /CLEAR/i
            @chartDataSource.reset
            self.performSelectorOnMainThread "setStatusBarMessage:", withObject:"Remotely cleared", waitUntilDone:true
            @dataTable.performSelectorOnMainThread "reloadData", withObject:nil, waitUntilDone:true
          when /^NAMES\s(.*)/i
            names = $1.split
            if names.count == seriesArray.count then
              @seriesArray.each_with_index do |s,i|
                s.name = names[i]
              end
            end
          when /^[m|s]\s*/
            counter += 1
            if @chartDataSource.addRecordFromString(raw) == :reload then
              self.performSelectorOnMainThread "resetDataTable", withObject:nil, waitUntilDone:true
            end
            @dataTable.performSelectorOnMainThread "reloadData", withObject:nil, waitUntilDone:true
            if counter >= @updatePeriod.to_i and self.updatePeriod != "never" then
              counter = 0
              plotController.performSelectorOnMainThread "rescaleAll:", withObject:self, waitUntilDone:true
            end
          else
            self.performSelectorOnMainThread "setStatusBarMessage:", withObject:"Got #{badMsg += 1} bad messages", waitUntilDone:false
          end
        end
        svr.close
        setListening 0
      end
    elsif listening == 0
      startStopButton.setLabel "Idle"
      setStatusBarMessage "Stopped listening"
      UDPSocket.open.send("CLOSE", 0, 'localhost', PORT + @port.to_i)
    end
  end
    
  # LAUNCHING URLS
  def launchGitHub(sender)
      NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString "https://github.com/pbosetti/Charter")
  end
  
  # DELEGATES for splitView
  def splitView(sender, resizeSubviewsWithOldSize:oldSize)
    dividerThickness = sender.dividerThickness
    leftRect = sender.subviews.objectAtIndex(0).frame
    rightRect = sender.subviews.objectAtIndex(1).frame
    newFrame = sender.frame
    
    leftRect.size.height = newFrame.size.height
    leftRect.origin = NSMakePoint(0, 0)
    rightRect.size.width = newFrame.size.width - leftRect.size.width - dividerThickness
    rightRect.size.height = newFrame.size.height
    rightRect.origin.x = leftRect.size.width + dividerThickness
    
    sender.subviews.objectAtIndex(0).setFrame(leftRect)
    sender.subviews.objectAtIndex(1).setFrame(rightRect)
  end
  
  # DELEGATES for tableView
  def tableViewSelectionDidChange(aNotification)
    
  end
    
  # DELEGATES for application
  def applicationWillTerminate(aNotification)
    @defaults.setInteger(@updatePeriod.to_i, forKey:"updatePeriod")                
  end
    
  def applicationShouldTerminateAfterLastWindowClosed(sender)
    true
  end
end

