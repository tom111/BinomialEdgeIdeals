newPackage("BEI",
	Version => "1.0",
	Date => "March 2015",
	Authors => {
     {Name => "Tobias Windisch",
      Email => "windisch@ovgu.de",
      HomePage => "http://www-e.uni-magdeburg.de/windisch/"}},
   Headline => "Package for computations with  binomial edge ideals",
	Configuration => {},
	Reload=>true
	)

export {

   --methods
   binomialEdgeIdeal,
   parityBinomialEdgeIdeal,
   disconnectors,
   isDisconnector,
   isEffective,
   s,

   -- wrapper
   bei,
   pbei,

   --Options
   Field,
   Permanental,
   TermOrder, 
   EffectiveOnly,
   UseHypergraphs
}


---------------------------------------------
--       TODO
-- isEffective computations using hypergraphs
-- give method s a better name
---------------------------------------------

--variable for polynomial ring
xx:=vars(23);
yy:=vars(24);


needsPackage "Graphs";
needsPackage "Binomials";

--------------------------------
-- Parity Binomial Edge Ideal --
--------------------------------

parityBinomialEdgeIdeal = method (Options => {Field =>
QQ,TermOrder=>Lex, Permanental=>false})
parityBinomialEdgeIdeal List := Ideal => opts -> E -> (parityBinomialEdgeIdeal(graph E,opts));
parityBinomialEdgeIdeal Graph := Ideal => opts -> G -> (
v:=vertices(G);
c:=0;
e:=apply(edges(G),toList);
R:=(opts.Field)[(for vv in v list xx_(vv))|(for vv in v list yy_(vv)),MonomialOrder=>opts.TermOrder];
if opts.Permanental then c=1 else c=-1;
return ideal for ee in e list (xx_(ee_0))_R*(xx_(ee_1))_R+c*(yy_(ee_0))_R*(yy_(ee_1))_R;
);


binomialEdgeIdeal = method (Options => {Field=>QQ,TermOrder=>Lex,Permanental=>false})
binomialEdgeIdeal List := Ideal => opts -> E -> (binomialEdgeIdeal(graph E,opts));
binomialEdgeIdeal Graph := Ideal => opts -> G -> (
v:=vertices(G);
c:=0;
e:=apply(edges(G),toList);
R:=(opts.Field)[(for vv in v list xx_(vv))|(for vv in v list yy_(vv)),MonomialOrder=>opts.TermOrder];
if opts.Permanental then c=1 else c=-1;
return ideal for ee in e list (xx_(ee_0))_R*(yy_(ee_1))_R+c*(yy_(ee_0))_R*(xx_(ee_1))_R;
);


pbei = O -> parityBinomialEdgeIdeal O
bei = O -> binomialEdgeIdeal O

--------------------------------
--        Disconnectors       --
--------------------------------

disconnectors = method (Options => {EffectiveOnly => false})
disconnectors List := List => opts -> E ->(disconnectors(graph(E),opts))
disconnectors Graph := List => opts -> G ->(
D:={};
if opts.EffectiveOnly == true  then (
    I:=pbei(G,Field=>QQ);
    R:=ring I;
    P:=binomialMinimalPrimes I;
    V:=set();
    v:="";

    for PP in P do (
        V=set();
        for g in PP_* do (
            if member(g,gens R) then (
                v=baseName(g_R);
                V=V+set{v#1}
                );
            ); 
        D=D|{V};
        ); 
    ); 

if opts.EffectiveOnly == false then (
    for S in subsets(vertices(G)) do (
        if #S<#(vertices G) then 
            if isDisconnector(G,S) then D=D|{S};    
        );
    );     
return apply(unique D,toList);
);


isDisconnector = method ()
isDisconnector (Graph,Set) := Boolean => (G,S) -> (isDisconnector(G,toList(S)));
isDisconnector (Graph,List) := Boolean => (G,S) -> (
GS:=deleteVertices(G,S);
sGS:=s(GS);
for v in S do (if sGS <= s(deleteVertices(G,delete(v,S))) then return false);
return true;
);


isEffective = method (Options => {UseHypergraphs => false})
isEffective (Graph,Set) := Boolean => opts -> (G,S) -> (isEffective(G,toList(S),opts));
isEffective (Graph,List) := Boolean => opts -> (G,S) -> (
if not isDisconnector(G,S) then return false;
if opts.UseHypergraphs = false then (
    d:=disconnectors(G,EffectiveOnly=>true);
    return member(set(d),apply(d,set));
    );
if opts.UseHypergraphs = true then (
   << "not implemented yet"; 
    );
);

s = method()
s Graph := ZZ => G -> (
nb:=0;
b:=0;
for H in connectedComponents(G) do (
--bug in Graph package: isBipartite(emptygraph) gives error
    IG:=inducedSubgraph(G,H);
    if #(edges IG) > 0 then (
        if isBipartite(IG) then b=b+1 else nb=nb+1; 
        ) else b=b+1;
    );
return 2*b+nb;
);


