//
//  TOPTIPJSONMappedObject.m
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOPTIPJSONMappedObject.h"

@implementation TOPTIPJSONMappedObject

+(NSArray *)objectsWithJSONArray:(NSArray *)jsonArray {
    if (!jsonArray) return nil;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[jsonArray count]];
    for (NSDictionary *json in jsonArray)
        [array addObject:[[self class] objectWithJSON:json]];

    return array;
}

+(instancetype)objectWithJSON:(NSDictionary *)json {
    if (!json) return nil;
    
    TOPTIPJSONMappedObject *instance = [[[self class] alloc] init];
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
    NSAssert([self class] != [TOPTIPJSONMappedObject class], @"I CAN HAZ SUBCLASS?!?!??!?!");
    return nil;
}

@end
