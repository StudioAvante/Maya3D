//
//  TzGlobal.m
//  Maya3D
//
//  Created by Roger on 04/02/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "TzGlobal.h"
#import "Tzolkin.h"
#import "TzDate.h"
#import "TzDatebook.h"
#import "TzClock.h"
#import "GLTextureLib.h"
#import "TzSoundManager.h"
#import "AvanteTextLabel.h"
#import "InfoVC.h"

@implementation TzGlobal

// Constant for the number of times per second (Hertz) to sample acceleration.
#define kAccelerometerFrequency     15


@synthesize prefLang;
@synthesize prefLangSuffix;
@synthesize prefLangSetting;
@synthesize prefMayaDreamspell;
@synthesize prefHemisphere;
@synthesize prefLastDate;
@synthesize prefStartDate;
@synthesize prefDateFormat;
@synthesize prefNumbering;
@synthesize prefClockStyle;
@synthesize prefGearName;
@synthesize prefGearSound;
@synthesize prefInfoSeen;
@synthesize accelX;
@synthesize accelY;
@synthesize accelZ;
@synthesize accelRoll;
@synthesize accelRollTable;
@synthesize accelPitch;
@synthesize dateInit;
@synthesize cal;
@synthesize datebook;
@synthesize theClock;
@synthesize theNavController;
@synthesize theTabBar;
@synthesize currentVC;
@synthesize currentTab;
@synthesize lastTab;
@synthesize texLib;
@synthesize texBound;
@synthesize blendingEnabled;
@synthesize soundLib;


- (void)dealloc {
	[locMan release];
	[dateInit release];
	[cal release];
	[theClock release];
	[datebook release];
	[texLib release];
	[soundLib release];
    [super dealloc];
}

