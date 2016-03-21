//
//  AMLSurveyTableViewCell.h
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

@class AMLSurveyTableViewCell;

@protocol AMLSurveyTableViewCellDelegate <NSObject>
- (void)cellDidChangeHeight:(UITableViewCell *)sender;
- (void)cellShouldBeDeleted:(UITableViewCell *)sender;
- (void)cellDidChangeText:(AMLSurveyTableViewCell *)sender;
@end

#pragma mark - // DEFINITIONS (Public) //

@interface AMLSurveyTableViewCell : UITableViewCell
@property (nonatomic, strong) id <AMLSurveyTableViewCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic) CGFloat minimumHeight;
+ (NSString *)reuseIdentifier;
@end
