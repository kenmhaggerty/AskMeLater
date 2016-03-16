//
//  AMLCoreDataController.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#import "AMLUserProtocols.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface AMLCoreDataController : NSObject
+ (id <AMLUser>)userWithEmail:(NSString *)email;
+ (void)save;
@end
