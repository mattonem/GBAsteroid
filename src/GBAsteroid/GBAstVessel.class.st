Class {
	#name : 'GBAstVessel',
	#superclass : 'GBNode',
	#instVars : [
		'position',
		'angle',
		'vesselPolygone',
		'flames',
		'vesselSpeed'
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
GBAstVessel >> position [ 
	^ position
]

{ #category : 'adding' }
GBAstVessel >> shootFrom: aPosition angle: anAngle [

	| shootPos visual speed newPosition life |
	life := 50.
	shootPos := position translation:
		            (0 @ -50 rotateBy: -1 * anAngle about: 0 @ 0)
		            - position position.
	shootPos addElement: (visual := GBNode new).
	visual addElement: (GBCircle new
			 color: 'white';
			 radius: 5;
			 yourself).
	speed := (Point r: 8 theta: anAngle - (Float pi / 2)) + vesselSpeed.
	shootPos addElement: (GBScript new
			 on: GBCalculate;
			 do: [ :e |
				 life := life - e duration.
				 life < 0 ifTrue: [ position removeElement: shootPos ].
				 newPosition := shootPos position + (speed * e duration) ]).
	shootPos addElement: (GBScript new
			 on: GBUpdate;
			 do: [ shootPos position: newPosition ]).
	shootPos addElement: (GBCollisionReference new identifier: #bullet).
	shootPos addElement: (GBCollision new
			 points: { (0 @ 0) };
			 lookfor: #asteroid;
			 do: [ :aCollider |
				 life := 0.
				 aCollider announcer announce: Shot new ];
			 yourself)
]

{ #category : 'adding' }
GBAstVessel >> vesselFactory [

	| newAngle newPosition rotating accelerating  visualVessel |
	position := self translation: 0 @ 0.
	self addElement: (visualVessel := GBNode new).
	rotating := 0.
	accelerating := 0 @ 0.
	vesselSpeed := 0 @ 0.
	angle := visualVessel rotation: 0.

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
						 self shootFrom: (0@0) angle: angle angle ].
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
				 friction := vesselSpeed * (0.01 @ 0.01).
				 newAngle := angle angle + (rotating * ev duration).
				 vesselSpeed := vesselSpeed
				          +
					          ((accelerating rotateBy: -1 * angle angle about: 0 @ 0)
					           * ev duration) - (friction * ev duration).
				 newPosition := position position - (vesselSpeed * ev duration).
				  ]).
	self addElement: (GBScript new
			 on: GBUpdate;
			 do: [
				 angle angle: newAngle.
				 position position: newPosition ])
]
