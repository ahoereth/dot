#!/bin/zsh
# Initialize ROS indigo.
source /opt/ros/indigo/setup.zsh
export PYTHONPATH=/opt/ros/indigo/lib/python2.7/site-packages:$PYTHONPATH
export PKG_CONFIG_PATH="/opt/ros/indigo/lib/pkgconfig:$PKG_CONFIG_PATH"
alias catkin_make="\ 
    catkin_make -DPYTHON_EXECUTABLE=/usr/bin/python2 \
                -DPYTHON_INCLUDE_DIR=/usr/include/python2.7 \
                -DPYTHON_LIBRARY=/usr/lib/libpython2.7.so"
echo "Sourced relevant ROS indigo files and set environment variables."
