//
//  AvantePicker.h
//  Maya3D
//
//  Created by Roger on 28/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"
#import "AvantePickerComponent.h"
#import "AvanteTextLabel.h"


@interface AvantePicker : UIPickerView <UIPickerViewDelegate,UIPickerViewDataSource> {
	NSMutableArray* components;		// Array of AvantePickerComponent
	id parent;
	BOOL drawLabels;
}

@property (nonatomic, setter=setDrawLabels:) BOOL drawLabels;

- (id)init:(CGFloat)x y:(CGFloat)y labels:(BOOL)l;
- (void)setDrawLabels:(BOOL)d;
- (void)addComponent:(NSString*)text w:(int)w;
- (void)addComponent:(NSString*)text w:(int)w h:(int)h;
- (BOOL)addRowToComponent:(int)component text:(NSString*)dt;
- (BOOL)addRowToComponent:(int)component text:(NSString*)dt data:(NSString*)str;
- (void)addComponentCallback:(NSInteger)component :(id)obj :(SEL)action;
- (void)selectRowWithData:(NSString*)dt inComponent:(NSInteger)component animated:(BOOL)anim;
- (void)selectRowWithDataCloser:(NSInteger)target inComponent:(NSInteger)component animated:(BOOL)anim;
- (NSString*)selectedRowData:(NSInteger)component;
- (NSString*)selectedRowText:(NSInteger)component;

@end
