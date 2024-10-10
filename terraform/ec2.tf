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

# Create the bastion host (public EC2)
resource "aws_instance" "bastion" {
  ami           = "ami-0866a3c8686eaeeba"  # Change to a valid AMI in your region
  instance_type = "t2.micro"
  key_name = aws_key_pair.tf_key.key_name
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true


  tags = {
    Name = "bastion"
  }
}


# Create a private EC2 instance
resource "aws_instance" "private_instance" {
  ami           = "ami-0866a3c8686eaeeba"  # Change to a valid AMI in your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_sg.id]
  key_name = aws_key_pair.tf_key.key_name

  tags = {
    Name = "private_instance"
  }
}


# Output the public IP of the Bastion Host
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

# Output the private IP of the Private Host
output "Private_instance_ip" {
  value = aws_instance.private_instance.private_ip
}