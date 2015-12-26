//
//  MayaGlyphVC.m
//  Maya3D
//
//  Created by Roger on 12/12/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "MayaGlyphVC.h"
#import "TzCalendar.h"
#import "TzGlobal.h"
#import "TzClock.h"
#import "SettingsVC.h"
#import "KinDecodeVC.h"
#import "TzSoundManager.h"
#import "AvanteKinButton.h"

@implementation MayaGlyphVC

// MAYA GLYPH
#define SPACER					2.0
#define SPACER_GAP				16.0
//#define VIEW_HEIGHT				(kActiveLessNavTab - kRollerVerticalHeight)
#define GLYPH_HEIGHT			60.0
#define GLYPH_WIDTH				60.0
#define GLYPH_WIDTH_NUM			30.0
#define ISIG_WIDTH				150.0
#define GAP_LEFT				(ceil( ( kscreenWidth - (GLYPH_WIDTH_NUM*2) - (SPACER*3) - (GLYPH_WIDTH*2) ) / 2.0) )
#define GAP_TOP					(ceil( ( VIEW_HEIGHT - (GLYPH_HEIGHT*5.0) - (SPACER*4.0) ) / 2.0 ) )
#define FONT_SIZE_MAYA_LABEL	12.0

// DREAMSPELL SIGNATURE
#define FONT_SIZE_NAME			18.0
#define FONT_SIZE_TEXT			14.0
#define FONT_SIZE_LABEL			12.0
#define FONT_SIZE_ORACLE		10.0
#define FONT_SIZE_AFFIRM		12.0
#define TONE_SIZE				40.0
#define SEAL_SIZE				60.0
#define ORACLE_SIZE				40.0
#define PLASMA_SIZE				28.0
#define PORTAL_SIZE				28.0
#define MOON_FASE_SIZE			32.0
//#define MOON_FASE_SIZE			40.0


- (void)dealloc {
	[contentViewMaya removeFromSuperview];
	[contentViewDreamspell removeFromSuperview];
	// Super
    [super dealloc];
}


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

 // Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}

 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning
{
	// Apaga view apenas se nao estiver nesta tela
	if (global.currentTab != TAB_GLYPH && contentViewMaya != nil)
	{
		AvLog(@"MEMORY WARNING: MayaGlyphVC: DUMP contentView...");
		[contentViewMaya removeFromSuperview];
		contentViewMaya = nil;
		[contentViewDreamspell removeFromSuperview];
		contentViewDreamspell = nil;
	}
	// super
    [super didReceiveMemoryWarning]; 
}


