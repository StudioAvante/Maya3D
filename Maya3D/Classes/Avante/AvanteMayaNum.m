//
//  AvanteMayaNum.m
//  Maya3D
//
//  Created by Roger on 21/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "AvanteMayaNum.h"

@implementation AvanteMayaNum


// DESTRUCTOR
- (void)dealloc
{
	[super dealloc];
}


// MY INIT
- (id)initInv:(int)n x:(CGFloat)x y:(CGFloat)y size:(CGFloat)sz
{
	// Inicializa
	inverted = TRUE;
	// OK!
	return [self init:n x:x y:y size:sz];
}
- (id)init:(int)n x:(CGFloat)x y:(CGFloat)y size:(CGFloat)sz
{
	// Inicializa
	if ((self = [super initWithFrame:CGRectMake(x, y, sz, sz)]) == nil)
		return nil;

	// config
	self.backgroundColor = [UIColor clearColor];
	size = sz;
	
	// Set internal num
	num = -1;
	[self updateWithNum:n];
	// OK!
	return self;
}

// Draw view
/*
 - (void)drawRect:(CGRect)rect {
	// draw the image and title using their draw methods
	CGPoint point = CGPointMake(0.0, 0.0);
	[self.image drawAtPoint:point];
}
*/

// Update field text
- (void)updateWithNum:(int)n
{
	// update number
	if (n == num)
		return;
	num = n;
	// Create image
	NSString *str;
	if (inverted == TRUE)
		str = [NSString stringWithFormat:@"numbig%02di.png", num];
	else if (size == IMAGE_SIZE_BIG)
		str = [NSString stringWithFormat:@"numbig%02d.png", num];
	else
		str = [NSString stringWithFormat:@"num%02d.png", num];
	self.image = [UIImage imageNamed:str];
	//AvLog(@"NEW MAYA NUM[%d] *image[%d] [%@]", num, image,str);
	// Finito!
	//[self setNeedsDisplay];
}

@end
