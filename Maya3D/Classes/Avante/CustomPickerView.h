//
//  CustomPickerView.h
//  Maya3D
//
//  Created by Roger on 12/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomPickerView : UIView
{
	NSString* title;
	BOOL highlighted;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic) BOOL highlighted;

//- (id)init:(BOOL)h;

@end
