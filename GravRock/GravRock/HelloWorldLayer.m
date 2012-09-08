//
//  HelloWorldLayer.m
//  GravRock
//
//  Created by Justin Shacklette on 8/27/12.
//  Copyright Saturnboy 2012. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "Rock.h"

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
        _rock.acc = ccp(0.0f, -250.0f);
        
        // compute rock size
        _rocksize = _rock.boundingBox.size;
        CCLOG(@"rocksize=%.0fx%.0f", _rocksize.width, _rocksize.height);
        
        [self scheduleUpdate];
	}
	return self;
}

- (void) update:(ccTime)dt {
    //CCLOG(@"dt=%.6f",dt);
    
    if (!_rock.visible) return;
    
    //euler
    _rock.position = ccpAdd(_rock.position, ccpMult(_rock.vel, dt));
    _rock.vel = ccpAdd(_rock.vel, ccpMult(_rock.acc, dt));
    
    //nsv
    //_rock.vel = ccpAdd(_rock.vel, ccpMult(_rock.acc, dt));
    //_rock.position = ccpAdd(_rock.position, ccpMult(_rock.vel, dt));
    
    //verlet???
    
    //velocity verlet
    //_rock.position = ccpAdd(ccpAdd(_rock.position, ccpMult(_rock.vel, dt)), ccpMult(_rock.acc, dt*dt));
    //_rock.vel = ccpAdd(_rock.vel, ccpMult(_rock.acc, dt));
    
    
    //CCLOG(@"new: pos(%.3f,%.3f) vel(%.3f,%.3f)", _rock.position.x, _rock.position.y, _rock.vel.x, _rock.vel.y);    
    
    // hide the rock when it falls off the bottom
    if (_rock.position.y < -_rocksize.height) {
        _rock.visible = NO;
        CCLOG(@"hide rock pos (%.0f,%.0f)", _rock.position.x, _rock.position.y);
    }
}

-(void) registerWithTouchDispatcher {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pos = [self convertTouchToNodeSpace:touch];
    CCLOG(@"touch (%.0f,%.0f)", pos.x, pos.y);
    _rock.position = pos;
    _rock.vel = ccp(0.0f,0.0f);
    _rock.visible = YES;
    return YES;
}

- (void) dealloc {
	[super dealloc];
}

@end
