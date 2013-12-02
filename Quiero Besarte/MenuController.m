//
//  MenuController.m
//  Quiero Besarte
//
//  Created by José Manuel Roldán Marín on 30/11/13.
//  Copyright (c) 2013 José Manuel Roldán Marín. All rights reserved.
//

#import "MenuController.h"

@interface MenuController ()


@property (strong, nonatomic)NSMutableArray *dataSource;
@property (strong, nonatomic)UIActivityIndicatorView *indicator;

@end




@implementation MenuController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        
        [self loadAssets];
        
    }
    return self;
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

-(IBAction)btnUploadPhotos:(UIButton*)sender
{
    [self takePhoto];
}


-(void)takePhoto {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    
    
    
    [self presentModalViewController:imagePickerController animated:YES];
}

-(IBAction)btnViewPhotos:(UIButton*)sender
{
    
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
            if([jsonObject isEqualToString:@"401"])
            {
                message = @"Esta boda no está activa";
            }
            else
            {
                message = @"Ha habido un error. Disculpe las molestias.";
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
            Image *d;
            self.dataSource = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            
            for (NSDictionary* key in json) {
                
                NSString *imageThumbnailPath = [key objectForKey:@"thumbnailPath"];
                NSString *image = [key objectForKey:@"originalPath"];
                // do stuff
                d = [[Image alloc] init];
                
                imageThumbnailPath = [imageThumbnailPath stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                d.web_url = [NSString stringWithFormat: @"%@%@", kAPIPathGetImagesWedding,imageThumbnailPath];
                
                
                image = [image stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                d.web_url_big =[NSString stringWithFormat: @"%@%@", kAPIPathGetImagesWedding,image];
                [self.dataSource addObject:d];
                
                
                [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:d.web_url_big]]];
                
                
            }
            self.photos = photos;
            // Create browser
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = YES;
            browser.displayNavArrows = NO;
            browser.wantsFullScreenLayout = YES;
            browser.zoomPhotosToFill = YES;
            [browser setCurrentPhotoIndex:0];
            [_indicator stopAnimating];
            // Push
            [self.navigationController pushViewController:browser animated:YES];
            
            // Test reloading of data after delay
            double delayInSeconds = 3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                
                
            });
        }
        
    }];
    
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}


- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %i", index);
}

#pragma mark - Load Assets

- (void)loadAssets {
    
    // Initialise
    self.assets = [NSMutableArray new];
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    NSURL *url = result.defaultRepresentation.url;
                    [_assetLibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset) {
                                       if (asset) {
                                           [self.assets addObject:asset];
                                           if (self.assets.count == 1) {
                                               
                                               // Added first asset so reload data
                                               //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                               
                                           }
                                       }
                                   }
                                  failureBlock:^(NSError *error){
                                      NSLog(@"operation was not successfull!");
                                  }];
                    
                }
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsUsingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
        };
        
        // Process!
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                         usingBlock:assetGroupEnumerator
                                       failureBlock:^(NSError *error) {
                                           NSLog(@"There is an error");
                                       }];
        
    });
    
}

#pragma mark - Image picker delegate methdos
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    // getting an NSString
    NSString *idWedding = [prefs stringForKey:@"idWedding"];
    
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // Resize the image from the camera
	[picker dismissModalViewControllerAnimated:NO];
    
    [[API sharedInstance] upLoadPhoto:idWedding image:image];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:NO];
}



@end
