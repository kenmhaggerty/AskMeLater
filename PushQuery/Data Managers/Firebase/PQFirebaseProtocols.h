//
//  PQFirebaseProtocols.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/7/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>

#pragma mark - // DEFINITIONS //

#pragma mark - // PROTOCOLS //

@protocol Firebase <NSObject>
+ (BOOL)isConnectedToFirebase;
+ (void)connectToFirebase;
+ (void)disconnectFromFirebase;
@end
