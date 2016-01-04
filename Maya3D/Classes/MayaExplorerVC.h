//
//  TzViewController.h
//  Maya3D
//
//  Created by Roger on 01/11/08.
//  Copyright Studio Avante 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"
#import "TzCalendar.h"
#import "AvanteTextLabel.h"
#import "AvanteTextField.h"
#import "AvanteMayaNum.h"
#import "AvanteRollerVertical.h"

// roger: <UITextFieldDelegate> para mandar nos textFields
@interface MayaExplorerVC : UIViewController {
	UIScrollView *contentView;
	// Julian Day Number
	AvanteTextField *julianField;
	// Data Gregoriana
	AvanteTextField *gregField;
	AvanteTextLabel *gregNameField;
	AvanteTextLabel *gregWeekdayField;
	// Maya Long Count
	AvanteTextField *abskinField;
	AvanteTextField *baktunField;
	AvanteTextField *katunField;
	AvanteTextField *tunField;
	AvanteTextField *uinalField;
	AvanteTextField *kinField;
	// Maya Tzolkin
	AvanteTextField *tzkinField;
	AvanteTextField *tznumberField;
	AvanteTextField *tzdayField;
	AvanteTextLabel *tzdayNameField;
	UIImageView *tznumberImage;
	UIImageView *tzdayImage;
	// Maya Haab
	AvanteTextField *haabkinField;
	AvanteTextField *haabdayField;
	AvanteTextField *haabuinalField;
	AvanteTextLabel *haabuinalNameField;
	UIImageView *haabdayImage;
	UIImageView *haabuinalImage;
	// Maya CalendarRound
	AvanteTextField *crField;
	AvanteTextField *crkinField;
	// Dreamspell Tzolkin
	AvanteTextField *tzkinField2;
	AvanteTextField *tznumberField2;
	AvanteTextField *tzdayField2;
	AvanteTextLabel *tzdayNameField2;
	UIImageView *tznumberImage2;
	UIImageView *tzdayImage2;
	// Dreamspell 13-Moon
	AvanteTextField *moonkinField;
	AvanteTextField *moondayField;
	AvanteTextField *moonmoonField;
	AvanteTextLabel *moonmoonNameField;
	UIImageView *plasmaImage;
	UIImageView *moonFaseImage;
	UIImageView *moonFaseMaya;
	AvanteTextLabel *plamaLabel;
	AvanteTextLabel *moonFaseLabel;
	// UI
	UISegmentedControl *mayaMoonSelector;
	UIView *mayaView;
	UIView *dreamspellView;
	AvanteRollerVertical *roller;
    
}

- (void)createContentView;
- (void)updateUI;
// Estes metodos vao aparecer no Interface Builder para ligar no botao
- (IBAction)julianAdd:(id)sender;
- (IBAction)julianSub:(id)sender;
- (IBAction)pickGregorian:(id)sender;
- (IBAction)pickJulian:(id)sender;
- (IBAction)pickLongCount:(id)sender;
// Actions
- (void)switchViewMode:(id)sender;
- (IBAction)goSettings:(id)sender;
- (IBAction)goToday:(id)sender;
- (IBAction)addDate:(id)sender;
// Info Actions
- (IBAction)infoGreg:(id)sender;
- (IBAction)infoJulian:(id)sender;
- (IBAction)infoLongCount:(id)sender;
- (IBAction)infoTzolkin:(id)sender;
- (IBAction)infoHaab:(id)sender;
- (IBAction)infoCalendarRound:(id)sender;
- (IBAction)infoMoon:(id)sender;
// Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)hemisphere;

@end
