###############################################################################
##
## ReidemeisterClass( hom1, hom2, g )
##
InstallMethod( ReidemeisterClass, "for double twisted conjugacy",
	[IsGroupHomomorphism, IsGroupHomomorphism, IsObject],
	function ( hom1, hom2, g )
		local G, H, fam, typ, tc, tcc;
		G := Range( hom1 );
		H := Source( hom1 );
		typ := NewType( FamilyObj( G ), IsReidemeisterClassGroupRep and 
			HasActingDomain and HasRepresentative and HasFunctionAction
		);
		tc := TwistedConjugation( hom1, hom2 );
		tcc := rec();
		ObjectifyWithAttributes(
			tcc, typ,
			ActingDomain, H,
			Representative, g,
			FunctionAction, tc,
			GroupHomomorphismsOfReidemeisterClass, [hom1, hom2]
		);
		return tcc;      
	end 
);


###############################################################################
##
## ReidemeisterClass( endo, g )
##
InstallOtherMethod( ReidemeisterClass, "for twisted conjugacy",
	[IsGroupHomomorphism and IsEndoGeneralMapping, IsObject],
	function ( endo, g )
		return ReidemeisterClass( endo, IdentityMapping( Source( endo ) ), g );
	end 
);

RedispatchOnCondition( ReidemeisterClass, true, 
	[IsGroupHomomorphism, IsObject], [IsEndoGeneralMapping, IsObject], 999 );
	

###############################################################################
##
## Methods for operations/attributes on a ReidemeisterClass
##
InstallMethod( \in, "for Reidemeister classes",
	[IsObject, IsReidemeisterClassGroupRep], 
	function ( g, tcc )
		local r, homs;
		r := Representative( tcc );
		homs := GroupHomomorphismsOfReidemeisterClass( tcc );
		return IsTwistedConjugate( homs[1], homs[2], g, r );
	end 
);

# Only necessary in GAP <= 4.10
InstallMethod( Random, "for Reidemeister classes",
	[IsReidemeisterClassGroupRep],
	function ( tcc )
		local tc;
		tc := FunctionAction( tcc );
		return tc( Representative( tcc ), Random( ActingDomain( tcc ) ) );
	end
);

# Method below seem to be not necessary?
#InstallMethod( HomeEnumerator, "for Reidemeister classes",
#	[IsReidemeisterClassGroupRep],
#	function ( tcc )
#		return Enumerator( ActingDomain( tcc ) );
#	end
#);

InstallMethod( PrintObj, "for Reidemeister classes",
	[IsReidemeisterClassGroupRep],
	function ( tcc )
		local homStrings, homs, i, G, gens;
		homStrings := [];
		homs := GroupHomomorphismsOfReidemeisterClass( tcc );
		for i in [1..2] do
			G := Source( homs[i] );
			if homs[i] = IdentityMapping( G ) then
				gens := PrintString( GeneratorsOfGroup( G ) );
				homStrings[i] := Concatenation( gens, " -> ", gens );
			else
				homStrings[i] := PrintString( homs[i] );
			fi;
		od;
		Print( Concatenation(
			"ReidemeisterClass( [ ",
			homStrings[1],
			", ",
			homStrings[2],
			" ], ",
			PrintString( Representative( tcc ) ),
			" )"
		));
		return;
	end
);


###############################################################################
##
## ReidemeisterClasses( hom1, hom2 )
##
InstallMethod( ReidemeisterClasses, "for finite groups",
	[IsGroupHomomorphism, IsGroupHomomorphism],
	function ( hom1, hom2 )
		local G, H, xset, s, Rcl, i, tcc, pos;
		G := Range( hom1 );
		H := Source( hom1 );
		if not IsFinite( G ) or not IsFinite( H ) then
			TryNextMethod();
		fi;
		xset := AsSSortedListNonstored( G );
		s := HasAsList( G ) or HasAsSSortedList( G );
		Rcl := [];
		for i in OrbitsDomain( H, xset, TwistedConjugation( hom1, hom2 ) ) do
			if One( G ) in i then
				tcc := ReidemeisterClass( hom1, hom2, One( G ) );
				pos := 1;
			else
				tcc := ReidemeisterClass( hom1, hom2, i[1] );
				pos := Length( Rcl )+1;
			fi;
			SetSize( tcc, Length( i ) );
			if s or Length( i ) < 5 then
				SetAsSSortedList( tcc, SortedList( i ) );
			fi;
            Add( Rcl, tcc, pos );
		od;
		return Rcl;
	end
);

