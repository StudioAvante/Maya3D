//
//  MayaOracleVC.m
//  Maya3D
//
//  Created by Roger on 12/12/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

//
// MAYA ORACLE
//
// Haab: Year Bearer
// Haab: Year Bearer: Good/Bad
// Haab: Month
// Haab: Month Translation
// Tzolkin: Day Meaning
// Tzolkin: Day Color
// Tzolkin: Day Direction
// Tzolkin: Day Element
// Tzolkin: Good Day To...
// Tzolkin: good day / bad day
// Tzolkin: Personality
//

//
// DREAMSPELL ORACLE
//
// Plasma: Chakra
// Plasma: Chakra affirmation
// Timecell???
// 13-Moon: Year
// 13-Moon: Year periodo (gregoriano)
// 13-Moon: Week purpose (init, ..., ripen)
// 13-Moon: Moon question
// 13-Moon: Fase da lua - bom pra que?
// Tzolkin: Kin #
// Tzolkin: TONE
// Tzolkin: Tone Desc
// Tzolkin: DAY / SEAL
// Tzolkin: Seal POWER
// Tzolkin: Day Color
// Tzolkin: Day Color purpose (init,...,ripen)
// Tzolkin: Day Color Tags
// Tzolkin: Day Color Desc
// Tzolkin: Day Direction
// Tzolkin: Day Element
// Tzolkin: Day Frase
// Tzolkin: Day Tags
// Tzolkin: Day Desc
// Destiny Oracle: position meaning < TAP!
// Destiny Oracle: position 
//

// GLYPH
//

#import "MayaOracleVC.h"
#import "TzGlobal.h"
#import "TzClock.h"
#import "AvanteTextLabel.h"
#import "AvanteRollerVertical.h"
#import "AvanteView.h"
#import "AvanteKinView.h"
#import "AvanteViewStack.h"
#import "AvanteKinButton.h"
#import "TzSoundManager.h"
#import "KinDecodeVC.h"


@implementation MayaOracleVC

@synthesize initY;

- (void)dealloc {
	// stack
	[mayaStack release];
	[dreamspellStack release];
	// views
	[mayaContentView removeFromSuperview];
	[dreamspellContentView removeFromSuperview];
	// Super
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// Apaga view apenas se nao estiver nesta tela
	if (global.currentTab != TAB_ORACLE && mayaContentView != nil)
	{
		AvLog(@"MEMORY WARNING: MayaOracleVC: DUMP contentView...");
		// Dump Maya
		[mayaStack release];
		[mayaContentView removeFromSuperview];
		mayaContentView = nil;
		// Dump Dreamspell
		[dreamspellStack release];
		[dreamspellContentView removeFromSuperview];
		dreamspellContentView = nil;
	}
	// super
    [super didReceiveMemoryWarning]; 
}


- (void)viewWillAppear:(BOOL)animated {
	// Redraw content view?
	if (mayaContentView == nil)
	{
		AvLog(@"MayaOracleVC: RELOAD contentView...");
		[self createContentViewMaya];
		[self createContentViewDreamspell];
	}
	// Pause Clock
	[global.theClock pause];
	// Usa View Mode atual
	if (mayaMoonSelector)
		mayaMoonSelector.selectedSegmentIndex = global.prefMayaDreamspell;
	// Remove LEAP DAY se estiver no modo DREAMSPELL
	[global.cal removeLeap];
	// Draw Glyph
	[self updateOracle];
	// Scroll to the top & Flash indicator
	if (!isDecoding)
		[self scrollToTop];
	isDecoding = FALSE;
	// Full screen?
	if (initY)
	{
		[self scrollToY:initY animated:FALSE];
		initY = 0.0;
	}
}
- (void)viewDidAppear:(BOOL)animated {
	global.currentTab = TAB_ORACLE;
	global.currentVC = self;
}
- (void)viewDidDisappear:(BOOL)animated {
	global.lastTab = TAB_ORACLE;
}
- (void)viewWillDisappear:(BOOL)animated {
	// Short name - para o BACK do nav controler
	self.navigationItem.title = LOCAL(@"TAB_ORACLE");
	// Se em FULL SCREEN, devolve posicao a view anterior
	if (fullScreen)
	{
		// Passa posicao Y para a view anterior
		MayaOracleVC *vc = (MayaOracleVC*) [self.navigationController.viewControllers objectAtIndex:0];
		vc.initY = [self currentScrollOffset];
	}
}

//
// init: FULLSCREEN
//
- (id)initFullScreen:(CGFloat)y
{
	fullScreen = YES;
	initY = y;
	return [self initWithNibName:@"TzFullView" bundle:nil];
}

//
// SCROLL
//
// Scroll to the top
- (void)scrollToTop
{
	[self scrollToY:0.0 animated:NO];
}
// Scrol to Kin Information
- (void)scrollToKin
{
	[self scrollToY:(dreamspellView1.heightSum + dreamspellView2.heightSum) animated:YES];
}
// Scroll to Y position & Flash indicator
- (void)scrollToY:(CGFloat)y  animated:(BOOL)animated
{
	UIScrollView *scroll;
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
		scroll = mayaContentView;
	else
		scroll = dreamspellContentView;

	// save inset (se setado mela o scroll)
	UIEdgeInsets inset = scroll.contentInset;
	[scroll setContentInset:UIEdgeInsetsZero];
	
	// scroll!
	CGRect frame = CGRectMake(0.0, y, 1.0, 1.0);
	[scroll scrollRectToVisible:frame animated:animated];
	[scroll flashScrollIndicators];
	
	//restore inset
	[scroll setContentInset:inset];
}

// Get current ScrollView offset
- (CGFloat)currentScrollOffset
{
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
		return mayaContentView.contentOffset.y;
	else
		return dreamspellContentView.contentOffset.y;
}



