//
//  MyPieChartView.m
//  CustomNSView
//
//  Created by Tim Isted on 27/11/2008.
//  Copyright Tim Isted © 2008. All rights reserved.
//
//  If this is useful to you, please let me know.
//  All acknowledgements encouraged and gratefully received!
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "ColorChartView.h"


@implementation ColorChartView

#pragma mark Initialization and Destruction

+ (void)initialize
{
	[self exposeBinding:@"segmentNamesArray"];
	[self exposeBinding:@"segmentValuesArray"];
	[self exposeBinding:@"selectionIndexes"];
	[self exposeBinding:@"rotationAmount"];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
        // Initialization code here.
    }
    return self;
}

- (void)dealloc
{
//	[_segmentNamesArray release];
//	[_segmentValuesArray release];
	
//	if( _segmentPathsArray )
//		[_segmentPathsArray release];
	
//	if( _segmentTextsArray )
//		[_segmentTextsArray release];
	
//	[super dealloc];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	[[NSColor whiteColor] set]; // white background
	NSRectFill([self bounds]);
	
	if( [self inLiveResize] )
	{
		[self generateDrawingInformation];
	}
	
	NSArray *pathsArray = [self segmentPathsArray];
	unsigned count;
	for( count = 0; count < [pathsArray count]; count++ )
	{
		NSBezierPath *eachPath = [pathsArray objectAtIndex:count];
		
		// fill the path with the drawing color for this index unless it's selected
		if( [[self selectionIndexes] containsIndex:count] )
			[[NSColor blueColor] set];
		else
			[[self colorForIndex:count] set];
		
		[eachPath fill];
		
		// draw a black border around it
		[[NSColor blackColor] set];
		[eachPath stroke];
	}
	
	NSArray *textsArray = [self segmentTextsArray];
	
	for( count = 0; count < [textsArray count]; count++ )
	{
		NSDictionary *eachTextDictionary = [textsArray objectAtIndex:count];
		NSPoint textPoint = NSMakePoint( [[eachTextDictionary valueForKey:@"textPointX"] floatValue], [[eachTextDictionary valueForKey:@"textPointY"] floatValue] );
		
		NSDictionary *textAttributes = [eachTextDictionary valueForKey:@"textAttributes"];
		
		NSString *text = [eachTextDictionary valueForKey:@"text"];
		[text drawAtPoint:textPoint withAttributes:textAttributes];
	}
}

- (NSColor *)randomColor
{
	float red = (random()%1000)/1000.0;
	float green = (random()%1000)/1000.0;
	float blue = (random()%1000)/1000.0;
	float alpha = (random()%1000)/1000.0;
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}

- (NSColor *)colorForIndex:(unsigned)index
{
	static NSMutableArray *colorsArray = nil;
	
	if( colorsArray == nil )
	{
		colorsArray = [[NSMutableArray alloc] init];
	}
	
	if( index >= [colorsArray count] )
	{
		unsigned currentNum = 0;
		for( currentNum = [colorsArray count]; currentNum <= index; currentNum++ )
		{
			[colorsArray addObject:[self randomColor]];
		}
	}
	
	return [colorsArray objectAtIndex:index];
}

