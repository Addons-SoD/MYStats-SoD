# MYStats-SoD

MYStats addon for World of Warcraft Classic Era (Season of Discovery).

## Branches

- `main` — 怀旧服（Classic Era / SoD），`## Interface: 11507`（原版）。
- `wow-forever` — 移植到「魔兽世界：无限」（WoW Forever，客户端目录 `_forever_`，产品代号 `wowf`，1.60.1），
  `## Interface: 16001`。API 兼容层见 `MYStatsCompat.lua`：旧式全局缺失时才定义、
  内部转发到现代 `C_` API；天赋标签 API 已随 10.0 改版移除，相关统计安全降级为「无天赋加成」。

## Install

1. Download the latest `MYStats` folder from this repository (or clone it).
2. Copy the `MYStats` folder into your game's `Interface\AddOns` directory.

## Syntax check

```bash
python -m pip install --quiet luaparser
python tools/check_lua_syntax.py
```

## License

MIT - see [LICENSE](LICENSE).
