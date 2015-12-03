//
//  CustomPickerView.m
//  Maya3D
//
//  Created by Roger on 12/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "CustomPickerView.h"

//#define MAIN_FONT_SIZE 18
//#define MIN_MAIN_FONT_SIZE 16
#define MAIN_FONT_SIZE 14
#define MIN_MAIN_FONT_SIZE 14

@implementation CustomPickerView

@synthesize title;
@synthesize highlighted;

- (id)init:(BOOL)h
{
	if (self = [super initWithFrame:CGRectZero])
	{
		self.frame = CGRectMake(0.0, 0.0, 280.0, 30.0);	// we know the frame size
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];	// make the background transparent
		self.highlighted = h;
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	CGFloat yCoord = 0.0, xCoord = 0.0;
	CGPoint point;

	//AvLog(@"VIEW DRAW [%s]", [self.title UTF8String]);

	if (self.title)
	{
		// Set color - SHADOW
		[[UIColor lightGrayColor] set];
		// Set coords
		xCoord += 10.0;
		yCoord = (self.bounds.size.height - MAIN_FONT_SIZE) / 2;
		point = CGPointMake(xCoord, yCoord);
		// Draw text
		[self.title drawAtPoint:point
		 forWidth:self.bounds.size.width
		 withFont:[UIFont systemFontOfSize:MAIN_FONT_SIZE]
		 minFontSize:MIN_MAIN_FONT_SIZE
		 actualFontSize:NULL
		 lineBreakMode:UILineBreakModeTailTruncation
		 baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

		// Set color
		if (self.highlighted)
			[[UIColor blueColor] set];
		else
			[[UIColor blackColor] set];
		// Set coords
		//xCoord -= 1;
		yCoord -= 1;
		point = CGPointMake(xCoord, yCoord);
		// Draw text
		[self.title drawAtPoint:point
		 forWidth:self.bounds.size.width
		 withFont:[UIFont systemFontOfSize:MAIN_FONT_SIZE]
		 minFontSize:MIN_MAIN_FONT_SIZE
		 actualFontSize:NULL
		 lineBreakMode:UILineBreakModeTailTruncation
		 baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	}
}

- (void)dealloc
{
	[super dealloc];
}


@end
