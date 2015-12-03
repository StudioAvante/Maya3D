//
//  InfoVC.h
//  Maya3D
//
//  Created by Roger on 19/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AvanteTextLabel.h"
#import "Tzolkin.h"

@class AvanteViewStack;

@interface InfoVC : UIViewController <UIScrollViewDelegate>
{
	int pageCount;
	int pageNum;
	int actualPage;
	UIScrollView *workPage;
	UIScrollView *cachedPages[INFO_PAGES_COUNT];
	NSString *pageNames[INFO_PAGES_COUNT];
	AvanteTextLabel *headerLabel;
	int link;
	// IB
	UIPageControl *pageNumbering;
}

// Estes metodos vao aparecer no Interface Builder para ligar no botao
- (id)initWithPage:(int)pg;
- (void)gotoPageLocal:(int)act;
- (void)gotoPage:(int)pg;
- (void)scrollToY:(CGFloat)y animated:(BOOL)animated;
- (void)loadPage;
- (CGSize)setupPage;
- (CGFloat)addText:(NSString*)locTxt y:(CGFloat)y;
- (CGFloat)addText:(NSString*)locTxt x:(CGFloat)x y:(CGFloat)y;
- (CGFloat)addText:(NSString*)locTxt y:(CGFloat)y align:(int)align;
- (CGFloat)addText:(NSString*)locTxt y:(CGFloat)y size:(CGFloat)font;
- (CGFloat)addText:(NSString*)locTxt x:(CGFloat)x y:(CGFloat)y align:(int)align size:(CGFloat)sz;
- (CGFloat)addImage:(NSString*)img y:(CGFloat)y;
- (CGFloat)addImage:(NSString*)img y:(CGFloat)y size:(CGFloat)sz;
- (CGFloat)addImage:(NSString*)img x:(CGFloat)x y:(CGFloat)y;
- (CGFloat)addImage:(NSString*)img x:(CGFloat)x y:(CGFloat)y align:(int)align size:(CGFloat)sz;
- (CGFloat)addMoreButton:(NSString*)locTxt func:(SEL)func y:(CGFloat)y;
- (CGFloat)addMoreButton:(NSString*)locTxt func:(SEL)func y:(CGFloat)y link:(BOOL)lnk;
// Actions
- (IBAction)goPagePrev:(id)sender;
- (IBAction)goPageNext:(id)sender;
- (void)goPageTzolkin;
- (void)goPageHaab;
- (void)goPageLongCount;
- (void)goPage2012;
- (void)goPageHarmonicModule;
- (void)goPageJulianDay;
- (void)goPageClock;
- (void)goPageDatebook;
// Links
- (void)goLinkAvante;
- (void)goLinkMaya3D;
- (void)goLinkSupport;
- (void)goLinkContact;
- (void)goLinkBuyMaya3D;
- (void)goLinkDownloadLite;
- (void)goLinkDownloadKin3D;
- (void)goLinkWeb;
- (void)goLinkBooks;
- (void)goLinkCalendarioDaPaz;
- (void)goLinkSincronarioDaPaz;
- (void)goLinkLawOfTime;
- (void)goLinkTortuga;
- (void)goLinkAppsTzolkin;
- (void)goLinkAppsMaya;

@end
