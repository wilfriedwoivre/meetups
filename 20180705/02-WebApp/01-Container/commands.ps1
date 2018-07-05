#Create image
docker build -t webapp4container .

#Run locally
docker run -d -p 8090:80 webapp4container

#Tag image
docker tag webapp4container ($registry.LoginServer + '/webapp4container:v1')

#Push image
docker push ($registry.LoginServer + '/webapp4container:v1')