- (void)viewWillAppear:(BOOL)animated {
    ///////////////////
    UIBarButtonItem *but;
    
    // call super
   // [super viewDidLoad];
    
    // Corrige nome
    if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
        self.title = LOCAL(@"TAB_GLYPH");
    else
        self.title = LOCAL(@"TAB_SIGNATURE");
    
    // Configura switch MAYA / DREAMSPELL
    mayaMoonSelector = [global addViewModeSwitch:self];
    if (mayaMoonSelector)
        [mayaMoonSelector addTarget:self action:@selector(switchViewMode:) forControlEvents:UIControlEventValueChanged];
    
    // SETTINGS BUTTON
    /*
     UIBarButtonItem *but;
     but = [[UIBarButtonItem alloc]
		   initWithImage:[global imageFromFile:@"icon_settings"]
		   style:UIBarButtonItemStylePlain
		   target:self action:@selector(goSettings:)];
     self.navigationItem.rightBarButtonItem = but;
     self.navigationItem.rightBarButtonItem.enabled = TRUE;
     [but release];
     */
    
    // SCREENSHOT BUTTON
    but = [[UIBarButtonItem alloc]
           //initWithImage:[global imageFromFile:@"icon_save"]
           //style:UIBarButtonItemStylePlain
           initWithBarButtonSystemItem:UIBarButtonSystemItemAction
           target:self
           action:@selector(share:)];
    
    [but setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = but;
    self.navigationItem.rightBarButtonItem.enabled = TRUE;
    [but release];
    
    // HELP BUTTON
    but = [[UIBarButtonItem alloc]
           initWithImage:[global imageFromFile:@"icon_info"]
           style:UIBarButtonItemStylePlain
           target:self action:@selector(goInfo:)];
    [but setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = but;
    self.navigationItem.leftBarButtonItem.enabled = TRUE;
    [but release];
    
    // Roller
    roller = [[AvanteRollerVertical alloc] init:0.0:VIEW_HEIGHT];
    [roller addCallback:self dragLeft:@selector(julianSub:) dragRight:@selector(julianAdd:)];
    [self.view addSubview:roller];
    [roller release];
    
    // Create Content Views
    [self createContentMaya];
    [self createContentDreamspell];

    ///////////////////
    
	// Redraw content view?
	if (contentViewMaya == nil)
	{
		AvLog(@"MayaGlyphVC: RELOAD contentView...");
		[self createContentMaya];
//		[self createContentDreamspell];
	}
	// Pause Clock
	[global.theClock pause];
	// Usa View Mode atual
	if (mayaMoonSelector)
		mayaMoonSelector.selectedSegmentIndex = global.prefMayaDreamspell;
	// Remove LEAP DAY se estiver no modo DREAMSPELL
	[global.cal removeLeap];
	// Draw Glyph
	[self updateGlyph];
}
- (void)viewDidAppear:(BOOL)animated {
	global.currentTab = TAB_GLYPH;
	global.currentVC = self;
}
- (void)viewWillDisappear:(BOOL)animated {
	// Short name - para o BACK do nav controler
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
		self.navigationItem.title = LOCAL(@"TAB_GLYPH");
	else
		self.navigationItem.title = LOCAL(@"TAB_SIGNATURE");
}
- (void)viewDidDisappear:(BOOL)animated {
	global.lastTab = TAB_GLYPH;
}

//////////////////////////////////////////////////////////
//
// VIEW SETUP
//
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
//	UIBarButtonItem *but;
//	
//	// call super
    [super viewDidLoad];
    
    VIEW_HEIGHT		=		(kActiveLessNavTab - kRollerVerticalHeight);
//
//	// Corrige nome
//	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
//		self.title = LOCAL(@"TAB_GLYPH");
//	else
//		self.title = LOCAL(@"TAB_SIGNATURE");
//	
//	// Configura switch MAYA / DREAMSPELL
//	mayaMoonSelector = [global addViewModeSwitch:self];
//	if (mayaMoonSelector)
//		[mayaMoonSelector addTarget:self action:@selector(switchViewMode:) forControlEvents:UIControlEventValueChanged];
//
//	// SETTINGS BUTTON
//	/*
//	UIBarButtonItem *but;
//	but = [[UIBarButtonItem alloc]
//		   initWithImage:[global imageFromFile:@"icon_settings"]
//		   style:UIBarButtonItemStylePlain
//		   target:self action:@selector(goSettings:)];
//	self.navigationItem.rightBarButtonItem = but;
//	self.navigationItem.rightBarButtonItem.enabled = TRUE;
//	[but release];
//	*/
//	
//	// SCREENSHOT BUTTON
//	but = [[UIBarButtonItem alloc]
//		   //initWithImage:[global imageFromFile:@"icon_save"]
//		   //style:UIBarButtonItemStylePlain
//		   initWithBarButtonSystemItem:UIBarButtonSystemItemAction
//		   target:self
//		   action:@selector(share:)];
//	self.navigationItem.rightBarButtonItem = but;
//	self.navigationItem.rightBarButtonItem.enabled = TRUE;
//	[but release];
//
//	// HELP BUTTON
//	but = [[UIBarButtonItem alloc]
//		   initWithImage:[global imageFromFile:@"icon_info"]
//		   style:UIBarButtonItemStylePlain
//		   target:self action:@selector(goInfo:)];
//	self.navigationItem.leftBarButtonItem = but;
//	self.navigationItem.leftBarButtonItem.enabled = TRUE;
//	[but release];
//	
//	// Roller
//	roller = [[AvanteRollerVertical alloc] init:0.0:VIEW_HEIGHT];
//	[roller addCallback:self dragLeft:@selector(julianSub:) dragRight:@selector(julianAdd:)];
//	[self.view addSubview:roller];
//	[roller release];
//
//	// Create Content Views
//	[self createContentMaya];
//	[self createContentDreamspell];
}

#pragma mark GLYPH DRAWING - ONCE

//////////////////////////////////////////////////////////
//
// DRAW - MAYA
//
- (void)createContentMaya {
	CGRect frame;
	CGFloat x = 0.0, y = 0.0;
	CGFloat w = 0.0, h = 0.0;
	CGFloat font;
	CGFloat lh = HEIGHT_FOR_LINES(FONT_SIZE_MAYA_LABEL,1);
	CGFloat dy = (GLYPH_HEIGHT-lh);
	
	//
	// Maya CONTENT VIEW
	//
	// add a bot to the height for screenshot
	if (!DUAL_MODE)
		frame = CGRectMake(0.0, -8.0, kscreenWidth, (VIEW_HEIGHT+15.0));
	else
		frame = CGRectMake(0.0, 0.0, kscreenWidth, (VIEW_HEIGHT+15.0));
    if( contentViewMaya )
    {
        [contentViewMaya removeFromSuperview];
        contentViewMaya = nil;
    }
	contentViewMaya = [[UIView alloc] initWithFrame:frame];
	contentViewMaya.backgroundColor = [UIColor clearColor];
	contentViewMaya.hidden = TRUE;
	[self.view addSubview:contentViewMaya];
	[contentViewMaya release];
	
	//
	// ROW 0
	//
	y = 0.0;
	
	// Gregorian
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,1);
	w = ISIG_WIDTH;
	x = GAP_LEFT + GLYPH_WIDTH_NUM + SPACER;
	frame = CGRectMake(x, y, w, h);
	mayaGregName = [[AvanteTextLabel alloc] init:@"gregname" frame:frame size:font color:[UIColor whiteColor]];
	[contentViewMaya addSubview:mayaGregName];
	[mayaGregName release];
	// desenha apenas em modu dual
	if (!DUAL_MODE)
		mayaGregName.hidden = true;
	// jump this
	y += font + SPACER;
	
	//
	// ROW 1
	//
	
	// ISIG = HAAB UINAL
	//x = (kscreenWidth - ISIG_WIDTH) / 2.0;
	x = GAP_LEFT + GLYPH_WIDTH_NUM + SPACER;
	frame = CGRectMake(x, y, ISIG_WIDTH, GLYPH_HEIGHT);
	mayaIsigGlyph = [[UIImageView alloc] initWithFrame:frame];
	[contentViewMaya addSubview:mayaIsigGlyph];
	[mayaIsigGlyph release];
	
	//
	// ROW 2
	//
	y += GLYPH_HEIGHT + SPACER;
	
	// BAKTUN LABEL
	x = 0.0;
	frame = CGRectMake(x, y+dy, GAP_LEFT, lh);
	mayaBaktunLabel = [[AvanteTextLabel alloc] init:@"baktun" frame:frame size:FONT_SIZE_MAYA_LABEL color:[UIColor whiteColor]];
	[contentViewMaya addSubview:mayaBaktunLabel];
	[mayaBaktunLabel release];
	// BAKTUN NUM
	x = GAP_LEFT;
	frame = CGRectMake(x, y, GLYPH_WIDTH_NUM, GLYPH_HEIGHT);
	mayaBaktunNum = [[UIImageView alloc] initWithFrame:frame];
	[contentViewMaya addSubview:mayaBaktunNum];
	[mayaBaktunNum release];
	// BAKTUN GLYPH
	x += GLYPH_WIDTH_NUM + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH, GLYPH_HEIGHT);
	mayaBaktunGlyph = [[UIImageView alloc] initWithFrame:frame];
	mayaBaktunGlyph.image = [global imageFromFile:@"long_baktun"];
	[contentViewMaya addSubview:mayaBaktunGlyph];
	[mayaBaktunGlyph release];
	
	// KATUN NUM
	x += GLYPH_WIDTH + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH_NUM, GLYPH_HEIGHT);
	mayaKatunNum = [[UIImageView alloc] initWithFrame:frame];
	[contentViewMaya addSubview:mayaKatunNum];
	[mayaKatunNum release];
	// KATUN GLYPH
	x += GLYPH_WIDTH_NUM + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH, GLYPH_HEIGHT);
	mayaKatunGlyph = [[UIImageView alloc] initWithFrame:frame];
	mayaKatunGlyph.image = [global imageFromFile:@"long_katun"];
	[contentViewMaya addSubview:mayaKatunGlyph];
	[mayaKatunGlyph release];
	// KATUN LABEL
	x += GLYPH_WIDTH;
	frame = CGRectMake(x, y+dy, GAP_LEFT, lh);
	mayaKatunLabel = [[AvanteTextLabel alloc] init:@"katun" frame:frame size:FONT_SIZE_MAYA_LABEL color:[UIColor whiteColor]];
	[contentViewMaya addSubview:mayaKatunLabel];
	[mayaKatunLabel release];
	
	//
	// ROW 3
	//
	y += GLYPH_HEIGHT + SPACER;
	
	// TUN LABEL
	x = 0.0;
	frame = CGRectMake(x, y+dy, GAP_LEFT, lh);
	mayaTunLabel = [[AvanteTextLabel alloc] init:@"tun" frame:frame size:FONT_SIZE_MAYA_LABEL color:[UIColor whiteColor]];
	[contentViewMaya addSubview:mayaTunLabel];
	[mayaTunLabel release];
	// TUN NUM
	x = GAP_LEFT;
	frame = CGRectMake(x, y, GLYPH_WIDTH_NUM, GLYPH_HEIGHT);
	mayaTunNum = [[UIImageView alloc] initWithFrame:frame];
	[contentViewMaya addSubview:mayaTunNum];
	[mayaTunNum release];
	// TUN GLYPH
	x += GLYPH_WIDTH_NUM + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH, GLYPH_HEIGHT);
	mayaTunGlyph = [[UIImageView alloc] initWithFrame:frame];
	mayaTunGlyph.image = [global imageFromFile:@"long_tun"];
	[contentViewMaya addSubview:mayaTunGlyph];
	[mayaTunGlyph release];
	
	// UINAL NUM
	x += GLYPH_WIDTH + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH_NUM, GLYPH_HEIGHT);
	mayaUinalNum = [[UIImageView alloc] initWithFrame:frame];
	[contentViewMaya addSubview:mayaUinalNum];
	[mayaUinalNum release];
	// UINAL GLYPH
	x += GLYPH_WIDTH_NUM + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH, GLYPH_HEIGHT);
	mayaUinalGlyph = [[UIImageView alloc] initWithFrame:frame];
	mayaUinalGlyph.image = [global imageFromFile:@"long_uinal"];
	[contentViewMaya addSubview:mayaUinalGlyph];
	[mayaUinalGlyph release];
	// UINAL LABEL
	x += GLYPH_WIDTH;
	frame = CGRectMake(x, y+dy, GAP_LEFT, lh);
	mayaUinalLabel = [[AvanteTextLabel alloc] init:@"uinal" frame:frame size:FONT_SIZE_MAYA_LABEL color:[UIColor whiteColor]];
	[contentViewMaya addSubview:mayaUinalLabel];
	[mayaUinalLabel release];

	//
	// ROW 4
	//
	y += GLYPH_HEIGHT + SPACER;
	
	// KIN LABEL
	x = 0.0;
	frame = CGRectMake(x, y+dy, GAP_LEFT, lh);
	mayaKinLabel = [[AvanteTextLabel alloc] init:@"kin" frame:frame size:FONT_SIZE_MAYA_LABEL color:[UIColor whiteColor]];
	[contentViewMaya addSubview:mayaKinLabel];
	[mayaKinLabel release];
	// KIN NUM
	x = GAP_LEFT;
	frame = CGRectMake(x, y, GLYPH_WIDTH_NUM, GLYPH_HEIGHT);
	mayaKinNum = [[UIImageView alloc] initWithFrame:frame];
	[contentViewMaya addSubview:mayaKinNum];
	[mayaKinNum release];
	// KIN GLYPH
	x += GLYPH_WIDTH_NUM + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH, GLYPH_HEIGHT);
	mayaKinGlyph = [[UIImageView alloc] initWithFrame:frame];
	mayaKinGlyph.image = [global imageFromFile:@"long_kin"];
	[contentViewMaya addSubview:mayaKinGlyph];
	[mayaKinGlyph release];
	
	// TZOLKIN NUM
	x += GLYPH_WIDTH + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH_NUM, GLYPH_HEIGHT);
	mayaTzolkinNum = [[UIImageView alloc] initWithFrame:frame];
	[contentViewMaya addSubview:mayaTzolkinNum];
	[mayaTzolkinNum release];
	// TZOLKIN GLYPH
	x += GLYPH_WIDTH_NUM + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH, GLYPH_HEIGHT);
	mayaTzolkinGlyph = [[UIImageView alloc] initWithFrame:frame];
	[contentViewMaya addSubview:mayaTzolkinGlyph];
	[mayaTzolkinGlyph release];
	// TZOLKIN LABEL
	x += GLYPH_WIDTH;
	frame = CGRectMake(x, y+dy, GAP_LEFT, lh);
	mayaTzolkinLabel = [[AvanteTextLabel alloc] init:@"tzolkin" frame:frame size:FONT_SIZE_MAYA_LABEL color:[UIColor whiteColor]];
	[contentViewMaya addSubview:mayaTzolkinLabel];
	[mayaTzolkinLabel release];
	
	//
	// ROW 5
	//
	y += GLYPH_HEIGHT + SPACER;
	
	// LORD LABEL
	x = 0.0;
	frame = CGRectMake(x, y+dy-15, GAP_LEFT, lh*2);
	mayaLordLabel = [[AvanteTextLabel alloc] init:@"lord" frame:frame size:FONT_SIZE_MAYA_LABEL color:[UIColor whiteColor]];
	[mayaLordLabel setWrap:YES];
	[contentViewMaya addSubview:mayaLordLabel];
	[mayaLordLabel release];
	// LORD GLYPH
	x = GAP_LEFT + GLYPH_WIDTH_NUM + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH, GLYPH_HEIGHT);
	mayaLordGlyph = [[UIImageView alloc] initWithFrame:frame];
	[contentViewMaya addSubview:mayaLordGlyph];
	[mayaLordGlyph release];
	
	// HAAB NUM
	x += GLYPH_WIDTH + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH_NUM, GLYPH_HEIGHT);
	mayaHaabNum = [[UIImageView alloc] initWithFrame:frame];
	[contentViewMaya addSubview:mayaHaabNum];
	[mayaHaabNum release];
	// HAAB GLYPH
	x += GLYPH_WIDTH_NUM + SPACER;
	frame = CGRectMake(x, y, GLYPH_WIDTH, GLYPH_HEIGHT);
	mayaHaabGlyph = [[UIImageView alloc] initWithFrame:frame];
	[contentViewMaya addSubview:mayaHaabGlyph];
	[mayaHaabGlyph release];
	// HAAB LABEL
	x += GLYPH_WIDTH;
	frame = CGRectMake(x, y+dy, GAP_LEFT, lh);
	mayaHaabLabel = [[AvanteTextLabel alloc] init:@"haab" frame:frame size:FONT_SIZE_MAYA_LABEL color:[UIColor whiteColor]];
	[contentViewMaya addSubview:mayaHaabLabel];
	[mayaHaabLabel release];
}


