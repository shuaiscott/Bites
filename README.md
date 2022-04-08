# Bites
Entire IT stack for webapp


## MVP Requirements
- All secrets/config properties are stored in .env
- Deploy Infrastructure via Terraform
    - Internal network for DB/Backend/Load balancer communication
    - CDN for webapp
    - DB for API
    - 3 app instances for backend
    - Load balancer for backend
    - AWS Deployment
    - ElasticStack for logging
    - Jaeger for app monitoring
    - Prometheus/Grafana for infrastructure monitoring
- Deploy Code changes via Github Actions
- Web app letting a user "eat" an apple
    - Upon page load, request fruit info for apple in /fruits endpoint
    - Reset button allows you to eat another apple
        - requests new meal id and stores in session storage (we don't want a user to come back to a rotten apple)
    - Apple bites and complete consumption are tracked via /bites API call
- Spring Boot backend to fruits, meals, and bites information
    - /meals POST endpoint
        - Creates a new meal id
        - Returns meal id
    - /bites PUT endpoint
        - Records a bite event occurring
        - Collects info for geolocation purposes (IP or other data)
        - Sends meal id to track bites
        - Returns meal id, fruit id, bites left
        - On invalid meal id, return 404
        - On no more bites available, return 400
    - /fruits GET endpoint
        - Generic information about current fruit to bite
    - DB contains fruit configuration data (how many bites it takes, name)

## Wishlist
- Websocket in Spring Boot to show live locations on map of any bites taken with a 30 second fade-out
- Kubernetes version of the app
- Ansible for configuration management
- Feedback form utilizing serverless function to send email/slack message/etc
- Fullstory integration for troubleshooting
- VPN to internal 'corporate' network
- Istio Service Mesh
