# Lua tests

Offline tests for the parts of the mod that can be exercised without the game:
JSON encoding and decoding, the file layer on top of it, and the player data
shapes that go through both.

Nothing here is deployed. `deploy.cmd` copies only `Contents\mods\PhunMart2`,
and removes `Tests` from the workshop staging folders outright.

## Running

```
Tests\lua\run.cmd
```

It needs LuaJIT, which is Lua 5.1:

```
winget install --id DEVCOM.LuaJIT --source winget
```

`run.cmd` looks for `luajit` on PATH and then in
`%LOCALAPPDATA%\Programs\LuaJIT\bin`. Individual suites run on their own too:

```
luajit Tests\lua\test_json.lua
```

## Why LuaJIT and not Lua 5.4

Project Zomboid is Lua 5.1, and the difference is not cosmetic. `json.lua`
escapes control characters with the pattern `[%z\1-\31\\"]`. `%z` is 5.1 only;
5.2 removed it, and the same pattern raises "malformed pattern" there. A suite
that passed under 5.4 would be testing a `json.lua` the game cannot run.

`DEVCOM.Lua` in winget only packages 5.4, hence LuaJIT.

## What the harness does

`harness.lua` makes stock Lua resemble the B42.20.4 runtime. Two halves:

**Taking things away.** B42.20.4 removed `loadstring`, `load` and `loadfile`,
which is the reason the config format is JSON at all. The harness replaces them
with functions that raise, so code reaching for them fails here rather than
working on a dev machine and being `nil` in the game. `next` goes the same way,
since mod code does not get it either. `pairs` and `ipairs` keep working: they
reach `next` below the C boundary, not through the global.

**Standing things in.** An in-memory `getFileReader` / `getFileWriter` pair over
a table of strings, so a test can save a file and read it back the way the mod
does without touching a disk. `readLine()` hands back one line at a time with
the newline stripped, which is what the real one does and what `readAll` in
`utils_file.lua` is written against. Plus the few engine globals the modules
touch on load: `Events`, `isClient`, `ModData`, `SandboxVars`.

Anything loaded through `require` has to be loaded *before* `harness.strip()`,
because `require` needs the loader machinery that strip takes away.

## The suites

| File                | Covers                                                          |
| ------------------- | --------------------------------------------------------------- |
| `test_json.lua`     | Encode/decode round-trips, every shipped defaults file, `utils_file` |
| `test_trackers.lua` | Playtime and kill trackers, save and load, SP and MP            |
| `test_wallet.lua`   | The single-player wallet key and the migration off the old one  |

Two behaviours are worth knowing about because they are deliberate and a future
change might look like a bug fix:

- **Encoding refuses a non-string key rather than coercing it.** JSON object
  keys are strings. A number key written out as a string comes back as a string,
  so the next lookup by number misses it and quietly creates a second record
  beside the first. Refusing loses nothing; coercing loses it slowly.
- **`saveTable` validates before opening the writer.** `getFileWriter`
  truncates on open, so checking afterwards would mean replacing a good file
  with an empty one. `test_json.lua` asserts the file is byte-identical after a
  refused save.
