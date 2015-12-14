//
//  AppDelegate.m
//  Maya3D
//
//  Created by Roger on 05/11/08.
//  Copyright Studio Avante 2008. All rights reserved.
//

#import "AppDelegate.h"
#import "TzCalendar.h"


@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize tabBarController;


- (void)dealloc {
	// Roger
    
	[global release];
	// system
    [window release];
    [super dealloc];

}


// INITIALIZE APP
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
#ifdef LITE
	AvLog(@">>> THIS IS LITE VERSION!");
#endif
	// GLOBALS
	global = [[TzGlobal alloc] init];
	
	// Configura Tab Bar - isso nao funciona mais no OS 3.0
	//self.tabBarController.selectedIndex = TAB_INIT;
	
	// Guarda para TzClock
	global.theTabBar = self.tabBarController;
	global.theNavController = self.navigationController;

	// Configura nomes dos tabs
	if (global.theTabBar)
	{

		UIViewController *vc;
		vc = (UIViewController*) [global.theTabBar.viewControllers objectAtIndex:TAB_MAYA3D];
		vc.tabBarItem.title = LOCAL(@"TAB_MAYA3D");

		vc = (UIViewController*) [global.theTabBar.viewControllers objectAtIndex:TAB_ORACLE];
		vc.tabBarItem.title = LOCAL(@"TAB_ORACLE");
		vc = (UIViewController*) [global.theTabBar.viewControllers objectAtIndex:TAB_EXPLORER];
		vc.tabBarItem.title = LOCAL(@"TAB_EXPLORER");
		vc = (UIViewController*) [global.theTabBar.viewControllers objectAtIndex:TAB_DATEBOOK];
		vc.tabBarItem.title = LOCAL(@"TAB_DATEBOOK");

		// Oracle: depende de configuracoes
		//[global switchViewMode: global.prefMayaDreamspell];
		
		// GLYPH: usa botao correto no tab
		[global updateGlyphTab];
	}
	
	// Configura Navigation Controller
#ifdef LITE
    [window addSubview:self.navigationController.view];
#else
	// NEW ios6
    //[window addSubview:self.tabBarController.view];
	[self.window setRootViewController:self.tabBarController];
#endif
	[window makeKeyAndVisible];
}

// TERMINATE APP
- (void)applicationWillTerminate:(UIApplication *)application
{
	[global updatePreferences];
}
// SLEEP APP
- (void)applicationWillResignActive:(UIApplication *)application
{
	[global updatePreferences];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	AvLog(@"!!!!!! MEMORY WARNING !!!!!!!!");
	
	// Super - nao tem no super!
	//[super applicationDidReceiveMemoryWarning:application];
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

@end

#pragma mark AVANTE

void AvLog(NSString *format, ...)
{
	// debug?
	if (DEBUG_LEVEL == 0)
		return;
	// debug!
	va_list args;
	va_start(args, format);
	NSLogv(format, args);
	va_end(args );
}

//
// LOG FREE MEMORY
//
#import <sys/sysctl.h>
#import <mach/mach_host.h>
void AvLogMemory(NSString *msg)
{
    size_t length;
    int mib[6];
    int pagesize;
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    length = sizeof(pagesize);
    sysctl(mib, 2, &pagesize, &length, NULL, 0);
	
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
	
    vm_statistics_data_t vmstat;
    host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count);
    double total = vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count;
    double free = vmstat.free_count / total;
	
    int percentFree = (int)(free * 100.0);
    int available = ((vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count) * pagesize) / 0x100000;
	int remaining = ((vmstat.free_count * pagesize) / 0x100000);
	
	AvLog(@"MEMORY :: %@ :: %%Free[%d] available[%d] remaining[%d]", msg, percentFree, available, remaining);
}



