### usage: create-script-and-qsub.sh 0 8
### 0 to 8

### function to create scripts
function create-myscript
## arg_1 = param 1 passed in to create-script-and-qsub.sh script
{
	echo "#!/bin/sh" > myscript-$1.sh
	echo "#PBS -N myscript-vik-$1" >> myscript-$1.sh
	echo "#PBS -l ncpus=1" >> myscript-$1.sh
	echo "#PBS -V" >> myscript-$1.sh
	echo "#PBS -o myscript-vik-$1.log" >> myscript-$1.sh
	echo "#PBS -e myscript-vik-$1.err" >> myscript-$1.sh

	echo "date" >> myscript-$1.sh
	echo  >> myscript-$1.sh
	echo "cd /home/jc2296/1KG/1KG_phase1_hg19"  >> myscript-$1.sh
	echo "zcat ALL.chr$1.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz | grep -e ^# -e SNP | vcf-subset -c NA06984,NA06986,NA06989,NA06994,NA07000,NA07037,NA07048,NA07051,NA07056,NA07347,NA07357,NA10847,NA10851,NA11829,NA11830,NA11831,NA11843,NA11892,NA11893,NA11894,NA11919,NA11920,NA11930,NA11931,NA11932,NA11933,NA11992,NA11993,NA11994,NA11995,NA12003,NA12004,NA12006,NA12043,NA12044,NA12045,NA12046,NA12058,NA12144,NA12154,NA12155,NA12249,NA12272,NA12273,NA12275,NA12282,NA12283,NA12286,NA12287,NA12340,NA12341,NA12342,NA12347,NA12348,NA12383,NA12399,NA12400,NA12413,NA12489,NA12546,NA12716,NA12717,NA12718,NA12748,NA12749,NA12750,NA12751,NA12761,NA12763,NA12775,NA12777,NA12778,NA12812,NA12814,NA12815,NA12827,NA12829,NA12830,NA12842,NA12843,NA12872,NA12873,NA12874,NA12889,NA12890 | bgzip -c > ceu.ALL.chr$1.phase1_release_v3.20101123.snps.vcf.gz"   >> myscript-$1.sh
	echo "date" >> myscript-$1.sh
}

### main 
for (( i=$1; i <= $2; i++ ))
do
	create-myscript $i
	chmod +x myscript-"$i".sh
	#qsub -q gerstein myscript-"$i".sh
done
