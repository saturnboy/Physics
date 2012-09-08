//
//  HelloWorldLayer.m
//  GravRockBounce
//
//  Created by Justin Shacklette on 9/6/12.
//  Copyright Saturnboy 2012. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "Rock.h"

#define PX_TO_M (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 50 : 25)
#define BOUNCE_RESTITUTION 1.0f

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
        
        // compute window size
		_winsize = [[CCDirector sharedDirector] winSize];
        CCLOG(@"winsize=%.0fx%.0f", _winsize.width, _winsize.height);
        
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
        
        // init rock
        _rock = [Rock spriteWithSpriteFrameName:@"giantrock.png"];
        _rock.position = ccp(_winsize.width/2, _winsize.height/2);
        [self addChild:_rock z:1 tag:123];
        
        // init rock acceleration
        _rock.acc = ccp(0, -10.0f * PX_TO_M);
        
        // compute rock size
        _rocksize = _rock.boundingBox.size;
        CCLOG(@"rocksize=%.0fx%.0f", _rocksize.width, _rocksize.height);
        
        [self scheduleUpdate];
	}
	return self;
}

- (void) update:(ccTime)dt {    
    //velocity verlet
    _rock.position = ccpAdd(ccpAdd(_rock.position, ccpMult(_rock.vel, dt)), ccpMult(_rock.acc, dt*dt));
    _rock.vel = ccpAdd(_rock.vel, ccpMult(_rock.acc, dt));

    // bounce the rock
    if (_rock.position.y < _rocksize.height/2) {
        _rock.position = ccp(_rock.position.x, _rocksize.height - _rock.position.y);
        _rock.vel = ccp(_rock.vel.x, -_rock.vel.y * BOUNCE_RESTITUTION);
    }
}

-(void) registerWithTouchDispatcher {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pos = [self convertTouchToNodeSpace:touch];
    CCLOG(@"touch (%.0f,%.0f)", pos.x, pos.y);
    _rock.position = pos;
    _rock.vel = ccp(0,0);
    return YES;
}

- (void) dealloc {
	[super dealloc];
}

@end
