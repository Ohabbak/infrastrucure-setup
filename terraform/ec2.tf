resource "aws_key_pair" "tf_key" {
  key_name   = "ec2-key"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf_key" {
  content  = tls_private_key.rsa-4096.private_key_pem
  filename = "ec2.pem"

}

# data "aws_ebs_volume" "jenkins_volume" {
#   volume_id = "vol-03cef4ae735f04bdb"
# }

resource "aws_volume_attachment" "jenkins_with_volume" {
  instance_id = aws_instance.jenkins.id
  volume_id = "vol-03cef4ae735f04bdb"
  device_name = "/dev/sdf"  # Change this device name as required
  
}


# Create the jenkins host (public EC2)
resource "aws_instance" "jenkins" {
  ami           = "ami-005fc0f236362e99f"  # Change to a valid AMI in your region
  instance_type = "t2.micro"
  key_name = aws_key_pair.tf_key.key_name
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true


  # # Attach the EBS volume
  # root_block_device {
  #   volume_id = data.aws_ebs_volume.jenkins_volume.id
  #   volume_size = 10  # Size of the EBS volume in GiB
  # }


  tags = {
    Name = "jenkins-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y openjdk-11-jdk


              sudo file -s /dev/xvdf          
              sudo mkfs -t ext4 /dev/xvdf
              sudo mount /dev/xvdf /var/lib/jenkins

              # Ensure proper ownership for Jenkins
              sudo chown -R jenkins:jenkins /var/lib/jenkins_home

              # Make the mount persistent across reboots
              if ! grep -qs '/var/lib/jenkins_home' /etc/fstab; then
                echo '/dev/xvdf /var/lib/jenkins_home ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab
              fi

              # Set Jenkins home directory
              sudo usermod -d /var/lib/jenkins_home jenkins



              # Install Jenkins
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install -y jenkins

              # Start and enable Jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF
}



# resource "aws_security_group" "jenkins_security_group" {
#   name= "jenkins_security_group"

#   ingress {
#     from_port = 8080
#     to_port = 8080
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] 
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"] 
#   }

# }


# # Create a private EC2 instance
# resource "aws_instance" "private_instance" {
#   ami           = "ami-0866a3c8686eaeeba"  # Change to a valid AMI in your region
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.private_subnet.id
#   security_groups = [aws_security_group.private_sg.id]
#   key_name = aws_key_pair.tf_key.key_name

#   tags = {
#     Name = "private_instance"
#   }
# }


# # Output the public IP of the Bastion Host
# output "bastion_public_ip" {
#   value = aws_instance.bastion.public_ip
# }

# # Output the private IP of the Private Host
# output "Private_instance_ip" {
#   value = aws_instance.private_instance.private_ip
# }


