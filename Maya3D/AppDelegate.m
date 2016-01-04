//
//  AppDelegate.m
//  Maya3D
//
//  Created by admin on 12/18/15.
//  Copyright (c) 2015 Avante. All rights reserved.
//

#import "AppDelegate.h"
#import "TzCalendar.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window;
//@synthesize navigationController;
//@synthesize tabBarController;


- (void)dealloc {
    // Roger
    
    [global release];
    // system
    [window release];
    [super dealloc];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    CGSize size = self.window.bounds.size;
    setSize(size.width, size.height);
#ifdef LITE
    AvLog(@">>> THIS IS LITE VERSION!");
#endif
    // GLOBALS
    global = [[TzGlobal alloc] init];
    
    // Configura Tab Bar - isso nao funciona mais no OS 3.0
    //self.tabBarController.selectedIndex = TAB_INIT;
    
    //self.tabBarController = [[MayaTabBarCtrl alloc] initWithNibName:nil bundle:NULL];
    // Guarda para TzClock
    global.theTabBar = self.tabBarController;
    global.theNavController = self.navigationController;
    
    // Configura nomes dos tabs
    if (global.theTabBar)
    {
//        global.theTabBar.tabBar.tintColor = [UIColor colorWithRed:0.98 green:0.92 blue:0.68 alpha:1];
        global.theTabBar.tabBar.tintColor = [UIColor colorWithRed:1 green:0.95 blue:0.87 alpha:1];
        
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
    [self.window addSubview:self.tabBarController.view];
    
#endif
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [global updatePreferences];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [global updatePreferences];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Avante.Maya3D" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Maya3D" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Maya3D.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

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

void setSize(int screenWidth,int screenHeight)
{
    kscreenWidth = screenWidth;//			320.0
    kscreenHeight = screenHeight;//			480.0
    kActive = kscreenHeight - 20;//					460.0	// 480 - 20 = 460
    kActiveLessNav = kscreenHeight - 20 -44;//			416.0	// 480 - 20 - 44 = 416
    kActiveLessTab = kscreenHeight - 20-49;//			411.0	// 480 - 20 - 49 = 411
    kActiveLessNavTab = kscreenHeight -  20 - 44 - 49;//		367.0	// 480 - 20 - 44 - 49 = 367
    ACTUAL_VIEW_HEIGHT = (kActiveLessNavTab - kRollerVerticalHeight);
    
    kUIPickerHeight = 216.0 * kscreenHeight / 480;

}



