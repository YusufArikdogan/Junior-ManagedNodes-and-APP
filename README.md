### Project Overview

This project aims to deploy and manage managed nodes through a control node created with Terraform. Additionally, it facilitates the creation of Docker images for our application and pushes them to DockerHub. Furthermore, it ensures the setup of the infrastructure using Ansible with the created images. For continuous integration, we will utilize Jenkins pipelines.

#### Initial Configuration Changes:

1. **Terraform Configuration:**
   - Modify the necessary variables in `main.tf`:
     - Update the AWS region at line 11.
     - Change the user at line 19.
     - Update the `key_name` at line 26.

2. **Ansible Configuration:**
   - Update `ansible.cfg`:
     - Replace `private_key_file` with your `keyname.pem`.

3. **Jenkins Pipeline:**
   - Edit `Jenkinsfile`:
     - Update lines 48, 49, 50, 60, 61, and 62 with the appropriate DockerHub username, replacing `insaniso`.

4. **Docker Configuration:**
   - In `Junior-Level.yaml`:
     - Update DockerHub repository names at lines 57, 87, and 113.

By implementing these changes, we ensure smooth deployment, management, and continuous integration of our application.