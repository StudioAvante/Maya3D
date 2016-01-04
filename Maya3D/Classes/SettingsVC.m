//
//  SettingsVC.m
//  Maya3D
//
//  Created by Roger on 19/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "SettingsVC.h"
#import "Tzolkin.h"
#import "TzGlobal.h"


@implementation SettingsVC

@synthesize controlHemisphere;
@synthesize controlStartDate;
@synthesize controlDateFormat;
@synthesize controlNumbering;
@synthesize controlGearLabel;
@synthesize controlGearSound;
@synthesize controlLangSetting;


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
	if ((self = [super initWithNibName:@"TzSettingsView" bundle:nil]) == nil)
		return nil;
	
	// color black!
	controlHemisphere.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
	controlStartDate.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
	controlDateFormat.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
	controlNumbering.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
	controlGearLabel.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
	controlGearSound.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
	controlLangSetting.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	// Seta valores atuais
	controlHemisphere.selectedSegmentIndex = global.prefHemisphere;
	controlStartDate.selectedSegmentIndex = global.prefStartDate;
	controlDateFormat.selectedSegmentIndex = global.prefDateFormat;
	controlNumbering.selectedSegmentIndex = global.prefNumbering;
	controlGearLabel.selectedSegmentIndex = global.prefGearName;
	controlGearSound.selectedSegmentIndex = global.prefGearSound;
	controlLangSetting.selectedSegmentIndex = global.prefLangSetting;
}
- (void)viewDidAppear:(BOOL)animated
{
	global.currentVC = self;
	// Muda estilo do botao de volta
	UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionDone:)];
    but.tintColor = [UIColor whiteColor];
	[self navigationController].navigationBar.topItem.leftBarButtonItem = but;
	[but release];
}
- (void)viewDidDisappear:(BOOL)animated
{
	// just in case...
	[global uncoverAll];
	[global updatePreferences];
}



#pragma mark ROGER

// ROGER
- (IBAction)setHemisphere:(id)sender {
    int h = (int)[sender selectedSegmentIndex];
//	// Detect
//	if (controlHemisphere.selectedSegmentIndex == HEMISPHERE_UNKNOWN)
//	{
//		[global locationSet:HEMISPHERE_UNKNOWN];
//		return;
//	}
	// Set Preference
	global.prefHemisphere = h;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:global.prefHemisphere forKey:@"prefHemisphere"];
	[defaults synchronize];
	// debug
	int value = (int)[defaults integerForKey:@"prefHemisphere"];
	AvLog(@"SET PLIST: h=%d global.prefHemisphere=%d defaults=%d", h, global.prefHemisphere, value);
}
- (IBAction)setStartDate:(id)sender {
	// Set Preference
	global.prefStartDate = (int)[sender selectedSegmentIndex];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:global.prefStartDate forKey:@"prefStartDate"];
	[defaults synchronize];
	// debug
	int value = (int)[defaults integerForKey:@"prefStartDate"];
	AvLog(@"SET PLIST: global.prefStartDate=%d", value);
}
- (IBAction)setDateFormat:(id)sender {
	// Set Preference
	global.prefDateFormat = (int)[sender selectedSegmentIndex];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:global.prefDateFormat forKey:@"prefDateFormat"];
	[defaults synchronize];
	// debug
	//int value = [defaults integerForKey:@"prefDateFormat"];
	//AvLog(@"SET PLIST: global.prefDateFormat=%d", value);
}
- (IBAction)setNumberting:(id)sender {
	// Set Preference
	global.prefNumbering = (int)[sender selectedSegmentIndex];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:global.prefNumbering forKey:@"prefNumbering"];
	[defaults synchronize];
	// debug
	//int value = [defaults integerForKey:@"prefNumbering"];
	//AvLog(@"SET PLIST: global.prefNumbering=%d", value);
}
- (IBAction)setGearSound:(id)sender {
	// Set Preference
	global.prefGearSound = (int)[sender selectedSegmentIndex];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:global.prefGearSound forKey:@"prefGearSound"];
	[defaults synchronize];
	// debug
	int value = (int)[defaults integerForKey:@"prefGearSound"];
	AvLog(@"SET PLIST: global.prefGearSound=%d", value);
}
- (IBAction)setGearLabel:(id)sender {
	// Set Preference
	global.prefGearName = (int)[sender selectedSegmentIndex];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:global.prefGearName forKey:@"prefGearName"];
	[defaults synchronize];
	// debug
	int value = (int)[defaults integerForKey:@"prefGearName"];
	AvLog(@"SET PLIST: global.prefGearName=%d", value);
}
- (IBAction)setLangSetting:(id)sender {
	// Set Preference
	global.prefLangSetting = (int)[sender selectedSegmentIndex];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:global.prefLangSetting forKey:@"prefLangSetting"];
	[defaults synchronize];
	[global setLang];
	// debug
	int value = (int)[defaults integerForKey:@"prefLangSetting"];
	AvLog(@"SET PLIST: global.prefLangSetting=%d", value);
}

// DONE!
- (IBAction)actionDone:(id)sender {
	// Volta para View anterior
	[[self navigationController] popViewControllerAnimated:YES];
}



@end
