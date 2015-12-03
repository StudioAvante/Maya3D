//
//  MayaOracleVC.h
//  Maya3D
//
//  Created by Roger on 12/12/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"
#import "TzCalendar.h"

@class AvanteRollerVertical;
@class AvanteTextLabel;
@class AvanteView;
@class AvanteViewStack;
@class AvanteKinView;
@class AvanteKinButton;

@interface MayaOracleVC : UIViewController {
	// GENERAL UI
	BOOL fullScreen;
	CGFloat initY;
	CGFloat actualViewSize;
	CGFloat contentViewSize;
	UISegmentedControl *mayaMoonSelector;
	AvanteRollerVertical *roller;
	// MAYA VIEWS
	UIScrollView *mayaContentView;
	AvanteViewStack *mayaStack;
	AvanteView *mayaView1;
	AvanteView *mayaView2;
	AvanteView *mayaView3;
	// MAYA UI - Gregorian
	AvanteTextLabel *mayaGregName;
	// MAYA UI - Year
	UIImageView *mayaYearNum;
	UIImageView *mayaYearGlyph;
	AvanteTextLabel *mayaYearName;
	AvanteTextLabel *mayaYearDesc;
	// MAYA UI - Month
	UIImageView *mayaHaabNum;
	UIImageView *mayaHaabGlyph;
	AvanteTextLabel *mayaHaabName;
	AvanteTextLabel *mayaHaabDesc;
	// MAYA UI - Day
	UIImageView *mayaTzolkinNum;
	UIImageView *mayaTzolkinGlyph;
	UIImageView *mayaTzolkinNews;
	UIImageView *mayaTzolkinThumb;
	AvanteTextLabel *mayaTzolkinName;
	AvanteTextLabel *mayaTzolkinDesc;
	AvanteTextLabel *mayaTzolkinAnimal;
	AvanteTextLabel *mayaTzolkinEnergy;
	AvanteTextLabel *mayaTzolkinElement;
	AvanteTextLabel *mayaTzolkinPersonality;
	AvanteTextLabel *mayaTzolkinGoodTo1;
	AvanteTextLabel *mayaTzolkinGoodTo2;
	AvanteTextLabel *mayaTzolkinGoodTo3;
	AvanteTextLabel *mayaTzolkinGoodTo4;
	
	// DREAMSPELL VIEWS
	UIScrollView *dreamspellContentView;
	AvanteViewStack *dreamspellStack;
	AvanteView *dreamspellView1;
	AvanteView *dreamspellView2;
	AvanteView *dreamspellView4;
	AvanteKinView *kinView;
	// DREAMSPELL UI - Gregorian
	AvanteTextLabel *dreamspellGregName;
	// DREAMSPELL UI - Year
	UIImageView *dreamspellYearNum;
	UIImageView *dreamspellYearGlyph;
	AvanteTextLabel *dreamspellYearName;
	AvanteTextLabel *dreamspellYearPeriod;
	// DREAMSPELL UI - month
	UIImageView *dreamspellMonthNum;
	UIImageView *dreamspellMoonFase;
	UIImageView *dreamspellPlasma;
	AvanteTextLabel *dreamspellMonthLabel;
	AvanteTextLabel *dreamspellMonthName;
	AvanteTextLabel *dreamspellMonthDayName;
	AvanteTextLabel *dreamspellPlasmaName;
	AvanteTextLabel *dreamspellMonthQuestion;
	//AvanteTextLabel *dreamspellMonthPower;
	//AvanteTextLabel *dreamspellMonthAction;
	//AvanteTextLabel *dreamspellPurpose;
	// KIN UI - Affirmation
	AvanteTextLabel *affirmation1;
	// KIN UI - Oracle
	BOOL isDecoding;	// Pushed Oracle Decode view
	UIImageView *oracleGuideNum;
	UIImageView *oracleAntipodeNum;
	UIImageView *oracleDestinyNum;
	UIImageView *oracleAnalogNum;
	UIImageView *oracleOccultNum;
	AvanteKinButton *oracleGuideGlyph;
	AvanteKinButton *oracleAntipodeGlyph;
	UIImageView *oracleDestinyGlyph;
	AvanteKinButton *oracleAnalogGlyph;
	AvanteKinButton *oracleOccultGlyph;
}

// Properties
@property (nonatomic) CGFloat initY;

- (id)initFullScreen:(CGFloat)y;
- (void)scrollToY:(CGFloat)y animated:(BOOL)animated;
- (void)scrollToTop;
- (void)scrollToKin;
- (CGFloat)currentScrollOffset;
// Draw!
- (void)createContentViewMaya;
- (void)createContentViewDreamspell;
// update!
- (void)updateOracle;
- (void)updateOracleMaya;
- (void)updateOracleDreamspell;
// actions
- (void)switchViewMode:(id)sender;
- (IBAction)julianAdd:(id)sender;
- (IBAction)julianSub:(id)sender;
- (IBAction)goFullScreen:(id)sender;
- (IBAction)goInfo:(id)sender;
- (void)goDecode:(AvanteKinButton*)but;
- (IBAction)share:(id)sender;
- (void)shareScreenshotTo:(NSInteger)shareOption withText:(NSString*)text withBody:(NSString*)body;
// Alert Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)option;

@end