- (void)generateDrawingInformation
{
	// Keep pointers to the segmentValuesArray and segmentNamesArray
	NSArray *cachedSegmentValuesArray = [self segmentValuesArray];
	NSArray *cachedSegmentNamesArray = [self segmentKeysArray];
	
	// Get rid of any existing Paths Array
//	if( _segmentPathsArray )
//	{
//		[_segmentPathsArray release];
//		_segmentPathsArray = nil;
//	}
//	
//	// Get rid of any existing Texts Array
//	if( _segmentTextsArray )
//	{
//		[_segmentTextsArray release];
//		_segmentTextsArray = nil;
//	}
	
	// If there aren't any values to display, we can exit now
	if( [cachedSegmentValuesArray count] < 1 )
		return;
	
	// Get the sum of the amounts and exit if it is zero
	float sumOfAmounts = 0;
	for( NSNumber *eachAmountToSum in cachedSegmentValuesArray )
		sumOfAmounts += [eachAmountToSum floatValue];
	
	if( sumOfAmounts == 0 )
		return;
	
	_segmentPathsArray = [[NSMutableArray alloc] initWithCapacity:[cachedSegmentValuesArray count]];
	_segmentTextsArray = [[NSMutableArray alloc] initWithCapacity:[cachedSegmentValuesArray count]];
	
	NSIndexSet *selectionIndexes = [self selectionIndexes];
	BOOL shouldOffsetSelectedSegment = ([selectionIndexes count] > 0) ? YES : NO;
	
#define PADDINGAROUNDGRAPH 20.0
#define TEXTPADDING 5.0
#define SELECTEDSEGMENTOFFSET 5.0
	
	NSRect viewBounds = [self bounds];
	NSRect graphRect = NSInsetRect(viewBounds, PADDINGAROUNDGRAPH, PADDINGAROUNDGRAPH);
	
	// Make the graphRect square and centred
	if( graphRect.size.width > graphRect.size.height )
	{
		double sizeDifference = graphRect.size.width - graphRect.size.height;
		graphRect.size.width = graphRect.size.height;
		graphRect.origin.x += (sizeDifference / 2);
	}
	
	if( graphRect.size.height > graphRect.size.width )
	{
		double sizeDifference = graphRect.size.height - graphRect.size.width;
		graphRect.size.height = graphRect.size.width;
		graphRect.origin.y += (sizeDifference / 2);
	}
	
	// get NSRects for the different quarters of the pie-chart
	NSRect topLeftRect, topRightRect;
	NSDivideRect(viewBounds, &topLeftRect, &topRightRect, (viewBounds.size.width / 2), NSMinXEdge );
	NSRect bottomLeftRect, bottomRightRect;
	NSDivideRect(topLeftRect, &topLeftRect, &bottomLeftRect, (viewBounds.size.height / 2), NSMinYEdge );
	NSDivideRect(topRightRect, &topRightRect, &bottomRightRect, (viewBounds.size.height / 2), NSMinYEdge );
	
	// Calculate how big a 'unit' is
	float unitSize = (360.0 / sumOfAmounts);
	
	if( unitSize > 360 )
		unitSize = 360;
	
	float radius = graphRect.size.width / 2;
	
	NSPoint midPoint = NSMakePoint( NSMidX(graphRect), NSMidY(graphRect) );
	
	// Set the text attributes to be used for each textual display
	NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSColor whiteColor], NSBackgroundColorAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:12], NSFontAttributeName, nil];
	
	// cycle through the segmentValues and create the bezier paths
	// Also add the text details (note we expect the texts' indexes to tie up with the values' indexes)
	float currentDegree = [[self rotationAmount] floatValue];
	unsigned currentIndex;
	for( currentIndex = 0; currentIndex < [cachedSegmentValuesArray count]; currentIndex++ )
	{
		NSNumber *eachValue = [cachedSegmentValuesArray objectAtIndex:currentIndex];
		
		float startDegree = currentDegree;
		currentDegree += ([eachValue floatValue] * unitSize);
		float endDegree = currentDegree;
		float midDegree = startDegree + ((endDegree - startDegree) / 2);
		
		NSBezierPath *eachSegmentPath = [NSBezierPath bezierPath];
		[eachSegmentPath moveToPoint:midPoint];
		
		[eachSegmentPath appendBezierPathWithArcWithCenter:midPoint radius:radius startAngle:startDegree endAngle:midDegree clockwise:NO];
		
		NSPoint textPoint = [eachSegmentPath currentPoint];
		
		[eachSegmentPath appendBezierPathWithArcWithCenter:midPoint radius:radius startAngle:midDegree endAngle:endDegree clockwise:NO];
		
		[eachSegmentPath closePath]; // close path also handles the lines from the midPoint to the start and end of the arc
		[eachSegmentPath setLineWidth:2.0];
		
		// Check to see whether we should offset this segment if it's currently selected in the array controller
		if( shouldOffsetSelectedSegment && [selectionIndexes containsIndex:currentIndex] )
		{
			float differenceRatio = (SELECTEDSEGMENTOFFSET / radius) + (SELECTEDSEGMENTOFFSET / (endDegree - startDegree));
			
			float diffY = (textPoint.y - midPoint.y) * differenceRatio;
			float diffX = (textPoint.x - midPoint.x) * differenceRatio;
			
			NSAffineTransform *transform = [NSAffineTransform transform];
			
			[transform translateXBy:diffX yBy:diffY];
			[eachSegmentPath transformUsingAffineTransform: transform];
			
			textPoint = [transform transformPoint:textPoint];
		}
		
		[_segmentPathsArray addObject:eachSegmentPath];
		
		// Get the text to be displayed, if it exists, and see how big it is
		NSString *eachText = @"";
		if( [cachedSegmentNamesArray count] > currentIndex )
			eachText = [cachedSegmentNamesArray objectAtIndex:currentIndex];
		
		NSSize textSize = [eachText sizeWithAttributes:textAttributes];
		
		// Offset it by TEXTPADDING in direction suitable for whichever quarter of the view it is in
		if( NSPointInRect(textPoint, topLeftRect) )
		{
			textPoint.y -= (textSize.height + TEXTPADDING);
			textPoint.x -= (textSize.width + TEXTPADDING);
		}
		else if( NSPointInRect(textPoint, topRightRect) )
		{
			textPoint.y -= (textSize.height + TEXTPADDING);
			textPoint.x += TEXTPADDING;
		}
		else if( NSPointInRect(textPoint, bottomLeftRect) )
		{
			textPoint.y += TEXTPADDING;
			textPoint.x -= (textSize.width + TEXTPADDING);
		}
		else if( NSPointInRect(textPoint, bottomRightRect) )
		{
			textPoint.y += TEXTPADDING;
			textPoint.x += TEXTPADDING;
		}
		
		// Make sure the point isn't outside the view's bounds
		if( textPoint.x < viewBounds.origin.x )
			textPoint.x = viewBounds.origin.x;
		
		if( (textPoint.x + textSize.width) > (viewBounds.origin.x + viewBounds.size.width) )
			textPoint.x = viewBounds.origin.x + viewBounds.size.width - textSize.width;
		
		if( textPoint.y < viewBounds.origin.y )
			textPoint.y = viewBounds.origin.y;
		
		if( (textPoint.y + textSize.height) > (viewBounds.origin.y + viewBounds.size.height) )
			textPoint.y = viewBounds.origin.y + viewBounds.size.height - textSize.height;
		
		// Finally add the details as a dictionary to our segmentTextsArray.
		// We include here the textAttributes lest we decide later to e.g. color the texts the same color as the segment fill
		[_segmentTextsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:textPoint.x], @"textPointX", [NSNumber numberWithFloat:textPoint.y], @"textPointY", eachText, @"text", textAttributes, @"textAttributes", nil]];
	}
}

