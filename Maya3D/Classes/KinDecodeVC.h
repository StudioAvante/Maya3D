//
//  KinDecodeVC.h
//  Maya3D
//
//  Created by Roger on 19/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TzCalTzolkinMoon;
@class AvanteKinView;

@interface KinDecodeVC : UIViewController
{
	AvanteKinView *kinView;
}

- (id)initWithType:(int)t tz:(TzCalTzolkinMoon*)tz destinyKin:(int)dkin;
- (IBAction)share:(id)sender;
// Alert Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)option;

@end
