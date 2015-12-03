//
//  TzCalGreg.h
//  Maya3D
//
//  Created by Roger on 22/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TzCalGreg : NSObject {
	// Data
	int absday;			// 1-366
	int day;			// 1-31
	int month;			// 1-12
	int year;			// ano astronomico
	int bi;				// anos bisextos desde -1331
	BOOL isLeapDay;		// Eh 29/fev?
	int weekDay;		// 0-6, onde 0=monday
	// Hour
	int hour;			// 00-23
	int minute;			// 00-59
	int second;			// 00-59
}

@property (nonatomic) int absday;
@property (nonatomic) int day;
@property (nonatomic) int month;
@property (nonatomic) int year;
@property (nonatomic) int bi;
@property (nonatomic) BOOL isLeapDay;
@property (nonatomic) int weekDay;
@property (nonatomic) int hour;
@property (nonatomic) int minute;
@property (nonatomic) int second;
// "method" properties
@property (nonatomic, readonly, getter=getDayNameFull)		NSString *dayNameFull;
@property (nonatomic, readonly, getter=getDayNameShort)		NSString *dayNameShort;
@property (nonatomic, readonly, getter=getDayNameNum)		NSString *dayNameNum;
@property (nonatomic, readonly, getter=getDayNameHour)		NSString *dayNameHour;
@property (nonatomic, readonly, getter=getHourName)			NSString *hourName;
@property (nonatomic, readonly, getter=getWeekDayName)		NSString *weekDayName;
@property (nonatomic, readonly, getter=getWeekDayNameShort) NSString *weekDayNameShort;

- (id)init:(int)j;
- (id)init:(int)j secs:(int)decSec;
- (void)updateWithJulian:(int)j;
- (void)updateWithJulian:(int)j secs:(int)s;
- (BOOL)amILeapYear;
// Conversores (Class methods)
+(int) convertGregToJulian:(int)d :(int)m :(int)y;
+(int) validateGreg:(int)d :(int)m :(int)y;
+(BOOL) isLeapYear:(int)y;
// Class methods
//+(NSString*) makeDayNameFull:(int)j;
+(NSString*) makeDayNameFull:(int)d :(int)m :(int)y;
+(NSString*) makeDayNameShort:(int)d :(int)m :(int)y;
+(NSString*) makeDayNameNum:(int)d :(int)m :(int)y;
+(NSString*) makeHourName:(int)h :(int)m :(int)s;
+(NSString*) constNameOfMonth:(int)m;
+(NSString*) constNameOfMonthShort:(int)m;
+(NSString*) constNameOfWeekDay:(int)d;
+(NSString*) constNameOfWeekDayShort:(int)d;

@end
