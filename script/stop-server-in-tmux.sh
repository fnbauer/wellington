#!/usr/bin/env bash

# Copyright 2020 Chris Rose
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
if hash tmux 2>/dev/null; then
    if tmux has-session -t wellington; then
        tmux kill-session -t wellington
    fi
else
    echo "tmux not found; skipping tmux service step"
fi
