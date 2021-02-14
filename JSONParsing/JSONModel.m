//
//  JSONModel.m
//
//  Created by Nick Randall on 2/8/20.
//  Copyright © 2020 Nick Randall. All rights reserved.
//

#import "JSONModel.h"
#import "NSObject+Introspection.h"
#import "ClassProperty.h"
#import "TypeEncoding.h"

@implementation JSONModel

+ (instancetype)parsedFromJSON:(id)jsonObj {
    if ([jsonObj isKindOfClass:NSDictionary.class] == NO) {
        return nil;
    }
    NSDictionary *jsonDict = (NSDictionary *)jsonObj;

    // Create a new instance of the subclass to fill in
    JSONModel *obj = [self new];

    // Introspect our properties
    NSArray<ClassProperty *> *props = [self classProperties];

    for (ClassProperty *prop in props) {
        NSString *jsonKey = [self jsonKeyForProperty:prop.name];
        id jsonVal = jsonDict[jsonKey];

        if (jsonVal == nil) {
            NSLog(@"No value found for property %@", prop.name);
            return nil;
        }

        if (prop.type.classType && [jsonVal isKindOfClass:prop.type.classType]) {
            [obj setValue:jsonVal forKey:prop.name];

        } else if ((prop.type.isIntType || prop.type.isFloatType)
                   && [jsonVal isKindOfClass:NSNumber.class]) {
            [obj setValue:jsonVal forKey:prop.name];

        } else {
            NSLog(@"Couldn't load value for %@", prop.name);
        }
    }

    return obj;
}

+ (NSString *)jsonKeyForProperty:(NSString *)propName {
    return propName;
}

@end
