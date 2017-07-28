#!/usr/bin/perl -w
$qsub_bash = "#!/bin/bash\n" ;

$qsub_directive = <<'END_DIRECTIVE';
#PBS -S /bin/bash
#PBS -q UCTlong
#PBS -l nodes=2:ppn=4:series600
#PBS -V
#PBS -M mario.jonas@uct.ac.za
#PBS -m ae
END_DIRECTIVE

$spectrum_num = 1;
foreach $prnfile(@ARGV){
  $prnfilename = $prnfile;
  $prnfilename =~ s/-/_/g;
  $prnfilename =~ s/\(/_/g;
  $prnfilename =~ s/\)/_/g;
  $prnfilename =~ s/\'/_/g;
  $prnfilename =~ s/ +/_/g;
  $prnfilename =~ s/\+/postive/g;
  $prnfilename = "XY_".$prnfilename;
  system("mv $prnfile $prnfilename");
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
        "GoldindecQsub($samplename,4,0.5,0.0001,'./',\"$samplename\");";
  close(RUNOCTAVE);

  open(RUNQSUB,">$samplename.qsub");
  print RUNQSUB $qsub_bash;
  print RUNQSUB "#PBS -N spectrum$spectrum_num\n";
  print RUNQSUB $qsub_directive,"\n";
  print RUNQSUB "module add software/octave-4.0.0\n",
      "octave --no-gui $samplename.m\n",
      "sed s'/,/\t/' $samplename.csv > $baselineoutfile\n",
      "paste $trimmedtext $baselineoutfile | awk 'BEGIN {OFS=\"\t\"}{dif=\$2-\$4;print \$1,\$2,\$4,dif}'> $finalout\n",
      "rm $samplename.csv $trimmedtext $baselineoutfile $txtfilename\n";

  close(RUNQSUB);

  system("qsub -d . $samplename.qsub");
  $spectrum_num++;
  if(($spectrum_num % 100) == 0){sleep 300;}
}
