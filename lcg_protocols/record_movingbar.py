#! /usr/bin/env python 
import socket
import time
import subprocess as sub
from argparse import ArgumentParser
from ipdb import set_trace

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
    ntrials = 5
    pars = [['Class','Moving Bar',''],
            ['Type','Single',''],
            ['Size',[0.2],'Size of bar'],
            ['Angle',[0],'Angle of bar'],
            ['Order','Forward','Sequence Order'],
            ['Repeats',1,'Number of repetitions'],
            ['Speed',8,'Speed'],
            ['BlankTime',1,'Time of blank stim after recording trigger'],
            ['PreTime',1,'Time before stim'],
            ['PostTime',1,'Time after stim'],
            ['InterStimTime',5,'Time between stimuli'],
            ['StimColor',1,'Stimulus contrast'],
            ['BgColour','125 125 125','Background color']]
    # Add parameters
    parser = ArgumentParser(add_help=True)
    # For the number of trials
    parser.add_argument('-n','--ntrials',
                        dest='ntrials',action='store',
                        default=ntrials,
                        help = 'Number of trials' + '\033[93m'+ '(Default: {0})'.format(ntrials)+'\033[0m')
    parser.add_argument('-V','--voltage-clamp',
                        dest='VC',action='store_true',
                        default=False,
                        help = 'Use voltage clamp \033[93m (Current clamp by default))\033[0m')

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
    stimMessage = "Class:Moving Bar;Type:Single;Size:_0.2;Angle:_0;Order:Forward;Repeats:1;Speed:8;PreTime:1;PostTime:1;InterStimTime:5;StimColor:1;BgColour:125 125 125;!!!"
    sock = socket.socket(socket.AF_INET,
                         socket.SOCK_DGRAM) # Open UDP connection
    
    extra_opts = ''
    if opts.VC:
        extra_opts +='-V'
        print('Recording in voltage clamp!')
    for ii in range(int(options['ntrials'])):
        print("Setting up recording.")
        # Create the stimulus file using the dry-run option
        string = 'lcg-stimulus-external-trigger --trigger-subdevice 2 --trigger-channel 3 -l 1000 -O none --digital-channels 0,1,2 --trigger-stop-channel 4 --dry-run {0}'.format(extra_opts)
        # Runs the stim file
        drun = sub.Popen(string,shell=True,stdout = sub.PIPE)
        proc = sub.Popen(drun.stdout.read(),shell=True)
        time.sleep(0.1)
        print('Presenting string: {0}'.format(presentCmd))
        sock.sendto(presentCmd, (remoteIP, remotePort))
        proc.communicate()    

if  __name__ == '__main__':
    main()