//////////////////////////////////////////////////////////
//
// DRAW - DREAMSPELL
//
- (void)createContentDreamspell {
	AvanteTextLabel *label = nil;
	CGRect frame;
	CGFloat x = 0.0, y = 0.0;
	CGFloat w = 0.0, h = 0.0;
	CGFloat hh = 0.0;
	NSString *str;
	CGAffineTransform rotate = CGAffineTransformMakeRotation (3.14/2);
	CGFloat font;
	
	//
	// Dreamspell CONTENT VIEW
	//
	frame = CGRectMake(0.0, 0.0, kscreenWidth, VIEW_HEIGHT);
    if( contentViewDreamspell)
    {
        [contentViewDreamspell removeFromSuperview];
        contentViewDreamspell = nil;
    }
	contentViewDreamspell = [[UIView alloc] initWithFrame:frame];
	contentViewDreamspell.backgroundColor = [UIColor blackColor];
	contentViewDreamspell.hidden = TRUE;
	[self.view addSubview:contentViewDreamspell];
	[contentViewDreamspell release];

	//
	// DAY / SEAL - ASSINATURA GALACTICA
	//
	// SEAL NUMBER
	//y = SPACER_GAP;
	y = 0.0;
	x = SPACER_GAP + ( (SEAL_SIZE-TONE_SIZE) / 2.0 );
	frame = CGRectMake(x, y, TONE_SIZE, TONE_SIZE);
	destinySealNum = [[UIImageView alloc] initWithFrame:frame];
	destinySealNum.transform = rotate;
	[contentViewDreamspell addSubview:destinySealNum];
	hh = destinySealNum.bounds.size.height;
	[destinySealNum release];
	// DAY / SEAL GLYPH
	y += hh;
	x = SPACER_GAP;
	frame = CGRectMake(x, y, SEAL_SIZE, SEAL_SIZE);
	destinySealGlyph = [[AvanteKinButton alloc] initWithFrame:frame];
	destinySealGlyph.kinType = ORACLE_DESTINY;
	destinySealGlyph.myVC = (UINavigationController*)self;
	[contentViewDreamspell addSubview:destinySealGlyph];
	hh = destinySealGlyph.bounds.size.height;
	[destinySealGlyph release];
	
	//
	// KIN NAME
	//
	x += (SEAL_SIZE + SPACER_GAP);
	w = (kscreenWidth - x);
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	y = 0.0 + TONE_SIZE - h;
	//AvLog(@">> x[%.1f] y[%.1f] w[%.1f] h[%.1f] ",x,y,w,h);
	frame = CGRectMake(x, y, w, h);
	kinText1 = [[AvanteTextLabel alloc] init:@"kin1" frame:frame size:font color:[UIColor whiteColor]];
	[kinText1 setAlign:ALIGN_LEFT];
	[contentViewDreamspell addSubview:kinText1];
	[kinText1 release];
	// Day name 1
	y += h;
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	kinText2 = [[AvanteTextLabel alloc] init:@"kin2" frame:frame size:font color:[UIColor whiteColor]];
	[kinText2 setAlign:ALIGN_LEFT];
	[contentViewDreamspell addSubview:kinText2];
	[kinText2 release];
	// Day name 2
	y += font;
	frame = CGRectMake(x, y, w, h);
	kinText3 = [[AvanteTextLabel alloc] init:@"kin3" frame:frame size:font color:[UIColor whiteColor]];
	[kinText3 setAlign:ALIGN_LEFT];
	[contentViewDreamspell addSubview:kinText3];
	[kinText3 release];
	// Gregorian
	y += h;
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	dreamspellGregName = [[AvanteTextLabel alloc] init:@"gregname" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellGregName setAlign:ALIGN_LEFT];
	[contentViewDreamspell addSubview:dreamspellGregName];
	hh = dreamspellGregName.bounds.size.height;
	[dreamspellGregName release];
	
	//
	// DOOT TEXT
	//
	y = 120.0;
	x = -10.0;	// ?????
	w = 200.0;
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	dootText = [[AvanteTextLabel alloc] init:@"Day Out Of Time" frame:frame size:font color:[UIColor whiteColor]];
	[dootText setWrap:NO];
	[contentViewDreamspell addSubview:dootText];
	[dootText release];
	
	//
	// PLASMA
	//
	y = 120.0;
	x = 40.0;
	// Plasma Glyph
	frame = CGRectMake(x, y, PLASMA_SIZE, PLASMA_SIZE);
	plasmaGlyph = [[UIImageView alloc] initWithFrame:frame];
	[contentViewDreamspell addSubview:plasmaGlyph];
	hh = plasmaGlyph.bounds.size.height;
	[plasmaGlyph release];
	// PLASMA NAME
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,1);
	w = 100.0;
	x += hh + SPACER_GAP;
	frame = CGRectMake(x, y, w, h);
	plasmaName = [[AvanteTextLabel alloc] init:@"plasma" frame:frame size:font color:[UIColor whiteColor]];
	[plasmaName setAlign:ALIGN_LEFT];
	[contentViewDreamspell addSubview:plasmaName];
	[plasmaName release];
	// chakra NAME
	y += font;
	frame = CGRectMake(x, y, w, h);
	chakraName = [[AvanteTextLabel alloc] init:@"chakra" frame:frame size:font color:[UIColor whiteColor]];
	[chakraName setAlign:ALIGN_LEFT];
	[contentViewDreamspell addSubview:chakraName];
	[chakraName release];
	//
	// PLASMA TEXT
	//
	y += h + 5.0;
	x = 5.0;
	w = 180;
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,4);
	frame = CGRectMake(x, y, w, h);
	plasmaText = [[AvanteTextLabel alloc] init:@"plasma_txt" frame:frame size:font color:[UIColor whiteColor]];
	[plasmaText setWrap:YES];
	[contentViewDreamspell addSubview:plasmaText];
	[plasmaText release];
	
	//
	// PORTAL DE ATIVACAO GALACTICA
	//
	//y = 0.0 + TONE_SIZE + SEAL_SIZE - PORTAL_SIZE;
	y = SPACER_GAP;
	x = kscreenWidth - PORTAL_SIZE - SPACER_GAP;
	// Moon Glyph
	frame = CGRectMake(x, y, PORTAL_SIZE, PORTAL_SIZE);
	portalGlyph = [[UIImageView alloc] initWithFrame:frame];
	[contentViewDreamspell addSubview:portalGlyph];
	[portalGlyph release];
	
	//            1
	// ORACLE = 2 3 4
	//            5
	//int orax = ( kscreenWidth - (ORACLE_SIZE*3.0) - (SPACER*2.0) ) / 2.0;
	y = 80.0;
	int orax = 190.0;
	font = FONT_SIZE_ORACLE;
	h = HEIGHT_FOR_LINES(font,1);
	//
	// ORACLE 1
	//
	y += SPACER;
	x = orax + ORACLE_SIZE + SPACER;
	// GUIDE Label
	str = LOCAL(@"ORACLE_GUIDE");
	frame = CGRectMake(x, y, ORACLE_SIZE, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[contentViewDreamspell addSubview:label];
	[label release];
	// ORACLE - GUIDE Glyph
	y += h;
	frame = CGRectMake(x, y, ORACLE_SIZE, ORACLE_SIZE);
	oracleGuideGlyph = [[AvanteKinButton alloc] initWithFrame:frame];
	oracleGuideGlyph.kinType = ORACLE_GUIDE;
	oracleGuideGlyph.myVC = (UINavigationController*)self;
	[contentViewDreamspell addSubview:oracleGuideGlyph];
	[oracleGuideGlyph release];
	//
	// ORACLE 2
	//
	y += ORACLE_SIZE + SPACER;
	x = orax;
	// ANTIPODE Label
	str = LOCAL(@"ORACLE_ANTIPODE");
	frame = CGRectMake(x-5.0, y-h, ORACLE_SIZE+10.0, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[contentViewDreamspell addSubview:label];
	[label release];
	// ANTIPODE Glyph
	frame = CGRectMake(x, y, ORACLE_SIZE, ORACLE_SIZE);
	oracleAntipodeGlyph = [[AvanteKinButton alloc] initWithFrame:frame];
	oracleAntipodeGlyph.kinType = ORACLE_ANTIPODE;
	oracleAntipodeGlyph.myVC = (UINavigationController*)self;
	[contentViewDreamspell addSubview:oracleAntipodeGlyph];
	[oracleAntipodeGlyph release];
	//
	// ORACLE 3
	//
	x += ORACLE_SIZE + SPACER;
	// DESTINY Glyph
	frame = CGRectMake(x, y, ORACLE_SIZE, ORACLE_SIZE);
	oracleDestinyGlyph = [[AvanteKinButton alloc] initWithFrame:frame];
	oracleDestinyGlyph.kinType = ORACLE_DESTINY;
	oracleDestinyGlyph.myVC = (UINavigationController*)self;
	[contentViewDreamspell addSubview:oracleDestinyGlyph];
	[oracleDestinyGlyph release];
	//
	// ORACLE 4
	//
	x += ORACLE_SIZE + SPACER;
	// ANALOG Label
	str = LOCAL(@"ORACLE_ANALOG");
	frame = CGRectMake(x, y-h, ORACLE_SIZE, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[contentViewDreamspell addSubview:label];
	[label release];
	// ANALOG Glyph
	frame = CGRectMake(x, y, ORACLE_SIZE, ORACLE_SIZE);
	oracleAnalogGlyph = [[AvanteKinButton alloc] initWithFrame:frame];
	oracleAnalogGlyph.kinType = ORACLE_ANALOG;
	oracleAnalogGlyph.myVC = (UINavigationController*)self;
	[contentViewDreamspell addSubview:oracleAnalogGlyph];
	[oracleAnalogGlyph release];
	//
	// ORACLE 5
	//
	y += ORACLE_SIZE + SPACER;
	x = orax + ORACLE_SIZE + SPACER;
	// OCCULT Glyph
	frame = CGRectMake(x, y, ORACLE_SIZE, ORACLE_SIZE);
	oracleOccultGlyph = [[AvanteKinButton alloc] initWithFrame:frame];
	oracleOccultGlyph.kinType = ORACLE_OCCULT;
	oracleOccultGlyph.myVC = (UINavigationController*)self;
	[contentViewDreamspell addSubview:oracleOccultGlyph];
	[oracleOccultGlyph release];
	// OCCULT Label
	y += ORACLE_SIZE;
	str = LOCAL(@"ORACLE_OCCULT");
	frame = CGRectMake(x, y, ORACLE_SIZE, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[contentViewDreamspell addSubview:label];
	[label release];
	
	
	//
	// AFFIRMATION
	//
	// AFFIRMATION 1
	y = 232.0;
	x = 0.0;
	font = FONT_SIZE_AFFIRM;
	h = HEIGHT_FOR_LINES(font,6);
	w = kscreenWidth;
	frame = CGRectMake(x, y, w, h);
	affirmation1 = [[AvanteTextLabel alloc] init:@"affirmation1"frame:frame size:font color:[UIColor whiteColor]];
	[affirmation1 setWrap:YES];
	[contentViewDreamspell addSubview:affirmation1];
	[affirmation1 release];
}


#pragma mark GLYPH UPDATE

// UPDATE GLYPH
- (void)updateGlyph {
	// Update date
	[global updateNavDate:self];
	// Update glyph
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
	{
		contentViewMaya.hidden = FALSE;
		contentViewDreamspell.hidden = TRUE;
		[self updateMayaGlyph];
	}
	else
	{
		contentViewMaya.hidden = TRUE;
		contentViewDreamspell.hidden = FALSE;
		[self updateDreamspellGlyph];
	}
}


//////////////////////////////////////////////////////////
//
// UPDATE - MAYA
//
- (void)updateMayaGlyph {

	// GREG
	[mayaGregName update:global.cal.greg.dayNameShort];

	// LONG COUNT
	mayaIsigGlyph.image = [UIImage imageNamed:global.cal.haab.imgIsigGlyph];
	mayaBaktunNum.image = [UIImage imageNamed:global.cal.longCount.imgBaktunNum];
	mayaKatunNum.image = [UIImage imageNamed:global.cal.longCount.imgKatunNum];
	mayaTunNum.image = [UIImage imageNamed:global.cal.longCount.imgTunNum];
	mayaUinalNum.image = [UIImage imageNamed:global.cal.longCount.imgUinalNum];
	mayaKinNum.image = [UIImage imageNamed:global.cal.longCount.imgKinNum];
	
	// TZOLKIN
	mayaTzolkinNum.image = [UIImage imageNamed:global.cal.tzolkin.imgNumGlyph];
	mayaTzolkinGlyph.image = [UIImage imageNamed:global.cal.tzolkin.imgGlyph];
	
	// HAAB
	mayaHaabNum.image = [UIImage imageNamed:global.cal.haab.imgNumGlyph];
	mayaHaabGlyph.image = [UIImage imageNamed:global.cal.haab.imgGlyph];
	
	// LORD GLYPH
	mayaLordGlyph.image = [UIImage imageNamed:global.cal.haab.imgLordGlyph];
	
	// Labels
	[mayaBaktunLabel update: global.cal.longCount.nameBaktun];
	[mayaKatunLabel update: global.cal.longCount.nameKatun];
	[mayaTunLabel update: global.cal.longCount.nameTun];
	[mayaUinalLabel update: global.cal.longCount.nameUinal];
	[mayaKinLabel update: global.cal.longCount.nameKin];
	[mayaTzolkinLabel update: global.cal.tzolkin.dayNameFull];
	[mayaHaabLabel update: global.cal.haab.dayNameFull];
	[mayaLordLabel update: global.cal.haab.lordNameFull];
}


//////////////////////////////////////////////////////////
//
// UPDATE - DREAMSPELL
//
- (void)updateDreamspellGlyph {
	NSString *str = @"";
	
	// GREGORIAN
	[dreamspellGregName update:global.cal.greg.dayNameShort];

	//
	// KIN
	//
	str = [NSString stringWithFormat:@"Kin %d",global.cal.tzolkinMoon.kin];
	[kinText1 update:str];
	[kinText2 update:global.cal.tzolkinMoon.dayName1];
	[kinText3 update:global.cal.tzolkinMoon.dayName2];
	
	// MISC
	destinySealNum.image = [UIImage imageNamed:global.cal.tzolkinMoon.imgNum];
	destinySealGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.imgGlyph];
	portalGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.imgPortal];
	plasmaGlyph.image = [UIImage imageNamed:global.cal.moon.imgPlasma];
	[plasmaName update:global.cal.moon.plasmaName];
	[plasmaText update:global.cal.moon.plasmaAffirmation];
	plasmaGlyph.image = [UIImage imageNamed:global.cal.moon.imgPlasma];
	[chakraName update:global.cal.moon.chakraName];
	//moonGlyph.image = [UIImage imageNamed:global.cal.moon.imgMoonFase];
	//[moonName update:global.cal.moon.moonFaseName];
	dootText.hidden = ! global.cal.moon.doot;
	
	//
	// ORACLE
	//
	oracleGuideGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzGuide.imgGlyph];
	oracleAntipodeGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzAntipode.imgGlyph];
	oracleDestinyGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.imgGlyph];
	oracleAnalogGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzAnalog.imgGlyph];
	oracleOccultGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzOccult.imgGlyph];
	// Config Oracle buttons
	destinySealGlyph.tzolkin = global.cal.tzolkinMoon;
	oracleGuideGlyph.tzolkin = global.cal.tzolkinMoon.tzGuide;
	oracleAntipodeGlyph.tzolkin = global.cal.tzolkinMoon.tzAntipode;
	oracleDestinyGlyph.tzolkin = global.cal.tzolkinMoon;
	oracleAnalogGlyph.tzolkin = global.cal.tzolkinMoon.tzAnalog;
	oracleOccultGlyph.tzolkin = global.cal.tzolkinMoon.tzOccult;
	
	//
	// AFFIRMATION
	//
	str = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",
		   global.cal.tzolkinMoon.affirmation1,
		   global.cal.tzolkinMoon.affirmation2,
		   global.cal.tzolkinMoon.affirmation3,
		   global.cal.tzolkinMoon.affirmation4,
		   global.cal.tzolkinMoon.affirmation5,
		   global.cal.tzolkinMoon.affirmation6 ];
	[affirmation1 update:str];
}