- (id)init
{
	if (0)
	{
		AvLog(@"SIZEOF: int     = [%d]", sizeof(int));
		AvLog(@"SIZEOF: int       = [%d]", sizeof(int));
		AvLog(@"SIZEOF: long      = [%d]", sizeof(long));
		AvLog(@"SIZEOF: NSInteger = [%d]", sizeof(NSInteger));
		AvLog(@"SIZEOF: float     = [%d]", sizeof(float));
		AvLog(@"SIZEOF: double    = [%d]", sizeof(double));
		AvLog(@"SIZEOF: CGFloat   = [%d]", sizeof(CGFloat));
	}
	
	// Create location manager - OFF
	locMan = [[CLLocationManager alloc] init];
	locMan.delegate = self;
	locMan.desiredAccuracy = kCLLocationAccuracyKilometer;
	locMan.distanceFilter = 500;
	// Leave OFF!!!
	[locMan stopUpdatingLocation];

	// Preferencias
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// First Time?
	int prefDejaVu = (int)[defaults integerForKey:@"prefDejaVu"];
	if (prefDejaVu == 0)
	{
		AvLog(@"PREFERENCES: FIRST TIME!");
		[defaults setInteger:LANG_DEVICE		forKey:@"prefLangSetting"];
		[defaults setInteger:VIEW_MODE_MAYA		forKey:@"prefMayaDreamspell"];
		[defaults setInteger:HEMISPHERE_UNKNOWN	forKey:@"prefHemisphere"];
		[defaults setInteger:0					forKey:@"prefLastDate"];
		[defaults setInteger:START_TODAY		forKey:@"prefStartDate"];
		[defaults setInteger:GREG_DMY			forKey:@"prefDateFormat"];
		[defaults setInteger:NUMBERING_MAYA		forKey:@"prefNumbering"];
		[defaults setInteger:CLOCK_STYLE_123	forKey:@"prefClockStyle"];
		[defaults setInteger:GEAR_NAME_ON		forKey:@"prefGearName"];
		[defaults setInteger:GEAR_SOUND_TICK	forKey:@"prefGearSound"];
		[defaults setInteger:0					forKey:@"prefInfoSeen"];
		[defaults setInteger:1					forKey:@"prefDejaVu"];
		// save
		[defaults synchronize];
	}
	
#ifdef LITE
	// LITE preferences
	[defaults setInteger:START_TODAY		forKey:@"prefStartDate"];
	[defaults setInteger:GREG_DMY			forKey:@"prefDateFormat"];
	[defaults setInteger:GEAR_SOUND_TICK	forKey:@"prefGearSound"];
	[defaults setInteger:GEAR_NAME_ON		forKey:@"prefGearName"];
#endif // LITE
	
	// Read preferences
	prefLangSetting		= (int)[defaults integerForKey:@"prefLangSetting"];
	prefHemisphere		= (int)[defaults integerForKey:@"prefHemisphere"];
	prefMayaDreamspell	= (int)[defaults integerForKey:@"prefMayaDreamspell"];
	prefHemisphere		= (int)[defaults integerForKey:@"prefHemisphere"];
	prefLastDate		= (int)[defaults integerForKey:@"prefLastDate"];
	prefStartDate		= (int)[defaults integerForKey:@"prefStartDate"];
	prefDateFormat		= (int)[defaults integerForKey:@"prefDateFormat"];
	prefNumbering		= (int)[defaults integerForKey:@"prefNumbering"];
	//prefClockStyle	= [defaults integerForKey:@"prefClockStyle"];
	prefClockStyle		= CLOCK_STYLE_123;
	prefGearName		= (int)[defaults integerForKey:@"prefGearName"];
	prefGearSound		= (int)[defaults integerForKey:@"prefGearSound"];
	prefInfoSeen		= (int)[defaults integerForKey:@"prefInfoSeen"];
	
	// Force View mode?
	if (MAYA_ONLY)
		prefMayaDreamspell = VIEW_MODE_MAYA;
	else if (DREAMSPELL_ONLY)
		prefMayaDreamspell = VIEW_MODE_DREAMSPELL;
	
	// debug
	AvLog(@"PREFERENCES: prefLangSetting     = [%d]", prefLangSetting);
	AvLog(@"PREFERENCES: prefMayaDreamspell  = [%d]", prefMayaDreamspell);
	AvLog(@"PREFERENCES: prefHemisphere       = [%d]", prefHemisphere);
	AvLog(@"PREFERENCES: prefLastDate        = [%d]", prefLastDate);
	AvLog(@"PREFERENCES: prefStartDate       = [%d]", prefStartDate);
	AvLog(@"PREFERENCES: prefDateFormat      = [%d]", prefDateFormat);
	AvLog(@"PREFERENCES: prefNumbering       = [%d]", prefNumbering);
	AvLog(@"PREFERENCES: prefClockStyle      = [%d]", prefClockStyle);
	AvLog(@"PREFERENCES: prefGearName        = [%d]", prefGearName);
	AvLog(@"PREFERENCES: prefGearSound       = [%d]", prefGearSound);
	AvLog(@"PREFERENCES: prefInfoSeen        = [%d]", prefInfoSeen);
	
	// Define language
	[self setLang];
	
	// Define Data inicial - TODAY
	TzDate *today = [[TzDate alloc] init];
	if (prefStartDate == START_LAST && today.julian != prefLastDate)
		dateInit = [[TzDate alloc] initJulian:prefLastDate];
	else
		dateInit = [[TzDate alloc] init];
	[today release];
	
	// Init main Calendar
	// init sem argumentos vai procurar pelo dateInit
	cal = [[TzCalendar alloc] init:dateInit.julian secs:dateInit.secs];

	/*
	 // Find Calendar Round beginning
	// 2010-03-18 00:56:32.094 Maya3D[38328:20b] CR jdn[596344] Tzolkin[1/1 Imix] Haab[365/4 Wayeb]	  delta=12061
	// 2010-03-18 00:56:05.384 Maya3D[38308:20b] CR jdn[596345] Tzolkin[2/2 Ik'] Haab[1/0 Pop]        delta=12062
	for (int n = 0 ; n < (52*365) ; n++)
	{
		int d = (CORRELATION + n);
		[cal updateWithJulian:d];
		if (cal.haab.kin == 1)
			AvLog(@"CR jdn[%d] Tzolkin[%d/%@] Haab[%d/%@] days from corr[%d]",d,cal.tzolkin.kin,cal.tzolkin.dayNameFull,cal.haab.kin,cal.haab.dayNameFull,n);
	}
	// Dreamspell
	[cal updateWithJulian:DREAMSPELL_JULIAN];
	AvLog(@"CR DR jdn[%d] Tzolkin[%d/%@] Moon[%d/%@] days from corr[%d]",DREAMSPELL_JULIAN,cal.tzolkinMoon.kin,cal.tzolkinMoon.dayName,cal.moon.kin,cal.moon.dayName,(DREAMSPELL_JULIAN-CORRELATION));
	 */
	
	// Init Timer
	// PS: depois de cal
	theClock = [[TzClock alloc] init];
	
	// Init Datebook
	datebook = [[TzDatebook alloc] init];
	
	// Alloc Texture lib
	texLib = [[GLTextureLib alloc] initWithCapacity:30];
	
	// Alloc Sound Manager
	soundLib = [[TzSoundManager alloc] init];
		
	// Configure and start the accelerometer
	self.motionManager = [[CMMotionManager alloc] init];
	self.motionManager.accelerometerUpdateInterval = OPENGL_INTERVAL;
	self.motionManager.gyroUpdateInterval = OPENGL_INTERVAL;
	[self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
											 withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error)
	 {
		 if(error) {
			 NSLog(@"%@", error);
		 }
		 else {
			 [self accelerometer:accelerometerData.acceleration];
		 }
	 }];
	/*[self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
									withHandler:^(CMGyroData *gyroData, NSError *error)
	 {
		 [self outputRotationData:gyroData.rotationRate];
	 }];*/

	// Finito!
	return self;
}