InstallMethod( ReidemeisterClasses, "for abelian range",
	[IsGroupHomomorphism, IsGroupHomomorphism],
	function ( hom1, hom2 )
		local G, N, Rcl, p, pg, R;
		G := Range( hom1 );
		if not IsAbelian( G ) then
			TryNextMethod();
		fi;
		N := Image( DifferenceGroupHomomorphisms@( hom1, hom2 ) );
		if IndexNC( G, N ) = infinity then
			return fail;
		else
			Rcl := [];
			p := NaturalHomomorphismByNormalSubgroupNC( G, N );
			R := Range( p );
			for pg in R do
				if pg = One( R ) then
					Add( Rcl, ReidemeisterClass( hom1, hom2, One( G ) ), 1 );
				else
					Add( Rcl, ReidemeisterClass( 
							hom1, hom2, PreImagesRepresentative( p, pg )
						) 
					);
				fi;
			od;
			return Rcl;
		fi;
	end
);

InstallMethod( ReidemeisterClasses, "for torsion-free nilpotent groups",
	[IsGroupHomomorphism and IsEndoGeneralMapping,
	 IsGroupHomomorphism and IsEndoGeneralMapping],
	function ( hom1, hom2 )
		local G, ALCS, Rcl, i, Gi, Gip1, p, hom1N, hom2N, hom1Np, hom2Np, RGiGip1, g, RclFactor, tcc;
		G := Source( hom1 );
		if not IsNilpotentGroup( G ) or not IsTorsionFree( G ) or IsAbelian( G ) then
			TryNextMethod();
		fi;
		ALCS := AdaptedLowerCentralSeriesOfGroup( G );
		Rcl := [ Identity( G ) ];
		for i in [1..Length( ALCS )-1 ] do
			Gi := ALCS[i];
			Gip1 := ALCS[i+1];
			p := NaturalHomomorphismByNormalSubgroupNC( Gi, Gip1 );
			hom1N := RestrictedEndomorphism( hom1, Gi );
			hom2N := RestrictedEndomorphism( hom2, Gi );
			hom1Np := InducedEndomorphism( p, hom1N );
			hom2Np := InducedEndomorphism( p, hom2N );
			RGiGip1 := ReidemeisterClasses( hom1Np, hom2Np );
			if RGiGip1 = fail then
				return fail;
			fi;
			RclFactor := [];
			for tcc in RGiGip1 do
				g := Representative( tcc );
				Add( RclFactor, PreImagesRepresentative( p, g ) );
			od;
			Rcl := List( Cartesian( Rcl, RclFactor ), x -> Product( x ) );
		od;
		Print("hi\n");
		return List( Rcl, x -> ReidemeisterClass( hom1, hom2, x ) );
	end
);


InstallMethod( ReidemeisterClasses, "for nilpotent groups",
	[IsGroupHomomorphism and IsEndoGeneralMapping,
	 IsGroupHomomorphism and IsEndoGeneralMapping],
	function ( hom1, hom2 ) 
		local G, p, RclGN, Rcl, pg, g, ighom1, RclN, iRclN, h, ihghom1, N;
		G := Source( hom1 );
		if not IsNilpotentGroup( G ) or IsTorsionFree( G ) or IsAbelian( G ) then
			TryNextMethod();
		fi;
		N := TorsionSubgroup( G );
		p := NaturalHomomorphismByNormalSubgroupNC( G, N );
		RclGN := ReidemeisterClasses( InducedEndomorphism( p, hom1 ),
			InducedEndomorphism( p, hom2 )
		);
		if RclGN = fail then
			return fail;
		fi;
		RclGN := List( RclGN, g -> PreImagesRepresentative( p, Representative( g ) ) );
		Rcl := [];
		for g in RclGN do
			ighom1 := ComposeWithInnerAutomorphism@( g^-1, hom1 );
			RclN := ReidemeisterClasses( RestrictedEndomorphism( ighom1, N ),
				RestrictedEndomorphism( hom2, N ) 
			);
			if RclN = fail then
				return fail;
			fi;
			RclN := List( RclN, g -> Representative( g ) );
			Append( Rcl, 
				List( RclN, l -> ReidemeisterClass( hom1, hom2, l*g ) ) 
			);
		od;
		return Rcl;
	end
);



