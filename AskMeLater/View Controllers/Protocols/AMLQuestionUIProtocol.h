//
//  AMLQuestionUIProtocol.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>
#import "AMLQuestionProtocols.h"

#pragma mark - // DEFINITIONS //

#pragma mark - // PROTOCOL (AMLQuestionUI) //

@protocol AMLQuestionUI <NSObject>
@property (nonatomic, strong) id <AMLQuestion> question;
@end