// Finaliza, salvando
- (void)updatePreferences
{
	// Get defaults pointer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// Save current estate preferences
	[defaults setInteger:global.prefMayaDreamspell forKey:@"prefMayaDreamspell"];
	[defaults setInteger:global.cal.julian forKey:@"prefLastDate"];
	[defaults setInteger:1 forKey:@"prefInfoSeen"];
	// Save ALL
	[defaults synchronize];
}


// Define globais que controlam a linguagem
- (void)setLang
{
	if (prefLangSetting == LANG_DEVICE)
	{
		// Recupera linguagens em ordem de preferencia (sistema)
		// Tipo, se settings = "en", "en" sera o primeiro
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
		
		// Debug
		//for (int n = 0 ; n < [languages count] ; n++)
		//	AvLog(@"default languages [%d] [%@]",n,[languages objectAtIndex:n]);
		AvLog(@"Current language  [%@]", [languages objectAtIndex:0]);
		AvLog(@"currentLocale     [%@]", [[NSLocale currentLocale] localeIdentifier]);
		AvLog(@"LOCALIZABLE       [%@] YES=[%@]", LOCAL(@"LOCALIZABLE"), LOCAL(@"YES"));

		// Check current
		NSString *lang = [languages objectAtIndex:0];
		if ([lang hasPrefix:@"pt"])			// "pt" ou "pt-PT"
			prefLang = LANG_PT;
		else if ([lang hasPrefix:@"es"])	// "es" ou "es-xx"
			prefLang = LANG_ES;
		else
			prefLang = LANG_EN;
		AvLog(@"GLOBAL LANG lang[%@] prefLangSetting[%d] prefLang[%d]",lang,prefLangSetting,prefLang);
		
	}
	else
		prefLang = prefLangSetting;
	
	// Suffix
	if (prefLang == LANG_PT)
		prefLangSuffix = [[NSString alloc] initWithString:@"pt"];
	else if (prefLang == LANG_ES)
		prefLangSuffix = [[NSString alloc] initWithString:@"es"];
	else
		prefLangSuffix = [[NSString alloc] initWithString:@"en"];
}


// Log
- (void)logTime:(id)obj :(NSString*)msg
{
	CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
	CFAbsoluteTime diff = (now - lastLog);
	AvLog(@"LOG TIME now[%.4f] diff[%.4f] : %@ : %@",now,diff,NSStringFromClass([obj class]),msg);
	lastLog = now;
}



#pragma mark ACCELEROMETER

#define kFilteringFactor 0.075

