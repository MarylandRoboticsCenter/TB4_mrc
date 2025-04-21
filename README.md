Docker image for working with Turtlebot4. The image is based on Ubuntu 24.04.

* Build ROS2 Jazzy docker image (run the command from the `docker` folder):
    ```
    userid=$(id -u) groupid=$(id -g) docker compose -f jazzy-tb4_mrc-compose.yml build
    ```    
* Start the container:
    ```
    docker compose -f jazzy-tb4_mrc-compose.yml run --rm jazzy-tb4_mrc-docker
    ```
* If in the RAL lab, connect to the `RAL_wifi_5GHz` wifi network (ask the TA or the lab manager for the password)
