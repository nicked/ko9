//
//  TypeEncoding.m
//
//  Created by Nick Randall on 21/5/20.
//  Copyright © 2020 Nick Randall. All rights reserved.
//

#import "TypeEncoding.h"

@implementation TypeEncoding

- (instancetype)initWithEncoding:(NSString *)encoding {
    self = [super init];
    if (self) {
        _encoding = [encoding copy];
        _type = [encoding characterAtIndex:0];

        static const unichar TypeConst = 'r';
        if (_type == TypeConst) {
            // const C strings are encoded as "r*", skip the 'r'
            _type = [encoding characterAtIndex:1];
        }
    }
    return self;
}

- (BOOL)isObjectType {
    return _type == TypeObject || _type == TypeClass;
}

- (BOOL)isFloatType {
    return _type == TypeFloat || _type == TypeDouble;
}

- (BOOL)isIntType {
    static const char *integralTypes = "cislqCISLQB";
    return strchr(integralTypes, _type) != NULL;
}

- (Class)classType {
    if (_type == TypeObject
        && [_encoding hasPrefix:@"@\""] && [_encoding hasSuffix:@"\""]) {
        NSRange range = NSMakeRange(2, _encoding.length - 3);
        NSString *classStr = [_encoding substringWithRange:range];
        return NSClassFromString(classStr) ?: NSObject.class;
    }
    return nil;
}

@end
