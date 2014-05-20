//
//  TOTIPQuery.m
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPQuery.h"
#import "AFNetworking.h"

NSString *const TOTIPQueryErrorDomain = @"TOTIPQueryErrorDomain";

@implementation TOTIPQuery

#pragma mark - Object Life Cycle

// no need for checks
-(instancetype)initWithCountry:(TOTIPCountry *)country type:(TOTIPMediaType *)type {
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
    NSMutableString *urlFormat = [[self.type.feedTypesURL objectForKey:feed] mutableCopy];
    if (!urlFormat) {
        (completion) ? dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, [NSError errorWithDomain:TOTIPQueryErrorDomain code:TOTIPQueryFeedTypeMismatch userInfo:nil]); }) : nil;
        return;
    }

    [urlFormat replaceOccurrencesOfString:@"<%= country_code %>" withString:self.country.countryCode options:0 range:NSMakeRange(0, [urlFormat length])];
    [urlFormat replaceOccurrencesOfString:@"<%= parameters %>" withString:@"" options:0 range:NSMakeRange(0, [urlFormat length])];
    
    NSString *genreParam = ([self.type.genres objectForKey:genre]) ? [NSString stringWithFormat:@"genre=%@", [self.type.genres objectForKey:genre]] : @"";
    NSString *limitParam = [NSString stringWithFormat:@"limit=%@", @((limit > 0) ? limit : 10)];
    NSString *explictParam = (self.explicitContent) ? @"explicit=true" : @"";
    
    NSMutableString *parameters = [NSMutableString stringWithFormat:@"%@%@", ([genreParam length] > 0) ? @"/" : @"", genreParam];
    [parameters appendFormat:@"/%@", limitParam];
    [parameters appendFormat:@"%@%@", ([explictParam length] > 0) ? @"/" : @"", explictParam];

    NSString *finalURLString = [urlFormat stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/json", parameters]];

    AFHTTPRequestOperation *feedQueryOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:finalURLString]]];
    feedQueryOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [feedQueryOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        id entries = [responseObject valueForKeyPath:@"feed.entry"];
        
        _results = [TOTIPEntry objectsWithJSONArray:([entries isKindOfClass:[NSArray class]]) ? entries : @[entries]];
        (completion) ? dispatch_async(dispatch_get_main_queue(), ^{ completion(self.results, nil); }) : nil;
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        (completion) ? dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, error); }) : nil;
    }];
    feedQueryOperation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [feedQueryOperation start];
    
}

@end
