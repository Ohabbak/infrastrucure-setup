cd terraform
sudo chmod 400 ec2.pem
sudo rm ~/.ssh/ec2.pem
sudo cp ec2.pem ~/.ssh


bastion_ip=$(terraform output --raw bastion_public_ip)
private_ip=$(terraform output --raw Private_instance_ip)
sudo cat << EOF > ~/.ssh/config
Host private
    HostName ${private_ip}
    ProxyCommand ssh -W %h:%p bastion
    user  ubuntu
    StrictHostKeyChecking no
    IdentityFile ~/.ssh/ec2.pem

Host bastion
    HostName ${bastion_ip}
    User ubuntu
    StrictHostKeyChecking no
    IdentityFile ~/.ssh/ec2.pem
EOF

sudo cat << EOF > ../ansible/vars.yml
private_ec2_ip: "${private_ip}"  # Replace with actual private EC2 IP
app_port: 30010  # Replace with actual application port
EOF