###############################################################################
##
## ReidemeisterZetaCoefficients( endo1, endo2 )
##
InstallMethod(
	ReidemeisterZetaCoefficients,
	"for finite groups",
	[ IsGroupHomomorphism and IsEndoGeneralMapping,
	  IsGroupHomomorphism and IsEndoGeneralMapping ],
	function ( endo1, endo2 )
		local G, k, l, steps, G1, G2, endo, R, P, Q;
		G := Range( endo1 );
		if not IsFinite( G ) then
			TryNextMethod();
		fi;
		k := 1;
		l := 0;
		for endo in [ endo1, endo2 ] do
			steps := -1;
			G2 := G;
			repeat
				steps := steps + 1;
				G1 := G2;
				G2 := ImagesSet( endo, G1 );
			until G1 = G2;
			k := LcmInt( k, Order( RestrictedMapping( endo, G1 ) ) );
			l := Maximum( l, steps );
		od;
		R := List( [1..k+l], n -> ReidemeisterNumber( endo1^n, endo2^n ) );
		R := Concatenation(
			R{ [1..l] },
			RemovePeriodsList@( R{ [ 1+l..k+l ] } )
		);
		k := Length( R ) - l;
		P := List( [1..k], n -> R[ (n-l-1) mod k + 1 + l ] );
		Q := List( [1..l], n -> R[n] - P[ (n-1) mod k + 1 ] );
		ShrinkRowVector( Q );
		return [ P, Q ];
	end
);

RedispatchOnCondition(
	ReidemeisterZetaCoefficients,
	true,
	[ IsGroupHomomorphism, IsGroupHomomorphism ],
	[ IsEndoGeneralMapping, IsEndoGeneralMapping ],
	0
);


###############################################################################
##
## ReidemeisterZetaCoefficients( endo )
##
InstallOtherMethod(
	ReidemeisterZetaCoefficients,
	[ IsGroupHomomorphism and IsEndoGeneralMapping ],
	function ( endo )
		local G;
		G := Range( endo );
		return ReidemeisterZetaCoefficients( endo, IdentityMapping( G )	);
	end
);

RedispatchOnCondition(
	ReidemeisterZetaCoefficients,
	true,
	[ IsGroupHomomorphism ],
	[ IsEndoGeneralMapping ],
	0
);


###############################################################################
##
## IsRationalReidemeisterZeta( endo1, endo2 )
##
InstallMethod(
	IsRationalReidemeisterZeta,
	"for finite groups",
	[ IsGroupHomomorphism and IsEndoGeneralMapping,
	  IsGroupHomomorphism and IsEndoGeneralMapping ],
	function ( endo1, endo2 )
		local G, coeffs;
		G := Range( endo1 );
		if not IsFinite( G ) then
			TryNextMethod();
		fi;
		coeffs := ReidemeisterZetaCoefficients( endo1, endo2 );
		if not IsEmpty( coeffs[2] ) then
			return false;
		fi;
		if DecomposePeriodicList@( coeffs[1] ) = fail then
			return false;
		fi;
		return true;
	end
);

RedispatchOnCondition(
	IsRationalReidemeisterZeta,
	true,
	[ IsGroupHomomorphism, IsGroupHomomorphism ],
	[ IsEndoGeneralMapping, IsEndoGeneralMapping ],
	0
);


###############################################################################
##
## IsRationalReidemeisterZeta( endo )
##
InstallOtherMethod(
	IsRationalReidemeisterZeta,
	"for finite groups",
	[ IsGroupHomomorphism and IsEndoGeneralMapping ],
	1,
	function ( endo )
		local G;
		G := Range( endo );
		if IsFinite( G ) then
			return true;
		else
			TryNextMethod();
		fi;
	end
);

RedispatchOnCondition(
	IsRationalReidemeisterZeta,
	true,
	[ IsGroupHomomorphism ],
	[ IsEndoGeneralMapping ],
	0
);


###############################################################################
##
## ReidemeisterZeta( endo1, endo2 )
##
InstallMethod(
	ReidemeisterZeta,
	"for rational Reidemeister zeta functions of finite groups",
	[ IsGroupHomomorphism and IsEndoGeneralMapping,
	  IsGroupHomomorphism and IsEndoGeneralMapping ],
	function ( endo1, endo2 )
		local G, coeffs, p;
		G := Range( endo1 );
		if not IsFinite( G ) then
			TryNextMethod();
		fi;
		coeffs := ReidemeisterZetaCoefficients( endo1, endo2 );
		if not IsEmpty( coeffs[2] ) then
			return fail;
		fi;
		p := DecomposePeriodicList@( coeffs[1] );
		if p = fail then
			return fail;
		fi;
		return function ( s )
			local zeta, i;
			zeta := 1;
			for i in [1..Length( p )] do
				if p[i] <> 0 then
					zeta := zeta*( 1-s^i )^-p[i];
				fi;
			od;
			return zeta;
		end;
	end
);

