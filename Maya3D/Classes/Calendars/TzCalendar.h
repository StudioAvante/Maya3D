//
//  TzCalendar.h
//  Maya3D
//
//  Created by Roger on 01/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/NSArray.h>
#import "Tzolkin.h"
#import "TzCalGreg.h"
#import "TzCalLong.h"
#import "TzCalTzolkin.h"
#import "TzCalTzolkinMoon.h"
#import "TzCalHaab.h"
#import "TzCalMoon.h"

// Definicao da classe
@interface TzCalendar : NSObject {
	// Gregorian
	int julian;			// JDN, inicia no meio-dia
	double secs;		// Segundos do dia, a partir do meio-dia
	double decSecs;		// Segundos decimais, notacao do JDN
	// Previous date
	int julianLast;
	double decSecsLast;
	BOOL tick;			// Esta na hora de fazer TICK?
	// Calendars
	TzCalGreg *greg;
	TzCalLong *longCount;
	TzCalHaab *haab;
	TzCalTzolkin *tzolkin;
	TzCalTzolkinMoon *tzolkinMoon;
	TzCalMoon *moon;
}

// Gregorian
@property (nonatomic) int julian;
@property (nonatomic) double secs;
@property (nonatomic) double decSecs;
@property (nonatomic) BOOL tick;
// Maya Long Count
@property (nonatomic, readonly) TzCalGreg *greg;
@property (nonatomic, readonly) TzCalLong *longCount;
@property (nonatomic, readonly) TzCalHaab *haab;
@property (nonatomic, readonly) TzCalTzolkin *tzolkin;
@property (nonatomic, readonly) TzCalTzolkinMoon *tzolkinMoon;
@property (nonatomic, readonly) TzCalMoon *moon;

- (id)initWithToday;
- (id)init:(int)j;
- (id)init:(int)j secs:(int)s;
- (void)updateWithToday;
- (int)updateWithJulian:(int)j;
- (int)updateWithJulian:(int)j secs:(double)s;
- (int)validateJulian:(int)l;
- (int)validateJulian:(int)l secs:(int)s;
- (int)addSeconds:(double)s;
- (void)removeLeap;
- (int)updateWithGreg:(int)d :(int)m :(int)y;
- (int)updateWithMaya:(int)b :(int)k :(int)t :(int)u :(int)i;
- (int)updateWithMayaKin:(int)k;

@end
