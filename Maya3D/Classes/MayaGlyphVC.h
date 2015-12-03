//
//  MayaGlyphVC.h
//  Maya3D
//
//  Created by Roger on 12/12/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"
#import "AvanteTextLabel.h"
#import "AvanteRollerVertical.h"

@class AvanteKinButton;

@interface MayaGlyphVC : UIViewController {
	// UI - IB
	UISegmentedControl *mayaMoonSelector;
	AvanteRollerVertical *roller;
	// UI - MAYA
	UIView *contentViewMaya;
	UIImageView *mayaIsigGlyph;
	UIImageView *mayaBaktunNum;
	UIImageView *mayaBaktunGlyph;
	UIImageView *mayaKatunNum;
	UIImageView *mayaKatunGlyph;
	UIImageView *mayaTunNum;
	UIImageView *mayaTunGlyph;
	UIImageView *mayaUinalNum;
	UIImageView *mayaUinalGlyph;
	UIImageView *mayaKinNum;
	UIImageView *mayaKinGlyph;
	UIImageView *mayaTzolkinNum;
	UIImageView *mayaTzolkinGlyph;
	UIImageView *mayaHaabNum;
	UIImageView *mayaHaabGlyph;
	UIImageView *mayaLordGlyph;
	AvanteTextLabel *mayaGregName;
	AvanteTextLabel *mayaBaktunLabel;
	AvanteTextLabel *mayaKatunLabel;
	AvanteTextLabel *mayaTunLabel;
	AvanteTextLabel *mayaUinalLabel;
	AvanteTextLabel *mayaKinLabel;
	AvanteTextLabel *mayaTzolkinLabel;
	AvanteTextLabel *mayaHaabLabel;
	AvanteTextLabel *mayaLordLabel;
	// UI - DREAMSPELL
	UIView *contentViewDreamspell;
	AvanteTextLabel *kinText1;
	AvanteTextLabel *kinText2;
	AvanteTextLabel *kinText3;
	AvanteTextLabel *dreamspellGregName;
	UIImageView *destinySealNum;
	AvanteKinButton *destinySealGlyph;
	UIImageView *portalGlyph;
	UIImageView *plasmaGlyph;
	AvanteTextLabel *plasmaName;
	AvanteTextLabel *plasmaText;
	AvanteTextLabel *dootText;
	AvanteTextLabel *chakraName;
	AvanteKinButton *oracleGuideGlyph;
	AvanteKinButton *oracleAntipodeGlyph;
	AvanteKinButton *oracleDestinyGlyph;
	AvanteKinButton *oracleAnalogGlyph;
	AvanteKinButton *oracleOccultGlyph;
	AvanteTextLabel *affirmation1;
}

- (void)createContentMaya;
- (void)createContentDreamspell;
- (void)updateGlyph;
- (void)updateMayaGlyph;
- (void)updateDreamspellGlyph;
- (void)switchViewMode:(id)sender;
- (IBAction)goInfo:(id)sender;
- (IBAction)julianAdd:(id)sender;
- (IBAction)julianSub:(id)sender;
- (void)goDecode:(AvanteKinButton*)but;
- (IBAction)share:(id)sender;
- (void)shareScreenshotTo:(NSInteger)shareOption withText:(NSString*)text withBody:(NSString*)body;
// Alert / Action Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)option;
@end
