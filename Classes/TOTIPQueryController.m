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

#define URL_COUNTRIES       [NSURL URLWithString:@"http://rss.itunes.apple.com/data/countries.json"]
#define URL_MEDIATYPES      [NSURL URLWithString:@"http://rss.itunes.apple.com/data/media-types.json"]
#define JSON_COUNTRIES      @"countries.json"
#define JSON_MEDIATYPES     @"media-types.json"

@implementation TOTIPQueryController

#pragma mark - Object Life Cycle

-(instancetype)initWithCountry:(NSString *)countryIdentifier type:(NSString *)typeIdentifier {
    return [self initWithCountry:countryIdentifier type:typeIdentifier limit:10];
}

-(instancetype)initWithCountry:(NSString *)countryIdentifier type:(NSString *)typeIdentifier limit:(NSUInteger)limit {
    return [self initWithCountry:countryIdentifier type:typeIdentifier limit:limit genre:nil];
}

-(instancetype)initWithCountry:(NSString *)countryIdentifier type:(NSString *)typeIdentifier limit:(NSUInteger)limit genre:(NSString *)genreIdentifier {
    if ((self = [super init])) {
        _country = countryIdentifier;
        _type = typeIdentifier;
        _limit = limit;
        _genre = genreIdentifier;
    }
    return self;
}

#pragma mark - Statics

static NSArray *__countries = nil;
static NSArray *__mediaTypes = nil;
static dispatch_queue_t queryExecutionQueue;

+(void)initialize {
    __countries = LoadJSONFile(JSON_COUNTRIES);
    __mediaTypes = LoadJSONFile(JSON_MEDIATYPES);
    queryExecutionQueue = dispatch_queue_create("co.lazylabs.TOTIP.query", NULL);
}

static id LoadJSONFile(NSString *jsonFileName) {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[libraryPath stringByAppendingPathComponent:jsonFileName]]) return nil;
    NSData *data = [NSData dataWithContentsOfFile:[libraryPath stringByAppendingPathComponent:jsonFileName]];
    if (!data) return nil;
    
    NSError *deserializationError = nil;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&deserializationError];
    if (!JSONObject)
        NSLog(@"Unable to deserialize JSON file: %@", deserializationError);
    
    return JSONObject;
}

static void WriteJSONFile(id JSONObject, NSString *path) {
    NSError *jsonWriteError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:&jsonWriteError];
    if (data) {
        [data writeToFile:path atomically:YES];
    } else {
        NSLog(@"Error creating JSON data for writing: %@", jsonWriteError);
    }
}

+(NSArray *)countries {
    return __countries;
}

+(NSArray *)mediaTypes {
    return __mediaTypes;
}

+(void)executeQueryWithContextBlock:(void (^)(NSArray *, NSArray *, NSSet *))block {
    if (!block) return;
    
    dispatch_async(queryExecutionQueue, ^{
        if (![[self class] countries])  __countries = LoadJSONFile(JSON_COUNTRIES);
        if (![[self class] mediaTypes]) __mediaTypes = LoadJSONFile(JSON_MEDIATYPES);

        dispatch_group_t networkFetchGroup = dispatch_group_create();
        NSMutableSet *errorSet = [NSMutableSet setWithCapacity:2];
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];

        if ([[self class] countries]) {
            dispatch_group_enter(networkFetchGroup);
            
            AFHTTPRequestOperation *countriesRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:URL_COUNTRIES]];
            countriesRequestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
            [countriesRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                __countries = responseObject;
                WriteJSONFile(__countries, [libraryPath stringByAppendingString:JSON_COUNTRIES]);
                dispatch_group_leave(networkFetchGroup);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [errorSet addObject:error];
                dispatch_group_leave(networkFetchGroup);
            }];
        }
        
        if ([[self class] mediaTypes]) {
            dispatch_group_enter(networkFetchGroup);

            AFHTTPRequestOperation *countriesRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:URL_MEDIATYPES]];
            countriesRequestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
            [countriesRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                __mediaTypes = responseObject;
                WriteJSONFile(__mediaTypes, [libraryPath stringByAppendingString:JSON_MEDIATYPES]);
                dispatch_group_leave(networkFetchGroup);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [errorSet addObject:error];
                dispatch_group_leave(networkFetchGroup);
            }];
        }
        
        dispatch_group_wait(networkFetchGroup, DISPATCH_TIME_FOREVER);
        
        if ([errorSet count] > 0) {
            block(nil, nil, errorSet);
            return;
        }
        
        block(__countries, __mediaTypes, nil);
    });
}

@end
