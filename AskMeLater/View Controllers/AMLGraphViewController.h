//
//  AMLGraphViewController.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

#import "AMLSurveyUIProtocol.h"

#pragma mark - // DEFINITIONS (Public) //

@interface AMLGraphViewController : UIViewController <AMLSurveyUI>
@property (nonatomic, strong) id <AMLSurvey> survey;
@end