//////////////////////////////////////////////////////////
//
// VIEW SETUP
//
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	UIBarButtonItem *but;

	// call super - order milk
    [super viewDidLoad];
	
	// Full Screen?
	if (fullScreen)
	{
		// Area util da view
		actualViewSize = kActiveLessNav;
		contentViewSize = kActiveLessNav; 
		
		// Remove contrroles descnecessarios
		if (mayaMoonSelector)
			[mayaMoonSelector removeFromSuperview];

		// SCREENSHOT BUTTON
		but = [[UIBarButtonItem alloc]
			   //initWithImage:[global imageFromFile:@"icon_save"]
			   //style:UIBarButtonItemStylePlain
			   initWithBarButtonSystemItem:UIBarButtonSystemItemAction
			   target:self
			   action:@selector(share:)];
		self.navigationItem.rightBarButtonItem = but;
		self.navigationItem.rightBarButtonItem.enabled = TRUE;
		[but release];
	}
	else
	{
		// Area util da view
		actualViewSize = ACTUAL_VIEW_HEIGHT;
		contentViewSize = ACTUAL_VIEW_HEIGHT; 
		
		// Corrige nome
		self.title = LOCAL(@"TAB_ORACLE");
		
		// Configura switch MAYA / DREAMSPELL
		mayaMoonSelector = [global addViewModeSwitch:self];
		if (mayaMoonSelector)
			[mayaMoonSelector addTarget:self action:@selector(switchViewMode:) forControlEvents:UIControlEventValueChanged];
		
		// FULL SCREEN BUTTON
		if (0)
		{
			but = [[UIBarButtonItem alloc]
				   initWithImage:[global imageFromFile:@"icon_fullscreen"]
				   style:UIBarButtonItemStylePlain
				   target:self action:@selector(goFullScreen:)];
			self.navigationItem.rightBarButtonItem = but;
			self.navigationItem.rightBarButtonItem.enabled = TRUE;
			[but release];
		}
		else
		{
			// SCREENSHOT BUTTON
			but = [[UIBarButtonItem alloc]
				   //initWithImage:[global imageFromFile:@"icon_save"]
				   //style:UIBarButtonItemStylePlain
				   initWithBarButtonSystemItem:UIBarButtonSystemItemAction
				   target:self
				   action:@selector(share:)];
			self.navigationItem.rightBarButtonItem = but;
			self.navigationItem.rightBarButtonItem.enabled = TRUE;
			[but release];
		}
		
		// HELP BUTTON
		but = [[UIBarButtonItem alloc]
			   initWithImage:[global imageFromFile:@"icon_info"]
			   style:UIBarButtonItemStylePlain
			   target:self action:@selector(goInfo:)];
		self.navigationItem.leftBarButtonItem = but;
		self.navigationItem.leftBarButtonItem.enabled = TRUE;
		[but release];
		
		// Roller
		roller = [[AvanteRollerVertical alloc] init:0.0:actualViewSize];
		[roller addCallback:self dragLeft:@selector(julianSub:) dragRight:@selector(julianAdd:)];
		[self.view addSubview:roller];
		[roller release];
	}
	
	// Create content
	[self createContentViewMaya];
	[self createContentViewDreamspell];
}


#pragma mark DRAW MAYA