#pragma mark ACTIONS

- (void)switchViewMode:(id)sender
{
	[global switchViewMode:mayaMoonSelector];
	// Top name
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
		self.title = LOCAL(@"TAB_GLYPH");
	else
		self.title = LOCAL(@"TAB_SIGNATURE");
	// Atualiza UI
	[self updateGlyph];
}
- (IBAction)goSettings:(id)sender {
	// stop roller
	[roller stop];
	// Create temporary vc
	SettingsVC *vc = [[SettingsVC alloc] init];
	vc.title = LOCAL(@"SETTINGS");
	vc.hidesBottomBarWhenPushed  = YES;
	[[self navigationController] pushViewController:vc animated:YES];
	[vc release];
}
- (IBAction)goInfo:(id)sender
{
	// stop roller
	[roller stop];
	// 1a vez mostra os BASICS
	if (global.prefInfoSeen == 0)
	{
		[global goInfo:INFO_BASICS vc:self];
		global.prefInfoSeen = 1;
	}
	else
		[global goInfo:(global.prefMayaDreamspell==0?INFO_MAYA_GLYPH:INFO_DREAMSPELL_KIN) vc:self];
}
- (void)goDecode:(AvanteKinButton*)but
{
	// stop roller
	[roller stop];
	// Create temporary vc
	KinDecodeVC *vc = [[KinDecodeVC alloc] initWithType:but.kinType tz:but.tzolkin destinyKin:global.cal.tzolkinMoon.kin];
	vc.hidesBottomBarWhenPushed  = YES;
    vc.prevTitle = self.title;
	[[self navigationController] pushViewController:vc animated:YES];
	[vc release];
}

