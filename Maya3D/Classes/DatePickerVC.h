//
//  DatePickerVC.h
//  Maya3D
//
//  Created by Roger on 27/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AvanteTextLabel;
@class AvantePicker;
@class AvantePickerImage;
@class TzCalendar;

@interface DatePickerVC : UIViewController {
	int type;
	int compDay;
	int compMonth;
	int secs;
	AvanteTextLabel *descLabel;
	AvantePicker *currentPicker;
	AvantePicker *gregPicker;
	AvantePicker *julianPicker;
	AvantePicker *longCountPicker;
	AvantePickerImage *longCountMayaPicker;
	NSTimer *timer1,*timer2,*timer3,*timer4,*timer5;
}

// init
- (id)initWithType:(int)t;
- (void)initGregPicker;
- (void)initJulianPicker;
- (void)initLongCountPicker;
- (void)initLongCountMayaPicker;
// date
- (void)goToDate:(TzCalendar*)cal;
// interaction
- (void)didChangeYear;
- (void)didChangeYear:(int)year;
- (void)didChangeCentury;
- (void)didChangeAnything;
- (void)updateLabel:(NSTimer*)theTimer;
- (void)updateLabel;
// actions
- (void)actionToday:(id)sender;
- (void)actionSelect:(id)sender;
- (IBAction)infoGreg:(id)sender;

@end
