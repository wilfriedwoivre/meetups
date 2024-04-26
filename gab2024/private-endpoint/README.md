# demo

## API Hell

deploy on one subscription  ./bicep/private-link/main.bicep
deploy on other sub  ./bicep/private-link/othersub/main.bicep

Try to create private endpoint. Don't forget to switch user account between subscription

## Private link from onpremise

deploy ./bicep/onpremise-privatelink/main.bicep

Use VPN Point 2 site to connect from your laptop to your DNS

- install P2S on your laptop
- configure your DNS with inbound private ip of your DNS resolver

