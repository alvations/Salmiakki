#!/usr/bin/env python -*- coding: utf-8 -*-

import io
from itertools import product


def preprocess_fin(infile, outfile):
    with io.open(infile, 'r', encoding='utf8') as fin, \
    io.open(outfile, 'w', encoding='utf8') as fout:
        for num, line in enumerate(fin):
            tokens = [sorted([j.replace('>', '> <') for j in 
                            list(set(i.split('|')))], 
                           key=lambda x:x.count(' '), reverse=True) 
                      for i in line.strip().split()]
    
            most_morph_tokens = unicode(" ".join([i[0] for i in tokens]))
            least_morph_tokens = unicode(" ".join([i[-2] if len(i) > 2 
                                           else i[-1] for i in tokens]))
            no_morph_tokens = unicode(" ".join([i[-1] for i in tokens]))
        
            fout.write(no_morph_tokens + '\n')
            fout.write(least_morph_tokens + '\n')
            fout.write(most_morph_tokens + '\n')
            
            '''
            c = 1
            print num, len(tokens),
            for sent in product(*tokens):
                #print num, len(tokens), c, sent
                c+=1
            print c
            '''

def duplicate_sents(infile, outfile, n=3):
    with io.open(infile, 'r', encoding='utf8') as fin, \
    io.open(outfile, 'w', encoding='utf8') as fout:
        for line in fin:
            for _ in range(n):
                fout.write(line)

infile = ['data/europarl.40k.train.fin',
          'data/europarl.5k.dev.fin',
          'data/europarl.5k.test.fin']
outfile = ['corpus.tok/train.fin', 
           'corpus.tok/dev.fin', 
           'corpus.tok/test.fin']

for i, o in zip(infile, outfile):
    preprocess_fin(i, o)
    
infile = ['data/europarl.40k.train.eng',
          'data/europarl.5k.dev.eng',
          'data/europarl.5k.test.eng']
outfile = ['corpus.tok/train.eng', 
           'corpus.tok/dev.eng', 
           'corpus.tok/test.eng']

for i,o in zip(infile, outfile):
    duplicate_sents(i,o)


