=head1 NAME

Lingua::FR::Fathom - Measure readability of French text

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

			use Lingua::FR::Fathom;

			my $text = new Lingua::FR::Fathom;

			$text->readability("path of source folder");

=head1 README

This script indicates French texts readability. It proposes the Flesch-Kincaid test and multiple indicators like total number of words, total number of sentences, average syllabes per word, total number of numbers, total number of words over 3 syllables... and finally number of times a word is found in a text.


=head1 FUNCTIONS

=head2 readability($path_folder)

The C<readability> function generates 2 csv files  (Score.csv and Occurrency.csv in same folder) those containing readability test results. Only text files in specified folder are analysed.


=head1 AUTHOR

Jean-Francois Leforestier - URC HEGP Paris XV, C<< <jean-francois.leforestier at egp.aphp.fr> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-lingua-fr-fathom at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Lingua-FR-Fathom>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 COPYRIGHT & LICENSE

Copyright 2009 Jean-Francois Leforestier - URC HEGP Paris XV.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

#------------------------------------------------------------------------------

package Lingua::FR::Fathom;

use strict;
use warnings;

our $VERSION = '0.01';

sub new
{
   my $class = shift;

   my $text = {};
   bless($text,$class);
   return($text);
}

sub readability {

  my $text = shift;

	my @arg = @_;
	
	#document entree au format txt
	my $folder = $arg[0];
	
	open(STDOUT, ">> $folder\\readability_log.log" ) or die "$!";
	print "*************\n\n".localtime()."\n*************\n";


	open(STDERR, ">> $folder\\readability_err.log" ) or die "$!";
	print STDERR "*************\n\n".localtime()."\n*************\n";

	my %occ_mot; #hachage du nombre d'occurrence de mot rencontre dans le texte

	my @sortie;

	#liste les fichiers txt du dossier
	#ouverture du dossier
	opendir (DIR,$folder) or die ("error: $folder $!");
	
	#cree la liste
	my @fic=readdir (DIR);
	
	#ATTENTION : les deux premiers elements de la liste ne correspondent pas a des dossiers ou fichier
	#elimine les deux premiers elements de @fic
	shift @fic;
	shift @fic;
	
	#parcourt les fichiers txt
	foreach my $nom_fichier (@fic) {

		if ($nom_fichier =~ /.*txt$/)	{
						
			my $ligne ="";
			my $compteur_phrases =0;
			my $compteur_mots =0;
			my $compteur_syllabes =0;#compte le nb de syllabes par mots	
			my $compteur_combiLettre =0;#compte syllabes pour les combinaisons de voyelles dans un mot
			my $compteur_num = 0;#compte les numeriques dans le texte
			my $compteur_mot_3syll = 0;#compte les mots de plus de 3 syll.
					
			my %syll; #table de hachage comptant le nb de syll par combinaison de voyelles
						
			#table de hachage des combinaisons de voyelles
				$syll{"aa"}  = 1;
				$syll{"ae"}  = 0;
				$syll{"aé"}  = 1;
				$syll{"aë"}  = 1;
				$syll{"aee"}  = 0;
				$syll{"aen"}  = 0;
				$syll{"ai"}  = 0;
				$syll{"aî"}  = 0;
				$syll{"aï"}  = 1;
				$syll{"aie"}  = 0;
				$syll{"aim"}  = 0;
				$syll{"ain"}  = 0;
				$syll{"am"}  = 0;
				$syll{"an"}  = 0;
				$syll{"ao"}  = 1;
				$syll{"aon"}  = 0;
				$syll{"aou"}  = 0;
				$syll{"aoû"}  = 0;
				$syll{"au"}  = 0;
				$syll{"ay"}  = 0;
				$syll{"aya"}  = 1;
				$syll{"aye"}  = 1;
				$syll{"ayé"}  = 1;
				$syll{"ayée"}  = 1;
				$syll{"ayo"}  = 1;
				$syll{"ea"}  = 0;
				$syll{"éa"}  = 1;
				$syll{"eai"}  = 0;
				$syll{"éai"}  = 1;
				$syll{"eaie"}  = 0;
				$syll{"eau"}  = 0;
				$syll{"ed"}  = 0;
				$syll{"ee"}  = 0;
				$syll{"ée"}  = 0;
				$syll{"éé"}  = 1;
				$syll{"éée"}  = 1;
				$syll{"ei"}  = 0;
				$syll{"éi"}  = 1;
				$syll{"eï"}  = 1;
				$syll{"éï"}  = 1;
				$syll{"ein"}  = 0;
				$syll{"em"}  = 0;
				$syll{"en"}  = 0;
				$syll{"eo"}  = 0;
				$syll{"éo"}  = 1;
				$syll{"éoa"}  = 2;
				$syll{"eoi"}  = 0;
				$syll{"er"}  = 0;
				$syll{"ers"}  = 0;
				$syll{"et"}  = 0;
				$syll{"eu"}  = 0;
				$syll{"éu"}  = 1;
				$syll{"eû"}  = 0;
				$syll{"eue"}  = 0;
				$syll{"eui"}  = 1;
				$syll{"ey"}  = 0;
				$syll{"eye"}  = 1;
				$syll{"ez"}  = 0;
				$syll{"ia"}  = 1;
				$syll{"iai"}  = 1;
				$syll{"iau"}  = 1;
				$syll{"ie"}  = 0;
				$syll{"ié"}  = 1;
				$syll{"iè"}  = 1;
				$syll{"iee"}  = 0;
				$syll{"iée"}  = 1;
				$syll{"iei"}  = 1;
				$syll{"ieu"}  = 1;
				$syll{"il"}  = 0;
				$syll{"ill"}  = 0;
				$syll{"im"}  = 0;
				$syll{"in"}  = 0;
				$syll{"io"}  = 1;
				$syll{"ioa"}  = 2;
				$syll{"ioé"}  = 2;
				$syll{"iou"}  = 1;
				$syll{"iu"}  = 1;
				$syll{"oa"}  = 1;
				$syll{"oe"}  = 0;
				$syll{"oê"}  = 0;
				$syll{"oeu"}  = 0;
				$syll{"oi"}  = 0;
				$syll{"oî"}  = 0;
				$syll{"oï"}  = 1;
				$syll{"oie"}  = 1;
				$syll{"oïé"}  = 2;
				$syll{"oin"}  = 0;
				$syll{"om"}  = 0;
				$syll{"on"}  = 0;
				$syll{"oo"}  = 0;
				$syll{"ou"}  = 0;
				$syll{"où"}  = 0;
				$syll{"oû"}  = 0;
				$syll{"oua"}  = 0;
				$syll{"oue"}  = 0;
				$syll{"oué"}  = 1;
				$syll{"ouée"}  = 1;
				$syll{"oueu"}  = 1;
				$syll{"oui"}  = 1;
				$syll{"oy"}  = 1;
				$syll{"oya"}  = 1;
				$syll{"oyai"}  = 1;
				$syll{"oye"}  = 1;
				$syll{"oyé"}  = 1;
				$syll{"oyée"}  = 1;
				$syll{"oyeu"}  = 1;
				$syll{"oyo"}  = 1;
				$syll{"ua"}  = 0;
				$syll{"uai"}  = 1;
				$syll{"uaie"}  = 1;
				$syll{"ue"}  = 0;
				$syll{"ué"}  = 1;
				$syll{"uê"}  = 1;
				$syll{"uë"}  = 1;
				$syll{"uée"}  = 1;
				$syll{"uei"}  = 1;
				$syll{"ueu"}  = 1;
				$syll{"ui"}  = 0;
				$syll{"uï"}  = 1;
				$syll{"uie"}  = 1;
				$syll{"uié"}  = 1;
				$syll{"uiè"}  = 1;
				$syll{"um"}  = 0;
				$syll{"un"}  = 0;
				$syll{"uo"}  = 1;
				$syll{"uoi"}  = 2;
				$syll{"uy"}  = 0;
				$syll{"uya"}  = 1;
				$syll{"uyau"}  = 1;
				$syll{"uye"}  = 1;
				$syll{"ya"}  = 0;
				$syll{"ye"}  = 0;
				$syll{"yé"}  = 0;
				$syll{"yè"}  = 0;
				$syll{"yeu"}  = 0;
				$syll{"ym"}  = 0;
				$syll{"yn"}  = 0;
				$syll{"yo"}  = 0;
				$syll{"you"}  = 0;
				$syll{"yu"}  = 0;
				$syll{"éeu"}  = 1;
				$syll{"uau"}  = 1;
				$syll{"uà"}  = 0;
				$syll{"oé"}  = 0;
				$syll{"iâ"}  = 1;
			
			open (E,"$folder\\$nom_fichier") or die "error: $nom_fichier $!";
			
			#pour chaque ligne du texte non vide
			
			while ($ligne=<E>) {
				
			#le retour ligne indique aussi une fin de phrase : a laisser en commentaire
			#		chomp $ligne;
				
				#si la ligne contient des mots on traite
				if ($ligne ne "\n") {
		
					#compte les numeriques dans un texte
					#espace + chiffre
					
					
					while ($ligne =~ /\s+ [0-9]+/xg) {
						$compteur_num++;
			
					}
					
					#elimine les numeriques
					$ligne =~ s/0/ /g;
					$ligne =~ s/1/ /g;
					$ligne =~ s/2/ /g;
					$ligne =~ s/3/ /g;
					$ligne =~ s/4/ /g;
					$ligne =~ s/5/ /g;
					$ligne =~ s/6/ /g;
					$ligne =~ s/7/ /g;
					$ligne =~ s/8/ /g;
					$ligne =~ s/9/ /g;
					
					#remplacer les caracteres speciaux et signes de ponctuation 
					#(sauf le . pour separer les phrases)	
					
					$ligne =~ s/\// /g;
					$ligne =~ s/\\/ /g;
					$ligne =~ s/\_/ /g;
					$ligne =~ s/\+/ /g; 		
		#			$ligne =~ s/\!/ /g;
		#			$ligne =~ s/\?/ /g;
					$ligne =~ s/\(/ /g;
					$ligne =~ s/\)/ /g;
					$ligne =~ s/\[/ /g;
					$ligne =~ s/\]/ /g;
					$ligne =~ s/\%/ /g;
					$ligne =~ s/\&/ /g;
					$ligne =~ s/\'/ /g;
					$ligne =~ s/\"/ /g;
					$ligne =~ s/\;/ /g;
					$ligne =~ s/\:/ /g;
					$ligne =~ s/\@/ /g;
					$ligne =~ s/\#/ /g;
					$ligne =~ s/\~/ /g;
					$ligne =~ s/\$/ /g;
					$ligne =~ s/\{/ /g;
					$ligne =~ s/\}/ /g;
					$ligne =~ s/\=/ /g;
					$ligne =~ s/\*/ /g;
					$ligne =~ s/\%/ /g;
					$ligne =~ s/\§/ /g;
					$ligne =~ s/\µ/ /g;
					$ligne =~ s/\¤/ /g;
					$ligne =~ s/\£/ /g;
					$ligne =~ s/\&/ /g;
					$ligne =~ s/\²/ /g;
					$ligne =~ s/\^/ /g;
					$ligne =~ s/\{/ /g;
					$ligne =~ s/\}/ /g;
					$ligne =~ s/\`/ /g;
					$ligne =~ s/\°/ /g;
					$ligne =~ s/\€/ /g;	
					$ligne =~ s/\,/ /g;
					$ligne =~ s/\®/ /g;
					$ligne =~ s/\’//g; #pas d'espace pour l'apostrophe
					$ligne =~ s/\-//g;#pas d'espace pour le tiret (mots composé correspondent à 1 seul mot)
					
					##CALCUL DU NOMBRE DE PHRASES
					
					#delimiteur de phrases : fin de ligne, point final, ?, ! ou ...
					#contient deux mots minimum séparés par un ou des espaces
					#debut de ligne ou tout caractere non-mot (ex: «) devant 1er mot possible
					#1er mot composé d'une majuscule suivi d'une ou plusieurs lettres ou A ou Y seuls
					#AU MOINS UN espace
					#2e mot composé d'au moins deux lettres ou a ou à ou y
					#espace
					#terminateur . ou .. ou ... ou ? ou !
					
					
					while ($ligne =~ /(^|\W+)(([A-Z][a-zàäâéèëêïîöôùüû]{1,} | [AYÀ]{1}) \s+ ([a-zàäâéèëêïîöôùüû]{2,}\s* | [aày]{1}\s*)+ .*? (\.{1,3} | \n | \! | \?)) /xg) {
						
		#				print "$2\n";
						
						my $phrase = $2;
						
						$compteur_phrases++;
					
		
						##CALCUL DU NOMBRE DE MOTS
									
						#calcul du nombre de mots (2 lettres minimum ou (à, a ou y) seulement)
						#insensible a la casse
						#les parentheses sont a garder car on recupere le mot
						while ($phrase =~ /([a-zàäâéèëêïîöôùüû]{2,} | [aày]{1}) /xig) {
							
							my $mot = "";
							$mot=$1;
			
							my $mot_origine = $1;#mot d'origine pour l'affichage 
							
		#					print "m=$mot\n";
		
							#on passe en minuscule
							$mot = lc ($mot);
							
							#Nombre occurrences de mot
							
							#remplacer les accents
							$mot =~ s/é/e/g;
							$mot =~ s/è/e/g;
							$mot =~ s/ê/e/g;
							$mot =~ s/ë/e/g;
							$mot =~ s/à/a/g;
							$mot =~ s/â/a/g;
							$mot =~ s/ä/a/g;
							$mot =~ s/ï/i/g;
							$mot =~ s/î/i/g;
							$mot =~ s/ö/o/g;
							$mot =~ s/ô/o/g;
							$mot =~ s/ü/u/g;
							$mot =~ s/ù/u/g;
							$mot =~ s/û/u/g;
							
							$mot =~ s/ç/c/g;
							
							if ($occ_mot{"$nom_fichier¤$mot"}) {$occ_mot{"$nom_fichier¤$mot"} = $occ_mot{"$nom_fichier¤$mot"}+1;}
							
							else {$occ_mot{"$nom_fichier¤$mot"} = 1;}
							
												
							##CALCUL DU NOMBRE DE SYLLABES
							
							#supprime les s du pluriel puis e muets à la fin du mot
							if ($mot =~ /[a-z]{2,}[s]$/) {
								chop $mot;
							}
							
							if ($mot =~ /[a-z]{2,}[e]$/) {
								chop $mot;
							}
		
							
							#on "rogne" le mot de droite a gauche jusqu'a la prochaine voylle
							while ($mot =~ /[^aàäâeéèëêiïîoöôuùûüy]$/) {
								chop $mot;
							}	
		
							#recherche des combinaisons de voyelles
							while ($mot =~ /([aàäâeéèëêiïîoöôuùûüy]{2,})/g) {
								
								my $combiLettre = "";
								$combiLettre=$1;
								
								if (exists $syll{"$combiLettre"}) {
									$compteur_combiLettre = $compteur_combiLettre + $syll{"$combiLettre"};
								}
								
								else {
									
									if (($combiLettre ne "ii") and ($combiLettre ne "iii") and ($combiLettre ne "uu")) {
										print "$nom_fichier: combination $combiLettre unrecognized\n";
									}
									
								}	
								
				
								#on remplace la combinaison de voy. par ¤
								$mot =~ s/$combiLettre/¤/;
							}
						
							
							
							#on incremente le nb de syllabes par le score de toutes les combinaisons
							if ($compteur_syllabes != 0) {
								
								$compteur_syllabes = $compteur_syllabes + $compteur_combiLettre;
							}
							else{
								
								$compteur_syllabes = $compteur_combiLettre;				
							}
								
							my $compteur_syllabes_mot = 0;# compte les syllabes d'un mot 
							
							#on compte une syll des qu'une voyelle ou ¤ est dans le mot
							while ($mot =~ /[aàäâeéèëêiïîoöôuùûüy¤]/g) {
								
								$compteur_syllabes_mot++;
								$compteur_syllabes++;
								
							}
							
							#si le mot contient 3 syll ou plusieurs
							if ($compteur_syllabes_mot >= 3) {
								
								$compteur_mot_3syll++;
							
							}
														
		#					print "$mot:";
		#					print "$compteur_mot_3syll\n";
		#					print "cpt combiLettre = $compteur_combiLettre\n";
		#					print "nb syll. total dans le mot $total\n";
		
							
		
							
		
		
							
							#pour chaque nouveau mot on reinitialise le compteur
							$compteur_combiLettre = 0;
				#			$compteur_syllabes = 0;
							
							$compteur_mots++;
							
							
						}#fin de pour chaque mot
				
					
						
					}#fin de pour chaque phrase	
				
				}#fin de si ligne non nulle
		
			}#fin de pour chaque ligne du texte		
			
			
			close E;
				
		
			
#			print "nb syll. $compteur_syllabes\n";
			
			#calcul du Flesch
			my $Flesch = "0";
			my $scoreFlesch = "0";
			
			if (($compteur_mots !=0) and ($compteur_phrases !=0))	{	
				$Flesch = 206.835-1.015*($compteur_mots/$compteur_phrases)-84.6*($compteur_syllabes/$compteur_mots);
				$scoreFlesch = sprintf ("%.2f",$Flesch); #format a 2 chiffres apres virgule
			}
			
			else {
				$Flesch = "NA";
				$scoreFlesch = "NA";
			}
			
			
		#	print "$Cst_a_traiter:\n";
		#	print "nb mots = $compteur_mots\n";
		#	print "nb phr. = $compteur_phrases\n";
#			print "nb syllab. par mots = $nbSyllMot\n";
		#	
		#	print "score F = $scoreFlesch\n";		
			
			#calcul du Flesch-Kincaid 
			my $FleschK = "0";
			my $scoreFleschK = "0";
			
			if (($compteur_mots !=0) and ($compteur_phrases !=0))	{
				$FleschK = 0.39*($compteur_mots/$compteur_phrases)+11.8*($compteur_syllabes/$compteur_mots)-15.59;
				$scoreFleschK = sprintf ("%.2f",$FleschK); #format a 2 chiffres apres virgule
			}
			
			else {
				$FleschK = "NA";
			}
			
		
			#calcul du nb de syllabes par mot
			my $nbSyllMot = "0";
			
			if (($compteur_mots !=0) and ($compteur_phrases !=0))	{
				$nbSyllMot = $compteur_syllabes/$compteur_mots;
				$nbSyllMot = sprintf ("%.2f",$nbSyllMot); #format a 2 chiffres apres virgule
			}
			
			else {
				$nbSyllMot = "NA";
			}
			
#			foreach my $key (sort keys %occ_mot) {
#				print "$key : $occ_mot{$key} fois\n";
#			}
			
			push(@sortie,"$nom_fichier;$compteur_mots;$compteur_phrases;$nbSyllMot;$compteur_num;$compteur_mot_3syll;$scoreFlesch;$scoreFleschK\n");	
			print "$nom_fichier	... OK\n";

		}
		
		else {
			print "$nom_fichier	not analyzed\n";
		}
	
	}#fin de pour chaque fichier txt

	open (F,">$folder\\Score.csv") or die "error: $folder\\Score.csv $!";
	
	print F "Filename;Total number of words;Total number of sentences;Average syllabes per word;Total number of numbers;Total number of words over 3 syllables;Flesch;Flesch Kincaid\n";
	
	print F @sortie;
	
	close F;
	
	open (F,">$folder\\Occurrency.csv") or die "error: $folder\\Occurrency.csv $!";

	print F "Filename;Word;Number of times found in the text\n";
	
	foreach my $key (sort keys %occ_mot) {
		
		my @split_key = split (/¤/,$key);
		
		my $nom_fichier = $split_key[0];
		my $mot = $split_key[1];
		
		print F "$nom_fichier;$mot;$occ_mot{$key}\n";
	}
	
	close F;
	
}

1; # End of Lingua::FR::Fathom
