# Containerising Flask Setup 

This project gets a container image of the random quote generator from my repository: [jonahmary17/mary-flask](https://hub.docker.com/repository/docker/jonahmary17/mary-flask/general).


## Installation

1. Fork the repository:
   ```sh
   git clone https://github.com/maryjonah/docker-aws-datadog-integration.git
   
2. Update 3 repo secrets with your own copy.
![Screenshot of repo secrets that need to be updated inorder to get the project running.](https://github.com/maryjonah/docker-aws-datadog-integration/blob/main/docker-datadog-setup.png)
3. Start a GitHub workflow and about 7 mins after a successful run, check DataDog host page for container metrics
![Screenshot of datadog showing container metrics for containerized application.](https://github.com/maryjonah/docker-aws-datadog-integration/blob/main/datadog-container-metrics.png)
