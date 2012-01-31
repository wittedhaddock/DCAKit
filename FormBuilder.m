//
//  FormBuilder.m
//  semaps
//
//  Created by Bion Oren on 7/29/11.
//  Copyright 2011 DrewCrawfordApps LLC. All rights reserved.
//

#import "FormBuilder.h"

#define TOP(rect) rect.origin.x
#define RIGHT(rect) rect.origin.y
#define BOTTOM(rect) rect.size.width
#define LEFT(rect) rect.size.height

@interface FormBuilder ()

@property (nonatomic, strong) NSMutableArray *elements;

-(void)setup;

@end

@implementation FormBuilder
@synthesize view;
@synthesize width;
@synthesize height;
@synthesize padding;
@synthesize elementPadding;
@synthesize elements;

- (id)init {
    if(self = [super init]) {
        view = [[UIView alloc] init];
        [self setup];
    }
    return self;
}

- (id)initWithView:(UIView*)newView {
    if((self = [super init])) {
        view = newView;
        [self setup];
    }
    return self;
}

- (void)setup {
    self.elements = [[NSMutableArray alloc] init];
    
    self.width = view.frame.size.width;
    self.padding = CGRectMake(10, 0, 10, 0);
    self.elementPadding = CGRectMake(0, 10, 0, 10);
    self.height = view.frame.size.height;
}

- (void)addField:(FormField*)obj {
    [self.elements addObject:obj];
}

- (void)reset {
    [self.elements removeAllObjects];
}

- (void)layout {
    height = TOP(self.padding);
    
    for(FormField *field in self.elements) {
        int xoffset = LEFT(self.padding);
        self.height += TOP(self.elementPadding);
        
        [field layoutInWidth:self.width xoffset:xoffset yoffset:self.height padding:self.padding elementPadding:self.elementPadding];
        if(field.label) {
            [self.view addSubview:field.label];
        }
        [view addSubview:field.field];
        
        self.height += field.field.frame.size.height;
        self.height += BOTTOM(self.elementPadding);
    }
    
    self.height += BOTTOM(self.padding);
    //finally, set the frame
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.width, self.height);
}

@end