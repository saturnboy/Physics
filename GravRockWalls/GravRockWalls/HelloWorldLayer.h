//
//  HelloWorldLayer.h
//  GravRockWalls
//
//  Created by Justin Shacklette on 9/6/12.
//  Copyright Saturnboy 2012. All rights reserved.
//

#import "cocos2d.h"
@class Rock;

@interface HelloWorldLayer : CCLayer {
    Rock *_rock;
    CGSize _rocksize;
    CGSize _winsize;
    CCSprite *_arrow;
    CGPoint _accelerometer;
    CGPoint _min;
    CGPoint _max;
}

+(CCScene *) scene;

@end