//////////////////////////////////////////////////////////
//
// DRAW - MAYA
//
- (void)createContentViewMaya {
	NSString *str;
	AvanteTextLabel *label;
	CGRect frame;
	CGFloat x, y, xx, yy;
	CGFloat w, h;
	CGFloat font;
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// MAYA CONTENT / SCROLL VIEW 1
	//
	frame = CGRectMake(0.0, 0.0, 320.0, contentViewSize);
	mayaContentView = [[UIScrollView alloc] initWithFrame:frame];
	mayaContentView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	mayaContentView.hidden = YES;
	mayaContentView.userInteractionEnabled = YES;
	mayaContentView.backgroundColor = [UIColor blackColor];
	// Add to VC
	[self.view addSubview:mayaContentView];
	[mayaContentView release];

	
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// >>> OPEN MAYA VIEW 3
	//
	mayaView3 = [[AvanteView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 500.0)];
	[mayaContentView addSubview:mayaView3];
	[mayaView3 release];
	y = 0.0;
	
	// DATA GREGORIANA
	// Ja foi criada no Maya
	// desenha apenas em modu dual
	font = FONT_SIZE_TEXT;
	h = (HEIGHT_FOR_LINES(font,1));
	x = SPACER_GAP;
	w = (320.0 - x);
	frame = CGRectMake(x, y, w, h);
	mayaGregName = [[AvanteTextLabel alloc] init:@"greg_name" frame:frame size:font color:[UIColor whiteColor]];
	[mayaGregName setAlign:ALIGN_LEFT];
	[mayaView3 addSubview:mayaGregName];
	[mayaGregName release];
	// Se nao for DUAL, esconde a data gregoriana
	if (!DUAL_MODE)
	{
		mayaGregName.hidden = true;
		[mayaContentView setContentInset:UIEdgeInsetsMake (-h, 0.0, 0.0, 0.0)];
	}
	
	// -LINE
	// jump this
	y += h;
	
	//
	// HAAB / YEAR BEARER
	//
	// - LINE
	// Year Bearer: NUM
	y += SPACER_GAP;
	x = SPACER_GAP;
	w = GLYPH_SIZE_NUM_SMALL;
	h = GLYPH_SIZE_SMALL;
	frame = CGRectMake(x, y, w, h);
	mayaYearNum = [[UIImageView alloc] initWithFrame:frame];
	[mayaView3 addSubview:mayaYearNum];
	[mayaYearNum release];
	// Year Bearer: GLYPH
	x += GLYPH_SIZE_NUM_SMALL + SPACER;
	w = GLYPH_SIZE_SMALL;
	h = GLYPH_SIZE_SMALL;
	frame = CGRectMake(x, y, w, h);
	mayaYearGlyph = [[UIImageView alloc] initWithFrame:frame];
	[mayaView3 addSubview:mayaYearGlyph];
	[mayaYearGlyph release];
	// Year Bearer: LABEL
	x += GLYPH_SIZE_SMALL + SPACER_GAP;
	yy = y + (FONT_SIZE_NAME-FONT_SIZE_LABEL);
	str = LOCAL(@"YEAR_BEARER");
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,1);
	w = WIDTH_FOR_TEXT(font,str) + SPACER_GAP;
	frame = CGRectMake(x, yy, w, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[label setAlign:ALIGN_LEFT];
	[mayaView3 addSubview:label];
	[label release];
	// Year Bearer: NAME
	xx = x + w;
	w = (320.0 - x);
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(xx, y, w, h);
	mayaYearName = [[AvanteTextLabel alloc] init:@"year_name" frame:frame size:font color:[UIColor whiteColor]];
	[mayaYearName setAlign:ALIGN_LEFT];
	[mayaView3 addSubview:mayaYearName];
	[mayaYearName release];
	// Year Bearer: DESC
	w = ( 320.0 - x - SPACER_GAP);
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	yy = y + GLYPH_SIZE_SMALL - h;
	frame = CGRectMake(x, yy, w, h);
	mayaYearDesc = [[AvanteTextLabel alloc] init:@"" frame:frame size:font color:[UIColor whiteColor]];
	[mayaYearDesc setAlign:ALIGN_LEFT];
	[mayaView3 addSubview:mayaYearDesc];
	[mayaYearDesc release];
	// Jump all
	y += GLYPH_SIZE_SMALL;
	// Da um espacinho ai...
	//y += SPACER_GAP;
	
	//
	// >>> CLOSE MAYA VIEW 3
	//
	mayaView3.heightFixed = y;
	
	

	/////////////////////////////////////////////////////////////////////////////
	//
	// >>> OPEN MAYA VIEW 2
	//
	mayaView2 = [[AvanteView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 500.0)];
	[mayaContentView addSubview:mayaView2];
	[mayaView2 release];
	y = 0.0;
	
	//
	// HAAB MONTH
	//
	// - LINE
	// Haab: NUM
	y += SPACER_GAP;
	x = SPACER_GAP;
	w = GLYPH_SIZE_NUM_SMALL;
	h = GLYPH_SIZE_SMALL;
	frame = CGRectMake(x, y, w, h);
	mayaHaabNum = [[UIImageView alloc] initWithFrame:frame];
	[mayaView2 addSubview:mayaHaabNum];
	[mayaHaabNum release];
	// Haab: GLYPH
	x += GLYPH_SIZE_NUM_SMALL + SPACER;
	w = GLYPH_SIZE_SMALL;
	h = GLYPH_SIZE_SMALL;
	frame = CGRectMake(x, y, w, h);
	mayaHaabGlyph = [[UIImageView alloc] initWithFrame:frame];
	[mayaView2 addSubview:mayaHaabGlyph];
	// Haab: LABEL
	x += GLYPH_SIZE_SMALL + SPACER_GAP;
	yy = y + (FONT_SIZE_NAME-FONT_SIZE_LABEL);
	str = LOCAL(@"HAAB_MONTH");
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,1);
	w = WIDTH_FOR_TEXT(font,str) + SPACER_GAP;
	frame = CGRectMake(x, yy, w, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[label setAlign:ALIGN_LEFT];
	[mayaView2 addSubview:label];
	[label release];
	// Haab: NAME
	xx = x + w;
	w = (320.0 - x);
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(xx, y, w, h);
	mayaHaabName = [[AvanteTextLabel alloc] init:@"haab_name" frame:frame size:font color:[UIColor whiteColor]];
	[mayaHaabName setAlign:ALIGN_LEFT];
	[mayaView2 addSubview:mayaHaabName];
	[mayaHaabName release];
	// Haab: DESC
	//x = SPACER_GAP;
	w = ( 320.0 - x - SPACER_GAP);
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	yy = y + GLYPH_SIZE_SMALL - h;
	frame = CGRectMake(x, yy, w, h);
	mayaHaabDesc = [[AvanteTextLabel alloc] init:@"haab_desc" frame:frame size:font color:[UIColor whiteColor]];
	//mayaHaabDesc.backgroundColor = [UIColor redColor];
	[mayaHaabDesc setAlign:ALIGN_LEFT];
	[mayaView2 addSubviewVar:mayaHaabDesc];
	[mayaHaabDesc release];
	// Jump all
	y += GLYPH_SIZE_SMALL;
	// Da um espacinho ai...
	//y += SPACER_GAP;
	
	//
	// >>> CLOSE MAYA VIEW 2
	//
	mayaView2.heightFixed = y;
	mayaView2.heightVar = 0;
	
	
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// OPEN MAYA VIEW 1
	//
	mayaView1 = [[AvanteView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 500.0)];
	[mayaContentView addSubview:mayaView1];
	[mayaView1 release];
	y = 0.0;
	
	//
	// TZOLKIN
	//
	// - LINE
	// Tzolkin: NUM
	y += SPACER_GAP;
	x = SPACER_GAP;
	w = GLYPH_SIZE_NUM_MED;
	h = GLYPH_SIZE_MED;
	frame = CGRectMake(x, y, w, h);
	mayaTzolkinNum = [[UIImageView alloc] initWithFrame:frame];
	[mayaView1 addSubview:mayaTzolkinNum];
	[mayaTzolkinNum release];
	// Tzolkin: GLYPH
	x += GLYPH_SIZE_NUM_MED + SPACER;
	w = GLYPH_SIZE_MED;
	h = GLYPH_SIZE_MED;
	frame = CGRectMake(x, y, w, h);
	mayaTzolkinGlyph = [[UIImageView alloc] initWithFrame:frame];
	[mayaView1 addSubview:mayaTzolkinGlyph];
	[mayaTzolkinGlyph release];
	
	// Tzolkin: LABEL
	x += GLYPH_SIZE_MED + SPACER_GAP;
	yy = y + (FONT_SIZE_NAME-FONT_SIZE_LABEL);
	str = LOCAL(@"TZOLKIN_DAY");
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,1);
	w = WIDTH_FOR_TEXT(font,str) + SPACER_GAP;
	frame = CGRectMake(x, yy, w, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[label setAlign:ALIGN_LEFT];
	[mayaView1 addSubview:label];
	[label release];

	
	// Tzolkin: NAME
	xx = x + w;
	w = (320.0 - x);
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1); 
	frame = CGRectMake(xx, y, w, h);
	mayaTzolkinName = [[AvanteTextLabel alloc] init:@"tz_name" frame:frame size:font color:[UIColor whiteColor]];
	[mayaTzolkinName setAlign:ALIGN_LEFT];
	[mayaView1 addSubview:mayaTzolkinName];
	[mayaTzolkinName release];

	
	// Tzolkin: NEWS
	yy = y + ( (GLYPH_SIZE_MED - NEWS_SIZE) / 2.0 ) - SPACER_GAP;
	xx = (320.0 - NEWS_SIZE - SPACER_GAP);
	w = NEWS_SIZE;
	h = NEWS_SIZE;
	frame = CGRectMake(xx, yy, w, h);
	mayaTzolkinNews = [[UIImageView alloc] initWithFrame:frame];
	[mayaView1 addSubview:mayaTzolkinNews];
	[mayaTzolkinNews release];
	// Tzolkin: THUMB
	yy = y;
	xx -= THUMB_SIZE;
	w = THUMB_SIZE;
	h = THUMB_SIZE;
	frame = CGRectMake(xx, yy, w, h);
	mayaTzolkinThumb = [[UIImageView alloc] initWithFrame:frame];
	mayaTzolkinThumb.hidden = true;
	[mayaView1 addSubview:mayaTzolkinThumb];
	[mayaTzolkinThumb release];
	
	// Tzolkin: ANIMAL
	font = FONT_SIZE_NAME;
	w = ( 320.0 - x - SPACER_GAP);
	h = HEIGHT_FOR_LINES(font,1);
	yy = y + GLYPH_SIZE_MED - h;
	frame = CGRectMake(x, yy, w, h);
	mayaTzolkinAnimal = [[AvanteTextLabel alloc] init:@"animal" frame:frame size:font color:[UIColor whiteColor]];
	[mayaTzolkinAnimal setAlign:ALIGN_LEFT];
	[mayaView1 addSubview:mayaTzolkinAnimal];
	[mayaTzolkinAnimal release];
	
	
	// Jump last (glyph)
	y += GLYPH_SIZE_MED;
	// -LINE
	y += SPACER_GAP;

	/*
	// Tzolkin: DESC
	x = SPACER_GAP;
	w = ( 320.0 - x - SPACER_GAP);
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	mayaTzolkinDesc = [[AvanteTextLabel alloc] init:@"element" frame:frame size:font color:[UIColor whiteColor]];
	[mayaTzolkinDesc setAlign:ALIGN_LEFT];
	[mayaView1 addSubview:mayaTzolkinDesc];
	[mayaTzolkinDesc release];
	*/

	// Tzolkin: ENERGY
	x = (SPACER_GAP*2.0);
	w = ( 320.0 - x - SPACER_GAP);
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	mayaTzolkinEnergy = [[AvanteTextLabel alloc] init:@"energy" frame:frame size:font color:[UIColor whiteColor]];
	[mayaTzolkinEnergy setAlign:ALIGN_LEFT];
	[mayaView1 addSubview:mayaTzolkinEnergy];
	[mayaTzolkinEnergy release];
	// Tzolkin: ELEMENT
	w = NEWS_SIZE;
	x = ( 320.0 - w - SPACER_GAP);
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	mayaTzolkinElement = [[AvanteTextLabel alloc] init:@"element" frame:frame size:font color:[UIColor whiteColor]];
	[mayaView1 addSubview:mayaTzolkinElement];
	[mayaTzolkinElement release];
	// Jump this
	y += font;
	// -LINE
	y += SPACER_GAP;

	// -LINE
	// Tzolkin: GOOD DAY TO...
	//y += SPACER_GAP;
	x = SPACER_GAP;
	w = ( 320.0 - x - SPACER_GAP);
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,1);
	str = LOCAL(@"GOOD_DAY_TO");
	frame = CGRectMake(x, y, w, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[label setAlign:ALIGN_LEFT];
	[mayaView1 addSubview:label];
	[label release];
	// -LINE
	// Tzolkin: GOOD DAY TO 1
	y += h;
	x = 10.0;
	w = ( 320.0 - x - SPACER_GAP);
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	mayaTzolkinGoodTo1 = [[AvanteTextLabel alloc] init:@"good1" frame:frame size:font color:[UIColor whiteColor]];
	[mayaTzolkinGoodTo1 setAlign:ALIGN_LEFT];
	[mayaView1 addSubview:mayaTzolkinGoodTo1];
	[mayaTzolkinGoodTo1 release];
	// Tzolkin: GOOD DAY TO 2
	y += h;
	frame = CGRectMake(x, y, w, h);
	mayaTzolkinGoodTo2 = [[AvanteTextLabel alloc] init:@"good2" frame:frame size:font color:[UIColor whiteColor]];
	[mayaTzolkinGoodTo2 setAlign:ALIGN_LEFT];
	[mayaView1 addSubview:mayaTzolkinGoodTo2];
	[mayaTzolkinGoodTo2 release];
	// Tzolkin: GOOD DAY TO 3
	y += h;
	frame = CGRectMake(x, y, w, h);
	mayaTzolkinGoodTo3 = [[AvanteTextLabel alloc] init:@"good3" frame:frame size:font color:[UIColor whiteColor]];
	[mayaTzolkinGoodTo3 setAlign:ALIGN_LEFT];
	[mayaView1 addSubview:mayaTzolkinGoodTo3];
	[mayaTzolkinGoodTo3 release];
	// Tzolkin: GOOD DAY TO 4
	y += h;
	frame = CGRectMake(x, y, w, h);
	mayaTzolkinGoodTo4 = [[AvanteTextLabel alloc] init:@"good4" frame:frame size:font color:[UIColor whiteColor]];
	[mayaTzolkinGoodTo4 setAlign:ALIGN_LEFT];
	[mayaView1 addSubview:mayaTzolkinGoodTo4];
	[mayaTzolkinGoodTo4 release];
	// Jump this
	y += h;
	y += SPACER_GAP;
	
	//
	// CLOSE FIXED PART
	//
	//y += SPACER_GAP;
	mayaView1.heightFixed = y;
	
	// -LINE
	// Tzolkin: PERSONALITY
	x = SPACER_GAP;
	w = ( 320.0 - x - SPACER_GAP);
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,12);
	frame = CGRectMake(x, y, w, h);
	mayaTzolkinPersonality = [[AvanteTextLabel alloc] init:@"personality" frame:frame size:font color:[UIColor whiteColor]];
	[mayaTzolkinPersonality setAlign:ALIGN_LEFT];
	[mayaTzolkinPersonality setWrap:YES];
	[mayaView1 addSubviewVar:mayaTzolkinPersonality];
	[mayaTzolkinPersonality release];
	// Jump this
	y += h;
	
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// Create View Stack Manager
	//
	mayaStack = [[AvanteViewStack alloc] init];
	[mayaStack stackView:mayaView3];
	[mayaStack stackView:mayaView2];
	[mayaStack stackView:mayaView1];

	/////////////////////////////////////////////////////////////////////////////
	//
	// RESIZE  CONTENT / SCROLL VIEW 1
	//
	// quado fizer update...
	//[mayaContentView setContentSize:CGSizeMake(320.0,mayaStack.heightSum)];
}


