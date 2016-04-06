//
//  AMLAppInfo.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 4/5/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface AMLAppInfo : NSObject
+ (BOOL)showTutorial;
+ (void)enableTutorial;
+ (void)disableTutorial;
@end
