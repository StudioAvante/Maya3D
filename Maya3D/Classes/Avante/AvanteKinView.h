//
//  AvanteKinView.h
//  Maya3D
//
//  Created by Roger on 08/04/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AvanteView.h"

// GENERIC
#define SPACER					2.0
#define SPACER_GAP				6.0
//#define ACTUAL_VIEW_HEIGHT		(kActiveLessNavTab - kRollerVerticalHeight)
#define FONT_SIZE_NAME			18.0
#define FONT_SIZE_TEXT			14.0
#define FONT_SIZE_AFFIRM		12.0
#define FONT_SIZE_HELP			13.0
#define FONT_SIZE_LABEL			13.0

// MAYA
#define GLYPH_SIZE				60.0
#define GLYPH_SIZE_MED			50.0
#define GLYPH_SIZE_SMALL		40.0
#define GLYPH_SIZE_NUM			30.0
#define GLYPH_SIZE_NUM_MED		25.0
#define GLYPH_SIZE_NUM_SMALL	20.0
#define THUMB_SIZE				28.0
#define NEWS_SIZE				80.0

// DREAMSPELL
#define TONE_SIZE				40.0
#define TONE_GAP				(40.0-24.0)
#define SEAL_SIZE				40.0
#define PLASMA_SIZE				28.0
#define PORTAL_SIZE				28.0
#define MOON_FASE_SIZE			40.0
#define ORACLE_SIZE				60.0



@class AvanteTextLabel;
@class AvanteViewStack;
@class AvanteKinButton;
@class TzCalTzolkinMoon;

@interface AvanteKinView : AvanteView {
	// KIN VIEWS
	AvanteViewStack *kinStack;
	AvanteView *kinView1;
	AvanteView *kinView2;
	AvanteView *kinView3;
	int destinyKin;
	// KIN UI - Kin
	UIImageView *dreamspellTzolkinNum;
	UIImageView *dreamspellTzolkinNum2;
	UIImageView *dreamspellTzolkinGlyph;
	UIImageView *dreamspellTzolkinGlyph2;
	UIImageView *dreamspellTzolkinNews;
	AvanteTextLabel *dreamspellTzolkinKin;
	AvanteTextLabel *dreamspellTzolkinNumName;
	AvanteTextLabel *dreamspellTzolkinNumDesc;
	AvanteTextLabel *dreamspellTzolkinGlyphLabel;
	AvanteTextLabel *dreamspellTzolkinGlyphName;
	AvanteTextLabel *dreamspellTzolkinGlyphFrase;
	AvanteTextLabel *dreamspellTzolkinGlyphTags;
	AvanteTextLabel *dreamspellTzolkinGlyphDesc;
	AvanteTextLabel *dreamspellTzolkinName;
	AvanteTextLabel *dreamspellTzolkinColor;
	AvanteTextLabel *dreamspellColorDesc;
	AvanteTextLabel *dreamspellColorTags;
	AvanteTextLabel *dreamspellColorPurpose;
	AvanteTextLabel *dreamspellColorElement;
}

- (id)initWithFrame:(CGRect)frame destinyKin:(int)dkin;
- (CGFloat)setupView;
- (CGFloat)setupView:(int)kinType;
- (void)updateView:(TzCalTzolkinMoon*)tzolkin;

@end
