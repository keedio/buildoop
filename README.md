Buildoop: Hadoop Ecosystem Builder
==================================

The Hadoop Ecosystem Builder -Buildoop- provides interoperable tools, metadata, 
and processes that enable the rapid, repeatable development of a Linux
Hadoop based system.

With Buildoop you can build a complete set of Hadoop ecosystem components based
on RPM or DEB packages, make integration tests for this tools on a RedHat/CentOS,
or Debian/Ubunto virtual system, and maintain a set of configuration files for
baremetal depolyment.

Fundations
----------
The Buildoop is splitted in the following fundations:

1. A main command line program for metadata operations: "buildoop".
2. A set of recipes: The metadata for package and tools building.
3. A set of integration tests: iTest framework.
4. A central repository for baremetal deployment configuration.

Technology
----------
From the technology point of view Buildoop is based on:

1. Command line "buildoop" based on Groovy.
2. Packaging reciypes based on Gradle.
3. iTest Framework: based on Groovy test scripts, and Vagrant for
   virtual development enviroment.
4. Set of Kickstart, Cheff and Puppet files for baremetal deployment.
