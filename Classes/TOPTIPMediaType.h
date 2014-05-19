//
//  TOPTIPMediaType.h
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOPTIPJSONMappedObject.h"

@interface TOPTIPMediaType : TOPTIPJSONMappedObject

@property (nonatomic, copy, readonly) NSString *translationKey;
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *store;

@property (nonatomic, readonly) BOOL canBeExplicit;
@property (nonatomic, strong, readonly) NSDictionary *feedTypesURL;
@property (nonatomic, strong, readonly) NSDictionary *genres;

@end
