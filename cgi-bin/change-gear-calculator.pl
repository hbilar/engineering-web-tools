#!/usr/bin/perl
#!c:/Perl64/bin/perl.exe


# w = rh/d   (w must be a whole number)
#
# r = ratio (1:r, or e.g. 60 for a table that moves 6 degrees with every turn (360/6))
# h = number of holes on dividing plate
# d = divisions required

use strict;
use warnings;

use CGI qw/:standard/;



my $inch = 25.4;

my $maxGears = 20;             # max gears in gearset (to stop someone entering loads of gears)
my $warning_gear_numbers = 0;  # Used to track if a warning has been issued already

my $progname = $0;
my $dirname = $progname;
{
    my @p = split("/", $progname);
    $progname = $p[-1];
}
$dirname =~ s/\/[^\/]*?$//;

my $title = "Change gear calculator";

my $stylesheet = "/stylesheet.css";


### Main form


sub DoMainForm
{
    print "<table class=table1>\n";
    print start_form;
    print "<tr>\n";
    print "<td>Pitch of lead screw</td><td>", textfield(-name=>'lead_tpi', default => '12'), "</td>\n";
    print "<td>metric" . checkbox(-name=>'metricLeadscrew', -checked => 0, -label => '') . 
	"</td>\n";

    print "<tr>\n";
    print "<td>Comma separated list of gears</td><td>", textfield(-name=>'gears', default => '20, 20, 24, 32, 44, 64'), "</td>\n";

    print "<tr>\n";
    print "<td>Required pitch</td><td>", textfield(-name=>'required_tpi', default => '10'), "</td>\n";
    print "<td>metric " . checkbox(-name=>'requiredMetricPitch', -checked => 0, -label => '') . 
	"</td>\n";

    print "<tr>\n";
    print "<td>Max % error</td><td>", textfield(-name=>'max_error', default => '5'), "</td>\n";

    print "<tr>\n";
    print "<td colspan=99 align=right>" . submit('calculate') . "</td>\n";

    print "</table>\n";

    print end_form;
}



sub DisplayHTMLData
{
    my $f = shift;

    if (open(FILE, "<$f")) {
	my @f = <FILE>;
	print @f;
	close FILE;
    } else {
	print "<font color=Red><b>ERROR: Cannot open file</b></font><br>\n";
    }
}


sub GetParams
{
    my $p1 = param("lead_tpi");
    my $p2 = param("gears");
    my $p3 = param("required_tpi");
    my $p4 = param("max_error");
    my $p5 = param("metricLeadscrew");
    my $p6 = param("requiredMetricPitch");

    my ($lead_tpi, $required_tpi, $max_error, $metricLead, $metricScrewPitch, @gears );

    # lead screw pitch
    if ($p1 =~ m/([0-9\.]+)/) {
	$lead_tpi = $1;
    } 
    
    # gears
    {
	@gears = ();
	my @p = split (",", $p2);
	foreach my $e (@p) {
	    if ($e =~ m/([0-9]+)/) {
		push @gears, $1;
	    }
	}

	if (scalar(@gears) > $maxGears) {
	    if (! $warning_gear_numbers) {
		print "<br><font color=red>Warning - too many gears in gearset specified. Using " . 
		    "first $maxGears only!</font><br><br>\n";
		$warning_gear_numbers = 1;
	    }
	    $#gears = ($maxGears - 1);
	}
    }

    # Divisions
    if ($p3 =~ m/([0-9\.]+)/) {
	$required_tpi = $1;
    } 

    # Max error
    if ($p4 =~ m/([0-9\.]+)/) {
	$max_error = $1;
    } 

    # Metric / imperial
    if ($p5 =~ m/^on$/) {
	$metricLead = 1;
	$lead_tpi = $inch / $lead_tpi;

#	print "Setting lead_tpi to $lead_tpi<br>\n";
    } else {
	$metricLead = 0;
    }
    
    if ($p6 =~ m/^on$/) {
	$metricScrewPitch = 1;
	$required_tpi = $inch / $required_tpi;
    } else {
	$metricScrewPitch = 0;
    }

    return ($lead_tpi, $required_tpi, $max_error, $metricLead, 
	    $metricScrewPitch, @gears );
}


sub CalculateSimpleGear
{
    my $required_ratio = shift;
    my $max_error = shift;
    my @gears = @_;

    # working gear combinations are stored in this hash
    my %exact_combination = ();
    my %gear_ratios = ();
    my %close_combination = ();

    my $i1 = 0;
    foreach my $g1 (@gears) {
	$i1++;

	my $i2 = 0;
	foreach my $g2 (@gears) {
	    $i2++;
	    
	    if ($i1 != $i2) {
		# Not the same gear (i.e. don't compare a gear with itself)
		my $r = $g2 / $g1;
#		my $r = $g1 / $g2;

#		if ($r  == $required_ratio) {
		if (abs($r - $required_ratio) < 0.00001) {
		    $exact_combination{"$g1:$g2"} = $r;
		}
		$gear_ratios{"$g1:$g2"} = $r;

		my $difference = (100 * abs( $r - $required_ratio) / 
				  $required_ratio);
#		my $difference = (100 * $required_ratio / abs( $r - $required_ratio));
#		my $difference = 100;
		if ($difference <= $max_error) {
		    $close_combination{"$g1:$g2"} = $difference;
		}
	    }
	}
    }
    return ( \%gear_ratios, \%exact_combination, \%close_combination);
}


