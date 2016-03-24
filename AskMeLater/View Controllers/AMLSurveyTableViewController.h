//
//  AMLSurveyTableViewController.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>
#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

#import "AMLSurveyUIProtocol.h"

#pragma mark - // DEFINITIONS (Public) //

@interface AMLSurveyTableViewController : UITableViewController <AMLSurveyUI>
@property (nonatomic, strong) id <AMLSurvey> survey;
@end
