//
//  TzClock.h
//  Maya3D
//
//  Created by Roger on 03/12/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"

@class Maya3DVC;
@class AvanteTextLabel;

@interface TzClock : NSObject {
	BOOL playing;			// 0 = paused / 1 = playing
	int speed;				// Speed (secs/sec)
	Maya3DVC *clockVC;
	// Clock TimerTimer
    NSTimer *clockTimer;
	CFAbsoluteTime lastTime;
	CFAbsoluteTime lastUIUpdate;
	// Speed View (para o VC do Clock)
	AvanteTextLabel *speedLabel;
	//Acceleration
	BOOL accelerating;				// 0 = paused / 1 = playing
	CFAbsoluteTime accelStart;		// Data do inicio da aceleracao
	CFAbsoluteTime accelLast;		// Data do inicio da aceleracao
	double accelSecs;				// Segundos a incrementar na proxima aceleracao
}

@property (nonatomic) BOOL playing;
@property (nonatomic) int speed;
@property (nonatomic, retain) AvanteTextLabel *speedLabel;

- (void)play;
- (void)pause;
// NSTimer control
- (void)startTimer;
- (void)stopTimer;
- (void)updateClock:(NSTimer*)theTimer;
// Acceletation
- (void)startAcceleration:(double)secs;
- (void)stopAcceleration;
- (double)getAcceleration;


@end
