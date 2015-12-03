//
//  Maya3DVC.m
//  Maya3D
//
//  Created by Roger on 05/11/08.
//  Copyright Studio Avante 2008. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "Maya3DVC.h"
#import "MayaExplorerVC.h"
#import "DatePickerVC.h"
#import "AvanteTextField.h"
#import "SettingsVC.h"
#import "ClockVC.h"
#import "InfoVC.h"
#import "Tzolkin.h"
#import "TzGlobal.h"
#import "TzClock.h"
#import "TzSoundManager.h"
#import "GLEngine.h"


#ifdef LITE
#define GL_VIEW_HEIGHT	kActiveLessNav
#else
#define GL_VIEW_HEIGHT	kActiveLessNavTab
#endif


@implementation Maya3DVC

@synthesize glView;


// destructor
- (void)dealloc {
	// Views
	[glView dealloc];
	[glView removeFromSuperview];
	// Timers
	[glTimer invalidate];
	[glTimer release];
	[uiTimer invalidate];
	[uiTimer release];
	//super
    [super dealloc];
}

#pragma mark UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
 // Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically.
 - (void)loadView {
 }
 */




//
// init: FULLSCREEN
//
- (id)initFullScreen:(GLEngine*)glv
{
	// Set full screen
	fullScreen = YES;
	// init
	[self initWithNibName:@"TzTabView" bundle:nil];
	// save glView pointer
	glView = glv;
	// ok!
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	UIBarButtonItem *but;
	
	// super
    [super viewDidLoad];
	
	// Corrige nome
	self.title = LOCAL(@"TAB_MAYA3D");
	
	// Tamanho da view
	if (SHOOTING)
	{
		// fotos quadradas
		glFrame.size.width = SHOOTING_SIZE;
		glFrame.size.height = SHOOTING_SIZE;
	}
	else
	{
		glFrame.size.width = 320.0;
		glFrame.size.height = GL_VIEW_HEIGHT;
	}

	// FULL SCREEN
	if (fullScreen)
	{
		// SCREENSHOT BUTTON - in fullscreen
		but = [[UIBarButtonItem alloc]
			   //initWithImage: [global imageFromFile:@"icon_save"]
			   //style:UIBarButtonItemStylePlain
			   initWithBarButtonSystemItem:UIBarButtonSystemItemAction
			   target:self
			   action:@selector(saveScreenshot:)];
		self.navigationItem.rightBarButtonItem = but;
		self.navigationItem.rightBarButtonItem.enabled = TRUE;
		[but release];
	}
	// NORMAL - WINDOWED
	else
	{
		// Configura switch MAYA / DREAMSPELL
		mayaMoonSelector = [global addViewModeSwitch:self];
		
		// HELP BUTTON
		but = [[UIBarButtonItem alloc]
			   initWithImage: [global imageFromFile:@"icon_info"]
			   style:UIBarButtonItemStylePlain
			   target:self action:@selector(goInfo:)];
		self.navigationItem.leftBarButtonItem = but;
		self.navigationItem.leftBarButtonItem.enabled = TRUE;
		[but release];
		
#ifdef LITE
		// PICK DATE
		but = [[UIBarButtonItem alloc]
			   initWithImage:[global imageFromFile:@"icon_search"]
			   style:UIBarButtonItemStylePlain
			   target:self action:@selector(pickGregorian:)];
		self.navigationItem.rightBarButtonItem = but;
		self.navigationItem.rightBarButtonItem.enabled = TRUE;
		[but release];
#else
		// modo foto?
		if (SHOOTING)
		{
			// MODO DE FOTO
			// FULL SCREEN BUTTON
			but = [[UIBarButtonItem alloc]
				   initWithImage:[global imageFromFile:@"icon_fullscreen"]
				   style:UIBarButtonItemStylePlain
				   target:self action:@selector(goFullScreen:)];
			self.navigationItem.rightBarButtonItem = but;
			self.navigationItem.rightBarButtonItem.enabled = TRUE;
			[but release];
		}
		else
		{
			// CLOCK BUTTON
			clockButton = [[UIBarButtonItem alloc]
						   initWithImage:[UIImage imageNamed:@"icon_clock_play.png"]
						   style:UIBarButtonItemStylePlain
						   target:self action:@selector(goClock:)];
			self.navigationItem.rightBarButtonItem = clockButton;
			self.navigationItem.rightBarButtonItem.enabled = TRUE;
			[clockButton release];
		}
#endif // LITE
		
	}
	
	// CLOK BUTTON
	/*
	 clockButton = [UIButton buttonWithType:UIButtonTypeCustom]
	 initWithImage:[UIImage imageNamed:@"icon_clock_play.png"]
	 style:UIBarButtonItemStylePlain
	 target:self action:@selector(goClock:)];
	 self.navigationItem.titleView = clockButton;
	 */
	
	// SETTINGS BUTTON
	/*
	 UIBarButtonItem *but;
	 but = [[UIBarButtonItem alloc]
	 initWithImage:[global imageFromFile:@"icon_settings"]
	 style:UIBarButtonItemStylePlain
		   target:self action:@selector(goSettings:)];
	self.navigationItem.leftBarButtonItem = but;
	self.navigationItem.leftBarButtonItem.enabled = TRUE;
	[but release];
*/
	
	// Alloc/Resize GL view
	glFrame.origin.x = ((320.0-glFrame.size.width)/2.0);
	glFrame.origin.y = ((GL_VIEW_HEIGHT-glFrame.size.height)/2.0);
	if (glView == nil && !fullScreen)
		glView = [[GLEngine alloc] initWithFrame:glFrame];
	// Add to current VC
	glView.myVC = self;
	[self.view addSubview:glView];
	
	// DATA GREGORIANA
	CGFloat w = 180.0;
	gregName = [[AvanteTextField alloc] init:@"" x:((320.0-w)/2.0) y:5.0 w:w h:22.0 size:16.0];
	gregName.hidden = YES;
	[self.view addSubview:gregName];
	[gregName release];
	
	// Imagem para entrar/sair de full screen
	fullImage = [[UIImageView alloc] initWithFrame:glFrame];
	fullImage.hidden = YES;
	[self.view addSubview:fullImage];
	[fullImage release];

	// Timers separados para o GL nao esperar ninguem
	glTimer = [NSTimer scheduledTimerWithTimeInterval:OPENGL_INTERVAL target:self selector:@selector(draw3DView:) userInfo:nil repeats:YES];
	uiTimer = [NSTimer scheduledTimerWithTimeInterval:UI_INTERVAL target:self selector:@selector(drawUI:) userInfo:nil repeats:YES];
	
	// OS 3.0b5 BUG WORKAROUND - evita App CRASH
	// https://devforums.apple.com/thread/15985
	/*
	CGAffineTransform cgCTM;
	cgCTM = CGAffineTransformMakeRotation(0.001);
	//cgCTM = CGAffineTransformMakeScale(1.001,1.001);
	self.view.transform = cgCTM;
	 */
}
- (void)viewWillAppear:(BOOL)animated {
	// Usa View Mode atual
	if (mayaMoonSelector)
		mayaMoonSelector.selectedSegmentIndex = global.prefMayaDreamspell;
	// Update gear names
	[glView updateNames];
	// Atualiza icone do relogio
	[self updateClockIcon];
	// Remove LEAP DAY se estiver no modo DREAMSPELL
	[global.cal removeLeap];
	// Back from Fullscreen: Add GL view
	if (![glView isDescendantOfView:self.view])
		[self.view addSubview:glView];
	fullImage.hidden = YES;
	// Se ja esta criada
	if (dejaVu)
	{
		// Anima para nao piscar
		isAnimating = TRUE;
		// Re-desenha 3D
		[self draw3DView];
		[self drawUI:nil];
	}
}
- (void)viewDidAppear:(BOOL)animated {
	global.currentTab = TAB_MAYA3D;
	global.currentVC = self;
	// Turn on sounds
	//[global.soundLib play];
	
	// First time
	dejaVu = YES;
	isAnimating = TRUE;
}
- (void)viewWillDisappear:(BOOL)animated {
	// Turn off sounds
	//[global.soundLib pause];
	// Stop animation
	isAnimating = FALSE;
	[global.theClock stopAcceleration];
	[glView stopAutoZoom];
	// Fullscreen?
	if (fullScreen)
	{
		fullImage.image = [self glToUIImage];
		fullImage.hidden = NO;
		[glView removeFromSuperview];
	}
	// Short name - para o BACK do nav controler
	self.navigationItem.title = LOCAL(@"TAB_MAYA3D");
}
- (void)viewDidDisappear:(BOOL)animated {
	global.lastTab = TAB_MAYA3D;
}

