//
//  DictionaryBackedObject.m
//
//  Created by Nick Randall on 16/5/21.
//  Copyright © 2021 Nick Randall. All rights reserved.
//

#import "DictionaryBackedObject.h"
#import "ClassProperty.h"
#import "NSObject+Introspection.h"
#import "TypeEncoding.h"

@interface DictionaryBackedObject ()
// internal storage for properties
@property (nonatomic) NSMutableDictionary *storage;
@end


@implementation DictionaryBackedObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _storage = [NSMutableDictionary dictionary];
    }
    return self;
}


+ (BOOL)resolveInstanceMethod:(SEL)sel {
    ClassProperty *prop = [self propertyForSelector:sel];
    if (prop == nil) {
        NSLog(@"Couldn't resolve method for selector %@",
              NSStringFromSelector(sel));
        return NO;
    }

    BOOL isGetter = (sel == prop.getter);

    id block = [self blockForAccessor:prop isGetter:isGetter];
    if (block == nil) {
        NSLog(@"Couldn't implement method for selector %@",
              NSStringFromSelector(sel));
        return NO;
    }

    NSString *typeEncoding = isGetter
        ? [prop.type.encoding stringByAppendingString:@"@:"]
        : [@"v@:" stringByAppendingString:prop.type.encoding];

    IMP imp = imp_implementationWithBlock(block);
    NSLog(@"Adding method [%@ %@]", NSStringFromClass(self), NSStringFromSelector(sel));

    return class_addMethod(self, sel, imp, typeEncoding.UTF8String);
}


+ (nullable ClassProperty *)propertyForSelector:(SEL)sel {
    for (ClassProperty *prop in self.classProperties) {
        if (sel == prop.getter || sel == prop.setter) {
            return prop;
        }
    }
    return nil;
}


#define GETTER_BLOCK(UNBOX_METHOD)          \
    (id)^(DictionaryBackedObject *self) {   \
        id val = self.storage[prop.name];   \
        return [val UNBOX_METHOD];          \
    }

#define SETTER_BLOCK(BOXABLE_TYPE)          \
    (id)^(DictionaryBackedObject *self, BOXABLE_TYPE val) {  \
        self.storage[prop.name] = @(val);   \
    }

#define ACCESSOR_BLOCK(GETTER, TYPE, UNBOX) \
    GETTER? GETTER_BLOCK(UNBOX) : SETTER_BLOCK(TYPE)

+ (nullable id)blockForAccessor:(ClassProperty *)prop isGetter:(BOOL)isGetter {
    switch (prop.type.type) {
        case TypeChar:
            return ACCESSOR_BLOCK(isGetter, char, charValue);
        case TypeInt:
            return ACCESSOR_BLOCK(isGetter, int, intValue);
        case TypeShort:
            return ACCESSOR_BLOCK(isGetter, short, shortValue);
        case TypeLong:
            return ACCESSOR_BLOCK(isGetter, long, longValue);
        case TypeLongLong:
            return ACCESSOR_BLOCK(isGetter, long long, longLongValue);
        case TypeUnsignedChar:
            return ACCESSOR_BLOCK(isGetter, unsigned char, unsignedCharValue);
        case TypeUnsignedInt:
            return ACCESSOR_BLOCK(isGetter, unsigned int, unsignedIntValue);
        case TypeUnsignedShort:
            return ACCESSOR_BLOCK(isGetter, unsigned short, unsignedShortValue);
        case TypeUnsignedLong:
            return ACCESSOR_BLOCK(isGetter, unsigned long, unsignedLongValue);
        case TypeUnsignedLongLong:
            return ACCESSOR_BLOCK(isGetter, unsigned long long, unsignedLongLongValue);
        case TypeFloat:
            return ACCESSOR_BLOCK(isGetter, float, floatValue);
        case TypeDouble:
            return ACCESSOR_BLOCK(isGetter, double, doubleValue);
        case TypeBool:
            return ACCESSOR_BLOCK(isGetter, BOOL, boolValue);
        case TypeObject:
        case TypeClass:
            return isGetter? GETTER_BLOCK(self) : (id)^(DictionaryBackedObject *self, id val) {
                self.storage[prop.name] = val;
            };
        case TypeCString:
            return ACCESSOR_BLOCK(isGetter, const char *, UTF8String);
        case TypeSelector:
            return isGetter?
            (id)^(DictionaryBackedObject *self) {
                id val = self.storage[prop.name];
                return val? NSSelectorFromString(val) : nil;
            }
            : (id)^(DictionaryBackedObject *self, SEL val) {
                self.storage[prop.name] = val? NSStringFromSelector(val) : nil;
            };
        case TypeVoid:
        case TypeArray:
        case TypeStruct:
        case TypeUnion:
        case TypeBitField:
        case TypePointer:
        case TypeUnknown:
        default:
            return nil;
    }
}

@end
