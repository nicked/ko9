//
//  NSDictionary+TypedValues.m
//
//  Created by Nick Randall on 16/10/20.
//  Copyright © 2020 Nick Randall. All rights reserved.
//

#import "NSDictionary+TypedValues.h"


@implementation NSDictionary (TypedValues)

- (NSString *)stringForKey:(NSString *)key {
    id val = self[key];
    return [val isKindOfClass:NSString.class]? val : nil;
}

- (NSNumber *)numberForKey:(NSString *)key {
    id val = self[key];
    return [val isKindOfClass:NSNumber.class]? val : nil;
}

- (NSInteger)integerForKey:(NSString *)key {
    return [self numberForKey:key].integerValue ?:
            [self stringForKey:key].integerValue;
}

@end
