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
	frame = CGRectMake(0.0, 0.0, 320.0, kActiveLessNav);
	kinView = [[AvanteKinView alloc] initWithFrame:frame destinyKin:dkin];
	// Create view
	[kinView setupView:kinType];
	[kinView updateView:tz];
	
	// Create main ScrollView
	frame = CGRectMake(0.0, 0.0, 320.0, kActiveLessNav);
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

- (void)viewDidAppear:(BOOL)animated {
	global.currentVC = self;
}

#pragma mark SHARING

//
// Display Sharing alert
- (IBAction)share:(id)sender
{
	[global alertSharing:self];
}
//
// UIAlertView DELEGATE
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)option
{
	NSString *text, *body;
	switch (option)
	{
		case SHARE_LOCAL:
		case SHARE_FACEBOOK:
		case SHARE_TUMBLR:
			text = LOCAL(@"SHARE_FACEBOOK_KIN_DECODE");
			[global shareView:kinView to:option withText:text withBody:nil];
			break;
		case SHARE_TWITTER:
			text = LOCAL(@"SHARE_TWITTER_KIN_DECODE");
			[global shareTwitterText:text];
			break;
		case SHARE_EMAIL:
			text = LOCAL(@"SHARE_EMAIL_KIN_DECODE");
			body = LOCAL(@"SHARE_EMAIL_BODY_KIN_DECODE");
			[global shareView:kinView to:option withText:text withBody:body];
			break;
	}
}





@end
