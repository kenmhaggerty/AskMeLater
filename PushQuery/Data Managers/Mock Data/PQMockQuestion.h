//
//  PQMockQuestion.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/19/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface PQMockQuestion : NSObject
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSMutableArray <NSString *> *choices;

// INITIALIZERS //

- (id)init;
- (id)initWithText:(NSString *)text choices:(NSArray <NSString *> *)choices;

@end
