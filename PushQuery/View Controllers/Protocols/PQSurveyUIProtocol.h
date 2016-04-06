//
//  PQSurveyUIProtocol.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/17/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>
#import "PQSurveyProtocols.h"

#pragma mark - // DEFINITIONS //

#define PQSurveyUIDidSelectQuestion @"kNotificationPQSurveyUI_DidSelectQuestion"

#pragma mark - // PROTOCOL (PQSurveyUI) //

@protocol PQSurveyUI <NSObject>
@property (nonatomic, strong) id <PQSurvey> survey;
@end
