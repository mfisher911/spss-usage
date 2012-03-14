#!/usr/bin/env python
""" Nagios monitor script tracking SPSS licensing use.

Ref: <http://nagiosplug.sourceforge.net/developer-guidelines.html>

Enable from an NRPE config file like:
  command[check_spss_use]=/path/to/spss_use_nagios.py -w 40 -c 45

NB: Requires Python 2.7+ for argparse.
"""

# Copyright (c) 2012, University of Rochester
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:

#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#   * Neither the name of the University of Rochester nor the names of
#     its contributors may be used to endorse or promote products
#     derived from this software without specific prior written
#     permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


import argparse
import datetime
import os
import sys

SPSS_USE_FILE = '/path/to/max_spss_use.txt'  # Change this.
VERSION = '0.0.1'
RETURN_CODES = {'OK': 0, 'Warning': 1, 'Critical': 2, 'Unknown': 3}


def init_parser():
    """ Return an ArgumentParser with Nagios options configured. """
    description = 'SPSS License Tracker, version {}'.format(VERSION)

    parser = argparse.ArgumentParser(description=description)
    parser.add_argument('-V', '--version', action='version',
                        version='%(prog)s {}'.format(VERSION))
    parser.add_argument('-t', '--timeout')
    parser.add_argument('-w', '--warning', required=True)
    parser.add_argument('-c', '--critical', required=True)
    parser.add_argument('-H', '--hostname')
    parser.add_argument('-v', '--verbose', action='count')
    ## common options per the Nagios plug-in development guide
    # parser.add_argument('-C', '--community')
    # parser.add_argument('-a', '--authentication')
    # parser.add_argument('-l', '--logname')
    ## parser.add_argument('-p', '--port')
    ## parser.add_argument('-p', '--password')
    ## parser.add_argument('-u', '--url')
    ## parser.add_argument('-u', '--username')
    return parser


def handle_spss_usage(warning, critical):
    """ Process the SPSS file and return a Nagios status code. """
    result = 'Unknown'
    count = -1
    try:
        lfm = os.path.getmtime(SPSS_USE_FILE)
        mtime = str(datetime.datetime.fromtimestamp(lfm))
    except OSError:
        return result, count, '[Error: missing file]'

    with open(SPSS_USE_FILE) as data:
        try:
            count = int(data.readline())
        except ValueError:
            # Probably not ideal, but I don't want to flap when
            # clients don't check in/out licenses. May need updates in
            # the R script.
            return 'OK', count, mtime

    if count >= int(critical):
        result = 'Critical'
    elif count >= int(warning):
        result = 'Warning'
    else:
        result = 'OK'

    return result, count, mtime


def main():
    """ Main processing method. """
    parser = init_parser()
    args = parser.parse_args()
    (status, clients, mtime) = handle_spss_usage(warning=args.warning,
                                                 critical=args.critical)
    print "SPSS Use: {status} ({clients} clients) @ {mtime}" \
        .format(status=status, clients=clients, mtime=mtime)
    sys.exit(RETURN_CODES[status])


if __name__ == "__main__":
    main()
