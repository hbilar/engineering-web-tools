#!/usr/bin/perl

#
# Generate the html page that will be used to drive the 
# image generation program
#

use CGI;

use HBCommon;

my $stylesheet = "/stylesheet.css";

my $divisions = 100;    # Number of dots on circles

my $shortSegLength = 5;    # Length of the short segment markers
my $longSegLength = 20;    # Length of the long segment markers
my $initialCircleRad = 80;    # Initial radius of first circle
my $circleOutline = 1;        # Set to 1 to generate a circle connecting the "dots">
my $majorIndex = 10;          # Mark each 10th index with a longer line
my $printNumbers = 1;         # Print numbers on majors


sub MainForm
{
    my $q = shift;
    print $q->start_form(-action=>"dial-image-gen.pl", -method=>"get");
    

    # Top html bit
    &HBCommon::DisplayHTMLData("$HBCommon::dirname/data/$HBCommon::progname-top.html");

    # Table to get parameters
    print "<br>\n";
    print "<table class=table1>\n";
    print "<tr>\n";
    print "<td></td><td><td>\n";

    # Number of marks on circle
    print "<tr>\n";
    print "<td>Number of divisions</td><td>" . 
	$q->textfield(-name=>'divisions', -value => $divisions) .
	"</td>\n";

    # Draw circle outlines
    print "<tr>\n";
    print "<td>Draw circle outline</td><td>" . 
	$q->checkbox(-name=>'circleOutline', -checked => $circleOutline, -label => '') .
	"</td>\n";

   # Mark each n'th division with a longer line
    print "<tr>\n";
    print "<td>Mark n'th div</td><td>" . 
	$q->textfield(-name=>'major_index', -value => $majorIndex) .
	"</td>\n";

    # Print numbers
    print "<tr>\n";
    print "<td>Print numbers</td><td>" . 
	$q->checkbox(-name=>'printNumbers', -checked => $printNumbers, -label => '') .
	"</td>\n";

    # Initial radius
    print "<tr>\n";
    print "<td>Circle radius</td><td>" . 
	$q->textfield(-name=>'circleRad', -value => $initialCircleRad) .
	"</td>\n";


    # Short segment length
    print "<tr>\n";
    print "<td>Short Segment Length</td><td>" . 
	$q->textfield(-name=>'shortSegLength', -value => $shortSegLength) .
	"</td>\n";

    # Long segment length
    print "<tr>\n";
    print "<td>Long Segment Length</td><td>" . 
	$q->textfield(-name=>'longSegLength', -value => $longSegLength) .
	"</td>\n";

    # Image scale 
    print "<tr>\n";
    print "<td>Image scale (X, Y)</td><td>" . 
	$q->textfield(-name=>'scaleX', -value => "1", -size=>'4') . 
	" * " .
	$q->textfield(-name=>'scaleY', -value => "1", -size=>'4') . 
	"</td>\n";


    # Submit button
    print "<tr>\n";
    print "<td colspan=99>" . $q->submit() . "</td>";

    print "</table>\n";
										
    print $q->end_form();

    # Bottom html bit
    &HBCommon::DisplayHTMLData("$HBCommon::dirname/data/$HBCommon::progname-bottom.html");
}


my $q = CGI->new;

print $q->header();
print "<head><link rel=\"stylesheet\" type=\"text/css\" href=\"$stylesheet\"></head>";

print $q->start_html(-title=>"The amazing circle generator");


MainForm($q);
