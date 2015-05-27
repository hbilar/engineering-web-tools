
package HBCommon;

$HBCommon::progname = $0;
my $dirname = $progname;
{
    my @p = split("/", $progname);
    $progname = $p[-1];
}
$dirname =~ s/\/[^\/]*?$//;
$HBCommon::dirname = $dirname;


sub DisplayHTMLData
{
    my $f = shift;

    if (open(FILE, "<$f")) {
	my @f = <FILE>;
	print @f;
	close FILE;
    } else {
	print "<font color=Red><b>ERROR: Cannot open file $f</b></font><br>\n";
    }
}


# Read a parameter from the CGI parameters and make sure there's no
# funny business going on (use pattern matching to grab data)
# Args: CGI object, parameter name, default value (optional)
sub SanitizedParameterNumber
{
    my $q = shift;
    my $paramName = shift;
    my $default = shift;
    if ((not defined($default)) || ($default eq '')) {
	$default = 0;
    } 

    my $rv = $default;
    if ($q->param($paramName)) {

	my $v = $q->param($paramName);
	if ($v =~ m/([0-9\.]+)/) {
	    $rv = $1;
	}
    }
    return $rv;
}


# Read a parameter from the CGI parameters and make sure there's no
# funny business going on (use pattern matching to grab data)
# Args: CGI object, parameter name, default value (optional)
sub SanitizedParameterCheckbox
{
    my $q = shift;
    my $paramName = shift;
    my $default = shift;
    if ((not defined($default)) || ($default eq '')) {
	$default = 0;
    } 

    my $rv = $default;
    if ($q->param($paramName) eq "on") {
	$rv = 1;
    } else {
	$rv = 0;
    }
    return $rv;
}

1;
