//
//  ClassProperty.m
//
//  Created by Nick Randall on 9/5/20.
//  Copyright © 2020 Nick Randall. All rights reserved.
//

#import "ClassProperty.h"

@implementation ClassProperty

@synthesize getter = _getter;
@synthesize setter = _setter;

- (instancetype)initWithProperty:(objc_property_t)property {
    self = [super init];
    if (self) {
        _name = @(property_getName(property));
        _setterType = Assign;  // this is the default
        NSString *attribStr = @(property_getAttributes(property));
        NSArray *attribs = [attribStr componentsSeparatedByString:@","];

        for (NSString *attrib in attribs) {
            unichar attribChar = [attrib characterAtIndex:0];
            NSString *attribDetail = [attrib substringFromIndex:1];

            switch (attribChar) {
                case 'T':
                    _encodeType = attribDetail;
                    break;
                case 'R':
                    _isReadOnly = YES;
                    break;
                case 'N':
                    _isNonAtomic = YES;
                    break;
                case 'D':
                    _isDynamic = YES;
                    break;
                case '&':
                    _setterType = Strong;
                    break;
                case 'W':
                    _setterType = Weak;
                    break;
                case 'C':
                    _setterType = Copy;
                    break;
                case 'G':
                    _getter = NSSelectorFromString(attribDetail);
                    break;
                case 'S':
                    _setter = NSSelectorFromString(attribDetail);
                    break;
                case 'V':
                    _ivarName = attribDetail;
                    break;
                default:
                    NSAssert(NO, @"Unknown attribute: %@", attrib);
            }
        }

        if (_getter == NULL) {
            _getter = NSSelectorFromString(_name);
        }

        if (_setter == NULL && _isReadOnly == NO) {
            NSString *name = [NSString stringWithFormat:@"set%@%@:",
                              [_name substringToIndex:1].uppercaseString,
                              [_name substringFromIndex:1]];
            _setter = NSSelectorFromString(name);
        }
    }
    return self;
}

@end
