//
//  API.h
//  Quiero Besarte
//
//  Created by José Manuel Roldán Marín on 29/11/13.
//  Copyright (c) 2013 José Manuel Roldán Marín. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
@interface API : AFHTTPRequestOperationManager

//API call completion block with result as json
typedef void (^JSONResponseBlock)(NSDictionary* json);

//the authorized user
@property (strong, nonatomic) NSDictionary* idWedding;
+(API*)sharedInstance;

//check whether there's an authorized user
-(void)login:(NSString*)passWedding onCompletion:(JSONResponseBlock)completionBlock;
-(void)getImages:(NSString*)passWedding onCompletion:(JSONResponseBlock)completionBlock;

@end
