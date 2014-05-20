//
//  TOPTIPCountry.h
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPJSONMappedObject.h"

@interface TOTIPCountry : TOTIPJSONMappedObject

@property (nonatomic, copy, readonly) NSString *translationKey;
@property (nonatomic, copy, readonly) NSString *flagIcon;
@property (nonatomic, copy, readonly) NSString *countryCode;
@property (nonatomic, copy, readonly) NSString *language;
@property (nonatomic, copy, readonly) NSString *region;
@property (nonatomic, readonly) BOOL enabled;

@property (nonatomic, readonly) NSSet *stores;

+(NSArray *)availableCountries;
+(void)updateAvailableCountriesWithCompletion:(void (^)(NSArray *countries, NSError *error))completion;
+(void)fetchTranslationDictionaryForLocaleIdentifier:(NSString *)localeIdentifier completion:(void (^)(NSDictionary *translation, NSError *error))completion;

@end
