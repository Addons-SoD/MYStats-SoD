"""Lua 语法检查（wow-forever 分支交付物）。

用法：
    python -m pip install --quiet luaparser
    python tools/check_lua_syntax.py

遍历仓库内所有 .lua 文件（跳过 .git 与临时目录），用 luaparser 逐一解析，
任何文件解析失败都会退出码 1，便于在 CI 或提交前做自检。
"""
import pathlib
import sys

from luaparser import ast

SKIP_DIRS = {'.git', 'tools', '.tmp-api-docs'}


def main():
    files = sorted(
        p for p in pathlib.Path('.').rglob('*.lua')
        if not any(part in SKIP_DIRS for part in p.parts)
    )

    failed = 0
    for path in files:
        source = path.read_text(encoding='utf-8')
        try:
            ast.parse(source)
        except Exception as exc:  # noqa: BLE001 - 失败原因需要原样打印
            failed += 1
            print('FAIL %-50s %s: %s' % (path, type(exc).__name__, exc))
        else:
            print('OK   %s' % path)

    print('')
    print('checked %d file(s), failed %d' % (len(files), failed))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
