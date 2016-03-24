//
//  AMLDataManager.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/5/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#pragma mark - // PROTOCOLS //

#import "AMLFirebaseProtocols.h"
#import "AMLUserProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

#import "AMLFirebaseNotifications.h"

@interface AMLDataManager : NSObject <Firebase>
+ (void)setup;
+ (void)save;
+ (void)test;
@end
