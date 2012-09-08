//
//  Rock.h
//  GravRockWalls
//
//  Created by Justin Shacklette on 9/6/12.
//  Copyright Saturnboy. All rights reserved.
//

#import "cocos2d.h"

@interface Rock : CCSprite {
	CGPoint vel;
    CGPoint acc;
}

@property(nonatomic,assign) CGPoint vel;
@property(nonatomic,assign) CGPoint acc;

@end
