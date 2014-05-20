//
//  TOPTIPMediaType.m
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPMediaType.h"
#import "AFNetworking.h"

#define URL_MEDIATYPES      [NSURL URLWithString:@"http://rss.itunes.apple.com/data/media-types.json"]
#define JSON_MEDIATYPES     @"media-types.json"

@interface TOTIPMediaType ()
@property (nonatomic, copy) NSString *translationKey;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *store;

@end

@implementation TOTIPMediaType

-(void)updateWithJSON:(NSDictionary *)json {
    [super updateWithJSON:json];
    
    _canBeExplicit = [[json valueForKeyPath:@"canBeExplicit"] boolValue];
    
    NSArray *feedTypes = [json valueForKeyPath:@"feed_types"];
    NSMutableDictionary *feedTypesMap = [NSMutableDictionary dictionaryWithCapacity:[feedTypes count]];
    for (NSDictionary *feed in feedTypes)
        [feedTypesMap setObject:[feed valueForKeyPath:@"urlPrefix"] forKey:[feed valueForKeyPath:@"translation_key"]];

    _feedTypesURL = feedTypesMap;
    
    NSArray *subgenres = [json valueForKeyPath:@"subgenres"];
    NSMutableDictionary *genres = [NSMutableDictionary dictionaryWithCapacity:[subgenres count]];
    for (NSDictionary *genre in subgenres)
        [genres setObject:[genre valueForKeyPath:@"id"] forKey:[genre valueForKeyPath:@"translation_key"]];
    
    _genres = genres;
}

+(NSDictionary *)mappedProperties {
    return @{@"store":              @"store",
             @"id":                 @"identifier",
             @"translation_key":    @"translationKey"};
}

#pragma mark - Static

static NSArray *__mediaTypes = nil;
static dispatch_queue_t mediaTypesUpdateQueue;

+(void)load {
    __mediaTypes = [TOTIPMediaType objectsWithJSONArray:LoadJSONFile(JSON_MEDIATYPES)];
    mediaTypesUpdateQueue = dispatch_queue_create("co.lazylabs.TOTIP.media-types", NULL);
}

+(NSArray *)availableMediaTypes {
    return __mediaTypes;
}

+(void)updateAvailableMediaTypesWithCompletion:(void (^)(NSArray *, NSError *))completion {
    AFHTTPRequestOperation *mediaTypesRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:URL_MEDIATYPES]];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"application/json", @"text/json", @"text/javascript", nil];

    mediaTypesRequestOperation.responseSerializer = responseSerializer;
    [mediaTypesRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        __mediaTypes = [TOTIPMediaType objectsWithJSONArray:responseObject];
        WriteJSONFile(responseObject, JSON_MEDIATYPES);
        (completion) ? dispatch_async(dispatch_get_main_queue(), ^{ completion(__mediaTypes, nil); }) : nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        (completion) ? dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, error); }) : nil;
    }];
    mediaTypesRequestOperation.completionQueue = mediaTypesUpdateQueue;
    [mediaTypesRequestOperation start];
}

+(void)fetchTranslationDictionaryForLocaleIdentifier:(NSString *)localeIdentifier completion:(void (^)(NSDictionary *, NSError *))completion {
    NSURL *translationKeyURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://rss.itunes.apple.com/data/lang/%@/media-types.json?_=%.0f", localeIdentifier, [[NSDate date] timeIntervalSince1970]]];
    AFHTTPRequestOperation *translationDictionaryOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:translationKeyURL]];
    translationDictionaryOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    translationDictionaryOperation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];
    
    [translationDictionaryOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        (completion) ? dispatch_async(dispatch_get_main_queue(), ^{ completion(responseObject, nil); }) : nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        (completion) ? dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, error); }) : nil;
    }];
    translationDictionaryOperation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [translationDictionaryOperation start];

}

@end
