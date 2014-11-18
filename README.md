repose_apicoverage
==================

Repository that will have all prototypal data for api coverage

Why
------------------
We need to be able to not only calculate code coverage but also verify that all of the api we expose is tested.  This is now possible by integrating api testing with repose and api-checker.  This tool validates this idea.

NOTE: this is just a prototype.  A more stable solution will be engineered based on outcomes from this prototype.
NOTE#2: this is running against api-checker v1.0.20-snapshot.  You can utilize this snapshot by cloning https://github.com/rackerlabs/api-checker/tree/dimitry-coverage and building it (`mvn clean install` on the root directory).

How
------------------
Prerequisite: install ruby.  This has been developed against ruby 2.1.0 but any version > 1.9.3 should work.  You can use http://rvm.io/ to install a specific ruby version.
Prerequisite #2: install java.  This is already required for repose to run.  This tool should be running on the same server as repose instance.

  - run `bundle install` at the root directory
  - run `rackup` at the root directory
  - run your tests through Repose
  - navigate to http://localhost:9292.  Validate that you can see the state machine.
  - click on "View Results" button to view api coverage data
  
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
