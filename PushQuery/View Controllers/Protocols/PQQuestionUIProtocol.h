//
//  PQQuestionUIProtocol.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>
#import "PQQuestionProtocols.h"

#pragma mark - // DEFINITIONS //

#pragma mark - // PROTOCOL (PQQuestionUI) //

@protocol PQQuestionUI <NSObject>
@property (nonatomic, strong) id <PQQuestion> question;
@end
