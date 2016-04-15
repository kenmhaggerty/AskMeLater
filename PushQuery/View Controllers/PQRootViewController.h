//
//  PQRootViewController.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/13/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>
#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

#import "PQCentralDispatch+Delegates.h"

#pragma mark - // DEFINITIONS (Public) //

@interface PQRootViewController : UIViewController <PQLoginDelegate>
@end
