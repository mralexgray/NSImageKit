//
//  AppDelegate.m
//  NSImageKit
//
//  Created by Alex Gray on 3/15/12.
//  Copyright (c) 2012 mrgray.com, inc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window, webView, jsonObject;


-(void) makeSomePie { 
	[colorChartView bind:@"segmentNamesArray" toObject:segmentsArrayController withKeyPath:@"arrangedObjects.color" options:nil];
	[colorChartView bind:@"segmentValuesArray" toObject:segmentsArrayController withKeyPath:@"arrangedObjects.count" options:nil];
	[colorChartView bind:@"selectionIndexes" toObject:segmentsArrayController withKeyPath:@"selectionIndexes" options:nil];
	[segmentsArrayController bind:@"selectionIndexes" toObject:colorChartView withKeyPath:@"selectionIndexes" options:nil];
	//	[sliderRotationControl bind:@"value" toObject:pieChartView withKeyPath:@"rotationAmount" options:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{	NSLog(@"App did f-launching.");

	NSImage *imagePath = [NSImage imageNamed:TEST_IMAGE];
	[self loadImage:imagePath];
	[self getColorsforImage:imagePath];
	
	// Insert code here to initialize your application
}

- (NSData *) dataFromImage: (NSImage *)image {
	
	NSData *imageData = [image TIFFRepresentation];
	NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
	return [imageRep representationUsingType:NSPNGFileType properties:nil];
}

- (void) loadImage:(NSImage*)image {

//	[image setSize:NSMakeSize(10.0f, 10.0f)];
	NSData *finalData = [self dataFromImage:image];	
	[[webView mainFrame] loadData:finalData MIMEType:@"image/png" textEncodingName:nil baseURL:nil];
}
	

- (void)getColorsforImage:(NSImage *)image {//:(NSMutableArray *)theApps{

	NSData *imageData = [self dataFromImage:image];
	NSString *base64Image = [imageData base64EncodedString];
//	NSLog(@"base64: %@", base64Image);
	NSTask *php = [[NSTask alloc] init];	NSPipe *pipe = [[NSPipe alloc] init]; NSFileHandle *handle; NSString *string;
	[php setLaunchPath:@"/usr/bin/php"];
	NSString *scriptPath = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"colors.base64.php"];
	[php setArguments:[NSArray arrayWithObjects:@"-f", scriptPath, base64Image, nil]];
	[php setStandardOutput:pipe];		handle=[pipe fileHandleForReading];		[php launch];
	string = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding]; 
//	string = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding]; 
	NSLog(@"string: %@",string);
	jsonObject = [string JSONValue];
	NSLog(@"jsonObject: %@  a member of class: %@",jsonObject, [jsonObject className]);
	
//	[anObject writeToFile:@"/Users/localadmin/Desktop/colors.plist"];
//	id jsonObject = [jsonParser objectWithUTF8String: length:<#(NSUInteger)#>:taskData];
//	if ([jsonObject isKindOfClass:[NSDictionary class]]) {
//		NSArray *jsonA = [NSArray arrayWithArray:jsonObject];
//		NSLog(@"dictioary: %@.  is class %@", colorDict, [colorDict className]);
	// treat as a dictionary, or reassign to a dictionary ivar
//	} else if ([jsonObject isKindOfClass:[NSArray class]]) {
//		NSDictionary *jsonD = [NSDictionary dictionaryWithDictionary:jsonObject];
//		NSLog(@"Array: %@", jsonD);
//	} else {
//		NSLog(@"Object = %@", anObject);
//	}
	// treat as an array or reassign to an array ivar.
	
//	NSArray *chunks = [string componentsSeparatedByString: @";"];
//	if ( chunks != nil ) {
//		int length=[[chunks objectAtIndex:0] length];
//		if ( length == 6 ) {
//			NSLog(@"PHP Says:  Colors for app%@ are %@", [app valueForKey:@"app"], chunks);
//		}
//	}

}

//	[webView loadData:imageData MIMEType:imageMIMEType textEncodingName:nil baseURL:nil];

//	NSString *HTMLData = @"
//	<h1>Hello this is a test</h1>
//	<img src="sample.jpg" alt="" width="100" height="100" />";
//	[webView loadHTMLString:HTMLData baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",imagePath]]];

//	 loadHTMLString: [NSString stringWithContentsOfFile:@"/Users/malcom/Desktop/prova.html"] baseURL:nil];
	
//	NSImage *image = [[NSImage alloc] initWithContentsOfFile: @"/Users/malcom/Desktop/ip.png"];
//	WebResource	*res = [[[WebResource alloc] initWithData: [image TIFFRepresentation] 
//													  URL: [NSURL URLWithString: @"mytest:///Users/malcom/Desktop/ip.png"]
//												 MIMEType:@"image/tiff" 
//										 textEncodingName: nil  frameName:nil] autorelease];
//	
//	
//	DOMHTMLImageElement *img = (DOMHTMLImageElement*)[[[view mainFrame] DOMDocument] createElement:@"img"];
//	[img setSrc: @"mytest:///Users/malcom/Desktop/ip.png"];
//	[[[view mainFrame] dataSource] addSubresource: res];

//	[webView reload: nil];
//}
@end
