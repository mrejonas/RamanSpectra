#!/usr/bin/perl -w

# This script runs baseline correction for Raman Spectra on spectra files
# in the current working directory
foreach $prnfile(@ARGV){
  $prnfilename = $prnfile;
  #Remove some special characters from filenames
  $prnfilename =~ s/-/_/g;  $prnfilename =~ s/\(/_/g;
  $prnfilename =~ s/\)/_/g;  $prnfilename =~ s/\'/_/g;
  $prnfilename =~ s/ +/_/g;  $prnfilename =~ s/\+/postive/g;
  # To ensure a filename starts with a string, pre-pend "XY_"
  $prnfilename = "XY_".$prnfilename;
  system("mv $prnfile $prnfilename");
  # Create different output filenames
  $baselineoutfile = $prnfilename; $baselineoutfile =~ s/\..+$/_baseline\.csv/;
  $txtfilename = $prnfilename; $txtfilename =~ s/\.prn/\.txt/;
  $trimmedtext = $prnfilename; $trimmedtext =~ s/\.prn/_trimmed\.txt/;
  $samplename = $trimmedtext; $samplename =~ s/\..+$//;
  $finalout = $samplename."_corrected.csv" ;
  open(PRNFILE,$prnfilename);
  open(TXTFILE,">>$txtfilename");
  # Convert .prn file into a parsable .txt file
  while(<PRNFILE>){ s/\r/\n/g; print TXTFILE; }
  close(TXTFILE);
  close(PRNFILE);
  open(TXTFILE,$txtfilename);
  open(TRIMMEDTXT, ">>$trimmedtext");
  my $flag = 0;
  # Further editing of .prn file to only print out Wavenumber vs Intensity
  while(<TXTFILE>){
    if(/Crypto/){ $flag = 1; }
    if(($flag == 1) && ($_ !~ /CryptoSignature/)){ print TRIMMEDTXT; }
  }
  close(TRIMMEDTXT);
  close(TXTFILE);

  # Create Octave/ Matlab script to call Goldindec script
  open(RUN,">run_me.m");
  print RUN "addpath ./\n",
        "load $trimmedtext\n",
        "Goldindec($samplename,4,0.5,0.0001,",
        "'./');";
  close(RUN);

  # Run baseline correction and create output that contains Wavenumber vs
  # Raw Intensity vs Baseline Intensity vs Corrected Intensity
  print "Processing $samplename\n";
  system("octave run_me.m");
  system("mv output.csv $baselineoutfile");
  system("sed s'/,/\t/' $baselineoutfile > temp.csv");
  # The "rename" command may differ between platforms
  rename("temp.csv", $baselineoutfile);
  system("paste $trimmedtext $baselineoutfile | awk 'BEGIN {OFS=\"\t\"}{dif=\$2-\$4;print \$1,\$2,\$4,dif}'> $finalout");

  # Clean up
  system("rm $trimmedtext $baselineoutfile run_me.m");
}
