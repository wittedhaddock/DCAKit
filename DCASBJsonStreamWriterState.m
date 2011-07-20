/*
 Copyright (c) 2010, Stig Brautaset.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

   Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   Neither the name of the the author nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "DCASBJsonStreamWriterState.h"
#import "DCASBJsonStreamWriter.h"

#define SINGLETON \
+ (id)sharedInstance { \
    static id state; \
    if (!state) state = [[self alloc] init]; \
    return state; \
}


@implementation DCASBJsonStreamWriterState
+ (id)sharedInstance { return nil; }
- (BOOL)isInvalidState:(DCASBJsonStreamWriter*)writer { return NO; }
- (void)appendSeparator:(DCASBJsonStreamWriter*)writer {}
- (BOOL)expectingKey:(DCASBJsonStreamWriter*)writer { return NO; }
- (void)transitionState:(DCASBJsonStreamWriter *)writer {}
- (void)appendWhitespace:(DCASBJsonStreamWriter*)writer {
	[writer appendBytes:"\n" length:1];
	for (NSUInteger i = 0; i < writer.stateStack.count; i++)
	    [writer appendBytes:"  " length:2];
}
@end

@implementation DCASBJsonStreamWriterStateObjectStart

SINGLETON

- (void)transitionState:(DCASBJsonStreamWriter *)writer {
	writer.state = [DCASBJsonStreamWriterStateObjectValue sharedInstance];
}
- (BOOL)expectingKey:(DCASBJsonStreamWriter *)writer {
	writer.error = @"JSON object key must be string";
	return YES;
}
@end

@implementation DCASBJsonStreamWriterStateObjectKey

SINGLETON

- (void)appendSeparator:(DCASBJsonStreamWriter *)writer {
	[writer appendBytes:"," length:1];
}
@end

@implementation DCASBJsonStreamWriterStateObjectValue

SINGLETON

- (void)appendSeparator:(DCASBJsonStreamWriter *)writer {
	[writer appendBytes:":" length:1];
}
- (void)transitionState:(DCASBJsonStreamWriter *)writer {
    writer.state = [DCASBJsonStreamWriterStateObjectKey sharedInstance];
}
- (void)appendWhitespace:(DCASBJsonStreamWriter *)writer {
	[writer appendBytes:" " length:1];
}
@end

@implementation DCASBJsonStreamWriterStateArrayStart

SINGLETON

- (void)transitionState:(DCASBJsonStreamWriter *)writer {
    writer.state = [DCASBJsonStreamWriterStateArrayValue sharedInstance];
}
@end

@implementation DCASBJsonStreamWriterStateArrayValue

SINGLETON

- (void)appendSeparator:(DCASBJsonStreamWriter *)writer {
	[writer appendBytes:"," length:1];
}
@end

@implementation DCASBJsonStreamWriterStateStart

SINGLETON


- (void)transitionState:(DCASBJsonStreamWriter *)writer {
    writer.state = [DCASBJsonStreamWriterStateComplete sharedInstance];
}
- (void)appendSeparator:(DCASBJsonStreamWriter *)writer {
}
@end

@implementation DCASBJsonStreamWriterStateComplete

SINGLETON

- (BOOL)isInvalidState:(DCASBJsonStreamWriter*)writer {
	writer.error = @"Stream is closed";
	return YES;
}
@end

@implementation DCASBJsonStreamWriterStateError

SINGLETON

@end