// Set clock icon
- (void)updateClockIcon
{
	NSString *img;
	if (global.theClock.playing)
		img = [NSString stringWithFormat:@"icon_clock_play.png"];
	else
		img = [NSString stringWithFormat:@"icon_clock_pause.png"];
	clockButton.image = [UIImage imageNamed:img];
	//[clockButton setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
}

#pragma mark ANIMATION

// Draw 3D view
- (void)draw3DView:(NSTimer*)theTimer {
	[self draw3DView];
}
- (void)draw3DView {
	// Should animate?
	if (isAnimating == FALSE)
		return;
	
	// Atualiza 3D View
	[glView draw3DView];
	
	// Play Sounds
	if (global.cal.tick)
	{
		// TICK
		if (global.prefGearSound == GEAR_SOUND_TICK)
		{
			[global.soundLib playWave:WAVE_TICK];
		}
		// CHIME
		else if (global.prefGearSound == GEAR_SOUND_CHIME)
		{
			//[global.soundLib playWave:WAVE_DUMMY];
			//[global.soundLib playSine:440.0 length:1.0 fade:TRUE];
		}
		// CHORD
		else if (global.prefGearSound == GEAR_SOUND_CHORD)
		{
			[glView playChord];
		}
		// Un-Tick
		global.cal.tick = FALSE;
		// Update gear names
		[glView updateNames];
	}

	// update UI - tem seu proprio timer
	//[self drawUI:nil];
}

