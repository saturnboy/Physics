//
//  Rock.h
//  GravRockCollisions
//
//  Created by Justin Shacklette on 9/6/12.
//  Copyright __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface Rock : CCSprite {
	CGPoint vel;
    CGPoint acc;
    float radius;
    float mass;
}

@property(nonatomic,assign) CGPoint vel;
@property(nonatomic,assign) CGPoint acc;
@property(nonatomic,assign) float radius;
@property(nonatomic,assign) float mass;

@end
