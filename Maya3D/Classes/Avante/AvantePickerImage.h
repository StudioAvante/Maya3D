//
//  AvantePicker.h
//  Maya3D
//
//  Created by Roger on 28/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"
#import "AvantePicker.h"
#import "AvantePickerComponent.h"


@interface AvantePickerImage : AvantePicker <UIPickerViewDelegate> {

}


- (BOOL)addRowToComponent:(int)c view:(UIView*)view data:(NSString*)dt;
- (BOOL)addRowToComponent:(int)c imageName:(NSString*)name data:(NSString*)dt;
@end
