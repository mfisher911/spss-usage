IBM SPSS Usage Reporting
========================

At work ([http://www.son.rochester.edu/](University of Rochester
School of Nursing)), we use IBM SPSS for statistical analysis. To reduce
the annual legwork of touching each SPSS user's machine, we take
advantage of the central license management server option ("Sentinel
License Manager").

This reporting functionality was written to ensure that we make sure
that we have enough licenses available in our pool.

This small toolkit is implemented in two parts:
  * `spss-use.r` (an [http://www.r-project.org/](R) program that reads
    a Sentinel usage report CSV file and generates a graph and a
    utilization text file)
  * `spss_use_nagios.py` (a [http://python.org/](Python) program that
    reads the utilization file and responds for our Nagios monitoring
    system so we can get an alert when usage reaches a warning or
    critical threshold).

Preprocessing Steps
-------------------

1. Be sure that your Sentinel License Service is enabled. On my
   machine (Windows Server 2008 R2), I set the
   `HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Rainbow Technologies\SentinelLM\Current Version` registry key to `-l spss-usage.log`
   (but read the documentation; search your machine for
   `License_Server_-_Commonly_Used_Variables.htm`).
2. Use the `vusage.exe` program to export the `spss-usage.log` file to
   a known location as a .CSV file:
   `vusage.exe -f C:\path\to\spss-usage.log -c C:\path\to\spss-usage.csv`

Processing
----------

Use R to process the CSV file. The `spss-use.r` program assumes that
it will be placed in the same folder as the `spss-usage.csv` file;
this is run with:

	R -f spss-use.r

Monitoring
----------

The R program also generates a small text file (`max_spss_use.txt`)
with the maximum checkout count (based on client checkins and
checkouts within the last hour of the CSV file's data). The Nagios
script reads that file and compares its information to provided
thresholds.

This script requires Python version 2.7. Actual use requires updating
the script to point to the correct path for the `max_spss_use.txt`
file and exposing the script results from NRPE. This was my
configuration line:

	command[check_spss_use]=/path/to/spss_use_nagios.py -w 40 -c 45

License
-------

Copyright (c) 2012, University of Rochester
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

  * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.
  * Neither the name of the University of Rochester nor the names of
    its contributors may be used to endorse or promote products
    derived from this software without specific prior written
    permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
