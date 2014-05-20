//
//  TOTIPQuery.h
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOTIPCountry.h"
#import "TOTIPMediaType.h"
#import "TOTIPEntry.h"

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

extern NSString *const TOTIPQueryErrorDomain;

typedef NS_ENUM(NSUInteger, TOTIPQueryErrorStatus) {
    TOTIPQueryFeedTypeMismatch,
    TOTIPQueryGenreMismatch
};

@interface TOTIPQuery : NSObject

@property (nonatomic, readonly, copy) NSArray *results;

@property (nonatomic, assign) BOOL explicitContent;
@property (nonatomic, readonly, strong) TOTIPCountry *country;
@property (nonatomic, readonly, strong) TOTIPMediaType *type;

-(instancetype)initWithCountry:(TOTIPCountry *)country type:(TOTIPMediaType *)type;
-(void)performQueryForFeedType:(NSString *)feed genre:(NSString *)genre limit:(NSUInteger)limit completion:(void (^)(NSArray *results, NSError *error))completion;
@end