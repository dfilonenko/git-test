#! ./perl
#
#use Win32;
#Win32::MsgBox('ok');
#use utf8;
use DBI;
use locale;
use Benchmark;
use Encode qw(from_to);
use Cwd;

#use POSIX qw(locale_h);
#setlocale(LC_ALL, 'CP-1251');
#my $my_encoding = 'cp1251';
#my $file_encoding = 'cp866';

my $SID="CD";
   my $host="10.0.100.101";
   my $user="IMPORT_USER";
   my $parol="IMPORT_DOLGNIKI";
   my $port="1521";
   ##
   my $dbhOracle=DBI->connect("dbi:Oracle:host=$host;sid=$SID;port=$port",$user,
       $parol,{AutoCommit=>0,RaiseError=>1}) or die "No connect to Oracle:$DBI::errstr\n";
#$statement="SELECT sysdate from dual";
#my $sth=$dbhOracle->prepare($statement);
#       $sth->execute();










($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$file_currentCol=0;
$strFileCurrent;
$strFileColumn;

$strReStreet="вулиця|провулок|переулок|проспект|квартал|проїзд|тупик|вул|ул|пров|пр|пр-т|м-н|пер|с|в";
$strReVillage="село|сел|смт|пгт|с|c|п";
$strReTown="мiсто|город|м|г";
$strReBuld="дом|буд|д|б";

my $t0;my $t1; my $td; my $rt;
my $fetch_bool;
$t0_sql;$t1_sql;$td_sql;
 PrepareParameters(@ARGV);
my $double_name;
my $current_path;
my $fetch_street=1;
$current_path=getcwd();

#open(FL, 'C:\PostIndex\Import 78.csv') || die "Can't open file \n";
#open(FL, 'C:\PostIndex\Import2.csv') || die "Can't open file \n";
#open(FL, 'C:\PostIndex\Import3.csv') || die "Can't open file \n";
open(FL, $strFileCurrent ) || die "Can't open file \n";
open(fff, ">convert".$strFileColumn.".csv") || die "Can't open file \n";
#open(test, '>C:\PostIndex\test.txt') || die "Can't open file \n";
my $dsn="Driver={Microsoft dBASE Driver (*.dbf)};FIL=FOXPRO 2.6;Dbq=$current_path ";
$dbh = DBI->connect("dbi:ADO:$dsn", "", "") or die $DBI::errstr;



$states_ua=(",ВIННИЦЬКА,ВОЛИНСЬКА,ДНIПРОПЕТРОВСЬКА,ДОНЕЦЬКА,ЖИТОМИРСЬКА,ЗАКАРПАТСЬКА,
ЗАПОРIЗЬКА,IВАНО-ФРАНКIВСЬКА,КИЇВСЬКА,КIРОВОГРАДСЬКА,ЛУГАНСЬКА,ЛЬВIВСЬКА,
МИКОЛАЇВСЬКА,ОДЕСЬКА,ПОЛТАВСЬКА,РIВНЕНСЬКА,СУМСЬКА,ТЕРНОПIЛЬСЬКА,
ХАРКIВСЬКА,ХЕРСОНСЬКА,ХМЕЛЬНИЦЬКА,ЧЕРКАСЬКА,ЧЕРНIВЕЦЬКА,ЧЕРНIГIВСЬКА,");

$states_ru=(",ВИННИЦКАЯ,ВОЛЫНСКАЯ,ДНЕПРОПЕТРОВСКАЯ,ДОНЕЦКАЯ,ЖЫТОМЫРСКАЯ,ЗАКАРПАТСКАЯ,
ЗАПОРОЖСКАЯ,ИВАНО-ФРАНКОВСКАЯ,КИЕВСКАЯ,КИРОВОГРАДСКАЯ,ЛУГАНСКАЯ,ЛЬВОВСКАЯ,
НИКОЛАЕВСКАЯ,ОДЕССКАЯ,ПОЛТАВСКАЯ,РОВНЕНСКАЯ,СУМСКАЯ,ТЕРНОПОЛЬСКАЯ,
ХАРКОВСКАЯ,ХЕРСОНСКАЯ,ХМЕЛЬНИЦКАЯ,ЧЕРКАСКАЯ,ЧЕРНОВЕЦКАЯ,ЧЕРНИГОВСКАЯ,");

@a_states_ua=split(/,/,$states_ua);
@a_states_ru=split(/,/,$states_ru);
$ListTown;
ActivListTown();

@states=("ВIННИЦЬКА","ВОЛИНСЬКА","ДНIПРОПЕТРОВСЬКА","ДОНЕЦЬКА","ЖИТОМИРСЬКА","ЗАКАРПАТСЬКА",
         "ЗАПОРIЗЬКА","IВАНО-ФРАНКIВСЬКА","КИЇВСЬКА","КIРОВОГРАДСЬКА","ЛУГАНСЬКА","ЛЬВIВСЬКА",
         "МИКОЛАЇВСЬКА","ОДЕСЬКА","ПОЛТАВСЬКА","РIВНЕНСЬКА","СУМСЬКА","ТЕРНОПIЛЬСЬКА",
         "ХАРКIВСЬКА","ХЕРСОНСЬКА","ХМЕЛЬНИЦЬКА","ЧЕРКАСЬКА","ЧЕРНIВЕЦЬКА");




$i=0;
my $str;
while ($string = <FL>) {
$u_town='';
#$t0=new Benchmark;
#open(fff, '>>C:\PostIndex\exp.txt') || die "Can't open file \n";
  @array = split(/;/,$string);
  $text=' '.$array[$strFileColumn]; #12  20 24


  $text=replvt($text); #dima!!!

  $text=~ s/Автономна Республ.ка Крим/АРК/i;
  $text=~ s/Республика Крым/АРК/i;




 if($text=~m/(?<=[\s,.])(АРК|Крим|Крым)(?=[\s,.])/i){
    $ark=$1;
	$text=~ s/$ark//gi;}
  else {$ark='';}

  $text=~s/\s*\-\s*/\-/gi;
  $text=~s/\"+/\'/gi;
  $text=~s/\'+/\'/gi;
  $text=~s/(\s+)/ /gi;
  $text=~ tr/І/I/;
  $text=~ tr/і/i/;
  $text=~s/\.,/\./gi;
  $text=~s/\`+/\'/gi;
  $text=~s/\n//g;
  $text=~s/\b\-*мiсто\b/ м\./i;
  $text=~s/\b(село|сел)\.*\b/ с\./i;
  $text=~s/\bх+\b//gi;
  $text=~s/,\s,/,/gi;
  $text=~s/\_+//g;
  $text=~s/с\.м\.т\./смт\./i;
  $text=~s/областi/обл\./i;

  #$text=~s//i;
  #$text=~tr/=//;
 # $text=~s/\b\\+\b//g;
 #$text=~s/\b\*+\b//g;

  if($text=~ m/(\d{4,5})/){
    $index=$1;
   # $text=~ s/\d{5}//;
   $text=~ s/$index//;

    if($index eq '00000' || $index eq '0000' || length($index)>5){  #dima!!!
     $index='';}

  }
  else { $index=''; }







    if($text=~ m/((?<=[\s,.])(\w*\'*\w*\s*-*)(\w*\'*(\w+ька|\w+кая)))/i){ #(?<=[\s,.])(\w*)
      $state=trim($1);
      $double_name=trim($3);
       if(CheckState1(uc $state)) {

       }
       elsif (CheckState1(uc $double_name)==1) {
         $state=$double_name;
	   }
	   else{$state='';}

    }
    else { $state=''; }


    if ($state) {
         $text=~ s/$state//i;
		 $text=~ s/(область|обл)//i;

    }

      # town select

   #if($text=~ m/([мг]\.\S+|(?<!\S)[мг]\s\S+)/i){
   #if($text=~ m/((?<=[\s,.])[мг][\s,.]+\S+)/i){  #\.\s  [\s-\s]*(\w*)(?!(вул|ул)) (\s*)(-*)(\s*)(\w*)
   # if($text=~ m/((?<=[\s,.])[мг][\s,.]+(\w+))/i){

    $text=~ s/^[\s,.\'\-\*\\\=]+//;
    if($text=~ m/^\w+/){  $text=" ".$text;}

	if($text=~ m/((?<=[\s,.])(${strReTown})[\s,.]+(\w+\'*\w*\s*-*\w*\'*\w*))/i){ #1
	  $town=$1;
	  $str=$`;
	    if ($str=~ m/(${strReVillage})[.,]$/i) { # проверка если есть  cпереди слово село
          $town='';
	    }
        $town=trim(DelWordToTown($town));

	    if ($town && CheckTown(uc $town)) {  # поиск города
		  $text=~ s/$town//i;
	    }
	    elsif($text=~ m/((?<=[\s,.])(${strReTown})[\s,.]+(\w+\'*\w*))/i){#2 # если не удачно, то поиск по первом слове
	       $town=$1;
	       $str=$`;
	       $p_var1=~s/(?<=[\s.])((${strReStreet})$)//i;

	       if ($str=~ m/(${strReVillage})[.,]$/i) {
              $town='';
	       }
          $town=trim(DelWordToTown($town));

	      if ($town && CheckTown(uc $town)) {
		     $text=~ s/$town//i;
	      }else{ $town=''; }
	    } #2
	    else{ $town=''; }
    }#1
    else { $town=''; }




    $text=~ s/^[\s,.\'\-\*\\]+//;
    if($text=~ m/^\w+/){  $text=" ".$text;}

   if($text=~ m/((?<=[\s,.])(${strReVillage})[\s,.]+(\w+\'*\w*\s*-*\w*\'*\w*))/i){
      $village=$1;
	  $village=~s/(?<=[\s,.])\b(${strReStreet}$)\b//i;
	  if(CheckVillage(uc  $village)){
		  $text=~ s/$village//;
	  }elsif ($text=~ m/((?<=[\s,.])(${strReVillage})[\s,.]+(\w+\'*\w*))/i){
            $village=$1;
	        $village=~s/(?<=[\s,.])(${strReStreet}$)//i;
            if(CheckVillage(uc  $village)){
		      $text=~ s/$village//;}
			else  {$village=''; }
	  }
	  else {$village=''; }

    }
    elsif($text=~ m/((?<=[\s,.])(смт|пгт)[\s,.]+(\w+\'*\w*\s*-*\w*\'*\w*))/i){
            $village=$1;
			if(CheckVillage(uc  $village)){
               $text=~ s/$village//;
			}elsif ($text=~ m/((?<=[\s,.])(смт|пгт)[\s,.]+(\w+\'*\w*))/i){
				$village=$1;
				if(CheckVillage(uc  $village)){
                   $text=~ s/$village//;}
				else {$village=''; }
			}
			else {$village=''; }
		  }
	else {$village=''; }

    $text=~ s/^[\s,.\'\-\*\\]+//;
    if($text=~ m/^\w+/){  $text=" ".$text;}

   if($text=~ m/((?<=[\s,.])(\w*\'*\w*\s*-*\w*\'*\w+ий))/i ){   #(?<=[\s,.]) \s*(?=р)  (\w*)[\s-]*  (?<=вул[\s.,])  #(?=[вул|ул][\s.,])
	$regional=$1;
	$str=$`;
	# відкоректовано 05.10.2011
	#if ($str=~ m/(${strReStreet})[.,]$/i) {
    #  $regional='';
	#}
	 # if($town){  # если город есть то чистим район
     #    $text=~ s/$regional//;
     #    $regional='';
	 # }
	  if($regional && CheckRegional(uc $regional)){
         $text=~ s/$regional//;
	  }
	  else {$regional='';}
    }
    else { $regional=''; }





    $text=~ s/(р-н|район|р-он)//i;
    $text=~ s/(область|обл)//i;
	 $text=~ s/^\s*(украина|україна)//i;
     $text=~ s/^[\s,.\'\-\*\\]+//;
	 if($text=~ m/^\w+/){  $text=" ".$text;}

     #провіряемо чи спочатку є число
      if($text=~ m/^(\s*\d{1,3})/){
         $text=~ s/$1//;
         $text=~ s/^[\s,.\'\-\*\\]+//;
         if($text=~ m/^\w+/){  $text=" ".$text;}
	  }
     # проверяем если $town и $village нет берем слово и проверяем если есть такой населенный пункт
    if($town eq '' &&  $village eq ''){
       if($text=~ m/((\w+\'*\w*)(\s*-*)(\w*\'*\w*))/i){
	      $u_town=$1;
		  my $u_town2=$2;
		  $u_town=trim(DelWordToTown($u_town));

	      if (CheckTown(uc $u_town)) {
		      $text=~ s/$u_town//;
	      }
		  elsif(CheckTown(uc $u_town2)){
           $u_town=trim($2);
    	   $text=~ s/$u_town//;
		  }
		  else {$u_town=''};
	   }
	 }
  $text=~ s/^[\s,.\'\-\*\\]+//;
  my $street=$text;
   if($street=~ m/^\w+/){  $text=" ".$street;}
###   my @rt= FindIndex($state,$town,$regional,$village,$u_town,$index);



  $str=$array[$strFileColumn];
  $str=~s/\n//gi;

#  print fff "  $str\n";


###  if($rt[0]){

	 if ( $street && ( $town || $u_town)) {
         $street=~ s/^(${strReTown})\b//i;
	   }



     if($street && ($town || $u_town ) ){   # провіряємо чи не має два раза назви міста
	   $str=$town ? $town : $u_town ? $u_town : '';
        $str=~ s/^(${strReTown})\b//i;
	    $str=~ s/^[\s,.\'\-\*\\]+//;
        $str=trim($str);
	   	$street=~ s/\b($str)(?=[\s,])//i;
	    $street=~ s/^[\s,.\']+//;
	 }

      if( $street && $street=~ m/\b(\w+ька|\w+кая)/i) {   # провіряємо чи не має назви області
       $str=lc($rt[0]);
       $str=~ s/область//i;
       $str=trim($str);
	   $street=~ s/^\b($str)(?=[\s,])//i;
	    $street=~ s/^[\s,.\'\-\*\\]+//;
	   }

       $street=~ s/\s,\s,//;
	   $street=~s/[\s,.\'\-\*\\]+$//;
	   $street=trim($street);
       my $tmp=$street;
	   $fetch_bool=1;
        $tmp=~s/^(${strReStreet})//i;
        $tmp=~ s/^[\s,.\'\-\*\\]+//;
       if ($tmp!~m/\w{4,}.+(?=\d)(\d+)/) { # провірим на наявність номера #28.04.2010 edit m/\w{3,}.+(?=\d)(\d+)/
	        $fetch_bool=0;
       }

	   if (!$street && ($town || $u_town )  ) {
		    $fetch_bool=0;
	   }
       # проба вулиці

       # тут попробуем розібрати вулицю по Києву і найти індекс 19.04.2011р.
       #if($rt[0]=~ m/^(КИЕВ|КИЇВ)$/ && $rt[3]=~ m/^1001$/ && $fetch_street ){#1
          $tmp=$street;
          $tmp=~s/^(${strReStreet})[\s,.]//i;
          $tmp=trim($tmp);
		  $tmp=~s/^(${strReStreet})[\s,.]//i;
		  # if($tmp=~ m/^\w+/){  $tmp=" ".$tmp;}
		   if($tmp=~ m/((\d{0,2}\s*)(\w+\'*\w*)(\s*-*)(\w*\'*\w*))/i){ #~ m/((d{0,2})(\s*)(\w+\'*\w*)[\s-](\w*\'*\w*))/i)
	      	  $_street=$1;
              $_street=trim($_street);

			   @rt=CheckStreet2($state,$town,$regional,$village,$u_town,$index,$_street);
			  #my $_index=CheckStreet(uc  $_street);
			  if(!$rt[3]){ # не найшли вули, продовжимо пошук
			    if ($tmp=~ m/(\w+\'*\w*)/i) {
                   $_street=$1; $_street=trim($_street);
				  # $_index=CheckStreet(uc  $_street);
				  @rt=CheckStreet2($state,$town,$regional,$village,$u_town,$index,$_street);
                   if(!$rt[3]){ # найшли вулицю і записали індекс
                    #$rt[3].='0';
				   #}
				   #else { #якщо нічого не найшли то рахуем що ми не розібрали
                      $fetch_bool=0;
				   }
			    }
			  }
			  #else{
              #  $rt[3].='0';
			  #}
		   }

	   #}#1

#      if($street && ( $town || $u_town) && $street=~ m/^((\w*\'*\w*)(\s*-*)(\w*\'*\w+ий))/i ){
#		 $str=$1;
#		 if($2=~m/^(${strReStreet})/i) {
#		 }
#		 else{
#		   $street=~ s/$str//;
#          $street=~ s/^[\s,.\'\-\*\\]+//;
#		 }
#	  }
     if($street=~ m/\w+$/){  $street.=" ";}
	# $street=$street;
      if($street && $street!~m/\b(${strReStreet})(?=[\s\.])/i){   # добавляемо слово вул. якщо немає слів вул|ул|вулиця|пров|провулок|пр|проспект|пр-т|квартал|с|в
	  $street="вул. ".$street;}


     $str=ucwords(lc($rt[0]));
	 $str=~ s/область/обл./i;
     $str=~ s/\bКиїв\b/Київська обл./i;
	 $str=~ s/Севастополь, Мiсто/АР Крим/i;

     if(!$town && !$village &&  !$u_town && trim($regional)=~ m/\w+ий$/i && $rt[1]=~ m/^$rt[2]/i) {
       $town=ucwords(lc($rt[2]));
	 }
     if($fetch_bool){	 #28.04.2010 edit


	  #print fff $fetch_bool ? "1" : "0";
	  print fff "1;$array[0];";
      print fff (length($rt[3])==4) ? "0"."$rt[3];" : "$rt[3];";

	  print fff "$str;";
      $str=ucwords(lc($rt[1]));
	  $str=~ s/район/р-н/i;

	  print fff ($village || $rt[5] ne 'МІСТО')? "$str;" : ";";
	  print fff ($town) ? "$town" :($village)? "$village": ($u_town) ? "$u_town":"";
	  print fff ";$street \n" ;
	 }
	 else {
		  print fff "0;$string";
	 }
###  }
###  else{
###	 print fff "0;$string";
###  }
  #$t1=new Benchmark;
  #$td = timediff($t1, $t0);
  #$td_sql = timediff($t1_sql, $t0_sql);


 # print fff "\n";
  #print "$file_currentCol  ", timestr($td)," ",timestr($td_sql,'5.2f'), " \n";
  print "$file_currentCol   \n";
  $file_currentCol++;
}


print fff "$i";
close FL; # закрыти_ фаc<а
close fff;


#$strSql="select * from index1  where rayon like '%МIСТО%'  "; # where    substr(gorod,1,1)='B'
#from_to($strSql,  $my_encoding,$file_encoding);
#my $sth = $dbh->prepare($strSql) or die $dbh->errstr();



#$sth->execute() or die $sth->errstr();

#my @data;
#    while (@data = $sth->fetchrow_array())
#                { $str=$data[0].$data[1].$data[2].$data[3];
#					#from_to($str, $file_encoding, $my_encoding);

#					print test " $data[1] $data[2] $data[3] \n"; }

$dbh->disconnect();
$dbhOracle->disconnect() or warn "Disconnection with ERRORS!",  $dbh->errstr();
#close test;
   print "Press [ ENTER ] to continue\n";
   <STDIN>;
#####----------------------------------------------------------------------------------########
sub FindIndex{
my $NameTown=uc $_[1];
my $NameState=uc $_[0];
my $NameRegional=uc $_[2];
my $NameVillage=uc $_[3];
my $NameU_town=uc $_[4];
my $NameIndex=uc $_[5];

if($NameU_town && !$NameVillage && !$NameTown ) {
	$NameTown=$NameU_town;
	$NameU_town='';}

my $NameTown_R;

$NameTown=~ s/^((${strReTown})[\s,\.]+)//i;
$NameTown=trim($NameTown);
#$NameTown=~ tr/І/I/;

if($ListTown=~ m/((?<=[,\n])$NameTown(?=,))/i){
 $NameTown_R="%".$NameTown."%МIСТО%";
} else {$NameTown_R="0";}

if(!$NameIndex && $NameTown=~ m/(КИЕВ|КИЇВ)/){
 return "КИЇВ","КИЇВ","КИЇВ","1001","1001";}

$NameRegional=trim($NameRegional);

$NameVillage=~ s/^((${strReVillage})[\s,\.]+)//i;
$NameVillage=trim($NameVillage);
#якщо пусто в переміних NameVillage NameTown NameU_town а регыон закынчуэться на ий
if(!$NameVillage && !$NameTown && !$NameU_town && $NameRegional=~ m/\w+ий$/i){
 $NameTown=$NameRegional;
}
#якщо індекс не пусто а назва міста і села пусто то виходимо
if($NameIndex && !($NameTown || $NameU_town || $NameVillage)  ) {
	return 0;
}

if($NameRegional) {$NameRegional.="%";}

$NameState=trim($NameState);
# проверка на русское название
if ($NameState=~ m/(\w+кая)/i) {
  # заменяем на ua
  $NameState=ChangeStatesRUtoUA($NameState);
}

if($NameState) {$NameState.=" ОБЛАСТЬ";}

$NameU_town=trim($NameU_town);




my @data;
my @dataIndex;
my $strSql="select count(*) from index71  where 1=1  ";
my $str='@data = $dbh->selectrow_array($strSql,undef';

my $strSql_="select count(*) from index71  where ? between index5 AND index5_   ";
my $str_='@dataIndex = $dbh->selectrow_array($strSql_,undef,$NameIndex);';

#my $str='$sth->execute(';

if($NameState){$strSql.=" and ( oblast=? or  oblasr_ru=? ) ";$str.=',$NameState,$NameState';}
if($NameTown) {$strSql.=" and ( gorod=? or gorod_ru=? ) ";$str.=',$NameTown,$NameTown';}
if($NameTown_R) {$strSql.=" and ( rayon like ? or rayon_ru like ? ) ";$str.=',$NameTown_R,$NameTown_R';}
if($NameTown  &&   $NameRegional=~ m/^$NameTown/i) {$strSql.=" and ( rayon like ? or rayon_ru like ? ) ";$str.=',$NameRegional,$NameRegional';}


if(!$NameTown  && $NameRegional) {$strSql.=" and ( rayon like ? or rayon_ru like ? ) ";$str.=',$NameRegional,$NameRegional';}
if(!$NameTown  && $NameVillage) {$strSql.=" and ( gorod=? or gorod_ru=? ) ";$str.=',$NameVillage,$NameVillage';}
if($NameU_town ) {$strSql.=" and ( gorod=? or gorod_ru=? ) ";$str.=',$NameU_town,$NameU_town';}

#$str=~s/,$//;
$str.=');';
#$t0_sql=new Benchmark;
 eval($str);
#$t1_sql=new Benchmark;

if(!$data[0] && $NameIndex  && $NameTown=~ m/(КИЕВ|КИЇВ)/){ #  если не найден но это КИЕВ и есть индекс
  eval($str_);
  if($dataIndex[0]){
     return "КИЇВ","КИЇВ","КИЇВ",$NameIndex,$NameIndex;
  }
  else {return "КИЇВ","КИЇВ","КИЇВ","1001","1001";}
}


if($data[0]==1){
 $strSql=~ s/count\(\*\)/\*/;
 eval($str);
 # my $s=$data[0]." ".$data[1]." ".$data[2]." ".$data[3];
 #если есть индекс то проверка
 if(length($NameIndex)>0 && ($NameIndex<minindex($data[3]) || $NameIndex>$data[4])) # dima!!!
  { return 0;}

  if( $data[0] && $NameIndex ){
    eval($str_);
    if($dataIndex[0]) {
		$i++;
		return $data[0],$data[1],$data[2],$NameIndex,$NameIndex; }
	else {
		return  $data[0],$data[1],$data[2],$data[3],$data[3];
		}
  }
    $i++;
  return @data ;
}
elsif ($data[0]>1 && $NameIndex){
   #$str=~s/\);s*$//;
   $strSql.=" and ".$NameIndex."  between index5 AND index5_ ";
  # $str.=",$NameIndex );";

   eval($str);
   if($data[0]==1) {
     $strSql=~ s/count\(\*\)/\*/;
     eval($str);
        $i++;
        return @data ;
   } else {return 0;}
}
else {return 0;}

#my $sth = $dbh->prepare($strSql) or die $dbh->errstr();


  #@data = $dbh->selectrow_array($strSql,undef,$NameTown);

#my @data;
#    while (@data = $sth->fetchrow_array())
#    {
#      $str=$data[0].$data[1].$data[2].$data[3];
#      $str.=' ';
#	}


}

sub CheckState
{

 my $NameState= $_[0];

 foreach my $item (@states)
 {
   if ($NameState eq $item){
     return 1; }

 }
 return 0;
}

sub CmrWordByChar{
}

sub CheckState1
{

 my $NameState= $_[0];
 #$NameState=~ tr/І/I/;
 if($states_ua=~ m/((?<=[,\n])$NameState(?=,))/i || $states_ru=~ m/((?<=[,\n])$NameState(?=,))/i ){
  return 1; }
 else { return 0;}
}


sub CheckTown{
my $NameTown= $_[0];
$NameTown=~ s/^((${strReTown})[\s,\.]+)//i;
$NameTown=trim($NameTown);
#$NameTown=~ tr/І/I/;
if($NameTown=~ m/^(КИЕВ|КИЇВ)$/){
return 1;}
if(!$NameTown){ return 0;}

my $strSql="select gorod from index71  where ( gorod=? or gorod_ru=? )   "; # where    substr(gorod,1,1)='B'

my @data = $dbh->selectrow_array($strSql,undef,$NameTown,$NameTown);
if(@data){
	return 1;
}
else {  #print fff "!!! not found Town $NameTown ";
        return 0;}
}

sub CheckVillage{
my $NameVillage= $_[0];
$NameVillage=~ s/^((${strReVillage})[\s,\.]+)//i;
$NameVillage=trim($NameVillage);
#$NameVillage=~ tr/І/I/;
if(!$NameVillage){ return 0;}

my $strSql="select gorod from index71  where ( gorod=? or gorod_ru=? ) "; # where    substr(gorod,1,1)='B'

my @data = $dbh->selectrow_array($strSql,undef,$NameVillage,$NameVillage);
if(@data){
	return 1;
}
else {  #print fff "!! not found Village $NameVillage ";
         return 0;}

}

sub CheckRegional{
my $NameRegional= $_[0];
#$NameRegional=~ tr/І/I/;
$NameRegional=trim($NameRegional);


if(!$NameRegional){ return 0;}

$NameRegional.=" РАЙОН";
my $strSql="select gorod from index71  where ( rayon=? or rayon_ru=? ) "; # where    substr(gorod,1,1)='B'

my @data = $dbh->selectrow_array($strSql,undef,$NameRegional,$NameRegional);
if(@data==1){
	return 1;
}
else {  #print fff "! not found Regional $NameRegional ";
return 0;}

}
sub trim{
my $p_var1= $_[0];
if($p_var1){
 $p_var1=~ s/^\s+//;
 $p_var1=~ s/\s+$//;
}
 return $p_var1;
}

sub ActivListTown{
my $strSql="select distinct rayon  from index71  where rayon like '%МIСТО%'  "; # where    substr(gorod,1,1)='B'
my $sth = $dbh->prepare($strSql) or die $dbh->errstr();
my $str=",";
$sth->execute() or die $sth->errstr();

my $data;
    while ($data = $sth->fetchrow_array()){
		$data=~ s/МIСТО//i;
        $data=trim($data);
		$str.=$data;
	}
$ListTown=$str;
}

sub DelWordToTown
{
my $p_var1= $_[0];
if($p_var1){
 $p_var1=~s/(?<=[\s.])((${strReStreet})$)//i;
}
return $p_var1;
}

sub ChangeStatesRUtoUA{
my $p_var1= $_[0];
for (my $item=0; $item<$#a_states_ru;$item++) {
	if($a_states_ru[$item] eq $p_var1){
		return $a_states_ua[$item];}
}
 return 0;
}


sub ucwords {
my $str = shift;
$str = lc($str);
$str =~ s/\b(\w+\'*\w*)/\u$1/g;
return $str; }

sub PrepareParameters
{
	my @args = @_;
    if ($#args == -1) {
            print "Bad command syntax! Try run this command with -h option to help\n";
            exit;
    }

   while ($#args != -1) {
        $arg = shift @args;
        if (  $arg eq "-h") {
            print "Usage: perl test1.pl -f [FILE] -c [COLUMN NUMBER] \n";
            exit;
        }
        elsif ($arg eq "-f") {
            $strFileCurrent = shift @args;
        }
        elsif ($arg eq "-c") {
            $strFileColumn = shift @args;
        } else {
            print "Bad command syntax! Try run this command with -h option to help\n";
            exit;       }
    }

   if($strFileColumn=~ m/\D/)
	{
       print "Error parameter [COLUMN NUMBER]  ....\n ";
	   exit;
	}

	if(! -f $strFileCurrent ){
        print "File not found $strFileCurrent ....\n ";
		exit;
	}


}


sub minindex
{
   my $index=shift;
    if($index=~/\d{5}/ && substr($index,3)!=00)
    {

        return substr($index,0,3)."00";
    }
    else
    {
        return $index;
    }

}

sub replvt
{
   my $text=shift;
   my $tmp;

   if($text=~m/((?<=[\s,.])(\w+\'*\w*\s*-*\w*\'*\w*)[\s,.]+(${strReVillage}|${strReTown}))\.?\s*,/i)
  {
      $tmp=$&;
      if($tmp!~m/\d+/i)
      {
         $tmp=~s/(\w+\'*\w*\s*-*\w*\'*\w*)[\s,.]+(${strReVillage}|${strReTown})(\.?)(\s*,)/$2$3 $1$4/;
         $text=~s/((?<=[\s,.])(\w+\'*\w*\s*-*\w*\'*\w*)[\s,.]+(${strReVillage}|${strReTown}))\.?\s*,/$tmp/;
         #print LOG "$text - ".$&." - tmp=$tmp SELO!\n";
      }

  }

   return $text;
}

sub CheckStreet
{
  my $street=shift;
   $street=$street."%";
my $strSql="select count(*) from KyivIdx  where  town_u like  ? or  town_r like  ? "; # where    substr(gorod,1,1)='B'

my @data = $dbh->selectrow_array($strSql,undef,$street,$street);
if($data[0]==1){
	 $strSql=~ s/count\(\*\)/index/;
	 @data = $dbh->selectrow_array($strSql,undef,$street,$street);
	return $data[0];
}
else {  #print fff "!! not found Village $NameVillage ";
         return -1;}
}

sub CheckStreet2
{
my $NameTown=uc $_[1];
my $NameState=uc $_[0];
my $NameRegional=uc $_[2];
my $NameVillage=uc $_[3];
my $NameU_town=uc $_[4];
my $NameIndex=uc $_[5];
my $NameStreet=uc  $_[6];



$NameTown=~ s/^((${strReTown})[\s,\.]+)//i;
$NameTown=trim($NameTown);
$NameTown=~ tr/I/І/;


$NameRegional=~ tr/I/І/;
$NameU_town=~ tr/I/І/;

$NameState=~ tr/I/І/;

 $NameStreet=~s/(?<=[\s.])((${strReBuld})$)//i;
 $NameStreet=trim($NameStreet);
 $NameStreet=~ tr/I/І/;
  if( $NameStreet=~m/\d{1,2}[\s,.]РОКІВ/i ) {#$NameTown=~ m/(КИЕВ|КИЇВ)/
      $NameStreet=~s/[\s,.]РОКІВ/-РІЧЧЯ/i;
  }
   if( $NameStreet=~m/\d{1,2}[\s,.]РІЧЧЯ/i ) {
      $NameStreet=~s/[\s,.]РІЧЧЯ/-РІЧЧЯ/i;
  }

   $NameStreet.="%";

$NameRegional=trim($NameRegional);

$NameVillage=~ s/^((${strReVillage})[\s,\.]+)//i;
$NameVillage=trim($NameVillage);
#якщо пусто в переміних NameVillage NameTown NameU_town а регыон закынчуэться на ий
if(!$NameVillage && !$NameTown && !$NameU_town && $NameRegional=~ m/\w+ий$/i){
 $NameTown=$NameRegional;
}
#якщо індекс не пусто а назва міста і села пусто то виходимо
if($NameIndex && !($NameTown || $NameU_town || $NameVillage)  ) {
	return 0;
}

if($NameRegional) {$NameRegional.="%";}

$NameState=trim($NameState);
# проверка на русское название
if ($NameState=~ m/(\w+кая)/i) {
  # заменяем на ua
  $NameState=ChangeStatesRUtoUA($NameState);
}

if($NameState) {$NameState.=" ОБЛ.";}

$NameU_town=trim($NameU_town);




my @data;
my @dataIndex;
my $strSQLCountHead="select count(*) from ( ";
my $strSQLCountTeal="  group by city, street, region, district  )";

my $strSql="select count(*) from ext_information.aipi  where 1=1  ";
my $str='@data = $dbhOracle->selectrow_array($strSql,undef';

my $strSql_="select count(*) from ext_information.aipi  where postcode=?    ";
my $str_='@dataIndex = $dbhOracle->selectrow_array($strSql_,undef,$NameIndex);';

#my $str='$sth->execute(';

if($NameState){$strSql.=" and ( region=? or  regionru=? ) ";$str.=',$NameState,$NameState';}
if($NameTown) {$strSql.=" and ( city=? or cityru=? ) ";$str.=',$NameTown,$NameTown';}
if($NameTown_R) {$strSql.=" and ( district like ? or districtru like ? ) ";$str.=',$NameTown_R,$NameTown_R';}
if($NameTown  &&   $NameRegional=~ m/^$NameTown/i) {$strSql.=" and ( district like ? or districtru like ? ) ";$str.=',$NameRegional,$NameRegional';}
if($NameStreet) {$strSql.=" and ( street like ? or streetru like ? ) ";$str.=',$NameStreet,$NameStreet';}



if(!$NameTown  && $NameRegional) {$strSql.=" and (  district like ? or districtru like ? ) ";$str.=',$NameRegional,$NameRegional';}
if(!$NameTown  && $NameVillage) {$strSql.=" and ( city=? or cityru=? ) ";$str.=',$NameVillage,$NameVillage';}
if($NameU_town ) {$strSql.=" and ( city=? or cityru=? ) ";$str.=',$NameU_town,$NameU_town';}



#$str=~s/,$//;
$str.=');';
#$t0_sql=new Benchmark;
 my $strSqlTmp=$strSql;
 $strSql=$strSQLCountHead.$strSql.$strSQLCountTeal;
 eval($str);
#$t1_sql=new Benchmark;

### if(!$data[0] && $NameIndex  && $NameTown=~ m/(КИЕВ|КИЇВ)/){ #  если не найден но это КИЕВ и есть индекс
###  eval($str_);
###  if($dataIndex[0]){
###     return "КИЇВ","КИЇВ","КИЇВ",$NameIndex,$NameIndex;
###  }
###  else {return "КИЇВ","КИЇВ","КИЇВ","1001","1001";}
###}


if($data[0]==1){
 $strSql=$strSqlTmp;

 $strSql=~s/count\(\*\)/\*/;

#$strSql=$strSQLCountHead.$strSql.$strSQLCountTeal;
 eval($str);
 # my $s=$data[0]." ".$data[1]." ".$data[2]." ".$data[3];
 #если есть индекс то проверка
 #if(length($NameIndex)>0 && $NameIndex!=$data[21])  # && ($NameIndex<minindex($data[3]) || $NameIndex>$data[4])) # dima!!!
  #{ return 0;}

  if( $data[0] && $NameIndex ){
    eval($str_);
    if($dataIndex[0]) {
		$i++;
		return $data[1],$data[3],$data[7],$NameIndex,$NameIndex,$data[5]; }
	else {
		$i++;
		return  $data[1],$data[3],$data[7],$data[21],$data[21],$data[5];
		}
  }
    $i++;
  return  $data[1],$data[3],$data[7],$data[21],$data[21],$data[5]; #@data ;
}
elsif ($data[0]>1 && $NameIndex){
   #$str=~s/\);s*$//;
   $strSql=$strSqlTmp;
   $strSql.=" and ".$NameIndex."  = postcode ";
   $strSql=$strSQLCountHead.$strSql.$strSQLCountTeal;
  # $str.=",$NameIndex );";

   eval($str);
   if($data[0]==1) {
     $strSql=$strSqlTmp;
     $strSql.=" and ".$NameIndex."  = postcode ";
     $strSql=$strSQLCountHead.$strSql.")";
     $strSql=~ s/count\(\*\)/\*/g;

     eval($str);
        $i++;
        return  $data[1],$data[3],$data[7],$data[21],$data[21],$data[5]; #@data ;
   } else {return 0;}
}
else {return 0;}

### my $strSql="select count(*) from (select count(*) from  ext_information.aipi  where   ( region=?  or  regionru=?  ) and ( city like ? or cityru like ?) and (street like  ? or  streetru like  ?) group by city, street )"; # where    substr(gorod,1,1)='B'

### my @data = $dbhOracle->selectrow_array($strSql,undef,$NameVillage,$NameVillage,$NameTown,$NameTown,$NameStreet,$NameStreet);
### if($data[0]==1){
###	 #$strSql=~ s/count\(\*\)/postcode/;
###	 $strSql="select postcode from  ext_information.aipi  where  ( city like ? or cityru like ?) and (street like  ? or  streetru like  ?)  ";
###	 @data = $dbhOracle->selectrow_array($strSql,undef,$NameTown,$NameTown,$street,$street);
###	return $data[0];
### }
### else {  #print fff "!! not found Village $NameVillage ";
###         return -1;}





}