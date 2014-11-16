#! /usr/bin/env python 
import socket
import time
import subprocess as sub
from argparse import ArgumentParser
from ipdb import set_trace

remoteIP = '10.1.5.20'
remotePort = 1214
configFile = '/home/farrowlab/configurations/trigger_recording.xml'

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
    pars = [['Class','Grating',''],
            ['Type','Stationary',''],
            ['Size',[0.2],'Size of grating'],
            ['Shape','Sine','Shape of sine'],
            ['Angle',[0],'Angle of grating'],
            ['Order','Forward','Sequence Order'],
            ['Repeats',1,'Number of repetitions'],
            ['TemporalFreq',8,'Temporal Frequency'],
            ['BlankTime',1,'Time of blank stim after recording trigger'],
            ['PreTime',1,'Time before stim'],
            ['PostTime',1,'Time after stim'],
            ['StimTime',1,'Stim duration'],
            ['InterStimTime',5,'Time between stimuli'],
            ['StimContrast',1,'Stimulus contrast'],
            ['BgColour','125 125 125','Background color']]
    # Add parameters
    parser = ArgumentParser(add_help=True)
    # For the number of trials
    parser.add_argument('-n','--ntrials',
                        dest='ntrials',action='store',
                        default=ntrials,
                        help = 'Number of trials' + '\033[93m'+ '(Default: {0})'.format(ntrials)+'\033[0m')

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
    stimMessage = "Class:Grating;Type:Stationary;Size:_0.1;Shape:Sine;Angle:_0;Order:Forward;Repeats:1;TemporalFreq:8;BlankTime:1;PreTime:1;PostTime:1;StimTime:1;InterStimTime:5;StimContrast:1;BgColour:125 125 125;!!!"
    sock = socket.socket(socket.AF_INET,
                         socket.SOCK_DGRAM) # Open UDP connection

    for ii in range(int(options['ntrials'])):
        print("Setting up recording.")
        proc = sub.Popen('lcg-experiment -c {0}'.format(configFile),shell=True)
        time.sleep(0.1)
        print('Presenting string: {0}'.format(presentCmd))
        sock.sendto(presentCmd, (remoteIP, remotePort))
        proc.communicate()    

if  __name__ == '__main__':
    main()
