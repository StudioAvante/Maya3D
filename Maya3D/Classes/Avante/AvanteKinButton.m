//
//  AvanteKinButton.m
//  Maya3D
//
//  Created by Roger on 08/04/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "AvanteKinButton.h"
#import "TzCalTzolkinMoon.h"
#import "Tzolkin.h"
#import "TzGlobal.h"
#import "KinDecodeVC.h"
#import "MayaGlyphVC.h"
#import "MayaOracleVC.h"

@implementation AvanteKinButton

@synthesize kinType;
@synthesize tzolkin;
@synthesize myVC;


- (void)dealloc {
	//[button release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
	// super init
    if ( (self = [super initWithFrame:frame]) == nil)
		return nil;

	// Enable button
	self.userInteractionEnabled = YES;
	
	// Create button
    button = [[UIButton alloc] init];//[UIButton buttonWithType:UIButtonTypeInfoLight];
	frame.origin.x = 0.0;
	frame.origin.y = 0.0;
	button.frame = frame;
	button.backgroundColor = [UIColor clearColor];
	[button setImage:nil forState:UIControlStateNormal];
	[button addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];	
	[self addSubview:button];
	
	// ok!
    return self;
}

// TOUCH!
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	AvLog(@"AvanteKinButton: TOUCH!! type[%d]",kinType);
	//[self tap];
}

// TOUCH!
- (void)tap
{
	AvLog(@"AvanteKinButton: TAP! type[%d]",kinType);
	if (kinType == ORACLE_DESTINY)
	{
		global.theTabBar.selectedIndex = TAB_ORACLE;
		//[(MayaOracleVC*)global.currentVC scrollToKin];
	}
	else
	{
		[(MayaGlyphVC*)myVC goDecode:self];
	}
}





@end
