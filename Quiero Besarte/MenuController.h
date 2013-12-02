//
//  MenuController.h
//  Quiero Besarte
//
//  Created by José Manuel Roldán Marín on 30/11/13.
//  Copyright (c) 2013 José Manuel Roldán Marín. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "Image.h"
#import "MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface MenuController : UIViewController <MWPhotoBrowserDelegate>


@property (nonatomic, strong) NSMutableArray *photos;

@property (atomic, strong) ALAssetsLibrary *assetLibrary;
@property (atomic, strong) NSMutableArray *assets;

- (void)loadAssets;

@end
