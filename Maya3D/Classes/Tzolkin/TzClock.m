//
//  TzClock.m
//  Maya3D
//
//  Created by Roger on 03/12/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "TzClock.h"
#import "TzGlobal.h"
#import "Maya3DVC.h"
#import "ClockVC.h"
#import "AvanteTextLabel.h"

@implementation TzClock

@synthesize playing;
@synthesize speed;
@synthesize speedLabel;


- (void)dealloc
{
	[self pause];
	// speedLabel foi riado em TzClockVC
	if (speedLabel)
		[speedLabel release];
    [super dealloc];
}



// CONSTRUCTOR
- (id)init{
	if ([super init] == nil)
		return nil;
	
	// Normal speed (1 sec/sec)
	speed = 1;
	
	// Init playing
	[self play];
	
	// Retorna ponteiro de si mesmo
	return self;
}

// PLAY
- (void)play
{
	if (playing)
		return;
	
	// Start Timer
	[self startTimer];
	playing = TRUE;
	
	// Update clock icon
	//UIViewController *vc = (UIViewController*) [global.theTabBar.viewControllers objectAtIndex:TAB_CLOCK];
	//vc.tabBarItem.image = [global imageFromFile:@"icon_play_big"];
	//[clockVC updateClockIcon];
}

// PAUSE
- (void)pause
{
	if (!playing)
		return;

	// Stop Timer
	[self stopTimer];
	playing = FALSE;
	accelerating = FALSE;
	
	// Update clock icon
	//[clockVC updateClockIcon];
}

#pragma mark NSTIMER CONTROL

// Start the timer
- (void)startTimer
{
	// already started?
	if (clockTimer != nil)
		return;
	// start!
	clockTimer = [NSTimer scheduledTimerWithTimeInterval:CLOCK_INTERVAL target:self selector:@selector(updateClock:) userInfo:nil repeats:YES];
	lastTime = CFAbsoluteTimeGetCurrent();
}
- (void)stopTimer
{
	// already stopped?
	if (clockTimer == nil)
		return;
	// stop!
    [clockTimer invalidate];
	clockTimer = nil;
}

// CLOCK UPDATE
- (void)updateClock:(NSTimer*)theTimer
{
	if (playing == FALSE && accelerating == FALSE)
		return;
	
	// Calcula quantos segundos deve avancar/retroceder
	CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
	double secs;
	// Get current accleration (can return 0.0!)
	if (accelerating)
		secs = [self getAcceleration];
	// Check if acceleration just stopped
	if (!accelerating)
		secs = (now - lastTime) * speed;
	// Save this time
	lastTime = now;
	//AvLog(@"CLOCK update timer*[%d] acc[%d] secs[%f] speed[%d] delta[%f]",theTimer,(int)accelerating,secs,speed,secs);
	
	// Avanca o relogio
	int valid;
	if ((valid = [global.cal addSeconds:secs]) != 0)
	{
		// data invalida
		if (valid < 0)
			[global alertSimple:LOCAL(@"DATE_TOO_LOW")];
		else
			[global alertSimple:LOCAL(@"DATE_TOO_HIGH")];
		// pause clock
		[self pause];
		return;
	}
	
	// Update clock view?
	if (global.currentTab == TAB_CLOCK && (now-lastUIUpdate) >= (1.0/4.0) )
	{
		//AvLog(@"UPDATE CLOCK VIEW");
		[(ClockVC*)global.currentVC updateClockPicker:TRUE];
		lastUIUpdate = now;
	}
}


#pragma mark ACCELERATION

// Start acceleration
- (void)startAcceleration:(double)secs
{
	accelerating = TRUE;
	accelStart = CFAbsoluteTimeGetCurrent();
	accelSecs = secs;
	// Start timer?
	[self startTimer];
	//AvLog(@"ACCELERATE!!! secs[%.3f]",accelSecs);
}

// Stop acceleration
- (void)stopAcceleration
{
	accelerating = FALSE;
}

#define ACCEL_DURATION	2.0		// Segundos de aceleracao
#define ACCEL_GAIN		1.0		// Segundos para recuperar a velocidade do relogio

// Gear acceleration
- (double)getAcceleration
{
	// Decrementa proximos segundos
	CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
	CFAbsoluteTime diff = (now - accelStart);
	double secs = 0.0;
	// Get acceleration
	if (diff < ACCEL_DURATION)
		secs = accelSecs *= (cos (diff/ACCEL_DURATION));
	// Regain clock speed
	else if (playing && diff < (ACCEL_DURATION+ACCEL_GAIN))
		secs = (now - lastTime) * (speed * (sin ((diff-ACCEL_DURATION)/ACCEL_GAIN)) );
	// Stop timer
	else
	{
		[self stopAcceleration];
		if (!playing)
			[self stopTimer];
	}
	//AvLog(@"ACCELERATING... secs[%.3f] diff[%.3f] cf[%f] cos[%f]",accelSecs,diff,(diff/ACCEL_DURATION),(cos (diff/ACCEL_DURATION)));
	
	// Return secs
	return secs;
}



@end
