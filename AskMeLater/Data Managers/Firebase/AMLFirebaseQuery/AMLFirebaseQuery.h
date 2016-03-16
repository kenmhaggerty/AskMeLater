//
//  AMLFirebaseQuery.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

typedef enum : NSUInteger {
    AMLKeyIsEqualTo = 0,
    AMLKeyIsLessThanOrEqualTo,
    AMLKeyIsGreaterThanOrEqualTo,
} AMLQueryRelation;

@interface AMLFirebaseQuery : NSObject

// INITIALIZERS //

- (id)init;
- (id)initWithKey:(NSString *)key relation:(AMLQueryRelation)relation value:(id)value;
+ (instancetype)queryWithKey:(NSString *)key relation:(AMLQueryRelation)relation value:(id)value;

@end
