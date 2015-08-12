#! /usr/bin/env python 
import socket
import time
import subprocess as sub
from argparse import ArgumentParser
from ipdb import set_trace
from glob import glob
remoteIP = '10.86.1.107'
remotePort = 1214

def buildPresentinatorString(pars,options):
    string = ''
    for par in pars:
        string += par[0] + ':'
        if not (type(par[1]) is list):
            string += str(options[par[0]])
        else:
            tmp = options[par[0]]
            if not type(tmp) is str:
                tmp = ','.join([str(i) for i in tmp])
            string += '_' + tmp.replace(',','_')
        string += ';'
    string += '!!!'
    return string 

def main():
    # default inputs
    pars = [['Class','Flashing Grid Square',''],
            ['Type','Single',''],
            ['Grid','Whole',''],
            ['Size',[5],'Size of square'],
            ['Trial',1,'Number of trail'],
            ['Duration',[0.5],'Duration'],
            ['ISI',1,'Time between stimuli'],
            ['StimLum',0,'Luminance'],
            ['BgColour','125 125 125','Background color']]
    # Add parameters
    parser = ArgumentParser(add_help=True)
    parser.add_argument('-V','--voltage-clamp',
                        dest='VC',action='store_true',
                        default=False,
                        help = 'Use voltage clamp \033[93m (Current clamp by default))\033[0m')
    parser.add_argument('--no-record',
                        dest='record',action='store_false',
                        default=True,
                        help = 'Do not run LCG (no record) \033[93m (Record by default))\033[0m')
    
    for par in pars:
        if par[0] is list:
            tmp = ','.join([str(i) for i in par[1]])
            parser.add_argument('--'+par[0],
                                dest=par[0],action='store',
                                default=tmp,
                                help = par[2] + '\033[93m'+ '(Default: {0})'.format(tmp)+'\033[0m')
        else:
            parser.add_argument('--'+ par[0],
                                dest=par[0],
                                action='store',
                                default=par[1],
                                help = par[2] + '\033[93m' + '(Default: {0})'.format(par[1]) + '\033[0m')
    # Parse parameters
    opts = parser.parse_args()
    options = vars(opts)
    presentCmd = buildPresentinatorString(pars,options)
    stimMessage = "Class:FlashingGridSquare;Type:Single;Grid:Whole;Size:_5;Trial:1;Duration:_0.5;ISI:1;StimLum:1;BgColour:125 125 125"
    sock = socket.socket(socket.AF_INET,
                         socket.SOCK_DGRAM) # Open UDP connection
    
    extra_opts = ''
    if opts.VC:
        extra_opts +='-V'
        print('Recording in voltage clamp!')
    for ii in range(int(1)):
        filename = time.strftime('%Y%m%d%H%M%S')+'.h5'
        oldfiles = glob('*.h5')
        print("Setting up recording.")
        # Create the stimulus file using the dry-run option
        string = 'lcg-stimulus-external-trigger --trigger-subdevice 2 --trigger-channel 3 -l 10000 -O none --digital-channels 0,1,2 --trigger-stop-channel 4 --dry-run {0} {1}'.format(extra_opts,'-o '+filename)
#        string = 'lcg-stimulus-external-trigger --trigger-subdevice 2 --trigger-channel 3 -l 10000 -O none --digital-channels 0,1,2 --trigger-stop-channel 4 --dry-run {0}'.format(extra_opts)
        # Runs the stim file
        if opts.record:
            drun = sub.Popen(string,shell=True,stdout = sub.PIPE)
            proc = sub.Popen(drun.stdout.read(),shell=True)
            time.sleep(0.1)
        presentCmdFname = presentCmd[:-3] + 'Filename:' + filename + ';!!!'
        print('Presenting string: {0}'.format(presentCmdFname))
        sock.sendto(presentCmdFname, (remoteIP, remotePort))
        if opts.record:
            proc.communicate()    
            # For the annotation
            files = glob('*.h5')
            for f in files:
                if not f in oldfiles:
                    sub.call('lcg-annotate -m "{1}" {0}'.format(f,stimMessage)
                             ,shell=True)
                    print('Writing to {0}'.format(f))
                    break
        else:
            duration = float(opts.ISI)
            time.sleep(duration)

if  __name__ == '__main__':
    main()
