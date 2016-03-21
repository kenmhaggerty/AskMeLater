//
//  AMLSurveyUIProtocol.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/17/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>
//#import "AMLSurveyProtocols.h"
#import "AMLMockSurvey.h" // temp

#pragma mark - // DEFINITIONS //

#pragma mark - // PROTOCOL (AMLSurveyUI) //

@protocol AMLSurveyUI <NSObject>
//@property (nonatomic, strong) id <AMLSurvey> survey;
@property (nonatomic, strong) AMLMockSurvey *survey;
@end
