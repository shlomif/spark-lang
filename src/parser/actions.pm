# $Id$

=begin comments

Steme::Grammar::Actions - ast transformations for Steme

This file contains the methods that are used by the parse grammar
to build the PAST representation of an Steme program.
Each method below corresponds to a rule in F<src/parser/grammar.pg>,
and is invoked at the point where C<{*}> appears in the rule,
with the current match object as the first argument.  If the
line containing C<{*}> also has a C<#= key> comment, then the
value of the comment is passed as the second argument to the method.

=end comments

class Steme::Grammar::Actions;

method TOP($/) {
    my $past := PAST::Block.new( :blocktype('declaration'), :node( $/ ) );
    for $<statement> {
        $past.push( $( $_ ) );
    }
    make $past;
}


method statement($/, $key) {
    make $( $/{$key} );
}

method special($/, $key) {
    make $( $/{$key} );
}

method if($/) {
    make PAST::Op.new( $( $<cond> ), $( $<iftrue> ), $( $<iffalse> ), :pasttype('if'), :node( $/ ) );
}

method define($/) {
    my $var := $( $<var> );
    $var.isdecl(1);
    my $val := $( $<val> );
    make PAST::Op.new( $var, $val, :pasttype('bind'), :node( $/ ) );
}

method simple($/) {
    my $past := PAST::Op.new( $( $<cmd> ), :pasttype('call'), :node( $/ ) );
    for $<term> {
        $past.push( $( $_ ) );
    }
    make $past;
}

##  term:
##    Like 'statement' above, the $key has been set to let us know
##    which term subrule was matched.
method term($/, $key) {
    make $( $/{$key} );
}


method value($/, $key) {
    make $( $/{$key} );
}


method integer($/) {
    make PAST::Val.new( :value( ~$/ ), :returns('Integer'), :node($/) );
}


method quote($/) {
    make PAST::Val.new( :value( $($<string_literal>) ), :node($/) );
}

method symbol($/) {
    make PAST::Var.new( :name( ~$<symbol> ), :scope('package') );
}


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
