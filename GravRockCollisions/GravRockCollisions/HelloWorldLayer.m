//
//  HelloWorldLayer.m
//  GravRockCollisions
//
//  Created by Justin Shacklette on 9/6/12.
//  Copyright Saturnboy 2012. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "Rock.h"

#define PX_TO_M (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 50 : 25)
#define BOUNCE_RESTITUTION 0.5f
#define ACCELEROMETER_INTERP_FACTOR 0.1f
#define MAX_ROCKS 20

#pragma mark - HelloWorldLayer

@implementation HelloWorldLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init {
	if( (self=[super init]) ) {
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = YES;
        
        // compute window size
		_winsize = [[CCDirector sharedDirector] winSize];
        CCLOG(@"window : size=%.0fx%.0f", _winsize.width, _winsize.height);
        
        // compute texture filename
        NSString *texturePlist = @"tex.plist";
        NSString *textureFile = @"tex.png";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            texturePlist = @"tex-hd.plist";
            textureFile = @"tex-hd.png";
        }
        
        // load texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:texturePlist];
        CCSpriteBatchNode *sheet = [CCSpriteBatchNode batchNodeWithFile:textureFile];
        [self addChild:sheet];
        
        // init rocks array
        _rocks = [[CCArray alloc] initWithCapacity:MAX_ROCKS];    
        
        // init rock
        Rock *rock = [self makeRock:ccp(0,0)];
        _rocksize = rock.boundingBox.size;
        CCLOG(@"rock : size=%.0fx%.0f", _rocksize.width, _rocksize.height);
        
        // compute rock bounds on screen
        _min = ccp(_rocksize.width/2, _rocksize.height/2);
        _max = ccpSub(ccpFromSize(_winsize), _min);
        _bounds = CGRectMake(_min.x, _min.y, _max.x-_min.x, _max.y-_min.y);
        
        // init arrow
        _arrow = [CCSprite spriteWithSpriteFrameName:@"arrow.png"];
        _arrow.position = ccp(_winsize.width/2, _winsize.height/2);
        _arrow.anchorPoint = ccp(0.25f,0.5f);
        [self addChild:_arrow z:2 tag:234];

        [self scheduleUpdate];
	}
	return self;
}

