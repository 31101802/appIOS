//
//  ViewerController.h
//  Quiero Besarte
//
//  Created by José Manuel Roldán Marín on 30/11/13.
//  Copyright (c) 2013 José Manuel Roldán Marín. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIIFlowView.h"


@interface ViewerController : UIViewController< IIIFlowViewDelegate>
@property (strong, nonatomic) IIIFlowView *view;

@end
