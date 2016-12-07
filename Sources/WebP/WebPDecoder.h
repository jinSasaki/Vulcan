//
//  WebPDecoder.h
//
//  Created by Jin Sasaki on 2016/11/04.
//  Copyright © 2016年 Sasakky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebPDecoder : NSObject
+ (nullable UIImage *)decode:(nullable NSData *)data;
@end
