//
//  OpenCVWrapper.h
//  OpenCVTrackerApp
//
//  Created by Vidur Satija on 04/03/16.
//  Copyright © 2016 Aromatic Studios. All rights reserved.
//

#ifndef OpenCVWrapper_h
#define OpenCVWrapper_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface OpenCVWrapper : NSObject

- (CGPoint)processImageWithOpenCV:(UIImage*)inputImage;

@end

#endif /* OpenCVWrapper_h */
