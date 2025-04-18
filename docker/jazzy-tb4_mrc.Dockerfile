##############
# modified full ubuntu image #
##############
FROM osrf/ros:jazzy-desktop AS jazzy-mod_desktop

# Set default shell
SHELL ["/bin/bash", "-c"]

ENV HOME=/root
WORKDIR ${HOME}

ENV DEBIAN_FRONTEND=noninteractive

# Basic setup
RUN apt-get update && apt-get install -y --no-install-recommends --allow-unauthenticated \
    autoconf \
    automake \
    bash-completion \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    g++ \
    git \
    iproute2 \
    iputils-ping \
    libxext-dev \
    libx11-dev \
    make \
    mc \
    mesa-utils \
    nano \
    pkg-config \
    software-properties-common \
    sudo \
    tmux \
    tzdata \
    xclip \
    x11proto-gl-dev && \
    sudo rm -rf /var/lib/apt/lists/*

# Set datetime and timezone correctly
RUN sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' | sudo tee -a /etc/timezone

ENV DEBIAN_FRONTEND=dialog


##############
# Aux ROS2 packages #
##############
FROM jazzy-mod_desktop AS jazzy-dev

# Install ROS packages
RUN sudo apt-get update && sudo apt-get install -y \
    ros-dev-tools \
    ros-jazzy-xacro \
    python-is-python3 \
    python3-pip \
    python3-colcon-common-extensions python3-vcstool && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# upgrading colcon package to fix symlink issues
RUN pip3 install setuptools==58.2.0 --break-system-packages

# removing the default user because its uid/gid might conflict
RUN userdel -r ubuntu


##############
# user with matching uid and gid#
##############
FROM jazzy-dev AS jazzy-user

ARG WS_DIR="dir_ws"
ARG USERNAME=user
ARG userid=1111
ARG groupid=1111
ARG PW=user@123

RUN groupadd -g ${groupid} -o ${USERNAME}
RUN useradd --system --create-home --home-dir /home/${USERNAME} --shell /bin/bash --uid ${userid} -g ${groupid} --groups sudo,video ${USERNAME} && \
    echo "${USERNAME}:${PW}" | chpasswd && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV USER=${USERNAME} \
    WS_DIR=${WS_DIR} \
    LANG=en_US.UTF-8 \
    HOME=/home/${USERNAME} \
    XDG_RUNTIME_DIR=/run/user/${userid} \
    TZ=America/New_York

USER ${USERNAME}
WORKDIR ${HOME}

# custom Bash prompt
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc

RUN sudo mkdir -p -m 0700 /run/user/${userid} && \
    sudo chown ${USERNAME}:${USERNAME} /run/user/${userid}

# Setup tmux config
ADD --chown=${USERNAME}:${USERNAME} https://raw.githubusercontent.com/MarylandRoboticsCenter/someConfigs/refs/heads/master/.tmux_K.conf $HOME/.tmux.conf


#####################
# ROS2 workspace #
#####################
FROM jazzy-user AS jazzy-user_ws

WORKDIR ${HOME}

# Create workspace folder
RUN source /opt/ros/jazzy/setup.bash && \
    mkdir -p $HOME/${WS_DIR}/src && \
    cd $HOME/${WS_DIR} && \
    colcon build --symlink-install --executor sequential

RUN echo 'source /opt/ros/jazzy/setup.bash' >> $HOME/.bashrc && \
    echo 'source /usr/share/colcon_cd/function/colcon_cd.sh' >> $HOME/.bashrc && \
    echo 'source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash' >> $HOME/.bashrc && \
    echo >> $HOME/.bashrc && \
    echo 'export PIP_BREAK_SYSTEM_PACKAGES=1' >> $HOME/.bashrc && \
    echo >> $HOME/.bashrc && \
    echo "source $HOME/${WS_DIR}/install/setup.bash" >> $HOME/.bashrc && \
    echo "source $HOME/${WS_DIR}/config/tb4_setup.bash" >> $HOME/.bashrc


#####################
# TB4 ROS2 packages#
#####################
FROM jazzy-user_ws AS jazzy-tb4_mrc

# installing TB4 packages
RUN sudo apt-get update && sudo apt-get install -y \
    ros-jazzy-turtlebot4-desktop \
    ros-jazzy-turtlebot4-simulator  \
    ros-jazzy-irobot-create-nodes && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# installing Gazebo Harmonic
RUN sudo curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    sudo apt-get update && sudo apt-get install -y gz-harmonic && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*


CMD /bin/bash
