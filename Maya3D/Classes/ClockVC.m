//
//  ClockVC.m
//  Maya3D
//
//  Created by Roger on 03/12/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "ClockVC.h"
#import "TzGlobal.h"
#import "AvanteMayaNum.h"
#import "DatebookVC.h"
#import "ClockSettingsVC.h"

#define kTransitionDuration		0.50
#define SPEED_PICKER_WIDTH		200.0
#define SPEED_PICKER_HEIGHT		24.0



@implementation ClockVC


- (void)dealloc {
	[defaultSpeedName release];
    [super dealloc];
}

#pragma mark UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}


- (id)init
{
	// Suuuper
    if ((self = [self initWithNibName:@"TzFullView" bundle:nil]) == nil)
		return nil;
	
	// Create view components
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	UIBarButtonItem *but;
	UIToolbar *toolBar;
	NSArray *items;
	CGRect frame;
	CGFloat y = 0.0;
	
    y = (kStatusBarHeight+44);
	// SETTINGS BUTTON
	/*
	 but = [[UIBarButtonItem alloc]
	 //initWithImage:[global imageFromFile:@"icon_settings"]
	 initWithImage:[global imageFromFile:@"icon_clock_play"]
	 style:UIBarButtonItemStylePlain
	 target:self action:@selector(goSettings:)];
	 self.navigationItem.leftBarButtonItem = but;
	 self.navigationItem.leftBarButtonItem.enabled = TRUE;
	 [but release];
	 */
	
	// HELP BUTTON
//    but = self.navigationItem.leftBarButtonItem;
//    [but setTintColor:[UIColor whiteColor]];
//    self.navigationItem.leftBarButtonItem = but;
    
	but = [[UIBarButtonItem alloc]
		   initWithImage:[global imageFromFile:@"icon_info"]
		   style:UIBarButtonItemStylePlain
		   target:self action:@selector(goInfo:)];
    [but setTintColor:[UIColor whiteColor]];
	self.navigationItem.rightBarButtonItem = but;
	self.navigationItem.rightBarButtonItem.enabled = TRUE;
	[but release];
	
	//
	// TOOL BAR estetico
	//
//	toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, y, kscreenWidth, kToolbarHeight)];
//	toolBar.barStyle = UIBarStyleBlackOpaque;
//	[self.view addSubview:toolBar];
//	[toolBar release];
//	
//	//
//	// PICKERS
//	//
	y += kToolbarHeight;
	clockPicker = [[AvantePicker alloc] init:0.0 y:y labels:YES];
	clockPicker.userInteractionEnabled = NO;
    
//    clockPicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self setupClockPicker];
	[self.view addSubview:clockPicker];
	[clockPicker release];
	
	//
	// SPEED Tool Bar
	//
//	y += kUIPickerHeight;
    y += clockPicker.frame.size.height+10;//clockPicker.bounds.size.height + 49;
	frame = CGRectMake(0.0, y, kscreenWidth, kToolbarHeight);
	toolBar = [[UIToolbar alloc] initWithFrame:frame];
	toolBar.barStyle = UIBarStyleBlackOpaque;
	// Create ToolBar Items
	// RESET button
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc]
									initWithTitle:LOCAL(@"CLOCK_RESET")
									style:UIBarButtonItemStyleBordered
									target:self action:@selector(actionReset:)];
    [resetButton setTintColor:[UIColor whiteColor]];
 	// SPEED BUTTON
	UIBarButtonItem *speedButton = [[UIBarButtonItem alloc]
									initWithTitle:LOCAL(@"CLOCK_SPEED")
									style:UIBarButtonItemStyleBordered
									target:self action:@selector(goSpeedSettings:)];
    [speedButton setTintColor:[UIColor whiteColor]];
 	// SPACER
	fixed.width = 160.0;
	// Add Itens To Toolbar
	items = [NSArray arrayWithObjects: flex, resetButton, flex, speedButton, flex, nil];
	[toolBar setItems:items animated:NO];
	[self.view addSubview:toolBar];
	// free
	[resetButton release];
	[speedButton release];
	[toolBar release];
	
	//
	// DEFAULT SPEED NAME - 1 s/s
	//
	defaultSpeedName = [[NSString alloc] initWithFormat:@" 1 %@ / %@",LOCAL(@"SECOND"),LOCAL(@"SEC")];

	//
	// SPEED LABEL
	//
	y+= kToolbarHeight;
	// 1a vez que entra no clock
	if (global.theClock.speedLabel == nil)
	{
		frame = CGRectMake(0.0, y, kscreenWidth, kToolbarHeight);
		AvanteTextLabel *label = [[AvanteTextLabel alloc] init:defaultSpeedName frame:frame size:20.0 color:[UIColor whiteColor]];
		[label setNavigationBarStyle];
		global.theClock.speedLabel = label;
		[label release];
	}
	[self.view addSubview:global.theClock.speedLabel];
	
	//
	// PLAY/PAUSE Tool Bar
	//
	y+= kToolbarHeight;
	//y = kActiveLessNavTab;
	frame = CGRectMake(0.0, y, kscreenWidth, kToolbarHeight);
	toolBar = [[UIToolbar alloc] initWithFrame:frame];
	toolBar.barStyle = UIBarStyleBlackOpaque;
	// Create ToolBar Items
	// PAUSE button
    pauseButton = [[UIBarButtonItem alloc]
				   initWithImage:[global imageFromFile:@"icon_pause"]
				   style:UIBarButtonItemStyleBordered
				   target:self action:@selector(actionPause:)];
    [pauseButton setTintColor:[UIColor whiteColor]];
	// PLAY button
    playButton = [[UIBarButtonItem alloc]
				  initWithImage:[global imageFromFile:@"icon_play"]
				  style:UIBarButtonItemStyleBordered
				  target:self action:@selector(actionPlay:)];
    [playButton setTintColor:[UIColor whiteColor]];
	// PLAY+GEAR button
    playGearButton = [[UIBarButtonItem alloc]
					  initWithImage:[global imageFromFile:@"icon_play_gear"]
					  style:UIBarButtonItemStyleBordered
					  target:self action:@selector(actionPlayGear:)];
    [playGearButton setTintColor:[UIColor whiteColor]];
	// Add Itens To Toolbar
	items = [NSArray arrayWithObjects: flex, pauseButton, playButton, playGearButton, flex, nil];
	[toolBar setItems:items animated:NO];
	// Add ToobBar to main view
	[self.view addSubview:toolBar];
	// Free used
	[pauseButton release];
	[playButton release];
	[playGearButton release];
	[toolBar release];
	
	// Free!
	[flex release];
	[fixed release];
	
	// Reset Clock
	//[self actionReset:self];
	
	// Bota pra tocar
	//[self actionPlay:self];
	
	// ok!
    


	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
	// super
    [super viewDidAppear:animated];

	// Turn off sounds
	[global.soundLib pause];

	// Set title
	self.title = [NSString stringWithString:LOCAL(@"CLOCK")];
	
    UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithTitle:self.prevTitle style:UIBarButtonItemStyleDone target:self action:@selector(goPrev:)];
    [but setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = but;
    self.navigationItem.leftBarButtonItem.enabled = TRUE;
    [but release];

    //[self setupClockPicker];  
	// update clock to timer
	[self updateClockPicker:FALSE];
}
- (void)viewDidAppear:(BOOL)animated {
	// Com isto o TzClock vai animar o picker
	global.currentTab = TAB_CLOCK;
	global.currentVC = self;
	
	// Liga botao de acordo com o status do relogio
	if (global.theClock.playing)
	{
		pauseButton.style = UIBarButtonItemStyleBordered;
		playButton.style = UIBarButtonItemStyleDone;
	}
	else
	{
		pauseButton.style = UIBarButtonItemStyleDone;
		playButton.style = UIBarButtonItemStyleBordered;
	}

	// Turn on sounds
	[global.soundLib play];
    
    
}
- (void)viewWillDisappear:(BOOL)animated {
}
- (void)viewDidDisappear:(BOOL)animated {
	global.lastTab = TAB_CLOCK;
}


