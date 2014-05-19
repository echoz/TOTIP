//
//  TOTIPQueryController.h
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOPTIPCountry.h"
#import "TOPTIPMediaType.h"

// Common:
// rss.itunes.apple.com/data/common.json common data structures
// rss.itunes.apple.com/data/countries.json for country specific localized content
// rss.itunes.apple.com/data/media-types.json for all available media types for query builder
// store = yes and the assocaited store for media types determins which media types are available.

// Language localizations (use "language" key from countries.json):
// ?_=<unix epoch>
// rss.itunes.apple.com/data/lang/en-US/media-types.json
// rss.itunes.apple.com/data/lang/en-US/common.json

// store localization in Library/Localization/<language>/
// store normal default

@interface TOTIPQueryController : NSObject

@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic, copy) NSString *type;
@property (nonatomic) NSUInteger limit;

-(instancetype)initWithCountry:(NSString *)countryIdentifier type:(NSString *)typeIdentifier;
-(instancetype)initWithCountry:(NSString *)countryIdentifier type:(NSString *)typeIdentifier limit:(NSUInteger)limit;
-(instancetype)initWithCountry:(NSString *)countryIdentifier type:(NSString *)typeIdentifier limit:(NSUInteger)limit genre:(NSString *)genreIdentifier;

+(NSArray *)countries;
+(NSArray *)mediaTypes;
+(void)executeWithContextBlock:(void (^)(NSArray *countries, NSArray *mediaTypes, NSSet *errorSet))block;

@end