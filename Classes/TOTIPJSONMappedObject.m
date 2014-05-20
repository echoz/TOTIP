//
//  TOPTIPJSONMappedObject.m
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPJSONMappedObject.h"

@implementation TOTIPJSONMappedObject

+(NSArray *)objectsWithJSONArray:(NSArray *)jsonArray {
    if (!jsonArray) return nil;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[jsonArray count]];
    for (NSDictionary *json in jsonArray)
        [array addObject:[[self class] objectWithJSON:json]];

    return array;
}

+(instancetype)objectWithJSON:(NSDictionary *)json {
    if (!json) return nil;
    
    TOTIPJSONMappedObject *instance = [[[self class] alloc] init];
    [instance updateWithJSON:json];
    return instance;
}

-(void)updateWithJSON:(NSDictionary *)json {
    for (NSString *key in [[self class] mappedProperties]) {
        id JSONValue = [json valueForKeyPath:key];
        if (!JSONValue) continue;
        
        [self setValue:JSONValue forKeyPath:[[self class] mappedProperties][key]];
    }
}

+(NSDictionary *)mappedProperties {
    NSAssert([self class] != [TOTIPJSONMappedObject class], @"I CAN HAZ SUBCLASS?!?!??!?!");
    return nil;
}

@end

id LoadJSONFile(NSString *jsonFileame) {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[libraryPath stringByAppendingPathComponent:jsonFileame]]) return nil;
    NSData *data = [NSData dataWithContentsOfFile:[[libraryPath stringByAppendingPathComponent:@"TOTIP"] stringByAppendingPathComponent:jsonFileame]];
    if (!data) return nil;
    
    NSError *deserializationError = nil;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&deserializationError];
    if (!JSONObject)
        NSLog(@"Unable to deserialize JSON file: %@", deserializationError);
    
    return JSONObject;
}

void WriteJSONFile(id JSONObject, NSString *jsonFilename) {
    NSError *jsonWriteError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:&jsonWriteError];
    if (data) {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [data writeToFile:[[libraryPath stringByAppendingPathComponent:@"TOTIP"] stringByAppendingPathComponent:jsonFilename] atomically:YES];
    } else {
        NSLog(@"Error creating JSON data for writing: %@", jsonWriteError);
    }
}