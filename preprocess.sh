MOSES_SCRIPT=/home/expert/mosesdecoder/scripts
SCRIPT_DIR=/home/expert/script.converter.distribution

mkdir corpus.tok
cd corpus.tok

for file in train dev test; do
 cat ../corpus.org/${file}.en | \
    perl ${MOSES_SCRIPT}/tokenizer/tokenizer.perl -l en \
    > ${file}.tok.en 
done 

for file in train dev test; do
 cat ../corpus.org/${file}.fi | \
    perl ${MOSES_SCRIPT}/tokenizer/tokenizer.perl -l "fi" \
    > ${file}.tok.fi
done 

cat train.tok.en dev.tok.en > train_dev.tok.en
${MOSES_SCRIPT}/recaser/train-truecaser.perl --model truecase-model.en --corpus train_dev.tok.en

for file in train dev test; do 
  ${MOSES_SCRIPT}/recaser/truecase.perl --model truecase-model.en < ${file}.tok.en > ${file}.en 
done 

cat train.en > train-all.en

perl ${MOSES_SCRIPT}/training/clean-corpus-n.perl train "fi" en train-clean 1 80

