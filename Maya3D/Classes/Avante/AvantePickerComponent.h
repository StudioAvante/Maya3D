//
//  AvantePickerElement.h
//  Maya3D
//
//  Created by Roger on 28/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"


@interface AvantePickerComponent : NSObject {
	NSString *title;			// Title of this Component
	CGFloat width;				// Width of this component
	CGFloat height;				// Height of this component
	NSMutableArray* text;		// Data of each component (NSString)
	NSMutableArray* data;		// Data of each component (NSString)
	NSMutableArray* views;		// Views (UIView)
	SEL callback;				// Selection Callback
}

@property (nonatomic, readonly) NSString *title;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) SEL callback;

- (id)init:(NSString*)t w:(int)w h:(int)h;
- (BOOL)addRow:(NSString*)str;
- (BOOL)addRow:(NSString*)str data:(NSString*)dt;
- (BOOL)addRowView:(UIView*)view data:(NSString*)dt;
- (NSUInteger)count;
- (CGFloat)smartHeight;
- (NSString*)dataForRow:(NSInteger)row;
- (NSString*)textForRow:(NSInteger)row;
- (UIView*)viewForRow:(NSInteger)row;
- (NSInteger)indexOfData:(NSString*)str;
- (NSInteger)indexOfDataCloser:(NSInteger)target;
- (NSInteger)indexOfText:(NSString*)str;


@end
