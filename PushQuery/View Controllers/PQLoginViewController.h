//
//  PQLoginViewController.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/21/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

#import "PQLoginUIProtocol.h"

#pragma mark - // DEFINITIONS (Public) //

@interface PQLoginViewController : UIViewController <PQLoginUI>
@property (nonatomic, strong) void (^completionBlock)(id <PQUser> user);
@end
