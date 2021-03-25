#! /usr/sbin/perl
#
# Program  : Ls2LstW.pl
# Purpose  : Convert output of unix bash comand "ls" to ToTal Commander diskdir_list *.LstW format
# Arguments : -
# Changes  : original version  : 25.03.2013 10:53 by peg
#            ls - new format v2: 08.06.2020 12:06 by peg
# Notes    : more info bellow after __END__
#
#           cd /volume2/Fldr1/peg/ls2Lst/
# Spusteni: perl -W ls2lst.pl <  Test.Txt  >  Test.LstW
#
# http://docstore.mik.ua/orelly/perl/cookbook/
# http://docstore.mik.ua/orelly/bookshelf.html

#  use strict;
#  use utf8;

#-------------------------------------------------------------------------------
# Configuration varible
$, = '\;';   # set output field separator
$\ = "\n";   # set output record separator
$" = "";     # applies to array values interpolated into a double-quoted string"
# Konstanty
# $cEaDir = '@eaDir'; # retezec @eaDir pro filtrovani
#-------------------------------------------------------------------------------
# Popis
$PopisRetezcu = '
-- z retezce --
"/volume2/Fldr1/peg/ls2Lst":
total 24612
drwxr-x---  3 admin users     4096 2020-06-10 13:42:34.335887811 +0200 "."
-rwxr-x---  1 admin users     9410 2014-10-01 21:45:00.552897900 +0200 "rsync.txt"

-- na retezec --
ls2Lst\	0	2020.6.10	13:18.54
rsync.txt	9410	2014.10.1	21:45.2
'; $PopisRetezcu = '';
#-------------------------------------------------------------------------------
# Perl - Date and Time - https://is.gd/ahZI5B
use POSIX qw(strftime);
$datestring = strftime "%F %T", localtime;
# printf("date and time - $datestring\n");
print        'N:\_' . $0 . '_v1.04_by_peg\\   Generated at: ' . $datestring;
print STDERR 'N:\_' . $0 . '_v1.04_by_peg\\   Generated at: ' . $datestring;
#-------------------------------------------------------------------------------
# Hlavni smycka
$Poprve = 5; # preskocim prvni 2 radky
# $DirOk  = 0; # filtruje vse z adresaru @eaDir
$dn     = ''; # jmeno adresare
while (<STDIN>) {
  $ln = $_;
  chomp($ln); # chomp only removes the last character if it is a newline
  # print STDERR "\nDelam: ".$ln;
  # print STDERR 'substr($ln, 0, 1): ' . substr($ln, 0, 1) . '<<';
  #  print STDERR "Poprve: " . $Poprve;
  #
  # Zpracovani radku
  if (  (!$Poprve)  ) {
    # Emty line
    next if ($ln eq '');
    # Parsovani radku
    if ( ( substr($ln, -1) ne ':') && ( substr($ln, 0, 1) ne 't')  ) {
      # file name
      ($fn) = $ln =~ /\".*\"/g;
      $fn = substr($fn, 1,-1);          #  print 'ln:'.$ln."\n";
      $fn =~ s/\:/\`/g;    # fix: ':'   ->  '`'
      $fn =~ s/\\/\`/g;    # fix: '\'   ->  '`'
      # file size
      ($fs) = $ln =~ /\s\d+\s\d+\-\d+\-\d+/g;
      ($fs) = $fs =~ /\s\d+\s/g;
      $fs =~ s/^\s+|\s+$//g;  # trim both ends - https://is.gd/h1848m
      # file date
      ($fd) = $ln =~ /\d+\-\d+\-\d+/g;
      # file date - oprava odelovace '2020-06-10' -> '2020.6.10'
      $fd =~ s/\-/\./g;  # print 'fd:'.$fd."\n";
      # file time
      ($ft) = $ln =~ /\d+\:\d+\:\d+/g;
      # file time - oprava sekund '19:48:10' -> '19:48.10'
      $ft =~ s/(\d+):(\d+):(\d+)/$1:$2.$3/g;  # print 'ft:'.$ft."\n";
      #  print STDERR "ln: " . $ln;
      #  print STDERR "fn: " . $fn;
      #  print STDERR "fs: " . $fs;
      #  print STDERR "fd: " . $fd;
      #  print STDERR "ft: " . $ft;
      #    print "\n";
      #
    };
    # Analyza radku
    if ( substr($ln, -1) eq ':') {          # adresar - Nazev
      # directory name
      $dn = substr($ln, 2,-2) . '/';        #  print 'ln:'.$ln."\n";
      $dn =~ s/\//\\/g;    # fix: '/'   ->  '\'
      $dn =~ s/\\\\/\\/g;  # fix: '\\'  ->  '\'
      $dn =~ s/\:/\`/g;    # fix: ':'   ->  '`'
      #  print STDERR '   -adresar  dn: ' . $dn . "\n";
    } elsif ( substr($ln, 0, 1) eq 't') {   # total nnn - se vynechava
      # total nnn - se vynechava
    } elsif ( substr($ln, 0, 1) eq 'd') {   # podadresar tj. "." nebo ".." nebo "nazev adresare"
      #  print STDERR '   -podadresar';  print STDERR $ln."\n";
      # ".." - podadresar se vynechava
      # "."  - tisknu adresar
      if ( $fn eq '.')  { # "."  - tisknu adresar
        print $dn."\t".'0'."\t".$fd."\t".$ft;    # '	323	2013.2.28	7:53.26';
      }
    } elsif ( substr($ln, 0, 1) eq '-') {   # radek souboru '-'
      # print STDERR '   -radek  fn: ' . $fn;
      print $fn."\t".$fs."\t".$fd."\t".$ft;    # '	323	2013.2.28	7:53.26';
    } else {
      # ostatni radky nedelam, napr. l - link
    }
#    print $ln."\n";
#    @eaDir - vsechny adresare co maji v nazvu vynechavam vcetne souboru v nich
  } else {
    # preskoceni 1. a 2. radku vstupniho souboru
    --$Poprve;
  }
}
print STDERR 'Konec.';
__END__

--------------------------------------------------------------------------------
:Algoritmus:
- spusteni unix shell skriptu co vylistuje soubory pres cely disk
  ls -Ra -l --time-style=long-iso
- preskocim 1. a 2. radek se preskakuji
akt. radek JE dir
- je radek s nazvem adresare zacina '/' a konci ':'
- nasledujici radek se preskakuje
- nasledujici radek s datem a casem adresare
akt. radek JE soubor
  - beru: jmeno size date time
--------------------------------------------------------------------------------

__END__

#
# Postup
#
# spusteni unix shell skriptu co vylistuje soubory pres cely disk
# ls -l | ./showtext  -This will display the output from the ls -l command as though it too was typed by the user at the keyboard.
#
# Vstupni soubor
#   1. radek informativni
#   : - posleni znak na radku - nazev adresare
#   d - 1.znak na radku       - radek s info o podadresari
#   - - 1.znak na radku       - radek s info o souboru
#
# Vystupni soubor
#   1. radek informativni
#   \ - posleni znak nazvu    - cely nazev adresare
#     - jinak                 - radek s info o souboru
# Transformace adresare - na konec misto : je \;   vymena / za \
# /.syno/patch:   na \.syno\patch\
#
#
#

cd /volume1/Fldr3_Test
whoami    >  lst.txt
pwd       >> lst.txt
ls -laR / >> lst.txt

__END__
