#!/usr/bin/perl

use GD::Simple;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

use HBCommon;

my $canvasX = 1024;           # X size of canvas
my $canvasY = 1024;           # Y size of canvas
my $centerX = $canvasX / 2;
my $centerY = $canvasY / 2;

my $holeDia = 10;             # Diameter of indexing marks
my $scaleX = 1;               # X scale factor
my $scaleY = 1;               # Y scale factor

my $circleOutline = 1;     # should we draw a circle outline
my $shortSegLength = 10;    # Length of the short segment markers
my $longSegLength = 20;    # Length of the long segment markers

my $circleRad = 80;    # Initial radius of first circle
my $major_index = 10;      # Make every n't line a bit longer
my $printNumbers = 1;   # Print numbers on the major segments

my $numberHoles = 0;          # Set to 1 / true to mark the holes with a "number" id

my $numberTextSizeX = 8;      # Font size X
my $numberTextSizeY = 16;      # Font size Y

my $drawScaleBars = 1;        # If yes, draw an X/Y bar to calculate the scale factor

my $img = GD::Simple->new($canvasX, $canvasY);

sub DrawCentreHole
{
    my $img = shift;
    $img->moveTo($centerX, $centerY);
    $img->ellipse($holeDia, $holeDia);

    # draw cross hair
    my $crossLength = 2*$holeDia;
    $img->moveTo($centerX - $crossLength/2 * $scaleX, $centerY);
    $img->line($scaleX * $crossLength, 0);

    $img->moveTo($centerX, $centerY - $crossLength/2 * $scaleX);
    $img->line(0, $scaleX * $crossLength);
}


########

my $q = CGI->new;

# Get parameters
{
    # Get number of holes for circles
    $divisions = &HBCommon::SanitizedParameterNumber($q, 'divisions', 80);

    # Should we draw outlines
    $circleOutline = &HBCommon::SanitizedParameterCheckbox($q, 'circleOutline', 1);

    # Initial rad
    $circleRad = &HBCommon::SanitizedParameterNumber($q, 'circleRad', $circleRad);

    # Major index
    $circleRadStep = &HBCommon::SanitizedParameterNumber($q, 'major_index', 10);

    # Should we draw outlines
    $printNumbers = &HBCommon::SanitizedParameterCheckbox($q, 'printNumbers', 1);

    # segment length
    $shortSegLength = &HBCommon::SanitizedParameterNumber($q, 'shortSegLength', 10);
    $longSegLength = &HBCommon::SanitizedParameterNumber($q, 'longSegLength', 30);

    # scaleX
    $scaleX = &HBCommon::SanitizedParameterNumber($q, 'scaleX', 1);
    $scaleY = &HBCommon::SanitizedParameterNumber($q, 'scaleY', 1);
}


# Draw circle outline if required
if ($circleOutline) {
    $img->moveTo($centerX, $centerY);
    $img->ellipse(2*$scaleX * $circleRad, 2*$scaleY * $circleRad);
}

# Draw the centre marker 
DrawCentreHole($img);


# Draw the actual "hole circle"
my $textcolour = $img->colorAllocate(255,0,0);
for (my $n = 0; $n < $divisions; $n++) {
    
    # Calculate the angle to point in
    my $a = 360* ($n / $divisions) * 3.14 / 180;

    my $segLength = $shortSegLength;

    # check if this is a major division
    if ((($n % $major_index) == 0)) {
	$segLength = $longSegLength;
	
	if ($printNumbers) {
	    my $marker = "$n";
	    my $markerLen = length($marker);
	    

	    $img->moveTo($centerX + $scaleX * ($circleRad - 1.5*$segLength) * cos($a) - $numberTextSizeX * $markerLen/2,
		         $centerY + $scaleY * ($circleRad - 1.5*$segLength) * sin($a) + $numberTextSizeY/2);
	    $img->string("$n");
	}
    }
    $img->moveTo($centerX + $scaleX * ($circleRad - $segLength) * cos($a), $centerY + $scaleY * ($circleRad - $segLength) * sin($a));
    
    # Draw a line of $segLength length, but pointing in $a direction
    $img->line($scaleX * $segLength * cos($a), $scaleY * $segLength * sin($a));
}


# Draw scale bars
if ($drawScaleBars) {
    # Draw two lines so that the user can calculate the print scale

    # X line
    $img->moveTo($canvasX/10, (1-1/10) * $canvasY);
    $img->line(3*$canvasX/10, 0);

    # Y line
    $img->moveTo($canvasX/10, (1-1/10) * $canvasY);
    $img->line(0, -3*$canvasX/10);
}

print $q->header('image/png');
print $img->png;

