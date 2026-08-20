LUA := ./env-5.4/bin/lua
LUAROCKS := ./env-5.4/bin/luarocks

# luarocks가 설치한 것들의 경로 + 우리 프로젝트 경로
LUA_PATH_SETUP = eval "$$($(LUAROCKS) path)" && export LUA_PATH="./src/?.lua;./src/?/init.lua;$$LUA_PATH"

.PHONY: hello loop-test repl

hello:
	@$(LUA_PATH_SETUP) && $(LUA) examples/hello_tcp.lua

loop-test:
	@$(LUA_PATH_SETUP) && $(LUA) examples/loop_test.lua

repl:
	@$(LUA_PATH_SETUP) && $(LUA) -i