//
//  AppDelegate.h
//  Maya3D
//
//  Created by admin on 12/18/15.
//  Copyright (c) 2015 Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TzGlobal.h"

TzGlobal *global;
int kscreenWidth;//			320.0
int kscreenHeight;//			480.0
int kActive;//					460.0	// 480 - 20 = 460
int kActiveLessNav;//			416.0	// 480 - 20 - 44 = 416
int kActiveLessTab;//			411.0	// 480 - 20 - 49 = 411
int kActiveLessNavTab;//		367.0	// 480 - 20 - 44 - 49 = 367
int ACTUAL_VIEW_HEIGHT;//		(kActiveLessNavTab - kRollerVerticalHeight)
int CONTENT_HEIGHT;//			(kActiveLessNav - HEADER_HEIGHT - TRAILER_HEIGHT - kRollerVerticalHeight)
int kUIPickerHeight;//			216.0

@interface AppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

