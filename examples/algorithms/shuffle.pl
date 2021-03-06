use v6;

sub fisher_yates_shuffle (@copy is copy) returns Array {
   for  0..@copy-1  -> $i {
      my $j = (1..$i).pick;
      @copy[$i,$j] = @copy[$j,$i];
   }
   return @copy;
}

sub compare (@a,@b) returns Str{
    state $compared; 
    for 0..(@a >= @b ?? @a-1 !! @b-1) -> $i{
        $compared ~= "@a[$i] \t @b[$i]\n"; 
    }
    $compared;    
}

my @nums = 1..50;
my @shuf = fisher_yates_shuffle @nums ;
say compare @nums,@shuf;

