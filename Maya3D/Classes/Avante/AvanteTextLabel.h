//
//  AvanteTextLabel.h
//  Maya3D
//
//  Created by Roger on 21/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"


@interface AvanteTextLabel : UIView {
	UILabel *theLabel;	// Nao derivei esta classe de UILabel porque acontecem rezises indevidos
	CGFloat parentX;
	CGFloat parentY;
	CGFloat width;
	CGFloat height;
	CGSize sizeOrig;
	BOOL framed;
	BOOL wrapped;
	BOOL autoResize;
}

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic, readonly) UILabel *theLabel;


- (id)init:(NSString*)str frame:(CGRect)f size:(CGFloat)sz color:(UIColor*)c;
- (id)init:(NSString*)str x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h size:(CGFloat)sz color:(UIColor*)c;
- (id)init:(NSString*)str x:(CGFloat)x y:(CGFloat)y size:(CGFloat)sz color:(UIColor*)c;
- (void)resizeFrame;
// update
- (void)update:(NSString*)str;
- (void)update:(NSString*)str color:(UIColor*)c;
// setters
- (void)setAlign:(int)a;
- (void)setWrap:(BOOL)wrap;
- (void)setFit:(BOOL)fit;
- (void)setBold:(BOOL)bold;
- (void)setColor:(UIColor*)c;
- (void)setShadow:(UIColor*)c;
- (void)setColorBestShadow:(UIColor*)c;
- (void)setPickerStyle;
- (void)setNavigationBarStyle;

@end
