
ayear="/asl/data/airs/L1C/2016"

for f1 in `ls -d $ayear/???`
do
    echo -n `basename $f1` " "
    ls $f1/AIRS*L1C.AIRS_Rad*.hdf | wc -l
done