#pragma mark DRAW DREAMSPELL

//////////////////////////////////////////////////////////
//
// DRAW - DREAMSPELL
//
- (void)createContentViewDreamspell {
	CGAffineTransform rotate = CGAffineTransformMakeRotation (3.14/2);
	AvanteTextLabel *label;
	NSString *str;
	CGRect frame;
	CGFloat x, y, xx, yy;
	CGFloat w, h;
	CGFloat font;
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// MAYA CONTENT / SCROLL VIEW 1
	//
	frame = CGRectMake(0.0, 0.0, 320.0, contentViewSize);
	dreamspellContentView = [[UIScrollView alloc] initWithFrame:frame];
	dreamspellContentView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	dreamspellContentView.hidden = YES;
	dreamspellContentView.userInteractionEnabled = YES;
	dreamspellContentView.backgroundColor = [UIColor blackColor];
	// Add to VC
	[self.view addSubview:dreamspellContentView];
	[dreamspellContentView release];
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// OPEN DREAMSPELL VIEW 1
	//
	dreamspellView1 = [[AvanteView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 500.0)];
	[dreamspellContentView addSubview:dreamspellView1];
	[dreamspellView1 release];
	y = 0.0;
	
	// DATA GREGORIANA
	// Ja foi criada no Maya
	// desenha apenas em modu dual
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	x = SPACER_GAP;
	w = (320.0 - x);
	frame = CGRectMake(x, y, w, h);
	dreamspellGregName = [[AvanteTextLabel alloc] init:@"greg_name" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellGregName setAlign:ALIGN_LEFT];
	[dreamspellView1 addSubview:dreamspellGregName];
	[dreamspellGregName release];
	// Se nao for DUAL, esconde a data gregoriana
	if (!DUAL_MODE)
	{
		dreamspellGregName.hidden = true;
		[dreamspellContentView setContentInset:UIEdgeInsetsMake (-h, 0.0, 0.0, 0.0)];
	}
	
	// -LINE
	// jump this
	y += h;
	
	//
	// DREAMSPELL YEAR
	//
	// step away...
	y -= TONE_GAP;
	// TONE NUM
	x = SPACER_GAP;
	w = TONE_SIZE;
	h = TONE_SIZE;
	frame = CGRectMake(x, y, w, h);
	dreamspellYearNum = [[UIImageView alloc] initWithFrame:frame];
	dreamspellYearNum.transform = rotate;
	[dreamspellView1 addSubview:dreamspellYearNum];
	[dreamspellYearNum release];

	// -LINE
	y += TONE_SIZE + SPACER;
	// Year: GLYPH
	w = SEAL_SIZE;
	h = SEAL_SIZE;
	frame = CGRectMake(x, y, w, h);
	dreamspellYearGlyph = [[UIImageView alloc] initWithFrame:frame];
	[dreamspellView1 addSubview:dreamspellYearGlyph];
	[dreamspellYearGlyph release];
	// jump glyph
	x += TONE_SIZE + SPACER_GAP;
	// Year: LABEL
	w = 40.0;
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,1);
	yy = y - h;
	str = LOCAL(@"DREAMSPELL_YEAR");
	frame = CGRectMake(x, yy, w, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[label setAlign:ALIGN_LEFT];
	[dreamspellView1 addSubview:label];
	[label release];
	// Year: NAME
	w = (320.0 - x);
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	dreamspellYearName = [[AvanteTextLabel alloc] init:@"year_name" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellYearName setAlign:ALIGN_LEFT];
	[dreamspellView1 addSubview:dreamspellYearName];
	[dreamspellYearName release];
	// Year: PERIOD
	yy = y + h;
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	w = ( 320.0 - x - SPACER_GAP);
	frame = CGRectMake(x, yy, w, h);
	dreamspellYearPeriod = [[AvanteTextLabel alloc] init:@"period" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellYearPeriod setAlign:ALIGN_LEFT];
	[dreamspellView1 addSubview:dreamspellYearPeriod];
	[dreamspellYearPeriod release];
	
	// -LINE
	// Jump Glyphs
	y += TONE_SIZE + SPACER_GAP;
	
	//
	// CLOSE FIXED PART
	//
	dreamspellView1.heightFixed = y;
	
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// >>> OPEN DREAMSPELL VIEW 2
	//
	dreamspellView2 = [[AvanteView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 500.0)];
	[dreamspellContentView addSubview:dreamspellView2];
	[dreamspellView2 release];
	y = 0.0;
	
	//
	// DREAMSPELL MONTH
	//
	// step away...
	y -= 10.0;
	// TONE NUM
	x = SPACER_GAP;
	w = TONE_SIZE;
	h = TONE_SIZE;
	frame = CGRectMake(x, y, w, h);
	dreamspellMonthNum = [[UIImageView alloc] initWithFrame:frame];
	dreamspellMonthNum.transform = rotate;
	[dreamspellView2 addSubview:dreamspellMonthNum];
	[dreamspellMonthNum release];

	// -LINE
	y += TONE_SIZE + SPACER;
	// Moon Fase: GLYPH
	w = MOON_FASE_SIZE;
	h = MOON_FASE_SIZE;
	frame = CGRectMake(x, y, w, h);
	dreamspellMoonFase = [[UIImageView alloc] initWithFrame:frame];
	[dreamspellView2 addSubview:dreamspellMoonFase];
	[dreamspellMoonFase release];
	// jump glyphs
	x += MOON_FASE_SIZE + SPACER_GAP;
	// Month: LABEL
	w = 100.0;
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,1);
	yy = y - h;
	str = LOCAL(@"DREAMSPELL_MONTH");
	frame = CGRectMake(x, yy, w, h);
	dreamspellMonthLabel = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellMonthLabel setAlign:ALIGN_LEFT];
	[dreamspellView2 addSubview:dreamspellMonthLabel];
	[dreamspellMonthLabel release];
	// Month: NAME
	w = (320.0 - x - PLASMA_SIZE - SPACER_GAP - SPACER_GAP);
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	dreamspellMonthName = [[AvanteTextLabel alloc] init:@"month_name" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellMonthName setAlign:ALIGN_LEFT];
	[dreamspellMonthName setFit:YES];
	[dreamspellView2 addSubview:dreamspellMonthName];
	[dreamspellMonthName release];
	// Month: DAY NAME
	yy = y + h - 5.0;
	w = (320.0 - x);
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, yy, w, h);
	dreamspellMonthDayName = [[AvanteTextLabel alloc] init:@"day_name" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellMonthDayName setAlign:ALIGN_LEFT];
	[dreamspellView2 addSubview:dreamspellMonthDayName];
	[dreamspellMonthDayName release];
	// Moon: PLASMA
	x = (320.0 - PLASMA_SIZE - SPACER_GAP - SPACER_GAP);
	h = PLASMA_SIZE;
	w = PLASMA_SIZE;
	yy = y - 5.0;
	frame = CGRectMake(x, yy, h, w);
	dreamspellPlasma = [[UIImageView alloc] initWithFrame:frame];
	[dreamspellView2 addSubview:dreamspellPlasma];
	[dreamspellPlasma release];
	// Moon: PLASMA NAME
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,1);
	w = 50.0;
	x += ( (PLASMA_SIZE-w) / 2.0);
	yy += PLASMA_SIZE + SPACER;
	frame = CGRectMake(x, yy, w, h);
	dreamspellPlasmaName = [[AvanteTextLabel alloc] init:@"plasma" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellView2 addSubview:dreamspellPlasmaName];
	[dreamspellPlasmaName release];

	// -LINE
	// jump moon glyph
	y += MOON_FASE_SIZE + SPACER_GAP;
	
	// Month: POWER
	/*
	x = SPACER_GAP;
	w = ( 160.0 - x);
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	dreamspellMonthPower = [[AvanteTextLabel alloc] init:@"power" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellMonthPower setAlign:ALIGN_LEFT];
	[dreamspellView2 addSubviewVar:dreamspellMonthPower];
	[dreamspellMonthPower release];
	// Month: ACTION
	x += 160.0;
	w = 160.0;
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	dreamspellMonthAction = [[AvanteTextLabel alloc] init:@"action" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellMonthAction setAlign:ALIGN_LEFT];
	[dreamspellView2 addSubviewVar:dreamspellMonthAction];
	[dreamspellMonthAction release];
	// - LINE
	y += h + SPACER_GAP;
	 */
	
	// Month: PURPOSE
	/*
	x = SPACER_GAP;
	w = ( 320.0 - x);
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(x, y, w, h);
	dreamspellPurpose = [[AvanteTextLabel alloc] init:@"purpose" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellPurpose setAlign:ALIGN_LEFT];
	[dreamspellPurpose setWrap:YES];
	[dreamspellView2 addSubviewVar:dreamspellPurpose];
	[dreamspellPurpose release];
	// jump this
	y += h;
	 */
	
	//
	// CLOSE FIXED PART
	//
	dreamspellView2.heightFixed = y;
	
	// Month: QUESTION
	x = SPACER_GAP;
	w = ( 320.0 - x);
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,2);
	frame = CGRectMake(x, y, w, h);
	dreamspellMonthQuestion = [[AvanteTextLabel alloc] init:@"question" frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellMonthQuestion setAlign:ALIGN_LEFT];
	[dreamspellMonthQuestion setWrap:YES];
	[dreamspellView2 addSubviewVar:dreamspellMonthQuestion];
	[dreamspellMonthQuestion release];


	/////////////////////////////////////////////////////////////////////////////
	//
	// >>> OPEN DREAMSPELL 3 - KIN VIEW
	//
	kinView = [[AvanteKinView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 500.0)];
	[dreamspellContentView addSubview:kinView];
	[kinView release];
	// Get actual size
	y = [kinView setupView];
	kinView.heightFixed = y;

	
	/////////////////////////////////////////////////////////////////////////////
	//
	// >>> OPEN DREAMSPELL VIEW 4
	//
	dreamspellView4 = [[AvanteView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 500.0)];
	[dreamspellContentView addSubview:dreamspellView4];
	[dreamspellView4 release];
	y = 0.0;
	
	//
	// AFFIRMATION
	//
	// AFFIRMATION LABEL
	y += SPACER_GAP;
	x = 0.0;
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	w = 320.0;
	str = LOCAL(@"DREAMSPELL_AFFIRM");
	frame = CGRectMake(x, y, w, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellView4 addSubview:label];
	[label release];
	// AFFIRMATION 1
	y += h + SPACER_GAP;
	x = 0.0;
	font = FONT_SIZE_AFFIRM;
	h = HEIGHT_FOR_LINES(font,6);
	w = 320.0;
	frame = CGRectMake(x, y, w, h);
	affirmation1 = [[AvanteTextLabel alloc] init:@"affirmation1" frame:frame size:font color:[UIColor whiteColor]];
	[affirmation1 setWrap:YES];
	[dreamspellView4 addSubview:affirmation1];
	[affirmation1 release];

	// - LINE
	y += h + SPACER_GAP;
	
	// ORACLE LABEL 1
	x = SPACER_GAP;
	font = FONT_SIZE_TEXT;
	h = HEIGHT_FOR_LINES(font,1);
	w = 100.0;
	str = LOCAL(@"DREAMSPELL_ORACLE");
	frame = CGRectMake(x, y, w, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[label setAlign:ALIGN_LEFT];
	[dreamspellView4 addSubview:label];
	[label release];
	// ORACLE LABEL 2
	yy = y + h;
	x = SPACER_GAP;
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,2);
	w = 120.0;
	str = LOCAL(@"DREAMSPELL_ORACLE_TAP");
	frame = CGRectMake(x, yy, w, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[label setAlign:ALIGN_LEFT];
	[label setWrap:YES];
	[dreamspellView4 addSubview:label];
	[label release];
	
	
	//            1
	// ORACLE = 2 3 4
	//            5
	x = ( 320.0 - (ORACLE_SIZE*3.0) - (SPACER*2.0) ) / 2.0;
	font = FONT_SIZE_LABEL;
	h = HEIGHT_FOR_LINES(font,1);
	//
	// ORACLE 1
	//
	xx = x + ORACLE_SIZE + SPACER;
	// GUIDE Label
	str = LOCAL(@"ORACLE_GUIDE");
	frame = CGRectMake(xx, y, ORACLE_SIZE, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellView4 addSubview:label];
	[label release];
	// ORACLE - GUIDE Num
	y += h;
	y -= TONE_GAP;
	frame = CGRectMake(xx+((ORACLE_SIZE-TONE_SIZE)/2.0), y, TONE_SIZE, TONE_SIZE);
	oracleGuideNum = [[UIImageView alloc] initWithFrame:frame];
	oracleGuideNum.transform = rotate;
	[dreamspellView4 addSubview:oracleGuideNum];
	[oracleGuideNum release];
	y += TONE_SIZE;
	// ORACLE - GUIDE Glyph
	frame = CGRectMake(xx, y, ORACLE_SIZE, ORACLE_SIZE);
	oracleGuideGlyph = [[AvanteKinButton alloc] initWithFrame:frame];
	oracleGuideGlyph.kinType = ORACLE_GUIDE;
	oracleGuideGlyph.myVC = (UINavigationController*)self;
	[dreamspellView4 addSubview:oracleGuideGlyph];
	[oracleGuideGlyph release];
	//
	// ORACLE 2
	//
	y += ORACLE_SIZE + SPACER;
	// ANTIPODE Label
	str = LOCAL(@"ORACLE_ANTIPODE");
	frame = CGRectMake(x, y-h, ORACLE_SIZE, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellView4 addSubview:label];
	[label release];
	// ANTIPODE Num
	yy = y - TONE_GAP;
	frame = CGRectMake(x+((ORACLE_SIZE-TONE_SIZE)/2.0), yy, TONE_SIZE, TONE_SIZE);
	oracleAntipodeNum = [[UIImageView alloc] initWithFrame:frame];
	oracleAntipodeNum.transform = rotate;
	[dreamspellView4 addSubview:oracleAntipodeNum];
	[oracleAntipodeNum release];
	// ANTIPODE Glyph
	yy += TONE_SIZE;
	frame = CGRectMake(x, yy, ORACLE_SIZE, ORACLE_SIZE);
	oracleAntipodeGlyph = [[AvanteKinButton alloc] initWithFrame:frame];
	oracleAntipodeGlyph.kinType = ORACLE_ANTIPODE;
	oracleAntipodeGlyph.myVC = (UINavigationController*)self;
	[dreamspellView4 addSubview:oracleAntipodeGlyph];
	[oracleAntipodeGlyph release];
	//
	// ORACLE 3
	//
	xx = x + ORACLE_SIZE + SPACER;
	// DESTINY Num
	yy = y - TONE_GAP;
	frame = CGRectMake(xx+((ORACLE_SIZE-TONE_SIZE)/2.0), yy, TONE_SIZE, TONE_SIZE);
	oracleDestinyNum = [[UIImageView alloc] initWithFrame:frame];
	oracleDestinyNum.transform = rotate;
	[dreamspellView4 addSubview:oracleDestinyNum];
	[oracleDestinyNum release];
	// DESTINY Glyph
	yy += TONE_SIZE;
	frame = CGRectMake(xx, yy, ORACLE_SIZE, ORACLE_SIZE);
	oracleDestinyGlyph = [[UIImageView alloc] initWithFrame:frame];
	[dreamspellView4 addSubview:oracleDestinyGlyph];
	[oracleDestinyGlyph release];
	//
	// ORACLE 4
	//
	xx += ORACLE_SIZE + SPACER;
	// ANALOG Label
	str = LOCAL(@"ORACLE_ANALOG");
	frame = CGRectMake(xx, y-h, ORACLE_SIZE, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellView4 addSubview:label];
	[label release];
	// ANALOG Num
	yy = y - TONE_GAP;
	frame = CGRectMake(xx+((ORACLE_SIZE-TONE_SIZE)/2.0), yy, TONE_SIZE, TONE_SIZE);
	oracleAnalogNum = [[UIImageView alloc] initWithFrame:frame];
	oracleAnalogNum.transform = rotate;
	[dreamspellView4 addSubview:oracleAnalogNum];
	[oracleAnalogNum release];
	// ANALOG Glyph
	yy += TONE_SIZE;
	frame = CGRectMake(xx, yy, ORACLE_SIZE, ORACLE_SIZE);
	oracleAnalogGlyph = [[AvanteKinButton alloc] initWithFrame:frame];
	oracleAnalogGlyph.kinType = ORACLE_ANALOG;
	oracleAnalogGlyph.myVC = (UINavigationController*)self;
	[dreamspellView4 addSubview:oracleAnalogGlyph];
	[oracleAnalogGlyph release];
	//
	// ORACLE 5
	//
	y += ORACLE_SIZE + TONE_SIZE - TONE_GAP + SPACER;
	xx = x + ORACLE_SIZE + SPACER;
	// OCCULT Num
	y -= TONE_GAP;
	frame = CGRectMake(xx+((ORACLE_SIZE-TONE_SIZE)/2.0), y, TONE_SIZE, TONE_SIZE);
	oracleOccultNum = [[UIImageView alloc] initWithFrame:frame];
	oracleOccultNum.transform = rotate;
	[dreamspellView4 addSubview:oracleOccultNum];
	[oracleOccultNum release];
	// OCCULT Glyph
	y += TONE_SIZE;
	frame = CGRectMake(xx, y, ORACLE_SIZE, ORACLE_SIZE);
	oracleOccultGlyph = [[AvanteKinButton alloc] initWithFrame:frame];
	oracleOccultGlyph.kinType = ORACLE_OCCULT;
	oracleOccultGlyph.myVC = (UINavigationController*)self;
	[dreamspellView4 addSubview:oracleOccultGlyph];
	[oracleOccultGlyph release];
	// OCCULT Label
	y += ORACLE_SIZE;
	str = LOCAL(@"ORACLE_OCCULT");
	frame = CGRectMake(xx, y, ORACLE_SIZE, h);
	label = [[AvanteTextLabel alloc] init:str frame:frame size:font color:[UIColor whiteColor]];
	[dreamspellView4 addSubview:label];
	[label release];
	// jump label
	y += h;
	// daum espacinho ai...
	y += SPACER_GAP;
	
	//
	// >>> CLOSE DREAMSPELL VIEW 4
	//
	dreamspellView4.heightFixed = y;
	
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// Create View Stack Manager
	//
	dreamspellStack = [[AvanteViewStack alloc] init];
	[dreamspellStack stackView:dreamspellView1];
	[dreamspellStack stackView:dreamspellView2];
	[dreamspellStack stackView:kinView];
	[dreamspellStack stackView:dreamspellView4];
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// RESIZE  CONTENT / SCROLL VIEW 1
	//
	// quado fizer update...
	//[dreamspellContentView setContentSize:CGSizeMake(320.0,dreamspellStack.heightSum)];
}


