//
//  HelloWorldLayer.h
//  GravRock
//
//  Created by Justin Shacklette on 8/27/12.
//  Copyright Saturnboy 2012. All rights reserved.
//

#import "cocos2d.h"
@class Rock;

@interface HelloWorldLayer : CCLayer {
    Rock *_rock;
    CGSize _rocksize;
    CGSize _winsize;
}

+(CCScene *) scene;

@end
