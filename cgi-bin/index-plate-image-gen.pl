#!/usr/bin/perl

use GD::Simple;
use CGI;
use CGI::Carp qw(fatalsToBrowser);




my @circles = (9, 10, 11);    # Number of dots on circles

my $canvasX = 1024;           # X size of canvas
my $canvasY = 1024;           # Y size of canvas
my $centerX = $canvasX / 2;
my $centerY = $canvasY / 2;

my $holeDia = 10;             # Diameter of indexing marks

my $scaleX = 1;               # X scale factor
my $scaleY = 1;               # Y scale factor


my $initialCircleRad = 80;    # Initial radius of first circle
my $circleRadStep = 40;       # How much further out the next circle will be drawn
my $circleOutline = 1;        # Set to 1 to generate a circle connecting the "dots">


my $numberHoles = 0;          # Set to 1 / true to mark the holes with a "number" id
my $numberTextSize = 12;      # Size of font for hole numbers
my $numberTextOffsetX = 10;   # How far away the text should end up
my $numberTextOffsetY = $numberTextSize / 2;  

my $drawScaleBars = 1;        # If yes, draw an X/Y bar to calculate the scale factor


my $img = GD::Simple->new($canvasX, $canvasY);

$img->font('Times:italic');
$img->fontsize($numberTextSize);



sub DrawCentreHole
{
    my $img = shift;
    $img->moveTo($centerX, $centerY);
    $img->ellipse($holeDia, $holeDia);
}


sub DrawCircleOutlines
{
    my $img = shift;
    my $circleRad = shift;

    $img->moveTo($centerX, $centerY);
    $img->ellipse(2 * $scaleX * $circleRad, 2 * $scaleY * $circleRad);
}


sub DrawHoleCircle
{
    my $img = shift;
    my $holes = shift;
    my $circleRad = shift;
    my $numberHoles = shift;


    # Draw cirle of holes
    my $arcStep = 360.0 / $holes;
    for (my $i = 1; $i <= $holes; $i++) {
    
	# Move pointer to new location

	my $curX = $centerX + $scaleX * $circleRad * cos((-90 + ($i - 1) * $arcStep) * 3.14 / 180);
	my $curY = $centerY + $scaleY * $circleRad * sin((-90 + ($i - 1) * $arcStep) * 3.14 / 180);
	$img->moveTo($curX, $curY);

	$img->fgcolor('black');
	$img->bgcolor('yellow'); 
	$img->ellipse($holeDia, $holeDia);

	if ($numberHoles == 1) {
	    $img->moveTo($curX + $numberTextOffsetX, $curY + $numberTextOffsetY);
	    $img->string($i);
	}

    }
}


########

my $q = CGI->new;

# Get parameters
{
#    open (FILE, ">/tmp/f") or die "blah";

    # Get number of holes for circles
    if ($q->param('numholes')) {
	my $v = $q->param('numholes');
	my @e = split (",", $v);
	my @tmpCircles = () ;
	foreach my $e (@e) {
	    if ($e =~ m/([0-9]+)/) {
		push @tmpCircles, $1;
	    }
	}
	@circles = @tmpCircles;
    }

    # Should we draw outlines
    if ($q->param('circleOutline') eq "on") {
	$circleOutline = 1;
    } else {
	$circleOutline = 0;
    }

    # Should we label holes
    if ($q->param('numberHoles') eq "on") {
	$numberHoles = 1;
    }


    # Initial rad
    if ($q->param('initialCircleRad')) {
	my $v = $q->param('initialCircleRad');
	if ($v =~ m/([0-9]+)/) {
	    my $v1 = $v;
	    if (($v1 < 1000) && ($v1 > 1)) {
		$initialCircleRad = $v;
#		print FILE "v = $v1\n";
	    }
	}
    }

    # Rad step
    if ($q->param('circleRadStep')) {
	my $v = $q->param('circleRadStep');
	if ($v =~ m/([0-9]+)/) {
	    my $v1 = $v;
	    if (($v1 < 500) && ($v1 > 1)) {
		$circleRadStep = $v;
	    }
	}
    }

    # scaleX
    if ($q->param('scaleX')) {
	my $v = $q->param('scaleX');
	if ($v =~ m/([0-9\.]+)/) {
	    my $v1 = $v;
	    if (($v1 < 30) && ($v1 > 0)) {
		$scaleX = $v1;
#		print FILE "scaleX = $v1\n";
	    }
	}
    }

    # scaleY
    if ($q->param('scaleY')) {
	my $v = $q->param('scaleY');
	if ($v =~ m/([0-9\.]+)/) {
	    my $v1 = $v;
	    if (($v1 < 30) && ($v1 > 0)) {
		$scaleY = $v1;
#		print FILE "scaleY = $v1\n";
	    }
	}
    }
#    close FILE;
}



# Draw outlines for the circles if required
my $circleRad = $initialCircleRad + scalar(@circles) * $circleRadStep;
if ($circleOutline) {
    foreach my $h (@circles) {
	$circleRad -= $circleRadStep;
	DrawCircleOutlines($img, $circleRad);
    }
}



# Draw the centre marker 
DrawCentreHole($img);


# Draw the actual "hole circle"
$circleRad = $initialCircleRad;
foreach my $h (@circles) {
    DrawHoleCircle($img, $h, $circleRad, $numberHoles, $circleOutline);
    $circleRad += $circleRadStep;
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

