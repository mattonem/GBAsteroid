Class {
	#name : 'GBAstVessel',
	#superclass : 'GBNode',
	#instVars : [
		'position',
		'angle',
		'vesselPolygone',
		'flames'
	],
	#pools : [
		'PjDomGlobals'
	],
	#category : 'GBAsteroid',
	#package : 'GBAsteroid'
}

{ #category : 'adding' }
GBAstVessel >> angularSpeed [

	^ 0.05
]

{ #category : 'adding' }
GBAstVessel >> initialize [

	super initialize.
	self vesselFactory.
	
]

{ #category : 'adding' }
GBAstVessel >> shootFrom: aPosition angle: anAngle [

	| shootPos visual speed newPosition life |
	life := 50.
	shootPos := self translation:
		            aPosition
		            + (0 @ -50 rotateBy: -1 * anAngle about: 0 @ 0).
	shootPos addElement: (visual := GBNode new).
	(shootPos translation: 1000 @ 0) addElement: visual.
	(shootPos translation: -1000 @ 0) addElement: visual.
	(shootPos translation: 0 @ 1000) addElement: visual.
	(shootPos translation: 0 @ -1000) addElement: visual.
	visual addElement: (GBCircle new
			 color: 'white';
			 radius: 5;
			 yourself).
	speed := 0 @ -8 rotateBy: -1 * anAngle about: 0 @ 0.
	shootPos addElement: (GBScript new
			 on: GBCalculate;
			 do: [ :e |
				 life := life - e duration.
				 life < 0 ifTrue: [ self removeElement: shootPos ].
				 newPosition := shootPos position + (speed * e duration) ]).
	shootPos addElement: (GBScript new
			 on: GBUpdate;
			 do: [ shootPos position: newPosition ])
]

{ #category : 'adding' }
GBAstVessel >> vesselFactory [

	| newAngle newPosition rotating accelerating speed visualVessel |
	position := self translation: 0 @ 0.
	position addElement: (visualVessel := GBNode new).
	rotating := 0.
	accelerating := 0 @ 0.
	speed := 0 @ 0.
	angle := visualVessel rotation: 0.

	(position translation: 1000 @ 0) addElement: visualVessel.
	(position translation: -1000 @ 0) addElement: visualVessel.
	(position translation: 0 @ 1000) addElement: visualVessel.
	(position translation: 0 @ -1000) addElement: visualVessel.
	angle addElement: (vesselPolygone := GBPolygon new
			                   points: {
					                   (0 @ -50).
					                   (-25 @ 25).
					                   (25 @ 25) };
			                   color: 'white';
			                   yourself).
	flames := GBPolygon new
		          points: {
				          (0 @ 50).
				          (-12 @ 12).
				          (12 @ 12) };
		          color: 'white';
		          yourself.
	self addElement: GBCaptureKeyboard new.
	self addElement: (GBScript new
			 on: GBKeyDown;
			 do: [ :e |
				 e evt code = 'Space' ifTrue: [
						 self shootFrom: position position angle: angle angle ].
				 e evt code = 'ArrowUp' ifTrue: [
						 angle addElement: flames.
						 accelerating := 0 @ -0.5 ].
				 e evt code = 'ArrowLeft' ifTrue: [
						 rotating := rotating + self angularSpeed ].
				 e evt code = 'ArrowRight' ifTrue: [
						 rotating := rotating - self angularSpeed ] ]).
	self addElement: (GBScript new
			 on: GBKeyUp;
			 do: [ :e |
				 e evt code = 'ArrowUp' ifTrue: [
						 angle removeElement: flames.
						 accelerating := 0 @ 0 ].
				 e evt code = 'ArrowLeft' ifTrue: [
						 rotating := rotating - self angularSpeed ].
				 e evt code = 'ArrowRight' ifTrue: [
						 rotating := rotating + self angularSpeed ] ]).
	self addElement: (GBScript new
			 on: GBCalculate;
			 do: [ :ev |
				 | friction |
				 friction := speed * (0.01 @ 0.01).
				 newAngle := angle angle + (rotating * ev duration).
				 speed := speed
				          +
					          ((accelerating rotateBy: -1 * angle angle about: 0 @ 0)
					           * ev duration) - (friction * ev duration).
				 newPosition := position position + (speed * ev duration).
				 newPosition x < -500 ifTrue: [
						 newPosition := newPosition + (1000 @ 0) ].
				 newPosition x > 500 ifTrue: [
						 newPosition := newPosition - (1000 @ 0) ].
				 newPosition y < -500 ifTrue: [
						 newPosition := newPosition + (0 @ 1000) ].
				 newPosition y > 500 ifTrue: [
						 newPosition := newPosition - (0 @ 1000) ] ]).
	self addElement: (GBScript new
			 on: GBUpdate;
			 do: [
				 angle angle: newAngle.
				 position position: newPosition ])
]
