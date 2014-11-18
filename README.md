Repose API Coverage
==================

Repository that will have all prototypal data for api coverage

Why
------------------
We need to be able to not only calculate code coverage but also verify that all of the api we expose is tested.  This is now possible by integrating api testing with repose and api-checker.  This tool validates this idea.

  NOTE: this is just a prototype.  A more stable solution will be engineered based on outcomes from this prototype.
  NOTE#2: this is running against api-checker v1.0.20-snapshot.  You can utilize this snapshot by cloning https://github.com/rackerlabs/api-checker/tree/dimitry-coverage and building it (`mvn clean install` on the root directory).

How
------------------

### Prerequisites:
  * install ruby.  This has been developed against ruby 2.1.0 but any version > 1.9.3 should work.  You can use http://rvm.io/ to install a specific ruby version.
  * install java.  This is already required for repose to run.  This tool should be running on the same server as repose instance.

### Installation steps:
  - run `bundle install` at the root directory
  - run `rackup` at the root directory
  - set repose to use validator.cfg.xml
  - start repose with the following command (or equivalent): java -Xmx1536M -Xms1024M -javaagent:/path/to/this/repo/apicoverage/lib/extras/jolokia-jvm-1.2.3-agent.jar -Dcom.sun.management.jmxremote.port=10011 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.local.only=true  -jar /path/to/repose-valve.jar -c /path/to/repose/configs
  - in config.yaml file, set the following:
    - host: domain where repose is located.  Defaults to localhost
    - port: port on which jolokia listens on.  Defaults to 8778
    - config_directory: repose config directory
    - output_directory: directory where .dot files are outputted (configured with dot-output attribute in validator element in validator.cfg.xml.  If the attribute doesn't have an absolute path, then the path is relative to repose configs directory)
  - run your tests through Repose
  - navigate to http://<server>:9292.  Validate that you can see the state machine.
  - click on "Render Results" button to view api coverage data
  
Vagrant
----------------
If you don't want to go through all that pain, you can just run everything in vagrant.  The vagrant file in this repo spins up a virtual environment with repose and proper version of api-checker, install all dependencies, sets up a dummy responder service, starts repose, and installs and starts this tool. 
  - Install vagrant from https://www.vagrantup.com/
  - in vagrant directory, run `vagrant up`
  - after completion, you can access the tool via http://localhost:8081 and you can execute repose requests via http://localhost
  - if you want to run your configurations, just add it to vagrant/configs directory and execute `vagrant provision`

Current features
-----------------
  - ability to generate data based on one validator (support for multiple validators is unstable)
  - ability to view happy path data
  - ability to view failed path data (this data has some issues at this point)
  - ability to view total available happy and failed paths and % covered for both.
  - ability to view specific paths covered
  
Roadmap
------------------
  - jenkins plugin
  - sonar plugin
  - cli to generate reports
  - support for multiple validators
  - streaming data with specific requests
  - response api coverage