// Draw UI & Play Sounds
- (void)drawUI:(NSTimer*)theTimer {
	// Should animate?
	if (isAnimating == FALSE)
		return;
	
	// Data e Hora
	[gregName update:global.cal.greg.dayNameHour];
	[global updateNavDate:self secs:YES];
	// first time? DUAL?
	if (gregName.hidden && DUAL_MODE)
		gregName.hidden = NO;
}


#pragma mark TOUCHES

// TOUCH BEGIN
- (void)touchBegin:(CGPoint)pos :(NSString*)name
{
	// Only if window is enabled
	if (global.prefGearName == GEAR_NAME_OFF)
		return;
	
	// Get text size
	CGSize size = [name sizeWithFont:[UIFont systemFontOfSize:16.0]];
	CGFloat w = (size.width+16.0);
	
	// Create Gear name field
	gearName = [[AvanteTextField alloc] init:name x:100.0 y:100.0 w:w h:22.0 size:16.0];
	[self.view addSubview:gearName];
	[gearName release];

	// Finger > Name Offset
	nameOffX = (w / 2.0);
	nameOffY = 65.0;

	// Move to pos
	[self touchMove:pos:name];
}
// TOUCH MOVE
- (void)touchMove:(CGPoint)pos :(NSString*)name
{
	// Only if window is enabled
	if (global.prefGearName == GEAR_NAME_OFF)
		return;
	
	// update name
	[gearName update:name];
	//TODO: Kin3D: gearName : rezize  bug
	//[gearName resizeToText];
	
	// Calc frame pos
	nameFrame.origin.x = pos.x - nameOffX + (nameOffY * cos(global.accelRollTable-(PI/2.0)));
	nameFrame.origin.y = pos.y + (nameOffY * sin(global.accelRollTable-(PI/2.0)));
	gearName.frame = nameFrame;
	
	// Rotate
	gearName.textField.transform = CGAffineTransformMakeRotation (global.accelRollTable);
	//AvLog(@"NAME MOVE posXY[%.2f/%.2f] nameXY[%.2f/%.2f] rot[%.2f]",pos.x,pos.y,nameFrame.origin.x,nameFrame.origin.y,global.accelRollTable*RADIAN_ANGLES);
}
// TOUCH END
- (void)touchEnd
{
	// Only if window is enabled
	if (global.prefGearName == GEAR_NAME_OFF || gearName == nil)
		return;
	// Destroy name
	[gearName removeFromSuperview];
	gearName = nil;
}


#pragma mark ACTIONS

