# security_report

[![Build Status](https://travis-ci.org/innoq/security_report.svg?branch=master)](https://travis-ci.org/innoq/security_report)
[![Depfu](https://badges.depfu.com/badges/d566920d877cee415e76cd9a4e680eb0/count.svg)](https://depfu.com/github/innoq/security_report?project=Bundler)

Check Ruby projects for dependencies with known security problems. This project
uses [bundler-audit](https://github.com/rubysec/bundler-audit) to check the
Gemfiles. It then generates a report like this:

    # jquery-rails (3.0.4)
    Projects: spec/examples/project_1
    Solution: Upgrade to a new version
    Problems:
    * CVE-2015-1840 (CSRF Vulnerability in jquery-r...)

    # paperclip (2.8.0)
    Projects: spec/examples/project_1
    Solution: Upgrade to a new version
    Problems:
    * CVE-2017-0889 (Paperclip ruby gem suffers fro...)
    * CVE-2015-2963 (Paperclip Gem for Ruby vulnera...)
    * 103151 (Paperclip Gem for Ruby contain...)

    # rest-client (1.6.7)
    Projects: spec/examples/project_1
    Solution: Upgrade to a new version
    Problems:
    * CVE-2015-1820 (rubygem-rest-client: session f...)
    * CVE-2015-3448 (Rest-Client Gem for Ruby logs...)

    # rubyzip (1.1.7)
    Projects: spec/examples/project_1, spec/examples/project_2
    Solution: Upgrade to a new version
    Problems:
    * CVE-2017-5946 (Directory traversal vulnerabil...)
    * CVE-2017-5946 (Directory traversal vulnerabil...)

The goal of this project is to provide a functionality similar to Github's
security mail for projects that are self hosted on Bitbucket or other
self-hosted version control repository hosting services. You can add a
scheduled job that runs security_report every night for each of your Ruby
projects and mail out the result to the developers.

security_report **does not check your code for security problems**. If you need
something like that and are using Rails, check out
[brakeman](https://github.com/presidentbeef/brakeman).

## Installation

    $ gem install security_report

## Usage

Run security_report like this:

    security_report path_to_your_project

This will output the security report to your terminal. You can also provide the
path to multiple projects. To run the security report for each project in the
projects folder, run:

    security_report projects/*

The tool uses a database of known vulnerabilities. To update the database, use
the `--update` option:

    security_report --update projects/*

You can also use a different output format. The default format is called plain.
There is also a table output. If you want to use it instead, run:

    security_report --format table projects/*

## License

security_report is licensed under Apache 2.0 License.
