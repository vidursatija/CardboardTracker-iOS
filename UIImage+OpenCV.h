//
//  UIImage+OpenCV.h
//  OpenCVTrackerApp
//
//  Created by Vidur Satija on 04/03/16.
//  Copyright © 2016 Aromatic Studios. All rights reserved.
//

#ifndef UIImage_OpenCV_h
#define UIImage_OpenCV_h
#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@interface UIImage (OpenCV)

//cv::Mat to UIImage
+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
- (id)initWithCVMat:(const cv::Mat&)cvMat;

//UIImage to cv::Mat
- (cv::Mat)CVMat;
- (cv::Mat)CVMat3;  // no alpha channel
- (cv::Mat)CVGrayscaleMat;

@end

#endif /* UIImage_OpenCV_h */