//
// ACCELEROMETER
//
// UIAccelerometerDelegate method, called when the device accelerates.
- (void)accelerometer:(CMAcceleration)acceleration {
	// Locked?
	if (accelLocked)
		return;
	
	// Motion
	accelX = (acceleration.x * kFilteringFactor) + (accelX * (1.0 - kFilteringFactor));
	accelY = (acceleration.y * kFilteringFactor) + (accelY * (1.0 - kFilteringFactor));
	accelZ = (acceleration.z * kFilteringFactor) + (accelZ * (1.0 - kFilteringFactor));
	// Gravity
	//accelX = accelX - ( (acceleration.x * kFilteringFactor) + (accelX * (1.0 - kFilteringFactor)) );
	//accelY = accelY - ( (acceleration.y * kFilteringFactor) + (accelY * (1.0 - kFilteringFactor)) );
	//accelZ = accelZ - ( (acceleration.z * kFilteringFactor) + (accelZ * (1.0 - kFilteringFactor)) );
	
	// Calc Roll (esq/dir)
	accelRoll = atan2(accelX,accelY) - PI;
	if (accelRoll < 0.0)
		accelRoll += (PI*2.0);
	
	// Calc Roll (esq/dir) - TABLE STABILITY
	accelRollTable = accelRoll;
	// on table...
	double angFix = -0.93;
	double angTurn = -0.88;
	if (accelZ <= angFix)
		accelRollTable = 0.0;
	// turning...
	else if (accelZ <= angTurn)
	{
		double prog = 1.0 - ((angTurn - accelZ) / (angTurn - angFix));
		//AvLog(@"ACCELEROMETER turn z[%.3f] prog[%.3f] zzz[%.3f]",accelZ,prog,accelZ*prog);
		// tombado para o lado direito, evita girar de 0.0 até 360.0
		if (accelX > 0.0)
			accelRollTable = PI2 - ((PI2-accelRoll)*prog);
		else
			accelRollTable *= prog;
	}
	
	// Calc Pitch (frente/tras)
	// 00  = Deitado, tela p/ cima
	// 90  = Em pé
	// 180 = Deitado, tel ap/ baixo
	// 270 = Donta cabeca
	accelPitch = atan2(accelY,accelZ) + PI;
	
	// Debug
	if (0)
	{
		AvLog(@"ACCELEROMETER x[%.3f] y[%.3f] z[%.3f] roll[%.3f] pitch[%.3f]",
			  accelX,accelY,accelZ,
			  accelRollTable*RADIAN_ANGLES,
			  accelPitch*RADIAN_ANGLES);
	}
}
// Stop / Start grabbing accelerometer data
- (void)stopAccelerometer
{
	accelLocked = YES;
}
- (void)startAccelerometer
{
	accelLocked = NO;
}


#pragma mark SCREENSHOT

//
// CAMERA SCREENSHOT
//

