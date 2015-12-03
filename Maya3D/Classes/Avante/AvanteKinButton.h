//
//  AvanteKinButton.h
//  Maya3D
//
//  Created by Roger on 08/04/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TzCalTzolkinMoon;

@interface AvanteKinButton : UIImageView {
	int kinType;
	TzCalTzolkinMoon *tzolkin;
	UINavigationController *myVC;
	UIButton *button;
}

@property (nonatomic) int kinType;
@property (nonatomic, assign) TzCalTzolkinMoon *tzolkin;
@property (nonatomic, assign) UINavigationController *myVC;

- (void)tap;

@end
