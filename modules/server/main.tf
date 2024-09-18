
resource "aws_security_group" "sec-grp" {
    name = "${var.env}-sec-grp"
    vpc_id = var.vpc_id   
    ingress {
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.my-ip]
    protocol    = "tcp"
    }
    ingress {
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    }
    tags = {
        Name = "${var.env}-sec-grp"
    } 
    egress{
        from_port=0
        to_port=0
        cidr_blocks=["0.0.0.0/0"] 
        protocol= "-1"
        prefix_list_ids=[]  
    }
}

data "aws_ami" "amazon-machine-image"{
    most_recent= true 
    owners=["amazon"]
    filter {
        name="name"
        values=["amzn2-ami-*-x86_64-gp2"]
    }
    filter {
        name="virtualization-type"
        values=["hvm"]
    }

}

resource "aws_instance" "ec2" {
    ami=data.aws_ami.amazon-machine-image.id
    instance_type=var.instance_type   
    subnet_id=var.subnet_id  
    vpc_security_group_ids=[aws_security_group.sec-grp.id]
    availability_zone=var.avail_zone   
    associate_public_ip_address= true
    key_name=aws_key_pair.ssh-key.key_name        
    user_data = file("userdata.sh")                  
    tags={
        Name="${var.env}-ec2-mod"   
    }

}

resource "aws_key_pair" "ssh-key" {
    key_name="tfkey56"
    public_key=file("/home/ghanem/.ssh/id_rsa.pub")
}
