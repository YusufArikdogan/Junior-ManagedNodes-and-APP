### Project Overview

This project aims to deploy and manage managed nodes through a control node created with Terraform. Additionally, it facilitates the creation of Docker images for our application and pushes them to DockerHub. Furthermore, it ensures the setup of the infrastructure using Ansible with the created images. For continuous integration, we will utilize Jenkins pipelines.

#### Initial Configuration Changes:  
1. **Cloning the Repository:**   
   Before proceeding with the configuration changes, create a new repository on your preferred Git hosting platform.  
   Then clone this repository to your local machine.  
   ``` 
   git clone <repository_url>  
   cd <cloned_repository_directory>
   ``` 
   Now that you have cloned the repository to your local machine, you can begin making changes and customizations according to the following modifications:  

2. **Terraform Configuration:**
   - Before modifying the necessary variables in main.tf, you need to create an S3 bucket on AWS. Follow these steps:  
      -Log in to the AWS Management Console.  
      -Navigate to the S3 service.  
      -Click on the "Create bucket" button.  
      -Enter a unique bucket name and select the region where you want to create the bucket.  
      -Choose your preferred settings for versioning, logging, and tags, or leave them as default.  
      -Click on the "Create bucket" button to create the S3 bucket.  
   - Once you've created the S3 bucket, you can proceed to modify the necessary variables in main.tf:
     - Update the bucket name at line 9.
     - Update the AWS region at line 16 (if you work in different region)  
     - Change the user at line 28.  
     - Update the `key_name` at line 36.  

3. **Ansible Configuration:**
   - Update `ansible.cfg`:
     - Replace `private_key_file` with your `keyname.pem`.

4. **Jenkins Pipeline:**
   - Edit `Jenkinsfile`:
     - Update lines 44, 45, 46, 56, 57, and 58 with the appropriate DockerHub username, replacing `insaniso`.

5. **Docker Configuration:**
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

