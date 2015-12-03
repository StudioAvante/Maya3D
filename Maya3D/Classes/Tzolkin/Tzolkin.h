/*
 *  Tzolkin.h
 *  Tzolkin
 *
 *  Created by Roger on 07/11/08.
 *  Copyright 2008 Studio Avante. All rights reserved.
 *
 */

//
// PODUCAO ?
//
#ifdef DISTRIBUTION
#define PROD					1	//  << CHECK FOR PROD : 1
#define DEBUG_LEVEL				0
#else
#define DEBUG_LEVEL		1
#endif

//
// MAYA / DREAMSPELL
//
#ifdef KIN3D
#define ENABLE_MAYA				0
#define ENABLE_DREAMSPELL		1
#else
#define ENABLE_MAYA				1
#define ENABLE_DREAMSPELL		0
#endif

// MAYA ONLY
#if (ENABLE_MAYA && !ENABLE_DREAMSPELL)
#define DUAL_MODE			0
#define MAYA_ONLY			1
#define DREAMSPELL_ONLY		0
// DREAMSPELL ONLY
#elif (!ENABLE_MAYA && ENABLE_DREAMSPELL)
#define DUAL_MODE			0
#define MAYA_ONLY			0
#define DREAMSPELL_ONLY		1
// else DUAL
#else
#define DUAL_MODE			1
#define MAYA_ONLY			0
#define DREAMSPELL_ONLY		0
#endif



// Settings - info.plist
// IMPORTANTE!!! >> DEVEM BATER COM A ORDEM NO IB
// Lang Settings
#define LANG_DEVICE				0
#define LANG_EN					1
#define LANG_PT					2
#define LANG_ES					3
// Main View mode
#define VIEW_MODE_MAYA			0
#define VIEW_MODE_DREAMSPELL	1
// Date to Start
#define START_TODAY				0
#define START_LAST				1
// Formato de datas gregorianas
#define GREG_DMY				0
#define GREG_MDY				1
// sistema de numeracao
#define NUMBERING_MAYA			0
#define NUMBERING_123			1
// global.prefClockStyle
#define CLOCK_STYLE_123			0
#define CLOCK_STYLE_MAYA		1
// global.prefGearName
#define GEAR_NAME_OFF			0
#define GEAR_NAME_ON			1
// global.prefGearSound
#define GEAR_SOUND_QUIET		0
#define GEAR_SOUND_TICK			1
#define GEAR_SOUND_CHIME		2
#define GEAR_SOUND_CHORD		3

// Visoes disponiveis do calendario = global "`"
// !!!! DEVE SER IGUAL A ORDEM DO TABBAR NO IB !!!!!!!
enum {
	TAB_MAYA3D,
	TAB_GLYPH,
	TAB_ORACLE,
	TAB_EXPLORER,
	TAB_DATEBOOK,
	TAB_CLOCK
} enumTabs;
#define TAB_INIT	TAB_MAYA3D

// Localização
enum {
	HEMISPHERE_UNKNOWN,
	HEMISPHERE_SOUTH,
	HEMISPHERE_NORTH
} enumHemisphere;

// Direcoes
// Bate com a cor do tzolkin, nesta ordem
enum {
	MALE,
	FEMALE
} enumGender;

// Direcoes
// Bate com a cor do tzolkin, nesta ordem
enum {
	DIR_EAST = 1,
	DIR_NORTH,
	DIR_WEST,
	DIR_SOUTH
} enumDirections;

// Oracle Kins
enum {
	ORACLE_GUIDE = 1,	// 1
	ORACLE_ANTIPODE,	// 2
	ORACLE_DESTINY,		// 3
	ORACLE_ANALOG,		// 4
	ORACLE_OCCULT		// 5
} enumOracleKin;

// Alinhamentos
enum {
	ALIGN_LEFT = -1,
	ALIGN_CENTER,
	ALIGN_RIGHT
} enumAlign;

// Estilos de Date Pickers
enum {
	DATE_PICKER_GREGORIAN,
	DATE_PICKER_JULIAN,
	DATE_PICKER_LONG_COUNT
} enumDatePickerTypes;



// Constantes
#define CORRELATION				584283						// Thompson Correlation
#define MAYANERAKINS			1872000						// 13.0.0.0.0
#define PIKTUNKINS				2880000						// 20.0.0.0.0
#define JULIAN_MIN				CORRELATION					// Dia minimo suportado
#define JULIAN_MAX				(CORRELATION+PIKTUNKINS)	// Dia maximo suportado (1 Piktun)
#define ABSTIMEJULIAN			2451911						// Absolute time = Jan 1 2001 00:00:00 GMT
#define SECONDS_PER_DAY			86400						// 24*60*60 = 86400 seconds in a day
#define SECONDS_PER_UINAL		(SECONDS_PER_DAY*20)
#define SECONDS_PER_TZOLKIN		(SECONDS_PER_DAY*260)
#define SECONDS_PER_TUN			(SECONDS_PER_DAY*360)
#define SECONDS_PER_HAAB		(SECONDS_PER_DAY*365)
#define CALENDAR_ROUND_DAYS		18980						// =52*365
#define DREAMSPELL_JULIAN		2447003						// JDN de 26-jul-1987
#define LUNATION				29.530589					// Duracao de uma lunacao
#define LUNATION_JDN0			0.816466					// Lunacao (0.0-1.0) em JDN-0
#define PI						3.1415926535				// PI
#define PI2						6.2831853070				// PI*2
#define RADIAN_ANGLES			57.2958						// angulos em graus de um radiano

