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

### Setting up Jenkins Pipeline

After completing the necessary changes, we need to push these files to your GitHub repository, ensuring that we do not include any secret files like key.pem.

Once everything is ready, we can transition to the Jenkins interface created in our previous project.

1. **Creating a New Pipeline:**
   - Navigate to "New Item" and create a new pipeline.
   - Give your pipeline a name and select "Pipeline" from the options. Proceed.

2. **Configuring Pipeline:**
   - Under the "Pipeline Script" section, select "Pipeline from SCM."
   - Choose Git as the SCM.
   - Paste the URL of your GitHub repository where you pushed the files.
   - Select the token created earlier.
   - Optionally, set up triggers for the pipeline to run on push events.
   - Click "Apply" and then "Save."

3. **Building the Pipeline:**
   - Click on "Build Now" to initiate the pipeline.
   - The pipeline will create the infrastructure and application step by step, which may take some time.

Once the pipeline is complete, you can access the user interface of your application via `react_node-public_ip:3000` in the AWS console.

Congratulations, your application is up and running! 

