Shadow Templar Engine Control
===================
STEC is a collection of modules for Dual Universe ship control.

----------

Installation
-------------
- To install STEC, paste STEC and STMM into `system.start`, and KeybindController into `library.start`.
- Add events to `system` for `actionStart`, `actionStop`, and `actionLoop`. The filter should be `*`
- Put `keybinds.call(action, "actiontype")` into each, where `actiontype` is the type: `down, up, and loop` respectively
- Put `engines.apply()` and `mouse.apply()` in `system.flush`
- Put your keybind code into `unit.start` as such: `keybinds.keyDown.up(function(action) dostuff() end)`
- `STEC_config.lua` offers a default keybind configuretion which you can paste into `unit.start`

Contribution
------------
To contribute, create a branch for the issue you're working on. When finished, make sure your squashed commit message contains the issue number i.e. `#1`, and push the branch onto the remote.
After that, create a pull request and add the reviewers. Your branch will be merged after review.
