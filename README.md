# feenk-releaser

## How to load

You can load the whole code in Pharo 7.0 using the following snippet:
```
EpMonitor current disable.
Metacello new
   baseline: 'FeenkReleaser';
   repository: 'github://feenkcom/feenk-releaser/src';
   load.
EpMonitor current enable.
```
