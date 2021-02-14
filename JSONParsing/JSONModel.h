//
//  JSONModel.h
//
//  Created by Nick Randall on 2/8/20.
//  Copyright © 2020 Nick Randall. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface JSONModel : NSObject

/// Returns nil if the JSON is not in the correct format
+ (nullable instancetype)parsedFromJSON:(id)jsonObj;

/// Returns the JSON key name for the given property name
+ (NSString *)jsonKeyForProperty:(NSString *)propName;

@end

NS_ASSUME_NONNULL_END
