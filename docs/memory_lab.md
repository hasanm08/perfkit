# Memory Lab

Episode 2 — Flutter Memory Leaks

## Scenarios

1. Undisposed controllers/streams
2. Surviving timers
3. Singleton object retention
4. Image cache retention
5. Closure captures

## DevTools Memory workflow

1. Open Memory view in profile/debug
2. Take a heap snapshot before Start
3. Reproduce (open/close / Start repeatedly)
4. Snapshot again; compare
5. Inspect retaining paths
6. Trigger GC and observe what remains

RSS growth alone does not prove a leak. Distinguish retained objects, heap growth, GC, and genuine leaks.
