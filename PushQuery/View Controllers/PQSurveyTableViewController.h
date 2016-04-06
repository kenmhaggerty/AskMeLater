//
//  PQSurveyTableViewController.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>
#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

#import "PQSurveyUIProtocol.h"

#pragma mark - // DEFINITIONS (Public) //

@interface PQSurveyTableViewController : UITableViewController <PQSurveyUI>
@property (nonatomic, strong) id <PQSurvey> survey;
@end
