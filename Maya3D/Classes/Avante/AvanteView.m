//
//  AvanteView.m
//  Maya3D
//
//  Created by Roger on 05/04/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "AvanteView.h"


@implementation AvanteView

@synthesize heightFixed;
@synthesize heightVar;

- (void)dealloc {
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    if ( (self = [super initWithFrame:frame]) == nil)
		return nil;
    return self;
}

/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)addSubviewFixed:(UIView *)view
{
	heightFixed += view.frame.size.height;
	[super addSubview:view];
}
- (void)addSubviewVar:(UIView *)view
{
	heightVar += view.frame.size.height;
	[super addSubview:view];
}

// GETTERS

- (CGFloat)getHeightSum
{
	return (heightFixed + heightVar);
}

@end
