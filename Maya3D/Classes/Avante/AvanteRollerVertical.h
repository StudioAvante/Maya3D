//
//  AvanteRollerVertical.h
//  Maya3D
//
//  Created by Roger on 16/12/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AvanteRollerVertical : UIView <UIScrollViewDelegate> {
	UIScrollView *scrollView;
	id  dragCallbackObj;
	SEL dragCallbackLeft;
	SEL dragCallbackRight;
	NSInteger lastCell;
}

- (id)init:(CGFloat)x:(CGFloat)y;
- (void)addCallback:(id)obj dragLeft:(SEL)action dragRight:(SEL)action;
- (void)scrollBackToCenter;
- (void)stop;

@end
