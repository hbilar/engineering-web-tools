#!/usr/bin/perl

#
# Generate the html page that will be used to drive the 
# image generation program
#

use CGI;

my $stylesheet = "/stylesheet.css";


my @circles = (9, 10, 11, 13, 15, 19);    # Number of dots on circles

my $initialCircleRad = 80;    # Initial radius of first circle
my $circleRadStep = 40;       # How much further out the next circle will be drawn
my $circleOutline = 1;        # Set to 1 to generate a circle connecting the "dots">

my $numberHoles = 1;          # Set to 1 / true to mark the holes with a "number" id


sub MainForm
{
    my $q = shift;
    print $q->start_form(-action=>"index-plate-image-gen.pl", -method=>"get");
    
    print "<br>\n";
    print "<p class=heading1>Indexing plate hole generator</p>\n";
    print "<p>This web page lets you generate simple patterns that can be used with a " . 
	"rotary table, or an indexing head to generate a number of divisions, semi-accurately. ";
    print "The idea is that you set the parameters below, generate an image, print the image and " . 
	"use it in lieu of a real metal indexing plate (useful if you lack the actual indexing ".
	"plate required etc).</p>\n";

    # Table to get parameters
    print "<br>\n";
    print "<table class=table1>\n";
    print "<tr>\n";
    print "<td>Parameters</td><td>Value<td>\n";

    # Number of holes / circles
    print "<tr>\n";
    print "<td>Number of holes (comma separated list)</td><td>" . 
	$q->textfield(-name=>'numholes', -value => join(", ", @circles)) .
	"</td>\n";

    # Draw circle outlines
    print "<tr>\n";
    print "<td>Draw circle outlines</td><td>" . 
	$q->checkbox(-name=>'circleOutline', -checked => $circleOutline, -label => '') .
	"</td>\n";

    # Print number next to holes
    print "<tr>\n";
    print "<td>Mark holes with number</td><td>" . 
	$q->checkbox(-name=>'numberHoles', -checked => $numberHoles, -label => '') .
	"</td>\n";

    # Initial radius
    print "<tr>\n";
    print "<td>Initial circle radius</td><td>" . 
	$q->textfield(-name=>'initialCircleRad', -value => $initialCircleRad) .
	"</td>\n";

    # Circle radius step radius
    print "<tr>\n";
    print "<td>Circle radius step</td><td>" . 
	$q->textfield(-name=>'circleRadStep', -value => $circleRadStep) .
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

    print "<br>\n";
    print "<p>I wrote this page/program to help me generate indexing plates for my " .
	"little rotary table. <br>" . 
	"The idea is very simple, in that you print " .
	"off these images, mount them on a piece of mdf (or similar) and " .
	"drill through the hole markers. You then mount them on your rotary " .
	"table crank and use them as an indexing plate. I am under no " .
	"illusion that the printed plates are perfect, but given that the " .
	"angle error diminishes by the ratio of the table, the angles will " .
	"still be fairly accurate even if the marks / holes are say 1 degree " .
	"out. <br>" . 
	"I wouldn't recommend using these for anything critical, but " .
	"for simple hobby purposes they should work reasonably well.</p>\n";
    print "<p><b>Please make sure you measure the scale lines at the bottom left " . 
	"corner of the page</b>. They should be equally long - if not, modify the " . 
	"Image Scale parameters above</p>\n";
    
    print "<p>\n";
    print "For comments and suggestions, please email me at henrik(a)bilar.co.uk<br>\n";
}


my $q = CGI->new;

print $q->header();
print "<head><link rel=\"stylesheet\" type=\"text/css\" href=\"$stylesheet\"></head>";

print $q->start_html(-title=>"The amazing circle generator");


MainForm($q);
