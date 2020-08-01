#import "ClassProperty.h"
#import "NSObject+Introspection.h"

@implementation NSObject (Introspection)

+ (NSArray<ClassProperty *> *)classProperties {
    NSMutableArray *clsProps = [NSMutableArray array];
    uint propCount;
    objc_property_t *props = class_copyPropertyList(self.class, &propCount);
    for (uint n = 0; n < propCount; n++) {
        [clsProps addObject:[[ClassProperty alloc] initWithProperty:props[n]]];
    }
    free(props);
    return clsProps;
}

@end
