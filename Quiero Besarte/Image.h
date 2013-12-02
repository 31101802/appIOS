//
//  Image.h
//  Quiero Besarte
//
//  Created by José Manuel Roldán Marín on 01/12/13.
//  Copyright (c) 2013 José Manuel Roldán Marín. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Image : NSObject
// Path for local image
@property (strong, nonatomic) NSString *local_url;
// URL for web image
@property (strong, nonatomic) NSString *web_url;

// URL for web image big
@property (strong, nonatomic) NSString *web_url_big;
@end
