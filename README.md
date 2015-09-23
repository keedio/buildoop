Buildoop: Hadoop Ecosystem Builder Version 1.0
================================================

The Hadoop Ecosystem Builder -Buildoop- provides interoperable tools, metadata, 
and processes that enable the rapid, repeatable development of a Linux
Hadoop based system.

With Buildoop you can build a complete set of Hadoop ecosystem components based
on RPM or DEB packages, make integration tests for this tools on a RedHat/CentOS,
or Debian/Ubuntu virtual system, and maintain a set of configuration files for
baremetal deployment.

NEW VERSION 1.0 NOTES
--------------------
Buildoop have receive a reestructuration of the code to isolate the core (builder and packager) and the recipes.
The previous recipes has been moved to https://github.com/keedio/buildoopRecipes
With these detachment we obtain an easier recipes versions maintenance. 
Also brings to the project the possibility to be used for build no-hadoop tools.

Fundations
----------
The Buildoop is splitted in the following fundations:

1. A main command line program for metadata operations: **buildoop**.  
2. A set of system integration tests: **SIT framework**.
3. A central repository for **baremetal deployment** configuration.
4. An external repository with the distribution **recipes**.

Technology
----------
From the technology point of view Buildoop is based on:

1. Command line "buildoop" based on **Groovy**.
2. Packaging recipes based on **JSON**.
3. SIT Framework: based on Groovy test scripts, and **Vagrant** for
   virtual development enviroment.


Folder scheme
-------------

* buildoop:
	Main folder for Buildoop main controler.
	
* conf:
	Buildoop configuration folder, BOM definitions, targets definitions.
	
* deploy:
	Folder for deploy in VM and Baremetal systems. Based on Puppet and Chef.
	
* sit:
	System Integration Testing tests for VM pseudo-cluster system.
	
* toolchain:
	Tools for cross-compiling for diferent targets.

HowTo
-----

1. Download Groovy binary:  

  `wget http://dl.bintray.com/groovy/maven/groovy-binary-2.3.3.zip`
  
2. Clone the project:  

  `git clone https://github.com/keedio/buildoop.git`

3. Set the enviroment:  

  `cd buildoop && source set-buildoop-env`

4. In order to build some packages you need install some dependecies:  

  `less buildoop/doc/DEPENDENCIES`
  

5. Usage examples:

  - List available distributions-versions in the external repository  
  `buildoop -remoterepo https://github.com/keedio/buildoopRecipes`

  - Select a distribution-version and download it  
  `buildoop -downloadrepo https://github.com/keedio/buildoopRecipes openbus-v1.0`
  
  - Build the whole ecosystem for the distribution openbus-v1.0:  
  `buildoop openbus-v1.0 -build`

  - Build the zookeeper package for the distribuion openbus-v1.0:  
  `buildoop openbus-v1.0 zookeeper -build`

6. For more commands:

  `less buildoop/doc/README`

Read More
---------

http://buildoop.github.io/

Pull request flow
------------------

Clone the repository from your project fork:  

`$ git clone https://github.com/keedio/buildoop.git`

The clone has as default active branch "buildoop-v1-dev"  

`$ git branch
* buildoop-v1-development`

Yo have to make your changes in the "buildoop-v1-dev" branch.  

`$ git add .`

`$ git commit -m "...."`

`$ git push origin`1

When you are ready to purpose a change to the original repository, you have 
to use the "Pull Request" button from GitHub interface.  

The point is the pull request have to go to the "buildoop-v1-dev" branch so the pull
request revisor can check the change, pull to original "buildoop-v1-dev" branch, and 
the last step is to push this "development pull request" to the "buildoop-v1-master" branch.

So the project has two branches:

1. The "buildoop-v1-master" branch: The deployable branch, only hard tested code and ready to use.
2. The "buildoop-v1-dev": Where the work is made and where the pull request has to make.


Roadmap
-------

| Feature        | Desc           | State  |
| -------------  |:-------------- | :-----:|
| Core Engine |Core building engine | Done |
| POM versioning | Simple BOM multi-versioning | Done |
| Git repsotory | Download sources from GIT | Done |
| Svn repsotory | Download sources from Subversion | Pending |
| Code refactoring | More elegant code | Forever Pending |
| Cross-Architecture | Cross build from different distributions | Pending |
| DEB Support | Debian/Ubuntu Support | Pending |
| Layers      | Add/Modify features without modify the core folders | Pending |
| SIT | System Integration Tests  |  Pending |

--
Javi Roman <jromanes@redhat.com>
Marcelo Valle <mvalle@keedio.com>
