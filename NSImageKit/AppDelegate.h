//
//  AppDelegate.h
//  NSImageKit
//
//  Created by Alex Gray on 3/15/12.
//  Copyright (c) 2012 mrgray.com, inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


#define TEST_IMAGE @"Google Chrome.png"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	IBOutlet NSDictionaryController	*segmentsArrayController;
	IBOutlet NSSlider 				*sliderRotationControl;
	IBOutlet NSView				*colorChartView;
	NSArray							*colorArray;
	
	SBJsonParser *jsonParser;

}

@property (assign) IBOutlet WebView 	*webView;
@property (assign) IBOutlet NSWindow	*window;
@property (assign) id 				jsonObject;

@end
