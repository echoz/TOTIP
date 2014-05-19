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

extern NSString *const TOTIPQueryControllerErrorDomain;

typedef NS_ENUM(NSUInteger, TOTIPQueryControllerErrorStatus) {
    TOTIPQueryControllerFeedTypeMismatch,
    TOTIPQueryControllerGenreMismatch
};

@interface TOTIPQueryController : NSObject

@property (nonatomic, readonly, copy) NSArray *results;

@property (nonatomic, assign) BOOL explicitContent;
@property (nonatomic, readonly, strong) TOPTIPCountry *country;
@property (nonatomic, readonly, strong) TOPTIPMediaType *type;

-(instancetype)initWithCountry:(TOPTIPCountry *)country type:(TOPTIPMediaType *)type;
-(void)performQueryForFeedType:(NSString *)feed genre:(NSString *)genre limit:(NSUInteger)limit completion:(void (^)(NSArray *results, NSError *error))completion;
@end