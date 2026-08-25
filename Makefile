# Aether — dev Makefile
# 예제 타깃은 examples/*.lua 를 자동 탐색한다. 파일을 추가하면 타깃도 자동으로 생긴다.

LUA      ?= ./env-5.4/bin/lua
LUAC     ?= ./env-5.4/bin/luac
LUAROCKS ?= ./env-5.4/bin/luarocks
BUSTED   ?= ./env-5.4/bin/busted

SRC_DIR      := src
SPEC_DIR     := spec
EXAMPLES_DIR := examples

# examples/crypto_test.lua -> crypto_test
EXAMPLES := $(patsubst $(EXAMPLES_DIR)/%.lua,%,$(wildcard $(EXAMPLES_DIR)/*.lua))
# crypto_test -> crypto-test (기존 하이픈 타깃 호환용 별칭)
ALIASES  := $(filter-out $(EXAMPLES),$(subst _,-,$(EXAMPLES)))

# luarocks 트리(cqueues, luaossl ...) + src/ 를 LUA_PATH 에 얹는다
RUN = eval "$$($(LUAROCKS) path)"; \
      export LUA_PATH="./$(SRC_DIR)/?.lua;./$(SRC_DIR)/?/init.lua;$$LUA_PATH";

ifeq ($(wildcard $(LUA)),)
$(warning [aether] $(LUA) 를 찾을 수 없습니다 — 로컬 Lua 5.4 env 를 먼저 만들어 주세요)
endif

.DEFAULT_GOAL := help
.PHONY: help list test check repl $(EXAMPLES) $(ALIASES)

help:
	@echo "Aether dev targets"
	@echo ""
	@echo "  make <example>    examples/<example>.lua 실행"
	@echo "  make list         실행 가능한 예제 목록"
	@echo "  make test         spec/ 를 busted 로 실행"
	@echo "  make check        모든 .lua 문법 검사 (luac -p)"
	@echo "  make repl         LUA_PATH 가 잡힌 대화형 lua"
	@echo ""
	@$(MAKE) --no-print-directory list

list:
	@for e in $(EXAMPLES); do echo "  make $$e"; done

# examples/*.lua -> 같은 이름의 타깃
$(EXAMPLES): %: $(EXAMPLES_DIR)/%.lua
	@$(RUN) $(LUA) $<

# crypto-test 처럼 하이픈으로도 호출할 수 있게
$(ALIASES):
	@$(MAKE) --no-print-directory $(subst -,_,$@)

test:
	@if [ ! -x $(BUSTED) ]; then \
		echo "busted 가 없습니다 -> $(LUAROCKS) install busted"; exit 1; \
	fi
	@$(RUN) $(BUSTED) $(SPEC_DIR)/

check:
	@fail=0; \
	for f in $$(find $(SRC_DIR) $(EXAMPLES_DIR) $(SPEC_DIR) -name '*.lua' | sort); do \
		$(LUAC) -p "$$f" || fail=1; \
	done; \
	if [ $$fail -eq 0 ]; then echo "syntax OK"; else exit 1; fi

repl:
	@$(RUN) $(LUA) -i
