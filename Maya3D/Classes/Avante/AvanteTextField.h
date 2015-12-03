//
//  AvanteTextField.h
//  Maya3D
//
//  Created by Roger on 21/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AvanteTextLabel.h"
#import "AvanteMayaNum.h"

@interface AvanteTextField : UIView {
	// "Button"
	id butTarget;
	SEL butAction;
	// Maya num
	BOOL type;
	AvanteMayaNum *mayaImage;
	// The text field
	UITextField *textField;
	AvanteTextLabel *label;
	// Text properties
	BOOL highlighted;
	CGFloat offsetX;
	CGFloat offsetY;
}

@property (nonatomic, readonly) UITextField *textField;

- (id)initMayaNum:(int)n x:(CGFloat)x y:(CGFloat)y offx:(CGFloat)offx offy:(CGFloat)offy w:(CGFloat)w h:(CGFloat)h size:(CGFloat)sz type:(int)t;
- (id)initMayaNum:(int)n x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h size:(CGFloat)sz type:(int)t;
- (id)init:(NSString*)str x:(CGFloat)x y:(CGFloat)y offx:(CGFloat)offx offy:(CGFloat)offy w:(CGFloat)w h:(CGFloat)h size:(CGFloat)sz;
- (id)init:(NSString*)str x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h size:(CGFloat)sz;
- (void)addTarget:(id)target action:(SEL)action;
- (void)update:(NSString*)str;
- (void)updateMayaNum:(int)n type:(int)t;
- (void)resizeToText;
- (void)resize:(CGFloat)w:(CGFloat)h;


@end