#pragma mark Event Handling
- (int)objectIndexForPoint:(NSPoint)thePoint
{
	NSArray *cachedPathsArray = [self segmentPathsArray];
	
	int count;
	for( count = 0; count < [cachedPathsArray count]; count++ )
	{
		NSBezierPath *eachPath = [cachedPathsArray objectAtIndex:count];
		
		if( [eachPath containsPoint:thePoint ] )
		{
			return count;
		}
	}
	
	// if control reaches here, no segment contained the point so return -1	
	return -1;
}

- (void)mouseUp:(NSEvent *)theEvent
{
	int index = [self objectIndexForPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
	
	NSMutableIndexSet *newSelectionIndexes = [[self selectionIndexes] mutableCopy];
	
	if ( [theEvent modifierFlags] & NSCommandKeyMask )
	{
		// Add or remove the clicked segment
		if ( [newSelectionIndexes containsIndex:index] )
		{
			[newSelectionIndexes removeIndex:index];
		}
		else
		{
			[newSelectionIndexes addIndex:index];
		}
	}
	else if ( [theEvent modifierFlags] & NSShiftKeyMask )
	{
		// Add range to selection
		if ([newSelectionIndexes count] == 0)
		{
			[newSelectionIndexes addIndex:index];
		}
		else
		{
			unsigned int origin = (index < [newSelectionIndexes lastIndex]) ? index :[newSelectionIndexes lastIndex];
			unsigned int length = (index < [newSelectionIndexes lastIndex]) ? [newSelectionIndexes lastIndex] - index : index - [newSelectionIndexes lastIndex];
			
			length++;
			[newSelectionIndexes addIndexesInRange:NSMakeRange(origin, length)];
		}
	}
	else // the user just clicked without modifier keys so simply select the segment
	{
		[newSelectionIndexes removeAllIndexes];
		if( index >= 0 )
			[newSelectionIndexes addIndex:index];
	}
	
	[self setSelectionIndexes:newSelectionIndexes];
//	[newSelectionIndexes release];
}

#pragma mark View Behavior Overrides

- (BOOL)isFlipped
{
	return YES;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

#pragma mark Accessors

- (NSArray *)segmentKeysArray
{
	return _segmentKeysArray;// retain];// autorelease];
}

- (void)setSegmentKeysArray:(NSArray *)newArray
{
	[self willChangeValueForKey:@"segmentKeysArray"];
//	[_segmentNamesArray release];
	_segmentKeysArray = [newArray copy];
	[self didChangeValueForKey:@"segmentKeysArray"];
	
	[self generateDrawingInformation];
	[self setNeedsDisplayInRect:[self visibleRect]];
}

- (NSArray *)segmentValuesArray
{
	return _segmentValuesArray;// retain] autorelease];
}

- (void)setSegmentValuesArray:(NSArray *)newArray
{
	[self willChangeValueForKey:@"segmentValuesArray"];
//	[_segmentValuesArray release];
	_segmentValuesArray = [newArray copy];
	[self didChangeValueForKey:@"segmentValuesArray"];
	
	[self generateDrawingInformation];
	[self setNeedsDisplayInRect:[self visibleRect]];
}

- (NSArray *)segmentPathsArray
{
	return _segmentPathsArray;
}

- (NSArray *)segmentTextsArray
{
	return _segmentTextsArray;
}

- (NSIndexSet *)selectionIndexes
{
    return _selectionIndexes;// retain] autorelease]; 
}

- (void)setSelectionIndexes:(NSIndexSet *)newIndexes
{
	if ((_selectionIndexes != newIndexes) && (![_selectionIndexes isEqualToIndexSet:newIndexes]))
	{
		[self willChangeValueForKey:@"selectionIndexes"];
//		[_selectionIndexes release];
		_selectionIndexes = [newIndexes copy];
		[self didChangeValueForKey:@"selectionIndexes"];
		
		[self generateDrawingInformation];
		[self setNeedsDisplayInRect:[self visibleRect]];
	}
}

- (NSNumber *)rotationAmount
{
	return [NSNumber numberWithFloat:_rotationAmount];
}

- (void)setRotationAmount:(NSNumber *)value
{
	if( [value floatValue] != _rotationAmount )
	{
		[self willChangeValueForKey:@"rotationAmount"];
		_rotationAmount = [value floatValue];
		[self didChangeValueForKey:@"rotationAmount"];
		
		[self generateDrawingInformation];
		[self setNeedsDisplayInRect:[self visibleRect]];
	}
}

@end
