//
//  ClockSettingsVC.m
//  Maya3D
//
//  Created by Roger on 19/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "ClockSettingsVC.h"
#import "TzGlobal.h"
#import "TzClock.h"
#import "Tzolkin.h"
#import "AvanteTextLabel.h"


@implementation ClockSettingsVC

#define kTransitionDuration		0.50
#define SPEED_PICKER_WIDTH		200.0
#define SPEED_PICKER_HEIGHT		24.0

//@synthesize controlClockStyle;


- (void)dealloc {
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
/*
 // Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */
/*
 // Implement loadView to create a view hierarchy programmatically.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view.
- (id)init
{
	// Suuuper
	if ((self = [super initWithNibName:@"TzFullView" bundle:nil]) == nil)
		return nil;
	
	// Create view components
	CGFloat y = 64;
	
    speedPicker = [[AvantePicker alloc] init:0.0 y:y labels:NO];
    [self setupSpeedPicker];
    [self.view addSubview:speedPicker];
    [speedPicker release];
    
	// Create Tool Bar estetico
//	y = kUIPickerHeight;
//	UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, y, kscreenWidth, kToolbarHeight)];
//	toolBar.barStyle = UIBarStyleBlackOpaque;
//	[self.view addSubview:toolBar];
//	[toolBar release];
//	
//	// Picker label
//	//y += (kToolbarHeight/2);
//	//y = 0.0;
//	AvanteTextLabel *label = [[AvanteTextLabel alloc] init:LOCAL(@"CLOCK_SPEED")
//														 x:0.0  y:y+10.0 
//														 w:kscreenWidth h:12.0
//													  size:12.0 color:[UIColor whiteColor]];
//	[self.view addSubview:label];
//	[label release];
	
	// Create SPEED GREGORIANO picker view
	// Create Picker

	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	// Pause clock?
	clockWasPlaying = global.theClock.playing;
	if (clockWasPlaying)
		[global.theClock pause];
	// Put picker on current value
	[self setPickersToSpeed:speedPicker];

	//AvLog(@"TOP TITLE [%@]",[self navigationController].navigationBar.topItem.title);
	//[self navigationController].navigationBar.topItem.leftBarButtonItem.style = UIBarButtonItemStyleDone;

}
- (void)viewDidAppear:(BOOL)animated
{
	// Muda estilo do botao de volta
	//AvLog(@"TOP TITLE [%@]",[self navigationController].navigationBar.topItem.title);
	//[self navigationController].navigationBar.topItem.leftBarButtonItem.style = UIBarButtonItemStyleDone;
	//[self navigationController].navigationBar.backItem.title = @"DDSDS";
	//AvLog(@"BACK TITLE [%@]",[self navigationController].navigationBar.backItem.title);
	//[self navigationController].navigationBar.topItem.leftBarButtonItem.style = UIBarButtonItemStyleDone;

	UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionDone:)];
    
    [but setTintColor:[UIColor whiteColor]];
	[self navigationController].navigationBar.topItem.leftBarButtonItem = but;
	[but release];
}
- (void)viewDidDisappear:(BOOL)animated
{
	if (clockWasPlaying)
		[global.theClock play];
}


// Speed em GREGORIANO
- (void)setupSpeedPicker
{
	// Add components
	int comp = 0;
	NSString *str;
	
	// Crate picker component
	[speedPicker addComponent:LOCAL(@"CLOCK_SPEED") w:SPEED_PICKER_WIDTH];
	//[speedPicker addComponentCallback:comp :self :@selector(didChangeSpeed)];
	
	// Add rows
	// 1 Sec / sec
	str = [NSString stringWithFormat:@" 1 %@ / %@",LOCAL(@"SECOND"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(1)] ];
	// 1 min / sec
	str = [NSString stringWithFormat:@" 1 %@ / %@",LOCAL(@"MINUTE"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(60)] ];
	// 1 hour / sec
	str = [NSString stringWithFormat:@" 1 %@ / %@",LOCAL(@"HOUR"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(60*60)] ];
	// 6 hours / sec
	str = [NSString stringWithFormat:@" 6 %@ / %@",LOCAL(@"HOURS"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(60*60*6)] ];
	// 12 hours / sec
	str = [NSString stringWithFormat:@"12 %@ / %@",LOCAL(@"HOURS"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(60*60*12)] ];
	// 1 day / sec
	str = [NSString stringWithFormat:@" 1 %@ / %@",LOCAL(@"DAY"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(60*60*24)] ];
	// 2 days / sec
	str = [NSString stringWithFormat:@" 2 %@ / %@",LOCAL(@"DAYS"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(2*60*60*24)] ];
	// 3 days / sec
	str = [NSString stringWithFormat:@" 3 %@ / %@",LOCAL(@"DAYS"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(3*60*60*24)] ];
	// 1 week / sec
	str = [NSString stringWithFormat:@" 1 %@ / %@",LOCAL(@"WEEK"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(60*60*24*7)] ];
	// 1 month / sec
	str = [NSString stringWithFormat:@" 1 %@ / %@",LOCAL(@"MONTH"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(60*60*24*30)] ];
	// 3 months / sec
	str = [NSString stringWithFormat:@" 3 %@ / %@",LOCAL(@"MONTHS"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(60*60*24*(365/4))] ];
	// 6 months / sec
	str = [NSString stringWithFormat:@" 6 %@ / %@",LOCAL(@"MONTHS"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(60*60*24*(365/2))] ];
	// 1 year / sec
	str = [NSString stringWithFormat:@" 1 %@ / %@",LOCAL(@"YEAR"),LOCAL(@"SEC")];
	[speedPicker addRowToComponent:comp text:str data:[NSString stringWithFormat:@"%d",(60*60*24*365)] ];
}


#pragma mark ACTIONS

// DONE!
- (IBAction)actionDone:(id)sender {
	global.theClock.speed = (int)[[speedPicker selectedRowData:0] integerValue];
	[global.theClock.speedLabel update:(NSString*) [speedPicker selectedRowText:0]];
	AvLog(@"NEW CLOCK SPEED [%d] secs [%@]",global.theClock.speed,global.theClock.speedLabel.theLabel.text);
	// Volta para View anterior
	[[self navigationController] popViewControllerAnimated:YES];
}

// Put pickers on current speed value
- (void)setPickersToSpeed:(AvantePicker*)picker
{
	[picker selectRowWithDataCloser:global.theClock.speed inComponent:0 animated:NO];
}


@end
