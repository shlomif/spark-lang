=head1 TITLE

spark.pir - A Spark compiler.

=head2 Description

This is the base file for the Spark compiler.

This file includes the parsing and grammar rules from
the src/ directory, loads the relevant PGE libraries,
and registers the compiler under the name 'Spark'.

=head2 Functions

=over 4

=item onload()

Creates the Spark compiler using a C<PCT::HLLCompiler>
object.

=cut

.HLL 'spark'

.namespace []

.loadlib 'spark_group'

.sub '' :anon :load :init
    load_bytecode 'PCT.pbc'
    .local pmc parrotns, hllns, exports
    parrotns = get_root_namespace ['parrot']
    hllns = get_hll_namespace
    exports = split ' ', 'PAST PCT PGE'
    parrotns.'export_to'(hllns, exports)
.end

.include 'src/gen_grammar.pir'
.include 'src/gen_actions.pir'

.namespace [ 'Spark';'Compiler' ]
.sub 'onload' :anon :load :init
    .local pmc spark
    $P0 = get_root_global ['parrot'], 'P6metaclass'
    spark = $P0.'new_class'('Spark::Compiler', 'parent'=>'PCT::HLLCompiler')
    spark.'language'('spark')
    $P0 = get_hll_namespace ['Spark';'Grammar']
    spark.'parsegrammar'($P0)
    $P0 = get_hll_namespace ['Spark';'Grammar';'Actions']
    spark.'parseactions'($P0)

    ## Create a list for holding the stack of nested blocks
    $P0 = new 'ResizablePMCArray'
    set_hll_global ['Spark';'Grammar';'Actions'], '@?BLOCK', $P0
    $P0 = new 'ResizablePMCArray'
    set_hll_global ['Spark';'Grammar';'Actions'], '@?LIBRARY', $P0
.end

=item main(args :slurpy)  :main

Start compilation by passing any command line C<args>
to the Spark compiler.

=cut

.sub 'main' :main
    .param pmc args

    $P0 = compreg 'spark'
    $P1 = $P0.'command_line'(args)
.end

.sub 'load_library' :method
    .param pmc ns
    .param pmc extra :named :slurpy
    .local pmc sourcens, ex, library
    .local string file, lang
    file = join '/', ns
    file = concat file, '.scm'
    # TODO We need a registry to prevent re-loading
    # TODO We need a search path
    self.'evalfiles'(file, 'encoding'=>'utf8', 'transcode'=>'ascii iso-8859-1')

    library = root_new ['parrot';'Hash']
    sourcens = get_hll_namespace ns
    library['name'] = ns
    library['namespace'] = sourcens
    $P0 = root_new ['parrot';'Hash']
    $P0['ALL'] = sourcens
    ex = sourcens['@EXPORTS']
    if null ex goto no_ex
    $P1 = root_new ['parrot';'NameSpace']
    sourcens.'export_to'($P1, ex)
    $P0['DEFAULT'] = $P1
    goto have_ex
  no_ex:
    $P0['DEFAULT'] = sourcens
  have_ex:
    library['symbols'] = $P0
    .return (library)
.end

.namespace []
.include 'src/gen_builtins.pir'

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

