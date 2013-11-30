//
//  API.m
//  Quiero Besarte
//
//  Created by José Manuel Roldán Marín on 29/11/13.
//  Copyright (c) 2013 José Manuel Roldán Marín. All rights reserved.
//

#import "API.h"

@implementation API

//the web location of the service
NSString *kAPIPathWedding = @"http://quierobesarte.es.nt5.unoeuro-server.com/api/Wedding";
NSString *kAppVersion = @"1.0";

@synthesize idWedding;


#pragma mark - Singleton methods
/**
 * Singleton methods
 */
+(API*)sharedInstance
{
    static API *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}



-(void) login:(NSString*)passWedding onCompletion:(JSONResponseBlock)completionBlock
{
    
    
    NSString *composedURL = [NSString stringWithFormat: @"%@/%@", kAPIPathWedding,passWedding];
    NSLog(@"%@", composedURL);
    NSURL *URL = [NSURL URLWithString:composedURL];
    NSMutableURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    
    // Create a mutable copy of the immutable request and add more headers
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest addValue:kAppVersion forHTTPHeaderField:@"App-Version"];
    
    // Now set our request variable with an (immutable) copy of the altered request
    request = [mutableRequest copy];
    
    // Log the output to make sure our new headers are there
    NSLog(@"%@", request.allHTTPHeaderFields);
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Status Code: %ld", (long)[operation.response statusCode]);
        
        long httpCode = (long)[operation.response statusCode];

        
        NSMutableDictionary *dict = [NSMutableDictionary alloc];
        
        switch (httpCode) {
            case 204:
            {
                dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"204", nil]
                                                                  forKeys:[NSArray arrayWithObjects:@"RESULT", nil]];
                break;
            }
            case 200:
            {
                NSError *error;
                dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                break;
            }
            default:
                break;
        }
        
        completionBlock(dict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSMutableDictionary *dict = [NSMutableDictionary alloc];
        long httpCode  = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
        
        
        switch (httpCode) {
            case 426:
            {
                dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"426", nil]
                                                          forKeys:[NSArray arrayWithObjects:@"RESULT", nil]];
                break;
            }
            
            default:
                dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"404", nil]
                                                          forKeys:[NSArray arrayWithObjects:@"RESULT", nil]];
                break;
        }
        
        completionBlock(dict);        
        
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}



@end
