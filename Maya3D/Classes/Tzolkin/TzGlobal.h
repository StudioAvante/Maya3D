//
//  TzGlobal.h
//  Maya3D
//
//  Created by Roger on 04/02/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class TzDate;
@class TzCalendar;
@class TzDatebook;
@class TzClock;
@class GLTextureLib;
@class TzSoundManager;
@class InfoVC;

//
// GLOBAIS
//

@interface TzGlobal : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate> {
	CLLocationManager *locMan;
	// Preferencias
	int prefLang;
	NSString *prefLangSuffix;
	int prefLangSetting;
	int prefMayaDreamspell;
	int prefHemisphere;
	int prefLastDate;
	int prefStartDate;
	int prefDateFormat;
	int prefNumbering;
	int prefClockStyle;
	int prefGearName;
	int prefGearSound;
	int prefInfoSeen;
	// Accelerometer Data
	BOOL accelLocked;
	double accelX;
	double accelY;
	double accelZ;
	double accelRoll;		// in RADIANS
	double accelRollTable;	// in RADIANS
	double accelPitch;		// in RADIANS
	// Data inicial
	TzDate *dateInit;
	// Calendario
	TzCalendar *cal;
	// Datebook
	TzDatebook *datebook;
	// Timer
	TzClock *theClock;
	// PONTEIROS GLOBAIS DE NAVEGACAO
	UINavigationController *theNavController;
	UITabBarController *theTabBar;
	UIViewController *currentVC;
	int currentTab;
	int lastTab;
	// GL Texture Lib
	GLTextureLib *texLib;
	int texBound;
	BOOL blendingEnabled;
	// Sound manager
	TzSoundManager *soundLib;
	// Log
	CFAbsoluteTime lastLog;
	// Camera operation
	BOOL cameraLocked;
	UIView *coverView;
	// VC
	InfoVC *info;
	// UI
	int alertResp;
}

@property (nonatomic) int prefLang;
@property (nonatomic, readonly) NSString *prefLangSuffix;
@property (nonatomic) int prefLangSetting;
@property (nonatomic) int prefMayaDreamspell;
@property (nonatomic) int prefHemisphere;
@property (nonatomic) int prefLastDate;
@property (nonatomic) int prefStartDate;
@property (nonatomic) int prefDateFormat;
@property (nonatomic) int prefNumbering;
@property (nonatomic) int prefClockStyle;
@property (nonatomic) int prefGearName;
@property (nonatomic) int prefGearSound;
@property (nonatomic) int prefInfoSeen;
@property (nonatomic) double accelX;
@property (nonatomic) double accelY;
@property (nonatomic) double accelZ;
@property (nonatomic) double accelRoll;
@property (nonatomic) double accelRollTable;
@property (nonatomic) double accelPitch;
@property (nonatomic, readonly) TzDate *dateInit;
@property (nonatomic, readonly) TzCalendar *cal;
@property (nonatomic, readonly) TzDatebook *datebook;
@property (nonatomic, readonly) TzClock *theClock;
@property (nonatomic, assign) UINavigationController *theNavController;
@property (nonatomic, assign) UITabBarController *theTabBar;
@property (nonatomic, assign) UIViewController *currentVC;
@property (nonatomic) int currentTab;
@property (nonatomic) int lastTab;
@property (nonatomic, readonly) GLTextureLib *texLib;
@property (nonatomic) int texBound;
@property (nonatomic) BOOL blendingEnabled;
@property (nonatomic, readonly) TzSoundManager *soundLib;


- (id)init;
- (void)updatePreferences;
- (void)setLang;
- (void)logTime:(id)obj:(NSString*)msg;
// Accelerometer
- (void)stopAccelerometer;
- (void)startAccelerometer;
// Screenshot
- (void)shareView:(UIView*)view to:(NSInteger)shareOption withText:(NSString*)text withBody:(NSString*)body;
- (void)saveImageToLibrary:(UIImage*)image;
- (void)screenshotSaved:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (void)coverAll:(NSString*)msg;
- (void)uncoverAll;
// Cached VC
- (void)goInfo:(int)pg vc:(UIViewController*)topVC;
- (void)goInfo:(int)pg vc:(UIViewController*)topVC y:(CGFloat)yoff;
// View mode
- (UISegmentedControl*)addViewModeSwitch:(UIViewController*)vc;
- (void)switchViewMode:(id)sender;
- (void)updateGlyphTab;
- (void)updateNavDate:(UIViewController*)vc;
- (void)updateNavDate:(UIViewController*)vc secs:(BOOL)secs;
// Alerts
- (void)alertSimple:(NSString*)msg;
- (void)alertYesNo:(NSString*)msg delegate:(id)delegate;
- (void)alertOKBack:(NSString*)msg delegate:(id)delegate;
- (void)alertLite:(NSString*)msg;
- (void)alertSharing:(id)delegate;
- (void)alertLocation:(id)delegate;
// misc
- (void)goLink:(int)link;
- (UIImage*)imageFromFile:(NSString*)file;
- (void)locationSet:(int)hemisphere;
// ShareKit
- (void)sharekitAction;
- (void)shareEmailImage:(UIImage*)image withText:(NSString*)text withBody:(NSString*)body;
- (void)shareFacebookImage:(UIImage*)image withText:(NSString*)text;
- (void)shareTumblrImage:(UIImage*)image withText:(NSString*)text;
- (void)shareTwitterText:(NSString*)text;



@end
