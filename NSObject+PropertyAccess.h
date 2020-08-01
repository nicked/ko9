//
//  NSObject+PropertyAccess.h
//
//  Created by Nick Randall on 14/7/20.
//  Copyright © 2020 Nick Randall. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PropertyAccess)

/// Returns the value of a property with the given name
- (nullable id)valueForProperty:(NSString *)propertyName;

/// Sets a property with the given name to the specified value
- (void)setValue:(nullable id)value forProperty:(NSString *)propertyName;

@end

NS_ASSUME_NONNULL_END