#pragma mark UPDATE

// UPDATE GLYPH
- (void)updateOracle {
	// Update date
	[global updateNavDate:self];
	// Update Oracle
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
	{
		mayaContentView.hidden = NO;
		dreamspellContentView.hidden = YES;
		[self updateOracleMaya];
	}
	else
	{
		mayaContentView.hidden = YES;
		dreamspellContentView.hidden = NO;
		[self updateOracleDreamspell];
	}
}

//////////////////////////////////////////////////////////
//
// UPDATE - MAYA
//
- (void)updateOracleMaya
{
	NSString *str;

	// GREGORIAN
	[mayaGregName update: global.cal.greg.dayNameFull];

	// YEAR
	mayaYearNum.image = [UIImage imageNamed:global.cal.haab.tzYear.imgNumGlyph];
	mayaYearGlyph.image = [UIImage imageNamed:global.cal.haab.tzYear.imgGlyph];
	//str = [NSString stringWithFormat:@"%@ - %@",global.cal.haab.tzYear.dayNameFull,global.cal.haab.yearDesc];
	[mayaYearName update: global.cal.haab.tzYear.dayNameFull];
	[mayaYearDesc update: global.cal.haab.yearDesc];
	
	// HAAB
	mayaHaabNum.image = [UIImage imageNamed:global.cal.haab.imgNumGlyph];
	mayaHaabGlyph.image = [UIImage imageNamed:global.cal.haab.imgGlyph];
	[mayaHaabName update: global.cal.haab.dayNameFull];
	[mayaHaabDesc update: global.cal.haab.uinalDesc];
	
	// TZOLKIN
	mayaTzolkinNum.image = [UIImage imageNamed:global.cal.tzolkin.imgNumGlyph];
	mayaTzolkinGlyph.image = [UIImage imageNamed:global.cal.tzolkin.imgGlyph];
	mayaTzolkinNews.image = [UIImage imageNamed:global.cal.tzolkin.imgNews];
	mayaTzolkinThumb.image = [UIImage imageNamed:global.cal.tzolkin.imgThumb];
	[mayaTzolkinName update: global.cal.tzolkin.dayNameFull];
	[mayaTzolkinDesc update: global.cal.tzolkin.dayMeaning];
	[mayaTzolkinAnimal update: global.cal.tzolkin.dayAnimal];
	[mayaTzolkinEnergy update: global.cal.tzolkin.dayEnergy];
	[mayaTzolkinElement update: global.cal.tzolkin.elementName];
	// Good day to...
	str = [NSString stringWithFormat:@"- %@", global.cal.tzolkin.goodDayTo1];
	[mayaTzolkinGoodTo1 update: str];
	str = [NSString stringWithFormat:@"- %@", global.cal.tzolkin.goodDayTo2];
	[mayaTzolkinGoodTo2 update: str];
	str = [NSString stringWithFormat:@"- %@", global.cal.tzolkin.goodDayTo3];
	[mayaTzolkinGoodTo3 update: str];
	str = [NSString stringWithFormat:@"- %@", global.cal.tzolkin.goodDayTo4];
	[mayaTzolkinGoodTo4 update: str];
	// Personality
	str = [NSString stringWithFormat:@"%@ %@",LOCAL(@"PERSONALITY"),global.cal.tzolkin.personality];
	[mayaTzolkinPersonality update: str];
	
	// Resize STACK
	mayaView1.heightVar = mayaTzolkinPersonality.height + SPACER_GAP;
	//mayaView2.heightVar = mayaHaabDesc.height;
	[mayaStack resize];
	
	// Resize SCROLL View
	[mayaContentView setContentSize:CGSizeMake(320.0,mayaStack.heightSum)];
}


