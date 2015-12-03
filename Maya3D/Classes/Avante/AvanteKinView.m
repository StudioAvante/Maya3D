//
//  AvanteKinView.m
//  Maya3D
//
//  Created by Roger on 08/04/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "AvanteKinView.h"
#import "TzGlobal.h"
#import "TzCalendar.h"
#import "AvanteTextLabel.h"
#import "AvanteViewStack.h"
#import "AvanteKinButton.h"


@implementation AvanteKinView

- (void)dealloc {
	// Stack
	[kinStack release];
	// Dreamspell Views
	[kinView1 removeFromSuperview];
	[kinView2 removeFromSuperview];
 	[kinView3 removeFromSuperview];
	// super
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame destinyKin:(int)dkin
{
	destinyKin = dkin;
	return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
	// super init
    if ( (self = [super initWithFrame:frame]) == nil)
		return nil;
	
	// Black background
	self.backgroundColor = [UIColor blackColor];

    // ok!
	return self;
}

// GETTERS

- (CGFloat)getHeightSum
{
	return kinStack.heightSum;
}



//
// SETUP VIEW
// Return MAX Height
//
- (CGFloat)setupView
{
	CGFloat h;
	h = [self setupView:ORACLE_DESTINY];
	AvLog(@"ORACLE Kin        h[%.1f]",h);
	return h;
}
- (CGFloat)setupView:(int)kinType
{
	CGAffineTransform rotate = CGAffineTransformMakeRotation (3.14/2);
	AvanteTextLabel *label;
	//NSString *str;
	CGRect frame;
	CGFloat x, y, xx, yy;
	CGFloat w, h;
	CGFloat font;

	/////////////////////////////////////////////////////////////////////////////
	//
	// >>> OPEN KIN VIEW 1
	//
	kinView1 = [[AvanteView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.0)];
	[self addSubview:kinView1];
	[kinView1 release];
	y = 0.0;
	
	//
	// DESCRICAO DO SELO
	//
	if (kinType != ORACLE_DESTINY)
	{
		// Oracle: LABEL (para foto)
		if (destinyKin)
		{
			y += SPACER_GAP;
			x = SPACER_GAP;
			font = FONT_SIZE_NAME;
			h = HEIGHT_FOR_LINES(font,1);
			w = 320.0;
			frame = CGRectMake(x, y, w, h);
			label = [[AvanteTextLabel alloc] init:@"label" frame:frame size:font color:[UIColor whiteColor]];
			[kinView1 addSubview:label];
			// Recupera tamanho real
			[label update:[TzCalTzolkinMoon constOracleNavLabels:kinType destinyKin:destinyKin]];
			h = label.height;
			[label release];
			// -LINE
			y += h;
		}
		// Oracle: DESC
		y += SPACER_GAP;
		x = SPACER_GAP;
		font = FONT_SIZE_TEXT;
		h = HEIGHT_FOR_LINES(font,4);
		w = (320.0 - x - SPACER_GAP);
		frame = CGRectMake(x, y, w, h);
		label = [[AvanteTextLabel alloc] init:@"seal_desc" frame:frame size:font color:[UIColor whiteColor]];
		[label setAlign:ALIGN_LEFT];
		[label setWrap:YES];
		[kinView1 addSubview:label];
		// Recupera tamanho real
		[label update:[TzCalTzolkinMoon constOracleDescs:kinType]];
		h = label.height;
		[label release];
		// -LINE
		y += h + SPACER_GAP;
	}
	
	//
	// DREAMSPELL TZOLKIN KIN
	//
	// step away...
	y -= 12.0;
	// Tzolkin: TONE NUM
	x = SPACER_GAP;
	w = TONE_SIZE;
	h = TONE_SIZE;
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinNum = [[UIImageView alloc] initWithFrame:frame];
	dreamspellTzolkinNum.transform = rotate;
	[kinView1 addSubview:dreamspellTzolkinNum];
	[dreamspellTzolkinNum release];
	
	// -LINE
	y += TONE_SIZE + SPACER;
	// Kin: GLYPH
	w = SEAL_SIZE;
	h = SEAL_SIZE;
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinGlyph = [[UIImageView alloc] initWithFrame:frame];
	[kinView1 addSubview:dreamspellTzolkinGlyph];
	[dreamspellTzolkinGlyph release];
	// jump glyph
	x += TONE_SIZE + SPACER_GAP;
	// Kin: LABEL
	/*
	 w = 40.0;
	 font = FONT_SIZE_LABEL;
	 h = HEIGHT_FOR_LINES(font,1);
	 yy = y - h;
	 str = LOCAL(@"DREAMSPELL_DAY");
	 frame = CGRectMake(x, yy, w, h);
	 label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	 [label setAlign:ALIGN_LEFT];
	 [kinView1 addSubview:label];
	 [label release];
	 */
	// Kin: LABEL
	w = 100.0;
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	yy = y - h;
	frame = CGRectMake(x, yy, w, h);
	dreamspellTzolkinKin = [[AvanteTextLabel alloc] init:@"kin" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellTzolkinKin setAlign:ALIGN_LEFT];
	[kinView1 addSubview:dreamspellTzolkinKin];
	[dreamspellTzolkinKin release];
	// Kin: NAME 1
	w = (320.0 - x);
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,2);
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinName = [[AvanteTextLabel alloc] init:@"name1" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellTzolkinName setAlign:ALIGN_LEFT];
	[dreamspellTzolkinName setWrap:YES];
	[kinView1 addSubview:dreamspellTzolkinName];
	[dreamspellTzolkinName release];
	
	// Kin: NEWS
	xx = (320.0 - NEWS_SIZE - SPACER_GAP);
	yy = y - 30.0;
	w = NEWS_SIZE;
	h = NEWS_SIZE;
	frame = CGRectMake(xx, yy, w, h);
	dreamspellTzolkinNews = [[UIImageView alloc] initWithFrame:frame];
	[kinView1 addSubview:dreamspellTzolkinNews];
	[dreamspellTzolkinNews release];
	
	// -LINE
	y += TONE_SIZE + SPACER_GAP;
	
	//
	// COLOR
	//
	// Tzolkin: Color
	x = SPACER_GAP;
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	w = 200.0;
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinColor = [[AvanteTextLabel alloc] init:@"color" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellTzolkinColor setAlign:ALIGN_LEFT];
	[dreamspellTzolkinColor setShadow:[UIColor clearColor]];
	[kinView1 addSubview:dreamspellTzolkinColor];
	[dreamspellTzolkinColor release];
	// Tzolkin: PURPOSE
	w = 200.0;
	x = ((320.0 - w) / 2.0);
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	dreamspellColorPurpose = [[AvanteTextLabel alloc] init:@"purpose" frame:frame size:font color:[UIColor whiteColor]];
	[kinView1 addSubview:dreamspellColorPurpose];
	[dreamspellColorPurpose release];
	// Tzolkin: ELEMENT
	w = NEWS_SIZE;
	x = ( 320.0 - w - SPACER_GAP);
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	dreamspellColorElement = [[AvanteTextLabel alloc] init:@"element" frame:frame size:font color:[UIColor whiteColor]];
	[kinView1 addSubview:dreamspellColorElement];
	[dreamspellColorElement release];
	
	// -LINE
	y += h + SPACER;
	// Tzolkin: COLOR TAGS
	x = SPACER_GAP;
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font, (global.prefLang == LANG_ES ? 2 : 1));
	w = (320.0 - x);
	frame = CGRectMake(x, y, w, h);
	dreamspellColorTags = [[AvanteTextLabel alloc] init:@"tags" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellColorTags setAlign:ALIGN_LEFT];
	if (global.prefLang == LANG_ES)		// em espanhol é mais comprido
		[dreamspellColorTags setWrap:YES];
	[kinView1 addSubview:dreamspellColorTags];
	[dreamspellColorTags release];
	
	// -LINE
	y += h + SPACER_GAP;
	// Tzolkin: COLOR DESC
	x = SPACER_GAP;
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,2);
	frame = CGRectMake(x, y, w, h);
	dreamspellColorDesc = [[AvanteTextLabel alloc] init:@"desc" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellColorDesc setAlign:ALIGN_LEFT];
	[dreamspellColorDesc setWrap:YES];
	[kinView1 addSubview:dreamspellColorDesc];
	[dreamspellColorDesc release];
	
	//
	// TONE
	//
	// -LINE
	y += h + SPACER_GAP;
	// Tzolkin: TONE NUM
	y -= 10.0;
	x = SPACER_GAP;
	w = TONE_SIZE;
	h = TONE_SIZE;
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinNum2 = [[UIImageView alloc] initWithFrame:frame];
	dreamspellTzolkinNum2.transform = rotate;
	[kinView1 addSubview:dreamspellTzolkinNum2];
	[dreamspellTzolkinNum2 release];
	// Tzolkin: TONE NAME
	x += TONE_SIZE + SPACER_GAP;
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	y += TONE_SIZE - h;
	w = (320.0 - x);
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinNumName = [[AvanteTextLabel alloc] init:@"tone" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellTzolkinNumName setAlign:ALIGN_LEFT];
	[dreamspellTzolkinNumName setFit:YES];
	[kinView1 addSubview:dreamspellTzolkinNumName];
	[dreamspellTzolkinNumName release];
	
	// -LINE
	y += h + SPACER_GAP;
	
	//
	// >>> CLOSE KIN VIEW 1
	//
	kinView1.heightFixed = y;
	
	// Tzolkin: TONE DESC
	x = SPACER_GAP;
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,15);
	w = (320.0 - x);
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinNumDesc = [[AvanteTextLabel alloc] init:@"tone_desc" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellTzolkinNumDesc setAlign:ALIGN_LEFT];
	[dreamspellTzolkinNumDesc setWrap:YES];
	[kinView1 addSubviewVar:dreamspellTzolkinNumDesc];
	[dreamspellTzolkinNumDesc release];
	
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// >>> OPEN KIN VIEW 2
	//
	kinView2 = [[AvanteView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.0)];
	[self addSubview:kinView2];
	[kinView2 release];
	y = 0.0;
	
	//
	//
	// SEAL
	//
	y += SPACER_GAP;
	// Tzolkin: SEAL
	x = SPACER_GAP;
	w = SEAL_SIZE;
	h = SEAL_SIZE;
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinGlyph2 = [[UIImageView alloc] initWithFrame:frame];
	[kinView2 addSubview:dreamspellTzolkinGlyph2];
	[dreamspellTzolkinGlyph2 release];
	// jump seal
	x += TONE_SIZE + SPACER_GAP;
	// Tzolkin: SEAL LABEL
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,1);
	w = (320.0 - x);
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinGlyphLabel = [[AvanteTextLabel alloc] init:@"seal label" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellTzolkinGlyphLabel setAlign:ALIGN_LEFT];
	[kinView2 addSubview:dreamspellTzolkinGlyphLabel];
	[dreamspellTzolkinGlyphLabel release];
	// Tzolkin: SEAL NAME
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	yy = y + SEAL_SIZE - h;
	w = (320.0 - x);
	frame = CGRectMake(x, yy, w, h);
	dreamspellTzolkinGlyphName = [[AvanteTextLabel alloc] init:@"seal name" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellTzolkinGlyphName setAlign:ALIGN_LEFT];
	[kinView2 addSubview:dreamspellTzolkinGlyphName];
	[dreamspellTzolkinGlyphName release];
	
	// -LINE
	y += SEAL_SIZE + SPACER_GAP;
	
	//
	// >>> CLOSE KIN VIEW 2
	//
	kinView2.heightFixed = y;
	
	// Tzolkin: SEAL FRASE
	x = SPACER_GAP;
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,2);
	w = (320.0 - x);
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinGlyphFrase = [[AvanteTextLabel alloc] init:@"seal_frase" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellTzolkinGlyphFrase setAlign:ALIGN_LEFT];
	[dreamspellTzolkinGlyphFrase setWrap:YES];
	[kinView2 addSubview:dreamspellTzolkinGlyphFrase];
	[dreamspellTzolkinGlyphFrase release];
	
	
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// >>> OPEN KIN VIEW 3
	//
	kinView3 = [[AvanteView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.0)];
	[self addSubview:kinView3];
	[kinView3 release];
	y = 0.0;
	
	// -LINE
	y += SPACER_GAP;
	// Tzolkin: SEAL TAGS
	x = SPACER_GAP;
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,2);
	w = (320.0 - x);
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinGlyphTags = [[AvanteTextLabel alloc] init:@"seal_tags" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellTzolkinGlyphTags setAlign:ALIGN_LEFT];
	[dreamspellTzolkinGlyphTags setWrap:YES];
	[kinView3 addSubview:dreamspellTzolkinGlyphTags];
	[dreamspellTzolkinGlyphTags release];
	
	// -LINE
	y += h + SPACER_GAP;
	
	//
	// >>> CLOSE KIN VIEW 3
	//
	kinView3.heightFixed = y;
	
	// Tzolkin: SEAL DESC
	x = SPACER_GAP;
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,11);
	w = (320.0 - x);
	frame = CGRectMake(x, y, w, h);
	dreamspellTzolkinGlyphDesc = [[AvanteTextLabel alloc] init:@"seal_desc" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellTzolkinGlyphDesc setAlign:ALIGN_LEFT];
	[dreamspellTzolkinGlyphDesc setWrap:YES];
	[kinView3 addSubviewVar:dreamspellTzolkinGlyphDesc];
	[dreamspellTzolkinGlyphDesc release];
	// -LINE
	//y += h + SPACER_GAP;
	
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// Create View Stack Manager
	//
	kinStack = [[AvanteViewStack alloc] init];
	[kinStack stackView:kinView1];
	[kinStack stackView:kinView2];
	[kinStack stackView:kinView3];
	
	// Return view size
	return (kinStack.heightSum);
}

