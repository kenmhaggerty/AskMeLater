//
//  PQMockSurvey.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/21/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
//#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

#import "PQSurveyProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

@interface PQMockSurvey : NSObject <PQSurvey_Editable>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *editedAt;
@property (nonatomic, strong, readonly) NSDate *createdAt;

// INITIALIZERS //

- (id)init;
- (id)initWithName:(NSString *)name;

@end
