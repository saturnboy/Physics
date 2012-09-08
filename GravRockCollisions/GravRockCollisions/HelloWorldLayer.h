//
//  HelloWorldLayer.h
//  GravRockCollisions
//
//  Created by Justin Shacklette on 9/6/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"
@class Rock;

@interface HelloWorldLayer : CCLayer {
    CCArray *_rocks;
    CGSize _rocksize;
    CGSize _winsize;
    CCSprite *_arrow;

    CGPoint _accelerometer;
    CGPoint _min;
    CGPoint _max;
    CGRect _bounds;
}

+(CCScene *) scene;

@end