// FUNCTIONS
#define DEG2RAD(a)						((a)/180.0*PI)
#define RAD2DEG(a)						((a)*RADIAN_ANGLES)
#define DISTANCE_BETWEEN(x1,y1,x2,y2)	(sqrt( pow((x2)-(x1),2.0)+pow((y2)-(y1),2.0)))	// Distancia entre 2 pontos
#define LOCAL(str)						(NSLocalizedString((str),@""))
#define	HEIGHT_FOR_LINES(font,lines)	(ceil(((font)*1.33)*(lines)))
#define	WIDTH_FOR_TEXT(font,text)		([(text) sizeWithFont:[UIFont systemFontOfSize:(font)]].width)

// Image sizes
#define IMAGE_SIZE_SMALL		20.0
#define IMAGE_SIZE_BIG			35.0

// Screenshot
#define SHOT_SIDE				5.0
#define SHOT_HEADER				5.0
#define SHOT_GREG_HEADER		20.0
#define SHOT_GREG_SIZE			16.0
#define SHOT_TRAILER			30.0

// OpenGL
#define CLOCK_INTERVAL			(1.0/60.0)	// Clock update interval
#define OPENGL_INTERVAL			(1.0/60.0)	// OpenGL optimum FPS
#define UI_INTERVAL				(1.0/13.0)	// UI update interval
#define ACCELEROMETER			1			// << CHECK FOR PROD : 1
#define DISPLAY_FPS				1
// Finger swipe (move camera)
#define ALLOW_SWIPE				0			// Pode mover camera com os dedos? << CHECK FOR PROD : 0
#define ALLOW_ROTATE			0			// Pode rodar camera com os dedos? << CHECK FOR PROD : 0
// Perspective
#define PERSPECTIVE				1
#define Z_NEAR					5.0			// Plano proximo
#define Z_PLANE					20.0		// Plano dos objetos
#define Z_FAR					100.0		// Plano longe
// Camera angle
#define PITCH_MAX				45.0		/// Maior pitch da camera
// Camera size
#define CAMERA_WIDTH			5.0			// Largura inicial
#define	CAMERA_WIDTH_MIN		3.0			// Largura minima
#define	CAMERA_WIDTH_MAX		13.0		// Largura maxima
#define	CAMERA_SIZE_LOCK		1			// Deve usar as regras de tamanho acima? << CHECK FOR PROD : 1
// Shooting modes
// > Desligar tambem o CAMERA_SIZE_LOCK
#define MAKE_SPLASH				0			// << CHECK FOR PROD : 0
#define SHOOTING				0			// << CHECK FOR PROD : 0
#define SHOOTING_SIZE			1024.0


// Sound Waves
enum {
	WAVE_TICK,
	//WAVE_SAVED,
	//WAVE_CLICK,
	//WAVE_DUMMY,
	WAVE_COUNT
} enumWaves;

// Info Pages
enum {
	INFO_BASICS,
	INFO_BASICS_LITE,
	INFO_MAYA,
	INFO_TZOLKIN,
	INFO_HAAB,
	INFO_LONG_COUNT,
	INFO_2012,
	INFO_MAYA_GLYPH,
	INFO_MAYA_ORACLE,
	INFO_DREAMSPELL,
	INFO_DREAMSPELL_MORE,
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
	INFO_ABOUT_LITE,
	INFO_BUY_FULL,
	// Count
	INFO_PAGES_COUNT
} enumInfoPages;


// Web Links
enum {
	LINK_STUDIO_AVANTE,
	LINK_MAYA3D,
	LINK_KIN3D,
	LINK_SUPPORT,
	LINK_CONTACT,
	LINK_BOOKS,
	LINK_LINKS,
	LINK_BUY_FULL,
	LINK_DOWNLOAD_LITE,
	LINK_DOWNLOAD_KIN3D,
	LINK_SINCRONARIO_DA_PAZ,
	LINK_CALENDARIO_DA_PAZ,
	LINK_LAW_OF_TIME,
	LINK_TORTUGA,
	LINK_APPS_TZOLKIN,
	LINK_APPS_MAYA
} enumLinks;


// control dimensions
// verified
#define kscreenWidth			320.0
#define kscreenHeight			480.0
#define kStatusBarHeight		20.0
#define kToolbarHeight			44.0
#define kToolBarButtonHeight	30.0
#define kTabBarHeight			49.0
#define kActive					460.0	// 480 - 20 = 460
#define kActiveLessNav			416.0	// 480 - 20 - 44 = 416
#define kActiveLessTab			411.0	// 480 - 20 - 49 = 411
#define kActiveLessNavTab		367.0	// 480 - 20 - 44 - 49 = 367
#define kUIPickerHeight			216.0
#define kPageControlHeight		24.0
// Avante
#define kRollerVerticalHeight	kToolbarHeight
// !!unverified!!
#define kStdButtonWidth			106.0
#define kStdButtonHeight		40.0
#define kSegmentedControlHeight 40.0
#define kSliderHeight			7.0
#define kSwitchButtonWidth		94.0
#define kSwitchButtonHeight		27.0
#define kTextFieldHeight		30.0
#define kSearchBarHeight		40.0
#define kProgressIndicatorSize	40.0
#define kUIProgressBarWidth		160.0
#define kUIProgressBarHeight	24.0
#define kUICellWidth			300.0


//
// GLOBAIS
//
@class TzGlobal;
extern TzGlobal *global;

//
// AppDelegate.m
//
void AvLog(NSString *format, ...);
void AvLogMemory(NSString *msg);


