# This script was MODIFIED by feddesfiech



# remove COMBINED-DATA directory if it might exist
rm -rf COMBINED-DATA

# create a new COMBINED-DATA directory (known for sure no previous ones)
mkdir -p COMBINED-DATA
#if [ ! -d $COMBINED-DATA ]; then
#    mkdir $COMBINED-DATA
#fi

# loop through all directories that have FASTA files
for fasta in $(ls -d RAW-DATA/DNA*); do
    # extract the culture name
    culture_name=$(basename $fasta)

    # assign the new name for a given culture from sample-translation.txt
    new_culture_name=$(grep $culture_name RAW-DATA/sample-translation.txt | awk '{print $2}')

    # assign a value to the counter, that the bins and mags will be sorted beginning with one
    MAG_counter=1
    BIN_counter=1

    # copy files that contain completion estimates and taxonomy into the new directory COMBINED-DATA as XXX-CHECKM.txt and XXX-GTDB-TAX.txt
    cp $fasta/checkm.txt COMBINED-DATA/$new_culture_name-CHECKM.txt
    cp $fasta/gtdb.gtdbtk.tax COMBINED-DATA/$new_culture_name-GTDB-TAX.txt

    # loop through each FASTA file in the bins/ directory and remove .fasta
    for fasta_file in $fasta/bins/*.fasta; do
        bin_name=$(basename $fasta_file .fasta)

        # search and print the completion and contamination percentages and print the actual numbers by piping it into awk. Counting the numbers, It should be $12 and $13, but by using $awk '{print NR, $12, $13, $14}' checkm.txt  column $13 and $14 was shown as correct columns. At the Marker lineage there is an empty space which indicates the aditional column.  
        completion=$(grep "$bin_name" $fasta/checkm.txt | awk '{print $13}')
        contamination=$(grep "$bin_name" $fasta/checkm.txt | awk '{print $14}')

        # reset the "new name" to indicate if the file is UNBINNED, BIN or MAG for the FASTA file (e.g. name it "UNBINNED"if the bin is unbinned)
        #  is MAG if the completion is 50% or more and contamination is 5% less according to the information in stored in the relevant checkm.txt file, otherwise it is BIN
        # & number the MAGs       
        if [[ $bin_name == bin-unbinned ]]; then
            new_name="${new_culture_name}_UNBINNED.fa"
        elif (( $(echo "$completion >= 50" | bc -l) && $(echo "$contamination < 5" | bc -l) )); then
            new_name=$(printf "${new_culture_name}_MAG_%03d.fa" $MAG_counter)
            MAG_counter=$(("$MAG_counter + 1"))
        else
            new_name=$(printf "${new_culture_name}_BIN_%03d.fa" $BIN_counter)
            BIN_counter=$(($BIN_counter + 1))
        fi

        # new names are introduced and replaced
        sed -i "s/ms.*${bin_name}/$(basename "$new_name" .fa)/g" "COMBINED-DATA/${new_culture_name}-CHECKM.txt"
        sed -i "s/ms.*${bin_name}/$(basename "$new_name" .fa)/g" "COMBINED-DATA/${new_culture_name}-GTDB-TAX.txt"

        # copy 
        cp $fasta_file COMBINED-DATA/$new_name
    done
done