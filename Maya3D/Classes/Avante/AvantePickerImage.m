//
//  AvantePicker.m
//  Maya3D
//
//  Created by Roger on 28/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "AvantePickerImage.h"
#import "AvanteMayaNum.h"

@implementation AvantePickerImage


// Adiciona um row (dado)
// Return TRUE ou FALSE
- (BOOL)addRowToComponent:(int)c view:(UIView*)view data:(NSString*)dt
{
	// Find component
	AvantePickerComponent *comp = [components objectAtIndex:c];
	if (comp == nil)
		return FALSE;
	// Add row
	//AvLog(@"NEW ROW at [%d] [%@]", c, str);
	[comp addRowView:view data:dt];
	return TRUE;
}

- (BOOL)addRowToComponent:(int)c imageName:(NSString*)name data:(NSString*)dt
{
    AvantePickerComponent *comp = [components objectAtIndex:c];
    if (comp == nil)
        return FALSE;
    
    [comp addRowImageName:name data:dt];
    return TRUE;
}
// tell the picker which view to use for a given component and row, we have an array of color views to show
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
		  forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if( component >= components.count )
        return nil;
//    
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return nil;
//	else
//		return [comp viewForRow:row];
    
    UIImageView *mayaView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE_BIG,IMAGE_SIZE_BIG)];
    mayaView.image = [UIImage imageNamed:[comp imageNameForRow:row]];
    [mayaView setBackgroundColor:[UIColor clearColor]];
//    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE_BIG, IMAGE_SIZE_BIG)];
//    [view1 addSubview:mayaView];
//    return view1;
    return mayaView;
}

@end


