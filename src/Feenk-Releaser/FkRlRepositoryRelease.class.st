Class {
	#name : #FkRlRepositoryRelease,
	#superclass : #FkRlRelease,
	#instVars : [
		'releaseBranchName',
		'referenceBranchName',
		'version',
		'repository',
		'projectReleases'
	],
	#category : #'Feenk-Releaser'
}

{ #category : #accessing }
FkRlRepositoryRelease >> addProjectRelease: aProjectRelease [
	aProjectRelease repositoryRelease: self.
	^ self projectReleases add: aProjectRelease
]

{ #category : #'accessing - dynamic' }
FkRlRepositoryRelease >> childRepositoryReleases [
	^ (self projectReleases flatCollect: [ :aProjectRelease | 
		aProjectRelease childReleases collect: #repositoryRelease ]) removeDuplicates
			remove: self ifAbsent: [ ];
			yourself
]

{ #category : #actions }
FkRlRepositoryRelease >> commitAndTagRelease [
	| iceRepository |
	iceRepository := self repository icebergRepository.
	iceRepository workingCopy 
		commitChanges: iceRepository workingCopyDiff 
		withMessage: 'Update to version ', self version versionString 
		force: true.
	self icebergReleaseBranch commit ensureCreateTag: self version versionString.
		
]

{ #category : #printing }
FkRlRepositoryRelease >> description [
	^ String streamContents: [ :stream |
		stream 
			nextPutAll: self repository id;
		 	nextPutAll: ', ';
			nextPutAll: self version versionString;
			nextPutAll: ', #';
			nextPutAll: self releaseBranchName ]
]

{ #category : #ui }
FkRlRepositoryRelease >> gtBranchesFor: aView [
	<gtView>
	^ self repository 
		ifNil: [ aView ]
		ifNotNil: [ :aRepository | aRepository gtBranchesFor: aView ]
]

{ #category : #ui }
FkRlRepositoryRelease >> gtProjectsFor: aView [
	<gtView>
	^ aView list 
		title: 'Project releases' translated;
		priority: 15;
		items: [ self projectReleases ]
]

{ #category : #ui }
FkRlRepositoryRelease >> gtRepoMapFor: aView [
	<gtView> 
	^ aView mondrian 
	  title: 'Release Map' translated;
	  priority: 10; 
	  painting: [ :mondrian | 
			| repos |
			repos := (self withDeepCollect: #childRepositoryReleases) asSet.
			mondrian nodes 
				umlClassShapeWithName: [ :aRepositoryRelease | aRepositoryRelease description ];
				with: repos;
				forEach: [ :aRepositoryRelease | 
					mondrian nodes
						shape: [ :aProjectRelease |
							(BlTextElement text: aProjectRelease project name asRopedText)
								constraintsDo: [ :c | 
									c padding: (BlInsets all: 2).
									c linear horizontal alignCenter ] ];
						with: aRepositoryRelease projectReleases.
					mondrian layout vertical ].
			mondrian edges
				shape: [
					BlParabollaArcElement new 
						zIndex: 0;
						curvatureFraction: 0.2;
						border: (BlBorder paint: (Color gray alpha: 0.2) width: 2);
						toHead: (BlArrowheadSimpleArrow new
							border: (BlBorder builder paint: (Color gray alpha: 0.2); width: 2; build)) ];
				fromRightCenter;
				toLeftCenter;
				connectFrom: #yourself 
				toAll: [:each | |dependedRepos |
					dependedRepos := each childRepositoryReleases.
					repos select: [ :project | dependedRepos anySatisfy: [ :dependedProject | dependedProject = project ] ] ].
			mondrian layout custom: (GtGradHorizontalDominanceCenteredTreeLayout new levelDistance: 50; nodeDistance: 10)]
]

{ #category : #ui }
FkRlRepositoryRelease >> gtTagsFor: aView [
	<gtView>
	^ self repository 
		ifNil: [ aView ]
		ifNotNil: [ :aRepository | aRepository gtTagsFor: aView ]
]

{ #category : #'accessing - dynamic' }
FkRlRepositoryRelease >> icebergReleaseBranch [
	^ self repository icebergRepository branchNamed: self releaseBranchName
]

{ #category : #actions }
FkRlRepositoryRelease >> mergeToReleaseBranch [
	| icebergRepository |
	icebergRepository := self repository icebergRepository.
	icebergRepository checkoutBranch: self releaseBranchName.
	"Do the merge from the current branch"
	IceMerge new 
		repository: icebergRepository; 
		mergeCommit: (icebergRepository branchNamed: self referenceBranchName) commit; 
		executeWithoutUpdatingWorkingCopy.
]

{ #category : #'accessing - dynamic' }
FkRlRepositoryRelease >> parentRepositoryReleases [
	^ (self projectReleases flatCollect: [ :aProjectRelease | 
		aProjectRelease parentReleases collect: #repositoryRelease ]) removeDuplicates 
			remove: self ifAbsent: [ ];
			yourself
]

{ #category : #printing }
FkRlRepositoryRelease >> printOn: aStream [
	super printOn: aStream.
	aStream 
		nextPutAll: '(';
		nextPutAll: self description;
		nextPutAll: ')'
]

{ #category : #accessing }
FkRlRepositoryRelease >> projectReleases [ 	
	^ projectReleases ifNil: [ 
		projectReleases := OrderedCollection new ]
]

{ #category : #accessing }
FkRlRepositoryRelease >> referenceBranchName [
	^ referenceBranchName
]

{ #category : #accessing }
FkRlRepositoryRelease >> referenceBranchName: aBranchName [
	referenceBranchName := aBranchName
]

{ #category : #accessing }
FkRlRepositoryRelease >> releaseBranchName [
	^ releaseBranchName
]

{ #category : #accessing }
FkRlRepositoryRelease >> releaseBranchName: aBranchName [
	releaseBranchName := aBranchName
]

{ #category : #accessing }
FkRlRepositoryRelease >> repository [
	^ repository 
]

{ #category : #accessing }
FkRlRepositoryRelease >> repository: aRepository [
	repository := aRepository
]

{ #category : #'accessing - dynamic' }
FkRlRepositoryRelease >> urlWithReleaseVersion [
	^ self repository urlWithVersion: self version versionString
]

{ #category : #accessing }
FkRlRepositoryRelease >> version [
	^ version
]

{ #category : #accessing }
FkRlRepositoryRelease >> version: aVersion [
	version := aVersion
]

{ #category : #'accessing - dynamic' }
FkRlRepositoryRelease >> versionString [
	^ self version versionString
]