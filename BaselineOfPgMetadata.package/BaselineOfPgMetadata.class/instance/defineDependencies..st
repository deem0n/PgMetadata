baselines
defineDependencies: spec
	^ spec
		baseline: 'P3' with: [ spec repository: 'github://deem0n/P3:master' ];
		yourself