- (IBAction)goSettings:(id)sender {
	SettingsVC *vc = [[SettingsVC alloc] init];
	//vc.title = LOCAL(@"SETTINGS");
	vc.hidesBottomBarWhenPushed  = YES;
	[[self navigationController] pushViewController:vc animated:YES];
	[vc release];
}
- (IBAction)goClock:(id)sender {
	ClockVC *vc = [[ClockVC alloc] init];
	//vc.title = @"Clock";
	vc.hidesBottomBarWhenPushed  = YES;
	[[self navigationController] pushViewController:vc animated:YES];
	[vc release];
}
- (IBAction)goInfo:(id)sender {
#ifdef LITE
	[global goInfo:INFO_BASICS vc:self];
#else
	[global goInfo:INFO_BASICS vc:self];
	/*
	// 1a vez mostra os BASICS
	if (global.prefInfoSeen == 0)
		[global goInfo:INFO_BASICS vc:self];
	else
		[global goInfo:(global.prefMayaDreamspell==0?INFO_MAYA:INFO_DREAMSPELL) vc:self];
	*/
#endif
}
- (IBAction)goFullScreen:(id)sender {
	// Create temporary vc
	Maya3DVC *vc = [[Maya3DVC alloc] initFullScreen:glView];
	vc.hidesBottomBarWhenPushed  = YES;
	vc.title = @"Tzolkin";
	// Make GL Image
	fullImage.image = [self glToUIImage];
	fullImage.hidden = NO;
	// Push!!
	[[self navigationController] pushViewController:vc animated:YES];
	// Release!
	[vc release];
}
// PICKER - GREGORIAN
- (IBAction)pickGregorian:(id)sender {
	// Create temporary vc
	DatePickerVC *vc = [[DatePickerVC alloc] initWithType:DATE_PICKER_GREGORIAN];
	vc.hidesBottomBarWhenPushed  = YES;
	[[self navigationController] pushViewController:vc animated:YES];
	[vc release];
}


#pragma mark SCREENSHOT

//
// SAVE SCREENSHOT of current view
//
- (IBAction)saveScreenshot:(id)sender
{
	UIImageView *imgv;
	UIImage *image;
	UIView *shotView;
	UIImage *shotImage;
	
	// Cria uma view temporaria com tudo em cima
	shotView = [[UIView alloc] initWithFrame:glView.frame];
	shotView.backgroundColor = [UIColor blackColor];
	
	// Adiciona GL
	image = [self glToUIImage];	// nao precisa de release
	imgv = [[UIImageView alloc] initWithImage:image];
	[shotView addSubview:imgv];
	[imgv release];
	
	// Modo de foto nao tem header
	if (!SHOOTING)
	{
		// GREG - Rasteriza e adiciona como view
		// Se adicionar como view, ela se perde depois !?!?!?!
		UIGraphicsBeginImageContext(gregName.frame.size);
		[gregName.layer renderInContext:(CGContextRef)UIGraphicsGetCurrentContext()];
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		// Adiciona greg
		imgv = [[UIImageView alloc] initWithImage:image];
		imgv.frame = gregName.frame;
		[shotView addSubview:imgv];
		[imgv release];
		
		// Adiciona trailer
		NSString *trailer_file = ( (ENABLE_MAYA) ? @"shot_trailer.png" : @"shot_trailer_dreamspell.png");
		imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:trailer_file]];
		imgv.frame = CGRectMake(0.0, (glFrame.size.height-SHOT_TRAILER), 320.0, SHOT_TRAILER);
		[shotView addSubview:imgv];
		[imgv release];
	}
	
	// Rasteriza view temporaria
	UIGraphicsBeginImageContext(shotView.frame.size);
	[shotView.layer renderInContext:(CGContextRef)UIGraphicsGetCurrentContext()];
	shotImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// Click!
	[global saveImageToLibrary:shotImage];
	
	// release
	[shotView release];
}

//
// Save GL content to UIImage
//
-(UIImage *) glToUIImage
{
	int w = (int)glFrame.size.width;
	int h = (int)glFrame.size.height;
	
	NSInteger myDataLength = w * h * 4;
	
	// allocate array and read pixels into it.
	GLubyte *buffer = (GLubyte *) malloc(myDataLength);
	glReadPixels(0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
	
	// gl renders "upside down" so swap top to bottom into new array.
	// there's gotta be a better way, but this works.
	GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
	for(int y = 0; y < h; y++)
	{
		for(int x = 0; x < w * 4; x++)
		{
			buffer2[((h-1) - y) * w * 4 + x] = buffer[y * 4 * w + x];
		}
	}
	
	// make data provider with data.
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
	
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
	
	// then make the uiimage from that
	UIImage *myImage = [UIImage imageWithCGImage:imageRef];
	return myImage;
}



@end
