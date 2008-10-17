#! /usr/bin/env perl
#
# cff-to-opencog.pl
#
# Read in files in the "compact file format", as generated by the
# src/java/relex/output/CompactView.java class, and convert them into 
# opencog format, as generated by src/java/relex/output/OpenCogScheme.java
#
# Copyright (c) 2008 Linas Vepstas <linasvepstas@gmail.com>
#

#--------------------------------------------------------------------
# Need to specify the binmodes, in order for \w to match utf8 chars
use utf8;
binmode STDIN, ':encoding(UTF-8)'; 
binmode STDOUT, ':encoding(UTF-8)';

use UUID;

print "scm\n";

$raw_sentence = 0;
$in_parse = 0;
$in_features = 0;

$parse_inst = "";
@word_list = ();

$sent_inst = "";

while (<>)
{
	if (/<sentence /) { $raw_sentence = 1;  next; }
	if ($raw_sentence)
	{
		$raw_sentence = 0;
		chop;
		print "; SENTENCE: [$_]\n";

		UUID::generate($uuid);
		UUID::unparse($uuid, $uuidstr);
		$sent_inst = "sentence@" . $uuidstr;
	}
	if (/<parse id="(\d)"/)
	{
		$in_parse = 1;
		$parse_id = $1;  # matches the \d
		$parse_id -= 1;  # start counting at zero, not 1.

		UUID::generate($uuid);
		UUID::unparse($uuid, $uuidstr);
		$parse_inst = "sentence@" . $uuidstr . "_parse_" . $parse_id;

# XXXXXXXXX Need to have stv for parse ranking
		print "(ParseLink\n";
		print "\t(ParseNode \"$parse_inst\")\n";
		print "\t(SentenceNode \"$sent_inst\")\n";
		print ")\n";

		# zero out the word list
		@word_list = ();
	}
	if (/<\/parse>/)
	{
		$in_parse = 0;
	}
	if (/<\/features>/)
	{
		$in_features = 0;
		# Spew out the sentence
		print "(ReferenceLink\n";
		print "\t(ParseNode \"$parse_inst\")\n";
		print "\t(ListLink\n";
		foreach $word_inst (@word_list)
		{
			print "\t\t(ConceptNode \"$word_inst\")\n";
		}
		print "\t)\n";
		print ")\n";
	}
	if ($in_features)
	{
		($n, $word, $lemma, $pos, $feat) = split;
		UUID::generate($uuid);
		UUID::unparse($uuid, $uuidstr);
		$word_inst = $word . "@" . $uuidstr;

		push (@word_list, $word_inst);

		print "(ReferenceLink\n";
		print "\t(ConceptNode \"$word_inst\")\n";
		print "\t(WordNode \"$word\")\n";
		print ")\n";

		print "(LemmaLink\n";
		print "\t(ConceptNode \"$word_inst\")\n";
		print "\t(WordNode \"$lemma\")\n";
		print ")\n";

		print "(PartOfSpeechLink\n";
		print "\t(ConceptNode \"$word_inst\")\n";
		print "\t(DefinedLinguisticConceptNode \"$pos\")\n";
		print ")\n";

		@feats = split (/\|/, $feat);
		foreach $f (@feats)
		{
			print "(InheritanceLink\n";
			print "\t(ConceptNode \"$word_inst\")\n";
			print "\t(DefinedLinguisticConceptNode \"$f\")\n";
			print ")\n";
		}
	}

	if (/<features>/)
	{
		$in_features = 1;
	}
}