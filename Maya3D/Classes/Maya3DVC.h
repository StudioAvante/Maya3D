//
//  Maya3DVC.h
//  Maya3D
//
//  Created by Roger on 05/11/08.
//  Copyright Studio Avante 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AvanteTextField;
@class AvanteTextLabel;
@class GLEngine;

@interface Maya3DVC : UIViewController {
	BOOL dejaVu;
	BOOL isAnimating;				// GL Is animating?
	CGRect glFrame;
    GLEngine *glView;
	UISegmentedControl *mayaMoonSelector;
	UIBarButtonItem *clockButton;
	//UIButton *clockButton;
	AvanteTextField *gregName;
	AvanteTextField *mayaName;
	// Fullscreen
	BOOL fullScreen;
	UIImageView *fullImage;
	// Gear name view
	AvanteTextField *gearName;
	CGRect nameFrame;
	CGFloat nameOffX, nameOffY;
	// Render Timer
    NSTimer *glTimer;
    NSTimer *uiTimer;
}

// IB
@property (nonatomic, assign) GLEngine *glView;


- (id)initFullScreen:(GLEngine*)glv;
- (void)updateClockIcon;
- (void)draw3DView:(NSTimer*)theTimer;
- (void)draw3DView;
- (void)drawUI:(NSTimer*)theTimer;
- (void)touchBegin:(CGPoint)pos:(NSString*)name;
- (void)touchMove:(CGPoint)pos:(NSString*)name;
- (void)touchEnd;
// actions
- (IBAction)goSettings:(id)sender;
- (IBAction)goClock:(id)sender;
- (IBAction)goInfo:(id)sender;
- (IBAction)goFullScreen:(id)sender;
- (IBAction)pickGregorian:(id)sender;
// SCREENSHOT
- (UIImage*)glToUIImage;
- (IBAction)saveScreenshot:(id)sender;

@end
