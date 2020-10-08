/*
     File: DraggableItemView.m 
 Abstract: Part of the DraggableItemView project referenced in the 
 View Programming Guide for Cocoa documentation.
  
  Version: 1.1 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "DraggableItemView.h"


static int sBackgroundColorIndex = 0;

static bool sFrame1Small = false;
static bool sFrame2Small = false;
static bool sDrawView2AltColor = false;

@implementation DraggableItemView

// -----------------------------------
// Initialize the View
// -----------------------------------

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		switch (sBackgroundColorIndex) {
		case 0: [self setBackgroundColor:[NSColor redColor]]; break;
		case 1: [self setBackgroundColor:[NSColor greenColor]]; break;
		case 2: [self setBackgroundColor:[NSColor blueColor]]; break;
		}
		sBackgroundColorIndex += 1;
		if (sBackgroundColorIndex == 3)
			sBackgroundColorIndex = 0;
    }
    return self;
}

// -----------------------------------
// Release the View
// -----------------------------------

- (void)dealloc
{
    [backgroundColor release];
    backgroundColor=nil;
    
    // call super
    [super dealloc];  
}

// -----------------------------------
// Draw the View Content
// -----------------------------------

- (void)drawRect:(NSRect)rect
{
	const NSRect *rects;
	NSInteger count;
	[self getRectsBeingDrawn:&rects count:&count];

	NSLog(@"Drawing %@ - Rects = %d\n", [self identifier], (int) count);
	for (NSInteger i=0; i<count; i++) {
		NSLog(@"-- %d, %d (%d x %d)\n", (int) rects[i].origin.x, (int) rects[i].origin.y, (int) rects[i].size.width, (int) rects[i].size.height);
	}
	// erase the background by drawing white
	if (sDrawView2AltColor && [[self identifier] isEqualToString:@"view_2"]) {
	
		sDrawView2AltColor = false;
		[[NSColor yellowColor] set];
		[NSBezierPath fillRect:rect];
	
	} else {
		[[self backgroundColor] set];
		[NSBezierPath fillRect:rect];
	}
}

- (BOOL)isOpaque
{
	NSLog(@"%@ - returning isOpauqe YES\n", [self identifier]);
    return YES;
}


// -----------------------------------
// Hit test the item
// -----------------------------------

- (BOOL)isPointInItem:(NSPoint)testPoint
{
    BOOL itemHit = NO;
    
    // yes, lets further refine the testing
    if (itemHit) {
	
    }
   
    return itemHit;
}

// -----------------------------------
// First Responder Methods
// -----------------------------------

- (BOOL)acceptsFirstResponder
{
	return [[self identifier] isEqualToString:@"main_view"];
}

// -----------------------------------
// Handle KeyDown Events 
// -----------------------------------

- (void)keyDown:(NSEvent *)event
{
    BOOL handled = NO;
    NSString  *characters;
    
    // get the pressed key
    characters = [event charactersIgnoringModifiers];
    
    if (!handled)
		[super keyDown:event];
    
}

-(void) getViews:(NSView**)outView1 view2:(NSView**)outView2
{
	*outView1 = NULL;
	*outView2 = NULL;
	
	NSArray* svArray = [self subviews];
	if ([svArray count] == 1) {
		*outView1 = [svArray objectAtIndex:0];
		if (*outView1 != NULL) {
			svArray = [*outView1 subviews];
			if ([svArray count] == 1) {
				*outView2  = [svArray objectAtIndex:0];
			}
		}
	}
}

// -----------------------------------
// Handle NSResponder Actions 
// -----------------------------------

-(IBAction)toggleInnerView1Size:(id)sender
{
	NSView* view1 = NULL;
	NSView* view2 = NULL;
	[self getViews:&view1 view2:&view2];
	
	if (view1 != NULL) {
		NSRect frame = [view1 frame];
		if (sFrame1Small) {
			frame.size.height += 20;
			frame.origin.y -= 20;
		} else {
			frame.size.height -= 20;
			frame.origin.y += 20;
		}
		sFrame1Small = !sFrame1Small;
		[view1 setFrame:frame];
	}
}

-(IBAction)toggleInnerView2Size:(id)sender
{
	NSView* view1 = NULL;
	NSView* view2 = NULL;
	[self getViews:&view1 view2:&view2];
	
	if (view2 != NULL) {
		NSRect frame = [view2 frame];
		if (sFrame2Small) {
				frame.size.height += 20;
				frame.origin.y -= 20;
			} else {
				frame.size.height -= 20;
				frame.origin.y += 20;
			}
		sFrame2Small = !sFrame2Small;
		[view2 setFrame:frame];
	}
}

-(IBAction)invalidateAreaView2:(id)sender
{
	NSView* view1 = NULL;
	NSView* view2 = NULL;
	[self getViews:&view1 view2:&view2];
	
	NSLog(@"******* Inner View 2: Set Needs Display in Rect (10,10 --  100x10)");
	sDrawView2AltColor = true;
	[view2 setNeedsDisplayInRect:NSMakeRect(10, 10, 100, 10)];
}

-(IBAction)invalidateAreaView1:(id)sender
{
	NSView* view1 = NULL;
	NSView* view2 = NULL;
	[self getViews:&view1 view2:&view2];
	
	NSLog(@"******* Inner View 1: Set Needs Display in Rect (40,40 --  100x10)");
	[view1 setNeedsDisplayInRect:NSMakeRect(40, 40, 100, 10)];
}

// -----------------------------------
//  Accessor Methods
// -----------------------------------

- (void)setBackgroundColor:(NSColor *)aColor
{
	if (![backgroundColor isEqual:aColor]) {
        [backgroundColor release];
        backgroundColor = [aColor retain];
    }
}


- (NSColor *)backgroundColor
{
    return [[backgroundColor retain] autorelease];
}



@end
