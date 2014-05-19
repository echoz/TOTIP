//
//  TOTIPQueryController.m
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPQueryController.h"
#import "AFNetworking.h"
#import "AFOnoResponseSerializer.h"


NSString *const TOTIPQueryControllerErrorDomain = @"TOTIPQueryControllerErrorDomain";

@implementation TOTIPQueryController

#pragma mark - Object Life Cycle

// no need for checks
-(instancetype)initWithCountry:(TOPTIPCountry *)country type:(TOPTIPMediaType *)type {
    if ((!country) || (!type)) return nil;
    
    if ((self = [super init])) {
        _country = country;
        _type = type;
        _explicitContent = NO;
    }
    return self;
}

#pragma mark - Query

-(void)performQueryForFeedType:(NSString *)feed genre:(NSString *)genre limit:(NSUInteger)limit completion:(void (^)(NSArray *results, NSError *error))completion {
    NSString *urlFormat = [self.type.feedTypesURL objectForKey:feed];
    if (!urlFormat) {
        (completion) ? dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, [NSError errorWithDomain:TOTIPQueryControllerErrorDomain code:TOTIPQueryControllerFeedTypeMismatch userInfo:nil]); }) : nil;
        return;
    }

    NSString *genreParam = ([self.type.genres objectForKey:genre]) ? [NSString stringWithFormat:@"genre=%@", [self.type.genres objectForKey:genre]] : @"";
    NSString *limitParam = [NSString stringWithFormat:@"limit=%@", @((limit > 0)?:1)];
    NSString *explictParam = (self.explicitContent) ? @"explicit=true" : @"";
    
    
}

@end
