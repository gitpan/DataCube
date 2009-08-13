


package DataCube::Cube::Style::HTML::CSS;

use strict;
use warnings;

sub new {
    my($class,%opts) = @_;
    my $self = bless { %opts }, ref($class) || $class;
    $self->{default_css} = $self->default_css;
    return $self;
}

sub css {
    my($self,$css) = @_;
    ($self->{css}) = ($css) and return $self if $css;
    return $self->{css} || $self->{default_css};
}

sub default_css {
    my($self,%opts) = @_;
    my $css = '
        <style type="text/css">
            p {
                font-family:    "Verdana", sans-serif;
                font-size:       70%;
                line-height:    12pt;
                margin-bottom:   0px;
                margin-left:    10px;
                margin-top:     10px;
            }
            body {
                background-color:   white;
                font-family:        "Verdana", sans-serif;
                font-size:          100%;
                margin-left:        0px;
                margin-top:         0px;
            } 
            .note {
                background-color:   #ffffff;
                color:              #336699;
                font-family:        "verdana", sans-serif;
                font-size:          100%;
                margin-bottom:       0px;
                margin-left:         0px;
                margin-top:          0px;
                padding-right:      10px;
            }
            .infotable {
                background-color:   #f0f0e0;
                border-bottom:      #ffffff 0px solid;
                border-collapse:    collapse;
                border-left:        #ffffff 0px solid;
                border-right:       #ffffff 0px  solid;
                border-top:         #ffffff 0px solid;
                border-color:       white;
                font-size:          70%;
                margin-left:        10px;
            } 
            .header {
                background-color:   #cecf9c;
                border-bottom:      #ffffff 1px solid;
                border-left:        #ffffff 1px solid;
                border-right:       #ffffff 1px solid;
                border-top:         #ffffff 1px solid;
                color:              #000000;
                font-weight:        bold;
            } 
            .content {
                background-color:   #e7e7ce;
                border-bottom:      #ffffff 1px solid;
                border-left:        #ffffff 1px solid;
                border-right:       #ffffff 1px solid;
            	border-top:         #ffffff 1px solid;
                padding-left:       3px;
            } 
            h1 {
                background-color:   #484448;
                border-bottom:      #336699 6px solid;
                color:              #ffffff;
                font-size:          130%;
                font-weight:        normal;
                margin:             0em 0em 0em -20px;
                padding-bottom:      8px;
                padding-left:       30px;
                padding-top:        16px;
            } 
            h2 {
                color:              #000000;
                font-size:          80%;
                font-weight:        normal;
                margin-bottom:       3px;
                margin-left:        10px;
                margin-top:         20px;
                padding-right:      20px;
            } 
            .foot {
                background-color:   #ffffff;
                border-bottom:      #ffffff 1px solid;
                border-top:         #ffffff 1px solid;
            }
            .footr {
                background-color:   #ffffff;
                border-bottom:      #ffffff 1px solid;
                border-top:         #ffffff 1px solid;
                border-right:       #efefef 1px solid;
            } 
            .beforeline {
                background-color:   red;
                color:              red;
            }
            .afterline {
                background-color:   green;
                color:              green;
            }
            a:link {
                color:              #336699;
                text-decoration:    underline;
            } 
            a:visited {
                color:              #336699;
            } 
            a:active {
                color:              #336699;
            }
            a:hover {
                color:              #003366;
                text-decoration:    underline;
            }
        </style>';

}


1;








