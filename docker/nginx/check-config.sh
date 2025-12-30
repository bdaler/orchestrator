#!/bin/bash

# Check config
sudo docker exec -it backend-nginx nginx -t

# Show config
sudo docker exec -it backend-nginx nginx -T