#pragma mark UPDATE

//
// UPDATE
//
- (void)updateView:(TzCalTzolkinMoon*)tzolkin
{

	// VIEW 3 - KIN
	// Tzolkin Kin
	[dreamspellTzolkinKin update:[NSString stringWithFormat:@"Kin %d:",tzolkin.kin]];
	[dreamspellTzolkinName update:[NSString stringWithFormat:@"%@\n%@",
								   tzolkin.dayName1,tzolkin.dayName2]];
	// Color & cia
	dreamspellTzolkinNews.image = [UIImage imageNamed: tzolkin.imgNews];
	[dreamspellTzolkinColor update: tzolkin.colorFamily];
	[dreamspellTzolkinColor setColor:tzolkin.colorUIColor];
	[dreamspellColorPurpose update: tzolkin.colorPurpose];
	[dreamspellColorElement update: tzolkin.elementName];
	[dreamspellColorTags update: tzolkin.colorTag];
	[dreamspellColorDesc update: tzolkin.colorDesc];
	// Tone / Num
	dreamspellTzolkinNum.image = [UIImage imageNamed: tzolkin.imgNum];
	dreamspellTzolkinNum2.image = [UIImage imageNamed: tzolkin.imgNum];
	[dreamspellTzolkinNumName update:tzolkin.toneNameFull];
	[dreamspellTzolkinNumDesc update:tzolkin.toneDesc];
	// Seal / Glyph
	dreamspellTzolkinGlyph.image = [UIImage imageNamed: tzolkin.imgGlyph];
	dreamspellTzolkinGlyph2.image = [UIImage imageNamed: tzolkin.imgGlyph];
	[dreamspellTzolkinGlyphName update:[NSString stringWithFormat:@"%@ / %@",tzolkin.sealName,tzolkin.dayNameMaya]];
	[dreamspellTzolkinGlyphLabel update:tzolkin.sealLabel];
	[dreamspellTzolkinGlyphFrase update:tzolkin.sealFrase];
	[dreamspellTzolkinGlyphTags update:tzolkin.sealTags];
	[dreamspellTzolkinGlyphDesc update:tzolkin.sealDesc];
	
	/// Resize Stack
	kinView1.heightVar = dreamspellTzolkinNumDesc.height;
	kinView2.heightVar = dreamspellTzolkinGlyphFrase.height;
	kinView3.heightVar = dreamspellTzolkinGlyphDesc.height;
	[kinStack resize];

	// Resize self
	CGRect frame = self.frame;
	frame.size.height = self.heightSum;
	self.frame = frame;
}

@end