//////////////////////////////////////////////////////////
//
// UPDATE - DREAMSPELL
//
- (void)updateOracleDreamspell
{
	NSString *str;

	// GREGORIAN
	[dreamspellGregName update: global.cal.greg.dayNameFull];

	// VIEW 1 - YEAR
	dreamspellYearNum.image = [UIImage imageNamed:global.cal.moon.tzYear.imgNum];
	dreamspellYearGlyph.image = [UIImage imageNamed:global.cal.moon.tzYear.imgGlyph];
	[dreamspellYearName update: global.cal.moon.tzYear.dayNameFull];
	[dreamspellYearPeriod update: global.cal.moon.yearPeriod];
	
	// VIEW 2 - MONTH
	dreamspellMonthNum.image = [UIImage imageNamed: global.cal.moon.imgNum];
	dreamspellMoonFase.image = [UIImage imageNamed: global.cal.moon.imgMoonFase];
	dreamspellPlasma.image = [UIImage imageNamed: global.cal.moon.imgPlasma];
	[dreamspellMonthLabel update: global.cal.moon.moonNumberLabel];
	[dreamspellMonthName update: global.cal.moon.moonNameFull];
	[dreamspellMonthDayName update: global.cal.moon.dayName];
	[dreamspellPlasmaName update: global.cal.moon.plasmaName];
	[dreamspellMonthQuestion update: global.cal.moon.moonQuestion];
	//[dreamspellMonthPower update: global.cal.moon.moonPowerFull];
	//[dreamspellMonthAction update: global.cal.moon.moonActionFull];
	//[dreamspellPurpose update: global.cal.moon.weekPurpose];

	// VIEW 3 - KIN
	[kinView updateView:global.cal.tzolkinMoon];
	
	// VIEW 4 - ORACLE
	oracleGuideNum.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzGuide.imgNum];
	oracleAntipodeNum.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzAntipode.imgNum];
	oracleDestinyNum.image = [UIImage imageNamed:global.cal.tzolkinMoon.imgNum];
	oracleAnalogNum.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzAnalog.imgNum];
	oracleOccultNum.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzOccult.imgNum];
	oracleGuideGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzGuide.imgGlyph];
	oracleAntipodeGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzAntipode.imgGlyph];
	oracleDestinyGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.imgGlyph];
	oracleAnalogGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzAnalog.imgGlyph];
	oracleOccultGlyph.image = [UIImage imageNamed:global.cal.tzolkinMoon.tzOccult.imgGlyph];
	// Config Oracle buttons
	oracleGuideGlyph.tzolkin = global.cal.tzolkinMoon.tzGuide;
	oracleAntipodeGlyph.tzolkin = global.cal.tzolkinMoon.tzAntipode;
	oracleAnalogGlyph.tzolkin = global.cal.tzolkinMoon.tzAnalog;
	oracleOccultGlyph.tzolkin = global.cal.tzolkinMoon.tzOccult;
	// AFFIRMATION
	str = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",
		   global.cal.tzolkinMoon.affirmation1,
		   global.cal.tzolkinMoon.affirmation2,
		   global.cal.tzolkinMoon.affirmation3,
		   global.cal.tzolkinMoon.affirmation4,
		   global.cal.tzolkinMoon.affirmation5,
		   global.cal.tzolkinMoon.affirmation6 ];
	[affirmation1 update:str];
	
	// Resize STACK
	dreamspellView2.heightVar = dreamspellMonthQuestion.height;
	[dreamspellStack resize];
	
	// Resize SCROLL View
	[dreamspellContentView setContentSize:CGSizeMake(320.0,dreamspellStack.heightSum)];
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
			[global alertSimple: LOCAL(@"DATE_TOO_LOW")];
		else
			[global alertSimple: LOCAL(@"DATE_TOO_HIGH")];
		return;
	}
	// Atualiza UI
	//[self scrollToTop];
	[self updateOracle];
	AvLog(@"SCROLL: y[%.2f]",[self currentScrollOffset]);
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
			[global alertSimple: LOCAL(@"DATE_TOO_LOW")];
		else
			[global alertSimple: LOCAL(@"DATE_TOO_HIGH") ];
		return;
	}
	// Atualiza UI
	//[self scrollToTop];
	[self updateOracle];
	// Play Sound
	if (global.prefGearSound != GEAR_SOUND_QUIET)
		[global.soundLib playWave:WAVE_TICK];
}

