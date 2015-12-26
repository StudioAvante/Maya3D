//
//  TzViewController.m
//  Maya3D
//
//  Created by Roger on 01/11/08.
//  Copyright Studio Avante 2008. All rights reserved.
//

#import "MayaExplorerVC.h"
#import "TzGlobal.h"
#import "TzDatebook.h"
#import "TzClock.h"
#import "SettingsVC.h"
#import "DatebookVC.h"
#import "DateAddVC.h"
#import "DatePickerVC.h"
#import "TzSoundManager.h"

#define SPACER					4.0		// multiplo de 4
#define LABEL_FONT_SIZE			16.0
#define LABEL_FONT_SIZE_MINI	13.0
#define DATA_FONT_SIZE			16.0
#define TEXT_FIELD_SIZE			22.0
#define TEXT_FIELD_GAP			(floor(((TEXT_FIELD_SIZE-DATA_FONT_SIZE)/2)))
#define BUTTON_SIZE				25.0
#define BUTTON_GAP				(floor(((TEXT_FIELD_SIZE-BUTTON_SIZE)/2)))
#define GLYPH_SIZE_SMALL		40.0
#define PLASMA_SIZE				28.0
#define MOON_FASE_SIZE			40.0

@implementation MayaExplorerVC

- (void)dealloc {
	// Release content View
	[contentView removeFromSuperview];
	// super
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)didReceiveMemoryWarning
{
	// Apaga view apenas se nao estiver nesta tela
	if (global.currentTab != TAB_EXPLORER && contentView)
	{
		AvLog(@"MEMORY WARNING: MayaExplorerVC: DUMP contentView...");
		[contentView removeFromSuperview];
		contentView = nil;
	}
	
	// super
    [super didReceiveMemoryWarning];
}


#pragma mark UIViewDelegate

//
// METODOS ORIGINAIS QUE PODEM SER HERDADOS
//

// ROGER
- (void)viewWillAppear:(BOOL)animated {
	// Reload view? 
	if (contentView == nil)
	{
		AvLog(@"MayaExplorerVC: RELOAD contentView...");
		[self createContentView];
	}
	// Pause Clock
	[global.theClock pause];
	// Remove LEAP DAY se estiver no modo DREAMSPELL
	[global.cal removeLeap];
	// Caso tenha mudado o formato de data, atualiza o cal
	[global.cal updateWithJulian:global.cal.julian secs:global.cal.secs];
	// Usa View Mode atual
	if (mayaMoonSelector)
		mayaMoonSelector.selectedSegmentIndex = global.prefMayaDreamspell;
	// Atualiza UI
	[self updateUI];
}
- (void)viewDidAppear:(BOOL)animated {
	// Save Current Tab
	global.currentTab = TAB_EXPLORER;
	global.currentVC = self;
	// Title
	[self navigationController].navigationBar.topItem.title = LOCAL(@"TAB_EXPLORER");
	// Flash scroll
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
		[contentView flashScrollIndicators];
	// Detect location?
	if (global.prefHemisphere == HEMISPHERE_UNKNOWN)
		[global alertLocation:self];
}
- (void)viewWillDisappear:(BOOL)animated {
	// Title
	//[self navigationController].navigationBar.backItem.title = @"xx";
	[self navigationController].navigationBar.topItem.title = LOCAL(@"TAB_EXPLORER");
	// just in case...
	[global uncoverAll];
}
- (void)viewDidDisappear:(BOOL)animated {
	// Save Last Tab
	global.lastTab = TAB_EXPLORER;
}

// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) == nil)
		return nil;
	AvLog(@"MAYA EXPLORER: initWithNibName");
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// ADD RULER
	//UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphone_ruler.png"]];
	//iv.frame = CGRectMake(0.0, 0.0, kscreenWidth, 480.0);
	//[self.view addSubview:iv];
	
	// Corrige nome 
	self.title = LOCAL(@"TAB_EXPLORER");
	
	// Configura switch MAYA / DREAMSPELL
	mayaMoonSelector = [global addViewModeSwitch:self];
	if (mayaMoonSelector)
		[mayaMoonSelector addTarget:self action:@selector(switchViewMode:) forControlEvents:UIControlEventValueChanged];

	// SETTINGS BUTTON
	UIBarButtonItem *but;
	but = [[UIBarButtonItem alloc]
		   initWithImage:[global imageFromFile:@"icon_settings"]
		   style:UIBarButtonItemStylePlain
		   target:self action:@selector(goSettings:)];
    [but setTintColor:[UIColor whiteColor]];
	self.navigationItem.leftBarButtonItem = but;
	self.navigationItem.leftBarButtonItem.enabled = TRUE;
	[but release];
	
	// ADD BUTTON
	but = [[UIBarButtonItem alloc]
		   initWithImage:[global imageFromFile:@"icon_datebook_add"]
		   style:UIBarButtonItemStylePlain
		   target:self action:@selector(addDate:)];
    [but setTintColor:[UIColor whiteColor]];    
	self.navigationItem.rightBarButtonItem = but;
	self.navigationItem.rightBarButtonItem.enabled = TRUE;
	[but release];
	
	// TODAY BUTTON
	if (!DUAL_MODE)
	{
		// make toolbar
		UIButton *todayButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0,-1, 120.0, kToolBarButtonHeight)];
		todayButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		todayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		todayButton.backgroundColor = [UIColor clearColor];
        todayButton.tintColor = [UIColor whiteColor];
		// iPhone OS 2.2.1 (deprecated)
		//todayButton.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
		todayButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
		[todayButton setTitle:LOCAL(@"GO_TODAY") forState:UIControlStateNormal];
		[todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[todayButton addTarget:self action:@selector(goToday:) forControlEvents:UIControlEventTouchUpInside];
		// button images
		UIImage *imgUp = [[UIImage imageNamed:@"buttonTemplateUp.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
		[todayButton setBackgroundImage:imgUp forState:UIControlStateNormal];
		UIImage *imgDown = [[UIImage imageNamed:@"buttonTemplateDown.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
		[todayButton setBackgroundImage:imgDown forState:UIControlStateHighlighted];
		// add
		self.navigationItem.titleView = todayButton;
		[todayButton release];
	}
	
	// SETUP!
	[self createContentView];
}


//
// SETUP
//
- (void)createContentView {
	// General
	AvanteTextLabel *label = nil;
	UIButton *button;
	CGFloat x = 0.0, y = 0.0;
	CGFloat w = 0.0, h = 0.0;
	CGFloat ww = 0.0, hh = 0.0;
	CGFloat fontSize = 0.0;
	NSString *str = @"";
	CGRect frame;
	
	//
	// CONTENT VIEW
	//
	frame = CGRectMake(0.0, 0.0, kscreenWidth, (kActiveLessNavTab - kRollerVerticalHeight));
    
    if( contentView)
    {
        [contentView removeFromSuperview];
        contentView = nil;
    }
    
	contentView = [[UIScrollView alloc] initWithFrame:frame];
	contentView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	contentView.userInteractionEnabled = YES;
	contentView.backgroundColor = [UIColor blackColor];
	[contentView setContentSize:frame.size];
	[self.view addSubview:contentView];
	[contentView release];
	
	// Cria botao do tipo UIButtonTypeDetailDisclosure para pegar sua imagem
	// pois crio usando o tipo UIButtonTypeInfoLight que tem uma area de toque maior
	UIImage *questionImg = [global imageFromFile:@"icon_info2"];
	UIImage *searchImg = [global imageFromFile:@"icon_search"];
	
	// MOON FASE IMAGE
	if (MAYA_ONLY)
	{
		frame = CGRectMake(250.0, 20.0, 50.0, 50.0);
		moonFaseMaya = [[UIImageView alloc] initWithFrame:frame];
		[contentView addSubview:moonFaseMaya];
		[moonFaseMaya release];
	}
	
	//
	// DATA GREGORIANA
	//
	// INFO BUTTON
	x += SPACER;
	y += SPACER;
	button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	button.frame = CGRectMake(x, y, BUTTON_SIZE, BUTTON_SIZE);
	button.backgroundColor = [UIColor clearColor];
    button.tintColor  =[UIColor whiteColor];
	[button setImage:questionImg forState:UIControlStateNormal];
	[button addTarget:self action:@selector(infoGreg:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:button];
	//[button release];
	// LABEL
	x += BUTTON_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"GREGORIAN_DATE");
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// DATA
	x = SPACER + BUTTON_SIZE + SPACER;
	y += hh;
	w = 150.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"";
	gregField = [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	[gregField addTarget:self action:@selector(pickGregorian:)];	
	[contentView addSubview:gregField];
	ww = gregField.bounds.size.width;
	[gregField release];
	// DATA - NAME
	x += (SPACER/2);
	w = 100.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"gregname";
	gregNameField = [[AvanteTextLabel alloc] init:str x:x y:y w:w h:h size:fontSize color:[UIColor blackColor]];
	gregNameField.userInteractionEnabled = FALSE;
	[contentView addSubview:gregNameField];
	[gregNameField release];
	// DATA - WEEKDAY
	w = 35.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"week";
	gregWeekdayField = [[AvanteTextLabel alloc] init:str x:x+100.0 y:y w:w h:h size:fontSize color:[UIColor blackColor]];
	gregWeekdayField.userInteractionEnabled = FALSE;
	[contentView addSubview:gregWeekdayField];
	[gregWeekdayField release];
	// ACTION BUTTON
	x += ww + SPACER + SPACER;
	button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[button setImage:searchImg forState:UIControlStateNormal];
	button.frame = CGRectMake(x, y+BUTTON_GAP, BUTTON_SIZE, BUTTON_SIZE);
	button.backgroundColor = [UIColor clearColor];    //
    button.tintColor  =[UIColor whiteColor];
	[button addTarget:self action:@selector(pickGregorian:) forControlEvents:UIControlEventTouchUpInside];	
	[contentView addSubview:button];
	
	//
	// JULIAN DAY NUMBER
	//
	// INFO BUTTON
	x = SPACER;
	y += h + (SPACER/2);
	button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	button.frame = CGRectMake(x, y, BUTTON_SIZE, BUTTON_SIZE);
	button.backgroundColor = [UIColor clearColor];
    button.tintColor  =[UIColor whiteColor];
	[button setImage:questionImg forState:UIControlStateNormal];
	[button addTarget:self action:@selector(infoJulian:) forControlEvents:UIControlEventTouchUpInside];	
	[contentView addSubview:button];
	// LABEL
	x += BUTTON_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"JULIAN_DAY_NUMBER");
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	w = label.bounds.size.width;
	h = label.bounds.size.height;
	[label release];
	// DATA
	x = SPACER + BUTTON_SIZE + SPACER;
	y += hh;
	w = 100.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"julian";
	julianField = [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	[julianField addTarget:self action:@selector(pickJulian:)];	
	[contentView addSubview:julianField];
	[julianField release];
	// ACTION BUTTON
	x += w + SPACER + SPACER;
	button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[button setImage:searchImg forState:UIControlStateNormal];
	button.frame = CGRectMake(x, y+BUTTON_GAP, BUTTON_SIZE, BUTTON_SIZE);
	button.backgroundColor = [UIColor clearColor];
    button.tintColor  =[UIColor whiteColor];
	[button addTarget:self action:@selector(pickJulian:) forControlEvents:UIControlEventTouchUpInside];	
	[contentView addSubview:button];
	
	//
	// LONG COUNT
	//
	// INFO BUTTON
	//
	x = SPACER;
	y += h + (SPACER/2);
	button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	button.frame = CGRectMake(x, y, BUTTON_SIZE, BUTTON_SIZE);
	button.backgroundColor = [UIColor clearColor];
    button.tintColor  =[UIColor whiteColor];
	[button setImage:questionImg forState:UIControlStateNormal];
	[button addTarget:self action:@selector(infoLongCount:) forControlEvents:UIControlEventTouchUpInside];	
	[contentView addSubview:button];
	// LABEL
	x += BUTTON_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"LONG_COUNT_DATE");
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	//
	// DATA
	//
	// MINI LABEL - BAKTUN
	x = SPACER + BUTTON_SIZE + SPACER;
	y += hh;
	fontSize = LABEL_FONT_SIZE_MINI;
	str = @"baktun";
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// DATA - BAKTUN
	w = 35.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	baktunField = [[AvanteTextField alloc] initMayaNum:0 x:x y:y+hh w:w h:h size:fontSize type:global.prefNumbering];
	[baktunField addTarget:self action:@selector(pickLongCount:)];	
	[contentView addSubview:baktunField];
	ww = baktunField.bounds.size.width;
	hh = baktunField.bounds.size.height;
	[baktunField release];
	// LABEL - "."
	x += ww + ceil(SPACER/4);
	fontSize = LABEL_FONT_SIZE;
	str = @".";
	label = [[AvanteTextLabel alloc] init:str x:x y:y+hh-TEXT_FIELD_GAP size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// MINI LABEL - KATUN
	x += ww + ceil(SPACER/4);
	fontSize = LABEL_FONT_SIZE_MINI;
	str = @" katun";
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// DATA - KATUN
	w = 35.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	katunField = [[AvanteTextField alloc] initMayaNum:0 x:x y:y+hh w:w h:h size:fontSize type:global.prefNumbering];
	[katunField addTarget:self action:@selector(pickLongCount:)];	
	[contentView addSubview:katunField];
	ww = katunField.bounds.size.width;
	hh = katunField.bounds.size.height;
	[katunField release];
	// LABEL - "."
	x += w + ceil(SPACER/4);
	fontSize = LABEL_FONT_SIZE;
	str = @".";
	label = [[AvanteTextLabel alloc] init:str x:x y:y+hh-TEXT_FIELD_GAP size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// MINI LABEL - TUN
	x += ww + ceil(SPACER/4);
	fontSize = LABEL_FONT_SIZE_MINI;
	str = @"  tun";
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// DATA - TUN
	w = 35.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	tunField = [[AvanteTextField alloc] initMayaNum:0 x:x y:y+hh w:w h:h size:fontSize type:global.prefNumbering];
	[tunField addTarget:self action:@selector(pickLongCount:)];	
	[contentView addSubview:tunField];
	ww = tunField.bounds.size.width;
	hh = tunField.bounds.size.height;
	[tunField release];
	// LABEL - "."
	x += w + ceil(SPACER/4);
	fontSize = LABEL_FONT_SIZE;
	str = @".";
	label = [[AvanteTextLabel alloc] init:str x:x y:y+hh-TEXT_FIELD_GAP size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// MINI LABEL - UINAL
	x += ww + ceil(SPACER/4);
	fontSize = LABEL_FONT_SIZE_MINI;
	str = @" winal";
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// DATA - UINAL
	w = 35.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	uinalField = [[AvanteTextField alloc] initMayaNum:0 x:x y:y+hh w:w h:h size:fontSize type:global.prefNumbering];
	[uinalField addTarget:self action:@selector(pickLongCount:)];	
	[contentView addSubview:uinalField];
	ww = uinalField.bounds.size.width;
	hh = uinalField.bounds.size.height;
	[uinalField release];
	// LABEL - "."
	x += w + ceil(SPACER/4);
	fontSize = LABEL_FONT_SIZE;
	str = @".";
	label = [[AvanteTextLabel alloc] init:str x:x y:y+hh-TEXT_FIELD_GAP size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// MINI LABEL - KIN
	x += ww + ceil(SPACER/4);
	fontSize = LABEL_FONT_SIZE_MINI;
	str = @"  kin";
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// DATA - KIN
	y += hh;
	w = 35.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	kinField = [[AvanteTextField alloc] initMayaNum:0 x:x y:y w:w h:h size:fontSize type:global.prefNumbering];
	[kinField addTarget:self action:@selector(pickLongCount:)];	
	[contentView addSubview:kinField];
	ww = kinField.bounds.size.width;
	hh = kinField.bounds.size.height;
	[kinField release];
	// ACTION BUTTON
	x += w + SPACER + SPACER;
	button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[button setImage:searchImg forState:UIControlStateNormal];
	button.frame = CGRectMake(x, y+BUTTON_GAP, BUTTON_SIZE, BUTTON_SIZE);
	button.backgroundColor = [UIColor clearColor];
    button.tintColor  =[UIColor whiteColor];
	[button addTarget:self action:@selector(pickLongCount:) forControlEvents:UIControlEventTouchUpInside];	
	[contentView addSubview:button];
	
	//
	// LONG COUNT KIN
	//
	// KIN LABEL
	x = SPACER + BUTTON_SIZE + SPACER;
	y += TEXT_FIELD_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"KIN:");
	label = [[AvanteTextLabel alloc] init:str x:x y:y+TEXT_FIELD_GAP size:fontSize color:[UIColor whiteColor]];
	[contentView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// KIN DATA
	x += ww + SPACER*1.5;
	w = 100.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"abskin";
	abskinField = [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	[contentView addSubview:abskinField];
	[abskinField release];
	// KIN ACTION BUTTON
	/*
	 x += w + SPACER + SPACER;
	 button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	 [button setImage:searchImg forState:UIControlStateNormal];
	 button.frame = CGRectMake(x, y+BUTTON_GAP, BUTTON_SIZE, BUTTON_SIZE);
	 button.backgroundColor = [UIColor clearColor];
	 [button addTarget:self action:@selector(pickLongCountKin:) forControlEvents:UIControlEventTouchUpInside];	
	 [contentView addSubview:button];
	 */
	
	////////////////////////////////////////////////////////////////////////
	//
	// SPECIFIC VIEWS
	//
	
	//
	// MAYA HAAB VIEW
	//
	CGFloat adicional = 45.0;
	y += h + (SPACER/2);
#if (ENABLE_MAYA)
	frame = CGRectMake(0.0, y, kscreenWidth, 200.0 + adicional);
	mayaView = [[UIView alloc] initWithFrame:frame];
	mayaView.hidden = TRUE;
	[contentView addSubview:mayaView];
	[mayaView release];
#endif
	
	//
	// DREAMSPELL VIEW
	//
#if (ENABLE_DREAMSPELL)
	adicional = 0.0;
	frame = CGRectMake(0.0, y, kscreenWidth, 200.0);
	dreamspellView = [[UIView alloc] initWithFrame:frame];
	dreamspellView.hidden = TRUE;
	[contentView addSubview:dreamspellView];
	[dreamspellView release];
#endif

	//
	// Resize content view
	CGSize size = contentView.contentSize;
	size.height += adicional;
	[contentView setContentSize:size];
	
	
	
	///////////////////////////////////////////////////////////////////
	//
	// MAYA VIEW
	//
#if (ENABLE_MAYA)
	//
	// HAAB
	//
	// INFO BUTTON
	y = 0.0;
	x = SPACER;
	button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	button.frame = CGRectMake(x, y, BUTTON_SIZE, BUTTON_SIZE);
	button.backgroundColor = [UIColor clearColor];
    button.tintColor  =[UIColor whiteColor];
	[button setImage:questionImg forState:UIControlStateNormal];
	[button addTarget:self action:@selector(infoHaab:) forControlEvents:UIControlEventTouchUpInside];	
	[mayaView addSubview:button];
	// LABEL
	x += BUTTON_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"HAAB_DATE");
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[mayaView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// DATA - DAY
	x = SPACER + BUTTON_SIZE + SPACER;
	y += hh;
	w = 35.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	//str = @"day";
	//haabdayField = [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	haabdayField = [[AvanteTextField alloc] initMayaNum:0 x:x y:y w:w h:h size:fontSize type:global.prefNumbering];
	[mayaView addSubview:haabdayField];
	[haabdayField release];
	// DATA - UINAL
	x += w + (SPACER/2);
	w = 150;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"uinal";
	haabuinalField = [[AvanteTextField alloc] initMayaNum:0 x:x y:y offx:50.0 offy:0.0 w:w h:h size:fontSize type:global.prefNumbering];
	[mayaView addSubview:haabuinalField];
	[haabuinalField release];
	// DATA - UINAL NAME
	x += (SPACER/2);
	w = 100.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"uinal";
	haabuinalNameField = [[AvanteTextLabel alloc] init:str x:x y:y w:w h:h size:fontSize color:[UIColor blackColor]];
	[mayaView addSubview:haabuinalNameField];
	[haabuinalNameField release];
	// DATA -  ( )
	x += w;
	w = 45.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"(      )";
	label = [[AvanteTextLabel alloc] init:str x:x y:y w:w h:h size:fontSize color:[UIColor blackColor]];
	[mayaView addSubview:label];
	ww = label.bounds.size.width;
	[label release];
	//
	// HAAB IMAGES
	//
	// TZOLKIN NUMBER
	x += ww + SPACER + SPACER;
	frame = CGRectMake(x, y, GLYPH_SIZE_SMALL, GLYPH_SIZE_SMALL);
	haabdayImage = [[UIImageView alloc] initWithFrame:frame];
	[mayaView addSubview:haabdayImage];
	[haabdayImage release];
	// TZOLKIN DAY
	x += GLYPH_SIZE_SMALL;
	frame = CGRectMake(x, y, GLYPH_SIZE_SMALL, GLYPH_SIZE_SMALL);
	haabuinalImage = [[UIImageView alloc] initWithFrame:frame];
	[mayaView addSubview:haabuinalImage];
	[haabuinalImage release];
	//
	// HAAB KIN
	//
	// KIN LABEL
	x = SPACER + BUTTON_SIZE + SPACER;
	y += TEXT_FIELD_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"KIN:");
	label = [[AvanteTextLabel alloc] init:str x:x y:y+TEXT_FIELD_GAP size:fontSize color:[UIColor whiteColor]];
	[mayaView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// KIN DATA
	x += ww + SPACER*1.5;
	w = 60.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"hkin";
	haabkinField = [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	[mayaView addSubview:haabkinField];
	[haabkinField release];
	
	//
	// MAYA TZOLKIN
	//
	// INFO BUTTON
	y += h + (SPACER/2);
	x = SPACER;
	button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	button.frame = CGRectMake(x, y, BUTTON_SIZE, BUTTON_SIZE);
	button.backgroundColor = [UIColor clearColor];
    button.tintColor  =[UIColor whiteColor];
	[button setImage:questionImg forState:UIControlStateNormal];
	[button addTarget:self action:@selector(infoTzolkin:) forControlEvents:UIControlEventTouchUpInside];	
	[mayaView addSubview:button];
	// LABEL
	x += BUTTON_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"TZOLKIN_DATE");
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[mayaView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// DATA - NUMBER
	x = SPACER + BUTTON_SIZE + SPACER;
	y += hh;
	w = 35.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	//str = @"num";
	//tznumberField = [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	tznumberField = [[AvanteTextField alloc] initMayaNum:0 x:x y:y w:w h:h size:fontSize type:global.prefNumbering];
	[mayaView addSubview:tznumberField];
	[tznumberField release];
	// DATA - DAY
	x += w + (SPACER/2);
	w = 150.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"day";
	tzdayField = [[AvanteTextField alloc] initMayaNum:0 x:x y:y offx:50.0 offy:0.0 w:w h:h size:fontSize type:global.prefNumbering];
	[mayaView addSubview:tzdayField];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[tzdayField release];
	// DATA - DAY NAME
	x += (SPACER/2);
	w = 100.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"dayname";
	tzdayNameField = [[AvanteTextLabel alloc] init:str x:x y:y w:w h:h size:fontSize color:[UIColor blackColor]];
	[mayaView addSubview:tzdayNameField];
	[tzdayNameField release];
	// DATA -  ( )
	x += w;
	w = 45.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"(      )";
	label = [[AvanteTextLabel alloc] init:str x:x y:y w:w h:h size:fontSize color:[UIColor blackColor]];
	[mayaView addSubview:label];
	ww = label.bounds.size.width;
	[label release];
	//
	// TZOLKIN IMAGES
	//
	// TZOLKIN NUMBER
	x += ww + SPACER + SPACER;
	frame = CGRectMake(x, y, GLYPH_SIZE_SMALL, GLYPH_SIZE_SMALL);
	tznumberImage = [[UIImageView alloc] initWithFrame:frame];
	[mayaView addSubview:tznumberImage];
	[tznumberImage release];
	// TZOLKIN DAY
	x += GLYPH_SIZE_SMALL;
	frame = CGRectMake(x, y, GLYPH_SIZE_SMALL, GLYPH_SIZE_SMALL);
	tzdayImage = [[UIImageView alloc] initWithFrame:frame];
	[mayaView addSubview:tzdayImage];
	[tzdayImage release];
	//
	// TZOLKIN KIN
	//
	// KIN LABEL
	x = SPACER + BUTTON_SIZE + SPACER;
	y += TEXT_FIELD_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"KIN:");
	label = [[AvanteTextLabel alloc] init:str x:x y:y+TEXT_FIELD_GAP size:fontSize color:[UIColor whiteColor]];
	[mayaView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// KIN DATA
	x += ww + SPACER*1.5;
	w = 60.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"tzkin";
	tzkinField= [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	[mayaView addSubview:tzkinField];
	[tzkinField release];
	
	//
	// MAYA CALENDAR ROUND
	//
	// INFO BUTTON
	y += h + (SPACER/2);
	x = SPACER;
	button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	button.frame = CGRectMake(x, y, BUTTON_SIZE, BUTTON_SIZE);
	button.backgroundColor = [UIColor clearColor];
    button.tintColor  =[UIColor whiteColor];
	[button setImage:questionImg forState:UIControlStateNormal];
	[button addTarget:self action:@selector(infoCalendarRound:) forControlEvents:UIControlEventTouchUpInside];	
	[mayaView addSubview:button];
	// LABEL
	x += BUTTON_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"CALENDAR_ROUND_DATE");
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[mayaView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// CALENDAR ROUND - NUMBER
	x = SPACER + BUTTON_SIZE + SPACER;
	y += hh;
	w = 35.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"cr_";
	crField= [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	[mayaView addSubview:crField];
	[crField release];
	// CALENDAR ROUND LABEL
	x += w + (SPACER*2.0);
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"KIN:");
	label = [[AvanteTextLabel alloc] init:str x:x y:y+TEXT_FIELD_GAP size:fontSize color:[UIColor whiteColor]];
	[mayaView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// CALENDAR ROUND KIN
	x += ww + (SPACER/2);
	w = 70.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"crkin";
	crkinField= [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	[mayaView addSubview:crkinField];
	[crkinField release];
#endif
	
	
	
	/////////////////////////////////////////////////////////////////////////
	//
	// 13-MOON VIEW
	//
#if (ENABLE_DREAMSPELL)
	//
	// DREAMSPELL 13-MOON
	//
	// INFO BUTTON
	y = 0.0;
	x = SPACER;
	button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	button.frame = CGRectMake(x, y, BUTTON_SIZE, BUTTON_SIZE);
	button.backgroundColor = [UIColor clearColor];
    
    button.tintColor  =[UIColor whiteColor];
	[button setImage:questionImg forState:UIControlStateNormal];
	[button addTarget:self action:@selector(infoMoon:) forControlEvents:UIControlEventTouchUpInside];	
	[dreamspellView addSubview:button];
	// LABEL
	x += BUTTON_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"13MOON_DATE");
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[dreamspellView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// DATA - DAY
	x = SPACER + BUTTON_SIZE + SPACER;
	y += hh;
	w = 35.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	moondayField = [[AvanteTextField alloc] initMayaNum:0 x:x y:y w:w h:h size:fontSize type:global.prefNumbering];
	[dreamspellView addSubview:moondayField];
	[moondayField release];
	// DATA - MOON
	x += w + (SPACER/2);
	w = 150;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"moon";
	moonmoonField = [[AvanteTextField alloc] initMayaNum:0 x:x y:y offx:50.0 offy:0.0 w:w h:h size:fontSize type:global.prefNumbering];
	[dreamspellView addSubview:moonmoonField];
	[moonmoonField release];
	// DATA - MOON NAME
	x += SPACER;
	w = 100.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"moon";
	moonmoonNameField = [[AvanteTextLabel alloc] init:str x:x y:y w:w h:h size:fontSize color:[UIColor blackColor]];
	[moonmoonNameField setFit:YES];
	[dreamspellView addSubview:moonmoonNameField];
	[moonmoonNameField release];
	// DATA -  ( )
	x += w;
	w = 45.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"(      )";
	label = [[AvanteTextLabel alloc] init:str x:x y:y w:w h:h size:fontSize color:[UIColor blackColor]];
	[dreamspellView addSubview:label];
	ww = label.bounds.size.width;
	[label release];
	//
	// 13-MOON IMAGES
	//
	// PLASMA IMAGE
	x += ww + 10.0 + SPACER;
	frame = CGRectMake(x, y, PLASMA_SIZE, PLASMA_SIZE);
	plasmaImage = [[UIImageView alloc] initWithFrame:frame];
	[dreamspellView addSubview:plasmaImage];
	ww = plasmaImage.bounds.size.width;
	[plasmaImage release];
	// PLASMA LABEL
	fontSize = LABEL_FONT_SIZE_MINI;
	w = 100.0;
	h = fontSize + 2.0;
	str = @"plasma";
	plamaLabel = [[AvanteTextLabel alloc] init:str x:x-((w-PLASMA_SIZE)/2) y:y+PLASMA_SIZE w:w h:h size:fontSize color:[UIColor whiteColor]];
	[dreamspellView addSubview:plamaLabel];
	[plamaLabel release];
	// MOON FASE IMAGE
	x += ww + 5.0 + SPACER;
	frame = CGRectMake(x, y, MOON_FASE_SIZE, MOON_FASE_SIZE);
	moonFaseImage = [[UIImageView alloc] initWithFrame:frame];
	[dreamspellView addSubview:moonFaseImage];
	[moonFaseImage release];
	//
	// 13-MOON KIN
	//
	// KIN LABEL
	x = SPACER + BUTTON_SIZE + SPACER;
	y += TEXT_FIELD_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"KIN:");
	label = [[AvanteTextLabel alloc] init:str x:x y:y+TEXT_FIELD_GAP size:fontSize color:[UIColor whiteColor]];
	[dreamspellView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// KIN DATA
	x += ww + SPACER*1.5;
	w = 60.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"hkin";
	moonkinField = [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	[dreamspellView addSubview:moonkinField];
	[moonkinField release];
	
	//
	// DREAMSPELL TZOLKIN
	//
	// INFO BUTTON
	y += h + (SPACER/2);
	x = SPACER;
	button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	button.frame = CGRectMake(x, y, BUTTON_SIZE, BUTTON_SIZE);
	button.backgroundColor = [UIColor clearColor];
    button.tintColor  =[UIColor whiteColor];
	[button setImage:questionImg forState:UIControlStateNormal];
	[button addTarget:self action:@selector(infoTzolkin2:) forControlEvents:UIControlEventTouchUpInside];	
	[dreamspellView addSubview:button];
	// LABEL
	x += BUTTON_SIZE + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"TZOLKIN_DATE");
	label = [[AvanteTextLabel alloc] init:str x:x y:y size:fontSize color:[UIColor whiteColor]];
	[dreamspellView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// DATA - NUMBER
	x = SPACER + BUTTON_SIZE + SPACER;
	y += hh;
	w = 35.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	//str = @"num";
	//tznumberField = [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	tznumberField2 = [[AvanteTextField alloc] initMayaNum:0 x:x y:y w:w h:h size:fontSize type:global.prefNumbering];
	[dreamspellView addSubview:tznumberField2];
	[tznumberField2 release];
	// DATA - DAY
	x += w + (SPACER/2);
	w = 150.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"day";
	tzdayField2 = [[AvanteTextField alloc] initMayaNum:0 x:x y:y offx:50.0 offy:0.0 w:w h:h size:fontSize type:global.prefNumbering];
	[dreamspellView addSubview:tzdayField2];
	[tzdayField2 release];
	// DATA - DAY NAME
	x += SPACER;
	w = 100.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"dayname";
	tzdayNameField2 = [[AvanteTextLabel alloc] init:str x:x y:y w:w h:h size:fontSize color:[UIColor blackColor]];
	//[tzdayNameField2 setFit:YES];
	[dreamspellView addSubview:tzdayNameField2];
	[tzdayNameField2 release];
	// DATA -  ( )
	x += w;
	w = 45.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"(      )";
	label = [[AvanteTextLabel alloc] init:str x:x y:y w:w h:h size:fontSize color:[UIColor blackColor]];
	[dreamspellView addSubview:label];
	ww = label.bounds.size.width;
	[label release];
	//
	// TZOLKIN IMAGES
	//
	// TZOLKIN NUMBER
	x += ww + SPACER + SPACER;
	frame = CGRectMake(x, y, GLYPH_SIZE_SMALL, GLYPH_SIZE_SMALL);
	tznumberImage2 = [[UIImageView alloc] initWithFrame:frame];
	[dreamspellView addSubview:tznumberImage2];
	[tznumberImage2 release];
	// TZOLKIN DAY
	x += GLYPH_SIZE_SMALL;
	frame = CGRectMake(x, y, GLYPH_SIZE_SMALL, GLYPH_SIZE_SMALL);
	tzdayImage2 = [[UIImageView alloc] initWithFrame:frame];
	[dreamspellView addSubview:tzdayImage2];
	[tzdayImage2 release];
	//
	// TZOLKIN KIN
	//
	// KIN LABEL
	x = SPACER + BUTTON_SIZE + SPACER;
	y += h + SPACER;
	fontSize = LABEL_FONT_SIZE;
	str = LOCAL(@"KIN:");
	label = [[AvanteTextLabel alloc] init:str x:x y:y+TEXT_FIELD_GAP size:fontSize color:[UIColor whiteColor]];
	[dreamspellView addSubview:label];
	ww = label.bounds.size.width;
	hh = label.bounds.size.height;
	[label release];
	// KIN DATA
	x += ww + SPACER*1.5;
	w = 60.0;
	h = TEXT_FIELD_SIZE;
	fontSize = DATA_FONT_SIZE;
	str = @"tzkin";
	tzkinField2 = [[AvanteTextField alloc] init:str x:x y:y w:w h:h size:fontSize];
	[dreamspellView addSubview:tzkinField2];
	[tzkinField2 release];
#endif

	////////////////////////////////////
	//
	// ROLLER
	//
	roller = [[AvanteRollerVertical alloc] init:0.0:(kActiveLessNavTab - kRollerVerticalHeight)];
	[roller addCallback:self dragLeft:@selector(julianSub:) dragRight:@selector(julianAdd:)];
	[self.view addSubview:roller];
	[roller release];
}




#pragma mark UI

//
// UI
//
// Atualiza os controles
- (void)updateUI {

	// Botao de ADD
	self.navigationItem.rightBarButtonItem.enabled = ![global.datebook dateExists:global.cal.julian];
	
	// GREG / JDN
	[julianField update:[NSString stringWithFormat:@"%d", global.cal.julian]];
	[gregNameField update: global.cal.greg.dayNameShort];
	[gregWeekdayField update: global.cal.greg.weekDayNameShort];
	//AvLog(@"UPDATE UI greg[%@]",global.cal.greg.nameShort);

	// LONG CONT
	[baktunField updateMayaNum:global.cal.longCount.baktun type:global.prefNumbering];
	[katunField updateMayaNum:global.cal.longCount.katun type:global.prefNumbering];
	[tunField updateMayaNum:global.cal.longCount.tun type:global.prefNumbering];
	[uinalField updateMayaNum:global.cal.longCount.uinal type:global.prefNumbering];
	[kinField updateMayaNum:global.cal.longCount.kin type:global.prefNumbering];
	[abskinField update:[NSString stringWithFormat:@"%d", global.cal.longCount.abskin]];
	
	// MAYA DATES
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
	{
		// Light up HAAB / 13-MOON views
		mayaView.hidden = FALSE;
		dreamspellView.hidden = TRUE;
		
		// Moon Fase Image
		if (MAYA_ONLY)
			moonFaseMaya.image = [UIImage imageNamed:global.cal.moon.imgMoonFase];

		// TZOLKIN
		[tznumberField updateMayaNum:global.cal.tzolkin.number type:global.prefNumbering];
		[tzdayField updateMayaNum:global.cal.tzolkin.day type:global.prefNumbering];
		[tzdayNameField update: global.cal.tzolkin.dayName];
		// kin
		[tzkinField update:[NSString stringWithFormat:@"%d", global.cal.tzolkin.kin]];
		// number image
		tznumberImage.image = [UIImage imageNamed:global.cal.tzolkin.imgNumSide];
		// glyph image
		tzdayImage.image = [UIImage imageNamed:global.cal.tzolkin.imgGlyph];

		// HAAB
		[haabdayField updateMayaNum:global.cal.haab.day type:global.prefNumbering];
		[haabuinalField updateMayaNum:global.cal.haab.uinal type:global.prefNumbering];
		[haabuinalNameField update:global.cal.haab.uinalName];
		// kin
		[haabkinField update:[NSString stringWithFormat:@"%d", global.cal.haab.kin]];
		// number image
		haabdayImage.image = [UIImage imageNamed:global.cal.haab.imgNumSide];
		// glyph image
		haabuinalImage.image = [UIImage imageNamed:global.cal.haab.imgGlyph];
		
		// CALENDAR ROUND
		[crField update:[NSString stringWithFormat:@"%d", global.cal.tzolkin.calendarRound]];
		[crkinField update:[NSString stringWithFormat:@"%d", global.cal.tzolkin.calendarRoundKin]];
	}
	// 13-MOON DATES
	else
	{
		// Light up HAAB / 13-MOON views
		mayaView.hidden = TRUE;
		dreamspellView.hidden = FALSE;
		
		// TZOLKIN
		[tznumberField2 updateMayaNum:global.cal.tzolkinMoon.number type:global.prefNumbering];
		[tzdayField2 updateMayaNum:global.cal.tzolkinMoon.day type:global.prefNumbering];
		[tzdayNameField2 update: global.cal.tzolkinMoon.dayName];
		[tzkinField2 update:[NSString stringWithFormat:@"%d", global.cal.tzolkinMoon.kin]];
		// number image
		tznumberImage2.image = [UIImage imageNamed:global.cal.tzolkinMoon.imgNum];
		// glyph image
		tzdayImage2.image = [UIImage imageNamed:global.cal.tzolkinMoon.imgGlyph];		
		
		// 13-MOON
		if (global.cal.moon.doot)	// out-of-time
		{
			[moondayField updateMayaNum:0 type:NUMBERING_123];
			[moonmoonField updateMayaNum:0 type:global.prefNumbering];
		}
		else
		{
			[moondayField updateMayaNum:global.cal.moon.day type:NUMBERING_123];
			[moonmoonField updateMayaNum:global.cal.moon.moon type:global.prefNumbering];
		}
		[moonmoonNameField update: global.cal.moon.moonName];
		[moonkinField update:[NSString stringWithFormat:@"%d", global.cal.moon.kin]];
		
		// Plasma Image
		plasmaImage.image = [UIImage imageNamed:global.cal.moon.imgPlasma];
		[plamaLabel update: global.cal.moon.plasmaName];
		// Moon Fase Image
		moonFaseImage.image = [UIImage imageNamed:global.cal.moon.imgMoonFase];
		//[moonFaseLabel update: global.cal.moon.moonFaseName];
	}
}


#pragma mark ACTIONS

- (void)switchViewMode:(id)sender {
	[global switchViewMode:mayaMoonSelector];
	// Atualiza UI
	[self updateUI];
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
	//AvLog(@"OUT SETTINGS!!");
}
- (IBAction)goToday:(id)sender {
	[roller stop];
	[global.cal updateWithToday];
	[self updateUI];
	// Play Sound
	if (global.prefGearSound != GEAR_SOUND_QUIET)
		[global.soundLib playWave:WAVE_TICK];
}
- (IBAction)addDate:(id)sender {
	// stop roller
	[roller stop];
	// Create temporary vc
	DateAddVC *vc = [[DateAddVC alloc] initAddItem:global.cal.julian];
	vc.title = LOCAL(@"DATE_ADD_TITLE");
    
    [vc setPrevTitle:self.title];
	vc.hidesBottomBarWhenPushed  = YES;
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
	[self updateUI];
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
	[self updateUI];
	// Play Sound
	if (global.prefGearSound != GEAR_SOUND_QUIET)
		[global.soundLib playWave:WAVE_TICK];
}
// PICKER - GREGORIAN
- (IBAction)pickGregorian:(id)sender {
	// stop roller
	[roller stop];
	// Create temporary vc
	DatePickerVC *vc = [[DatePickerVC alloc] initWithType:DATE_PICKER_GREGORIAN];
    [vc setPrevTitle:self.title];
	vc.hidesBottomBarWhenPushed  = YES;
	[[self navigationController] pushViewController:vc animated:YES];
	[vc release];
}
- (IBAction)pickJulian:(id)sender {
	// stop roller
	[roller stop];
	// Create temporary vc
	DatePickerVC *vc = [[DatePickerVC alloc] initWithType:DATE_PICKER_JULIAN];
    [vc setPrevTitle:self.title];
	vc.hidesBottomBarWhenPushed  = YES;
	[[self navigationController] pushViewController:vc animated:YES];
	[vc release];
}
- (IBAction)pickLongCount:(id)sender {
	// stop roller
	[roller stop];
	// Create temporary vc
	DatePickerVC *vc = [[DatePickerVC alloc] initWithType:DATE_PICKER_LONG_COUNT];
    [vc setPrevTitle:self.title];    
	vc.hidesBottomBarWhenPushed  = YES;
	[[self navigationController] pushViewController:vc animated:YES];
	[vc release];
}




#pragma mark INFO ACTIONS

//
// INFO ACTIONS
//
- (IBAction)infoGreg:(id)sender {
	[global goInfo:INFO_GREGORIAN vc:self];
}
- (IBAction)infoJulian:(id)sender {
	[global goInfo:INFO_JULIAN vc:self];
}
- (IBAction)infoLongCount:(id)sender {
	[global goInfo:INFO_LONG_COUNT vc:self];
}
- (IBAction)infoCalendarRound:(id)sender {
	CGFloat pos;
	if (global.prefLang == LANG_PT)
		pos = 850.0;
	else if (global.prefLang == LANG_ES)
		pos = 870.0;
	else	// en
		pos = 830.0;
	[global goInfo:INFO_MAYA vc:self y:pos];
}
- (IBAction)infoTzolkin:(id)sender {
	[global goInfo:INFO_TZOLKIN vc:self];
}
- (IBAction)infoTzolkin2:(id)sender {
	[global goInfo:INFO_TZOLKIN_DREAMSPELL vc:self];
}
- (IBAction)infoHaab:(id)sender {
	[global goInfo:INFO_HAAB vc:self];
}
- (IBAction)infoMoon:(id)sender {
	[global goInfo:INFO_13MOON vc:self];
}

// Debug Touches
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	AvLog(@"EXPLORER: touchesBegan");
	[super touchesBegan:touches	withEvent:event];
}
*/


#pragma mark LOCATION

//
// UIAlertView DELEGATE
//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)hemisphere
{
	// Set Preference
	[global locationSet:(int)hemisphere];
	// update Moon
	[self updateUI];
}



@end
