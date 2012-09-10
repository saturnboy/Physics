//
//  HelloWorldLayer.h
//  CrateStacker
//
//  Created by Justin Shacklette on 9/8/12.
//  Copyright Saturnboy 2012. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

@interface HelloWorldLayer : CCLayer {
    CGSize _winsize;
    b2World *_world;
    GLESDebugDraw *_debug;
}

+(CCScene *) scene;

@end
