//
//  InfoVC.m
//  Maya3D
//
//  Created by Roger on 19/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "InfoVC.h"
#import "Tzolkin.h"
#import "TzGlobal.h"
#import "TzCalendar.h"
#import "TzSoundManager.h"
#import "AvanteTextLabel.h"
#import "AvanteKinView.h"
#import "AvanteRollerVertical.h"

@implementation InfoVC

#ifdef LITE
#define	CACHE_PAGES				1
#else
#define	CACHE_PAGES				0	// << CHECK FOR PROD : 0
#endif
#define	CACHED_IMAGES			1	// << CHECK FOR PROD : 1

#define INFO_GAP				8.0
#define HEADER_HEIGHT			35.0
#define TRAILER_HEIGHT			22.0
//#define CONTENT_HEIGHT			(kActiveLessNav - HEADER_HEIGHT - TRAILER_HEIGHT - kRollerVerticalHeight)
#define BUTTON_SIZE				20.0

#define INFO_BACK_COLOR			([UIColor blackColor])
#define INFO_TEXT_COLOR			([UIColor whiteColor])

// Info Pages
// MAYA only
const int activePages[] = {
#if (MAYA_ONLY)
#ifdef LITE
INFO_BASICS,
INFO_BUY_FULL,
INFO_ABOUT_LITE,
#else
INFO_BASICS,
INFO_MAYA,
INFO_TZOLKIN,
INFO_HAAB,
INFO_LONG_COUNT,
INFO_2012,
INFO_MAYA_GLYPH,
INFO_MAYA_ORACLE,
INFO_GREGORIAN,
INFO_JULIAN,
INFO_TIMER,
INFO_DATEBOOK,
INFO_DREAMSPELL,
INFO_ABOUT,
#endif	// LITE
#elif (DREAMSPELL_ONLY)
// DREAMSPELL only
#ifdef LITE
INFO_BASICS,
INFO_DREAMSPELL,
INFO_DREAMSPELL_MORE,
INFO_BUY_FULL,
INFO_ABOUT_LITE,
#else
INFO_BASICS,
INFO_DREAMSPELL,
INFO_TZOLKIN_DREAMSPELL,
INFO_HARMONIC_MODULE,
INFO_13MOON,
INFO_DREAMSPELL_KIN,
INFO_DREAMSPELL_ORACLE,
INFO_MAYA,
INFO_2012,
INFO_GREGORIAN,
INFO_JULIAN,
INFO_TIMER,
INFO_DATEBOOK,
INFO_DREAMSPELL_MORE,
INFO_BUY_FULL,
INFO_ABOUT,
#endif	// LITE
#else
// DUAL
INFO_BASICS,
INFO_MAYA,
INFO_TZOLKIN,
INFO_HAAB,
INFO_LONG_COUNT,
INFO_2012,
INFO_MAYA_GLYPH,
INFO_MAYA_ORACLE,
INFO_DREAMSPELL,
INFO_TZOLKIN_DREAMSPELL,
INFO_HARMONIC_MODULE,
INFO_13MOON,
INFO_DREAMSPELL_KIN,
INFO_DREAMSPELL_ORACLE,
INFO_GREGORIAN,
INFO_JULIAN,
INFO_TIMER,
INFO_DATEBOOK,
INFO_ABOUT,
#endif
-1
};


- (void)dealloc {
	// views
	if (CACHE_PAGES)
	{
		for (int n = 0 ; n < INFO_PAGES_COUNT ; n++)
			if (cachedPages[n])
				[cachedPages[n] removeFromSuperview];
	}
	else
	{
		if (workPage)
			[workPage removeFromSuperview];
	}
	// super
	[super dealloc];
}

