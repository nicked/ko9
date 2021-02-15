//
//  NSDictionary+TypedValues.h
//
//  Created by Nick Randall on 16/10/20.
//  Copyright © 2020 Nick Randall. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (TypedValues)

- (nullable NSString *)stringForKey:(NSString *)key;
- (nullable NSNumber *)numberForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
