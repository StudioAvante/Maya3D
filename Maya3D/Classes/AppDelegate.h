//
//  AppDelegate.h
//  Maya3D
//
//  Created by Roger on 05/11/08.
//  Copyright Studio Avante 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TzGlobal.h"

// Globals
TzGlobal *global;


@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate> {
	UIWindow *window;
	// No Interface Builder, o App Delegate eh associado a este TabBarControler...
	UINavigationController *navigationController;
	// No Interface Builder, o o Tab Bar eh associado a este...
	UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
