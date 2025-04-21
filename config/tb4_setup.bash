export ROS_DOMAIN_ID=0
export ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# !!!important!!! for TB4_1
export ROS_SUPER_CLIENT=True
export ROS_DISCOVERY_SERVER=";192.168.79.228:11811;"

# # !!!important!!! for TB4_2
# export ROS_SUPER_CLIENT=True
# export ROS_DISCOVERY_SERVER=";192.168.79.215:11888;"

# old or not used yet
# export FASTRTPS_DEFAULT_PROFILES_FILE=$HOME/${WS_DIR}/config/fastdds_mrc.xml
# export ROS_LOCALHOST_ONLY=0