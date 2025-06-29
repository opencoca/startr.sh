# startr.sh v0.2.1

## Now with the power of the CEP (Common Enlightenment Protocol or the Conventional Environment Protocol)!

> The ultimate launchpad for your development projects following industry best practices.

Startr.sh - is the ultimate launchpad for your development projects! With a simple terminal command, `bash <(curl -sL startr.sh)`, you can set up your project environment in no time. Streamline your Docker image creation process and say goodbye to tedious setup and configuration.

Startr.sh is designed to enhance your development workflow, regardless of the framework you use. It supports popular languages and frameworks such as Python, Django, Flask, Node, and Startr.Style CSS, ensuring a seamless and efficient experience.

The service is backed by experienced developers who've mastered the art of project deployment. They provide the tools and insights needed to launch your projects reliably and quickly, saving you precious time and effort.

Make your development process effortless and focus on what matters most - your code. Get started with Startr.sh today and experience the convenience of one-command project setup!

## Quick Start

```bash
# Build and run your project
bash <(curl -sL startr.sh)

# Or use the standardized Makefile
make it_run
```

## What is Startr.sh?

Startr.sh is both **a landing page** and **the actual script** - when you visit [startr.sh](https://startr.sh), you're seeing an HTML page that contains the complete bash script. This innovative approach means the documentation and script are always in sync.

Startr.sh automatically detects your project type (Python, Django, Flask, Node.js, static sites) and creates the appropriate Docker setup, streamlining your development workflow.

## 📖 Documentation

- **[Complete Documentation](docs/)** - Comprehensive guides and references
- **[Standardized Makefile](docs/makefile/)** - One-command build and deployment
- **[Development Workflow](docs/development/DEVELOPMENT_WORKFLOW.md)** - SOLID principles and best practices

## Features

- ✅ **Smart Detection** - Automatically identifies your project type
- ✅ **Docker Integration** - Builds and runs containers seamlessly  
- ✅ **Standardized Makefile** - Consistent commands across all projects
- ✅ **Git Flow Support** - Release management built-in
- ✅ **CapRover Deployment** - One-command production deployment

## How it works

```sh
bash <(curl -sL startr.sh)
```

startr.sh , `bash <(curl -sL startr.sh)`, is a powerful tool that can simplify the process of setting up a development environment. Let's break down the components and understand what they do:


1. **`curl -sL startr.sh`**: 
      - `curl`: This is a command-line tool for transferring data with URLs. It's used here to fetch content from the Startr.sh server.

   - `-sL`: These are flags used with `curl`. The `-s` flag enables silent mode, suppressing progress indicators and error messages, while `-L` enables location, which is useful for following redirects.

   - When you run this in your terminal, it fetches `startr.sh` and executes it as a Bash script, which likely includes setting up the environment, installing dependencies, and configuring your project.


2. **`<()` Process Substitution**: 
   - After `curl` fetches the `startr.sh` script, `<()` (process substitution) is used. This is a feature of Bash and other shells that allows the output of a command (in this case, `curl -sL startr.sh`) to be used as a file input. Instead of saving the downloaded content to a file and then executing that file, process substitution handles it all in memory, making the operation more streamlined.

3. **`bash`**: 
   - The downloaded script is then passed to `bash`, which interprets and executes the commands within the script. This initiates the setup process defined by `startr.sh`, likely involving the setup of a development environment, Docker configurations, and potentially installing dependencies or frameworks.

**Other Potential Uses and Modifications:**

1. **Custom Scripts and Automation:**
   Instead of `startr.sh`, you could point `curl` to any other script URL to automate various tasks. For instance, a script that sets up a specific development stack, configures a server, or runs a series of tests could be executed in a similar fashion.

2. **Script Parameterization:**
   The command can be extended to pass parameters to the downloaded script. If `startr.sh` accepted arguments, you could modify the command to something like `bash <(curl -sL startr.sh) arg1 arg2`, allowing for customization of the setup process based on user input.

3. **Integration with CI/CD Pipelines:**
   This command pattern can be integrated into Continuous Integration/Continuous Deployment pipelines to automate the setup of test or deployment environments. Tools like Jenkins, GitLab CI/CD, or GitHub Actions could use similar commands to prepare the necessary environments before running tests or deploying code.

4. **Conditional Execution:**
   You could wrap the command in conditional logic based on the outcome of previous steps or system checks. For example, running the script only if a certain version of a software is not already installed.

5. **Security Checks and Verification:**
   Before blindly executing scripts from the internet, it's crucial to verify their source and contents. One could modify the process to first download the script, inspect its contents, and then execute it manually if deemed safe. This could involve saving the file locally, reviewing it, and running `bash ./localfile.sh`.

The fundamental structure of this command—fetching and executing a remote script—opens up a wide array of possibilities for automation, environment setup, and task execution in various development and deployment scenarios. However, it's essential to balance convenience with security considerations when executing remote scripts.




Extrapolating on its potential uses, the versatility of this command becomes apparent. Here are some possible applications:

1. **Remote Script Execution**: You could use it to fetch and execute scripts from a remote server. This could be handy for developers who want to keep their local development environment clean and minimal, installing only the essential tools, while fetching specific scripts as needed.

2. **Automated Setup**: If the fetched script contains the necessary commands, it could automate the process of setting up development tools, IDEs, or specific project configurations, saving developers time and effort.

3. **Project Initialization**: The command could initialize a new project by setting up the project structure, installing necessary dependencies, and configuring the development environment with optimal settings.

4. **Continuous Integration/Continuous Deployment**: In CI/CD pipelines, this command could be used to prepare the environment for building and testing code changes, ensuring a consistent and reproducible setup across different machines.

5. **Toolchain Installation**: Developers could use it to install and manage complex toolchains, especially if the script fetches and installs the required components seamlessly.

6. **Update Management**: The command could potentially fetch and apply updates for existing projects, ensuring that developers always work with the latest tools and libraries.

However, it's essential to exercise caution when running commands fetched from the internet. Trusting the source is crucial, as executing arbitrary code can potentially expose your system to security risks. Startr.sh seems to be a service that aims to simplify development setup, but one should always verify the integrity and safety of the script before execution.


# Get involved with the development

You can work on the development of Startr.sh by following these steps:

1. **Fork the Repository**: Start by forking the main Startr.sh repository to your GitHub account. This will create a copy of the project under your account, allowing you to make changes without affecting the original repository.

2. **Clone the Repository**: Clone the forked repository to your local machine using the `git clone` command. This will download the project files to your computer, enabling you to work on them locally.

3. **Launch the Project**: Navigate to the project directory and run the necessary commands to launch the project. This may involve setting up a development environment, installing dependencies, and configuring the project settings.

   ```
   cd startr.sh
   bash <(curl -sL startr.sh)
   ```

**Note:** Automatic dev env setup is comming soon!