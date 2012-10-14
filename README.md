STBinding
=========

Bring OS X Bindings back to iOS

This class allow you to bind properties of objects.

## Example

    [myObject bindKeyPath:@"myProperty" toObject:otherObject withKeyPath:@"otherProperty" oneWay:YES];

With this example, myProperty of myObject will be automatically updated as soon as otherProperty of otherObject will change.