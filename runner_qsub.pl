#!/usr/bin/perl -w

foreach $prnfilename(@ARGV){
  $baselineoutfile = $prnfilename; $baselineoutfile =~ s/\..+$/_baseline\.csv/;
  $txtfilename = $prnfilename; $txtfilename =~ s/\.prn/\.txt/;
  $trimmedtext = $prnfilename; $trimmedtext =~ s/\.prn/_trimmed\.txt/;
  $samplename = $trimmedtext; $samplename =~ s/\..+$//;
  $finalout = $samplename."_corrected.csv" ;
  open(PRNFILE,$prnfilename);
  open(TXTFILE,">>$txtfilename");
  while(<PRNFILE>){ s/\r/\n/g; print TXTFILE; }
  close(TXTFILE);
  close(PRNFILE);
  open(TXTFILE,$txtfilename);
  open(TRIMMEDTXT, ">>$trimmedtext");
  my $flag = 0;
  while(<TXTFILE>){
    if(/Crypto/){ $flag = 1; }
    if(($flag == 1) && ($_ !~ /CryptoSignature/)){ print TRIMMEDTXT; }
  }
  close(TRIMMEDTXT);
  close(TXTFILE);
  open(RUNOCTAVE,">$samplename.m");

  print RUNOCTAVE "addpath ./\n",
        "load $trimmedtext\n",
        "GoldindecQsub($samplename,4,0.5,0.0001,",
        "'./',\"$samplename\");";
  close(RUN);

  open(RUNQSUB,">$samplename.qsub");
  print RUNQSUB "octave $samplename.m\n",
          "mv $samplename.csv $baselineoutfile\n",
          "sed s'/,/\t/' $baselineoutfile > $samplename.temp.csv\n",
          "rename(\"$samplename.temp.csv\", $baselineoutfile)\n",
          "paste $trimmedtext $baselineoutfile | awk 'BEGIN {OFS=\"\t\"}{dif=\$2-\$4;print \$1,\$2,\$4,dif}'> $finalout\n";
  close(RUNQSUB);

  system("qsub -d . $samplename.qsub");

  system("time octave $samplename.m");
  system("mv $samplename.csv $baselineoutfile");
  system("sed s'/,/\t/' $baselineoutfile > $samplename.temp.csv");
  rename("$samplename.temp.csv", $baselineoutfile);
  system("paste $trimmedtext $baselineoutfile | awk 'BEGIN {OFS=\"\t\"}{dif=\$2-\$4;print \$1,\$2,\$4,dif}'> $finalout");
}
