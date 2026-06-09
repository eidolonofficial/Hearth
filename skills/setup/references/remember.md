# remember

Keep two running records so a later session picks up where this one left off.
Both rely on the shared base in SKILL.md. Do not repeat those rules here.

## Why two records

Most setups only write down what broke. That makes Claude good at not breaking
things, but blind to what is working, because nothing good ever got written
down. Keeping a second record of what worked balances the picture. The two
together mirror how an experienced person works: watching for trouble and
watching for good patterns at the same time.

## The two records

```
docs/fixes/      what broke and how it got fixed
docs/insights/   what worked and is worth reusing
```

Filenames:

```
docs/fixes/FIX-YYYY-MM-DD-short-name.md
docs/insights/INSIGHT-YYYY-MM-DD-short-name.md
```

## Write a fix entry when

- a test failed and it took real effort to work out why
- something behaved in a way you did not expect
- the person caught a problem a check should have caught

A fix entry covers: what failed and how it showed up; the real cause (checked,
not guessed); the fix; what went well (signals that fired, checks that caught
related issues); and what would catch it earlier next time.

## Write an insight entry when

- something worked, AND
- it would transfer beyond this one spot

This is the before_reuse check from the shared base (your synthesis protocol).
Run it honestly. If the lesson only helped right here, it is not an insight.
Name two or three other places the same idea would apply before you save it.
Bound it too: say what the insight is NOT, so it does not get over-applied later.

## Keep it lean

When these records grow, retire the entries that have stopped earning their
place. Growing the record is not a win. Every entry is a cost the next reader
pays. A record nobody reads is not memory, it is clutter.

## Source

This is the plain-English version of your dual-log-memory skill. The full text,
with the synthesis protocol and the sunset rules, stays in that repo
(github.com/gmrmk/dual-log-memory) as the source of record. Internal name: the
insight side is your synthesis protocol.
