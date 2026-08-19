---
description: Conventions for Google Apps Script sensors
paths: ["**/*.gs"]
---

# Apps Script rules

- Sensors write typed JSON events to the spool through `gh-spool.gs`. They never
  write anywhere else, and never call an AI model except the cheap
  classification tier.
- Secrets live in Script Properties, never in code. Reference them by name.
- Every sensor emits a `sensor.run` heartbeat even when it found nothing, so
  silence is distinguishable from failure.
- Structural protection runs before any suppression. An allowlisted sender, an
  invoice term, a document attachment or a thread the owner replied to survives
  regardless of what the classifier thinks.
- Event IDs are derived from the source reference or the content hash, so a
  replayed run cannot create a duplicate.
- The `state` field is the only mutable field on an event. Nothing else may be
  rewritten, ever.
- Enum values used by a classifier must be listed in the prompt as well as the
  response schema, or classification drifts.
- Trigger installation belongs in `setUp()`. A trigger created by hand in the
  UI is a trigger nobody knows exists.
