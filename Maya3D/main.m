//
//  main.m
//  Maya3D
//
//  Created by Roger on 13/07/09.
//  Copyright Studio Avante 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
	// NEW ios6
	@autoreleasepool {
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	}

	// Old iOS4
	/*
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
    [pool release];
	return retVal;
	 */
}
