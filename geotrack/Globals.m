//
//  Globals.m
//  geotrack
//
//  Created by James M. Shin on 8/20/13.
//  Copyright (c) 2013 James M. Shin. All rights reserved.
//

#import "Globals.h"
#import <CommonCrypto/CommonDigest.h>

const double KEEPALIVE_INTERVAL = 530.0;
const double GEOTAG_INTERVAL = 3600.0;
const int ROW_HEIGHT = 100;
const int MAX_QUERY_SIZE = 50;


NSString *md5hash(NSString *str)
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    // get hash string
    CC_MD5(cStr, strlen(cStr), result);
    // return NSString of hexadecimals
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15] ];
}