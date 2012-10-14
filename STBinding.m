//
//  STBinding.m

/***********************************************************************************
 *
 * Copyright (c) 2012 Thomas Dupont
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************/

#import "STBinding.h"

@implementation NSObject (STBinding)

- (void)bindKeyPath:(NSString*)keyPath toObject:(id)observable withKeyPath:(NSString*)observableKeyPath oneWay:(BOOL)oneWay
{
	[STBinding bind:self withKeyPath:keyPath toObject:observable withKeyPath:observableKeyPath oneWay:oneWay];
}

- (void)unbindKeyPath:(NSString*)keyPath
{
	[STBinding unbindObject:self withKeyPath:keyPath];
}

- (void)unbindAllKeyPaths
{
	[STBinding unbindAllKeyPathsOfObject:self];
}

@end

@interface STBinding ()

@property (nonatomic, assign) id object;
@property (nonatomic, assign) id observable;
@property (nonatomic, copy) NSString* objectKeyPath;
@property (nonatomic, copy) NSString* observableKeyPath;
@property (nonatomic, assign) BOOL oneWay;

+ (NSMutableDictionary*)bindings;
+ (NSString*)identForObject:(id)object;
+ (void)addBinding:(STBinding*)binding;
+ (void)removeBinding:(STBinding*)binding;
+ (void)removeAllBindingsOfObject:(id)object;
+ (STBinding*)bindingForObject:(id)object keyPath:(NSString*)keyPath;
+ (NSArray*)allBindingsForObject:(id)object;

@end

@implementation STBinding

@synthesize object = _object;
@synthesize observable = _observable;
@synthesize objectKeyPath = _objectKeyPath;
@synthesize observableKeyPath = _observableKeyPath;
@synthesize oneWay = _oneWay;

- (void)dealloc
{
	self.object = nil;
	self.observable = nil;
    self.objectKeyPath = nil;
	self.observableKeyPath = nil;
    [super dealloc];
}

dispatch_queue_t dispatch_get_bindings_queue ()
{
	static dispatch_queue_t gBindingsQueue = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gBindingsQueue = dispatch_queue_create("com.isoftom.bindings", 0);
	});
	return gBindingsQueue;
}

+ (NSMutableDictionary*)bindings
{
	static NSMutableDictionary* bindings = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		bindings = [[NSMutableDictionary alloc] init];
	});
	
	return bindings;
}

+ (NSString*)identForObject:(id)object
{
	return [NSString stringWithFormat:@"%p", object];
}

+ (void)addBinding:(STBinding*)binding
{
	NSString* ident = [STBinding identForObject:binding.object];
	
	dispatch_sync(dispatch_get_bindings_queue(), ^{
		
		NSMutableDictionary* dict = [[STBinding bindings] objectForKey:ident];
		
		if (!dict)
		{
			dict = [[[NSMutableDictionary alloc] init] autorelease];
			[[STBinding bindings] setObject:dict forKey:ident];
		}
		
		[dict setObject:binding forKey:binding.objectKeyPath];
	});
}

+ (void)removeBinding:(STBinding*)binding
{
	NSString* ident = [STBinding identForObject:binding.object];
	
	dispatch_sync(dispatch_get_bindings_queue(), ^{
		
		NSMutableDictionary* dict = [[STBinding bindings] objectForKey:ident];
		[dict removeObjectForKey:binding.objectKeyPath];
		
	});
}

+ (void)removeAllBindingsOfObject:(id)object
{
	NSString* ident = [STBinding identForObject:object];
	
	dispatch_sync(dispatch_get_bindings_queue(), ^{
		
		[[STBinding bindings] removeObjectForKey:ident];
		
	});
}

+ (STBinding*)bindingForObject:(id)object keyPath:(NSString*)keyPath
{
	NSString* ident = [STBinding identForObject:object];
	
	__block STBinding* binding = nil;
	
	dispatch_sync(dispatch_get_bindings_queue(), ^{
		
		NSMutableDictionary* dict = [[STBinding bindings] objectForKey:ident];
		
		if (dict)
		{
			binding = [dict objectForKey:keyPath];
		}
		
	});
	
	return binding;
}

+ (NSArray*)allBindingsForObject:(id)object
{
	NSString* ident = [STBinding identForObject:object];
	
	__block NSArray* array = nil;
	
	dispatch_sync(dispatch_get_bindings_queue(), ^{
		
		NSMutableDictionary* dict = [[STBinding bindings] objectForKey:ident];
		
		if (dict)
		{
			array = [dict allValues];
		}
		
	});
	
	return array;
}

+ (void)bind:(id)object withKeyPath:(NSString*)keyPath toObject:(id)observable withKeyPath:(NSString*)observableKeyPath oneWay:(BOOL)oneWay
{
	STBinding* binding = [[[STBinding alloc] init] autorelease];
	binding.object = object;
	binding.observable = observable;
	binding.objectKeyPath = keyPath;
	binding.observableKeyPath = observableKeyPath;
	binding.oneWay = oneWay;
	
	[STBinding addBinding:binding];
	
	[observable addObserver:binding forKeyPath:observableKeyPath options:NSKeyValueObservingOptionNew context:nil];
	if (!oneWay)
	{
		[object addObserver:binding forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
	}
}

+ (void)unbindObject:(id)object withKeyPath:(NSString*)keyPath
{
	STBinding* binding = [STBinding bindingForObject:object keyPath:keyPath];
	if (!binding.oneWay) [binding.object removeObserver:binding forKeyPath:binding.objectKeyPath];
	[binding.observable removeObserver:binding forKeyPath:binding.observableKeyPath];
	[STBinding removeBinding:binding];
}

+ (void)unbindAllKeyPathsOfObject:(id)object
{
	NSArray* bindings = [STBinding allBindingsForObject:object];
	
	for (STBinding* binding in bindings)
	{
		if (!binding.oneWay) [binding.object removeObserver:binding forKeyPath:binding.objectKeyPath];
		[binding.observable removeObserver:binding forKeyPath:binding.observableKeyPath];
	}
	
	[STBinding removeAllBindingsOfObject:object];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	id toUpdateObject = nil;
	NSString* toUpdateKeyPath = nil;
	BOOL shouldObserve = NO;
	
	if (object == self.object && [keyPath isEqualToString:self.objectKeyPath])
	{
		shouldObserve = YES;
		toUpdateObject = self.observable;
		toUpdateKeyPath = self.observableKeyPath;
	}
	else
	{
		shouldObserve = !self.oneWay;
		toUpdateObject = self.object;
		toUpdateKeyPath = self.objectKeyPath;
	}
	
	if (shouldObserve)
	{
		[toUpdateObject removeObserver:self forKeyPath:toUpdateKeyPath];
	}
	
	[toUpdateObject setValue:[change objectForKey:NSKeyValueChangeNewKey] forKey:toUpdateKeyPath];
	
	if (shouldObserve)
	{
		[toUpdateObject addObserver:self forKeyPath:toUpdateKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	
}

@end
