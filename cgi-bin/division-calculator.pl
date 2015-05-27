#!c:/Perl64/bin/perl.exe
#!/usr/bin/perl

# w = rh/d   (w must be a whole number)
#
# r = ratio (1:r, or e.g. 60 for a table that moves 6 degrees with every turn (360/6))
# h = number of holes on dividing plate
# d = divisions required

use strict;
use warnings;

use CGI qw/:standard/;

my $stylesheet = "/stylesheet.css";

my $r = 60; # Rack ratio
my @plates = (2, 3, 5, 7, 11, 13, 37);  # Available plates

my $d = 37; # divisions


# Return 1 if the passed in number is a whole number, 0 otherwise
sub IsWholeNumber
{
    my $num = shift;
    
    if (int($num) == $num) {
	return 1;
    } else {
	return 0;
    }
}


# Return 1 if the plate can be used for the number of divisions
# args: number of divisions required, ratio of table, holes in plate
# return value: 1 if the combo works, otherwise 0
sub TestPlate
{
    my $divisions = shift;
    my $ratio = shift;
    my $plate = shift;


    if (IsWholeNumber(1.0 * $ratio * $plate / ($divisions * 1.0))) {
	return 1;
    } else {
	return 0;
    }
}


# Find all plates that can be used to produce n divisions using the 
# available plates.
# return value: (list)
sub FindAllPlates
{
    my $divisions = shift;
    my $ratio = shift;
    my @available_plates = @_;

    my @rv;

    foreach my $p (@available_plates) {
	if (TestPlate($divisions, $ratio, $p)) {
	    push @rv, $p;
	}
    }
    return @rv;
}




### Main form



sub DoMainForm
{
    print "<table class=table1>\n";
    print start_form;
    print "<tr>\n";
    print "<td>Ratio of table/gear (1:ratio)</td><td>", textfield(-name=>'ratio', default => '60'), "</td>\n";
    print "<tr>\n";
    print "<td>Comma separated list of hole circles on plates</td><td>", textfield(-name=>'plates', default => '15, 16, 17'), "</td>\n";
    print "<tr>\n";
    print "<td>Divisions required</td><td>", textfield(-name=>'divisions', default => '15'), "</td>\n";

    print "<tr>\n";
    print "<td colspan=99 align=right>" . submit('calculate') . "</td>\n";

    print "</table>\n";

    print "<br>\n";
    print "<p class=info1>To see all possible divisions up to 128 divisions using your set of plates, " . 
	"click the &quot;display table&quot; button.\n";
    print "<br>\n";
    print submit('display table');
    print "</p><br>\n";

    print end_form;
}


print header;
print "<head><link rel=\"stylesheet\" type=\"text/css\" href=\"$stylesheet\"></head>";
print start_html("Index Plate Calculator");


print "<br>\n";
print "<p class=heading1>Index plate hole calculator</p>";
print "<p class=info1>This is an online calculator to calculate what indexing plate to use and number of " . 
    "holes to skip for a given number of divisions. This calculator can be used for both rotary " . 
    "tables and indexing heads.</p>";
print "<p class=info1>The ratio below describes how many turns of the handle makes the table rotate " . 
    "one full revolution. For example, if your table rotates 6 degrees for every turn on the " .
    "crank handle, the ratio is 360/6 = 60.</p>\n";
print "<p class=info1>The available number of holes on the indexing plates are given as a comma separated " .
    "list of integer values (For example, if your plates have 11, 12 and 15 holes, enter " . 
    "&quot;11, 12, 15&quot; in the textbox below.</p>\n";

DoMainForm;


if (param("display table")) {
    my $p1 = param("ratio");
    my $p2 = param("plates");
    
    # Ratio
    if ($p1 =~ m/([0-9]+)/) {
	$r = $1;
    } 
    
    # Plates
    {
	@plates = ();
	my @p = split (",", $p2);
	foreach my $e (@p) {
	    if ($e =~ m/([0-9]+)/) {
		push @plates, $1;
		##print "Pushing $1 to plates<br>\n";
	    }
	}
    }


    print "<br>\n";
    print "<table border=1>\n";
    print "<tr>\n";
    print "<td>Divisions</td><td>Plate</td><td>Full Revs</td><td>Remainder</td>\n";

    for (my $i = 1; $i <= 127; $i++) {

	# Find all plates that can divide $r racks into $d divisions
	my @combos = FindAllPlates($i, $r, @plates);
	
	print "<tr>\n";
	if (scalar(@combos)) {
	    my $c1 = $combos[0];

	    my $totalHolesToSkip = $r * $c1 / $i;
	    my $fullRevs = int($totalHolesToSkip / $c1);
	    my $remainder = $totalHolesToSkip - ($c1 * $fullRevs);

	    print "<td>$i</td><td>$c1</td><td>$fullRevs</td><td>$remainder</td>\n";
	} else {
	    print "<td>$i</td><td colspan=99>Not possible</td>\n";
	}
	
    }
}
elsif (param("calculate")) {
    my $p1 = param("ratio");
    my $p2 = param("plates");
    my $p3 = param("divisions");
    
    # Ratio
    if ($p1 =~ m/([0-9]+)/) {
	$r = $1;
    } 
    
    # Plates
    {
	@plates = ();
	my @p = split (",", $p2);
	foreach my $e (@p) {
	    if ($e =~ m/([0-9]+)/) {
		push @plates, $1;
		##print "Pushing $1 to plates<br>\n";
	    }
	}
    }

    # Divisions
    if ($p3 =~ m/([0-9]+)/) {
	$d = $1;
    } 

    # Find all plates that can divide $r racks into $d divisions
    my @combos = FindAllPlates($d, $r, @plates);
    
    print hr;
    if (scalar(@combos)) {
	print "<br>\n";
	my $angle = 360.0/$d;
	printf "To produce %d divisions (%.4g degrees between divisions) using a 1:%d ratio rack, use the following combination of plates:\n", $d, $angle, $r;

	print "<br>\n";
	print "<br>\n";
	print "<br>\n";
	print "<table border=1>\n";
	print "<tr>\n";
	print "<td>Plate</td><td>Full revolutions</td><td>Remainder holes</td>\n";
	
	foreach my $c (@combos) {
	    print "<tr>";
	    print "<td>$c hole</td>\n";

	    my $totalHolesToSkip = $r * $c / $d;
	    #print "totalholestoskip ($c):  $totalHolesToSkip\n";

	    my $fullRevs = int($totalHolesToSkip / $c);
	    my $remainder = $totalHolesToSkip - ($c * $fullRevs);
	    print "<td>$fullRevs</td><td>$remainder</td>";
	}
	print "</table>\n";
    }
    else {
	print "No plate combinations to divide a 1:$r ratio table to $d divisions\n";
    }
}
