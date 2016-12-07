//
//  OpenCVWrapper.m
//  OpenCVTrackerApp
//
//  Created by Vidur Satija on 04/03/16.
//  Copyright © 2016 Aromatic Studios. All rights reserved.
//

//#import <Foundation/Foundation.h>
#include <vector>
#include <algorithm>
#include <iostream>
#include "OpenCVWrapper.h"
#import "UIImage+OpenCV.h"

#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

double dist(cv::Point x, cv::Point y)
{
    return (x.x-y.x)*(x.x-y.x)+(x.y-y.y)*(x.y-y.y);
}

pair<cv::Point,double> circleFromPoints(cv::Point p1, cv::Point p2, cv::Point p3)
{
    double offset = pow(p2.x,2) +pow(p2.y,2);
    double bc =   ( pow(p1.x,2) + pow(p1.y,2) - offset )/2.0;
    double cd =   (offset - pow(p3.x, 2) - pow(p3.y, 2))/2.0;
    double det =  (p1.x - p2.x) * (p2.y - p3.y) - (p2.x - p3.x)* (p1.y - p2.y);
    double TOL = 0.0000001;
    if (abs(det) < TOL) { cout<<""<<endl;return make_pair(cv::Point(0,0),0); }
    
    double idet = 1/det;
    double centerx =  (bc * (p2.y - p3.y) - cd * (p1.y - p2.y)) * idet;
    double centery =  (cd * (p1.x - p2.x) - bc * (p2.x - p3.x)) * idet;
    double radius = sqrt( pow(p2.x - centerx,2) + pow(p2.y-centery,2));
    
    return make_pair(cv::Point(centerx,centery),radius);
}


@implementation OpenCVWrapper : NSObject


- (CGPoint)processImageWithOpenCV:(UIImage*)inputImage {
    Mat frame = [inputImage CVMat];
    
    // do your processing here
    //cout<<"HERE!";
    
    Mat hsv;
    cvtColor(frame, hsv, COLOR_RGB2HSV);
    
    //Scalar low(230, 210, 90);
    //Scalar high(255, 250, 110);
    cv::Mat yellow_hue;
    cv::inRange(hsv, cv::Scalar(24, 120, 200), cv::Scalar(36, 180, 255), yellow_hue);
    //
    
    GaussianBlur(yellow_hue, yellow_hue, cv::Size(5,5), 2);
    
    // Copy masked part to result image
    //frame.copyTo(res, mask);
    
    
    vector<vector<cv::Point> > contours;
    //Get the frame
    
    
    //Find the contours in the foreground
    findContours(yellow_hue,contours,CV_RETR_EXTERNAL,CV_CHAIN_APPROX_NONE);
    
    
    // MOMENTS
    vector<Moments> mu(contours.size() );
    ///  Get the mass centers:
    vector<Point2f> mc( contours.size() );
    
    int i;
    cv::Point rectCenter;

    for(i=0;i<contours.size();i++)
    {
        //if(contourArea(contours[i])>=5000)
        //{
        
            //mu[i] = moments(contours[i], false);
            //mc[i] = Point2f( mu[i].m10/mu[i].m00 , mu[i].m01/mu[i].m00 );
        
        cv::Rect bdRect = boundingRect(contours[i]);
        rectCenter = Point2f(bdRect.x + bdRect.width/2, bdRect.y + bdRect.height/2);
            circle(yellow_hue, rectCenter, 10, Scalar(255, 128,0));
            //cout<<"X :"<<mc[i].x<<" Y :"<<mc[i].y<<"";
            break;
        //}
            
    }
    
    
    return CGPointMake(rectCenter.x, rectCenter.y);
}

@end