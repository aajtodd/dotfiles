# bosun.md — dotfiles

State + pointers for the dotfiles repo. Single source of truth across sessions.

## Current Status

GNU Stow-managed dotfiles; `master` branch. bosun.md is now COMMITTED normally alongside related
work (the old "keep uncommitted" rule was retired 2026-07-08 — it was friction and this is useful
recoverable state). User still commits when they choose; assistant may stage bosun.md with a
change. Build/test n/a; "green" = configs parse + `zsh -n` clean. See `git log` for history.

USER ACTIONS PENDING (need a human / a fresh shell):
- `exec zsh` to clear the starship-recursion'd widget + smoke-test the batch (dot, dict, the
  mode glyph, gs/frg/clone). Re-source in the broken session won't fix the widget.
- Add `Host sshdev` to ~/.ssh/config to use the ssh helpers (machine-local; can't write safely).

DONE this session (all verified):
- **broken-shells**: live Mac fixed (relinked starship/fnm, stowed starship, node via fnm,
  removed nvm); bootstrap-macos.sh rewritten to AL2023 rigor.
- **`dot` framework**: personal reference/snippet/function system. 12 guides, 7 function
  domains (clip/find/git/nav/sessions/ssh/words) + clone, 4 navi cheats. Commands: `dot`,
  `dot <topic>`, `dot -s`, `dot run`. navi installed + in both bootstraps. jq added too.
- **cli tools**: zoxide, bat, navi installed + wired; ls/grep color fix.
- **line-editing**: `keymap vi|emacs` toggle (persists ~/.zsh_keymap), edit-command-line,
  mode-colored ❯ glyph indicator. Default vi, KEYTIMEOUT=1.
- **zellij plugin-build machinery**: plugins.lock + build-plugins.sh (pinned-SHA→cargo→vendored
  gitignored .wasm). Built autolock fix. zellij upgraded 0.44.0→0.44.3 (brew, cargo build removed).
- **SSH prompt hostname indicator** (shows only over SSH).

NOT YET BUILT (next big chunks):
- **nvim-modernize** (below) — Phase 1+2 DONE + committed (79a468f) in the nvim-dev SANDBOX,
  verified on 0.12.4. REMAINING: (1) user drives nvim-dev on real work; (2) PROMOTE nvim-dev/ →
  nvim/ COUPLED with upgrading daily nvim 0.11.2→0.12 (modern config needs 0.12); (3) lspmux
  (the original rust-LSP reopen-lag goal, now unblocked on a modern base).
- **stow-fix** (below) — gates the whole zellij autolock/nav/forgot WIRING (decisions all made).
- **project-workflow model** (`dot project ...`) — designed, not built; needs a focused session.
- **Rust `dot` graduation** — when sed parsing pain recurs.

## Workstreams

### zellij-enhance  [partial — machinery DONE, config WIRING blocked on stow-fix]

Turn the minimal zellij config into a proper nvim-centric setup. All decisions made;
plugin-build machinery + autolock .wasm + zellij 0.44.3 DONE. The actual config wiring
(autolock/MoveFocus/forgot keybinds) + nvim smart-splits are NOT yet written — gated on
stow-fix (live config is still the Kiro file). Tasks at the bottom of this section.

Findings / facts established:
- Installed zellij is **0.44.0**.
- nvim has plain `<C-h/j/k/l>` → `<C-W>` window moves (config.lua:56-59). `smart-splits.nvim`
  is only a wishlist line in nvim/README.md — NOT installed. Zero nvim↔zellij integration today.
- zellij web server (0.43+): serves browser terminal client; binds `127.0.0.1:8082` by default;
  serves **plain HTTP on localhost** (no cert needed — `enforce_https_for_localhost` default false);
  token auth (`zellij web --create-token`, `--create-read-only-token`); read-only tokens exist.
- Tunnels (`tunnels.lab.aws.dev`, pkg PdebieTunnels, #tunnels-interest): internal ngrok.
  `toolbox install tunnels`; `tunnel create 8082 --name pair --allow posix:team`. Midway-gated,
  WebSocket proxying (terminal traffic is ideal — tiny payloads). Dies when mwinit expires
  (~12-23h); not for always-on. Without `--allow`, owner-only.

CRITICAL FINDING (2026-06-22): zellij-autolock + vim-zellij-navigator are BOTH broken on
zellij 0.44 (new wasmi engine: list_clients() no longer populates running_command).
- autolock issue #18 (open, maintainer absent ~17mo). vim-zellij-navigator #26/#36.
- FIX: PR #21 on zellij-autolock migrates detection to 0.44.2 `CommandChanged` event.
  Maintainer unresponsive, so we build from a fork. Pinned: kierr/zellij-autolock
  @ e2f6546 (tag v0.2.3-0.44fix). Requires zellij >= 0.44.2.
- smart-splits NATIVE zellij nav works on 0.44 (only needs pane ID, not command).

DONE (2026-06-22) — plugin build machinery:
- Upgraded zellij 0.44.0 (cargo build from ~/sandbox/rs/3P/zellij) → 0.44.3 via brew;
  `cargo uninstall zellij` to remove the shadowing build. zellij now = /opt/homebrew/bin (0.44.3).
- `zellij/plugins.lock` — committed source of truth: name|repo|ref|sha|target|note per plugin.
- `zellij/build-plugins.sh` — clones each pinned plugin, ASSERTS checked-out SHA == lock SHA
  (aborts on drift), `cargo build --release --target wasm32-wasip1`, copies .wasm + writes
  .provenance. Idempotent, arch-agnostic, auto-adds wasm target. Reusable: +1 line per plugin.
- Build-on-demand: *.wasm + *.provenance gitignored; .lock + script committed. Standalone
  (NOT wired into bootstrap — run manually, document in README).
- VERIFIED: built zellij-autolock.wasm (1.5MB) from pinned SHA; gitignore confirmed correct.

DECIDED (2026-06-22):
- **Seamless nav: smart-splits.nvim (nvim) + plain zellij MoveFocus binds (zellij).**
  nvim side: smart-splits handles `Ctrl-hjkl` within nvim; at edge runs `zellij action
  move-focus` (CLI, lock-proof). zellij side: rebind `Ctrl-hjkl` → `MoveFocus` in normal mode
  (NOT a plugin). Replaces config.lua:56-59.
  NOTE: vim-zellij-navigator plugin is DROPPED — redundant given autolock + smart-splits.
- **Collision strategy: zellij-autolock plugin** (focus-based). Locks when focused pane runs
  nvim, unlocks on shell focus. Glue that makes the two nav halves cooperate. Manual Ctrl-g
  lock habit retires.
- **autolock triggers: nvim ONLY to start.** Known consequence: fzf in a shell pane stays
  unlocked, so zellij's Ctrl-j/k MoveFocus steals fzf's item nav (arrows/Ctrl-n still work).
  fzf is the expected first addition to triggers when this bites.
- **MANUAL LOCK PRESERVED: Ctrl-g stays the lock/unlock toggle** (zellij default keybind; NOT
  removed). autolock does NOT delete it. Caveat: autolock re-evaluates on focus/command change
  (~0.3s) and will OVERRIDE a manual state that contradicts the focus rule (e.g. manually
  unlocking while focused in nvim → autolock re-locks on next tick). Manual control exists but
  isn't authoritative while autolock runs. (If authoritative manual control wanted later:
  add a "pause autolock" bind, or run autolock off.)
- **zellij-forgot: bind `F1`** (near-zero collision; leaves Ctrl-g free as the lock toggle).
  `shared_except "locked"`. **Labels: auto-load on (LOAD_ZELLIJ_BINDINGS default), revisit**
  if verbose labels annoy → then hand-write ~10 clean entries.
- **zjstatus: SKIP** — against user's minimal-UI taste (`pane_frames false`); no speed gain.
- **dev layout: DEFERRED.**
- **web-sharing: document the share/pair workflow now; configure + try live later.**

Tasks:
- [ ] Wire smart-splits.nvim into nvim plugin specs; remove old C-hjkl maps (config.lua:56-59)
      — takes effect immediately, independent of stow-fix
- [ ] zellij config (ALL gated on stow-fix to go live):
      - [ ] rebind Ctrl-hjkl → MoveFocus in normal mode
      - [ ] add zellij-autolock plugin (triggers: nvim only) + load_plugins entry
      - [ ] add zellij-forgot (v0.4.2) bound F1, LaunchOrFocusPlugin { floating true }, auto-load labels
      - [ ] keep Ctrl-g lock/unlock toggle (zellij default — do not remove)
- [ ] README section: "Sharing a zellij session for pairing" (Tunnels + zellij web tokens,
      read-only default, mwinit-expiry caveat). Document now; setup later.

Open questions: (none blocking — ready to implement)

Links: research lives in this file for now (no research/ dir yet).

### stow-fix  [blocked — deferred by user "worry about it in a minute"]

The **live** `~/.config/zellij/config.kdl` is a regular file (Kiro-injected, 590 lines, has a
`config.kdl.bak` alongside), NOT the stowed symlink. The stowed dotfile
(zellij/.config/zellij/config.kdl, 24 lines, hand-written) is therefore ignored at runtime.
Any zellij dotfile edit is inert until this is resolved.

DIFF ANALYSIS DONE (2026-06-27): live uses `keybinds clear-defaults=true` and re-lists the
ENTIRE stock 0.44.3 keymap explicitly in lowercase. Diff vs `zellij setup --dump-config` is
~600 lines but 90% is casing ("Normal"→"normal") + reordering of DEFAULT binds (verified
ToggleGroupMarking etc. are stock). The ONLY genuinely non-default content:
- **zj-claude wiring (KEEP)** — the user's in-progress plugin (replaces old zj-kiro.wasm):
    * shared block binds: `Ctrl u` → MessagePlugin "zj-claude" {name "jump-top"; floating false};
      `Ctrl y` → LaunchOrFocusPlugin "zj-claude" {floating true; move_to_focused_tab true}
    * plugins{} alias: zj-claude location="file:~/.config/zellij/plugins/zj-claude.wasm"
    * load_plugins{ zj-claude }
    * wasm at ~/.config/zellij/plugins/zj-claude.wasm (rebuilt Jun 26 — ACTIVELY iterating)
- two trivial non-defaults (user's call): `show_startup_tips false`, `web_client { font "monospace" }`
=> Our minimal file CAN replace the live one; just port the zj-claude wiring (and add our
keybind additions WITHOUT clear-defaults — we want stock defaults + our adds).

zellij-forgot: NOT installed. plugins.lock has ONLY zellij-autolock (kierr fork @ e2f6546).
autolock .wasm IS built/present in repo; nothing loads it yet (wiring is in the unwritten
keybinds section of repo config.kdl).

SECOND STOW PROBLEM (found via `stow -n`): build-plugins.sh + plugins.lock sit at the zellij
PACKAGE ROOT, so stow targets them at $HOME (~/build-plugins.sh, ~/plugins.lock) — wrong.
Need to relocate under .config/ or otherwise keep stow from linking them into $HOME.

OPEN DESIGN Q (decide before writing repo config.kdl): zj-claude is a `file:` path to a wasm
that's actively rebuilt (user's own in-progress plugin), unlike autolock (pinned upstream SHA,
vendored). Where does its wiring live? Options: (a) machine-local override kdl, (b) stow it but
gitignore the wasm. Don't vendor an in-flight plugin like a pinned dependency.

Tasks:
- [ ] Decide zj-claude wiring placement (local-override vs stowed+gitignored wasm)
- [ ] Write repo config.kdl: keep defaults (no clear-defaults) + our keybind adds + zj-claude
- [ ] Fix build-plugins.sh / plugins.lock placement so stow doesn't link them into $HOME
- [ ] back up + rm live config.kdl (+ .bak) → `stow zellij` → re-establish symlink

### nvim-modernize  [active — Phase 1+2 DONE + committed 79a468f (sandbox); promote + lspmux remain]

Driver: user opens/closes nvim frequently; rust-analyzer re-indexes every open → LSP lag.
That fix = lspmux (persistent RA server) — PARKED until config is modernized first (user's
call). Along the way user asked to audit the whole plugin set vs current (mid-2026) state.

STATUS 2026-07-07: all sandbox config work (Phase 1 + Phase 2 2a-2f + leap→flash + kernel-style
comment cleanup + flash-modes doc) DONE, verified on 0.12.4, committed as 79a468f (nvim-dev/
only). REMAINING, in order:
1. User drives nvim-dev on real work to shake out feel (blink completion muscle memory, flash `s`).
2. PROMOTE + daily-0.12 upgrade (COUPLED — see gate below): copy verified nvim-dev/ changes into
   nvim/, re-stow; AND bump daily nvim 0.11.2→0.12 (brew upgrade neovim on mac; al2023 bootstrap
   already installs the 2nd 0.12 binary but daily-nvim path there needs deciding). Can't promote
   without the upgrade — treesitter main + rustaceanvim v9 require 0.12.
3. lspmux (Codeberg p2502/lspmux, EUPL, ~0.3.1) — the ORIGINAL reopen-lag goal, now unblocked.
   Ties into zellij-persist-ssh (RA bg process needs systemd-run/linger on the dev desk too).

VERSION FACTS (corrected): STABLE nvim is 0.12.x (0.12.4); master = 0.13-dev. User on 0.11.
Modernization target = 0.12 patterns. Config: nvim/.config/nvim/, lazy.nvim, split specs
core/editor/ui/languages.lua + configs/*.lua. rust maps in after/ftplugin/rust.lua.

lspmux (was ra-multiplex): ACTIVELY developed (Codeberg p2502/lspmux, ~0.3.1, EUPL-1.2 =
EU Public Licence, OSI copyleft — irrelevant for just RUNNING the tool). It's the renamed+
relicensed continuation of the ARCHIVED ra-multiplex (MIT, crates.io, still works). Target
lspmux when we get to it. Ties into zellij-persist-ssh (RA bg process also needs the
systemd-run/linger treatment on the dev desk to survive disconnect).

RESEARCH VERDICTS (4 agents, GitHub READMEs/dates + nvim 0.12 news.txt, July 2026):

MUST-FIX (broken / obsolete, do regardless):
- **nvim-treesitter — LATENT BROKEN.** lazy pulls `main` (now repo default) but
  configs/treesitter.lua calls `require("nvim-treesitter.configs").setup{}` which DOESN'T
  EXIST on main (ground-up rewrite, requires 0.12, repo ARCHIVED Apr 2026 so main=final API).
  New API: `require('nvim-treesitter').install({parsers})` + FileType autocmd calling
  `vim.treesitter.start()` (highlight no longer auto-enabled); add `build=':TSUpdate'`,
  `lazy=false`. Drop use_languagetree/additional_vim_regex_highlighting (now nvim default).
  CAVEAT: check smithy/kotlin parser-name vs filetype-name mapping. TOP PRIORITY.
- **FixCursorHold.nvim — DROP.** Obsolete since nvim 0.8 (PR #20198, 2022). neotest still
  lists it but its own docs say unneeded. Remove from neotest deps in editor.lua.

OUTDATED PATTERNS (keep plugin, rewrite usage):
- **LSP framework:** `require('lspconfig').x.setup{}` + mason-lspconfig `setup_handlers` BOTH
  deprecated. 0.12 path = `vim.lsp.config()` + `vim.lsp.enable()` (+ lsp/<name>.lua files).
  Rewrite configs/lsp.lua. Keep nvim-lspconfig (server-config DB) + mason (installer).
- **mason org MOVED:** williamboman/* → mason-org/* (mason.nvim v2.3.1, mason-lspconfig v2.3.0).
- **mason-lspconfig:** role shrunk to auto-enable (`automatic_enable=true` calls vim.lsp.enable)
  + :LspInstall. setup_handlers REMOVED from API. Keep thin or DROP + call vim.lsp.enable self.
- **cmp_nvim_lsp capabilities wiring** (`default_capabilities()`) — legacy; set via
  vim.lsp.config('*',{capabilities=...}) or let blink provide.
- **rustaceanvim:** version pin `^5` STALE → v9 (requires nvim 0.12). Confirmed: self-manages
  rust-analyzer, NO lspconfig dep; must NOT install RA via mason nor enable via lspconfig/
  mason-lspconfig (conflicts). Configure via vim.g.rustaceanvim.server / vim.lsp.config("rust-analyzer").
- **telescope:** pinned `tag='0.1.5'` (ancient) → current 0.2.1 (needs 0.11.7+). Pin risks API
  drift w/ the vimgrep_arguments internals in configs/telescope.lua. Move to version='*'.
- **which-key:** v3 changed spec (add() not register()). Check init usage (user's spec looks
  minimal, may be fine).

SUPERSEDED — replace candidates (USER'S CALL, not forced):
- **leap.nvim → flash.nvim.** leap UNMAINTAINED (moved to Codeberg, "not updated anymore").
  flash (folke) = maintained successor. [user previously liked leap; decision pending]
- **nvim-cmp + cmp-* galaxy → blink.cmp.** nvim-cmp MAINTENANCE-ONLY (hrsh7th stepped back).
  blink.cmp (Saghen, pin v1.*) bundles lsp/buffer/path/cmdline/snippets + kind icons → DROP
  cmp-buffer/cmp-path/cmp-cmdline/cmp-nvim-lua/cmp_luasnip/lspkind. Rust fuzzy matcher. Keep
  cmp-dap only via blink.compat if wanted. LuaSnip: keep (blink integrates) or drop→vim.snippet.
- **Comment.nvim → DROP** for built-in gc/gcc (shipped nvim 0.10; not in 0.12 news b/c older).
- **nvim-ufo:** 0.11+ built-in LSP folding (vim.lsp.foldexpr/foldtext). ufo only adds fancy
  foldtext handler + peek UX. Keep if wanted else drop→builtin foldexpr (user has elaborate
  ufo config incl K=peek-or-hover; non-trivial to unwind).

KEEP AS-IS (current/healthy): rustaceanvim(bump), neo-tree(v3.x correct), vim-matchup(now
decoupled from old TS API — good), gitsigns(v2, check on_attach), trouble(v3 toggle("diagnostics")
is CORRECT), fidget(v2, needs 0.11.3), toggleterm, fugitive+rhubarb, lualine, nvim-surround(v4,
0.12-aware), nvim-dap stack, neotest(v5.19), nvim-nio(required dep), onenord(active), web-devicons.
cmp-dap: keep-if-nvim-cmp / drop-if-blink.

META-PLUGINS (flagged, NOT required): mini.nvim (independent modules, matches user's minimalist
taste) or snacks.nvim (folke bundle). Only unforced clear wins = drop-Comment + leap→flash.
vim.pack (built-in pkg mgr) EXPERIMENTAL in 0.12 → keep lazy.nvim, revisit 0.13.

VERSION DELTAS (2nd research pass 2026-07-06 — "what CHANGED", agents a6310a441592a800f,
aa980e379ef5108db):
- **rustaceanvim v5→v9:** only v6 + v9 really bite. v6: STOPPED auto-registering completion
  capabilities (must pass server.capabilities yourself now — likely source of any rust-cmp
  oddness), dropped tools.edition + rust-analyzer.json. v7: ra-multiplex→lspmux. v8: dropped
  .vscode/settings.json (→codesettings.nvim if used). v9: min nvim 0.12. Struct otherwise
  stable (tools/server/dap). Fix = bump pin, add server.capabilities, del tools.edition.
- **treesitter master→main:** no ensure_installed/configs.setup{}; use .install({...}) +
  vim.treesitter.start() FileType autocmd + build=':TSUpdate' + lazy=false. DRAGS textobjects
  (also main branch, imperative keymaps) IF we add it (user doesn't run it today). vim-matchup
  TS-integration was via removed configs.setup{matchup=} — matchup works but that wiring has no
  main-branch config key; verify during migration.
- **blink.cmp:** preset-based keymap ('default'/'super-tab'/'enter') not explicit mapping
  tables. Built-in lsp/buffer/path/cmdline/snippets + kind icons → collapses 8 cmp-* + lspkind
  to ONE. LuaSnip via snippets={preset='luasnip'}. caps via require('blink.cmp').get_lsp_capabilities().
  Pin version='1.*'. Full before/after config captured in agent a6310a441592a800f output.
- **mason v1→v2:** org williamboman→mason-org; setup()/ensure_installed UNCHANGED (only
  scripting API broke). mason-lspconfig v2: setup_handlers REMOVED → automatic_enable=true
  (auto vim.lsp.enable); ensure_installed still works; automatic_installation removed.
- **flash (←leap):** s=jump S=treesitter; MULTI-char vs leap's fixed 2-char (muscle-memory
  change); no equivalence_classes (needs custom search.mode fn to mimic).
- **telescope 0.1.5→0.2.1:** LOW effort — user's vimgrep_arguments + find_command patterns
  UNCHANGED/valid; just unpin tag (0.2.0 raised min nvim to 0.10.4, dropped TS requirement,
  fixed 0.12 deprecations). which-key v2→v3: user relies on desc auto-discovery, NO register()
  calls → ZERO changes needed (optionally set opts.delay; timeoutlen now separate from popup delay).

TEST HARNESS — DECIDED (2026-07-06): NVIM_APPNAME isolation. Name = `nvim-dev` (chosen over
nvim-next: a STANDING permanent sandbox for ongoing experiments, not a transient migration
staging area). BUILT: zsh/functions/nvim.zsh adds `nvim-dev()` = `NVIM_APPNAME=nvim-dev command
nvim` (isolated config ~/.config/nvim-dev, data ~/.local/share/nvim-dev, own plugins + lazy-lock;
daily nvim untouched, only binary shared). Documented in dot/guides/nvim.md (dir table + promote
workflow + wipe cmd) + CLAUDE.md. NVIM_APPNAME was unused before — clean lever. PLAN: seed
nvim-dev/ as a NEW stow package (copy of nvim/ to start), iterate+verify there, PROMOTE a vetted
change by copying into nvim/ + re-stow; KEEP nvim-dev around for future experiments. Git =
rollback. nvim install: brew (mac) / latest release tarball (al2023); config is a stow symlink
~/.config/nvim → dotfiles.

SEEDED 2026-07-06: nvim-dev/ stow package created as a faithful COPY of nvim/ (24/24 files inc.
lazy-lock + spell), inner dir renamed .config/nvim → .config/nvim-dev. `stow nvim-dev` applied +
VERIFIED: lazy installed into isolated ~/.local/share/nvim-dev, sandbox comes up = daily config.
NOT in bootstrap stow lines (opt-in sandbox that diverges; stow manually).

CORRECTION 2026-07-06: treesitter is NOT currently broken (I over-claimed). The pinned commit
ff553df2 (Mar 2025) is an EARLY main-branch commit that STILL ships lua/nvim-treesitter/configs.lua,
so configs.setup{} works + highlight is active (headless-verified). It's a LATENT-ON-UPDATE hazard:
`:Lazy update` would pull a newer main commit where configs.lua is gone → then it breaks. AND
can't safely update anyway — current main needs 0.12.

VERSION GATE (key realization): NVIM_APPNAME isolates CONFIG not BINARY. Daily nvim = 0.11.2
(brew). treesitter-main / rustaceanvim-v9 / mature-native-LSP all need 0.12. So the big
modernization is really a 0.12-UPGRADE PROJECT. DECISION (user): install a SECOND 0.12 binary
for the sandbox, keep daily on 0.11. DONE 2026-07-06: installed nvim 0.12.4 → ~/opt/nvim-0.12/
(arm64 macOS tarball, quarantine-stripped, no sudo, doesn't shadow brew 0.11). nvim.zsh updated:
nvim-dev prefers ~/opt/nvim-0.12/bin/nvim else falls back to PATH nvim. Verified nvim-dev=0.12.4,
daily nvim=0.11.2. bootstrap-macos.sh installs the pinned 0.12 build (v0.12.4, arch-aware).
al2023 bootstrap NOT yet updated for the 2nd binary (do when touching that box).

CHECKHEALTH on 0.12 (user ran) confirmed the plan empirically:
- treesitter FULLY HEALTHY (all ✅, highlight active) — reconfirms it's NOT broken, just
  latent-update hazard. Rewrite is now a modernization, not a fix.
- `vim.deprecated` section = the evidence-backed to-do: vim.tbl_islist REMOVED-in-0.12 called by
  telescope 0.1.5 (most urgent — removed not just deprecated); vim.str_utfindex (nvim-cmp);
  vim.lsp.get_log_path (nvim-lspconfig); vim.validate{table} (LuaSnip/ufo/dap-ui). mason v1.11
  wants v2.3.1. which-key gc-overlap warning confirms built-in commenting present → Comment.nvim
  redundant.

PHASE 1 DONE + VERIFIED (2026-07-06, in sandbox on 0.12) — small safe batch, NOT the risky
interdependent LSP/cmp/telescope changes yet:
- rust-analyzer files.excludeDirs {.git,target,node_modules,.direnv,.venv} — filled in the
  previously-commented vim.g.rustaceanvim block in nvim-dev/.../after/ftplugin/rust.lua. THE
  original reopen-lag lever (less watcher/index churn).
- dropped FixCursorHold.nvim from neotest deps (obsolete since nvim 0.8 #20198). Verified gone:
  headless lazy.plugins() = 45 plugins, none match FixCursorHold; clean startup, no errors.
  (still physically in ~/.local/share/nvim-dev/lazy until :Lazy clean — harmless.)
Both files headless-parse + full startup clean on 0.12.4. Changes are in nvim-dev/ ONLY (sandbox);
daily nvim/ untouched. NOT yet promoted.

PHASE 2 (sandbox, interdependent 0.12 modernization, one verifiable sub-batch at a time):
- [x] 2a DONE 2026-07-06: telescope unpin tag='0.1.5' → version='*' (now v0.2.2). Lazy! update
  telescope.nvim in sandbox. VERIFIED: clean startup, telescope.builtin loads + find_files
  resolves, `vim.tbl_islist` (REMOVED-in-0.12) gone from checkhealth vim.deprecated (0 mentions).
  NOTE: `Lazy! restore` pins to LOCKFILE (kept 0.1.5) — must use `Lazy! update <plugin>` to
  advance a version='*'/branch spec + rewrite the sandbox lazy-lock.
- [x] 2b DONE 2026-07-06: treesitter master→main rewrite. editor.lua spec: branch='main',
  build=':TSUpdate', lazy=false. configs/treesitter.lua: `ensure` list (one lang/line, clean
  style per user), require('nvim-treesitter').install(ensure), FileType autocmd (NO pattern,
  pcall(vim.treesitter.start) — starts TS for ANY buffer w/ a parser, silently skips misses;
  sidesteps smithy/kotlin ft-vs-parser-name concern entirely + cleaner than a pattern list).
  Lazy! update nvim-treesitter checked out main (detached @ Apr-2026 commit, lazy pins by SHA).
  VERIFIED: main API present (install fn exists, old nvim-treesitter.configs module gone),
  clean startup (no ERRORS), highlight active=true on lua+rust+python.
  GOTCHA FOUND (real, recorded): parsers install to stdpath('data')/site/parser
  (~/.local/share/nvim-dev/site/parser), NOT the lazy plugin dir. install() is ASYNC — a
  --headless process starts it and exits before it finishes, so headless testing shows endless
  "Downloading..." + get_installed()=0. In INTERACTIVE use the async install completes once in
  bg and persists → subsequent launches are no-ops. Config is CORRECT; the re-download-every-run
  was a headless artifact. To pre-seed synchronously: require('nvim-treesitter').install({...}):wait(ms).
  First-ever interactive launch = highlighting appears ~1s late while parsers build (standard for
  main branch). vim-matchup: its matchup queries still load fine (checkhealth showed them);
  standalone, no TS-integration config needed.
- [x] 2c DONE 2026-07-06: LSP framework → native. configs/lsp.lua rewritten: mason.setup() +
  mason-lspconfig.setup{ensure_installed={lua_ls,pyright}} (automatic_enable default calls
  vim.lsp.enable); global caps via vim.lsp.config("*",{capabilities=cmp_nvim_lsp.default_capabilities()
  + didChangeWatchedFiles}); system servers via vim.lsp.enable({ts_ls,gopls}). DROPPED
  setup_handlers + all lspconfig.<x>.setup{}. LspAttach autocmd + keymaps UNCHANGED. editor.lua
  deps williamboman/* → mason-org/* (mason v2 line). VERIFIED: mason remotes=mason-org, clean
  startup, vim.lsp.config["*"]/lua_ls/ts_ls resolve, and lua_ls ATTACHES to a lua buffer (1 client).
- [x] 2d DONE 2026-07-06: rustaceanvim ^5→^9 (now v9.0.5, needs 0.12). Added
  server.capabilities = cmp_nvim_lsp.default_capabilities() to the vim.g.rustaceanvim block in
  after/ftplugin/rust.lua (v6+ dropped auto-registration → rust completion would degrade without).
  Kept files.excludeDirs. Confirmed NOT going through lspconfig/mason (rustaceanvim owns RA).
- [x] 2e DONE 2026-07-06: cmp→blink.cmp (user: "modernize it, wasn't set on nvim-cmp"). NEW
  configs/blink.lua (keymap preset='enter' + Tab=select_and_accept, S-Tab=select_prev,
  C-u/C-d=scroll docs — behavior parity w/ old cmp; snippets preset=luasnip; nerd_font icons
  replace lspkind; list.selection.preselect=false so <CR> only accepts explicit pick; bordered
  menu+docs; sources lsp/path/snippets/buffer; fuzzy prefer_rust_with_warning). editor.lua spec:
  single {saghen/blink.cmp, version='1.*', deps={LuaSnip}} REPLACES the 9-plugin nvim-cmp block
  (nvim-cmp + cmp-nvim-lsp/buffer/path/cmdline/nvim-lua + lspkind + cmp_luasnip + cmp-dap). Deleted
  configs/cmp.lua. DROPPED cmp-dap (DAP-REPL completion; niche, would need blink.compat — re-add
  blink-cmp-dap later if missed). DROPPED cmp-nvim-lua source (lua_ls covers nvim API completion).
  Swapped BOTH capability call sites cmp_nvim_lsp.default_capabilities() → blink.cmp.get_lsp_capabilities()
  (lsp.lua '*' config + rust.lua rustaceanvim server.capabilities).
  TWO SNAGS (both fixed, recorded): (1) cmp-nvim-lsp was STILL listed as an nvim-lspconfig
  dependency in editor.lua (missed in 2c) → its InsertEnter autocmd fired require('cmp')→ERROR.
  Removed the dep line, re-synced, cmp-nvim-lsp cleaned. (2) blink Rust matcher binary
  (libblink_cmp_fuzzy.dylib) auto-built on install (version='1.*' ships prebuilt). VERIFIED:
  blink loads + get_lsp_capabilities fn + lua_ls attaches (1 client) + blink loaded by lazy +
  clean startup; checkhealth vim.deprecated str_utfindex (cmp's) NOW 0 (also tbl_islist still 0).
- [x] 2f DONE 2026-07-06: dropped Comment.nvim (built-in gc/gcc/gbc since nvim 0.10). Removed
  the spec from core.lua; verified gc mapping exists on 0.12, plugin cleaned.
- [x] leap→flash DONE 2026-07-06: replaced ggandor/leap.nvim (unmaintained) with folke/flash.nvim
  in core.lua. Kept `s`=jump (muscle memory), `S`=treesitter, <c-s>=toggle in cmdline search.
  opts: modes.search.enabled=false + modes.char.enabled=false (leave / ? and f/t/F/T native).
  VERIFIED: leap add_default_mappings deprecation warning GONE from startup, flash loads, s mapped.
  Dropped leap's equivalence_classes (no flash equivalent; custom search.mode fn if ever needed).

FIDGET (user asked): `:Fidget history` empty is EXPECTED, not a bug. History only records
vim.notify-routed notifications after startup; LSP $/progress spinners (which work) are a
separate channel and don't populate history. Nothing to fix.

PHASE 2 COMPLETE (2a-2f + leap→flash), committed 79a468f. Sandbox nvim-dev fully modernized on
0.12.4, all verified headless + user-driven (Rust completion/docs/LSP-goto confirmed working).
NEXT: user drives nvim-dev on real work to shake out feel; THEN PROMOTE (copy nvim-dev/ verified
changes → nvim/, re-stow) — but daily nvim is 0.11.2 (brew) and several changes REQUIRE 0.12
(treesitter main, rustaceanvim v9). So promotion is GATED on upgrading daily nvim 0.11→0.12 (brew
upgrade neovim + al2023 bootstrap 0.12 tarball). Decide promotion + daily-upgrade together. THEN
lspmux (orig lag goal).
PROMOTION CHECKLIST when it happens: (a) copy nvim-dev/.config/nvim-dev/* → nvim/.config/nvim/;
(b) bump daily nvim to 0.12 (brew + al2023 bootstrap); (c) UPDATE dot/guides/nvim.md — it still
documents the OLD daily setup (leap `s`, Comment.nvim gc/gcc) which is CORRECT until promotion,
then must flip to flash (`s` jump / `S` treesitter) + built-in gc; (d) re-stow; (e) reconcile
lazy-lock. The nvim-dev sandbox itself stays as the standing experiment surface (don't delete).

ORTHOGONAL to the lag fix — user acknowledged. Sequencing proposed (not yet approved):
1. quick wins: rust-analyzer files.excludeDirs (target/, node_modules/) — the user's own
   instinct, directly reduces watcher/index churn; + diagnostics virtual_text state.
2. FIX treesitter (broken) + drop FixCursorHold.
3. LSP framework → native vim.lsp.config/enable.
4. completion: evaluate blink vs keep cmp.
5. THEN lspmux on the modernized base.
Agent IDs (resumable): LSP/cmp a3ddb7a135454b286, TS/tele/fold abeb3970dfda8ca3b,
edit/ui/motion a06bbe6b2e0a8de81, 0.12+dap/test a9e2fac86817efc03.

### zellij-persist-ssh  [PARKED 2026-07-08 — colors+zjk fixed; persistence STILL SUSPECT]

PARK NOTE 2026-07-08: user pivoting to real work on the remote; persistence debug on hold.
STATUS at park:
- FIXED + committed (3a201ee): colors regression (service got the user-manager's bare env →
  no TERM/COLORTERM/PATH in panes; now forwarded via systemd-run --setenv, user confirmed
  colors work); zjk broken (EXITED-only filter matched nothing once sessions stay live, and
  ignored $1 — now kills by name or picks from ALL sessions, and stops the backing service).
- STILL SUSPECT: user reports persistence "not working still" (sessions gone after
  disconnect+reconnect) DESPITE a clean manual test where `test2` service+server survived
  (PID 31287 alive after reconnect, session listed). CONTRADICTION UNRESOLVED — my read was
  "the vanished session was started before `exec zsh` (old --scope code)"; NOT confirmed.
- OPEN QUESTIONS to resolve when resumed:
  1. Does a session created by the CURRENT zjs (fresh shell, service+`-b`) survive, or only
     the hand-run `systemd-run` test? Isolate: fresh `exec zsh` → `zjs newname` → verify
     `systemctl --user is-active zellij-newname` + server pid, disconnect, reconnect, recheck.
  2. Is `zjs` actually taking the persist path on the remote, or silently falling to plain
     `zellij attach --create`? Check `_zj_persist_host` returns true there (SSH_CONNECTION set,
     systemd-run present, user mgr not offline).
  3. Does `zjs` reconnect AUTO-REATTACH, or land in a plain shell so live sessions look "gone"
     until you `zjs` again? (may be UX, not a persistence failure.)
- Mechanism PROVEN in isolation (service+`-b` survives; --scope does not). Gap is between that
  and the zjs code path / user workflow. Resume with the 3 questions above.

--- ORIGINAL (2026-06-28) — historical; --scope design below was WRONG, see resolution above ---

Problem: zellij session goes EXITED when the SSH connection to a remote (AL2023 dev desk)
drops, killing in-flight work (overnight builds/tests). Resurrectable, but the running
PROCESSES die — so work doesn't continue across a disconnect. Goal: a job started in zellij
survives SSH drop / logout.

>>> RESOLUTION 2026-07-08 (supersedes the --scope design below, which was WRONG): live testing
on the dev desk proved `systemd-run --user --scope` does NOT survive disconnect — the scope is
bound to the SSH session cgroup and gets cgroup-KILLed on logout (tell: list-sessions showed the
session "live" while the server pid was already dead = SIGKILL, not clean exit). A `--sleep` in a
scope only "survived" by reparenting to init; the zellij SERVER (daemon in the scope's cgroup)
did not. Isolation tests: `--scope` sleep → scope went inactive (process orphaned to init);
`--user --unit` transient SERVICE sleep → stayed active + alive across disconnect. DECISIVE end-
to-end: server started via `systemd-run --user --unit=zj-svctest --property=Type=forking zellij
attach --create-background svctest` → PID 17888 ALIVE after disconnect+reconnect, service active.
=> FIX = start the zellij SERVER headless in a lingering `--user` SERVICE via
`zellij attach --create-background` (short -b; exists since zellij 0.40, present in 0.44.3),
then `zellij attach <name>` as the foreground CLIENT. Linger (enable-linger) IS honored here;
it just doesn't protect scopes, only user-manager-owned services. BUILT: zjs rewritten around
_zj_attach (service+`-b` on remote-systemd, plain attach --create elsewhere) + _zj_persist_host
gate; old _zj_persist (--scope) removed. setup script + ssh guide comments corrected. Also fixed
the zjs new-name-in-picker bug (fzf exited 1 on typed-unmatched input) via --print-query.
USER RE-VERIFYING through the real zjs path (new-name launch + survive-disconnect). <<<

ROOT CAUSE (diagnosed 2026-06-28 on the live dev desk):
- `loginctl show-user $USER` → `Linger=no` (user manager does NOT persist past last session).
- No KillUserProcesses override anywhere → systemd default `KillUserProcesses=yes` → when the
  SSH session ends, logind tears down the SESSION SCOPE and SIGTERMs everything in it,
  including the zellij server.
- `systemctl --user is-system-running` → `running` (a `systemd --user` manager IS available
  to host a user-level scope).

KEY FACT (researched): lingering ALONE doesn't save a process — it keeps the user MANAGER
alive but a process still parented to the SESSION scope is killed regardless. The process
must be moved OUT of the session scope into the user hierarchy. So the fix is two parts:
  1. `loginctl enable-linger $USER`  (one-time per box; user manager survives logout)
  2. launch zellij via `systemd-run --user --scope zellij ...` (parents it to the user
     manager, not the session scope — surgical: ONLY zellij escapes the logout-kill,
     everything else still gets cleaned up normally on disconnect).
NO system-wide change needed (rejected flipping KillUserProcesses=no globally — root, blunt,
may not persist on a managed/reimaged box). User-space only.

REJECTED ALTERNATIVES: (A) KillUserProcesses=no system-wide — too broad, root, non-scoped.
(C) systemd-run --user --unit= (transient SERVICE) — wants non-interactive; --scope fits an
interactive multiplexer better. Non-systemd fallback (setsid/nohup the server) only if a box
lacks a user manager — not our case (AL2023 has one).

DESIGN (split per user's call — one-time setup separate from per-invocation): BUILT 2026-06-28.
- [x] ONE-TIME: standalone `zellij/setup-zellij-persistence.sh` — enables linger, idempotent
  (checks Linger state first), no-op off systemd (guards on loginctl), warns if systemd-run
  absent. Runnable one-off to fix THIS box; also referenced from bootstrap-al2023.sh.
- [x] PER-INVOCATION: `_zj_persist` helper in zellij.zsh wraps BOTH zjs attach paths
  (session-pick + dir-sessionize). Gates on $SSH_CONNECTION/$SSH_TTY set AND systemd-run
  present AND `systemctl --user is-system-running` != offline/empty (tolerates "degraded" so
  one failed user unit doesn't disable persistence). Uses `--scope --quiet --collect`. Plain
  exec otherwise (local macOS / no systemd-run / not over SSH). zsh -n clean.
- [x] bootstrap-al2023.sh calls the setup script; ssh guide documents the two-part fix.

VERIFY ON BOX (user, needs the dev desk) — exact sequence (order matters; linger only takes
effect on a FRESH login, so a session started before re-login will fail even if config is right):
  1. `./zellij/setup-zellij-persistence.sh`   (one-time; enables linger, needs sudo)
  2. FULLY log out of the dev desk and log back in  (linger activates on fresh login)
  3. `exec zsh`  (load the updated zjs/_zj_persist)
  4. `zjs` into a dir; in a pane start a marker: `sleep 600 &`  (or `while :; do date >> /tmp/alive; sleep 5; done &`)
  5. While still connected, CONFIRM PLACEMENT: `systemd-cgls --user` — the zellij server must
     appear under a `run-*.scope` in the USER manager, NOT under `session-*.scope`. If it's
     under session-*.scope the systemd-run wrap didn't take → persistence won't hold.
  6. DROP the connection UNGRACEFULLY (not `exit` — must mimic a yanked link):
       - in the ssh session, on a fresh line type the escape:  `~.`   (Enter, then ~, then .)
       - OR from a local terminal: `pkill -9 -f 'ssh .*sshdev'`
       - OR disable wifi ~30s (highest fidelity)
  7. Reconnect, `zjs` back — PASS = the marker process is still running (check `/tmp/alive`
     kept growing, or `jobs`/`pgrep -af sleep`).
If it still dies despite step 5 showing the user scope: investigate KillUserProcesses drop-in
(may need a user-level override) — but step-5 placement is the primary signal.

### claude-zj-plugin  [active — separate effort, context here]

User is building a new zellij plugin for Claude to replace `zj-kiro.wasm` (currently
auto-loaded via `load_plugins` in the live config). When stow-fix lands, the "keep zj-kiro?"
question becomes "wire in the new Claude plugin instead." Tracked so the two efforts stay
coherent.

### bootstrap-macos / broken-shells  [done 2026-06-22]

Symptom: new macOS shells "broken" (bare `%~ %#` prompt, no node/npm).
Root cause (live machine, NOT stale bootstrap): starship + fnm were brew-installed
but UNLINKED (no symlink in /opt/homebrew/bin) → `.zshrc` `command -v` probes failed →
starship fell back to minimal prompt; fnm eval never ran → no node/npm. Also
`starship.toml` had never been stowed. Old nvm world (brew keg + ~/.nvm v20/v22/v24)
still on disk but unloaded since the zshrc rewrite to fnm.

Fixed live:
- `brew install starship fnm` re-linked both (recreated /opt/homebrew/bin symlinks).
- `stow starship` → ~/.config/starship.toml now symlinked to dotfile.
- `fnm install --lts && fnm default lts-latest` → node v24.17.0 / npm 11.13.0.
- Removed orphaned nvm: `brew uninstall nvm` + `rm -rf ~/.nvm`.
- Verified in interactive login shell: all tools resolve, two-line prompt active.

Fixed bootstrap-macos.sh (rewrite, matches AL2023 rigor — UNCOMMITTED, `git status` M):
- `set -euo pipefail`, Homebrew auto-install guard, brew shellenv eval.
- Added `uv` (official installer → ~/.local/bin, parity w/ AL2023).
- Added `fd` to brew list (was missing); rust via rustup (not brew); fnm node LTS.
- Real `stow nvim zsh wezterm zellij starship tmux` apply step (was a bare comment —
  the exact trap that broke this machine: starship installed, config never stowed).
- Idempotent / re-runnable.

Note for future: `brew doctor` would have flagged the unlinked kegs. Unclear how they
got unlinked (past `brew unlink`, failed upgrade, or migration).

### cli-tools / shell-polish  [active 2026-06-22]

DONE:
- **ls/grep color regression fixed** (lost when oh-my-zsh dropped). zshrc probes
  `ls --color=auto` → GNU branch (alias), else CLICOLOR=1 (BSD). grep→`grep --color=auto`.
  This Mac has brew coreutils so GNU branch fires. Works on AL2023 too.
- **grep NOT aliased to ripgrep** (deliberate — different regex/recursion/flags would
  surprise scripts + muscle memory). Use `rg` by name. Rationale in zshrc comment.
- **zoxide 0.9.9 + bat 0.26.1 installed** (brew) + wired in zshrc:
  - zoxide: `eval "$(zoxide init zsh)"` → `z`/`zi`. NOT using `--cmd cd` yet (see open Q).
  - bat: BAT_THEME=Nord (matches nvim onenord), BAT_STYLE=numbers,changes,header,
    `cat`→`bat --paging=never`, MANPAGER routes man through bat.
- **Bootstrap updated BOTH:** macOS brew line +zoxide +bat; AL2023 `cargo install` line
  +bat +zoxide (not packaged, same as rg/fd). Both bootstraps now also call
  `./zellij/build-plugins.sh` after stow. Syntax-checked.

DEFERRED: lsd/eza (ls replacement) — user said wait.

### docs / cheatsheets  [active 2026-06-22]

User forgets own keybinds/tools — wants quickstart docs in the dotfiles.
Design principle: document things with NO live introspection (shell tools,
aliases, workflows); POINT AT live tools for things that have them (zellij
keybinds → F1/zellij-forgot; nvim → :Telescope keymaps). Avoids rot.

Style: KERNEL-STYLE docs/comments — contract not history. No project-state
narrative ("restores color lost when oh-my-zsh dropped" etc.). Scrubbed from
zshrc ls/grep/zoxide/bat comments too.

DONE:
- Docs split into per-tool SUBTOPICS, not one long sheet. `docs/sh/{zoxide,bat,fzf,
  search,node,python,aliases}.md` + `docs/README.md` index. Each file's H1
  "# name — tagline" feeds a GENERATED sub-index (add a file → appears automatically).
- `cheat` helper in zshrc: `cheat` (index), `cheat sh` (generated sub-index from H1s),
  `cheat sh zoxide` (subtopic), bad arg → error + fallback index. Renders via bat,
  tab-completes topics+subtopics.
- `$DOTFILES` env var set ONCE at source time from `${${(%):-%x}:A:h:h}` (this file's
  own path, :A follows stow symlink). Replaced the per-call readlink/cd resolution
  that the sandbox intermittently denied. Generally useful var beyond cheat.

PENDING (write when content is stable):
- zellij guide — the MODEL (autolock, seamless nav, lock); F1 = live keys.
- nvim guide — notable maps. Stable now; can write anytime.

### `dot` framework — personal reference + runnable snippets + functions  [active 2026-06-24]

RENAME: `cheat` → `dot` (cheat collides w/ cheat/cheat.sh tools + navi's "cheats"
vocabulary; also it's "more than a kb"). `dot` = named after dotfiles, scales to
repo-mgmt verbs later. Existing docs/sh/* + cheat()/_cheat() get migrated/removed.

MODEL (the coherent framework — single source of truth, fights doc-rot + alias-amnesia):
- Location: IN the repo, NOT stowed. Resolved via $DOTFILES (set at zshrc source time
  from ${${(%):-%x}:A:h:h}). Works on remote (repo cloned there). Layout:
    $DOTFILES/dot/
      guides/*.md      PROSE — "explain/remind how X works" (concepts)
      cheats/*.cheat   navi — executable/parameterized commands ("fill blanks + run")
  + zsh/functions/<domain>.zsh — custom functions w/ `#@ name : desc` doc lines,
    sourced by .zshrc in a loop.
- navi is the ENGINE for parameterized snippets (do NOT hand-roll a template engine).
  Confirmed via /private/tmp/navi source: `navi --print` emits filled cmd to stdout
  (→ onto prompt, not executed); `--query X --best-match` headless; `.cheat` vars can
  pull values from live commands (`$ branch: git branch|...`); caller can pre-set
  (`branch=x navi ...`). Point navi at cheats via NAVI_PATH=$DOTFILES/dot/cheats.
- `dot` dispatch:
    dot              index (guides + function list + cheat tags)
    dot <topic>      render a prose guide (via bat), or a domain's functions
    dot -s <query>   rg full-text across guides → fzf → jump
    dot run [query]  navi --print → filled command onto the prompt
- Split rule: .cheat = executable/parameterized; .md = conceptual prose. Most "syntax I
  forget" cases are .cheat. Doc-comment (#@) lives next to function → dot generates →
  can't rot.

DECISIONS:
- navi: install NOW + add to BOTH bootstrap scripts (macOS brew; AL2023 cargo install).
- NO keybindings yet — add per-function only when user finds themselves reaching for it.
- atuin: still deferred.

BUILD — DONE (2026-06-24), all verified in fresh login shell:
1. Skeleton: $DOTFILES/dot/{guides,cheats}/ + dot/README.md; zsh/functions/ sourced via
   loop in .zshrc; #@ doc convention; `dot` command (index/topic/-s search/run). Migrated
   docs/sh/* → dot/guides/ (git mv); removed old docs/ + cheat()/_cheat().
2. zsh/functions/zellij.zsh (zjo open, zjt jump, zjr rename, zjs sessionizer, zjl, zjk
   fzf-kill, zjclean — merged from former sessions.zsh + zjo.zsh on 2026-06-27),
   clip.zsh (cpath/cfpath/cfile/cpwd — the realpath|pbcopy workflow). All #@-documented,
   command -v guarded, show in `dot` index.
3. navi 2.24.0 installed (brew) + added to BOTH bootstraps. NAVI_PATH=$DOTFILES/dot/cheats.
   `dot run` → navi --print → print -z (cmd onto prompt buffer, not executed). Seeded
   dot/cheats/{clipboard,git}.cheat. Verified: `n=3 navi --query "interactive rebase"
   --print` → `git rebase -i HEAD~3` (fill-blanks works).
   Gotcha fixed: `paste -sd', '` cycles delimiters per-char (→ "clipboard,git path");
   use -sd',' then sed 's/,/, /g'.

NOT YET / next candidates: git.zsh (gs/gco/glog/gclean std names), fzf-pickers
(frg=rg→fzf→nvim+line, fkill), nav (cdg/mkcd/tmpd), brazil picker. atuin still deferred.
Note: `dot` bare shows GENERATED index (live, can't rot); dot/README.md is for repo browsers.

### ssh + words domains, grouped index  [done 2026-06-24]

- `dot` index now GROUPS functions by domain file. Convention: `#@@ domain : desc`
  (file header) + `#@ name : desc` (per function). BUG FIXED: `s/^#@ *//` matched `#@@`
  too → use `s/^#@ /` and `s/^#@@ /` (require the space; no `*`).
- ssh.zsh (`dot ssh` namespace): named targets = ssh-config Host entries (NOT a zsh alias —
  so ssh/scp/rsync all resolve them). Pickers fzf only CONCRETE hosts (globs like `Host *`
  filtered via awk `$i !~ /[*?]/`). Host registry decision: SSH config (machine-local),
  NOT committed.
  - sshto [host] [-- cmd]: JUST CONNECTS — `ssh -t host` (login shell, so remote dotfiles/PATH
    apply) or `ssh -t host -- cmd` for a one-off. NO zellij logic (see below).
  - sshput (rsync local→remote, fzf host+dir), sshget (rsync remote→local THEN cpath the
    local path — closes the "pull file → path on clipboard for Claude" loop), sshcp
    (copy host:/abs/path).
  - BUG FIXED (2026-06-25): fzf-picked host carried trailing whitespace → ssh dropped the
    `HostName` rewrite (dev-dsk full name → `dev-dsk-al2023` Corp-Fabric short name) → wssh
    "403 unable to resolve". Fix: `_ssh_pick_host` trims `${h//[[:space:]]/}` (protects all 4
    helpers). User-confirmed fixed. (Couldn't repro 403 in-sandbox — no wssh.)
  - DESIGN (2026-06-25): DROPPED zellij auto-attach from sshto entirely. It caused a
    non-login-shell PATH problem (ssh host CMD = `$SHELL -c`, sources only .zshenv; our PATH is
    in .zshrc/interactive). Rather than hardcode ~/.local/bin or wrestle login/interactive shell
    sourcing + remote-rc opt-out (env-forward needs sshd AcceptEnv), we removed the concern:
    sshto just connects (login shell), and on a dotfiles host the SESSIONIZER (`zjs`) handles
    zellij there. ssh stays ssh; zellij concerns stay in zellij tooling. Guide updated to match.
- clip.zsh: removed cpwd (redundant w/ `cpath` no-arg). Remote-path-copy lives in ssh
  domain (sshcp), NOT a cpath variant — keeps cpath a pure-local, can't-hang helper.
- words.zsh: `dict <word>` / `-s` synonyms / `-a` antonyms. dictionaryapi.dev JSON + jq
  (one robust source vs scraping dict.org prose). SHADOWS the `dict` protocol client (fine,
  we use curl+jq). Added jq to bootstraps (brew; AL2023 dnf — it IS packaged there).
- Mode indicator: decided LEFT-side [N]/[I] via starship native vi-mode (NOT RPROMPT —
  too fragile: zle-keymap-select hook + scroll quirks). NOT YET BUILT.

MORE DOMAINS + GUIDES DONE (2026-06-24):
- git.zsh (gs/glog/gco fzf-branch/gcm/gclean fzf-merged/groot), find.zsh (frg=rg→fzf→nvim+line/
  ff/fkill/fcd), nav.zsh (mkcd/tmpd/up). All #@@/#@ documented, grouped in index.
- Guides: dot/guides/nvim.md (verified maps from telescope.lua/lsp.lua/config.lua; points at
  which-key `,` + :Telescope keymaps as live source), zellij.md (sessions/zj*/resurrection/
  remote; keybinds → F1 since real config awaits stow-fix).
- Now: 11 guides, 7 function domains (clip/find/git/nav/sessions/ssh/words), 4 cheats.
- starship double-init guard fixed (FUNCNEST recursion on ESC). USER ACTION: needs a fresh
  shell to clear the already-broken widget + verify [N] indicator live.

PLANNED GRADUATION: `dot` → its own Rust CLI, built+vendored via the existing
build-plugins.sh / plugins.lock machinery (pinned SHA → cargo → gitignored binary).
Reason: the index is a parser (extract #@/#@@, group, format) and sed/awk-in-zsh is
brittle (already hit the #@@ collision). Port ONCE the design/content stabilizes — not
while it's moving. Shell shrinks to a thin wrapper. Trigger when sed pain recurs.

TRIO DONE (2026-06-24):
- starship [character]: [I] green (insert) / [N] amber (normal). Uses starship's built-in
  zle-keymap-select redraw (no RPROMPT hook).
  BUG FOUND+FIXED: double-sourcing .zshrc (e.g. `source ~/.zshrc` to test edits) made
  starship's keymap-select wrapper preserve ITSELF as the "original" → infinite recursion
  on ESC (FUNCNEST: maximum nested function level). Fix: guard starship init with
  _STARSHIP_INITED so it runs once per shell. Need a FRESH shell to clear an already-broken
  widget (re-source in the broken session won't fix it).
- dot/guides/ssh.md (named-target model, helper family, zellij-remote rationale, rsync ref).
- dot/cheats/ssh.cheat (rsync/scp/ssh/port-forward, <host> pulled from ssh config via awk).
  Verified navi --print emits the parameterized template.

### bin-package + cargo-reclaim  [done 2026-07-01; test-drive pending]

Needed a home for hand-written scripts (cargo-reclaim was loose in repo root). Decisions:
- **NEW stow package `bin/`** → maps `bin/opt/bin/*` to `~/opt/bin` (already on PATH via
  zshrc line 63 `_append_path "$HOME/opt/bin"`). Chose ~/opt/bin over ~/.local/bin
  DELIBERATELY (user's call): .local/bin is where bootstrap dumps DOWNLOADED release binaries
  (starship/fnm/uv/zellij); ~/opt/bin is the "mine / dotfiles-tracked" dir — obvious ownership.
- Script name kept as `cargo-reclaim` (user's call). cargo- prefix => also invokable `cargo reclaim`.
- Wired `bin` into stow apply lines: both bootstraps + CLAUDE.md. cargo-clean-all added to
  BOTH bootstraps (macos: `cargo install`; al2023: appended to the cargo install line).
- stow -n bin: folds ~/opt → bin/opt (tree-folding, since ~/opt didn't exist). Fine; noted that
  while folded, new files dropped in ~/opt land inside the repo. Offered a placeholder to force
  no-folding if user wants ~/opt to stay a real dir — user didn't request it.

cargo-reclaim vs cargo-clean-all ANALYSIS (dnlmlr/cargo-clean-all):
- clean-all BETTER: parallel delete (-t), --keep-days N (skip recently-built), --keep-executable,
  interactive TUI (-i), maintained, `cargo install`. 
- OURS BETTER: CACHEDIR.TAG SIGNATURE check (clean-all deletes by dir/project detection, NO tag
  verify per its README) → safer vs coincidental "target" dirs; catches ORPHANED target/ dirs
  (Cargo.toml gone) since we scan target/CACHEDIR.TAG directly; zero deps beyond fd; dry-run default.
- VERDICT given: clean-all is the better general tool, ours is safer+narrower (sig-verified,
  orphan-aware). Recommended keep ours. User: keep minimal, ALSO install clean-all to test-drive,
  decide later. So both coexist for now; DECISION PENDING user's test-drive.
- If keeping ours long-term, the one worth-stealing feature is --keep-days (~5 lines). Deferred.

Smoke-tested from new location (syntax, --help, dry-run) OK. `stow bin` NOT yet applied on the
live mac (user action, like other stows).

### wezterm-tabs  [done 2026-06-30]

QoL + consistency for wezterm tabs (the OUTER layer; zellij tabs are inner). User keeps
separate wezterm tabs for SSH/remote + occasional extras. Added 3 CMD-based binds to
wezterm/.config/wezterm/wezterm.lua (+ `local act = wezterm.action`):
- ⌘P  ShowLauncherArgs{FUZZY|TABS}  — fuzzy tab switcher (zjt analog)
- ⌘E  PromptInputLine → active_tab:set_title (zjr analog; nil=ESC cancel, ""=auto title)
- ⌘⇧←/→  MoveTabRelative -1/+1  — reorder (defaults' ⌘⇧[/] only NAVIGATE)
Validated via `wezterm show-keys` + luac parse.

KEY DESIGN PRINCIPLE: CMD is the conflict-free layer — zellij/nvim run INSIDE wezterm and
never see CMD (wezterm intercepts), so CMD binds can't shadow zellij mode-prefixes
(Ctrl-t/p/n/o/s/g/b) or nvim maps. Ctrl/Alt fall THROUGH to zellij. NOTE on user's existing
muscle memory (left as-is per user, not remapped): `Ctrl-t` = zellij tab prefix (NOT wezterm),
`Ctrl-Shift-T` = wezterm SpawnTab (new tab, not back-nav), `Alt-n` = zellij NewPane.

KEYBOARD FINDING (user works from both a PC-shaped external kbd + the mac laptop kbd, always
forgets the mapping): macOS maps by key IDENTITY not position — PC Windows key → ⌘/SUPER,
PC Alt → ⌥/OPT. So one CMD binding fires from BOTH keyboards (Win key IS Cmd). The fumble is
POSITIONAL: bottom row Ctrl|Win|Alt|Space (PC) vs Ctrl|Opt|Cmd|Space (mac) → ⌘ is one key
further right on the laptop. Caveat: assumes no System Settings modifier remap.

Docs: new dot/guides/wezterm.md (two-tab-layer model, CMD-vs-Ctrl rule, the two-keyboard
mapping table, custom + default tab keys, panes-left-to-zellij rationale). 12 guides now.
Persistence intentionally NOT pursued: wezterm tabs are local GUI state (no disconnect to
survive); wezterm's mux-server would duplicate zellij → rejected (no nesting).

### line-editing keymap toggle  [done 2026-06-24]

Discovery: shell was in vi mode BY ACCIDENT (zsh infers vi from EDITOR=nvim matching "vi"),
unconfigured → emacs keys (Ctrl-A/E/K/Y) dead, ESC lag, no mode indicator. User is a vim
user but wanted to A/B both → built a TOGGLE, not a fixed choice.
- `keymap [vi|emacs]` function in zshrc: switches live, persists to ~/.zsh_keymap
  (machine-local, NOT committed). Default vi. vi sets KEYTIMEOUT=1 (kills ESC lag);
  emacs sets 40.
- Both modes rebind: Ctrl-P (fzf→nvim), Ctrl-R (fzf history), and emacs keys
  Ctrl-A/E/K/U/W/Y as an insert-mode safety net so nothing is stranded.
- edit-command-line enabled: Ctrl-X Ctrl-E (both modes) + `v` in vi-normal → edit cmd in nvim.
- starship [character]: vimcmd_symbol amber ❮ (normal) vs green ❯ (insert) = live mode cue.
- `dot/guides/keys.md` documents both modes. (Self-corrected: `v`/edit-command-line is NOT
  a zsh default — had to autoload+zle -N it; guide fixed to match.)
- Must apply keymap AFTER fzf sourced (so Ctrl-R points into the live keymap).

Open questions (muscle-memory decisions — flip after living with them):
- zoxide `--cmd cd`: replace `cd` entirely so every nav trains zoxide? (Currently additive:
  `z` only, `cd` untouched. `--cmd cd` ramps faster but retrains the reflex.)
- bat `cat` alias: keep `cat`→bat, or leave cat as cat and use `bat` by name? (Some dislike
  cat being aliased for piping/scripts — though --paging=never keeps it pipe-safe.)

### zellij + SSH  [researched 2026-06-23 — recommend punt-build, adopt-habit]

Core tension (a triangle, pick 2): session-resumption needs the mux ON THE REMOTE;
single-pane-of-glass tempts running everything in LOCAL zellij; combining them =
nested zellij, which collides on keybinds (prefix/lock/Ctrl-hjkl).

Findings:
- Nesting is a KNOWN UNSOLVED pain — zellij creator (imsnif) works around it w/ a
  separate window (issues #387, #775, #1607; "wormhole"/unified-session fix is roadmap,
  unimplemented). Workarounds exist (lock+Write bypass PR #4770, dual-prefix, Alt-based)
  but all are "pliers as a hammer."
- autolock-on-ssh (add `ssh` to triggers): local zellij auto-locks on SSH pane, keys pass
  to remote. WORKS but taxes the common action — local pane nav needs Alt-z unlock toggle
  while in an SSH pane. Not worth it.
- zellij is client-server: remote server SURVIVES SSH drops. `ssh -t host 'zellij attach -c
  main'` = attach-or-create, reconnects to live session after a drop. Live daemon covers
  disconnects; disk serialization (default on) only matters for remote reboots.
- WezTerm SSH/mux domains: native local panes for remote, no nesting — but needs wezterm
  binary on AL2023 + may choke on corp jump hosts. TLS domains auto-reconnect; SSH domains
  need manual reconnect. Corporate-network risk.
- mosh: best laptop-sleep resilience BUT needs UDP 60000-61000 (corp networks often block).

DONE (2026-06-23): SSH prompt indicator. starship `[hostname]` ssh_only, globe ssh_symbol,
placed on the directory block's blue bg (no own separator → collapses clean when local).
Verified: absent locally, "󰢹 <host>" before path under SSH_CONNECTION.

DECIDED (2026-06-23): User keeps the separate-tab SSH approach (Option B): SSH in a
separate WezTerm tab → remote zellij (`zellij attach -c`). NO nesting, NO autolock-ssh
trigger, NO local-mux change (user uses zellij locally — WezTerm-splits-as-local-mux idea
was WRONG and dropped; WezTerm is just the emulator). zellij stays the local multiplexer.
`sshz` helper still nice-to-have but not prioritized; user juggles tabs by choice.
- SSH PROMPT INDICATOR: DONE (see above).

### project-workflow + clone  [design / mulling 2026-06-24]

User's current convention (working, but manual): each project = a zellij TAB named for it.
Tab has pane(s): one running claude in the project's PLANNING dir (~/sandbox/rs/ai/<project>),
another shell in the SOURCE dir (varies, usually ~/sandbox/rs/...). Renames tabs+panes by hand.
Pain: must remember to add source dir to claude, which agent to launch, manual naming.

DECIDED DIRECTION (2026-06-24): DECOUPLE tooling from repo shape. Project registry =
machine-local STATE in ~/.config/dot/ (NOT committed; dirs vary by machine — like ~/.zsh_keymap,
~/.ssh/config). Planning FILES stay where they are today (~/sandbox/rs/ai/<proj>). User migrates
to monorepo on their own time; tooling is agnostic. Integrate as `dot project <subcmd>` /
`dot new-project`. "Assume monorepo but don't treat it as one."

SETTLED TAXONOMY (2026-06-25, extended 2026-06-27) — all in ONE domain file
zsh/functions/zellij.zsh (merged zjo.zsh + sessions.zsh 2026-06-27 so `dot` groups all
zj* under one `#@@ zellij` header instead of zjo dangling alphabetically last):
- `z`              cd in place (zoxide; exists)
- `zjo [name]`     open a DIR in a new pane (-t tab, -f floating); no arg = picker.
                   Like `z` but new surface. DONE (see below).
- `zjo --project <name>`  open a project as a tab w/ layout (planning+source panes).
                   DEFERRED — needs KDL layout + claude --add-dir design. Stub errors for now.
- `zjt [name]`     jump to a tab by name (no arg = fzf-pick from query-tab-names). DONE.
- `zjr [name]`     rename focused TAB (-p = focused pane); no arg = vared prompt. DONE.
- `zjs`            session-level sessionizer / SWITCH sessions. Different AXIS from
                   zjo: zjo opens within current session; zjs switches which session.
                   UNIONED 2026-06-27 to list live+exited sessions alongside zoxide dirs.
- `zjl/zjk/zjclean` session mgmt (exist).
- `dot`            reference + roots config + (future) project mgmt. Does NOT define projects
                   beyond convention + per-project override files.

ROOTS CONFIG (DONE): zshrc sets DOT_SRC/DOT_3P/DOT_PLANNING with defaults
(~/sandbox, ~/sandbox/3P, ~/sandbox/planning), overridable via sourced ~/.config/dot/config
(KEY=value). NOTE: defaults don't match current on-disk (~/sandbox/rs/ai, ~/sandbox/rs/3P) —
user migrates or sets config. 3P is GLOBAL (one shared pool, not per-project).

zjo DONE (2026-06-25): zsh/functions/zellij.zsh (was zjo.zsh). Picker = zoxide frecent ∪
children of $DOT_SRC/$DOT_3P (union, deduped). Explicit dir | zoxide-query-resolve | fzf
picker. Outside zellij → cd fallback. pane=new-pane --cwd --name, float=--floating,
tab=new-tab. new-pane/new-tab echo pane id to stdout (0.44 scripting) → silenced w/ >/dev/null.

zjt/zjr DONE (2026-06-27): zjt = go-to-tab-name (arg) or fzf over query-tab-names (no arg).
zjr = rename-tab (default) / rename-pane (-p); no arg → vared interactive prompt. Both guard
on $ZELLIJ. Keybind equivalents still gated on stow-fix; these are the CLI path.

zjs UNION DONE (2026-06-27): was dir-only (zoxide). Now _zjs_candidates emits tab-delimited
"<kind>\t<payload>\t<display>" rows: live+exited sessions (marked) first, then zoxide dirs.
fzf --delimiter=tab --with-nth=3.. shows only display; pick routes by kind (session→attach,
dir→sessionize by basename). Closes the gap where an existing session whose dir you can't
zoxide-to was unreachable via zjs. Raw `zellij attach <name>` is now just the escape hatch.

--project DEFERRED design (capture, pick up after basic zjo settles):
- Convention by default: planning=$DOT_PLANNING/<name> (the anchor/name), src=$DOT_SRC/<name>.
- BUT src often DIVERGES from planning name (real case) AND can be MULTIPLE dirs → needs a
  per-project OVERRIDE. Structure: ~/.config/dot/{config, projects/<name>}. projects/<name>
  lists src dir(s); absent → convention. Single root config + per-project override files.
- src list does DOUBLE DUTY: panes to open + `claude --add-dir <each>` args (run claude from
  planning dir w/ all src dirs added — kills the "forgot to add-dir" pain). DESIGN W/ KDL.

STILL OPEN (separate from tooling, user's own time):
- Private HOSTING for planning monorepo (not gitfarm-per-project, not shared). NEEDS RESEARCH.
- Cross-project knowledge sharing → monorepo shared/ dir once migrated.

DONE 2026-06-24:
- clone.zsh: `clone <url|owner/repo>` → ~/sandbox/rs/3P/<repo> (depth-1, pulls if exists, cd's
  in); `clone -t` → /tmp throwaway. github shorthand expands.
- Mode indicator: switched ACTIVE to mode-COLORED ❯ glyph (green insert / amber normal) per
  user lean. NOT a live toggle — starship TOML has no conditionals; a live swap would need
  STARSHIP_CONFIG file-swapping (not worth it for cosmetic). Instead: the [I]/[N] text variant
  is a commented ALT block right below in starship.toml — swap = uncomment + reload. RPROMPT
  NOT used (stays on character module, no FUNCNEST risk).

Mode indicator refinement request: move [I]/[N] to the TOP prompt line (before path), make the
input line a `>`/glyph colored by mode. CONSTRAINT: starship's only vi-aware module is
`character` (one instance) — can't natively do I/N-on-top AND mode-colored-`>`-on-bottom. Options:
(a) I/N badge top + static `>` bottom [most native], (b) mode-colored glyph bottom only [current
minus text], (c) both via zsh zle-keymap-select var + custom module [complex, FUNCNEST-risk].

## Cross-Cutting Open Questions

- bosun.md: RESOLVED 2026-07-08 — commit it normally (the earlier "keep uncommitted" rule
  retired; landed in commit 0c69c43 and kept that way).
- Machine-local state convention emerging: ~/.zsh_keymap, ~/.ssh/config, and (planned)
  ~/.config/dot/projects/. Things that vary by machine or are personal/private live there,
  NOT in the committed repo.

## Deferred

- stow-fix (above) — user chose to defer.

## Consider later (raised, not yet evaluated)

- **markdown terminal viewer** — raised 2026-06-27. Compare candidates when picked up:
    * mdterm (https://github.com/bahdotsh/mdterm)
    * glow  (https://github.com/charmbracelet/glow) — charm, well-maintained, has pager/TUI
  Evaluate fit + overlap with what we already have (bat renders md w/ syntax highlight; `dot`
  guides currently render via bat). Question to answer: does a real md renderer earn a place
  alongside bat, and could `dot`/`dot run` use it for guides? glow is the incumbent to beat.
