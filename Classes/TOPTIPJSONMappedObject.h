//
//  TOPTIPJSONMappedObject.h
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

extern id LoadJSONFile(NSString *jsonFilename);
extern void WriteJSONFile(id JSONObject, NSString *jsonFilename);

@interface TOPTIPJSONMappedObject : NSObject

+(NSArray *)objectsWithJSONArray:(NSArray *)jsonArray;
+(instancetype)objectWithJSON:(NSDictionary *)json;
-(void)updateWithJSON:(NSDictionary *)json;
+(NSDictionary *)mappedProperties;

@end
