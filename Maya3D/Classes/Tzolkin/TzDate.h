//
//  TzDate.h
//  Maya3D
//
//  Created by Roger on 04/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"
#import "TzCalendar.h"
#import "CustomPickerView.h"

@interface TzDate : NSObject {
	// Julian Day Number
	int julian;
	int secs;		// segundos do dia
	// Data Gregoriana
	TzCalGreg *greg;
	// Usado no Datebook
	int dateAdded;
	NSString *text;
	NSString *desc;
	BOOL visible;
	BOOL today;
	BOOL fixed;
	CustomPickerView *pickerView;	// View para picker
}

// Data
@property (nonatomic) int julian;
@property (nonatomic) int secs;
@property (nonatomic, readonly) TzCalGreg *greg;
// Para uso no Datebook
@property (nonatomic) int dateAdded;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *desc;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL today;
@property (nonatomic) BOOL fixed;
@property (nonatomic, readonly) CustomPickerView *pickerView;

// Gregoriano > Maya
- (id)init;
- (id)initJulian:(int)j;
- (id)initJulian:(int)j:(NSString*)d;
- (void)setDescription:(NSString*)d;

@end