RedispatchOnCondition(
	ReidemeisterZeta,
	true,
	[ IsGroupHomomorphism, IsGroupHomomorphism ],
	[ IsEndoGeneralMapping, IsEndoGeneralMapping ],
	0
);


###############################################################################
##
## ReidemeisterZeta( endo )
##
InstallOtherMethod(
	ReidemeisterZeta,
	[ IsGroupHomomorphism and IsEndoGeneralMapping ],
	function ( endo )
		local G;
		G := Range( endo );
		return ReidemeisterZeta( endo, IdentityMapping( G ) );
	end
);

RedispatchOnCondition(
	ReidemeisterZeta,
	true, 
	[ IsGroupHomomorphism ],
	[ IsEndoGeneralMapping ],
	0
);


###############################################################################
##
## PrintReidemeisterZeta( endo1, endo2 )
##
InstallMethod(
	PrintReidemeisterZeta,
	"for finite groups",
	[ IsGroupHomomorphism and IsEndoGeneralMapping,
	  IsGroupHomomorphism and IsEndoGeneralMapping ],
	function ( endo1, endo2 )
		local G, coeffs, P, Q, q, i, qi, zeta, factors, powers, p, k, pi;
		G := Range( endo1 );
		if not IsFinite( G ) then
			TryNextMethod();
		fi;
		coeffs := ReidemeisterZetaCoefficients( endo1, endo2 );
		P := coeffs[1];
		Q := coeffs[2];
		if not IsEmpty( Q ) then
			q := "";
			for i in [1..Length( Q )] do
				if Q[i] = 0 then
					continue;
				fi;
				if q <> "" and Q[i] > 0 then
					q := Concatenation( q, "+" );
				elif Q[i] < 0 then
					q := Concatenation( q, "-" );
				fi;
				qi := AbsInt( Q[i] )/i;
				if qi = 1 then
					q := Concatenation( q, "s" );
				else
					q := Concatenation( q, PrintString( qi ), "*s" );
				fi;
				if i <> 1 then
					q := Concatenation( q, "^", PrintString( i ) );
				fi;
			od;
			zeta := Concatenation( "exp(", q, ")" );
		else
			zeta := "";
		fi;
		factors := [];
		powers := [];
		p := DecomposePeriodicList@TwistedConjugacy( P );
		if p = fail then
			k := Length( P );
			for i in [0..k-1] do
				pi := ValuePol( ShiftedCoeffs( P, 1 ), E(k)^-i )/k;
				if pi = 0 then
					continue;
				fi;
				if i = k/2 then
					Add( factors, "1+s" );
				elif i = 0 then
					Add( factors, "1-s" );
				elif i = 1 then
					Add( factors, Concatenation(
						"1-E(",
						PrintString( k ),
						")*s"
					));
				elif i = k/2+1 then
					Add( factors, Concatenation(
						"1+E(",
						PrintString( k ),
						")*s"
					));
				elif k mod 2 = 0 and i > k/2 then
					Add( factors, Concatenation(
						"1+E(",
						PrintString( k ),
						")^",
						PrintString( i-k/2 ),
						"*s"
					));
				else
					Add( factors, Concatenation(
						"1-E(",
						PrintString( k ),
						")^",
						PrintString( i ),
						"*s"
					));
				fi;
				Add( powers, -pi );
			od;
		else
			for i in [1..Length( p )] do
				if p[i] = 0 then
					continue;
				fi;
				if i > 1 then
					Add( factors, Concatenation( "1-s^", PrintString( i ) ) );
				else
					Add( factors, "1-s" );
				fi;
				Add( powers, -p[i] );
			od;
		fi;
		for i in [1..Length( factors )] do
			if zeta <> "" then
				zeta := Concatenation( zeta, "*" );
			fi;
			zeta := Concatenation( zeta, "(", factors[i], ")" );
			if not IsPosInt( powers[i] ) then
				zeta := Concatenation(
					zeta,
					"^(",
					PrintString( powers[i] ),
					")"
				);
			elif powers[i] <> 1 then
				zeta := Concatenation(
					zeta,
					"^",
					PrintString( powers[i] )
				);
			fi;
		od;
		return zeta;
	end
);

RedispatchOnCondition(
	PrintReidemeisterZeta,
	true,
	[ IsGroupHomomorphism, IsGroupHomomorphism ],
	[ IsEndoGeneralMapping, IsEndoGeneralMapping ],
	0
);


###############################################################################
##
## PrintReidemeisterZeta( endo )
##
InstallOtherMethod(
	PrintReidemeisterZeta,
	[ IsGroupHomomorphism and IsEndoGeneralMapping ],
	function ( endo )
		local G;
		G := Range( endo );
		return PrintReidemeisterZeta( endo, IdentityMapping( G ) );
	end
);

RedispatchOnCondition(
	PrintReidemeisterZeta,
	true,
	[ IsGroupHomomorphism ],
	[ IsEndoGeneralMapping ],
	0
);