- (void) update:(ccTime)dt {
    Rock *rock;
    int i = 0;
    CCARRAY_FOREACH(_rocks, rock) {
        // velocity verlet
        rock.position = ccpAdd(ccpAdd(rock.position, ccpMult(rock.vel, dt)), ccpMult(rock.acc, dt*dt));
        rock.vel = ccpAdd(rock.vel, ccpMult(rock.acc, dt));

        // bounce the rock off the walls
        if (rock.position.y < _min.y) {
            rock.position = ccp(rock.position.x, _min.y);
            rock.vel = ccp(rock.vel.x, -rock.vel.y * BOUNCE_RESTITUTION);
        }
        if (rock.position.y > _max.y) {
            rock.position = ccp(rock.position.x, _max.y);
            rock.vel = ccp(rock.vel.x, -rock.vel.y * BOUNCE_RESTITUTION); 
        }
        if (rock.position.x < _min.x) {
            rock.position = ccp(_min.x, rock.position.y); 
            rock.vel = ccp(-rock.vel.x * BOUNCE_RESTITUTION, rock.vel.y); 
        }
        if (rock.position.x > _max.x) {
            rock.position = ccp(_max.x, rock.position.y); 
            rock.vel = ccp(-rock.vel.x * BOUNCE_RESTITUTION, rock.vel.y);
        }
        
        // collide with other rocks
        for (int j = i + 1; j < _rocks.count; j++) {
            Rock *rock2 = [_rocks objectAtIndex:j];
            
            CGPoint delta = ccpSub(rock.position, rock2.position);
            
            // assume rocks are circles to make collision math easy
            float collisionDistSQ = (rock.radius + rock2.radius) * (rock.radius + rock2.radius);
            float distSQ = ccpDot(delta, delta);
            //CCLOG(@"before pos: (%.3f,%.3f) (%.3f,%.3f)",rock.position.x,rock.position.y,rock2.position.x,rock2.position.y);                       
            //CCLOG(@"before vel: (%.3f,%.3f) (%.3f,%.3f)",rock.vel.x,rock.vel.y,rock2.vel.x,rock2.vel.y);
            if (distSQ <= collisionDistSQ) {  
                // compute separation vector -- distance need to push rocks appart
                float d = ccpLength(delta);
                CGPoint sep = ccpMult(delta, ((rock.radius + rock2.radius) - d)/d);
                
                // compute sum of masses
                float sum = rock.mass + rock2.mass;
                
                // pull both rocks apart weighted by their mass
                rock.position = ccpAdd(rock.position, ccpMult(sep, rock2.mass / sum));
                rock2.position = ccpSub(rock2.position, ccpMult(sep, rock.mass / sum));
                
                // compute normal unit and tangential unit vectors
                CGPoint normUnit = ccpNormalize(sep);
                CGPoint tanUnit = ccpPerp(normUnit);
                
                // project v1 & v2 into normal & tangential space
                CGPoint v = ccp(ccpDot(normUnit, rock.vel), ccpDot(tanUnit, rock.vel));
                CGPoint v2 = ccp(ccpDot(normUnit, rock2.vel), ccpDot(tanUnit, rock2.vel));
                
                // tangential is preserved, normal is elastic collision
                CGPoint vFinal = ccp( (BOUNCE_RESTITUTION * rock2.mass * (v2.x - v.x) + rock.mass * v.x + rock2.mass * v2.x) / sum, v.y);
                CGPoint v2Final = ccp( (BOUNCE_RESTITUTION * rock.mass * (v.x - v2.x) + rock.mass * v.x + rock2.mass * v2.x) / sum, v2.y);
                
                // project back to real space
                CGPoint vBackN = ccpMult(normUnit, vFinal.x);
                CGPoint vBackT = ccpMult(tanUnit, vFinal.y);
                CGPoint v2BackN = ccpMult(normUnit, v2Final.x);
                CGPoint v2BackT = ccpMult(tanUnit, v2Final.y);
                
                // sum Normal + Tangential velocities to get the final velocity
                rock.vel = ccpAdd(vBackN, vBackT);
                rock2.vel = ccpAdd(v2BackN, v2BackT);
            }
            
            //CCLOG(@"after pos: (%.3f,%.3f) (%.3f,%.3f)",rock.position.x,rock.position.y,rock2.position.x,rock2.position.y);                       
            //CCLOG(@"after vel: (%.3f,%.3f) (%.3f,%.3f)",rock.vel.x,rock.vel.y,rock2.vel.x,rock2.vel.y);
        }
        
        i++;
    }
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {    
    _accelerometer = ccpLerp(_accelerometer, ccp(-acceleration.x, -acceleration.y), ACCELEROMETER_INTERP_FACTOR);
    float angle = -CC_RADIANS_TO_DEGREES(ccpToAngle(_accelerometer));
    CCLOG(@"ang=%.3f mag=%.5f", angle, ccpLength(_accelerometer));
    
    // rotate arrow
    _arrow.rotation = angle + 180.0f;

    // update gravity on each rock
    CGPoint grav = ccpMult(_accelerometer, -10.0f * PX_TO_M);
    Rock *rock;
    CCARRAY_FOREACH(_rocks, rock) {
        rock.acc = grav;
    }
}

-(void) registerWithTouchDispatcher {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pos = [self convertTouchToNodeSpace:touch];
    CCLOG(@"touch (%.0f,%.0f)", pos.x, pos.y);
    
    // add rock to world
    if (_rocks.count < MAX_ROCKS && CGRectContainsPoint(_bounds, pos)) {
        Rock *rock = [self makeRock:pos];
        [self addChild:rock z:1 tag:100 + _rocks.count];
        
        [_rocks addObject:rock];
        CCLOG(@"add rock #%d", _rocks.count);
    }
    
    return YES;
}

-(Rock *) makeRock:(CGPoint)pos {
    Rock *rock = [Rock spriteWithSpriteFrameName:@"rock.png"];
    rock.position = pos;
    rock.vel = ccp(0,0);
    rock.acc = ccp(0,0);
    rock.mass = 1.0f;
    rock.radius = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1 : 0.5) * _rocksize.width;
    return rock;
}

- (void) dealloc {
    [_rocks release]; _rocks = nil;
	[super dealloc];
}

@end
