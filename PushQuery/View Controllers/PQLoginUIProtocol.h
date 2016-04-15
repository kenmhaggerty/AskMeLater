//
//  PQLoginUIProtocol.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/13/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>

#import "PQUserProtocols.h"

#pragma mark - // DEFINITIONS //

#pragma mark - // PROTOCOLS //

@protocol PQLoginUI <NSObject>
@property (nonatomic, strong) void (^completionBlock)(id <PQUser> user);
@end
