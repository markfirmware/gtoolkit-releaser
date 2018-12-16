Class {
	#name : #GtRlNullReleaseStrategy,
	#superclass : #GtRlReleaseStrategy,
	#category : #'GToolkit-Releaser'
}

{ #category : #printing }
GtRlNullReleaseStrategy >> description [
	^ 'Null'
]

{ #category : #accessing }
GtRlNullReleaseStrategy >> nullVersionNumber [
	^ GtRlNullVersionNumber new
]

{ #category : #actions }
GtRlNullReleaseStrategy >> updateFor: anUpdateWorkflow [
	self repositoryRelease
		version: self nullVersionNumber;
		makePassiveRelease
]