#pragma mark ACTIONS

// DIA SEGUINTE
- (IBAction)julianAdd:(id)sender {
	int diff;
	if ((diff = [global.cal updateWithJulian:(int)(global.cal.julian+1)]) != 0)
	{
		// Stop roller!
		[roller stop];
		// Display error
		if (diff < 0)
			[global alertSimple:LOCAL(@"DATE_TOO_LOW")];
		else
			[global alertSimple:LOCAL(@"DATE_TOO_HIGH")];
		return;
	}
	// Update UI
	[self updateGlyph];
	// Play Sound
	if (global.prefGearSound != GEAR_SOUND_QUIET)
		[global.soundLib playWave:WAVE_TICK];
}
// DIA ANTERIOR
- (IBAction)julianSub:(id)sender {
	int diff;
	if ((diff = [global.cal updateWithJulian:(int)(global.cal.julian-1)]) != 0)
	{
		// Stop roller!
		[roller stop];
		// Display error
		if (diff < 0)
			[global alertSimple:LOCAL(@"DATE_TOO_LOW")];
		else
			[global alertSimple:LOCAL(@"DATE_TOO_HIGH")];
		return;
	}
	// Update UI
	[self updateGlyph];
	// Play Sound
	if (global.prefGearSound != GEAR_SOUND_QUIET)
		[global.soundLib playWave:WAVE_TICK];
}

#pragma mark SHARING

//
// Display Sharing alert
- (IBAction)share:(id)sender
{
	NSString *text, *body;
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
	{
		text = LOCAL(@"SHARE_EMAIL_MAYA_GLYPH");
		body = LOCAL(@"SHARE_EMAIL_BODY_MAYA_GLYPH");
	}
	else
	{
		text = LOCAL(@"SHARE_EMAIL_KIN_GLYPH");
		body = LOCAL(@"SHARE_EMAIL_BODY_KIN_GLYPH");
	}

	// show greg name
	if (!DUAL_MODE && global.prefMayaDreamspell == VIEW_MODE_MAYA)
		mayaGregName.hidden = FALSE;
	// take shot
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
		[global shareView:contentViewMaya vc:self withText:text withBody:body];
	else
		[global shareView:contentViewDreamspell vc:self withText:text withBody:body];
	// show greg name
	if (!DUAL_MODE && global.prefMayaDreamspell == VIEW_MODE_MAYA)
		mayaGregName.hidden = TRUE;
}





@end
