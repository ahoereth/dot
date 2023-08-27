#!/bin/bash

mosh="mosh --experimental-remote-ip=remote"

session=portal
tmux kill-session -t $session
tmux new-session -d -s $session

window=0
inner=core
tmux rename-window -t $session:$window super
tmux send-keys -t $session:$window "$mosh portalsuper1" C-m
tmux send-keys -t $session:$window "tmux new-session -d -s $inner || true" C-m
tmux send-keys -t $session:$window "tmux rename-window -t $inner:0 core0" C-m
tmux send-keys -t $session:$window "tmux new-window -t $inner:1 -n core1" C-m
tmux send-keys -t $session:$window "tmux a -t $inner:0" C-m

window=1
inner=tsn0
tmux new-window -t $session:$window -n tsn0
tmux send-keys -t $session:$window "$mosh portaljetson1" C-m
tmux send-keys -t $session:$window "tmux new-session -d -s $inner || true" C-m
tmux send-keys -t $session:$window "tmux rename-window -t $inner:0 $inner" C-m
tmux send-keys -t $session:$window "tmux new-window -t $inner:1 -n build" C-m
tmux send-keys -t $session:$window "tmux a -t $inner:0" C-m

window=2
inner=tsn1
tmux new-window -t $session:$window -n tsn1
tmux send-keys -t $session:$window "$mosh portaljetson2" C-m
tmux send-keys -t $session:$window "tmux new-session -d -s $inner || true" C-m
tmux send-keys -t $session:$window "tmux rename-window -t $inner:0 $inner" C-m
tmux send-keys -t $session:$window "tmux new-window -t $inner:1 -n build" C-m
tmux send-keys -t $session:$window "tmux a -t $inner:0" C-m

window=3
inner=ssn
tmux new-window -t $session:$window -n ssn
tmux send-keys -t $session:$window "$mosh portaljetson3" C-m
tmux send-keys -t $session:$window "tmux new-session -d -s $inner || true" C-m
tmux send-keys -t $session:$window "tmux rename-window -t $inner:0 $inner" C-m
tmux send-keys -t $session:$window "tmux new-window -t $inner:1 -n build" C-m
tmux send-keys -t $session:$window "tmux a -t $inner:0" C-m

tmux a -t $session:0