// MEMORY!!!
- (void)didReceiveMemoryWarning {
	AvLog(@"MEMORY WARNING: InfoVC...");
	// Libera paginas em cache
	for (int n = 0 ; n < INFO_PAGES_COUNT ; n++)
	{
		if (cachedPages[n] && n != actualPage)
		{
			AvLog(@"MEMORY WARNING: InfoVC... free page[%d]",n);
			[cachedPages[n] removeFromSuperview];
			cachedPages[n] = nil;
		}
	}
	// super
	[super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    


    
}
- (void)viewWillAppear:(BOOL)animated
{
	// load page
	//[self loadPage];
//    [self.navigationItem.leftBarButtonItem. setTitle:@"go"];
//    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];

    
//    but = [[UIBarButtonItem alloc]
//           //initWithImage: [global imageFromFile:@"icon_save"]
//           //style:UIBarButtonItemStylePlain
//           initWithBarButtonSystemItem:UIBarButtonSystemItemUndo
//           target:self
//           action:@selector(goPrev:)];
    UIBarButtonItem *but;
    but = [[UIBarButtonItem alloc] initWithTitle:self.prevTitle style:UIBarButtonItemStylePlain target:self action:@selector(goPrev:)];
    
    [but setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = but;
    self.navigationItem.leftBarButtonItem.enabled = TRUE;
    [but release];

}
- (void)viewDidAppear:(BOOL)animated
{
	// Title
	[self navigationController].navigationBar.topItem.title = LOCAL(@"INFO_SCREEN");
//    [[self navigationController].navigationBar.backItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
	// Flash indicator
	//[workPage flashScrollIndicators];
}

-(void)SetPrevTitle:(NSString *)title
{
    self.prevTitle = [[NSString alloc] initWithString:title];//[NSString stringWithString:title];
}
- (IBAction)goPrev:(id)sender  
{
    [self.navigationController popViewControllerAnimated:YES];
}

//
// INIT
//
- (id)initWithPage:(int)pg
{
    CONTENT_HEIGHT	=	(kActive - HEADER_HEIGHT - TRAILER_HEIGHT - kRollerVerticalHeight+kStatusBarHeight);
//    CONTENT_HEIGHT	=	(kActiveLessNav  - kRollerVerticalHeight);
    // Suuuper
	if ( (self = [super initWithNibName:@"TzFullView" bundle:nil]) == nil)
		return nil;
	
	CGRect frame;
	CGFloat font;
	CGFloat y, h;
	
	// Count pages
	for (pageCount = 0 ; activePages[pageCount] >= 0 ; pageCount++)
		;
	AvLog(@"InfoVC PAGE_COUNT[%d] pageCount[%d]",INFO_PAGES_COUNT,pageCount);
	
	// Cria Header
	font = FONT_SIZE_NAME;
	h = HEIGHT_FOR_LINES(font,1);
	frame = CGRectMake(0.0, INFO_GAP +kStatusBarHeight+44, kscreenWidth, h);
	headerLabel = [[AvanteTextLabel alloc] init:@"header" frame:frame size:FONT_SIZE_NAME color:[UIColor whiteColor]];
	[self.view addSubview:headerLabel ];
	[headerLabel release];
	
	// Page control
	y = (kActive-kPageControlHeight-kRollerVerticalHeight+kStatusBarHeight);
	frame = CGRectMake(0.0, y, kscreenWidth, kPageControlHeight);
	pageNumbering = [[UIPageControl alloc] initWithFrame:frame];
	pageNumbering.numberOfPages = pageCount;
	pageNumbering.userInteractionEnabled = NO;
	[self.view addSubview:pageNumbering ];
	[pageNumbering release];
	
	// Cria Roller
	//y += kPageControlHeight;
//    AvanteRollerVertical *roller = [[AvanteRollerVertical alloc] init:0.0:(kActiveLessNav - kRollerVerticalHeight)];//y];
    AvanteRollerVertical *roller = [[AvanteRollerVertical alloc] init:0.0:(kActive-kRollerVerticalHeight+kStatusBarHeight)];//y];
    [roller addCallback:self dragLeft:@selector(goPagePrev:) dragRight:@selector(goPageNext:)];
	[self.view addSubview:roller];
	[roller release];
	
	// load page
	[self gotoPage:pg];
	
    //[self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
	// ok!
    
	return self;
}

//
// GOTO PAGE
//
- (void)gotoPageLocal:(int)pg
{
	[self gotoPage:activePages[pg]];
}
- (void)gotoPage:(int)actual
{
	// Validate page number
	AvLog(@"INFO: goto actual[%d]...",actual);
	if ( actual < 0 || actual >= INFO_PAGES_COUNT )
	{
		AvLog(@"ERRO: Invlaid page num actual[%d]",actual);
		return;
	}
	
	// Erase old page
	//AvLog(@"INFO old [%d] new[%d]", pageNum, actualPage);
	if (actual != actualPage && workPage)
	{
		//AvLog(@"INFO old*[%d] subviews [%d]", workPage,[self.view.subviews count]);
		if (CACHE_PAGES)
		{
			// Se cacheia, esconde a atual e pega a nova do cache
			workPage.hidden = TRUE;
			workPage = cachedPages[actual];
		}
		else
		{
			// se nao cacheia, destroi antiga!
			[workPage removeFromSuperview];
			workPage = nil;
		}
		//AvLog(@"INFO old*[%d] subviews [%d]", workPage,[self.view.subviews count]);
	}
	// set current page num
	actualPage = actual;
	
	// local page
	for (pageNum = 0 ; activePages[pageNum] != actualPage ; pageNum++)
		;
	// Ajusta marcador de paginas
	pageNumbering.currentPage = pageNum;
	
	// load page
	if (workPage == nil)
		[self loadPage];
	workPage.hidden = FALSE;
	
	// flash!
	[workPage flashScrollIndicators];
	
	// Atualiza Header
	[headerLabel update:pageNames[actualPage]];
	
	// Play Sound
	if (global.prefGearSound != GEAR_SOUND_QUIET)
		[global.soundLib playWave:WAVE_TICK];
	
	// free old pages
	AvLog(@"INFO Page [%d/%d] [%@] OK!",pageNum,actualPage,pageNames[actualPage]);
}

// Scroll to Y position & Flash indicator
- (void)scrollToY:(CGFloat)y  animated:(BOOL)animated
{
	// save inset (se setado mela o scroll)
	UIEdgeInsets inset = workPage.contentInset;
	[workPage setContentInset:UIEdgeInsetsZero];
	
	// scroll!
	CGRect frame = CGRectMake(0.0, y, 1.0, 1.0);
	[workPage scrollRectToVisible:frame animated:animated];
	[workPage flashScrollIndicators];
	
	//restore inset
	[workPage setContentInset:inset];
}


#pragma mark SETUP

// Load page
- (void)loadPage
{
	CGSize size;
	AvLog(@"INFO Page loading...");
	
	// Ajusta Scroll View para o tamanho da imagem
	CGRect frame = CGRectMake(0.0, HEADER_HEIGHT, kscreenWidth, CONTENT_HEIGHT);
	workPage = [[UIScrollView alloc] initWithFrame:frame];
	workPage.backgroundColor = INFO_BACK_COLOR;
	workPage.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	//workPage.userInteractionEnabled = YES;	// para botoes
	// add scroll
	[self.view addSubview:workPage];
	// Deixa o unico retain na view - para destruir, basta remove-la
	[workPage release];
	
	// Setup page
	size = [self setupPage];
	
	// resize contents view
	[workPage setContentSize:size];
	
	// Cache page?
	if (CACHE_PAGES)
		cachedPages[actualPage] = workPage;
}

//
// ADD TEXT
//
- (CGFloat)addText:(NSString*)locTxt y:(CGFloat)y
{
	return [self addText:locTxt x:0.0 y:y align:ALIGN_LEFT size:FONT_SIZE_HELP];
}
- (CGFloat)addText:(NSString*)locTxt x:(CGFloat)x y:(CGFloat)y
{
	return [self addText:locTxt x:x y:y align:ALIGN_LEFT size:FONT_SIZE_HELP];
}
- (CGFloat)addText:(NSString*)locTxt y:(CGFloat)y align:(int)align
{
	return [self addText:locTxt x:0.0 y:y align:align size:FONT_SIZE_HELP];
}
- (CGFloat)addText:(NSString*)locTxt y:(CGFloat)y size:(CGFloat)font
{
	return [self addText:locTxt x:0.0 y:y align:ALIGN_LEFT size:font];
}
- (CGFloat)addText:(NSString*)locTxt x:(CGFloat)x y:(CGFloat)y align:(int)align size:(CGFloat)font
{
	NSString *text = LOCAL(locTxt);
	AvanteTextLabel *label;
	CGSize size;
	CGRect frame;
	CGFloat w, h;
	
	// Find text size
	w = (kscreenWidth-x-INFO_GAP-INFO_GAP);
	size = CGSizeMake(w, 500.0);
	size = [text sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
	h = size.height;
	
	// Add text view
	frame = CGRectMake(x+INFO_GAP, y, w, h);
	label = [[AvanteTextLabel alloc] init:text frame:frame size:font color:INFO_TEXT_COLOR];
	[label setAlign:align];
	[label setWrap:YES];
	//[label setBold:YES];
	// Add to the page
	[workPage addSubview:label];
	// release
	[label release];
	
	// Return view height
	return (h + INFO_GAP);
}

//
// ADD IMAGE
//
- (CGFloat)addImage:(NSString*)img y:(CGFloat)y
{
	return [self addImage:img x:0.0 y:y align:ALIGN_CENTER size:0.0];
}
- (CGFloat)addImage:(NSString*)img y:(CGFloat)y size:(CGFloat)sz
{
	return [self addImage:img x:0.0 y:y align:ALIGN_CENTER size:sz];
}
- (CGFloat)addImage:(NSString*)img x:(CGFloat)x y:(CGFloat)y
{
	return [self addImage:img x:x y:y align:ALIGN_LEFT size:0.0];
}
- (CGFloat)addImage:(NSString*)img x:(CGFloat)x y:(CGFloat)y align:(int)align size:(CGFloat)sz
{
	UIImageView *imageView;
	UIImage *image;
	CGRect frame;
	CGFloat w, h;
	
	// Make filename
	// Tenta com LANG
	image = [global imageFromFile:[NSString stringWithFormat:@"%@-%@",img,global.prefLangSuffix]];
	// Tenta sem LANG
	if (image == nil)
		image = [global imageFromFile:img];
	// Se nao achou poe dummy!
	else if (image == nil)
		image = [global imageFromFile:@"dummy"];
	//AvLog(@"filename [%@]",filename);
	
	// Load image - NO CACHE
	// Save height
	if (sz)
	{
		w = sz;
		h = sz;
	}
	else
	{
		w = image.size.width;
		h = image.size.height;
	}
	
	// Align
	if (x == 0.0 && align == ALIGN_CENTER)
		x = floor((kscreenWidth - w) / 2.0);
	
	// Create view
	frame = CGRectMake( x, y, w, h);
	imageView = [[UIImageView alloc] initWithFrame:frame];
	imageView.image = image;
	// Add to the page
	[workPage addSubview:imageView];
	// release
	[imageView release];
	//[image release];
	
	// Return view height
	return (h + INFO_GAP);
}

//
// MORE BUTTON
//
- (CGFloat)addMoreButton:(NSString*)locTxt func:(SEL)func y:(CGFloat)y
{
	return [self addMoreButton:locTxt func:func y:y link:false];
}
- (CGFloat)addMoreButton:(NSString*)locTxt func:(SEL)func y:(CGFloat)y link:(BOOL)lnk
{
	UIButton *button;
    UIImage *helpImg = [UIImage imageNamed:@"icon_info3.png"];
    UIImage *linkImg = [UIImage imageNamed:@"icon_link2.png"];
    
	// more button
	button = [UIButton buttonWithType:UIButtonTypeCustom];
    
	if (lnk)
    {
		[button setImage:linkImg forState:UIControlStateNormal];
        button.frame = CGRectMake(35.0, y, linkImg.size.width, linkImg.size.height);
    }
	else
    {
		[button setImage:helpImg forState:UIControlStateNormal];
        button.frame = CGRectMake(35.0, y, helpImg.size.width, helpImg.size.width);
    }
	
    /*
	button.backgroundColor = [UIColor clearColor];
    button.tintColor = [UIColor whiteColor];
     */
     
	[button addTarget:self action:func forControlEvents:UIControlEventTouchUpInside];	
	[workPage addSubview:button];
	//[button release];
	// more text
	[self addText:locTxt x:60.0 y:y+2.0];
	return (BUTTON_SIZE + INFO_GAP);
}

//
// SETUP PAGE
//
- (CGSize)setupPage
{
	UIButton *button;
	NSString *nameLoc;
	NSString *str;
	CGFloat y = 0.0;
	CGFloat w = kscreenWidth;
	CGFloat h = 0.0;
	CGFloat xx, yy;
	
    CGFloat font;
    
    font = FONT_SIZE_NAME;
    h = HEIGHT_FOR_LINES(font,1);
    y += INFO_GAP +kStatusBarHeight+h ;
    // Seta titulo e texto
	switch (actualPage)
	{
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_BASICS:
			nameLoc = @"INFO_BASICS";
			// setup page
			if (ENABLE_MAYA)
				y += [self addText:@"INFO_BASICS_01" y:y];
			else
				y += [self addText:@"INFO_BASICS_01_DREAMSPELL" y:y];
			if (DUAL_MODE)
			{
				y += [self addText:@"INFO_BASICS_02" y:y];
				// TODO: DUAL: ES: traduzir switch-es.png
				y += [self addImage:@"switch" y:y];
			}
			y += [self addText:@"INFO_BASICS_03" y:y];
			if (ENABLE_MAYA)
				y += [self addImage:@"3d_maya" y:y];
			else
				y += [self addImage:@"3d_dreamspell" y:y];
			
#ifdef LITE
			// picker
			y += [self addText:@"INFO_BASICS_11" y:y];
			h = [self addImage:@"but_picker" x:20.0 y:y];
			[self addText:@"INFO_BUT_PICKER" x:80.0 y:y+8.0];
			y += h;
#else
			// TIMER
			y += [self addText:@"INFO_BASICS_04" y:y];
			if (CACHED_IMAGES)
				y += [self addImage:@"buts_clock_play" x:0.0 y:y];
			else
			{
				// clock play
				h = [self addImage:@"but_clock_playing" x:20.0 y:y];
				[self addText:@"INFO_BUT_CLOCK_PLAYING" x:80.0 y:y+8.0];
				y += h;
				// clock pause
				h = [self addImage:@"but_clock_paused" x:20.0 y:y];
				[self addText:@"INFO_BUT_CLOCK_PAUSED" x:80.0 y:y+8.0];
				y += h;
			}
			// more...
			y += [self addMoreButton:@"INFO_MORE_CLOCK" func:@selector(goPageClock) y:y];
			
			// EXPLORER TAB
			y += [self addText:@"INFO_BASICS_05a" y:y];
			if (CACHED_IMAGES)
			{
				y += [self addImage:@"tabs_explorer" x:0.0 y:y];
			}
			else
			{
				h = [self addImage:@"tab_explorer" x:20.0 y:y];
				[self addText:@"INFO_TAB_EXPLORER" x:80.0 y:y+15.0];
				y += h;
			}
			y += [self addText:@"INFO_BASICS_05b" y:y];
			y += [self addImage:@"explorer" y:y];
			
			// scroller
			y += [self addText:@"INFO_BASICS_07" y:y];
			y += [self addImage:@"roller" y:y];
			
			// SETTINGS
			y += [self addText:@"INFO_BASICS_09" y:y];
			if (CACHED_IMAGES)
				y += [self addImage:@"buts_settings" x:0.0 y:y];
			else
			{
				// sett 1
				h = [self addImage:@"but_settings" x:20.0 y:y];
				[self addText:@"INFO_BUT_SETTINGS" x:70.0 y:y+8.0];
				y += h;
				// sett 2
				h = [self addImage:@"but_date_add" x:20.0 y:y];
				[self addText:@"INFO_BUT_DATE_ADD" x:80.0 y:y+8.0];
				y += h;
			}
			
			// Datebook
			y += [self addText:@"INFO_BASICS_10" y:y];
			h = [self addImage:@"tab_datebook" x:20.0 y:y];
			[self addText:@"INFO_TAB_DATEBOOK" x:80.0 y:y+15.0];
			y += h;
			// more...
			y += [self addMoreButton:@"INFO_MORE_DATEBOOK" func:@selector(goPageDatebook) y:y];

			// OTHER TABS
			if (MAYA_ONLY)
				y += [self addText:@"INFO_BASICS_06_MAYA" y:y];
			else if (DREAMSPELL_ONLY)
				y += [self addText:@"INFO_BASICS_06_DREAMSPELL" y:y];
			else
				y += [self addText:@"INFO_BASICS_06" y:y];
			if (CACHED_IMAGES)
			{
				if (MAYA_ONLY)
					y += [self addImage:@"tabs_maya" x:0.0 y:y];
				else if (DREAMSPELL_ONLY)
					y += [self addImage:@"tabs_dreamspell" x:0.0 y:y];
				// TODO: DUAL: ES: traduzir tabs-es.png
				else
					y += [self addImage:@"tabs" x:0.0 y:y];
			}
			else
			{
				// tab maya glyph
				if (ENABLE_MAYA)
				{
					h = [self addImage:@"tab_glyph" x:20.0 y:y];
					[self addText:@"INFO_TAB_GLYPH" x:80.0 y:y+15.0];
					y += h;
				}
				// tab kin
				if (ENABLE_DREAMSPELL)
				{
					h = [self addImage:@"tab_kin" x:20.0 y:y];
					[self addText:@"INFO_TAB_KIN" x:80.0 y:y+15.0];
					y += h;
				}
				// tab oracle
				h = [self addImage:@"tab_oracle" x:20.0 y:y];
				[self addText:@"INFO_TAB_ORACLE" x:80.0 y:y+15.0];
				y += h;
			}
			
			// FULLSCREEN
			y += [self addText:@"INFO_BASICS_08" y:y];
			if (CACHED_IMAGES)
				//y += [self addImage:@"buts_fullscreen" x:0.0 y:y];
				y += [self addImage:@"buts_screenshot" x:0.0 y:y];
			else
			{
				// full 1
				h = [self addImage:@"but_fullscreen" x:20.0 y:y];
				[self addText:@"INFO_BUT_FULL" x:70.0 y:y+8.0];
				y += h;
				// full 2
				h = [self addImage:@"but_save" x:20.0 y:y];
				[self addText:@"INFO_BUT_SHOT" x:70.0 y:y+8.0];
				y += h;
			}
			
#endif
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_MAYA:
			nameLoc = @"INFO_MAYA";
			// setup page
			y += [self addText:@"INFO_MAYA_01" y:y];
#ifdef OLDLITE
			y += [self addMoreButton:@"LITE_ALERT_INFO" func:@selector(goLinkBuyMaya3D) y:y link:YES];
			break;
#endif
			y += [self addText:@"INFO_MAYA_02" y:y];
			
			// numbers
			if (CACHED_IMAGES)
				y += [self addImage:@"maya_numbers" y:y];
			else
			{
				CGFloat size = IMAGE_SIZE_BIG;
				int lines = 5;
				for (int n = 0 ; n < 20 ; n++)
				{
					// Maya num
					str = [NSString stringWithFormat:@"numbig%02di",n];
					xx = (INFO_GAP+(80.0*(n/lines)));
					yy = (y+(size*(n%lines)));
					h = [self addImage:str x:xx y:yy];
					// Num
					xx += size;
					[self addText:[NSString stringWithFormat:@"%d",n] x:xx y:yy+10.0 align:ALIGN_LEFT size:FONT_SIZE_TEXT];
				}
				y += ((lines * size) + INFO_GAP);
			}
			
			// resto
			y += [self addText:@"INFO_MAYA_03" y:y];
			if (ENABLE_MAYA)
			{
				y += [self addMoreButton:@"INFO_MORE_TZOLKIN" func:@selector(goPageTzolkin) y:y];
				y += [self addMoreButton:@"INFO_MORE_HAAB" func:@selector(goPageHaab) y:y];
				y += [self addText:@"INFO_MAYA_04" y:y];
				y += [self addImage:@"3d_maya" y:y];
			}
			y += [self addText:@"INFO_MAYA_05" y:y];
			if (ENABLE_MAYA)
				y += [self addMoreButton:@"INFO_MORE_LONG_COUNT" func:@selector(goPageLongCount) y:y];
			y += [self addText:@"INFO_MAYA_06" y:y];
			if (ENABLE_MAYA)
				y += [self addMoreButton:@"INFO_MORE_2012" func:@selector(goPage2012) y:y];
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_TZOLKIN:
			nameLoc = @"INFO_TZOLKIN";
			// setup page
			y += [self addText:@"INFO_TZOLKIN_01" y:y];
			y += [self addText:@"INFO_TZOLKIN_02" y:y];
			y += [self addText:@"INFO_TZOLKIN_03" y:y];
			y += [self addText:@"INFO_TZOLKIN_04" y:y];
			
			// DAYS
			if (CACHED_IMAGES)
				y += [self addImage:@"tzolkin_days" x:0.0 y:y];
			else
			{
				CGFloat size = 40.0;
				int lines = 10;
				for (int n = 0 ; n < 20 ; n++)
				{
					// Maya num
					str = [NSString stringWithFormat:@"tzday%02d",n+1];
					xx = (INFO_GAP+(160.0*(n/lines)));
					yy = (y+(size*(n%lines)));
					h = [self addImage:str x:xx y:yy align:ALIGN_LEFT size:size];
					// Name
					xx += size;
					str = [NSString stringWithFormat:@"%d: %@",n+1,[TzCalTzolkin constDayName:n+1]];
					[self addText:str x:xx y:yy+10.0];
				}
				y += ((lines * size) + INFO_GAP);
			}
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_HAAB:
			nameLoc = @"INFO_HAAB";
			// setup page
			y += [self addText:@"INFO_HAAB_01" y:y];
			y += [self addText:@"INFO_HAAB_02" y:y];
			y += [self addText:@"INFO_HAAB_03" y:y];
			y += [self addText:@"INFO_HAAB_04" y:y];
			
			// UINALS
			if (CACHED_IMAGES)
				y += [self addImage:@"uinals" x:0.0 y:y];
			else
			{
				CGFloat size = 40.0;
				int lines = 10;
				for (int n = 0 ; n < 19 ; n++)
				{
					// Maya num
					str = [NSString stringWithFormat:@"uinal%02d",n];
					xx = (INFO_GAP+(160.0*(n/lines)));
					yy = (y+(size*(n%lines)));
					h = [self addImage:str x:xx y:yy align:ALIGN_LEFT size:size];
					// Name
					xx += size;
					str = [NSString stringWithFormat:@"%d: %@",n,[TzCalHaab constUinalName:n]];
					[self addText:str x:xx y:yy+10.0];
				}
				y += ((lines * size) + INFO_GAP);
			}
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_LONG_COUNT:
			nameLoc = @"INFO_LONG_COUNT";
			// setup page
			y += [self addText:@"INFO_LONG_COUNT_01" y:y];
			y += [self addText:@"INFO_LONG_COUNT_02" y:y];
			y += [self addImage:@"long_count_days" y:y];
			y += [self addText:@"INFO_LONG_COUNT_03" y:y];
			y += [self addImage:@"long_count" y:y];
			y += [self addText:@"INFO_LONG_COUNT_04" y:y];
			y += [self addImage:@"long_count_long" y:y];
			y += [self addText:@"INFO_LONG_COUNT_05" y:y];
			y += [self addMoreButton:@"INFO_MORE_JUIAN_DAY" func:@selector(goPageJulianDay) y:y];
			y += [self addText:@"INFO_LONG_COUNT_06" y:y];
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_2012:
			nameLoc = @"INFO_2012";
			// setup page
			y += [self addText:@"INFO_2012_01" y:y];
			y += [self addText:@"INFO_2012_02" y:y];
			y += [self addText:@"INFO_2012_03" y:y];
			y += [self addText:@"INFO_2012_04" y:y];
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_MAYA_GLYPH:
			nameLoc = @"INFO_MAYA_GLYPH";
			// setup page
			y += [self addText:@"INFO_MAYA_GLYPH_01" y:y];
			y += [self addText:@"INFO_MAYA_GLYPH_02" y:y];
			y += [self addText:@"INFO_MAYA_GLYPH_03" y:y];
			y += [self addImage:@"maya_glyph" y:y];
			y += [self addText:@"INFO_MAYA_GLYPH_04" y:y];
			// photo
			if (CACHED_IMAGES)
				y += [self addImage:@"buts_screenshot" x:0.0 y:y];
			else
			{
				h = [self addImage:@"but_save" x:20.0 y:y];
				[self addText:@"INFO_BUT_SHOT" x:70.0 y:y+8.0];
				y += h;
			}
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_MAYA_ORACLE:
			nameLoc = @"INFO_MAYA_ORACLE";
			// setup page
			y += [self addText:@"INFO_MAYA_ORACLE_01" y:y];
			y += [self addText:@"INFO_MAYA_ORACLE_02" y:y];
			y += [self addImage:@"maya_oracle_year" y:y];
			y += [self addText:@"INFO_MAYA_ORACLE_03" y:y];
			y += [self addImage:@"maya_oracle_day" y:y];
			y += [self addText:@"INFO_MAYA_ORACLE_04" y:y];
			// fullscreen
			if (CACHED_IMAGES)
				//y += [self addImage:@"buts_fullscreen" x:0.0 y:y];
				y += [self addImage:@"buts_screenshot" x:0.0 y:y];
			else
			{
				// full 1
				//h = [self addImage:@"but_fullscreen" x:20.0 y:y];
				h = [self addImage:@"buts_screenshot" x:20.0 y:y];
				[self addText:@"INFO_BUT_FULL" x:70.0 y:y+8.0];
				y += h;
				// full 2
				h = [self addImage:@"but_save" x:20.0 y:y];
				[self addText:@"INFO_BUT_SHOT" x:70.0 y:y+8.0];
				y += h;
			}
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_DREAMSPELL:
			nameLoc = @"INFO_DREAMSPELL";
			// setup page
			if (MAYA_ONLY)
			{
				y += [self addText:@"INFO_DREAMSPELL_00" y:y];
				y += [self addImage:@"3d_dreamspell" y:y];
				y += [self addMoreButton:@"INFO_LINK_DOWNLOAD_KIN3D" func:@selector(goLinkDownloadKin3D) y:y link:YES];
				y += [self addText:@"INFO_DREAMSPELL_01" y:y];
				y += [self addText:@"INFO_DREAMSPELL_03_short" y:y];
				// LINKS
				y += [self addText:@"INFO_LINKS" y:y size:FONT_SIZE_NAME];
				if (global.prefLang != LANG_EN)
				{
					y += [self addMoreButton:@"INFO_LINK_SINCRONARIO_DA_PAZ" func:@selector(goLinkSincronarioDaPaz) y:y link:YES];
					y += [self addMoreButton:@"INFO_LINK_CALENDARIO_DA_PAZ" func:@selector(goLinkCalendarioDaPaz) y:y link:YES];
				}
				y += [self addMoreButton:@"INFO_LINK_LAW_OF_TIME" func:@selector(goLinkLawOfTime) y:y link:YES];
				y += 10;
				y += [self addMoreButton:@"INFO_LINK_TORTUGA" func:@selector(goLinkTortuga) y:y link:YES];
				// BOOKS
				y += [self addText:@"INFO_BOOKS" y:y size:FONT_SIZE_NAME];
				y += [self addText:@"INFO_BOOKS_DREAMSPELL_01" y:y];
				y += [self addText:@"INFO_BOOKS_DREAMSPELL_02" y:y];
				y += [self addMoreButton:@"INFO_LINK_BOOKS_BUY" func:@selector(goLinkBooks) y:y link:YES];
				// APPS
				y += [self addText:@"INFO_APPS" y:y size:FONT_SIZE_NAME];
				y += [self addMoreButton:@"INFO_APPS_TZOLKIN" func:@selector(goLinkAppsTzolkin) y:y link:YES];
				y += 10;
				//y += [self addMoreButton:@"INFO_APPS_MAYA" func:@selector(goLinkAppsMaya) y:y link:YES];
				//y += 10;
			}
			else
			{
				y += [self addText:@"INFO_DREAMSPELL_01" y:y];
				y += [self addText:@"INFO_DREAMSPELL_02" y:y];
				y += [self addText:@"INFO_DREAMSPELL_03" y:y];
				y += [self addText:@"INFO_DREAMSPELL_04" y:y];
				y += [self addText:@"INFO_DREAMSPELL_05" y:y];
				y += [self addText:@"INFO_DREAMSPELL_06" y:y];
				y += [self addText:@"INFO_DREAMSPELL_07" y:y];
			}
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_DREAMSPELL_MORE:
			nameLoc = @"INFO_DREAMSPELL_MORE";
			// LINKS
			y += [self addText:@"INFO_LINKS" y:y size:FONT_SIZE_NAME];
			if (global.prefLang != LANG_EN)
			{
				y += [self addMoreButton:@"INFO_LINK_SINCRONARIO_DA_PAZ" func:@selector(goLinkSincronarioDaPaz) y:y link:YES];
				y += [self addMoreButton:@"INFO_LINK_CALENDARIO_DA_PAZ" func:@selector(goLinkCalendarioDaPaz) y:y link:YES];
			}
			y += [self addMoreButton:@"INFO_LINK_LAW_OF_TIME" func:@selector(goLinkLawOfTime) y:y link:YES];
			y += 10;
			y += [self addMoreButton:@"INFO_LINK_TORTUGA" func:@selector(goLinkTortuga) y:y link:YES];
			// BOOKS
			y += [self addText:@"INFO_BOOKS" y:y size:FONT_SIZE_NAME];
			y += [self addText:@"INFO_BOOKS_DREAMSPELL_01" y:y];
			y += [self addText:@"INFO_BOOKS_DREAMSPELL_02" y:y];
			y += [self addMoreButton:@"INFO_LINK_BOOKS_BUY" func:@selector(goLinkBooks) y:y link:YES];
			// APPS
			y += [self addText:@"INFO_APPS" y:y size:FONT_SIZE_NAME];
			y += [self addMoreButton:@"INFO_APPS_TZOLKIN" func:@selector(goLinkAppsTzolkin) y:y link:YES];
			y += 10;
			//y += [self addMoreButton:@"INFO_APPS_MAYA" func:@selector(goLinkAppsMaya) y:y link:YES];
			//y += 10;
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_TZOLKIN_DREAMSPELL:
			nameLoc = @"INFO_TZOLKIN_DREAMSPELL";
			// setup page
			y += [self addText:@"INFO_TZOLKIN_DREAMSPELL_01" y:y];
			y += [self addText:@"INFO_TZOLKIN_DREAMSPELL_02" y:y];
			
			// Tones
			if (CACHED_IMAGES)
				y += [self addImage:@"tones" y:y];
			else
			{
				CGFloat size = 35.0;
				int lines = 7;
				for (int n = 0 ; n < 13 ; n++)
				{
					// Maya num
					str = [NSString stringWithFormat:@"numbig%02di",n+1];
					xx = (INFO_GAP+(160.0*(n/lines)));
					yy = (y+(size*(n%lines)));
					h = [self addImage:str x:xx y:yy align:ALIGN_LEFT size:size];
					// Name
					xx += size;
					str = [NSString stringWithFormat:@"%d: %@",n+1,[TzCalTzolkinMoon constToneNames:n+1]];
					[self addText:str x:xx y:yy+10.0];
				}
				y += ((lines * size) + INFO_GAP);
			}
			
			// Seals
			y += [self addText:@"INFO_TZOLKIN_DREAMSPELL_03" y:y];
			if (CACHED_IMAGES)
				y += [self addImage:@"seals" x:0.0 y:y];
			else
			{
				CGFloat size = 35.0;
				int lines = 10;
				for (int n = 0 ; n < 20 ; n++)
				{
					// Maya num
					str = [NSString stringWithFormat:@"seal%02d",n+1];
					xx = (INFO_GAP+(160.0*(n/lines)));
					yy = (y+(size*(n%lines)));
					h = [self addImage:str x:xx y:yy align:ALIGN_LEFT size:size];
					// Name
					xx += size;
					str = [NSString stringWithFormat:@"%d: %@",n+1,[TzCalTzolkinMoon constSealNames:n+1]];
					[self addText:str x:xx y:yy+10.0];
				}
				y += ((lines * size) + INFO_GAP);
			}
			
			// resto
			y += [self addText:@"INFO_TZOLKIN_DREAMSPELL_04" y:y];
			
			// BOTAO HARMONIC MODULE
			h = [self addImage:@"tzolkin_mini" y:y];
			// Create button
			button = [UIButton buttonWithType:UIButtonTypeInfoLight];
			button.frame = CGRectMake(((kscreenWidth-100.0)/2.0), y, 100.0, h);
			button.backgroundColor = [UIColor clearColor];
            button.tintColor = [UIColor whiteColor];
			[button setImage:nil forState:UIControlStateNormal];
			[button addTarget:self action:@selector(goPageHarmonicModule) forControlEvents:UIControlEventTouchUpInside];
			// add
			[workPage addSubview:button];
			//[button release];
			y += h;
			
			// resto
			y += [self addText:@"INFO_TZOLKIN_DREAMSPELL_05" y:y];
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_HARMONIC_MODULE:
			nameLoc = @"INFO_HARMONIC_MODULE";
			// setup page
			y = [self addImage:@"tzolkin_module" x:20.0 y:y];
			w = 520.0;
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_13MOON:
			nameLoc = @"INFO_13MOON";
			// setup page
			//y += [self addText:@"INFO_13MOON_01" y:y];
			y += [self addText:@"INFO_13MOON_02" y:y];
			y += [self addText:@"INFO_13MOON_03" y:y];
			y += [self addText:@"INFO_13MOON_04" y:y];
			y += [self addText:@"INFO_13MOON_05" y:y align:ALIGN_CENTER];
			y += [self addText:@"INFO_13MOON_06" y:y];
			y += [self addImage:@"plasmas" y:y];
			y += [self addText:@"INFO_13MOON_07" y:y];
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_DREAMSPELL_KIN:
			nameLoc = @"INFO_DREAMSPELL_KIN";
			// setup page
			y += [self addText:@"INFO_DREAMSPELL_KIN_01" y:y];
			y += [self addImage:@"kin_sig" y:y];
			y += [self addText:@"INFO_DREAMSPELL_KIN_02" y:y];
			y += [self addImage:@"kin_oracle" y:y];
			y += [self addText:@"INFO_DREAMSPELL_KIN_03" y:y];
			y += [self addImage:@"kin_plasma" y:y];
			y += [self addImage:@"kin_affirm" y:y];
			y += [self addText:@"INFO_DREAMSPELL_KIN_04" y:y];
			y += [self addImage:@"portal_on" y:y size:28.0];
			y += [self addText:@"INFO_DREAMSPELL_KIN_05" y:y];
			// photo
			if (CACHED_IMAGES)
				y += [self addImage:@"buts_screenshot" x:0.0 y:y];
			else
			{
				h = [self addImage:@"but_save" x:20.0 y:y];
				[self addText:@"INFO_BUT_SHOT" x:70.0 y:y+8.0];
				y += h;
			}
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_DREAMSPELL_ORACLE:
			nameLoc = @"INFO_DREAMSPELL_ORACLE";
			// setup page
			y += [self addText:@"INFO_DREAMSPELL_ORACLE_01" y:y];
			y += [self addImage:@"oracle_moon" y:y];
			y += [self addText:@"INFO_DREAMSPELL_ORACLE_02" y:y];
			y += [self addImage:@"oracle_color" y:y];
			y += [self addText:@"INFO_DREAMSPELL_ORACLE_03" y:y];
			y += [self addImage:@"oracle_tone" y:y];
			y += [self addText:@"INFO_DREAMSPELL_ORACLE_04" y:y];
			y += [self addImage:@"oracle_seal" y:y];
			y += [self addText:@"INFO_DREAMSPELL_ORACLE_05" y:y];
			y += [self addImage:@"kin_oracle" y:y];
			y += [self addText:@"INFO_DREAMSPELL_ORACLE_06" y:y];
			// fullscreen
			if (CACHED_IMAGES)
				//y += [self addImage:@"buts_fullscreen" x:0.0 y:y];
				y += [self addImage:@"buts_screenshot" x:0.0 y:y];
			else
			{
				// full 1
				//h = [self addImage:@"but_fullscreen" x:20.0 y:y];
				h = [self addImage:@"buts_screenshot" x:20.0 y:y];
				[self addText:@"INFO_BUT_FULL" x:70.0 y:y+8.0];
				y += h;
				// full 2
				h = [self addImage:@"but_save" x:20.0 y:y];
				[self addText:@"INFO_BUT_SHOT" x:70.0 y:y+8.0];
				y += h;
			}
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_GREGORIAN:
			nameLoc = @"INFO_GREGORIAN";
			// setup page
			y += [self addText:@"INFO_GREGORIAN_01" y:y];
			y += [self addText:@"INFO_GREGORIAN_02" y:y];
			y += [self addImage:@"inter-grav" y:y];
			y += [self addText:@"INFO_GREGORIAN_03a" y:y];
			y += [self addText:@"INFO_GREGORIAN_03b" y:y];
			y += [self addText:@"INFO_GREGORIAN_04" y:y];
			y += [self addText:@"INFO_GREGORIAN_05" y:y];
			y += [self addText:@"INFO_GREGORIAN_06" y:y align:ALIGN_CENTER];
			y += [self addText:@"INFO_GREGORIAN_07" y:y];
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_JULIAN:
			nameLoc = @"INFO_JULIAN";
			// setup page
			y += [self addText:@"INFO_JULIAN_01" y:y];
			y += [self addText:@"INFO_JULIAN_02" y:y];
			y += [self addText:@"INFO_JULIAN_03" y:y];
			y += [self addText:@"INFO_JULIAN_04" y:y];
			y += [self addText:@"INFO_JULIAN_05" y:y];
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_TIMER:
			nameLoc = @"INFO_TIMER";
			// setup page
			y += [self addText:@"INFO_TIMER_01" y:y];
			y += [self addText:@"INFO_TIMER_02" y:y];
			y += [self addText:@"INFO_TIMER_03" y:y];
			if (CACHED_IMAGES)
				y += [self addImage:@"buts_clock" x:0.0 y:y];
			else
			{
				// clock 1
				y += h;
				h = [self addImage:@"but_clock_pause" x:20.0 y:y];
				[self addText:@"INFO_TIMER_PAUSE" x:90.0 y:y+8.0];
				y += h;
				// clock 2
				h = [self addImage:@"but_clock_play" x:20.0 y:y];
				[self addText:@"INFO_TIMER_PLAY" x:90.0 y:y+8.0];
				y += h;
				// clock 3
				h = [self addImage:@"but_clock_playgear" x:20.0 y:y];
				[self addText:@"INFO_TIMER_PLAY_GEAR" x:90.0 y:y+8.0];
				y += h;
				// clock 4
				//h = [self addImage:@"but_clock_reset" x:28.0 y:y];
				//[self addText:@"INFO_TIMER_RESET" x:90.0 y:y];
				//y += h;
			}
			
			// clock status
			y += [self addText:@"INFO_TIMER_04" y:y];
			if (CACHED_IMAGES)
				y += [self addImage:@"buts_clock_play" x:0.0 y:y];
			else
			{
				// clock play
				h = [self addImage:@"but_clock_playing" x:20.0 y:y];
				[self addText:@"INFO_BUT_CLOCK_PLAYING" x:80.0 y:y+8.0];
				y += h;
				// clock pause
				h = [self addImage:@"but_clock_paused" x:20.0 y:y];
				[self addText:@"INFO_BUT_CLOCK_PAUSED" x:80.0 y:y+8.0];
				y += h;
			}
			
			// outros
			//y += [self addText:@"INFO_TIMER_05" y:y];
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_DATEBOOK:
			nameLoc = @"INFO_DATEBOOK";
			// setup page
			y += [self addText:@"INFO_DATEBOOK_01" y:y];
			
			// date add
			y += [self addText:@"INFO_DATEBOOK_02" y:y];
			if (CACHED_IMAGES)
				y += [self addImage:@"buts_datebook_add" x:0.0 y:y];
			else
			{
				h = [self addImage:@"but_date_add" x:20.0 y:y];
				[self addText:@"INFO_BUT_DATE_ADD" x:80.0 y:y+8.0];
				y += h;
			}
			
			// select
			y += [self addText:@"INFO_DATEBOOK_03" y:y];
			if (CACHED_IMAGES)
				y += [self addImage:@"buts_datebook_select" x:0.0 y:y];
			else
			{
				h = [self addImage:@"but_select" x:20.0 y:y];
				[self addText:@"INFO_DATE_SELECT" x:120.0 y:y+8.0];
				y += h;
			}
			
			// delete/edit
			y += [self addText:@"INFO_DATEBOOK_04" y:y];
			if (CACHED_IMAGES)
				y += [self addImage:@"buts_datebook_edit" x:0.0 y:y];
			else
			{
				// delete
				h = [self addImage:@"but_delete" x:20.0 y:y];
				[self addText:@"INFO_DATE_DELETE" x:55.0 y:y+8.0];
				y += h;
				// edit
				h = [self addImage:@"but_edit" x:20.0 y:y];
				[self addText:@"INFO_DATE_EDIT" x:65.0 y:y+8.0];
				y += h;
			}
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_ABOUT:
			nameLoc = @"INFO_ABOUT";
			// setup page
			if (MAYA_ONLY)
				y += [self addText:@"INFO_ABOUT_01_MAYA" y:y];
			else if (DREAMSPELL_ONLY)
				y += [self addText:@"INFO_ABOUT_01_DREAMSPELL" y:y];
			else
				y += [self addText:@"INFO_ABOUT_01" y:y];
			//y += [self addText:@"INFO_ABOUT_02" y:y];
			y += [self addText:@"INFO_ABOUT_03" y:y];
			y += [self addImage:@"avante" y:y];
			y += [self addMoreButton:@"INFO_LINK_AVANTE" func:@selector(goLinkAvante) y:y link:YES];
			if (ENABLE_MAYA)
			{
				y += [self addMoreButton:@"INFO_LINK_MAYA3D" func:@selector(goLinkMaya3D) y:y link:YES];
				y += [self addMoreButton:@"INFO_LINK_KIN3D" func:@selector(goLinkKin3D) y:y link:YES];
				y += [self addMoreButton:@"INFO_LINK_DOWNLOAD_KIN3D" func:@selector(goLinkDownloadKin3D) y:y link:YES];
			}
			else
			{
				y += [self addMoreButton:@"INFO_LINK_KIN3D" func:@selector(goLinkKin3D) y:y link:YES];
				y += [self addMoreButton:@"INFO_LINK_MAYA3D" func:@selector(goLinkMaya3D) y:y link:YES];
				y += [self addMoreButton:@"INFO_LINK_BUY_MAYA3D" func:@selector(goLinkBuyMaya3D) y:y link:YES];
			}
			y += [self addMoreButton:@"INFO_LINK_SUPPORT" func:@selector(goLinkSupport) y:y link:YES];
			y += [self addMoreButton:@"INFO_LINK_CONTACT" func:@selector(goLinkContact) y:y link:YES];
			
			// ABOUT: Credits
			y += 10.0;
			y += [self addText:@"INFO_CREDITS" y:y size:FONT_SIZE_NAME];
			y += [self addText:@"INFO_CREDITS_01" y:y];
			y += [self addText:@"INFO_CREDITS_02" y:y];
			y += [self addText:@"INFO_CREDITS_03" y:y];
			if (ENABLE_DREAMSPELL)
				y += [self addText:@"INFO_CREDITS_04" y:y];
			y += [self addText:@"INFO_CREDITS_05" y:y];
			y += [self addText:@"INFO_CREDITS_06" y:y];
			y += [self addText:@"INFO_CREDITS_07" y:y];
			y += [self addText:@"INFO_CREDITS_08" y:y];
			
			// ABOUT: Books
			if (ENABLE_MAYA)
			{
				y += [self addText:@"INFO_BOOKS_MAYA" y:y size:FONT_SIZE_NAME];
				y += [self addText:@"INFO_BOOKS_MAYA_01" y:y];
				y += [self addText:@"INFO_BOOKS_MAYA_02" y:y];
				y += [self addText:@"INFO_BOOKS_MAYA_03" y:y];
				y += [self addText:@"INFO_BOOKS_MAYA_04" y:y];
				y += [self addText:@"INFO_BOOKS_MAYA_05" y:y];
				y += [self addText:@"INFO_BOOKS_MAYA_06" y:y];
				y += [self addText:@"INFO_BOOKS_MAYA_07" y:y];
				y += [self addMoreButton:@"INFO_LINK_BOOKS" func:@selector(goLinkBooks) y:y link:YES];
			}
			if (ENABLE_DREAMSPELL)
			{
				y += [self addText:@"INFO_BOOKS_DREAMSPELL" y:y size:FONT_SIZE_NAME];
				y += [self addText:@"INFO_BOOKS_DREAMSPELL_01" y:y];
				y += [self addText:@"INFO_BOOKS_DREAMSPELL_02" y:y];
				y += [self addMoreButton:@"INFO_LINK_BOOKS" func:@selector(goLinkBooks) y:y link:YES];
			}

			// LINKS
			y += [self addText:@"INFO_LINKS" y:y size:FONT_SIZE_NAME];
			y += [self addMoreButton:@"INFO_LINK_WEB" func:@selector(goLinkWeb) y:y link:YES];

			// APPS
			y += [self addText:@"INFO_APPS" y:y size:FONT_SIZE_NAME];
			if (ENABLE_MAYA)
			{
				y += [self addMoreButton:@"INFO_APPS_MAYA" func:@selector(goLinkAppsMaya) y:y link:YES];
				y += 10;
				y += [self addMoreButton:@"INFO_APPS_TZOLKIN" func:@selector(goLinkAppsTzolkin) y:y link:YES];
				y += 10;
			}
			else
			{
				y += [self addMoreButton:@"INFO_APPS_TZOLKIN" func:@selector(goLinkAppsTzolkin) y:y link:YES];
				y += 10;
				y += [self addMoreButton:@"INFO_APPS_MAYA" func:@selector(goLinkAppsMaya) y:y link:YES];
				y += 10;
			}
			
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_ABOUT_LITE:
			nameLoc = @"INFO_ABOUT";
			// setup page
			y += [self addImage:@"avante" y:y];
			
			// LINKS
			y += [self addMoreButton:@"INFO_LINK_BUY_MAYA3D" func:@selector(goLinkBuyMaya3D) y:y link:YES];
			//y += [self addMoreButton:@"INFO_LINK_DOWNLOAD_MAYA3DLITE" func:@selector(goLinkDownloadLite) y:y link:YES];
			y += [self addMoreButton:@"INFO_LINK_BUY_FULL" func:@selector(goLinkBuyMaya3D) y:y link:YES];
			if (ENABLE_MAYA)
				y += [self addMoreButton:@"INFO_LINK_MAYA3D" func:@selector(goLinkMaya3D) y:y link:YES];
			else
				y += [self addMoreButton:@"INFO_LINK_KIN3D" func:@selector(goLinkKin3D) y:y link:YES];
			y += [self addMoreButton:@"INFO_LINK_AVANTE" func:@selector(goLinkAvante) y:y link:YES];
			y += [self addMoreButton:@"INFO_LINK_SUPPORT" func:@selector(goLinkSupport) y:y link:YES];
			y += [self addMoreButton:@"INFO_LINK_CONTACT" func:@selector(goLinkContact) y:y link:YES];
			
			// CREDITS
			y += 10.0;
			//y += [self addText:@"INFO_CREDITS" y:y size:FONT_SIZE_NAME];
			y += [self addText:@"INFO_ABOUT_03" y:y];
			y += [self addText:@"INFO_CREDITS_01" y:y];
			if (ENABLE_MAYA)
			{
				y += [self addText:@"INFO_CREDITS_02" y:y];
				y += [self addText:@"INFO_CREDITS_03" y:y];
				y += [self addText:@"INFO_CREDITS_06" y:y];
			}
			if (ENABLE_DREAMSPELL)
			{
				y += [self addText:@"INFO_CREDITS_04" y:y];
			}
			break;
			
			//
			///////////////////////////////////////////////////////////
			//
		case INFO_BUY_FULL:
#ifdef KIN3D
			nameLoc = @"INFO_BUY_FULL_KIN3D";
			// setup
			y += [self addText:@"INFO_BUY_FULL_KIN3D_01" y:y];
			y += [self addImage:@"maya3d" y:y];
			//y += [self addText:@"INFO_BUY_FULL_KIN3D_02" y:y];
			y += [self addMoreButton:@"INFO_LINK_BUY_MAYA3D" func:@selector(goLinkBuyMaya3D) y:y link:YES];
			//y += [self addMoreButton:@"INFO_LINK_DOWNLOAD_MAYA3DLITE" func:@selector(goLinkDownloadLite) y:y link:YES];
#else
			nameLoc = @"INFO_BUY_FULL";
			y += [self addText:@"INFO_BUY_FULL_01" y:y];
			y += [self addMoreButton:@"INFO_LINK_BUY_FULL" func:@selector(goLinkBuyMaya3D) y:y link:YES];
#endif
			// Topics
			y += [self addText:@"INFO_BUY_FULL_02" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_01" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_02" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_03" y:y];
			y += [self addImage:@"gregorian" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_04" y:y];
			y += [self addImage:@"tzolkin_teaser" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_05" y:y];
			y += [self addImage:@"maya_glyph_teaser" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_06" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_07" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_08" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_09" y:y];
			y += [self addImage:@"oracle_teaser" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_10" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_11" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_12" y:y];
			y += [self addText:@"INFO_BUY_FULL_TOPIC_13" y:y];
			// Finish
			y += [self addText:@"INFO_BUY_FULL_03" y:y];
			y += [self addText:@"INFO_BUY_FULL_04" y:y];
			// buy!
#ifdef KIN3D
			y += [self addMoreButton:@"INFO_LINK_BUY_MAYA3D" func:@selector(goLinkBuyMaya3D) y:y link:YES];
			//y += [self addMoreButton:@"INFO_LINK_DOWNLOAD_MAYA3DLITE" func:@selector(goLinkDownloadLite) y:y link:YES];
#else
			y += [self addMoreButton:@"INFO_LINK_BUY_FULL" func:@selector(goLinkBuyMaya3D) y:y link:YES];
#endif
			break;
			
		default:
			nameLoc = @"NOT_FOUND";
			// setup page
			y += [self addText:@"NOT_FOUND" y:y];
			break;
	}
	
	// da um espacinho
	y += 10;
	
	// Get actual page name
	pageNames[actualPage] = LOCAL(nameLoc);
	
	// Return page size
	return CGSizeMake(w, y);
}

#pragma mark ACTIONS

// PAGE ACTINS
- (IBAction)goPagePrev:(id)sender {
	if (pageNum > 0)
		[self gotoPageLocal:(pageNum-1)];
}
- (IBAction)goPageNext:(id)sender {
	if (pageNum < (pageCount-1))
		[self gotoPageLocal:(pageNum+1)];
}
- (void)goPageTzolkin
{
	[self gotoPage:INFO_TZOLKIN];
}
- (void)goPageHaab
{
	[self gotoPage:INFO_HAAB];
}
- (void)goPageLongCount
{
	[self gotoPage:INFO_LONG_COUNT];
}
- (void)goPage2012
{
	[self gotoPage:INFO_2012];
}
- (void)goPageHarmonicModule
{
	[self gotoPage:INFO_HARMONIC_MODULE];
}
- (void)goPageJulianDay
{
	[self gotoPage:INFO_JULIAN];
}
- (void)goPageClock
{
	[self gotoPage:INFO_TIMER];
}
- (void)goPageDatebook
{
	[self gotoPage:INFO_DATEBOOK];
}


#pragma mark ACTION LINKS

// LINK ACTIONS
- (void)goLinkAvante
{
	link = LINK_STUDIO_AVANTE;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkMaya3D
{
	link = LINK_MAYA3D;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkKin3D
{
	link = LINK_KIN3D;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkSupport
{
	link = LINK_SUPPORT;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkContact
{
	link = LINK_CONTACT;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkBuyMaya3D
{
	link = LINK_BUY_FULL;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkDownloadLite
{
	link = LINK_DOWNLOAD_LITE;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkDownloadKin3D
{
	link = LINK_DOWNLOAD_KIN3D;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkWeb
{
	link = LINK_LINKS;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkBooks
{
	link = LINK_BOOKS;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
// Dreamspell Links
- (void)goLinkSincronarioDaPaz
{
	link = LINK_SINCRONARIO_DA_PAZ;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkCalendarioDaPaz
{
	link = LINK_CALENDARIO_DA_PAZ;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkLawOfTime
{
	link = LINK_LAW_OF_TIME;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkTortuga
{
	link = LINK_TORTUGA;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkAppsTzolkin
{
	link = LINK_APPS_TZOLKIN;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}
- (void)goLinkAppsMaya
{
	link = LINK_APPS_MAYA;
	[global alertOKBack:LOCAL(@"WEB_LINK") delegate:self];
}


// LINK RESPONSE
// UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)i
{
	if (i)
		[global goLink:link];
}




@end