#pragma mark ACTIONS

- (void)switchViewMode:(id)sender
{
	[global switchViewMode:mayaMoonSelector];
	// Atualiza UI
	[self scrollToTop];
	[self updateOracle];
}
- (IBAction)goFullScreen:(id)sender {
	// stop roller
	[roller stop];
	// Create temporary vc
	MayaOracleVC *vc = [[MayaOracleVC alloc] initFullScreen:[self currentScrollOffset]];
	vc.hidesBottomBarWhenPushed  = YES;
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
		vc.title = LOCAL(@"MAYA_ORACLE");
	else
		vc.title = LOCAL(@"ORACLE_SELO_DESTINY");
	// Push!!
	[[self navigationController] pushViewController:vc animated:YES];
	// Release!
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
		[global goInfo:(global.prefMayaDreamspell==0?INFO_MAYA_ORACLE:INFO_DREAMSPELL_ORACLE) vc:self];
}
- (void)goDecode:(AvanteKinButton*)but
{
	// stop roller
	[roller stop];
	// Create temporary vc
	KinDecodeVC *vc = [[KinDecodeVC alloc] initWithType:but.kinType tz:but.tzolkin destinyKin:global.cal.tzolkinMoon.kin];
	vc.hidesBottomBarWhenPushed  = YES;
	[[self navigationController] pushViewController:vc animated:YES];
	[vc release];
	// Remember gone into decoding...
	isDecoding = YES;
}

