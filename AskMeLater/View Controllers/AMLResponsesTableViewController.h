//
//  AMLResponsesTableViewController.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

#import "AMLQuestionUIProtocol.h"

#pragma mark - // DEFINITIONS (Public) //

@interface AMLResponsesTableViewController : UITableViewController <AMLQuestionUI>
@property (nonatomic, strong) id <AMLQuestion> question;
@end