-- End of source code ---

beginDocumentation()


document {
        Key => BEI,
        Headline => "a package for binomial edge ideals",

        EM "BEI", " is a package for computations with binomial edge
        ideals",
	
	BR{},BR{},
	BOLD "Literature \n",
	UL {
	  LI {"[HHHTR2010] ", EM "Binomial edge ideals and conditional
     independence statements ", "(J. Herzog, T. Hibi, F. Hreinsdottir,
     T. Kahle, J. Rauh, 2010).\n"},
	  LI {"[HMMW2014] ", EM "On the ideal of orthogonal representations
     of a graph in R^2 ", "(J. Herzog, A. Macchia, S. Madani,
     V. Welker, 2014).\n"},
	  LI {"[KSW2015] ", EM "Parity binomial edge ideals ", "(T. Kahle,
     C. Sarmiento, T. Windisch, 2015)"}}}

document {
     Key => {parityBinomialEdgeIdeal,
	  (parityBinomialEdgeIdeal, Graph), (parityBinomialEdgeIdeal, List)},
     Headline => "Parity binomial edge ideals",
     Usage => "parityBinomialEdgeIdeal G",
     Inputs => {
          "G" => { "a graph"} },
     Outputs => {
          {"the parity binomial edge ideal of G"} },
     "This routine returns the (permanental) parity binomial edge ideal of G.",
     EXAMPLE {
          "G=graph({{1,2},{2,3},{3,1}})",
          "I = parityBinomialEdgeIdeal(G,Field=>ZZ/2)",
          "J = parityBinomialEdgeIdeal(G)"
          },
     "A synonym for this function is ", TO pbei, ".",
     SeeAlso => {pbei,binomialEdgeIdeal}}

document {
     Key => pbei,
     Headline => "Parity binomial edge ideal",
     "pbei is a synonym for ", TO parityBinomialEdgeIdeal ,"."}

document {
     Key => {binomialEdgeIdeal,
	  (binomialEdgeIdeal, Graph), (binomialEdgeIdeal, List)},
     Headline => "Binomial edge ideals",
     Usage => "binomialEdgeIdeal G",
     Inputs => {
          "G" => { "a graph"} },
     Outputs => {
          {"the binomial edge ideal of G"} },
     "This routine returns the (permanental) binomial edge ideal of G.",
     EXAMPLE {
          "G=graph({{1,2},{2,3},{3,1}})",
          "I = binomialEdgeIdeal(G,Field=>ZZ/2)",
          "J = binomialEdgeIdeal(G,Permanental=>true)"
          },
     "A synonym for this function is ", TO bei, ".",
     SeeAlso => {bei,parityBinomialEdgeIdeal}}

document {
     Key => bei,
     Headline => "Binomial edge ideal",
     "bei is a synonym for ", TO binomialEdgeIdeal ,"."}

document {
     Key => {disconnectors,
	  (disconnectors, Graph), (disconnectors,List)},
     Headline => "Disconnectors of a graph",
     Usage => "disconnectors G",
     Inputs => {
          "G" => { "a graph"} },
     Outputs => {
          {"the disconnectors of G"} },
     "This routine computes the disconnectors of the parity binomial
     edge ideal and the permanental binomial edge ideal of G",
     EXAMPLE {
          "G=graph({{1,2},{2,3},{3,1}})",
          "d = disconnectors(G)",
          "d = disconnectors(G,EffectiveOnly=>true)"
          },
     SeeAlso => isEffective}

document {
     Key => {isDisconnector,
	  (isDisconnector, Graph, Set), (isDisconnector,Graph,List)},
     Headline => "A test for being a disconnector",
     Usage => "isDisconnector(G,S)",
     Inputs => {
          "G" => { "a graph"},
          "S" => { "a List or a Set"}},
     Outputs => {
          {"true or false, depending on wheater S is a disconnector of
          G"} },
     "This routine checks wheater a Set or a List is a disconnector of
     a graph",
     EXAMPLE {
          "G=graph({{1,2},{2,3},{3,1}})",
          "S={1}",
          "isDisconnector(G,S)"
          },
     SeeAlso => disconnectors}


document {
     Key => {isEffective,
	  (isEffective, Graph, Set), (isEffective,Graph,List)},
     Headline => "A test for being an effective disconnector",
     Usage => "isEffective(G,S)",
     Inputs => {
          "G" => { "a graph"},
          "S" => { "a List or a Set"}},
     Outputs => {
          {"true or false, depending on whether S is an effective disconnector of
          G"} },
     "This routine checks whether a Set or a List is an effective disconnector of
     a graph",
     EXAMPLE {
          "G=graph({{1,2},{2,3},{3,1}})",
          "S={1}",
          "isEffective(G,S)"
          },
     SeeAlso => disconnectors}