#pragma mark SHARING

//
// Display Sharing alert
- (IBAction)share:(id)sender
{
	NSString *text, *body;
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
	{
		text = LOCAL(@"SHARE_EMAIL_MAYA_ORACLE");
		body = LOCAL(@"SHARE_EMAIL_BODY_MAYA_ORACLE");
	}
	else
	{
		text = LOCAL(@"SHARE_EMAIL_KIN_ORACLE");
		body = LOCAL(@"SHARE_EMAIL_BODY_KIN_ORACLE");
	}
	
	// Separa a view correta
	UIScrollView *view;
	UIEdgeInsets origInset = UIEdgeInsetsZero;
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
	{
		view = mayaContentView;
		// display greg name
		if (!DUAL_MODE)
		{
			mayaGregName.hidden = FALSE;
			origInset = mayaContentView.contentInset;
			mayaContentView.contentInset = UIEdgeInsetsZero;
		}
	}
	else
	{
		view = dreamspellContentView;
		// display greg name
		if (!DUAL_MODE)
		{
			dreamspellGregName.hidden = FALSE;
			origInset = dreamspellContentView.contentInset;
			dreamspellContentView.contentInset = UIEdgeInsetsZero;
		}
	}
	
	// Usa tamanho do content
	CGPoint offset = view.contentOffset;
	CGRect frame = view.frame;
	CGFloat h = frame.size.height;
	frame.size.height = view.contentSize.height;
	view.frame = frame;
	view.showsVerticalScrollIndicator = NO;

	// Click!
	[global shareView:view vc:self withText:text withBody:body];
	
	// Volta tamanho original
	frame.size.height = h;
	view.frame = frame;
	view.showsVerticalScrollIndicator = YES;
	view.contentOffset = offset;
	
	// Hide greg name
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA && !DUAL_MODE)
	{
		mayaGregName.hidden = TRUE;
		mayaContentView.contentInset = origInset;
	}
	else if (global.prefMayaDreamspell == VIEW_MODE_DREAMSPELL && !DUAL_MODE)
	{
		dreamspellGregName.hidden = TRUE;
		dreamspellContentView.contentInset = origInset;
	}
}



@end
