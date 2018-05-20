# Project Title

Records start time, end time and duration
Posts a Custom Time Range to the AppDynamics Controller using start and end times

## Getting Started

TBD

### Prerequisites

Configure the environment variables:
```
export APPD_USER_NAME=""
export APPD_ACCOUNT=""
export APPD_PWD=""
export APPD_CONTROLLER_HOST=""
export APPD_CONTROLLER_PORT=""
```
See envvar.sh

### Installing

Runs directly from command line:

```
./appCustomTimeRange.sh start
#
# Execute workload test case
#
./appCustomTimeRange.sh end
# Post the Custom Time Range based on start and end to the Controller
./appCustomTimeRange.sh post "TEST" "DESCRIPTION OF TEST"
```

## Running the tests

TBD

## Contributing

TBD

## Versioning

TBD

## Authors

* **David Ryder**


## License

Copyright 2018 AppDynamics

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.

see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Reference: https://community.appdynamics.com/appdynamics/attachments/appdynamics/Dashboards/418/1/JMeter%20integration%20with%20AppDynamics%20v2.pdf
