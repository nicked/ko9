//
//  TypeEncoding.h
//
//  Created by Nick Randall on 21/5/20.
//  Copyright © 2020 Nick Randall. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(unichar, EncodedType) {
    TypeChar              = 'c',
    TypeInt               = 'i',
    TypeShort             = 's',
    TypeLong              = 'l',  // note long encodes to q on 64 bit
    TypeLongLong          = 'q',
    TypeUnsignedChar      = 'C',
    TypeUnsignedInt       = 'I',
    TypeUnsignedShort     = 'S',
    TypeUnsignedLong      = 'L',
    TypeUnsignedLongLong  = 'Q',
    TypeFloat             = 'f',
    TypeDouble            = 'd',
    TypeBool              = 'B',  // note, BOOL encodes to c on 64 bit
    TypeVoid              = 'v',
    TypeCString           = '*',
    TypeObject            = '@',
    TypeClass             = '#',
    TypeSelector          = ':',
    TypeArray             = '[',
    TypeStruct            = '{',
    TypeUnion             = '(',
    TypeBitField          = 'b',
    TypePointer           = '^',
    TypeUnknown           = '?',
};

NS_ASSUME_NONNULL_BEGIN

@interface TypeEncoding : NSObject

@property (nonatomic, readonly) EncodedType type;

/// The raw type encoding
@property (nonatomic, readonly, copy) NSString *encoding;

/// If the type is either an object, a Class type, or a block
@property (nonatomic, readonly) BOOL isObjectType;

/// If the type is float or double
@property (nonatomic, readonly) BOOL isFloatType;

/// If the type is a signed or unsigned integer of any size
@property (nonatomic, readonly) BOOL isIntType;

/// The class of the object type. Nil for anything except TypeObject.
@property (nonatomic, readonly, nullable) Class classType;

- (instancetype)initWithEncoding:(NSString *)encoding;

@end

NS_ASSUME_NONNULL_END
