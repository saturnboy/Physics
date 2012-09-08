//
//  HelloWorldLayer.h
//  GravRockBounce
//
//  Created by Justin Shacklette on 9/6/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
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
