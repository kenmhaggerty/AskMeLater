//
//  AMLMockQuestion.h
//  AskMeLater
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

@interface AMLMockQuestion : NSObject
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *leftChoice;
@property (nonatomic, strong) NSString *rightChoice;

// INITIALIZERS //

- (id)init;
- (id)initWithText:(NSString *)text leftChoice:(NSString *)leftChoice rightChoice:(NSString *)rightChoice;

@end
