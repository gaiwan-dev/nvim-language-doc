#!/bin/bash

nvim --headless -u scripts/minimal_init.lua -c \
  "lua require('plenary.busted').run('lua/nvim-language-doc/test/python_spec.lua', {minimal_init = 'scripts/minimal_init.lua'})"

