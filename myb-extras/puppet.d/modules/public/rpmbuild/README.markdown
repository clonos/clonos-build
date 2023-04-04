rpmbuild
========

Table of Contents
------------------

1. [Overview - What is the rpmbuild module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with rpmbuild module](#setup)
4. [Usage - How to use the module for various tasks](#usage)
5. [Upgrading - Guide for upgrading from older revisions of this module](#upgrading)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Disclaimer](#disclaimer)
9. [Contributors - List of module contributors](#contributors)

Overview
--------

The rpmbuild module allows you to set up an environment for building RPMs

Module Description
------------------

The rpmbuild module sets up a environment for building and maintaining RPMs. This module will install all the needed basic
packages needed for building RPMs, this will also install some addition packages needed for building RPMs on Fedora as well
as allowing for an addition array of package names that might need to be installed for a custom enviornment. This module will
also set up a standard build directories and .rpmmacros file in a user's home directory.

Setup
-----

**Pre-Setup Requirements**

* Before this module is run the user's home directory must already created

Usage
-----

**Parameters**

rpmbuild_packages - A standard set of packages needed for a build environmnent, this should not have to be overrided 
optional_packages - an array of additional package names that are needed for a more custom build environment

example usage with default parameters
    
    class { 'rpmbuild': }


**Managing user environment**

The userhome define is used to create the needed directories and .rpmmacros file that is needed for the build environment. This will provide the .rpmmacros file through a template that will customize a basic file for the user, this define also allows for a completely custom .rpmmacros file from an existing file.

* Paramters:
    * username -> title - the username of the user to create the environment for
    * usedefaultmacros - this is set to yes to use the default template or no to use a custom file, default is yes
    * userfirstname - the first name of the user
    * userlastname - the lastname of the user
    * companyname - the company name of the user (this is optional)
    * emailaddress - the email address of the user
    * macrofilepath - this is only used if you are using a custom macros file, this should be the path of the file

* example:
    
    rpmbuild::env::userhome { 'exampleuser':
        userfirstname => 'user',
        userlastname => 'name',
        companyname => 'example company LLC',
        emailaddress => 'user@company.com',
    }

Upgrading
---------

Since this is the first version there are no notes about upgrading

Limitations
-----------

Since the package limitations this will only work on RHEL based systems and Fedora.

Development
-----------

Contributions and pull requests are welcome to making this module the best that it can be.

**Test**

There is a full set of rspec-puppet tests include in the module, just run rake spec in the top directory of the 
module to run the tests. As always a full integration test with a tool like vagrant is reccomended to ensure compatibilty
correct usage.

Disclaimer
----------

This module is provided without warranty of any kind, the creator(s) and contributors do their best to ensure stablity but can make no warranty about the stability of this module in different environments. The creator(s) and contributors reccomend that you test this module and all future releases of this module in your environment before use.

Contributors
------------

* [Diego Gutierrez](https://github.com/dgutierrez1287) ([@diego_g](https://twitter.com/diego_g))



    








