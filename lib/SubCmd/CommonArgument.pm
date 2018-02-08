package SubCmd::CommonArgument;

use strict;
use warnings;
use File::Basename;
use FindBin;
use Pod::Usage;
use Cwd qw(abs_path);

use Meth::OverRegion;

## class, $opts, $opts_sub
sub new{
    my $class     = shift;
    return bless {}, $class;  # built in bless function 
}

sub common_argument{

    my ($class, $opts_sub, $exit_code) = @_;
   
    my $exit_code_common = 0;
    my ($sub_cmd) = @{$opts_sub->{subcommand}};
    #print "Test: $sub_cmd\n";
    #### This is mainly for MethOverRegion
    #flank regions
    if(!$opts_sub->{"flank"}){
	if($sub_cmd eq "MethOverRegion"){
	    $opts_sub->{"flank"} = 2000;
            # binLength
	    if(!$opts_sub->{"binLength"}){
        	$opts_sub->{"binLength"} = 100;
            }
	    if(1000 % $opts_sub->{"binLength"} != 0){
                print "ERROR: If we use 1000 to divide binLenght, we shoud get no remainder. Otherwise we need to reset binLength\n";
	        ++$exit_code_common; #exit 0;
	    }else{
		### check lib/Meth/OverRegion.R
		$opts_sub->{adjustXaxis} = 1000 / $opts_sub->{"binLength"}; 
	    }
        }elsif($sub_cmd eq "MethOneRegion"){
	    $opts_sub->{"flank"} = 300;
        }
    }

    # binNumber
    if(!$opts_sub->{"binNumber"}){
        $opts_sub->{"binNumber"} = 60;
    }
   
    # minLength
    if(!$opts_sub->{"minLength"}){
        $opts_sub->{"minLength"} = 300;
    }

    # maxLength
    if(!$opts_sub->{"maxLength"}){
        $opts_sub->{"maxLength"} = 5000000;
    }
    ## output directory  
    if(!$opts_sub->{"outdir"}){
        $opts_sub->{"outdir"} = abs_path "./";
    }else{
        if(-e  $opts_sub->{"outdir"} && !-d $opts_sub->{"outdir"}){
            print "File $opts_sub->{outdir} already exists. Please provide a new directory name.\n";
            ++$exit_code_common; #exit 0;
        }
        `mkdir $opts_sub->{"outdir"}` if !-d $opts_sub->{outdir};
        $opts_sub->{"outdir"} = abs_path $opts_sub->{"outdir"};
    }
    `mkdir $opts_sub->{"outdir"}` if !-d $opts_sub->{outdir};
    print "Output directory is: $opts_sub->{outdir}\n" if $exit_code == 0;
    
    if(!$opts_sub->{"prefix"}){
	$opts_sub->{prefix} = $sub_cmd;
	print "Default output prefix is used: $sub_cmd\n" if $exit_code == 0; 
    }else{
	print "Output prefix: $opts_sub->{prefix}\n" if $exit_code == 0;
    }
   
    
    # GlobalMethLev, BisNonConvRate, MethCoverage, MethLevDist, MethGeno, MethOverRegion, MethHeatmap, MethOneRegion 
    #my %rec_cord = {""};
    if(!@{$opts_sub->{context}}){
        if($sub_cmd ne "BisNonConvRate"){
	    #print "$opts_sub->{subcommand} ne BisNonConvRate\n"; 
            push @{$opts_sub->{context}}, "CG";
        }else{
            ## CXX means calculate conversion rate based on all the Cytosines.
            # One reviewer asked one questions about whether we can calculate the conversion rate for different context. So we add --context for subcommand "BisNonConvRate"
	    push @{$opts_sub->{context}}, "CXX"; 
        }
    }

    if(!$opts_sub->{"minDepth"}){
        $opts_sub->{"minDepth"} = 5;
    }

    if(!$opts_sub->{"maxDepth"}){
        $opts_sub->{"maxDepth"} = 1000000;
    }

    ##### lib/SubCmd/MethGeno.pm
    #window size
    if(!$opts_sub->{"win"}){
        $opts_sub->{"win"} = 500000;
    }
    ## step size
    if(!$opts_sub->{"step"}){
        $opts_sub->{"step"} = 500000;
    } 
   
    ##### lib/SubCmd/MethHeatmap.pm 
    if(!$opts_sub->{"cluster_rows"}){
        $opts_sub->{"cluster_rows"} = "TRUE";
    }else{
        $opts_sub->{"cluster_rows"} = uc $opts_sub->{"cluster_rows"};
        my $value = $opts_sub->{"cluster_rows"};
        if($value ne "TRUE" && $value ne "FALSE"){
            print "--cluster_rows should be either FALSE or TRUE. Please check\n";
            ++$exit_code_common;
        }
    }

    if(!$opts_sub->{"cluster_cols"}){
        $opts_sub->{"cluster_cols"} = "FALSE";
    }else{
        $opts_sub->{"cluster_cols"} = uc $opts_sub->{"cluster_cols"};
        my $value = $opts_sub->{"cluster_cols"};
        if($value ne "TRUE" && $value ne "FALSE"){
            print "--cluster_cols should be either FALSE or TRUE. Please check\n";
            ++$exit_code_common;
        }
    }

    # random_region 
    if(!$opts_sub->{random_region}){
        $opts_sub->{random_region} = 2000;
    }

    ##### For generating figures.  ######
   
    if(!$opts_sub->{width}){
        $opts_sub->{width} = 10;
    }
   
    if(!$opts_sub->{height}){
        $opts_sub->{height} = 10;
    }
  
    if(!$opts_sub->{width2}){
        $opts_sub->{width2} = 10;
    }

    if(!$opts_sub->{height2}){
        $opts_sub->{height2} = 10;
    }
   
    return $exit_code_common;
}

1;
