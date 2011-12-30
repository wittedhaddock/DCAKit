//
//  FormBuilder.m
//  semaps
//
//  Created by Bion Oren on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FormBuilder.h"
#import "UITableView+resize.h"
#import "DCAUILabel.h"

#define VPADDING 10
#define HPADDING 0

@interface FormBuilder ()

@property (nonatomic, strong) NSMutableDictionary *elements;
@property (nonatomic, strong) NSMutableArray *elementOrder;

@end

@implementation FormBuilder
@synthesize view;
@synthesize elements;
@synthesize elementOrder;

- (id)initWithView:(UIView*)newView
{
    if((self = [super init]))
    {
        view = newView;
        self.elements = [[NSMutableDictionary alloc] init];
        self.elementOrder = [[NSMutableArray alloc] init];
        
        width = view.frame.size.width;
        top_padding = VPADDING;
        left_padding = HPADDING;
        bottom_padding = VPADDING;
        right_padding = HPADDING;
        fieldOffset = 145;
        elementPadding = 10;
        height = -1;
    }
    return self;
}

- (void)addObject:(DCAUIView*)obj withName:(NSString*)name {
    [self.elements setObject:obj forKey:name];
    [self.elementOrder addObject:name];
}

- (UIView*)view
{
    if(height < 0)
    {
        height = top_padding;
        int offset = top_padding;
        
        for (NSString *name in elementOrder)
        {
            DCAUILabel *nameField = [DCAUILabel init];
            UILabel *nameLabel = (UILabel*)nameField.field;
            nameLabel.text = name;
            [nameLabel sizeToFit];
            nameLabel.frame = CGRectMake(left_padding, offset, nameLabel.frame.size.width, nameLabel.frame.size.height);
            [view addSubview:nameLabel];
            
            UIView *element = [elements valueForKey:name];
            [element sizeToFit];
            int elementHeight = element.frame.size.height;
            if(elementHeight <= 0)
            {
                elementHeight = nameLabel.frame.size.height;
            }
            element.frame = CGRectMake(fieldOffset, offset, width-(left_padding+fieldOffset+right_padding), elementHeight);
            [view addSubview:element];
            
            offset += (nameLabel.frame.size.height > element.frame.size.height)?nameLabel.frame.size.height:element.frame.size.height;
            offset += elementPadding;
        }
        
        //finally, set the frame
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, height+offset+bottom_padding);
    }
    return view;
}

@end