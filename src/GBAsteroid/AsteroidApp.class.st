Class {
	#name : 'AsteroidApp',
	#superclass : 'PjFileBasedWebApp',
	#traits : 'StaticComponentHolder',
	#classTraits : 'StaticComponentHolder classTrait',
	#instVars : [
		'clock',
		'reference',
		'root'
	],
	#classInstVars : [
		'staticComponents'
	],
	#category : 'GBAsteroid',
	#package : 'GBAsteroid'
}

{ #category : 'description' }
AsteroidApp class >> appClasses [

	<pharoJsSkip>
	^ super appClasses , { WCGameBoxCanvas }
]

{ #category : 'description' }
AsteroidApp class >> bridgeClientClass [
	<pharoJsSkip>
	
	^ PjZnHostedBrowserBridgeClient
]

{ #category : 'description' }
AsteroidApp class >> exporterClass [
	<pharoJsSkip>
	
	^ PjFileExporterWithIndexHtml
]

{ #category : 'description' }
AsteroidApp class >> generateHtmlUsing: html [

	<pharoJsSkip>
	html div
		class: 'container';
		with: [
			html div
				class: 'card col-10 mx-auto text-center';
				with: [
					html div
						class: 'card-header';
						with: [
							html heading
								level: 1;
								with: 'Pharasteroids' ].
					html div
						class: 'card-body';
						with: [
							html div with: [
									self addComponent: (WCGameBoxCanvas on: html) named: #plotter ].
							html div with: [
									html label
										for: 'tps';
										class: 'form-label';
										with: 'TPS: '.
									html inputRange
										min: 1;
										max: 240;
										value: 120;
										class: 'form-range';
										id: 'tps' ].

							html div
								id: #pause;
								class: 'btn btn-primary';
								with: [
									html idiomatic class: 'bi bi-pause'.
									html idiomatic class: 'bi bi-slash'.
									html idiomatic class: 'bi bi-play' ].
							html div
								class: 'text-start';
								with: [
									html paragraph with: [
											html idiomatic class: 'bi bi-arrow-up-square'.
											html text: ' accelerate' ].
									html paragraph with: [
											html idiomatic class: 'bi bi-arrow-left-square'.
											html text: ' '.
											html idiomatic class: 'bi bi-arrow-right-square'.
											html text: ' turn' ].
									html paragraph with: [
											html image
												style: 'max-height: 1.5em;';
												url: 'https://www.svgrepo.com/show/309996/spacebar.svg'. html text: ' shoot' ] ] ] ] ]
]

{ #category : 'description' }
AsteroidApp class >> updateHtmlRoot: root [

	<pharoJsSkip>
	root language: 'en'.
	root stylesheet url:
		'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css'.
	root stylesheet url:
		'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css'
]

{ #category : 'as yet unclassified' }
AsteroidApp >> asteroidShape [
	
	^ (1 to: 10) collect: [ :i |
		  Point r: (50 to: 150) atRandom theta: 2 * i * Float pi / 10 ].
]

{ #category : 'as yet unclassified' }
AsteroidApp >> newAsteroid: aPosition [

	| pos visual newPosition speed rotationSpeed angle newAngle poly |
	pos := reference translation: aPosition.
	pos addElement: (visual := GBNode new).
	speed := Point r: 1 theta: (0 to: 1000) atRandom / 1000 * Float pi.
	rotationSpeed := (-500 to: 500) atRandom / 80000.
	angle := visual rotation: (0 to: 1000) atRandom / 1000 * Float pi.
	(pos translation: 1000 @ 0) addElement: visual.
	(pos translation: -1000 @ 0) addElement: visual.
	(pos translation: 0 @ 1000) addElement: visual.
	(pos translation: 0 @ -1000) addElement: visual.
	angle addElement: (poly := GBPolygon new
			         points: self asteroidShape;
			         color: nil;
			         strokeStyle: 'white';
			         lineWidth: 5;
			         yourself).
	pos addElement: (GBScript new
			 on: GBCalculate;
			 do: [ :e |
				 newPosition := pos position + (speed * e duration).
				 newPosition x < -500 ifTrue: [
						 newPosition := newPosition + (1000 @ 0) ].
				 newPosition x > 500 ifTrue: [
						 newPosition := newPosition - (1000 @ 0) ].
				 newPosition y < -500 ifTrue: [
						 newPosition := newPosition + (0 @ 1000) ].
				 newPosition y > 500 ifTrue: [
						 newPosition := newPosition - (0 @ 1000) ].
				 newAngle := angle angle + (rotationSpeed * e duration) ]).
	pos addElement: (GBScript new
			 on: GBUpdate;
			 do: [
				 pos position: newPosition.
				 angle angle: newAngle ]).
	pos addElement: (GBCollisionReference new
			 identifier: #asteroid;
			 shape: poly).
	pos addElement: (GBScript new
			 on: Shot;
			 do: [ reference removeElement: pos ])
]

{ #category : 'as yet unclassified' }
AsteroidApp >> prepGame [

	reference := root translation: 500 @ 500.
	reference addElement: GBAstVessel new.
	4 timesRepeat: [ :i |
		self newAsteroid: (0 to: 1000) atRandom @ (0 to: 1000) atRandom ]
]

{ #category : 'as yet unclassified' }
AsteroidApp >> sceneFactory [

	| orchestrator drawEvent |
	drawEvent := GBDrawFullClearSequenceStart new
		             context: (self componentNamed: #plotter) context;
		             yourself.

	orchestrator := GBOchestrator new
		                sequence: {
				                GBCollisionDetection new.
				                GBCalculate new.
				                GBUpdate new.
				                drawEvent };
		                yourself.
	clock := GBClock new.
	clock
		requestedTps: 120;
		waitUntilIsFinished: orchestrator.
	root := GBCollisionScope new.
	root addElement: (reference := GBDrawingTranslation new
			              position: 500 @ 500;
			              yourself).
	root addElement: clock.
	root addElement: orchestrator.
	root addElement:
		(GBDrawSequencer new drawingEvent: GBDrawingNowPartial new yourself).
	root addElement: (GBCaptureMouseClick new
			 onCanvas: (self componentNamed: #plotter);
			 yourself).
	root addElement: (GBCaptureMouseMove new
			 onCanvas: (self componentNamed: #plotter);
			 yourself).
	root addElement: (GBRectangle new
			 color: '#333333';
			 corner: 1000 @ 1000;
			 yourself).
	self prepGame.
	root addElement: GBDebugger new.

	clock start.
	^ root
]

{ #category : 'initialize-release' }
AsteroidApp >> start [

	| scene |
	super start.
	self initializeComponentHolder.
	(self componentNamed: #plotter) scene: (scene := self sceneFactory).
	(document getElementById: #pause) addEventListener: #click block: [
		clock started
			ifTrue: [ clock stop ]
			ifFalse: [ clock start ] ].
	(document getElementById: #tps)
		addEventListener: #input
		block: [ clock requestedTps: (document getElementById: #tps) value ]
]
