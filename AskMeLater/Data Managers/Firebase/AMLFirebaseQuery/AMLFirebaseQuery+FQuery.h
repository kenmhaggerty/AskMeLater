//
//  AMLFirebaseQuery+FQuery.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "AMLFirebaseQuery.h"

#import <Firebase/Firebase.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface AMLFirebaseQuery (FQuery)

+ (FQuery *)queryWithQueryItem:(AMLFirebaseQuery *)queryItem andDirectory:(Firebase *)directory;
+ (FQuery *)appendQueryItem:(AMLFirebaseQuery *)queryItem toQuery:(FQuery *)query;

@end
