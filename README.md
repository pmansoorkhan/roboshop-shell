*********************************ROBOSHOP APPLICATION***********************************
AUTHOR: MANSOOR KHAN PATAN
APPLICATION: ROBOSHOP
DATE: 28/10/2026
****************************************************************************************
Create a server "Shell server" with our AMI "ami-0055977a6e828a4f4"
Configure the  admin role in the server with command "aws configure" by passing Access key & Secret key of the admin privilages user (shell )
Login the server and clone the repo "roboshop-shell" in it.
Move to the repo directory (cd roboshop-shell/)
To deploy the servers via shell script in the server , give the command  : sh roboshop.sh mongodb catalogue ....
As per the above command the number of servers are deployed in the infra.
Login the mongodb server and then run the script : sudo sh mongodb.sh 
Login the catalogue  server and then run the script : sudo sh catalogue.sh 
Once all the services are started in the respective servers
Then we can login "shannu.online" in the browser and access the roboshop application 
