---
title: Revision control
published: false
---
## Atomic commit

Both these articles talk about atomic commits, but they don't really define what they mean by an atomic commit.

https://about.futurelearn.com/blog/telling-stories-with-your-git-history/ - "Atomic commits" section:

> Think of atomic commits as the smallest amount of code changed which delivers value

http://www.annashipman.co.uk/jfdi/good-pull-requests.html

This seems to mean different things to different people. The idea of curating commits

Summarising a couple of sections of the relevant Wikipedia page:

* A commit which does not result in merge conflicts; those that do are rejected[^1].
* A small commit which only affects one aspect of the system[^2], e.g. avoid mixing formatting and functional changes in the same commit.

The idea of atomicity doesn't make much sense unless you define what level of system consistency you are expecting i.e. what constitutes a valid state of the system. In this respect, even the first definition (above) is a bit ambiguous, because it doesn't specify what it means by a merge conflict.

Git is only atomic in the sense that a commit must either completely succeed or completely fail; it's not possible for some of the changes to be accepted into the repository, but for others to be rejected. It's possible to commit changes including conflict markers into a git repository.

My idea of an atomic commit leaves the system in a working state, i.e.

Levels of consistency:

1. All changes in a commit are accepted or they are all rejected; nothing in between.
2. No conflict markers.
3. Code parses / compiles & links.
4. Tests all pass.

* Refactoring tools, e.g. "move method", "rename class", "extract method".
* Language-aware / semantic merging.
* http://martinfowler.com/bliki/SemanticDiff.html
* http://martinfowler.com/bliki/SemanticConflict.html
* https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History
* https://en.wikipedia.org/wiki/Consistency_(database_systems)
* Natural consequence of TDD
* Tricks:
  * Implement new functionality, but don't make it visible to the user / navigable
  * Implement changed behaviour alongside existing behaviour, but make existing behaviour the default
  * Marking acceptance tests as pending

## Goldilocks commit

Not too big, not too small.

## References

[^1]: Wikipedia: [Atomic commit: Revision control](https://en.wikipedia.org/wiki/Atomic_commit#Revision_control)
[^2]: Wikipedia: [Atomic commit: Atomic commit convention](https://en.wikipedia.org/wiki/Atomic_commit#Atomic_commit_convention)
[^3]: Wikipedia: [Goldilocks principle](https://en.wikipedia.org/wiki/Goldilocks_principle)
