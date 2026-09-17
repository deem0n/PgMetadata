initialize-release
initialize
	super initialize.
	self arguments: OrderedCollection new.
	self dependencies: Set new.