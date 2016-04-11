## this wrapper script calculates read depth from cnvnator and ROOT 
## do this in the directory you keep the personal genome; bin size
## for multiple genomes, write a shell script to create personal genome folders and copy this script individually into each folder and run them; this can be concurrent with vcf2diploid
## USAGE: alleleWrap_cnvnator_rd <1> <2> <3> <4> <5>
## <1> = individual's ID, e.g. NA12878
## <2> = path for BAM file, note that a softlink does NOT work
## <3> = <sequencer>_<genotypeCaller>_<date> e.g. hiseq_pcrfree_hc_130506
## <4> = path to FASTAs
## <5> = binsize e.g. 100 for high coverage (trio), 1000 for low coverage (1KG)
## e.g. ./alleleWrap_2_cnvnator_rd.sh NA12878 /here/na12878.bam miseq_pcr_free_131313 /here/reference/fasta

## creates cnv_rd folder prep for cnv read depth calculation
mkdir cnv_rd_$1_$3
cp -r ~/jmtools/alleleSeq_cnvScript/ cnv_rd_$1_$3
cd cnv_rd_$1_$3
ln -s /scratch/fas/gerstein/jc2296/personal_genomes/g1k_cnvnator_root/unrelated/his.$1.ILLUMINA.root
ln -s /scratch/fas/gerstein/jc2296/personal_genomes/g1k_cnvnator_root/unrelated/tree.$1.ILLUMINA.root
#cnvnator -root $1.$3.tree.root -tree $2
#cnvnator -root $1.$3.tree.root -outroot $1.$3.his.root -his $5 -chrom 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y -d $4
#cnvnator -root $1.$3.his.root -stat $5

cnvnator -root his.$1.ILLUMINA.root -eval $5 > binSize$5.log

## prepare addRD file
ln -s alleleSeq_cnvScript/addRD
rd=$(grep "Average RD per bin (1-22) is" binSize$5.log | sed 's/Average RD per bin (1-22) is //g'  | awk '{printf("%d\n"),$1 + 0.5}')
cd alleleSeq_cnvScript
./print_addRDcpp.sh tree.$1.ILLUMINA.root $rd./$5
make addRD
cd .. ## this gets out from cnvScript folder to cnv_rd folder
mv alleleSeq_cnvScript/create-split-chr-qsub.sh alleleSeq_cnvScript/cnvnator-root.sh .

## run addRD
## split and run (manual)
ln -s /net/gerstein/jc2296/personal_genomes/vcf2snp/$1.snp.calls
sed '1i\a\tb\tc\td\te\tf\tg' $1.snp.calls > $1.snp.calls_
# split accrding to chr
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X; do chr=$(echo $i); awk '{OFS="\t"}{FS="\t"}{if($1 == c){print $0}}' c=$chr $1.snp.calls_ >> fsplitchr"$i".$1.snp.calls; done
# this checks the number of snps
wc -l $1.snp.calls $1.snp.calls_ 
wc -l fsplitchr*.$1.snp.calls

## submit jobs
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X
do
 	echo "#!/bin/sh" > myscript-$1-$i.sh
        echo "#PBS -N myscript-$1-$i" >> myscript-$1-$i.sh
        echo "#PBS -l ncpus=1" >> myscript-$1-$i.sh
        echo "#PBS -V" >> myscript-$1-$i.sh
        echo "#PBS -o myscript-$1-$i.log" >> myscript-$1-$i.sh
        echo "#PBS -e myscript-$1-$i.err" >> myscript-$1-$i.sh

        echo "date" >> myscript-$1-$i.sh
        echo  >> myscript-$1-$i.sh
        echo "cd $(pwd)"  >> myscript-$1-$i.sh
        echo "./addRD fsplitchr"$i".$1.snp.calls >& fsplitchr"$i".$1.snp.calls.log"   >> myscript-$1-$i.sh
        echo "date" >> myscript-$1-$i.sh
	chmod +x myscript-$1-$i.sh
	qsub -l walltime=2400:00:00 -q gerstein myscript-$1-$i.sh
done

#mkdir scripts_logs
#mv *.log myscript-*.sh scripts_logs

#mkdir trash
#mv fsplitchr*.$1.snp.calls trash
#mv $1.snp.calls_ trash
