//
//  NSObject+PropertyAccess.m
//
//  Created by Nick Randall on 14/7/20.
//  Copyright © 2020 Nick Randall. All rights reserved.
//

#import "NSObject+PropertyAccess.h"
#import "ClassProperty.h"
#import "TypeEncoding.h"
@import ObjectiveC.runtime;


@implementation NSObject (PropertyAccess)

- (id)valueForProperty:(NSString *)propertyName {

    objc_property_t prop = class_getProperty(self.class,
                                             propertyName.UTF8String);

    if (prop == NULL) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Can't find property %@.%@",
         NSStringFromClass(self.class), propertyName];
    }

    ClassProperty *property = [[ClassProperty alloc] initWithProperty:prop];

    SEL getter = property.getter;

    IMP imp = class_getMethodImplementation(self.class, getter);

    if (imp == NULL) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Can't find implementation of %@.%@",
                    NSStringFromClass(self.class), propertyName];
    }

    #define RETURN_BOXED(TYPE) {                              \
        TYPE (*getterFunc)(id, SEL) = (TYPE (*)(id, SEL))imp; \
        TYPE val = getterFunc(self, getter);                  \
        return @(val);                                        \
    }

    switch (property.type.type) {
        case TypeChar:              RETURN_BOXED(char)
        case TypeInt:               RETURN_BOXED(int)
        case TypeShort:             RETURN_BOXED(short)
        case TypeLong:              RETURN_BOXED(long)
        case TypeLongLong:          RETURN_BOXED(long long)
        case TypeUnsignedChar:      RETURN_BOXED(unsigned char)
        case TypeUnsignedInt:       RETURN_BOXED(unsigned int)
        case TypeUnsignedShort:     RETURN_BOXED(unsigned short)
        case TypeUnsignedLong:      RETURN_BOXED(unsigned long)
        case TypeUnsignedLongLong:  RETURN_BOXED(unsigned long long)
        case TypeFloat:             RETURN_BOXED(float)
        case TypeDouble:            RETURN_BOXED(double)
        case TypeBool:              RETURN_BOXED(BOOL)
        case TypeObject:
        case TypeClass:
            return ((id (*)(id, SEL))imp)(self, getter);
        case TypeCString:
            RETURN_BOXED(char *)
        case TypeSelector: {
            SEL (*selGetter)(id, SEL) = (SEL (*)(id, SEL))imp;
            SEL sel = selGetter(self, getter);
            return NSStringFromSelector(sel);
        }
        case TypeStruct: {
            // allocate a buffer to hold the return value
            NSMethodSignature *sig = [self methodSignatureForSelector:getter];
            void *buffer = malloc(sig.methodReturnLength);

            // set up and call the invocation
            NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:sig];
            invoc.selector = getter;
            [invoc invokeWithTarget:self];
            [invoc getReturnValue:buffer];

            // box the returned struct
            const char *encoding = property.type.encoding.UTF8String;
            NSValue *val = [NSValue valueWithBytes:buffer objCType:encoding];
            free(buffer);
            return val;
        }
        case TypeVoid:
        case TypeArray:
        case TypeUnion:
        case TypeBitField:
        case TypePointer:
        case TypeUnknown:
        default:
            [NSException raise:NSInvalidArgumentException
                        format:@"Not KVC-compliant: %@.%@",
                        NSStringFromClass(self.class), propertyName];
    }

    return nil;
}



- (void)setValue:(id)value forProperty:(NSString *)propertyName {

    objc_property_t prop = class_getProperty(self.class,
                                             propertyName.UTF8String);

    if (prop == NULL) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Can't find property %@.%@",
                    NSStringFromClass(self.class), propertyName];
    }

    ClassProperty *property = [[ClassProperty alloc] initWithProperty:prop];

    SEL setter = property.setter;

    if (property.isReadOnly || setter == NULL) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Can't set read-only property %@.%@",
                    NSStringFromClass(self.class), propertyName];
    }

    IMP imp = class_getMethodImplementation(self.class, setter);
    if (imp == NULL) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Can't find setter of %@.%@",
                    NSStringFromClass(self.class), propertyName];
    }

    #define SET_UNBOXED(TYPE, METHOD) {                                   \
        void (*setterFunc)(id, SEL, TYPE) = (void (*)(id, SEL, TYPE))imp; \
        setterFunc(self, setter, [value METHOD]);                         \
        break;                                                            \
    }

    switch (property.type.type) {
        case TypeChar:             SET_UNBOXED(char, charValue)
        case TypeInt:              SET_UNBOXED(int, intValue)
        case TypeShort:            SET_UNBOXED(short, shortValue)
        case TypeLong:             SET_UNBOXED(long, longValue)
        case TypeLongLong:         SET_UNBOXED(long long, longLongValue)
        case TypeUnsignedChar:     SET_UNBOXED(unsigned char, unsignedCharValue)
        case TypeUnsignedInt:      SET_UNBOXED(unsigned int, unsignedIntValue)
        case TypeUnsignedShort:    SET_UNBOXED(unsigned short, unsignedShortValue)
        case TypeUnsignedLong:     SET_UNBOXED(unsigned long, unsignedLongValue)
        case TypeUnsignedLongLong: SET_UNBOXED(unsigned long long, unsignedLongLongValue)
        case TypeFloat:            SET_UNBOXED(float, floatValue)
        case TypeDouble:           SET_UNBOXED(double, doubleValue)
        case TypeBool:             SET_UNBOXED(BOOL, boolValue)
        case TypeObject:
        case TypeClass:            SET_UNBOXED(id, self)
        case TypeCString:          SET_UNBOXED(const char *, UTF8String)
        case TypeSelector: {
            void (*setterFunc)(id, SEL, SEL) = (void (*)(id, SEL, SEL))imp;
            setterFunc(self, setter, NSSelectorFromString(value));
            break;
        }
        case TypeStruct: {
            // get the size of the struct parameter
            const char *encoding = property.type.encoding.UTF8String;
            NSUInteger size;
            NSGetSizeAndAlignment(encoding, &size, NULL);

            // allocate a buffer and copy the value into it
            void *buffer = malloc(size);
            [value getValue:buffer size:size];

            // set up and call the invocation
            NSMethodSignature *sig = [self methodSignatureForSelector:setter];
            NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:sig];
            invoc.selector = setter;
            [invoc setArgument:buffer atIndex:2];
            [invoc invokeWithTarget:self];

            free(buffer);
            break;
        }
        case TypeVoid:
        case TypeArray:
        case TypeUnion:
        case TypeBitField:
        case TypePointer:
        case TypeUnknown:
        default:
            [NSException raise:NSInvalidArgumentException
                        format:@"Not KVC-compliant: %@.%@",
                        NSStringFromClass(self.class), propertyName];
    }
}

@end