sub SimpleTable
{
    my $gear_ratio_ref = shift;
    my $exact_combination_ref = shift;
    my $close_combination_ref = shift;
    my $lead_tpi = shift;
    my $metricScrewPitch = shift;
    my $metricLead = shift;
    my @gears = @_;

    my %gear_ratios = %$gear_ratio_ref;
    my %exact_combination = %$exact_combination_ref;
    my %close_combination = %$close_combination_ref;
    
    # Do table of gear ratios
    print br;
    print hr;
    print "<p class=heading1>Simple Gear Train</p>\n";
    print "<p>Exact matches are shown in <span class=exactmatch>Green" .
	"</span>. Matches within the tolerance limit are shown in " . 
	"<span class=closematch>Blue</span></p>\n";

    # Outside table
    print "<table class=ratiotable>\n";
    print "<tr class=tabletop>\n";
    print "<td>&nbsp;</td><th colspan=99 class=center>Headstock gear</th>\n";
    print "</tr>\n";

    print "<tr class=tabletop>\n";
    print "<th>Leadscrew</th>";

    # Inside table
    print "<td>\n";
    print "<table class=ratiotable>\n";
    print "<tr class=tabletop>\n";
    print "<td>&nbsp;</td>";
    foreach my $g (@gears) {
	print "<td>$g</td>";
    }
    print "</tr>\n";

    #### #### ########################
    #### #### #### #### #### #### ####

    my $i1 = 0;
    foreach my $g1 (@gears) {
	$i1++;
	print "<tr>\n";
	print "<td class=tabletop> $g1</td>\n";

	my $i2 = 0;
	 foreach my $g2 (@gears) {
	    $i2++;
	    
	    if ($i1 != $i2) {
		my $cellclass = "standardcell";

		if (defined($exact_combination{"$g2:$g1"})) {
		    $cellclass = "exactmatch";
		}
		elsif (defined($close_combination{"$g2:$g1"})) {
		    $cellclass = "closematch";
		}
		
		if ($metricScrewPitch) {
		    printf "<td class=$cellclass>%.3f</td>",  $inch / ($lead_tpi * $gear_ratios{"$g2:$g1"}) ;
		} else {
#		    printf "<td class=$cellclass>%.3f</td>",  $lead_tpi / $gear_ratios{"$g2:$g1"};
		    printf "<td class=$cellclass>%.3f</td>",  $lead_tpi * $gear_ratios{"$g2:$g1"};
		}
	    } else {
		print "<td class=disabledcell>&nbsp;</td>\n";
	    }
	}
	print "</tr>\n";
    }
    print "</table>\n";

    print "</td>\n";
    print "</table>\n";
    
    print "Table in " ;
    if ($metricScrewPitch) {
	print "metric (mm) ";
    }
    else {
	print "imperial (tpi) ";
    }
}


sub DoSimpleTrain
{
    my ($lead_tpi, $required_tpi, $max_error, $metricLead, 
	$metricScrewPitch, @gears ) = GetParams;
    
    my $required_ratio = $required_tpi / $lead_tpi;

    # Calculate the gear ratios etc
    my %exact_combination = ();
    my %gear_ratios = ();
    my %close_combination = ();

    my ($gear_ratio_ref, $exact_combination_ref, $close_combination_ref) = 
	CalculateSimpleGear($required_ratio, $max_error, @gears);

    SimpleTable($gear_ratio_ref, $exact_combination_ref, 
		$close_combination_ref, $lead_tpi, $metricScrewPitch, 
		$metricLead, @gears);
    print "<br>\n";
    print "<br>\n";
}


