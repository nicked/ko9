@import Foundation;
@import ObjectiveC.runtime;


typedef NS_ENUM(char, SetterType) {
    Assign, Strong, Weak, Copy
};


@interface ClassProperty : NSObject

@property (nonatomic, readonly) NSString *name;

/// This will be the raw type encoding for now
@property (nonatomic, readonly) NSString *encodeType;

@property (nonatomic, readonly) BOOL isReadOnly;
@property (nonatomic, readonly) BOOL isNonAtomic;
@property (nonatomic, readonly) BOOL isDynamic;
@property (nonatomic, readonly) SetterType setterType;

/// Custom getter or the default getter
@property (nonatomic, readonly) SEL getter;

/// Custom or default setter, NULL if the property is readonly
@property (nonatomic, readonly, nullable) SEL setter;

/// Will be nil if the property is computed or dynamic
@property (nonatomic, readonly, nullable) NSString *ivarName;

- (instancetype)initWithProperty:(objc_property_t)property;

@end
