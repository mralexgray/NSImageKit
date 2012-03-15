//
//  MyPieChartView.h
//  CustomNSView
//
//  Created by Tim Isted on 27/11/2008.
//  Copyright Tim Isted © 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyPieChartView : NSView 
{
	NSArray *_segmentNamesArray;
	NSArray *_segmentValuesArray;
	
	NSMutableArray *_segmentPathsArray;
	NSMutableArray *_segmentTextsArray;
	
	NSIndexSet *_selectionIndexes;
	
	float _rotationAmount;
}

- (NSArray *)segmentNamesArray;
- (void)setSegmentNamesArray:(NSArray *)newArray;

- (NSArray *)segmentValuesArray;
- (void)setSegmentValuesArray:(NSArray *)newArray;

- (NSArray *)segmentPathsArray;
- (NSArray *)segmentTextsArray;
- (void)generateDrawingInformation;

- (NSColor *)randomColor;
- (NSColor *)colorForIndex:(unsigned)index;

- (NSIndexSet *)selectionIndexes;
- (void)setSelectionIndexes:(NSIndexSet *)newIndexes;

- (int)objectIndexForPoint:(NSPoint)thePoint;

- (void)setRotationAmount:(NSNumber *)value;
- (NSNumber *)rotationAmount;

@end