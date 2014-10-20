LANG_F=fi
LANG_E=en 
CORPUS_LM=../corpus.tok/train-all 
CORPUS=../corpus.tok/train-clean 
DEV_F=../corpus.tok/dev.${LANG_F} 
DEV_E=../corpus.tok/dev.${LANG_E} 
TEST=../corpus.tok/test.${LANG_F} 
REF=../corpus.tok/test.${LANG_E} 
LM_ORDER=10
JOBS=12 

MOSES_SCRIPT=/home/expert/mosesdecoder/scripts 
MOSES_BIN_DIR=/home/expert/mosesdecoder/bin 
EXT_BIN_DIR=/home/expert/giza-pp/bin 

WORK_DIR=work.${LANG_F}-${LANG_E} 
TRAINING_DIR=${WORK_DIR}/training 
MODEL_DIR=${WORK_DIR}/training/model 

mkdir phraseModel
cd phraseModel/
mkdir -p ${TRAINING_DIR}/lm

LM_FILE=`pwd`/${TRAINING_DIR}/lm/lm.${LANG_E}.arpa.gz 

${MOSES_BIN_DIR}/lmplz --order ${LM_ORDER} -S 80% -T /tmp < ${CORPUS_LM}.${LANG_E} | gzip > ${LM_FILE} 

${MOSES_SCRIPT}/training/train-model.perl \
  --root-dir `pwd`/${TRAINING_DIR} \
  --model-dir `pwd`/${MODEL_DIR} \
  --corpus ${CORPUS} \
  --external-bin-dir ${EXT_BIN_DIR} \
  --f ${LANG_F} \
  --e ${LANG_E} \
  --parallel \
  --alignment grow-diag-final-and \
  --reordering msd-bidirectional-fe \
  --score-options "--GoodTuring" \
  --lm 0:${LM_ORDER}:${LM_FILE}:8 \
  --cores ${JOBS} \
  --sort-buffer-size 10G \
  --parallel \
  >& ${TRAINING_DIR}/training_TM.log

${MOSES_SCRIPT}/training/filter-model-given-input.pl \
  ${MODEL_DIR}.filtered/dev \
  ${MODEL_DIR}/moses.ini \
  ${DEV_F}

mkdir -p ${WORK_DIR}/tuning

${MOSES_SCRIPT}/training/mert-moses.pl \
  ${DEV_F} \
  ${DEV_E} \
  ${MOSES_BIN_DIR}/moses \
  `pwd`/${MODEL_DIR}.filtered/dev/moses.ini \
  --mertdir ${MOSES_BIN_DIR} \
  --working-dir `pwd`/${WORK_DIR}/tuning/mert \
  --threads ${JOBS} \
  --no-filter-phrase-table \
  --decoder-flags "-threads ${JOBS} -distortion-limit 20" \
  --predictable-seeds \
  >& ${WORK_DIR}/tuning/mert.log 

perl ${MOSES_SCRIPT}/ems/support/substitute-weights.perl \
  ${MODEL_DIR}/moses.ini \
  ${WORK_DIR}/tuning/mert/moses.ini \
  ${MODEL_DIR}/moses-tuned.ini 


OUTPUT_DIR=${WORK_DIR}/output 
mkdir ${OUTPUT_DIR} 

${MOSES_SCRIPT}/training/filter-model-given-input.pl \
  ${MODEL_DIR}.filtered/test \
  ${MODEL_DIR}/moses-tuned.ini \
  ${TEST} 

outfile=${OUTPUT_DIR}/test.out 

${MOSES_BIN_DIR}/moses -config ${MODEL_DIR}.filtered/test/moses.ini -distortion-limit 20 -threads ${JOBS} < ${TEST} > ${outfile} 2> ${outfile}.log 

${MOSES_SCRIPT}/recaser/detruecase.perl < ${outfile} > ${outfile}.tok 
${MOSES_SCRIPT}/tokenizer/detokenizer.perl -l en < ${outfile}.tok > ${outfile}.detok 

