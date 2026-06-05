# Project Context

This repository is a fork of the original Caelestia Shell project.

## Goal

Make this shell leaner and faster for an older MacBook Air from 2012.

Priorities:

- Remove unnecessary features, modules, services, assets, and dependencies that slow the shell down.
- Remove features the user does not use.
- Keep the project focused on the user's actual setup instead of preserving unused upstream functionality.
- Prefer simple, direct changes over compatibility layers or fallback code.

## Related Configuration

The user's Nix configuration lives at:

- `/home/jdr/nixconfig`

That configuration is where this fork is consumed. The relevant host is `Miamia`, which currently uses this Caelestia Shell project.

When deciding whether a feature is needed, inspect `/home/jdr/nixconfig` and the `Miamia` host configuration to see how this shell is actually configured and used.

## Working Guidance

- Read the current implementation before editing.
- Verify assumptions against the real config in `/home/jdr/nixconfig` instead of guessing.
- Remove unused code cleanly rather than leaving disabled legacy paths.
- After changes, run the lightest relevant checks available for this project.
