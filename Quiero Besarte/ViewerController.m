//
//  ViewerController.m
//  Quiero Besarte
//
//  Created by José Manuel Roldán Marín on 30/11/13.
//  Copyright (c) 2013 José Manuel Roldán Marín. All rights reserved.
//

#import "ViewerController.h"
#import "IIIBaseData.h"
#import "SDImageCache+IIIThumb.h"
#import "API.h"

@interface ViewerController (){
    NSString *_basePath;

}

@property (strong, nonatomic)NSMutableArray *dataSource;
@property (strong, nonatomic)NSMutableArray *dataSourceBig;
@property (strong, nonatomic)NSMutableArray *testA;
@property (strong, nonatomic)NSMutableArray *testB;
@property (strong, nonatomic)UIActivityIndicatorView *indicator;

@end




@implementation ViewerController


@synthesize dataSource = _dataSource, testA;
@synthesize dataSourceBig = _dataSourceBig, testB;

int currentY = 0;

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        
        CGRect f = [UIScreen mainScreen].applicationFrame;
        self.view = [[IIIFlowView alloc] initWithFrame:f];
        self.view.flowDelegate = self;
        
        
        
        //create indicator to show loading...
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_indicator setFrame:self.view.frame];
        
        [_indicator.layer setBackgroundColor:[[UIColor colorWithWhite: 0.0 alpha:0.30] CGColor]];
        [_indicator layer].cornerRadius = 8.0;
        [_indicator layer].masksToBounds = YES;
        _indicator.transform = CGAffineTransformMakeScale(1.75, 1.75);
        _indicator.center = self.view.center;
        [self.view addSubview:_indicator];
        [_indicator bringSubviewToFront:self.view];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
        [_indicator startAnimating];
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        // getting an NSString
        NSString *idWedding = [prefs stringForKey:@"idWedding"];
        
        
        
        [[API sharedInstance] getImages:idWedding onCompletion:^(NSDictionary *json) {
            //handle the response
            
            //if json has just one value, some problem...
            if([json count] == 1)
            {
                NSString *jsonObject = [json objectForKey: @"RESULT"];
                NSString *message;
                if([jsonObject isEqualToString:@"426"])
                {
                    message = @"Por favor actualice la aplicación en la Apple Store";
                }
                else
                {
                    message = @"Ha habido un error. Disculpe las molestias";
                }
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Información"
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
            }
            //Everything was fine
            else
            {
                NSString *kAPIPathGetImagesWedding = @"http://quierobesarte.es.nt5.unoeuro-server.com";
                IIIBaseData *d;
                self.dataSource = [NSMutableArray arrayWithCapacity:0];
                self.dataSourceBig = [NSMutableArray arrayWithCapacity:0];
                
                for (NSDictionary* key in json) {
                    
                        NSString *imageThumbnailPath = [key objectForKey:@"thumbnailPath"];
                        NSString *image = [key objectForKey:@"originalPath"];
                        // do stuff
                        d = [[IIIBaseData alloc] init];
                    
                        imageThumbnailPath = [imageThumbnailPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        d.web_url = [NSString stringWithFormat: @"%@%@", kAPIPathGetImagesWedding,imageThumbnailPath];
                        [self.dataSource addObject:d];
                    
                        image = [image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        d.web_url =[NSString stringWithFormat: @"%@%@", kAPIPathGetImagesWedding,image];
                        NSLog(@"JSON: %@",d.web_url);
                        [self.dataSourceBig addObject:d];
                    
                
                }
                
                    
                
                
                [_indicator stopAnimating];

            }
            
            
            //NSLog(@"JSON: %@", [json description]);
            
        }];
        
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    
    [super viewDidAppear:animated];
    [self.view reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IIIFlowView delegate required methods

- (NSInteger)numberOfColumns {
    return 3;
}


- (NSInteger)numberOfCells {
    return self.dataSource.count;
}


- (CGFloat)rateOfCache {
    return 10.0f;
}


- (IIIFlowCell *)flowView:(IIIFlowView *)flow cellAtIndex:(int)index {
    NSString *reuseId = @"CommonCell";
    IIIFlowCell *cell = [flow dequeueReusableCellWithId:reuseId];
    if (!cell) {
        cell = [[IIIFlowCell alloc] initWithReuseId:reuseId];
    }
    return cell;
}

- (IIIBaseData *)dataSourceAtIndex:(int)index {
    return [self.dataSource objectAtIndex:index];
}


#pragma mark - Optional IIIFlowView delegate methods

- (void)didSelectCellAtIndex:(int)index {
    
    if(index > 0)
    {
        
        UIImage *img;
        IIIBaseData *d = [self.dataSourceBig objectAtIndex:index];
        img = [[SDImageCache sharedThumbImageCache] imageFromKey:d.local_url];
        if (!img) {
            img = [[SDImageCache sharedThumbImageCache] imageFromKey:d.web_url];
        }
        if (img) {
            CGRect f = [UIScreen mainScreen].applicationFrame;
            UIViewController *c = [[UIViewController alloc] init];
            c.view.frame = (CGRect){{0, 0}, f.size};
            UIScrollView *sv = [[UIScrollView alloc] initWithFrame:(CGRect){{0, 0}, f.size}];
            [c.view addSubview:sv];
            UIImageView *iv = [[UIImageView alloc] initWithImage:img];
            [sv addSubview:iv];
            iv.frame = CGRectMake(0, 0, f.size.width, f.size.width * img.size.height / img.size.width);
            [sv setContentSize:CGSizeMake(iv.frame.size.width, iv.frame.size.height+self.navigationController.navigationBar.bounds.size.height)];
            [self.navigationController pushViewController:c animated:YES];
        }
    }
}

// optional
- (void)didDownloadedImage:(UIImage *)image atIndex:(int)index {
    IIIBaseData *d = [self.dataSource objectAtIndex:index];
    d.local_url = [_basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_web.jpg", index+1]];
    NSData *imgData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
    NSError *err;
    [imgData writeToFile:d.local_url options:NSDataWritingAtomic error:&err];
    if (err) {
        NSLog(@"Write image to file error: %@\nindex:%i", err.localizedDescription, index);
        d.local_url = nil;
    }
}


@end