// Save main view to Saved Screenshots
//
// Metodo 1: (*)
// UIImageWriteToSavedPhotosAlbum: Salva com nome automatico
//
// Metodo 2:
// NSData *dataObj = UIImageJPEGRepresentation(self, 90);
// [dataObj writeToFile:path atomically:NO];
//
- (void)shareView:(UIView*)view vc:(UIViewController*)vc withText:(NSString*)text withBody:(NSString*)body
{
	UIImageView *rasterView;
	UIImageView *trailerView;
	UIView *shotView;
	UIImage *image;
	CGRect frame;
	CGFloat w, h;
	CGFloat y = 0.0;
	
	// Camera locked?
	if (cameraLocked)
		return;
	// Lock camera
	cameraLocked = YES;

	// Define tamanho da view
	w = (320.0 + SHOT_SIDE + SHOT_SIDE);
	h = (view.frame.size.height + SHOT_HEADER + SHOT_TRAILER);
	
	// Cria uma view temporaria com header e trailer
	frame = CGRectMake(0.0, 0.0, w, h);
	shotView = [[UIView alloc] initWithFrame:frame];
	shotView.backgroundColor = [UIColor blackColor];
	
	// Rasteriza a view original
	// Se adicionar como view, ela se perde depois !?!?!?!
	UIGraphicsBeginImageContext(view.frame.size);
	[view.layer renderInContext:(CGContextRef)UIGraphicsGetCurrentContext()];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// Adiciona imagem rasterizada da view
	frame = CGRectMake(SHOT_SIDE, y, 320.0, view.frame.size.height);
	rasterView = [[UIImageView alloc] initWithFrame:frame];
	rasterView.image = image;
	[shotView addSubview:rasterView];
	// jump this
	y+= view.frame.size.height;
	
	// Add Trailer
	NSString *trailer_file = ( (ENABLE_MAYA) ? @"shot_trailer.png" : @"shot_trailer_dreamspell.png");
	frame = CGRectMake(SHOT_SIDE, y, 320.0, SHOT_TRAILER);
	trailerView = [[UIImageView alloc] initWithFrame:frame];
	trailerView.image = [UIImage imageNamed:trailer_file];
	[shotView addSubview:trailerView];
	[trailerView release];
	
	// Create Image
	UIGraphicsBeginImageContext(shotView.frame.size);
	[shotView.layer renderInContext:(CGContextRef)UIGraphicsGetCurrentContext()];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	// Save!
	cameraLocked = NO;
	
	// Share!
	NSArray *activityItems = @[text, image];
	UIActivityViewController *activityController =
	[[UIActivityViewController alloc] initWithActivityItems:activityItems
									  applicationActivities:nil];
	[vc presentViewController:activityController
					 animated:YES
				   completion:nil];

	// release all
	[rasterView release];
	[shotView release];
}
- (void)saveImageToLibrary:(UIImage*)image
{
	// Camera locked?
	if (cameraLocked)
		return;
	// Lock camera
	cameraLocked = YES;

	// Cria cover
	[self coverAll:LOCAL(@"SHOT_SAVING")];
	
	// Save Screenshot to iPhone library
	UIImageWriteToSavedPhotosAlbum(image, self, @selector(screenshotSaved:didFinishSavingWithError:contextInfo:), nil);
	
	// Click!
	//[self.soundLib playWave:WAVE_SAVED];
}
- (void)screenshotSaved:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	// Display message
	if (error.code)
		[self alertSimple:LOCAL(@"SHOT_SAVED_ERROR")];
	else
		[self  alertSimple:LOCAL(@"SHOT_SAVED_OK")];
	// Remove cover
	[self uncoverAll];
	// Unlock camera
	cameraLocked = NO;
}
// Cria cover
- (void)coverAll:(NSString*)msg
{
	// ja tem cover?
	if (coverView != nil)
		[self uncoverAll];
	
	// Cria cover
	coverView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kActiveLessNav)];
	coverView.backgroundColor = [UIColor blackColor];
	coverView.opaque = FALSE;
	coverView.alpha = 0.85;
	// Cover message
	AvanteTextLabel *coverLabel = [[AvanteTextLabel alloc] init:msg x:0.0 y:120.0 w:320.0 h:30.0 size:16.0 color:[UIColor whiteColor]];
	[coverView addSubview:coverLabel];
	[coverLabel release];
	// Add cover
	[currentVC.view addSubview:coverView];
	[coverView release];
}
- (void)uncoverAll
{
	// nao tem cover?
	if (coverView == nil)
		return;
	
	// remove cover
	[coverView removeFromSuperview];
	coverView = nil;
}


#pragma mark CACHED VIEW CONTROLLERS

- (void)goInfo:(int)pg vc:(UIViewController*)topVC
{
	[self goInfo:pg vc:topVC y:0.0];
}

- (void)goInfo:(int)pg vc:(UIViewController*)topVC y:(CGFloat)yoff
{
	// TEMP VC
	if (1)
	{
		info = [[InfoVC alloc] initWithPage:pg];
		info.hidesBottomBarWhenPushed  = YES;
		[[topVC navigationController] pushViewController:info animated:YES];
		[info release];
	}
	// KEEP VC
	else
	{
		// Create VC
		if (info == nil)
		{
			info = [[InfoVC alloc] initWithPage:pg];
			info.hidesBottomBarWhenPushed  = YES;
		}
		else
		{
			[info gotoPage:pg];
		}
		// Push Info VC
		[[topVC navigationController] pushViewController:info animated:YES];
	}
	// Go to...
	if (yoff > 0.0)
		[info scrollToY:yoff animated:FALSE];
}



#pragma mark UI

//
// UI
//

