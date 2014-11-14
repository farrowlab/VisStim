#! /usr/bin/env python

import subprocess as sub
import numpy as np
import time
import sys
from argparse import ArgumentParser
sensapex_cmd = 'sensapex -p /dev/ttyUSB0 -z {0}'

def advance_until(target,stepsize,waittime,start = 0):
    print('Going to move at {0} micron steps till {1}'.format(stepsize,target))
    for pos in np.arange(start,target,stepsize):
        sub.call(sensapex_cmd.format(stepsize),shell=True,stdout=sub.PIPE)
        sys.stdout.write('Position'+'\033[91m'+' {0:04.2f}'.format(pos)+'\033[0m'+'\r')
        sys.stdout.flush()
        time.sleep(waittime)
    print('\n')

def main():

    stepsize = 2
    max_pos = 1000
    sleeptime = 1
    parser = ArgumentParser(add_help=True)
    # For the number of trials
    parser.add_argument('-s','--stepsize',
                        dest='stepsize',action='store',
                        default=stepsize,
                        help = 'Stepsize' + '\033[93m'+ '(Default: {0} microns)'.format(stepsize)+'\033[0m')
    parser.add_argument('-m','--maximum',
                        dest='max_pos',action='store',
                        default=max_pos,
                        help = 'Maximum position' + '\033[93m'+ '(Default: {0} microns)'.format(max_pos)+'\033[0m')
    parser.add_argument('-w','--wait-time',
                        dest='sleeptime',action='store',
                        default=sleeptime,
                        help = 'Time to sleep between steps' + '\033[93m'+ '(Default: {0} seconds)'.format(sleeptime)+'\033[0m')
    options = parser.parse_args()

    advance_until(float(options.max_pos), float(options.stepsize) ,float(options.sleeptime))

if __name__ == '__main__':
    main()