InstallMethod( ReidemeisterClasses, "for polycyclic groups",
	[IsGroupHomomorphism and IsEndoGeneralMapping,
	 IsGroupHomomorphism and IsEndoGeneralMapping],
	function ( hom1, hom2 )
		local G;
		G := Source( hom1 );
		if not IsPcpGroup( G ) or IsAbelian( G ) or 
			( IsNilpotent( G ) and IsTorsionFree( G ) ) then
			TryNextMethod();
		fi;
		return ReidemeisterClassesByNormal( hom1, hom2, DerivedSubgroup( G ) );
	end
);


###############################################################################
##
## ReidemeisterClasses( endo )
##
InstallOtherMethod( ReidemeisterClasses,
	[IsGroupHomomorphism and IsEndoGeneralMapping],
	function ( endo )
		return ReidemeisterClasses( endo, IdentityMapping( Source( endo ) ) );
	end
);

RedispatchOnCondition( ReidemeisterClasses, true, 
	[IsGroupHomomorphism], [IsEndoGeneralMapping], 0 );

RedispatchOnCondition( ReidemeisterClasses, true, 
	[IsGroupHomomorphism, IsGroupHomomorphism],
	[IsEndoGeneralMapping, IsEndoGeneralMapping], 0 );


###############################################################################
##
## ReidemeisterClassesByNormal( hom1, hom2, N )
##
InstallMethod( ReidemeisterClassesByNormal,
	[IsGroupHomomorphism and IsEndoGeneralMapping, 
	 IsGroupHomomorphism and IsEndoGeneralMapping, IsGroup], 
	function ( hom1, hom2, N ) 
		local G, p, RclGN, Rcl, pg, g, ighom1, RclN, iRclN, h, ihghom1;
		G := Source( hom1 );
		p := NaturalHomomorphismByNormalSubgroupNC( G, N );
		RclGN := ReidemeisterClasses( InducedEndomorphism( p, hom1 ),
			InducedEndomorphism( p, hom2 )
		);
		if RclGN = fail then
			return fail;
		fi;
		RclGN := List( RclGN, g -> Representative( g ) );
		Rcl := [];
		for pg in RclGN do
			g := PreImagesRepresentative( p, pg );
			# TODO: Calculate preimages immediately?
			ighom1 := ComposeWithInnerAutomorphism@( g^-1, hom1 );
			RclN := ReidemeisterClasses( RestrictedEndomorphism( ighom1, N ),
				RestrictedEndomorphism( hom2, N ) 
			);
			if RclN = fail then
				return fail;
			fi;
			RclN := List( RclN, g -> Representative( g ) );
			iRclN := [Remove( RclN, 1 )];
			for h in RclN do
				# Condition below is basically just
				# IsTwistedConjugate( igendo, k, h )
				# This way of formulating speeds things up
				ihghom1 := ComposeWithInnerAutomorphism@( h^-1, ighom1 );
				if ForAll( iRclN, 
					k -> RepTwistConjToId( ihghom1, hom2, k*h^-1  ) = fail 
				) then
					Add( iRclN, h );
				fi;
			od;
			Append( Rcl, 
				List( iRclN, l -> ReidemeisterClass( hom1, hom2, l*g ) ) 
			);
		od;
		return Rcl;
	end
);

RedispatchOnCondition( ReidemeisterClassesByNormal, true, 
	[IsGroupHomomorphism, IsGroupHomomorphism, IsGroup],
	[IsEndoGeneralMapping, IsEndoGeneralMapping, IsGroup], 999 );
	