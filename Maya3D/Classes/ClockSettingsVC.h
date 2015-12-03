//
//  ClockSettingsVC.h
//  Maya3D
//
//  Created by Roger on 19/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"
#import "TzCalendar.h"
#import "TzClock.h"
#import "AvantePicker.h"
#import "AvantePickerImage.h"


@interface ClockSettingsVC : UIViewController
{
	AvantePicker	  *speedPicker;
	BOOL clockWasPlaying;
}

- (id)init;
- (void)setupSpeedPicker;
- (IBAction)actionDone:(id)sender;
- (void)setPickersToSpeed:(AvantePicker*)picker;

@end
