//
//  AvanteView.h
//  Maya3D
//
//  Created by Roger on 05/04/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AvanteView : UIView {
	CGFloat heightFixed;
	CGFloat heightVar;
}

@property (nonatomic) CGFloat heightFixed;
@property (nonatomic) CGFloat heightVar;
@property (nonatomic, readonly, getter=getHeightSum) CGFloat heightSum;

//- (void)addSubview:(UIView *)view;
- (void)addSubviewFixed:(UIView *)view;
- (void)addSubviewVar:(UIView *)view;

@end
