LUA := ./env-5.4/bin/lua
LUA_PATH_SETUP = LUA_PATH="./src/?.lua;./src/?/init.lua;$$LUA_PATH"

.PHONY: repl loop-test

# 경로 잡힌 REPL
repl:
	@$(LUA_PATH_SETUP) $(LUA) -i -e "aether = require('aether')"

# event_loop A/B 동시성 확인
loop-test:
	@$(LUA_PATH_SETUP) $(LUA) examples/loop_test.lua