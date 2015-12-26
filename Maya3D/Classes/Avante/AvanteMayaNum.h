//
//  AvanteMayaNum.h
//  Maya3D
//
//  Created by Roger on 21/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"

@interface AvanteMayaNum : UIImageView {
	int num;
	CGFloat size;
	BOOL inverted;
}

@property(nonatomic,retain) NSString* imageName;
- (id)initInv:(int)n x:(CGFloat)x y:(CGFloat)y size:(CGFloat)sz;
- (id)init:(int)n x:(CGFloat)x y:(CGFloat)y size:(CGFloat)sz;
- (void)updateWithNum:(int)n;

@end
