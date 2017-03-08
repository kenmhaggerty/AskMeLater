//
//  PQSyncEngine.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
//#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface PQSyncEngine : NSObject
+ (void)setup;
+ (void)fetchSurveysWithCompletion:(void(^)(BOOL success))completionBlock;
@end
