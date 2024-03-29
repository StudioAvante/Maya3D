//
//  KinDecodeVC.m
//  Maya3D
//
//  Created by Roger on 19/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "KinDecodeVC.h"
#import "Tzolkin.h"
#import "TzGlobal.h"
#import "TzCalendar.h"
#import "AvanteKinView.h"
#import "TzSoundManager.h"


@implementation KinDecodeVC


- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (id)initWithType:(int)kinType tz:(TzCalTzolkinMoon*)tz destinyKin:(int)dkin
{
	// Suuuper
    if ((self = [self initWithNibName:@"TzFullView" bundle:nil]) == nil)
		return nil;
	
	// SCREENSHOT BUTTON
	UIBarButtonItem *but = [[UIBarButtonItem alloc]
							//initWithImage:[global imageFromFile:@"icon_save"]
							//style:UIBarButtonItemStylePlain
							initWithBarButtonSystemItem:UIBarButtonSystemItemAction
							target:self
							action:@selector(share:)];
    [but setTintColor:[UIColor whiteColor]];
	self.navigationItem.rightBarButtonItem = but;
	self.navigationItem.rightBarButtonItem.enabled = TRUE;
	[but release];
	
	// Get 
	switch (kinType) {
		case ORACLE_GUIDE:
			self.title = LOCAL(@"ORACLE_GUIDE");
			break;
		case ORACLE_ANTIPODE:
			self.title = LOCAL(@"ORACLE_ANTIPODE");
			break;
		case ORACLE_DESTINY:
			self.title = LOCAL(@"ORACLE_DESTINY");
			break;
		case ORACLE_ANALOG:
			self.title = LOCAL(@"ORACLE_ANALOG");
			break;
		case ORACLE_OCCULT:
			self.title = LOCAL(@"ORACLE_OCCULT");
			break;
	}

	// Create kin View
	CGRect frame;
	frame = CGRectMake(0.0, 0.0, kscreenWidth, kActiveLessNav);
	kinView = [[AvanteKinView alloc] initWithFrame:frame destinyKin:dkin];
	// Create view
	[kinView setupView:kinType];
	[kinView updateView:tz];
	
	// Create main ScrollView
	frame = CGRectMake(0.0, 0.0, kscreenWidth, kActiveLessNav+64);
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	// SCROLL: INSIDE view
	[scrollView setContentSize:kinView.frame.size];
	// Add kin View
	[scrollView addSubview:kinView];
	[kinView release];

	// Add Scroll to VC
	[self.view addSubview:scrollView];
	[scrollView release];

	// ok!
	return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithTitle:self.prevTitle style:UIBarButtonItemStylePlain target:self action:@selector(goPrev:)];
    [but setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = but;
    [but release];
}
- (void)viewDidAppear:(BOOL)animated {
	global.currentVC = self;
}

#pragma mark SHARING

//
// Display Sharing alert
- (IBAction)share:(id)sender
{
	NSString *text = LOCAL(@"SHARE_EMAIL_KIN_DECODE");
	NSString *body = LOCAL(@"SHARE_EMAIL_BODY_KIN_DECODE");
	[global shareView:kinView vc:self withText:text withBody:body];
}


-(IBAction)goPrev:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}




@end
