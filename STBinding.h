//
//  STBinding.h

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

#import <Foundation/Foundation.h>

@interface NSObject (STBinding)

/*
 *	@brief Will bind the property of the receiver to the property of an other object
 *	@param keyPath The property of the receiver to update as soon as the observable one will change
 *	@param observable The object to observe
 *	@param observableKeyPath The property to observe
 *	@param oneWay If oneWay is false, keyPath of the observable object will be binded to keyPath of the receiver
 */
- (void)bindKeyPath:(NSString*)keyPath toObject:(id)observable withKeyPath:(NSString*)observableKeyPath oneWay:(BOOL)oneWay;

/*
 *	@brief Will unbind the keyPath of the receiver
 *	@param keyPath The keyPath to unbind
 */
- (void)unbindKeyPath:(NSString*)keyPath;

/*
 *	@brief Will unbind all the keyPaths of the receiver
 */
- (void)unbindAllKeyPaths;

@end

@interface STBinding : NSObject

/*
 *	@brief Will bind the property of an object to the property of an other one
 *	@param object The object to bind
 *	@param keyPath The property of the object to update as soon as the observable one will change
 *	@param observable The object to observe
 *	@param observableKeyPath The property to observe
 *	@param oneWay If oneWay is false, keyPath of the observable object will be binded to keyPath of the receiver
 */
+ (void)bind:(id)object withKeyPath:(NSString*)keyPath toObject:(id)observable withKeyPath:(NSString*)observableKeyPath oneWay:(BOOL)oneWay;

/*
 *	@brief Will unbind the keyPath of the object
 *	@param object The object to unbind
 *	@param keyPath The keyPath to unbind
 */
+ (void)unbindObject:(id)object withKeyPath:(NSString*)keyPath;

/*
 *	@brief Will unbind all the keyPaths of the object
 */
+ (void)unbindAllKeyPathsOfObject:(id)object;

@end
