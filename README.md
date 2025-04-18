Docker image for working with Turtlebot4. The image is based on Ubuntu 24.04.

* Build ROS2 Humble docker image (run the command from the `docker` folder):
    ```
    userid=$(id -u) groupid=$(id -g) docker compose -f jazzy-tb4_mrc-compose.yml build
    ```    
* Start the container:
    ```
    docker compose -f jazzy-tb4_mrc-compose.yml run --rm jazzy-tb4_mrc-docker
    ```