- (UISegmentedControl*)addViewModeSwitch:(UIViewController*)vc
{
	// Cria apenas se MAYA e DREAMSPELL estiverem habilitados
	if (ENABLE_MAYA == FALSE || ENABLE_DREAMSPELL == FALSE)
		return nil;

	// Create control
	NSArray *items = [NSArray arrayWithObjects: LOCAL(@"MAYA"), LOCAL(@"DREAMSPELL"), nil];
	UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:items];
	control.segmentedControlStyle = UISegmentedControlStyleBar;
	control.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
	[control addTarget:self action:@selector(switchViewMode:) forControlEvents:UIControlEventValueChanged];
	// add to VC
	vc.navigationItem.titleView = control;
	[control release];
	// return the control
	return control;
}

// Muda modo de tela - MAYA / DREAMSPELL
- (void)switchViewMode:(id)sender
{
	// Set preferences
	int viewMode = (int)((UISegmentedControl*)sender).selectedSegmentIndex;
	prefMayaDreamspell = viewMode;
	AvLog(@"SWITCH VIEW MODE [%d]", self.prefMayaDreamspell);
	
	// Remove LEAP DAY se estiver no modo DREAMSPELL
	[cal removeLeap];
	
	// Atualiza Tabs - GLYPH
	[self updateGlyphTab];
}

// Atualiza botao do glifo no tabbar
- (void)updateGlyphTab
{
	// Atualiza Tabs - GLYPH
	UIViewController *vc = (UIViewController*) [self.theTabBar.viewControllers objectAtIndex:TAB_GLYPH];
	if (prefMayaDreamspell == VIEW_MODE_MAYA)
	{
		// nav controller- aparentemente isso nao funciona, reseto no GlyphVC
		vc.title = LOCAL(@"TAB_GLYPH");
		// tab bar item
		vc.tabBarItem.image = [UIImage imageNamed:@"icon_glyph.png"];
		vc.tabBarItem.title = LOCAL(@"TAB_GLYPH");
	}
	else
	{
		// nav controller- aparentemente isso nao funciona, reseto no GlyphVC
		vc.title = LOCAL(@"TAB_SIGNATURE");
		// tab bar item
		vc.tabBarItem.image = [UIImage imageNamed:@"icon_signature.png"];
		vc.tabBarItem.title = LOCAL(@"TAB_SIGNATURE");
	}
}

// Update navigation controller date
- (void)updateNavDate:(UIViewController*)vc
{
	[self updateNavDate:vc secs:NO];
}
- (void)updateNavDate:(UIViewController*)vc secs:(BOOL)secs
{
	vc.navigationItem.title = ( (secs) ? global.cal.greg.dayNameHour : global.cal.greg.dayNameShort );
}

// WEB LINK
- (void)goLink:(int)link
{
	NSString *url;
	switch (link)
	{
		case LINK_STUDIO_AVANTE:		url = @"http://www.studioavante.com/"; break;
		case LINK_MAYA3D:				url = @"http://www.maya3d.mobi/"; break;
		case LINK_KIN3D:				url = @"http://www.kin3d.mobi/"; break;
		case LINK_SUPPORT:				url = @"http://www.studioavante.com/support"; break;
		case LINK_CONTACT:				url = @"mailto:contact@studioavante.com?subject=Tzolkin"; break;
		case LINK_BOOKS:				url = @"http://www.maya3d.mobi/books"; break;
		case LINK_LINKS:				url = @"http://www.maya3d.mobi/links"; break;
		//case LINK_BUY_FULL:			url = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=318688264&mt=8"; break;
		case LINK_BUY_FULL:				url = @"http://itunes.com/apps/Maya3D"; break;
		//case LINK_DOWNLOAD_LITE:		url = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=323929287&mt=8"; break;
		case LINK_DOWNLOAD_LITE:		url = @"http://itunes.com/apps/Maya3DLite"; break;
		case LINK_DOWNLOAD_KIN3D:		url = @"http://itunes.com/apps/Kin3D"; break;
		case LINK_SINCRONARIO_DA_PAZ:	url = @"http://www.sincronariodapaz.org/"; break;
		case LINK_CALENDARIO_DA_PAZ:	url = @"http://www.calendariodapaz.com.br/"; break;
		case LINK_LAW_OF_TIME:			url = @"http://www.lawoftime.org/"; break;
		case LINK_TORTUGA:				url = @"http://www.tortuga.com/"; break;
		case LINK_APPS_TZOLKIN:			url = @"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=software&restrict=false&submit=seeAllLockups&term=tzolkin"; break;
		case LINK_APPS_MAYA:			url = @"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=software&restrict=false&submit=seeAllLockups&term=maya%20calendar"; break;
		default: return;
	}
	AvLog(@"OPEN LINK [%d] [%@]",link,url);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

//
// Devolve um UIImage sem cache
// Nao precisa dar release!
//
- (UIImage*)imageFromFile:(NSString*)file
{
	return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:@"png"]];
}

