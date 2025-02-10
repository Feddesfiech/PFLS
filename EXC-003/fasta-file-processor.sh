if [ $# -ne 1 ]; then
    echo "USE $0 /INPUTFILE.fna"
    exit 1
fi  
sequences=$(awk '!/^>/{print}' "$1")

num_seq=$(grep -c  '>' $1)

tot_length=$(awk '/^>/ {next} {total += length($0)} END {print total}' "$1")

longest_seq=$(echo "$tot_length" | sort -nr | head -n1)

shortest_seq=$(echo "$tot_length" | sort -n | head -n1)

# aver_seq_length=$($ bc <<< "$tot_length/$num_seq")

gc_count= $(echo "$sequences" | grep -o '[GCgc]' | wc -l)

echo "FASTA File Statistics:"
echo "----------------------"
echo "Number of sequences: $num_seq"
echo "Total length of sequences: $tot_length"
echo "Length of the longest sequence: $longest_seq"
echo "Length of the shortest sequence: $shortest_seq"
echo "Average sequence length: $aver_seq_length"
echo "GC Content (%): $gc_cont"