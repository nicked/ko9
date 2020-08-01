//
//  NSObject+Introspection.h
//
//  Created by Nick Randall on 9/5/20.
//  Copyright © 2020 Nick Randall. All rights reserved.
//


@class ClassProperty;

@interface NSObject (Introspection)
@property (class, readonly) NSArray<ClassProperty *> *classProperties;
@end