sub CalculateCompoundGearCombos
{
    my ($lead_tpi, $required_tpi, $max_error, $metricLead, 
	$metricScrewPitch, @gears ) = GetParams;

    my %all_combination = ();
    my %exact_combination = ();
    my %close_combination = ();

    my $required_ratio = $lead_tpi / $required_tpi;

    # Calculate full "sets" with one gear at the headstock, 
    # one compound gear in the middle, and one gear at the 
    # lead screw
    
    my @sets = ();

    for (my $i1 = 0; $i1 < scalar(@gears); $i1++) {
	my $g1 = $gears[$i1]; # headstock

	for (my $i2 = 0; $i2 < scalar(@gears); $i2++) {
	    my $g2 = $gears[$2]; # lead screw
	    
	    if ($i1 == $i2) { 
		# Cannot use the gear with itself
		next;
	    }
	    
	    # Generate all permutations of the remaining gears
	    for (my $i3 = 0; $i3 < scalar(@gears); $i3++) {
		if (($i3 == $i2) || ($i3 == $i1)) {
		    next;
		}

		for (my $i4 = 0; $i4 < scalar(@gears); $i4++) {
		    if (($i4 == $i2) || ($i4 == $i1) || ($i4 == $i3)) {
			next;
		    }

		    my $g1 = $gears[$i1];
		    my $g2 = $gears[$i2];
		    my $g3 = $gears[$i3];
		    my $g4 = $gears[$i4];
		    
		    my $compoundRatio = ($g1 / $g3) * ($g4 / $g2);
		    my $resultantTPI = $lead_tpi / $compoundRatio;

		    my $difference = (100 * abs( $compoundRatio - $required_ratio) / 
				      $required_ratio);
		    if ($difference == 0) {
			# Exact match
			$exact_combination{"$g1:$g3:$g4:$g2"} = 0;
		    } elsif ($difference <= $max_error) {
			# Close enough
			$close_combination{"$g1:$g3:$g4:$g2"} = $difference;
#			print "THIS IS A CLOSE COMBINATION $g1:$g3:$g4:$g2<br>\n";
		    }
		    $all_combination{"$g1:$g3:$g4:$g2"} = $resultantTPI;
#		    print "combination:  $gears[$i1], $gears[$i3], $gears[$i4], $gears[$i2], " . 
#			"ratio $compoundRatio, required_ratio = $required_ratio, resultantTPI = $resultantTPI,  difference = $difference <br>\n";
		}
	    }
	}
    }
    return (\%all_combination, \%exact_combination, \%close_combination);
}


sub DoCompoundGearTable
{
    my $allRef = shift;
    my $exactRef = shift;
    my $closeRef = shift;

    my ($lead_tpi, $required_tpi, $max_error, $metricLead, 
	$metricScrewPitch, @gears ) = GetParams;

    print "<p class=heading1>Compound Gear Train</p>\n";


    if ((scalar(keys %$closeRef) + scalar(keys %$exactRef)) == 0) {
	# No valid combinations found
	print "<p>No valid gear combinations found for this pitch.</p>\n";
    } else {

	print "<p>The headstock gear is driving gear 1, which is locked " .
	    "to gear 2, which is driving the lead screw.</p>\n";

	print "<table class=ratiotable border=1>\n";
	print "<tr class=tabletop>\n";
	print "<th>Headstock</th>";
	print "<th>Gear 1</th>";
	print "<th>Gear 2</th>";
	print "<th>Leadscrew</th>";
	if ($metricScrewPitch) {
	    print "<th>pitch (mm)</th>";
	} else {
	    print "<th>TPI</th>";
	}
	print "<th>Variance</th>";
	print "</tr>\n";

	if (scalar(keys %$exactRef)) {
	    foreach my $e (keys %$exactRef) {
		print "<tr>\n";
		my @e = split(":", $e);
		print "<td class=center>$e[0]</td>";
		print "<td class=center>$e[1]</td>";
		print "<td class=center>$e[2]</td>";
		print "<td class=center>$e[3]</td>";
		
		my $p = $$allRef{$e};
		if ($metricScrewPitch) {
		    $p = $inch / $p;
		}
		printf "<td class=center>%.3f</td>", $p;
		print "<td class=center>0%</td>";
	    }
	}

	if (scalar(keys %$closeRef)) {
#	my @closeRefKeys = keys %$closeRef;
#	@closeRefKeys = sort { 
	    my @keys = sort { $closeRef->{$a} <=> $closeRef->{$b} } keys(%$closeRef);
#	my @vals = @{$closeRef}{@keys};
	    foreach my $e (@keys) {

		print "<tr>\n";
		my @e = split(":", $e);
		print "<td class=center>$e[0]</td>";
		print "<td class=center>$e[1]</td>";
		print "<td class=center>$e[2]</td>";
		print "<td class=center>$e[3]</td>";
		
		my $p = $$allRef{$e};
		if ($metricScrewPitch) {
		    $p = $inch / $p;
		}
		printf "<td class=center>%.3f</td>", $p;
		printf "<td class=center>%.3f%%</td>", $$closeRef{$e};
	    }
	}
	print "</table>\n";
    }
}

sub DoCompoundGearTrain
{
    my ($lead_tpi, $required_tpi, $max_error, $metricLead, 
	$metricScrewPitch, @gears ) = GetParams;

    my ($allRef, $exactRef, $closeRef) = CalculateCompoundGearCombos();

    DoCompoundGearTable($allRef, $exactRef, $closeRef);
}


print header;
print "<head><link rel=\"stylesheet\" type=\"text/css\" href=\"$stylesheet\"></head>";
print start_html($title);

DisplayHTMLData("$dirname/data/$progname-top.html");



DoMainForm;


if (param("calculate")) {


    DoSimpleTrain;

    DoCompoundGearTrain;



	

}