-(IBAction)goPrev:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
}
// Create Pickers
- (void)setupClockPicker
{
	// Add components
	int comp, n;
	NSString *str, *dt;
	
    float fact = (float)kscreenWidth / 320.0;
    int width;
	// Year
	comp = 0;
    
    width = (int)(70.0 * fact);
	[clockPicker addComponent:LOCAL(@"YEAR") w:70];  //70
	for ( n = -3113 ; n <= 4772 ; n++ )
	{
		str = [NSString stringWithFormat:@"%d",n];
		[clockPicker addRowToComponent:comp text:str];
	}
	// Month
	comp++;
    
    width = (int)(60.0 * fact);
	[clockPicker addComponent:LOCAL(@"MONTH") w:60]; //60
	for ( n = 1 ; n <= 12 ; n++ )
	{
		dt = [NSString stringWithFormat:@"%d",n];
		str = [TzCalGreg constNameOfMonthShort:n];
		[clockPicker addRowToComponent:comp text:str data:dt];
	}
	// Day
	comp++;
    
    width = (int)(40.0 * fact);
	[clockPicker addComponent:LOCAL(@"DAY") w:40];  //40
	for ( n = 1 ; n <= 31 ; n++ )
	{
		str = [NSString stringWithFormat:@"%d",n];
		[clockPicker addRowToComponent:comp text:str];
	}
	// Hours
	comp++;
	[clockPicker addComponent:LOCAL(@"HOUR") w:40];
	for ( n = 0 ; n <= 23 ; n++ )
	{
		str = [NSString stringWithFormat:@"%d",n];
		[clockPicker addRowToComponent:comp text:str];
	}
	// Minutes
	comp++;
	[clockPicker addComponent:LOCAL(@"MIN_HIGH") w:40];
	for ( n = 0 ; n <= 59 ; n++ )
	{
		str = [NSString stringWithFormat:@"%d",n];
		[clockPicker addRowToComponent:comp text:str];
	}
	// Minutes
	comp++;
	[clockPicker addComponent:LOCAL(@"SEC_HIGH") w:40];
	for ( n = 0 ; n <= 59 ; n++ )
	{
		str = [NSString stringWithFormat:@"%d",n];
		[clockPicker addRowToComponent:comp text:str];
	}
}

