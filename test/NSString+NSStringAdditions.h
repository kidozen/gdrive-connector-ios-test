//
//  NSString+NSStringAdditions.h
//  test
//
//  Created by Christian Carnero on 11/14/13.
//  Copyright (c) 2013 Leandro Boffi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringAdditions)
+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;
+ (NSData *) base64DataFromString:(NSString *)string;
+ (NSString *) base64StringFromString:(NSString *)string;
@end