#pragma mark UI

//
// UI
//

// UI - ALERTA SIMPLES
- (void)alertSimple:(NSString*)msg
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@""
						  message:msg
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

// UI - YES / NO
- (void)alertYesNo:(NSString*)msg delegate:(id)delegate
{
	// Display alert
	alertResp = -1;
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@""
						  message:msg
						  delegate:delegate
						  cancelButtonTitle:LOCAL(@"NO")
						  otherButtonTitles:LOCAL(@"YES"), nil];
	[alert show];
	[alert release];
}

// UI - OK / BACK
- (void)alertOKBack:(NSString*)msg delegate:(id)delegate
{
	// Display alert
	alertResp = -1;
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@""
						  message:msg
						  delegate:delegate
						  cancelButtonTitle:LOCAL(@"BACK")
						  otherButtonTitles:@"OK",  nil];
	[alert show];
	[alert release];
}

// UI - LITE ALERT
- (void)alertLite:(NSString*)msg
{
	// Display alert
	alertResp = -1;
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@""
						  message:msg
						  delegate:self
						  cancelButtonTitle:LOCAL(@"BACK")
						  otherButtonTitles:LOCAL(@"BUY_FULL"), nil];
	
	[alert show];
	[alert release];
}

// UI - LOCATION DETECTION
- (void)alertLocation:(id)delegate
{
	// Display alert
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@""
						  message:LOCAL(@"DETECT_LOCATION")
						  delegate:delegate
						  cancelButtonTitle:LOCAL(@"DETECT_AUTO")
						  otherButtonTitles:LOCAL(@"DETECT_SOUTH"),LOCAL(@"DETECT_NORTH"), nil];
	[alert show];
	[alert release];
}
- (void)locationSet:(int)hemisphere
{
	// Detect
	if (hemisphere == 0)
	{
		AvLog(@"MODEL [%@]",[UIDevice currentDevice].model);
		// MODEL [iPod touch]
		if (0)
		{
			[self alertSimple:LOCAL(@"DETECT_IPOD_TOUCH")];
		}
		// iPhone
		else
		{
			[self coverAll:LOCAL(@"DETECT_DETECTING")];
			[locMan startUpdatingLocation];
		}
		return;
	}
	
	// Set Preference
	global.prefHemisphere = hemisphere;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:global.prefHemisphere forKey:@"prefHemisphere"];
	[defaults synchronize];
	AvLog(@"HEMISPHERE: global.prefHemisphere=%d", hemisphere);
	
	// just in case....
	[self uncoverAll];
}
// Delegate method from the CLLocationManagerDelegate protocol...
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	AvLog(@"LOCATION: latitude[%+.6f] longitude[%+.6f]\n",
		  newLocation.coordinate.latitude,newLocation.coordinate.longitude);
	// stop updating
	[manager stopUpdatingLocation];
	// save location
	[self locationSet: ( (newLocation.coordinate.latitude >= 0.0) ? HEMISPHERE_NORTH : HEMISPHERE_SOUTH) ];
	// update view
	[currentVC viewWillAppear:FALSE];
	// Uncover view
	[self uncoverAll];
}
// Location error....
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	AvLog(@"LOCATION ERROR!!!\n");
	// stop updating
	[manager stopUpdatingLocation];
	// Uncover view
	[self uncoverAll];
}

//
// UIAlertView DELEGATE
//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)i
{
	// BUY FULL
	if (i)
		[global goLink:LINK_BUY_FULL];
}


@end
