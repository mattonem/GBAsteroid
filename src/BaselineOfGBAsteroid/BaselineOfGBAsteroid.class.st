Class {
	#name : 'BaselineOfGBAsteroid',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGBAsteroid',
	#package : 'BaselineOfGBAsteroid'
}

{ #category : 'baselines' }
BaselineOfGBAsteroid >> baseline: spec [

	<baseline>
	spec for: #common do: [

		spec
			baseline: 'WCGamebox'
			with: [ spec repository: 'github://mattonem/WCGamebox' ].

		spec package: #GBAsteroid with: [ spec requires: #( WCGamebox ) ] ]
]
