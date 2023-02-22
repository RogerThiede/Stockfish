#!/usr/bin/env python3

import sys
import os
import argparse
import re
import pandas as pd

def is_valid_fen(fen_string):
    """
    Validates whether the given string is a valid chess position in Forsyth–Edwards Notation (FEN) notation.
    Does not handle Extended Position Description (EPD) notation.

    :param fen_string: FEN string to validate
    :return: True if the fen_string is a valid FEN
    """
    # Regular expression for validating FEN strings
    regex = r'^\s*([rnbqkpRNBQKP1-8]+\/){7}([rnbqkpRNBQKP1-8]+)\s+[bw]\s+(-|K?Q?k?q?)\s+[-]\s+(\d+)\s+(\d+)$'
    return (re.match(regex, fen_string) != None)

def is_valid_currmovenumber_info_update(uci_info_string):
    """
    Validates whether the given UCI info string is a valid currmovenumber info update line like the following:
    "info depth 64 currmove a2a3 currmovenumber 5"
    This type of info line is periodically sent from the engine to the GUI whenever one of the info has changed.

    :param uci_info_string: UCI info line to validate
    :return True if the uci_info_string matches the format of an info message from the engine
    """
    regex = r'info depth (?P<depth>\d+) currmove (?P<currmove>\w+) currmovenumber (?P<currmovenumber>\d+)'
    match = re.match(regex, uci_info_string)
    if match:
        groups = match.groupdict()
        print(groups)
        return groups
    else:
        print("Invalid currmovenumber info string.")
        return False

def parse_fen_line(fen_string):
    """
    Generates the stockfish UCI commands which will log a deep analaysis from a given FEN string.

    :param fen_string: validated FEN string
    :raises ValueType: if fen_string does not fit the FEN notation format
    """
def parse_fen_line(fen_string):
    if is_valid_fen(fen_string):
        stockfish_command_template = ''.join(('setoption name Debug Log File value /tmp/{FILENAME}\n',
                                            'compiler\n',
                                            'uci\n',
                                            'position fen "{FEN}"\n',
                                            'setoption name SyzygyProbeDepth value 1\n',
                                            'setoption name MultiPV value 8\n',
                                            'go'))

        # FEN strings include forward slashes and spaces which are not filesystem friendly.
        # Replace those characters with filesystem friendly characters instead.
        # '/' -> '-'
        # ' ' -> '_'
        filename = fen_string.replace('/', '-').replace(' ','_') + '.txt'
        stockfish_command = stockfish_command_template.replace('{FILENAME}', filename).replace('{FEN}',fen_string)
        print(stockfish_command)
    else:
        raise ValueError("Invalid FEN: " + fen_string)

def parse_UCI_info_line(uci_info_string):
    """
    Validates whether the given UCI info string is valid and tokenizes it to the following groups:
    ['depth', 'seldepth', 'multipv', 'score', 'wdlwin', 'wdldraw', 'wdlloss', 'nodes', 'nps', 'hashfull', 'tbhits', 'seconds', 'pv']

    :param uci_info_string: UCI info line to validate
    :return False if the uci_info_string was missing groups, otherwise returns a dictionary
            with matched values that can be accessed using their corresponding keys
    """
    # Regular expression for UCI info string with the first match being the depth, and the second match being the seldepth, etc.
    # pv match can explicitly be matched to '(?P<pv>([a-h][1-8][a-h][1-8]\s?)+)' but '(?P<pv>(\w\s?)+)' is a simpler match
    regex =  r"info depth (?P<depth>\d+) seldepth (?P<seldepth>\d+) multipv (?P<multipv>\d+) score cp (?P<score>\d+) wdl (?P<wdl_win>\d+) (?P<wdl_draw>\d+) (?P<wdl_loss>\d+) nodes (?P<nodes>\d+) nps (?P<nps>\d+) hashfull (?P<hashfull>\d+) tbhits (?P<tbhits>\d+) time (?P<seconds>\d+) pv (?P<pv>(\w\s?)+)"
    
    match = re.match(regex, uci_info_string)
    if match:
        groups = match.groupdict()
        print(groups)
        return groups
    else:
        print("Invalid UCI info string.")
        return False



def convert_file_to_dataframe(filename = ''):
    info_tree = []
    
    try:
        with open(filename, 'r') as file:
            for line in file:   
                if line.startswith('<<'):
                    # '<<' represents a message from the engine to the GUI.
                    # Remove '<<' and remove any trailing new line characters
                    line = line[2:].rstrip()                          
                    if line.startswith('info'):
                        if is_valid_currmovenumber_info_update(line):
                            print('Skipping currmovenumber.')
                        else:
                            info_tree.append(parse_UCI_info_line(line))
                    else:
                        raise ValueError(line)
    except FileNotFoundError:
        print("File not found: " + filename)
    except ValueError as err:
        print('Unknown line to process: ', err)

    print(info_tree)
    df = pd.DataFrame.from_records(info_tree)
    print("DataFrame =", df)
    print(df.to_markdown()) 
    
if __name__ == '__main__':
    
    parser = argparse.ArgumentParser()
    parser.add_argument('filename', nargs='?', default='default.txt')
    args = parser.parse_args()
    #convert_file_to_dataframe(args.filename)
    print("Filename: ", args.filename)
    parse_fen_line(args.filename)
        

