# lattice-align

Lattice-based word alignment and phrase extraction for machine translation


## Installation

1. Install OpenFst 1.3
2. `pip install pyfst` (do not try installing directly from the git repository)

## Preprocess

python nbest-fst.py example/test_nbest2.txt example/test_nbest2.fst example/test_nbest2.isyms example/test_nbest2.osyms

fstcompile --isymbols=example/test_nbest2.isyms --osymbols=example/test_nbest2.osyms example/test_nbest2.fst example/test_nbest2.fst.bin
