//
//  ClockVC.h
//  Maya3D
//
//  Created by Roger on 03/12/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"
#import "TzClock.h"
#import "AvanteTextLabel.h"
#import "AvantePicker.h"
#import "AvantePickerImage.h"
#import "TzCalendar.h"


@interface ClockVC : UIViewController <UIPickerViewDelegate> {
	AvantePicker *clockPicker;
	UIBarButtonItem *pauseButton;
	UIBarButtonItem *playButton;
	UIBarButtonItem *playGearButton;
	// Speed label
	NSString *defaultSpeedName;		// default speed text
}

- (id)init;
- (void)setupClockPicker;
- (void)updateClockPicker:(BOOL)animated;
// Actions
- (IBAction)actionReset:(id)sender;
- (IBAction)actionPause:(id)sender;
- (IBAction)actionPlay:(id)sender;
- (IBAction)actionPlayGear:(id)sender;
- (IBAction)goSpeedSettings:(id)sender;
- (IBAction)goInfo:(id)sender;

@end