#pragma mark CLOCK SET

// Put clock to current time
- (void)updateClockPicker:(BOOL)animated
{
	NSInteger comp;
	NSString *dt;
	
	// Year
	comp = 0;
	dt = [NSString stringWithFormat:@"%d",global.cal.greg.year];
	[clockPicker selectRowWithData:dt inComponent:comp animated:animated];
	// Month
	comp++;
	dt = [NSString stringWithFormat:@"%d",global.cal.greg.month];
	[clockPicker selectRowWithData:dt inComponent:comp animated:animated];
	// Day
	comp++;
	dt = [NSString stringWithFormat:@"%d",global.cal.greg.day];
	[clockPicker selectRowWithData:dt inComponent:comp animated:animated];
	// Hour
	comp++;
	dt = [NSString stringWithFormat:@"%d",global.cal.greg.hour];
	[clockPicker selectRowWithData:dt inComponent:comp animated:animated];
	// Minute
	comp++;
	dt = [NSString stringWithFormat:@"%d",global.cal.greg.minute];
	[clockPicker selectRowWithData:dt inComponent:comp animated:animated];
	// Second
	comp++;
	dt = [NSString stringWithFormat:@"%d",global.cal.greg.second];
	[clockPicker selectRowWithData:dt inComponent:comp animated:animated];
}




#pragma mark ACTIONS

- (IBAction)actionReset:(id)sender
{
	// Reset Speed
	global.theClock.speed = 1;
	// Reset date
	[global.cal updateWithToday];
	// set speed label
	[global.theClock.speedLabel update:defaultSpeedName];
	// Update clock
	[self updateClockPicker:TRUE];
}
- (IBAction)actionPause:(id)sender
{
	// Highlight button
	pauseButton.style = UIBarButtonItemStyleDone;
	playButton.style = UIBarButtonItemStyleBordered;
	playGearButton.style = UIBarButtonItemStyleBordered;
	// Stop timer
	[global.theClock pause];
}
- (IBAction)actionPlay:(id)sender
{
	// Highlight button
	pauseButton.style = UIBarButtonItemStyleBordered;
	playButton.style = UIBarButtonItemStyleDone;
	playGearButton.style = UIBarButtonItemStyleBordered;
	// Start timer
	[global.theClock play];
}
- (IBAction)actionPlayGear:(id)sender
{
	// Start timer
	[self actionPlay:sender];
	// Go back to gear view
	//self.tabBarController.selectedIndex = TAB_MAYA3D;
	// Volta para View anterior
	[[self navigationController] popViewControllerAnimated:YES];
}

// Go to Datebook
- (IBAction)goSpeedSettings:(id)sender {
	ClockSettingsVC *vc = [[ClockSettingsVC alloc] init];
	vc.title = LOCAL(@"CLOCK_SETTINGS");
	vc.hidesBottomBarWhenPushed  = YES;
	[[self navigationController] pushViewController:vc animated:YES];
	[vc release];
}
- (IBAction)goInfo:(id)sender {
	[global goInfo:INFO_TIMER vc:self];
}

@end
